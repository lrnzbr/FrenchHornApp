import XCTest
import AVFoundation
@testable import HornMusicCore

final class MetronomeAudioRendererTests: XCTestCase {
    private func settings(_ bpm: Double) -> MetronomeSettings {
        MetronomeSettings(bpm: bpm, meter: .fourFour, accentFirstBeat: true)!
    }

    /// Runs the production source node without a speaker, microphone, or wall-clock waits.
    private func render(sampleRate: Double, firstFrames: Int, followingFrames: Int = 0,
                        tempoAfterFirst: Double? = nil, chunk: Int = 512) throws -> [Float] {
        let renderer = try XCTUnwrap(MetronomeAudioRenderer(sampleRate: sampleRate, settings: settings(120)))
        let engine = AVAudioEngine()
        let source = renderer.makeSourceNode()
        engine.attach(source)
        engine.connect(source, to: engine.mainMixerNode, format: renderer.format)
        try engine.enableManualRenderingMode(.offline, format: renderer.format, maximumFrameCount: AVAudioFrameCount(chunk))
        try engine.start()
        defer { engine.stop() }
        let buffer = try XCTUnwrap(AVAudioPCMBuffer(pcmFormat: renderer.format, frameCapacity: AVAudioFrameCount(chunk)))
        var result: [Float] = []
        func appendFrames(_ count: Int) throws {
            var remaining = count
            while remaining > 0 {
                let frames = AVAudioFrameCount(min(chunk, remaining))
                let status = try engine.renderOffline(frames, to: buffer)
                guard status == .success else {
                    XCTFail("Offline rendering failed: \(status.rawValue)")
                    return
                }
                let samples = try XCTUnwrap(buffer.floatChannelData?.pointee)
                result.append(contentsOf: UnsafeBufferPointer(start: samples, count: Int(buffer.frameLength)))
                remaining -= Int(buffer.frameLength)
            }
        }
        try appendFrames(firstFrames)
        if let tempo = tempoAfterFirst { renderer.update(settings: settings(tempo)) }
        try appendFrames(followingFrames)
        return result
    }

    private func onsets(_ samples: [Float]) -> [Int] {
        var silence = 128
        var result: [Int] = []
        for (frame, sample) in samples.enumerated() {
            if abs(sample) > 0.00001 {
                if silence >= 128 { result.append(frame) }
                silence = 0
            } else { silence += 1 }
        }
        return result
    }

    func testRenderedClicksUseTheAudioClockAtDifferentSampleRatesAndBufferSizes() throws {
        for (rate, chunk) in [(44_100.0, 256), (48_000.0, 1_024), (96_000.0, 512)] {
            let samples = try render(sampleRate: rate, firstFrames: Int(rate * 2), chunk: chunk)
            let clicks = onsets(samples)
            XCTAssertEqual(clicks.count, 4)
            for (index, frame) in clicks.enumerated() {
                XCTAssertEqual(Double(frame), Double(index) * rate / 2 + 1, accuracy: 2)
            }
        }
    }

    func testRendererAppliesLiveTempoWithoutAnExtraClick() throws {
        let samples = try render(sampleRate: 48_000, firstFrames: 12_000,
                                 followingFrames: 60_000, tempoAfterFirst: 60)
        let clicks = onsets(samples)
        XCTAssertEqual(clicks.count, 2)
        XCTAssertEqual(clicks.first, 1)
        XCTAssertEqual(Double(clicks.last!), 36_001, accuracy: 2)
    }

    func testFastLiveTempoChangeUpdatesSubsequentIntervals() throws {
        let samples = try render(sampleRate: 48_000, firstFrames: 12_000,
                                 followingFrames: 48_000, tempoAfterFirst: 208)
        let clicks = onsets(samples)
        XCTAssertEqual(clicks.count, 4)
        let firstNewClick = 12_000.0 + 12_000 * 120 / 208
        for (index, frame) in clicks.dropFirst().enumerated() {
            XCTAssertEqual(Double(frame), firstNewClick + Double(index) * 48_000 * 60 / 208 + 1, accuracy: 2)
        }
    }

    func testConcurrentParameterChangesAndRenderingRemainSafe() throws {
        let renderer = try XCTUnwrap(MetronomeAudioRenderer(sampleRate: 48_000, settings: settings(120)))
        let engine = AVAudioEngine()
        let source = renderer.makeSourceNode()
        engine.attach(source)
        engine.connect(source, to: engine.mainMixerNode, format: renderer.format)
        try engine.enableManualRenderingMode(.offline, format: renderer.format, maximumFrameCount: 256)
        try engine.start()
        defer { engine.stop() }
        let buffer = try XCTUnwrap(AVAudioPCMBuffer(pcmFormat: renderer.format, frameCapacity: 256))
        let writer = DispatchGroup()
        writer.enter()
        DispatchQueue.global().async {
            defer { writer.leave() }
            for index in 0..<10_000 {
                renderer.update(settings: MetronomeSettings(
                    bpm: index.isMultiple(of: 2) ? 40 : 208,
                    meter: index.isMultiple(of: 3) ? .sixEight : .fourFour,
                    accentFirstBeat: index.isMultiple(of: 2)
                )!)
            }
        }
        for _ in 0..<500 {
            XCTAssertEqual(try engine.renderOffline(256, to: buffer), .success)
            let samples = try XCTUnwrap(buffer.floatChannelData?.pointee)
            for frame in 0..<Int(buffer.frameLength) {
                XCTAssertTrue(samples[frame].isFinite)
                XCTAssertLessThanOrEqual(abs(samples[frame]), 0.88)
            }
        }
        XCTAssertEqual(writer.wait(timeout: .now() + 5), .success)
    }
}
