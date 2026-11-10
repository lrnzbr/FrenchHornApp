import Foundation

/// Presentation reads the same target/cents calculation as capture; inactive input never displays an old pitch.
struct TunerPresentation {
    enum Direction { case waiting, flat, inTune, sharp }
    static let inTuneThresholdCents = 2.0
    let reading: TunerReading?
    let writtenNote: Note?
    let soundingNote: Note?
    let frequency: Double?

    init(data: TunerData, state: MicrophoneState, instrumentKey: InstrumentKey) {
        let reading = state == .running ? TunerReading(frequency: Double(data.pitch), instrumentKey: instrumentKey) : nil
        self.reading = reading
        writtenNote = reading.map { Note(pitch: Pitch(Int8($0.writtenMIDINote)), key: .G) }
        soundingNote = reading.map { Note(pitch: Pitch(Int8($0.soundingMIDINote)), key: .G) }
        frequency = reading == nil ? nil : Double(data.pitch)
    }

    var direction: Direction {
        guard let cents = reading?.cents else { return .waiting }
        if abs(cents) <= Self.inTuneThresholdCents { return .inTune }
        return cents < 0 ? .flat : .sharp
    }
    var directionLabel: String {
        switch direction {
        case .waiting: return "Waiting for a note"
        case .flat: return "Flat"
        case .inTune: return "In tune"
        case .sharp: return "Sharp"
        }
    }
    var centsLabel: String { reading.map { String(format: "%+.1f cents", $0.cents) } ?? "— cents" }
    /// -1 is 50 cents flat, 0 is the target, +1 is 50 cents sharp.
    var needlePosition: Double? { reading.map { max(-1, min(1, $0.cents / 50)) } }
}
