import Foundation

/// Presentation only: raw capture and note/cents calculations remain instantaneous.
struct TunerDisplayHold {
    static let duration: TimeInterval = 1.5
    private(set) var data = TunerData()
    private(set) var deadline: TimeInterval?
    private(set) var isHolding = false

    mutating func receive(_ measurement: TunerData, state: MicrophoneState, at time: TimeInterval) {
        guard state == .running, time.isFinite, time >= 0 else { clear(); return }
        if measurement.pitch.isFinite, measurement.pitch > 0, !measurement.noteNameWithSharps.isEmpty {
            data = measurement
            deadline = time + Self.duration
            isHolding = false
        } else {
            expire(at: time)
            isHolding = deadline != nil
        }
    }

    mutating func expire(at time: TimeInterval) {
        guard time.isFinite, let deadline = deadline, time < deadline else { clear(); return }
    }

    mutating func clear() {
        data = TunerData()
        deadline = nil
        isHolding = false
    }
}
