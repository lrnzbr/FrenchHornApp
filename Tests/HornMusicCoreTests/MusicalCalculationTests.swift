import XCTest
@testable import HornMusicCore

final class MusicalCalculationTests: XCTestCase {
    func testMiddleCUsesScientificPitchNotation() {
        XCTAssertEqual(C4.octave, 4)
        XCTAssertEqual(C4.description, "C4")
        XCTAssertEqual(C4.noteNumber, 60)
        XCTAssertEqual(A4.noteNumber, 69)
    }

    func testEveryTunerLabelMatchesItsNotes() {
        for (label, notes) in noteNameMapping {
            let spellings = label.components(separatedBy: " / ")
            XCTAssertEqual(notes.first?.description, spellings.first, label)
            XCTAssertEqual(notes.last?.description, spellings.last, label)
            XCTAssertEqual(Set(notes.map(\.noteNumber)).count, 1, label)
        }
    }

    func testReferencePlaybackForEveryConfiguration() {
        let expectedMiddleC: [Int: Int8] = [1: 53, 2: 53, 3: 53, 4: 53, 5: 58, 6: 53, 7: 58, 8: 53]
        for instrument in instruments {
            let offset = instrument.key.soundingSemitoneOffset
            XCTAssertEqual(C4.pitch(offset).midiNoteNumber, expectedMiddleC[instrument.id], instrument.name)
        }
    }

    func testMarchingHornNotationUsesTheCorrectValves() {
        // Written D4 uses valve 1 in B-flat notation and valves 1+2 in F notation.
        let bFlat = instruments.first { $0.id == 7 }!
        let f = instruments.first { $0.id == 8 }!
        let bFlatD = bFlat.fingerings[D4]!.first!
        let fD = f.fingerings[D4]!.first!
        XCTAssertEqual([bFlatD.valve1, bFlatD.valve2, bFlatD.valve3], [true, false, false])
        XCTAssertEqual([fD.valve1, fD.valve2, fD.valve3], [true, true, false])
        XCTAssertEqual(bFlat.fingerings, SingleBFlatHornFingeringsBFlatWritten)
        XCTAssertEqual(f.fingerings, SingleBFlatHornFingeringsFWritten)
    }

    func testEverySelectableNoteHasFingeringsAndNotation() {
        XCTAssertEqual(instruments.reduce(0) { $0 + $1.availableNotes.count }, 286)
        for instrument in instruments {
            for group in instrument.availableNotes {
                XCTAssertFalse(group.isEmpty, instrument.name)
                XCTAssertEqual(Set(group.map(\.noteNumber)).count, 1)
                for note in group {
                    XCTAssertFalse(instrument.fingerings[note]?.isEmpty ?? true, "\(instrument.name): \(note)")
                    XCTAssertNotNil(trebleClefNoteMappings[note], "\(note)")
                }
            }
        }
    }

    func testPitchDoesNotImplicitlyTransposeANote() {
        XCTAssertEqual(C4.pitch.midiNoteNumber, 60)
        XCTAssertEqual(Note(pitch: Pitch(60)).description, "C4")
        for midi in Int8(12)...119 {
            XCTAssertEqual(Note(pitch: Pitch(midi)).pitch.midiNoteNumber, midi)
        }
    }

    func testAccidentalsCrossOctaveBoundaries() {
        XCTAssertEqual(Note(.C, accidental: .flat, octave: 4).noteNumber, 59)
        XCTAssertEqual(Note(.B, accidental: .sharp, octave: 4).noteNumber, 72)
        XCTAssertEqual(CSharp4.noteNumber, DFlat4.noteNumber)
    }

    func testFrequencyUsesTwelveSemitonesPerOctave() {
        XCTAssertEqual(calculateFrequency(stepsAwayFromBaseFrequency: 12), 880, accuracy: 0.000001)
        XCTAssertEqual(calculateFrequency(stepsAwayFromBaseFrequency: -12), 220, accuracy: 0.000001)
        XCTAssertEqual(calculateFrequency(stepsAwayFromBaseFrequency: 1), 466.1637615, accuracy: 0.000001)
    }

    func testStaffAndLedgerReferencePositions() {
        let cases: [(Note, CGFloat, [CGFloat])] = [
            (C4, 36, [36]), (D4, 30, []), (E4, 24, []), (B4, 0, []),
            (F5, -24, []), (G5, -30, []), (A5, -36, [-36]),
            (C6, -48, [-36, -48]), (CSharp6, -48, [-36, -48]),
            (DFlat6, -54, [-36, -48]), (C2, 120, [36, 48, 60, 72, 84, 96, 108, 120]),
            (C0, 204, Array(stride(from: CGFloat(36), through: 204, by: 12))),
            (B8, -168, Array(stride(from: CGFloat(-36), through: -168, by: -12)))
        ]
        for (note, position, ledgers) in cases {
            let visual = trebleClefNoteMappings[note]!
            XCTAssertEqual(visual.notePosition, position, "\(note)")
            XCTAssertEqual((visual.ledgerLines ?? []).map(\.offset), ledgers, "\(note)")
        }
    }

    func testEveryTunerNoteHasCorrectStaffGeometry() {
        for notes in noteNameMapping.values {
            for note in notes {
                let visual = trebleClefNoteMappings[note]!
                let distanceAboveE4 = (note.octave - 4) * 7 + note.letter.rawValue - Letter.E.rawValue
                let position = 24 - CGFloat(distanceAboveE4) * 6
                XCTAssertEqual(visual.notePosition, position, "\(note)")
                let expectedLedgerCount = max(0, Int((abs(position) - 24) / 12))
                XCTAssertEqual(visual.ledgerLines?.count ?? 0, expectedLedgerCount, "\(note)")
            }
        }
    }
}
