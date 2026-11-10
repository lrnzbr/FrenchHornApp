import Foundation

// Compiled alongside the app's Model sources by export-fixtures.py.
// The prototype uses the app's actual range, spellings, transposition and tables.
@main
struct ExportDesignFixtures {
    static func main() throws {
        let records: [[String: Any]] = instruments.map { instrument in
            [
                "id": instrument.id,
                "name": instrument.name,
                "offset": instrument.key.soundingSemitoneOffset,
                "triggers": instrument.hasTrigger2 ? 2 : (instrument.hasTrigger1 ? 1 : 0),
                "pistons": instrument.hasPistons,
                "notes": instrument.availableNotes.map { spellings in
                    spellings.map { note in
                        [
                            "name": "\(note.noteClass)\(note.octave)",
                            "letter": note.letter.rawValue,
                            "accidental": Int(note.accidental.rawValue),
                            "octave": note.octave,
                            "midi": Int(note.noteNumber),
                            "fingerings": (instrument.fingerings[note] ?? []).map { fingering in
                                [fingering.trigger1, fingering.trigger2,
                                 fingering.valve1, fingering.valve2, fingering.valve3]
                            }
                        ] as [String: Any]
                    }
                }
            ]
        }
        let data = try JSONSerialization.data(withJSONObject: records, options: [.sortedKeys])
        print("// Generated from the app's Model sources. Run Design/scripts/export-fixtures.py to refresh.")
        print("window.ADAGIO_INSTRUMENTS = \(String(decoding: data, as: UTF8.self));")
    }
}
