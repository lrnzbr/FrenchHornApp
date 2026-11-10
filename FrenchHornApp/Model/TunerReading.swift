import Foundation

/// A single equal-tempered target. Note identity and cents always use the same target.
struct TunerReading {
    let soundingMIDINote: Int
    let writtenMIDINote: Int
    let cents: Double

    // The notation and name tables cover C0 through B8.
    static let writtenMIDIRange = 12...119
    private static let sharpNames = ["C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B"]
    private static let flatNames = ["C", "D♭", "D", "E♭", "E", "F", "G♭", "G", "A♭", "A", "B♭", "B"]

    init?(frequency: Double, instrumentKey: InstrumentKey) {
        guard frequency.isFinite, frequency > 0 else { return nil }

        // Subtract logarithms rather than dividing first, avoiding underflow for tiny inputs.
        let continuousMIDI = 69 + 12 * (log2(frequency) - log2(440))
        let targetMIDI = continuousMIDI.rounded()
        guard targetMIDI.isFinite, (0...127).contains(targetMIDI) else { return nil }

        let sounding = Int(targetMIDI)
        let written = sounding - instrumentKey.soundingSemitoneOffset
        guard Self.writtenMIDIRange.contains(written) else { return nil }

        soundingMIDINote = sounding
        writtenMIDINote = written
        cents = (continuousMIDI - targetMIDI) * 100
    }

    var noteNameWithSharps: String {
        "\(Self.sharpNames[writtenMIDINote % 12])\(writtenMIDINote / 12 - 1)"
    }

    var noteNameWithFlats: String {
        "\(Self.flatNames[writtenMIDINote % 12])\(writtenMIDINote / 12 - 1)"
    }
}

struct TunerData {
    var pitch: Float = 0
    var amplitude: Float = 0
    var cents: Float = 0
    var noteNameWithSharps = ""
    var noteNameWithFlats = ""

    /// Pure conversion used by the live tuner and regression tests. Invalid input clears old data.
    static func measure(pitch: Float, amplitude: Float, sensitivity: Float, instrumentKey: InstrumentKey) -> TunerData {
        guard amplitude.isFinite, sensitivity.isFinite, (0...1).contains(sensitivity),
              amplitude > sensitivity,
              let reading = TunerReading(frequency: Double(pitch), instrumentKey: instrumentKey)
        else { return TunerData() }

        return TunerData(
            pitch: pitch,
            amplitude: amplitude,
            cents: Float(reading.cents),
            noteNameWithSharps: reading.noteNameWithSharps,
            noteNameWithFlats: reading.noteNameWithFlats
        )
    }
}
