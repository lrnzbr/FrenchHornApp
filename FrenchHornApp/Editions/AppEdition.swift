import AdagioCore
import Foundation

/// Which instrument app this build is. Every edition shares the same screens; it differs in
/// its instrument list, wording and fingering diagram.
///
/// Each app target sets the `ADAGIO_EDITION` build setting, which reaches `Info.plist` as
/// `AdagioEdition`. The horn target leaves it empty. Debug builds can also be switched with the
/// launch argument `-adagioEdition clarinet`.
enum AppEdition: String, CaseIterable {
    case horn, clarinet, flute, trumpet

    static let current: AppEdition = {
        var candidates: [String?] = []
        #if DEBUG
        candidates.append(UserDefaults.standard.string(forKey: "adagioEdition"))
        #endif
        candidates.append(Bundle.main.object(forInfoDictionaryKey: "AdagioEdition") as? String)
        return candidates.compactMap { $0 }.compactMap(AppEdition.init(rawValue:)).first ?? .horn
    }()

    /// Working titles for the three new apps; only the horn title is a shipped name.
    var almanacTitle: String {
        switch self {
        case .horn: return "The Hornist's Almanac"
        case .clarinet: return "The Clarinetist's Almanac"
        case .flute: return "The Flutist's Almanac"
        case .trumpet: return "The Trumpeter's Almanac"
        }
    }

    var instrumentNoun: String { rawValue }

    var chooserTitle: String { "Choose your \(instrumentNoun)" }

    var chooserSubtitle: String {
        "Choose the \(instrumentNoun) you play so notes and fingerings match your instrument."
    }

    var instruments: [Instrument] {
        switch self {
        case .horn: return hornInstruments()
        case .clarinet: return Self.clarinets
        case .flute: return Self.flutes
        case .trumpet: return Self.trumpets
        }
    }

    private static let clarinets = [
        Instrument(profile: InstrumentCatalog.clarinetInBFlat, id: 101),
        Instrument(profile: InstrumentCatalog.clarinetInEFlat, id: 102),
        Instrument(profile: InstrumentCatalog.clarinetInA, id: 103)
    ]
    private static let flutes = [
        Instrument(profile: InstrumentCatalog.flute, id: 201, notationLabel: "Flute · concert pitch")
    ]
    private static let trumpets = [
        Instrument(profile: InstrumentCatalog.trumpetInBFlat, id: 301),
        Instrument(profile: InstrumentCatalog.trumpetInC, id: 302)
    ]
}

/// The horn list from `Model/Instrument.swift`, read at file scope where the name is unambiguous.
private func hornInstruments() -> [Instrument] { instruments }

extension Instrument {
    /// Builds the app's instrument model from a shared `AdagioCore` profile, so clarinet, flute
    /// and trumpet need no hand-written note or fingering tables in this app.
    init(profile: InstrumentProfile, id: Int, notationLabel: String? = nil) {
        let playable = profile.writtenRange.filter { !profile.fingerings(forWritten: $0).isEmpty }
        let groups = playable.map(Self.spellings(forMIDI:))
        var valves: [Note: [Fingering]] = [:]
        if profile.family == .brass {
            for (midi, group) in zip(playable, groups) {
                let list = profile.fingerings(forWritten: midi).enumerated().map { index, spec in
                    Fingering(id: index,
                              trigger1: spec.isPressed("T1"), trigger2: spec.isPressed("T2"),
                              valve1: spec.isPressed("1"), valve2: spec.isPressed("2"),
                              valve3: spec.isPressed("3"))
                }
                for note in group { valves[note] = list }
            }
        }
        self.init(id: id, name: profile.name,
                  key: InstrumentKey(soundingSemitoneOffset: profile.soundingSemitoneOffset),
                  imageName: "", availableNotes: groups, fingerings: valves,
                  hasPistons: profile.family == .brass, hasTrigger1: false, hasTrigger2: false,
                  instrumentGuideImage: "", handImage: "",
                  profileID: profile.id, notationLabel: notationLabel ?? profile.name)
    }

    /// The shared profile behind this instrument: by ID for the new editions, by the horn
    /// app's numeric ID for the horns.
    var profile: InstrumentProfile? {
        profileID.flatMap(InstrumentCatalog.profile(id:)) ?? InstrumentCatalog.profile(legacyID: id)
    }

    /// One note for a natural, sharp and flat spellings for the rest.
    private static func spellings(forMIDI midi: Int) -> [Note] {
        let octave = midi / 12 - 1
        switch midi % 12 {
        case 0: return [Note(.C, octave: octave)]
        case 1: return [Note(.C, accidental: .sharp, octave: octave), Note(.D, accidental: .flat, octave: octave)]
        case 2: return [Note(.D, octave: octave)]
        case 3: return [Note(.D, accidental: .sharp, octave: octave), Note(.E, accidental: .flat, octave: octave)]
        case 4: return [Note(.E, octave: octave)]
        case 5: return [Note(.F, octave: octave)]
        case 6: return [Note(.F, accidental: .sharp, octave: octave), Note(.G, accidental: .flat, octave: octave)]
        case 7: return [Note(.G, octave: octave)]
        case 8: return [Note(.G, accidental: .sharp, octave: octave), Note(.A, accidental: .flat, octave: octave)]
        case 9: return [Note(.A, octave: octave)]
        case 10: return [Note(.A, accidental: .sharp, octave: octave), Note(.B, accidental: .flat, octave: octave)]
        default: return [Note(.B, octave: octave)]
        }
    }
}
