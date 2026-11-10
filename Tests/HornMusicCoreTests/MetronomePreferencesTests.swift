import XCTest
@testable import HornMusicCore

final class MetronomePreferencesTests: XCTestCase {
    private func withStore(_ body: (MetronomePreferences, UserDefaults) throws -> Void) rethrows {
        let suite = "AdagioMetronomeTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        try body(MetronomePreferences(defaults: defaults), defaults)
    }

    func testFreshInstallUsesExistingPracticeDefaults() {
        withStore { store, _ in
            XCTAssertEqual(store.load(), MetronomeSettings(bpm: 120, meter: .fourFour, accentFirstBeat: true))
        }
    }

    func testTempoMeterAndAccentRestoreForEverySupportedMeterAndTempoLimit() {
        withStore { store, defaults in
            for bpm in [40.0, 96, 208] {
                for meter in MetronomeMeter.allCases {
                    for accent in [true, false] {
                        let settings = MetronomeSettings(bpm: bpm, meter: meter, accentFirstBeat: accent)!
                        store.save(settings)
                        XCTAssertEqual(MetronomePreferences(defaults: defaults).load(), settings)
                    }
                }
            }
        }
    }

    func testCorruptMissingInvalidAndFuturePreferencesFallBackSafely() {
        withStore { store, defaults in
            for json in ["not json", "{}", "[]",
                #"{"version":2,"bpm":96,"meter":"3/4","accent":false}"#,
                #"{"version":1,"bpm":209,"meter":"4/4","accent":true}"#,
                #"{"version":1,"bpm":39,"meter":"4/4","accent":true}"#,
                #"{"version":1,"bpm":96,"meter":"7/8","accent":true}"#,
                #"{"version":1,"bpm":"96","meter":"3/4","accent":false}"#] {
                defaults.set(Data(json.utf8), forKey: MetronomePreferences.storageKey)
                XCTAssertEqual(store.load(), MetronomePreferences.standard)
            }
            defaults.set("wrong storage type", forKey: MetronomePreferences.storageKey)
            XCTAssertEqual(store.load(), MetronomePreferences.standard)
        }
    }

    func testExactTempoEntryAcceptsWholeNumbersAndWhitespaceAtSupportedBoundaries() {
        for (text, expected) in [("40", 40.0), ("208", 208.0), (" 96\n", 96.0), ("0084", 84.0)] {
            XCTAssertEqual(MetronomeTempoEntry.tempo(from: text), expected)
        }
    }

    func testExactTempoEntryRejectsOutOfRangeFractionalAndNonNumericInput() {
        for text in ["", " ", "0", "39", "209", "-96", "+96", "96.5", "96.0", "1e2", "NaN", "inf", "96 bpm", "９６", String(repeating: "9", count: 400)] {
            XCTAssertNil(MetronomeTempoEntry.tempo(from: text), text)
        }
    }
}
