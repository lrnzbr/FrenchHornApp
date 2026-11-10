import XCTest
import AVFoundation
@testable import HornMusicCore

final class ReferenceSamplerTests: XCTestCase {
    private var sounds: URL {
        URL(fileURLWithPath: #filePath).deletingLastPathComponent()
            .deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("FrenchHornApp/Sounds")
    }

    /// Exercise the shipped sampler preset and recording, not just MIDI/frequency arithmetic.
    /// Rendering is offline: it never opens a microphone or plays through a speaker.
    private func render(midi: UInt8) throws -> [Float] {
        let source = try Data(contentsOf: sounds.appendingPathComponent("FrenchHorn.aupreset"))
        var preset = try XCTUnwrap(PropertyListSerialization.propertyList(from: source, format: nil) as? [String: Any])
        var references = try XCTUnwrap(preset["file-references"] as? [String: String])
        // Bind the sample to this checkout; the original authoring path is not portable.
        for key in references.keys {
            references[key] = sounds.appendingPathComponent(URL(fileURLWithPath: references[key]!).lastPathComponent).path
        }
        preset["file-references"] = references
        let temporary = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".aupreset")
        try PropertyListSerialization.data(fromPropertyList: preset, format: .xml, options: 0).write(to: temporary)
        defer { try? FileManager.default.removeItem(at: temporary) }

        let engine = AVAudioEngine()
        let sampler = AVAudioUnitSampler()
        engine.attach(sampler)
        let format = try XCTUnwrap(AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 2))
        engine.connect(sampler, to: engine.mainMixerNode, format: format)
        try sampler.loadInstrument(at: temporary)
        sampler.reset()
        try engine.enableManualRenderingMode(.offline, format: format, maximumFrameCount: 512)
        try engine.start()
        defer { engine.stop() }
        sampler.startNote(midi, withVelocity: 90, onChannel: 0)
        defer { sampler.stopNote(midi, onChannel: 0) }
        let buffer = try XCTUnwrap(AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 512))
        var result: [Float] = []
        for _ in 0..<64 {
            XCTAssertEqual(try engine.renderOffline(512, to: buffer), .success)
            let samples = try XCTUnwrap(buffer.floatChannelData?[0])
            result.append(contentsOf: UnsafeBufferPointer(start: samples, count: Int(buffer.frameLength)))
        }
        return result
    }

    /// First strongly repeating period avoids mistaking a bright horn harmonic for its fundamental.
    private func fundamental(_ samples: [Float], startingAt start: Int) throws -> Double {
        let count = 2_048
        let maximumLag = 900
        XCTAssertGreaterThan(samples.count, start + count + maximumLag)
        var error = [Double](repeating: 1, count: maximumLag + 1)
        for lag in 20...maximumLag {
            var difference = 0.0
            var energy = 0.0
            for index in 0..<count {
                let a = Double(samples[start + index])
                let b = Double(samples[start + index + lag])
                difference += (a - b) * (a - b)
                energy += a * a + b * b
            }
            error[lag] = energy > 0.000001 ? difference / energy : 1
        }
        let lag = try XCTUnwrap((21..<maximumLag).first {
            error[$0] < 0.1 && error[$0] < error[$0 - 1] && error[$0] <= error[$0 + 1]
        }, "No stable fundamental in rendered reference")
        let a = error[lag - 1], b = error[lag], c = error[lag + 1]
        let correction = 0.5 * (a - c) / (a - 2 * b + c)
        return 44_100 / (Double(lag) + correction)
    }

    func testRenderedReferenceMatchesConcertPitchAndOctaveForBothWrittenKeys() throws {
        // C5 in F -> F4; C5 in B♭ -> B♭4. Include a lower register and an accidental.
        for (index, midi) in [(1, C5.noteNumber), (4, C5.noteNumber), (1, C4.noteNumber), (1, CSharp5.noteNumber)] {
            let selection = FingeringSelection(instrument: instruments[index], writtenMIDI: midi)
            let samples = try render(midi: UInt8(try XCTUnwrap(selection.soundingPitch).midiNoteNumber))
            let expected = try XCTUnwrap(selection.frequency)
            for start in [8_192, 16_384] {
                let frequency = try fundamental(samples, startingAt: start)
                let cents = 1_200 * log2(frequency / expected)
                XCTAssertEqual(cents, 0, accuracy: 12,
                    "Written MIDI \(midi), instrument \(index + 1): expected \(expected) Hz, rendered \(frequency) Hz")
            }
        }
    }
}
