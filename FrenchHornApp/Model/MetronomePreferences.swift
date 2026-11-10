import Foundation

/// Only practice choices are stored. Playback intent and audio state are never persisted.
final class MetronomePreferences {
    static let storageKey = "adagio.metronome.settings.v1"
    static let standard = MetronomeSettings(bpm: 120, meter: .fourFour, accentFirstBeat: true)!
    private let defaults: UserDefaults

    private struct Stored: Codable {
        let version: Int
        let bpm: Double
        let meter: String
        let accent: Bool
    }

    init(defaults: UserDefaults = .standard) { self.defaults = defaults }

    func load() -> MetronomeSettings {
        guard let data = defaults.data(forKey: Self.storageKey),
              let stored = try? JSONDecoder().decode(Stored.self, from: data), stored.version == 1,
              let meter = MetronomeMeter(rawValue: stored.meter),
              let settings = MetronomeSettings(bpm: stored.bpm, meter: meter, accentFirstBeat: stored.accent)
        else { return Self.standard }
        return settings
    }

    func save(_ settings: MetronomeSettings) {
        let stored = Stored(version: 1, bpm: settings.bpm, meter: settings.meter.rawValue, accent: settings.accentFirstBeat)
        if let data = try? JSONEncoder().encode(stored) { defaults.set(data, forKey: Self.storageKey) }
    }
}

enum MetronomeTempoEntry {
    /// Integer tempos only, matching the existing slider's steps and beat unit.
    static func tempo(from text: String) -> Double? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed.utf8.allSatisfy({ (48...57).contains($0) }),
              let value = Double(trimmed), value.isFinite, MetronomeSettings.tempoRange.contains(value)
        else { return nil }
        return value
    }
}
