import SwiftUI

struct FingeringRow: View {
    let instrument: Instrument
    let fingering: Fingering
    let index: Int
    @Environment(\.sizeCategory) private var sizeCategory
    @ScaledMetric(relativeTo: .caption) private var diameter: CGFloat = 28

    private var positions: [(label: String, pressed: Bool)] {
        var result: [(String, Bool)] = []
        if instrument.hasTrigger1 { result.append(("T", fingering.trigger1)) }
        if instrument.hasTrigger2 { result.append(("T2", fingering.trigger2)) }
        result += [("1", fingering.valve1), ("2", fingering.valve2), ("3", fingering.valve3)]
        return result
    }
    private var title: String {
        if instrument.id == 2 || instrument.id == 3 {
            if fingering.trigger2 { return "High F side" }
            return fingering.trigger1 ? "B♭ side" : "F side"
        }
        return "Fingering \(index + 1)"
    }
    private var detail: String { index == 0 ? "First listed" : "Alternative \(index)" }
    private var description: String {
        positions.map { "\($0.label) \($0.pressed ? "pressed" : "released")" }.joined(separator: ", ")
    }
    private var labels: some View {
        VStack(alignment: .leading, spacing: AdagioTheme.Space.xs) {
            Text(title).font(AdagioTheme.TypeStyle.support)
            Text(detail).font(.caption).foregroundColor(AdagioTheme.Colors.secondaryInk)
        }
    }
    private var diagram: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: diameter, maximum: diameter), spacing: 6)], spacing: 8) {
            ForEach(positions.indices, id: \.self) { position in
                let item = positions[position]
                Text(item.label)
                    .font(.caption.weight(.medium))
                    .frame(width: diameter, height: diameter)
                    .foregroundColor(item.pressed ? AdagioTheme.Colors.surface : AdagioTheme.Colors.ink)
                    .background(Circle().fill(item.pressed ? AdagioTheme.Colors.ink : AdagioTheme.Colors.surface))
                    .overlay(Circle().strokeBorder(AdagioTheme.Colors.secondaryInk,
                        style: StrokeStyle(lineWidth: 1, dash: item.label.hasPrefix("T") ? [2, 2] : [])))
            }
        }
    }

    var body: some View {
        Group {
            if sizeCategory.isAccessibilityCategory {
                VStack(alignment: .leading, spacing: AdagioTheme.Space.md) { labels; diagram }
            } else {
                HStack(spacing: AdagioTheme.Space.sm) {
                    labels
                    Spacer(minLength: 0)
                    diagram.frame(width: diameter * CGFloat(positions.count) + 6 * CGFloat(positions.count - 1))
                }
            }
        }
        .padding(.horizontal, AdagioTheme.Space.md)
        .padding(.vertical, AdagioTheme.Space.md)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title), \(detail)")
        .accessibilityValue(description)
        .accessibilityIdentifier("fingerings.row.\(index)")
    }
}
