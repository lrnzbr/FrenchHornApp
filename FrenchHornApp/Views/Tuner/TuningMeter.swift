import SwiftUI

struct TuningMeter: View {
    let presentation: TunerPresentation

    var body: some View {
        VStack(spacing: AdagioTheme.Space.xs) {
            GeometryReader { geometry in
                let width = geometry.size.width - 16
                ZStack(alignment: .topLeading) {
                    Capsule().fill(presentation.reading == nil ? AdagioTheme.Colors.surfaceMuted : AdagioTheme.Colors.successMuted)
                        .frame(width: max(0, width) * CGFloat(TunerPresentation.inTuneThresholdCents / 50), height: 52)
                        .position(x: geometry.size.width / 2, y: 40)
                    Path { path in
                        for index in 0...24 {
                            let x = 8 + width * CGFloat(index) / 24
                            let major = index % 6 == 0
                            path.move(to: CGPoint(x: x, y: major ? 25 : 32))
                            path.addLine(to: CGPoint(x: x, y: major ? 56 : 49))
                        }
                    }.stroke(AdagioTheme.Colors.secondaryInk, lineWidth: 1)
                    if let fraction = presentation.needlePosition {
                        let x = 8 + width * CGFloat(fraction + 1) / 2
                        Path { path in
                            path.move(to: CGPoint(x: x, y: 16))
                            path.addLine(to: CGPoint(x: x, y: 65))
                        }.stroke(AdagioTheme.Colors.ink, lineWidth: 2)
                        Path { path in
                            path.move(to: CGPoint(x: x - 4, y: 9))
                            path.addLine(to: CGPoint(x: x + 4, y: 9))
                            path.addLine(to: CGPoint(x: x, y: 16))
                            path.closeSubpath()
                        }.fill(AdagioTheme.Colors.ink)
                    }
                }
            }.frame(height: 74)
            HStack {
                Text("−50 · Flat")
                Spacer()
                Text("0")
                Spacer()
                Text("Sharp · +50")
            }.font(.caption).foregroundColor(AdagioTheme.Colors.secondaryInk)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Pitch error")
        .accessibilityValue("\(presentation.centsLabel), \(presentation.directionLabel)")
        .accessibilityIdentifier("tuner.meter")
    }
}

struct TunerReadout: View {
    let presentation: TunerPresentation
    var isListening = true
    var isHolding = false
    @Environment(\.sizeCategory) private var sizeCategory
    @ScaledMetric(relativeTo: .largeTitle) private var pitchSize: CGFloat = 88
    @ScaledMetric(relativeTo: .largeTitle) private var octaveSize: CGFloat = 34

    private var pitch: some View {
        Group {
            if let note = presentation.writtenNote {
                if sizeCategory.isAccessibilityCategory {
                    VStack(spacing: 0) { pitchClass(note); octave(note) }
                } else {
                    HStack(alignment: .firstTextBaseline, spacing: 0) { pitchClass(note); octave(note) }
                }
            } else {
                Text("—").font(.system(size: pitchSize, weight: .medium))
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(isHolding ? "Last written note" : "Written note")
        .accessibilityValue(presentation.writtenNote?.description ?? "No note")
        .accessibilityIdentifier("tuner.pitch")
    }

    var body: some View {
        VStack(spacing: AdagioTheme.Space.md) {
            Text(isHolding ? "Last written pitch" : "Written pitch").font(AdagioTheme.TypeStyle.support)
                .foregroundColor(AdagioTheme.Colors.secondaryInk)
            pitch
            if let sounding = presentation.soundingNote, let frequency = presentation.frequency {
                Text("Sounding \(sounding.description) · \(frequency, specifier: "%.1f") Hz")
                    .font(AdagioTheme.TypeStyle.support)
                    .foregroundColor(AdagioTheme.Colors.secondaryInk)
            } else {
                Text(isListening ? "Play a steady, comfortable note" : "Microphone inactive")
                    .font(AdagioTheme.TypeStyle.support)
                    .foregroundColor(AdagioTheme.Colors.secondaryInk)
            }
            StaffPreview(note: presentation.writtenNote, accessibilityID: "tuner.staff")
                .adagioSurface()
            if isListening {
                Label(presentation.directionLabel, systemImage: presentation.direction == .inTune ? "checkmark" : "tuningfork")
                    .font(.headline)
                    .foregroundColor(presentation.direction == .waiting ? AdagioTheme.Colors.secondaryInk :
                        presentation.direction == .inTune ? AdagioTheme.Colors.success : AdagioTheme.Colors.attention)
                    .padding(.top, AdagioTheme.Space.sm)
                Text(presentation.centsLabel).font(AdagioTheme.TypeStyle.support).monospacedDigit()
                    .foregroundColor(AdagioTheme.Colors.secondaryInk)
                TuningMeter(presentation: presentation)
            }
        }.frame(maxWidth: .infinity)
    }

    private func pitchClass(_ note: Note) -> some View {
        Text(note.noteClass.description).font(.system(size: pitchSize, weight: .medium))
            .lineLimit(1).minimumScaleFactor(0.7)
    }
    private func octave(_ note: Note) -> some View {
        Text("\(note.octave)").font(.system(size: octaveSize, weight: .medium)).monospacedDigit()
    }
}

struct TunerReadout_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            sample(cents: 0.4).previewDisplayName("In tune")
            sample(cents: -12).previewDisplayName("Flat")
            sample(cents: 12).preferredColorScheme(.dark).previewDisplayName("Sharp · low light")
            TunerReadout(presentation: TunerPresentation(data: TunerData(), state: .running, instrumentKey: .F))
                .previewDisplayName("Waiting")
            sample(cents: 0).environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
                .previewDisplayName("Accessibility text")
        }
        .foregroundColor(AdagioTheme.Colors.ink)
        .padding(AdagioTheme.Space.xl)
        .background(AdagioTheme.Colors.canvas)
        .previewLayout(.sizeThatFits)
    }
    private static func sample(cents: Double) -> some View {
        let data = TunerData.measure(pitch: Float(349.2282314 * pow(2, cents / 1200)), amplitude: 1,
                                     sensitivity: 0.2, instrumentKey: .F)
        return TunerReadout(presentation: TunerPresentation(data: data, state: .running, instrumentKey: .F))
    }
}
