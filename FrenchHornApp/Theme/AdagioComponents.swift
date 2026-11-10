import SwiftUI

struct AdagioPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .frame(minHeight: AdagioTheme.Control.primaryHeight)
            .padding(.horizontal, AdagioTheme.Space.lg)
            .foregroundColor(AdagioTheme.Colors.canvas)
            .background(AdagioTheme.Colors.ink)
            .clipShape(RoundedRectangle(cornerRadius: AdagioTheme.Radius.control))
            .opacity(isEnabled ? (configuration.isPressed ? 0.8 : 1) : 0.45)
    }
}

struct AdagioSecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.medium))
            .padding(.horizontal, AdagioTheme.Space.lg)
            .frame(minWidth: AdagioTheme.Control.minimumTarget,
                   minHeight: AdagioTheme.Control.minimumTarget)
            .foregroundColor(AdagioTheme.Colors.ink)
            .background(configuration.isPressed ? AdagioTheme.Colors.surfaceMuted : AdagioTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AdagioTheme.Radius.control))
            .overlay(RoundedRectangle(cornerRadius: AdagioTheme.Radius.control)
                .strokeBorder(AdagioTheme.Colors.borderStrong, lineWidth: 1))
            .opacity(isEnabled ? 1 : 0.45)
    }
}

private struct AdagioSurface: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(AdagioTheme.Space.lg)
            .background(AdagioTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AdagioTheme.Radius.panel))
            .overlay(RoundedRectangle(cornerRadius: AdagioTheme.Radius.panel)
                .strokeBorder(AdagioTheme.Colors.border, lineWidth: 1))
    }
}

extension View {
    func adagioSurface() -> some View { modifier(AdagioSurface()) }
}

struct AdagioMeasurement: View {
    let value: String
    @ScaledMetric(relativeTo: .largeTitle) private var size: CGFloat = 88

    var body: some View {
        Text(value)
            .font(.system(size: size, weight: .medium, design: .default))
            .monospacedDigit()
            .foregroundColor(AdagioTheme.Colors.ink)
    }
}

struct AdagioComponents_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            examples.preferredColorScheme(.light).previewDisplayName("Studio · light")
            examples.preferredColorScheme(.dark).previewDisplayName("Studio · low light")
            examples.environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
                .previewDisplayName("Studio · accessibility text")
        }
    }

    private static var examples: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AdagioTheme.Space.xl) {
                Text("adagio studios").font(AdagioTheme.TypeStyle.wordmark)
                Text("Metronome").font(AdagioTheme.TypeStyle.screenTitle)
                AdagioMeasurement(value: "96")
                Text("Quarter notes per minute").foregroundColor(AdagioTheme.Colors.secondaryInk)
                Text("Reference pitch · A4 = 440 Hz").adagioSurface()
                Button("Start metronome") {}.buttonStyle(AdagioPrimaryButtonStyle())
                Button("Try again") {}.buttonStyle(AdagioSecondaryButtonStyle())
            }.padding(AdagioTheme.Space.xl)
        }
        .foregroundColor(AdagioTheme.Colors.ink)
        .background(AdagioTheme.Colors.canvas.ignoresSafeArea())
    }
}
