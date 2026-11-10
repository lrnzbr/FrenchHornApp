import XCTest
@testable import HornMusicCore

final class TunerCalculationTests: XCTestCase {
    private func frequency(midi: Double) -> Double {
        440 * pow(2, (midi - 69) / 12)
    }

    func testKnownReferenceTones() throws {
        let f = try XCTUnwrap(TunerReading(frequency: 440, instrumentKey: .F))
        XCTAssertEqual(f.soundingMIDINote, 69)
        XCTAssertEqual(f.writtenMIDINote, 76)
        XCTAssertEqual(f.noteNameWithSharps, "E5")
        XCTAssertEqual(f.cents, 0, accuracy: 0.000001)

        let bFlat = try XCTUnwrap(TunerReading(frequency: 233.08188076, instrumentKey: .Bflat))
        XCTAssertEqual(bFlat.soundingMIDINote, 58)
        XCTAssertEqual(bFlat.writtenMIDINote, 60)
        XCTAssertEqual(bFlat.noteNameWithSharps, "C4")
        XCTAssertEqual(bFlat.cents, 0, accuracy: 0.000001)
    }

    func testFormerOctaveBoundaryFailures() throws {
        for (hz, written, cents) in [(240.0, "F♯4", -49.3629415), (260.0, "G4", -10.7902806)] {
            let reading = try XCTUnwrap(TunerReading(frequency: hz, instrumentKey: .F))
            XCTAssertEqual(reading.noteNameWithSharps, written)
            XCTAssertEqual(reading.cents, cents, accuracy: 0.000001)
        }
    }

    func testCentsKeepTheirSignAndMagnitude() throws {
        for cents in [-49.0, -25, -2, 0, 2, 25, 49] {
            let reading = try XCTUnwrap(TunerReading(frequency: frequency(midi: 69 + cents / 100), instrumentKey: .F))
            XCTAssertEqual(reading.soundingMIDINote, 69)
            XCTAssertEqual(reading.cents, cents, accuracy: 0.000001)
        }
    }

    func testEverySemitoneBoundaryIncludingBToC() throws {
        for key in [InstrumentKey.F, .Bflat] {
            // Exercise every boundary that keeps both written targets in the notation tables.
            for lowerWritten in TunerReading.writtenMIDIRange.dropLast() {
                let lowerSounding = lowerWritten + key.soundingSemitoneOffset
                for delta in [-0.001, 0.001] {
                    let pitch = Double(lowerSounding) + 0.5 + delta
                    let reading = try XCTUnwrap(TunerReading(frequency: frequency(midi: pitch), instrumentKey: key))
                    let expectedSounding = delta < 0 ? lowerSounding : lowerSounding + 1
                    XCTAssertEqual(reading.soundingMIDINote, expectedSounding)
                    XCTAssertEqual(reading.writtenMIDINote, expectedSounding - key.soundingSemitoneOffset)
                    XCTAssertEqual(reading.cents, delta < 0 ? 49.9 : -49.9, accuracy: 0.000001)
                }
            }
        }
    }

    func testAllChartNotesRoundTripThroughPlaybackAndTuning() throws {
        for instrument in instruments {
            for group in instrument.availableNotes {
                for note in group {
                    let sounding = note.pitch(instrument.key.soundingSemitoneOffset).midiNoteNumber
                    let reading = try XCTUnwrap(TunerReading(frequency: frequency(midi: Double(sounding)), instrumentKey: instrument.key))
                    XCTAssertEqual(reading.writtenMIDINote, Int(note.noteNumber), "\(instrument.name): \(note)")
                    XCTAssertEqual(reading.cents, 0, accuracy: 0.000001)
                    let label = "\(reading.noteNameWithSharps) / \(reading.noteNameWithFlats)"
                    XCTAssertTrue(noteNameMapping[label]?.contains(note) == true, label)
                }
            }
        }
    }

    func testWholeSupportedTunerRangeHasNotationAndMatchingLabels() throws {
        for key in [InstrumentKey.F, .Bflat] {
            for written in TunerReading.writtenMIDIRange {
                let reading = try XCTUnwrap(TunerReading(frequency: frequency(midi: Double(written + key.soundingSemitoneOffset)), instrumentKey: key))
                let notes = try XCTUnwrap(noteNameMapping["\(reading.noteNameWithSharps) / \(reading.noteNameWithFlats)"])
                for note in notes {
                    XCTAssertEqual(Int(note.noteNumber), written)
                    XCTAssertNotNil(trebleClefNoteMappings[note])
                }
            }
            for written in [11, 120] {
                XCTAssertNil(TunerReading(frequency: frequency(midi: Double(written + key.soundingSemitoneOffset)), instrumentKey: key))
            }
        }
    }

    func testInvalidPitchAndExtremeValuesReturnNoReading() {
        let invalid: [Double] = [0, -1, .nan, .infinity, -.infinity, .leastNonzeroMagnitude, .greatestFiniteMagnitude]
        for key in [InstrumentKey.F, .Bflat] {
            for value in invalid {
                XCTAssertNil(TunerReading(frequency: value, instrumentKey: key), "\(value)")
            }
        }
    }

    func testLiveTunerConversionClearsInvalidAndSilentMeasurements() {
        var data = TunerData.measure(pitch: 440, amplitude: 1, sensitivity: 0.2, instrumentKey: .F)
        XCTAssertEqual(data.noteNameWithSharps, "E5")
        for pitch: Float in [0, -1, .nan, .infinity, -.infinity, .leastNonzeroMagnitude, .greatestFiniteMagnitude] {
            data = TunerData.measure(pitch: pitch, amplitude: 1, sensitivity: 0.2, instrumentKey: .F)
            XCTAssertEqual(data.pitch, 0)
            XCTAssertEqual(data.noteNameWithSharps, "")
        }
        for amplitude: Float in [0, 0.2, -1, .nan, .infinity] {
            data = TunerData.measure(pitch: 440, amplitude: amplitude, sensitivity: 0.2, instrumentKey: .F)
            XCTAssertEqual(data.pitch, 0)
            XCTAssertEqual(data.noteNameWithFlats, "")
        }
    }
}
