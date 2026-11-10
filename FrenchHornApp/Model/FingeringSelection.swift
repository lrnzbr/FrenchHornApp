import Foundation

/// Written-note selection and reference metadata share the instrument's existing source of truth.
struct FingeringSelection {
    private(set) var instrument: Instrument
    private(set) var writtenMIDI: Int8?
    var prefersFlats: Bool

    init(instrument: Instrument, writtenMIDI: Int8 = 72, prefersFlats: Bool = false) {
        self.instrument = instrument
        self.prefersFlats = prefersFlats
        self.writtenMIDI = Self.nearest(to: Int(writtenMIDI), in: instrument.availableNotes.compactMap(\.first))?.noteNumber
    }

    var selectedNote: Note? {
        guard let midi = writtenMIDI,
              let group = instrument.availableNotes.first(where: { $0.first?.noteNumber == midi }) else { return nil }
        return spelling(in: group)
    }

    var octaves: [Int] { Array(Set(instrument.availableNotes.compactMap { $0.first?.octave })).sorted() }
    var notesInOctave: [Note] {
        guard let octave = selectedNote?.octave else { return [] }
        return instrument.availableNotes.filter { $0.first?.octave == octave }.compactMap(spelling)
    }
    var fingerings: [Fingering] { selectedNote.flatMap { instrument.fingerings[$0] } ?? [] }
    var soundingPitch: Pitch? { selectedNote?.pitch(instrument.key.soundingSemitoneOffset) }
    var soundingNote: Note? {
        soundingPitch.map { Note(pitch: $0, key: prefersFlats ? .F : .G) }
    }
    var frequency: Double? {
        soundingPitch.map { calculateFrequency(stepsAwayFromBaseFrequency: Int($0.midiNoteNumber) - 69) }
    }

    mutating func select(_ midi: Int8) {
        guard instrument.availableNotes.contains(where: { $0.first?.noteNumber == midi }) else { return }
        writtenMIDI = midi
    }

    mutating func selectOctave(_ octave: Int) {
        guard let midi = writtenMIDI, octaves.contains(octave) else { return }
        let desired = Int(midi % 12) + (octave + 1) * 12
        // Partial boundary octaves (e.g. C6 only) must not create unsupported notes.
        writtenMIDI = Self.nearest(to: desired, in: instrument.availableNotes.compactMap(\.first)
            .filter { $0.octave == octave })?.noteNumber
    }

    func canStep(_ direction: Int) -> Bool {
        guard let index = index else { return false }
        return instrument.availableNotes.indices.contains(index + direction)
    }

    mutating func step(_ direction: Int) {
        guard let index = index, canStep(direction) else { return }
        writtenMIDI = instrument.availableNotes[index + direction].first?.noteNumber
    }

    mutating func changeInstrument(_ instrument: Instrument) {
        self = Self(instrument: instrument, writtenMIDI: writtenMIDI ?? 72, prefersFlats: prefersFlats)
    }

    private var index: Int? {
        guard let midi = writtenMIDI else { return nil }
        return instrument.availableNotes.firstIndex { $0.first?.noteNumber == midi }
    }
    private func spelling(in group: [Note]) -> Note? {
        group.first { prefersFlats ? $0.accidental.rawValue < 0 : $0.accidental.rawValue > 0 } ?? group.first
    }
    private static func nearest(to midi: Int, in notes: [Note]) -> Note? {
        notes.min { abs(Int($0.noteNumber) - midi) < abs(Int($1.noteNumber) - midi) }
    }
}
