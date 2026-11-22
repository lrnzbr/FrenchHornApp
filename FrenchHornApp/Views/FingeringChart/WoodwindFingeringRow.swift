import AdagioCore
import SwiftUI

/// Where each key of a woodwind sits in the schematic diagram.
struct WoodwindKeyLayout {
    let upperCaption: String
    let upper: [String]
    let thumb: String
    let left: [String]
    let right: [String]
    let lowerCaption: String
    let lower: [String]

    init(family: InstrumentFamily) {
        thumb = "T"
        left = ["L1", "L2", "L3"]
        right = ["R1", "R2", "R3"]
        switch family {
        case .flute:
            upperCaption = "Left little finger"
            upper = ["G#"]
            lowerCaption = "Right little finger"
            lower = ["Eb", "C#", "C"]
        default:
            upperCaption = "Register, throat and side keys"
            upper = ["Reg", "A", "G#", "SideEb"]
            lowerCaption = "Little-finger keys"
            lower = ["C#", "E", "F", "F#", "Ab"]
        }
    }

    static func displayName(_ key: String) -> String {
        switch key {
        case "Reg": return "Register"
        case "SideEb": return "Side E♭"
        default:
            return key.replacingOccurrences(of: "#", with: "♯")
                .replacingOccurrences(of: "b", with: "♭")
        }
    }
}

/// One clarinet or flute fingering: tone holes as circles, the other keys as labelled pills.
/// A schematic, not a drawing of the instrument.
struct WoodwindFingeringRow: View {
    let profile: InstrumentProfile
    let fingering: FingeringSpec
    let index: Int
    @ScaledMetric(relativeTo: .caption) private var diameter: CGFloat = 30

    private var layout: WoodwindKeyLayout { WoodwindKeyLayout(family: profile.family) }
    private var title: String { "Fingering \(index + 1)" }
    private var detail: String { index == 0 ? "First listed" : "Alternative \(index)" }
    private var spoken: String {
        fingering.isOpen ? "Open, no keys pressed"
            : profile.keys.filter(fingering.isPressed).map(WoodwindKeyLayout.displayName).joined(separator: ", ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AdagioTheme.Space.md) {
            VStack(alignment: .leading, spacing: AdagioTheme.Space.xs) {
                Text(title).font(AdagioTheme.TypeStyle.support)
                Text(detail).font(.caption).foregroundColor(AdagioTheme.Colors.secondaryInk)
            }
            keyStrip(layout.upperCaption, layout.upper)
            HStack(alignment: .top, spacing: AdagioTheme.Space.lg) {
                holes("Thumb", [layout.thumb], dashed: true)
                holes("Left hand", layout.left)
                holes("Right hand", layout.right)
            }
            keyStrip(layout.lowerCaption, layout.lower)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AdagioTheme.Space.md)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title), \(detail)")
        .accessibilityValue(spoken)
        .accessibilityIdentifier("fingerings.row.\(index)")
    }

    private func holes(_ caption: String, _ keys: [String], dashed: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: AdagioTheme.Space.xs) {
            HStack(spacing: 6) {
                ForEach(keys, id: \.self) { key in
                    let pressed = fingering.isPressed(key)
                    Text(key == layout.thumb ? "T" : String(key.suffix(1)))
                        .font(.caption.weight(.medium))
                        .frame(width: diameter, height: diameter)
                        .foregroundColor(pressed ? AdagioTheme.Colors.surface : AdagioTheme.Colors.ink)
                        .background(Circle().fill(pressed ? AdagioTheme.Colors.ink : AdagioTheme.Colors.surface))
                        .overlay(Circle().strokeBorder(AdagioTheme.Colors.secondaryInk,
                            style: StrokeStyle(lineWidth: 1, dash: dashed ? [2, 2] : [])))
                }
            }
            Text(caption).font(.caption2).foregroundColor(AdagioTheme.Colors.secondaryInk)
        }
    }

    private func keyStrip(_ caption: String, _ keys: [String]) -> some View {
        VStack(alignment: .leading, spacing: AdagioTheme.Space.xs) {
            Text(caption).font(.caption2).foregroundColor(AdagioTheme.Colors.secondaryInk)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: diameter * 1.9), spacing: 6, alignment: .leading)],
                      alignment: .leading, spacing: 6) {
                ForEach(keys, id: \.self) { key in
                    let pressed = fingering.isPressed(key)
                    Text(WoodwindKeyLayout.displayName(key))
                        .font(.caption.weight(.medium))
                        .lineLimit(1).minimumScaleFactor(0.7)
                        .padding(.horizontal, AdagioTheme.Space.sm)
                        .frame(maxWidth: .infinity, minHeight: diameter)
                        .foregroundColor(pressed ? AdagioTheme.Colors.surface : AdagioTheme.Colors.ink)
                        .background(Capsule().fill(pressed ? AdagioTheme.Colors.ink : AdagioTheme.Colors.surface))
                        .overlay(Capsule().strokeBorder(AdagioTheme.Colors.secondaryInk, lineWidth: 1))
                }
            }
        }
    }
}

struct WoodwindFingeringRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            WoodwindFingeringRow(profile: InstrumentCatalog.clarinetInBFlat,
                                 fingering: InstrumentCatalog.clarinetInBFlat.fingerings(forWritten: 72)[0], index: 0)
            WoodwindFingeringRow(profile: InstrumentCatalog.flute,
                                 fingering: InstrumentCatalog.flute.fingerings(forWritten: 70)[0], index: 0)
        }
        .foregroundColor(AdagioTheme.Colors.ink)
        .background(AdagioTheme.Colors.surface)
    }
}
