import XCTest
@testable import HornMusicCore

final class FingeringSelectionTests: XCTestCase {
    func testEverySelectionUsesTheOriginalFingeringsAndSoundingPitch() {
        for instrument in instruments {
            var selection = FingeringSelection(instrument: instrument)
            for group in instrument.availableNotes {
                selection.select(group[0].noteNumber)
                for flats in [false, true] {
                    selection.prefersFlats = flats
                    let note = selection.selectedNote!
                    XCTAssertTrue(group.contains(note))
                    XCTAssertEqual(selection.fingerings, instrument.fingerings[note])
                    XCTAssertEqual(selection.soundingPitch, note.pitch(instrument.key.soundingSemitoneOffset))
                    XCTAssertEqual(selection.soundingNote?.pitch, selection.soundingPitch)
                    XCTAssertEqual(selection.frequency!, 440 * pow(2, Double(Int(note.noteNumber) + instrument.key.soundingSemitoneOffset - 69) / 12), accuracy: 0.000001)
                }
            }
        }
    }

    func testSpellingChangesNotationWithoutChangingReferenceTone() {
        var selection = FingeringSelection(instrument: instruments[1], writtenMIDI: CSharp5.noteNumber)
        let pitch = selection.soundingPitch
        let fingerings = selection.fingerings
        XCTAssertEqual(selection.selectedNote, CSharp5)
        selection.prefersFlats = true
        XCTAssertEqual(selection.selectedNote, DFlat5)
        XCTAssertEqual(selection.soundingPitch, pitch)
        XCTAssertEqual(selection.fingerings, fingerings)
        XCTAssertNotEqual(StaffPreviewLayout(note: CSharp5).noteY, StaffPreviewLayout(note: DFlat5).noteY)
    }

    func testChromaticNavigationStopsAtBothRangeBoundaries() {
        for instrument in instruments {
            var selection = FingeringSelection(instrument: instrument, writtenMIDI: 0)
            XCTAssertEqual(selection.selectedNote, instrument.availableNotes.first?.first)
            XCTAssertFalse(selection.canStep(-1))
            for group in instrument.availableNotes.dropFirst() {
                XCTAssertTrue(selection.canStep(1))
                selection.step(1)
                XCTAssertEqual(selection.writtenMIDI, group[0].noteNumber)
            }
            XCTAssertFalse(selection.canStep(1))
            let last = selection.writtenMIDI
            selection.step(1)
            XCTAssertEqual(selection.writtenMIDI, last)
        }
    }

    func testOctavesKeepPitchClassAndClampPartialBoundaryOctaves() {
        var selection = FingeringSelection(instrument: instruments[1], writtenMIDI: B5.noteNumber)
        selection.selectOctave(4)
        XCTAssertEqual(selection.selectedNote, B4)
        selection.selectOctave(6)
        XCTAssertEqual(selection.selectedNote, C6)
        XCTAssertEqual(selection.notesInOctave, [C6])
        selection.selectOctave(8)
        selection.select(119)
        XCTAssertEqual(selection.selectedNote, C6)
    }

    func testInstrumentChangePreservesWrittenPitchButUpdatesTranspositionAndTables() {
        var selection = FingeringSelection(instrument: instruments[1], writtenMIDI: C5.noteNumber, prefersFlats: true)
        XCTAssertEqual(selection.soundingNote, F4)
        selection.changeInstrument(instruments[4])
        XCTAssertEqual(selection.selectedNote, C5)
        XCTAssertEqual(selection.soundingNote, BFlat4)
        XCTAssertEqual(selection.frequency!, 466.1637615, accuracy: 0.000001)
        XCTAssertEqual(selection.fingerings, SingleBFlatHornFingeringsBFlatWritten[C5])
        selection.changeInstrument(instruments[6])
        selection.selectOctave(3)
        XCTAssertEqual(selection.selectedNote, G3) // Marching horn starts at G3, not C3.
    }

    func testAllStaffNotesAndLedgersFitInsideTheirPreviewIncludingEnharmonicExtremes() {
        for group in noteNameMapping.values {
            for note in group {
                let layout = StaffPreviewLayout(note: note)
                XCTAssertGreaterThanOrEqual(layout.noteY, 20)
                XCTAssertLessThanOrEqual(layout.noteY, layout.height - 20)
                for line in layout.staffLines + layout.ledgerLines {
                    XCTAssertGreaterThanOrEqual(line, 0, note.description)
                    XCTAssertLessThanOrEqual(line, layout.height, note.description)
                }
            }
        }
    }

    func testEmptyInstrumentDoesNotInventAPlayableNote() {
        var instrument = instruments[0]
        instrument.availableNotes = []
        var selection = FingeringSelection(instrument: instrument)
        selection.step(1)
        selection.selectOctave(4)
        XCTAssertNil(selection.selectedNote)
        XCTAssertNil(selection.soundingPitch)
        XCTAssertTrue(selection.fingerings.isEmpty)
    }
}
