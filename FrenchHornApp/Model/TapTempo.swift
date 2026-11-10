import Foundation

/// Human input only. This never drives the audio clock or schedules a click.
struct TapTempo {
    private var lastTap: TimeInterval?
    private var intervals: [TimeInterval] = []

    mutating func tap(at time: TimeInterval) -> Double? {
        guard time.isFinite, time >= 0 else { return nil }
        guard let previous = lastTap else { lastTap = time; return nil }
        let interval = time - previous
        if interval <= 0 || interval > 2.5 {
            reset()
            lastTap = time
            return nil
        }
        // Ignore accidental double presses without shifting the previous intentional tap.
        guard interval >= 0.12 else { return nil }
        lastTap = time
        intervals.append(interval)
        if intervals.count > 5 { intervals.removeFirst() }
        let sorted = intervals.sorted()
        let middle = sorted.count / 2
        let median = sorted.count.isMultiple(of: 2) ? (sorted[middle - 1] + sorted[middle]) / 2 : sorted[middle]
        return max(MetronomeSettings.tempoRange.lowerBound,
                   min(MetronomeSettings.tempoRange.upperBound, (60 / median).rounded()))
    }

    mutating func reset() {
        lastTap = nil
        intervals.removeAll(keepingCapacity: true)
    }
}
