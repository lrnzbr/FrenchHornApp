import SwiftUI

struct TunerView: View {
    var isActive = true
    @StateObject private var conductor = TunerConductor.shared
    @StateObject private var instrumentModel = InstrumentViewModel.shared
    @State private var listeningRequested = true
    @Environment(\.sizeCategory) private var sizeCategory
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    private var key: InstrumentKey { instrumentModel.selectedInstrument?.key ?? .F }
    private var presentation: TunerPresentation {
        TunerPresentation(data: conductor.displayData, state: isActive && listeningRequested ? conductor.state : .idle, instrumentKey: key)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AdagioTheme.Space.lg) {
                if let instrument = instrumentModel.selectedInstrument {
                    Text(instrument.name)
                        .font(AdagioTheme.TypeStyle.support)
                        .foregroundColor(AdagioTheme.Colors.secondaryInk)
                }
                TunerReadout(presentation: presentation, isListening: isActive && listeningRequested && conductor.state == .running,
                             isHolding: conductor.isHoldingReading)
                if listeningRequested {
                    MicrophoneStatusView(state: conductor.state, retry: conductor.retry)
                } else {
                    Text("Tuner paused").font(.headline).foregroundColor(AdagioTheme.Colors.secondaryInk)
                }
                Group {
                    if sizeCategory.isAccessibilityCategory {
                        VStack(alignment: .leading, spacing: AdagioTheme.Space.lg) { referencePitch; notation }
                    } else {
                        HStack { referencePitch; Spacer(); notation }
                    }
                }.frame(maxWidth: .infinity, alignment: .leading).adagioSurface()
                if conductor.state == .running && listeningRequested {
                    Label("Microphone · Listening", systemImage: "mic")
                        .font(.caption).foregroundColor(AdagioTheme.Colors.secondaryInk)
                }
            }
            .padding(AdagioTheme.Space.xl)
            .frame(maxWidth: 680)
            .frame(maxWidth: .infinity)
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                listeningRequested.toggle()
                updateActivity()
            } label: {
                Text(sizeCategory.isAccessibilityCategory ? (listeningRequested ? "Pause" : "Resume") : (listeningRequested ? "Pause tuner" : "Resume tuner"))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(AdagioSecondaryButtonStyle())
            .accessibilityLabel(listeningRequested ? "Pause tuner" : "Resume tuner")
            .accessibilityIdentifier("tuner.listening")
            .disabled(!isActive)
            .padding(.horizontal, AdagioTheme.Space.lg)
            .padding(.vertical, verticalSizeClass == .compact ? AdagioTheme.Space.xs : AdagioTheme.Space.lg)
            .frame(maxWidth: 680).frame(maxWidth: .infinity)
            .background(AdagioTheme.Colors.canvas)
        }
        .onAppear { updateActivity() }
        .onChange(of: isActive) { _ in updateActivity() }
        .onDisappear { conductor.stop(for: .tuner) }
    }

    private var referencePitch: some View {
        VStack(alignment: .leading, spacing: AdagioTheme.Space.xs) {
            Text("Reference pitch").font(.caption).foregroundColor(AdagioTheme.Colors.secondaryInk)
            Text("A4 = 440 Hz").font(AdagioTheme.TypeStyle.support.weight(.medium))
        }
    }
    private var notation: some View {
        VStack(alignment: .leading, spacing: AdagioTheme.Space.xs) {
            Text("Notation").font(.caption).foregroundColor(AdagioTheme.Colors.secondaryInk)
            Text(key == .F ? "Horn in F" : "Horn in B♭").font(AdagioTheme.TypeStyle.support.weight(.medium))
        }
    }
    private func updateActivity() {
        if isActive && listeningRequested { conductor.start(for: .tuner) }
        else { conductor.stop(for: .tuner) }
    }
}

struct TunerView_Previews: PreviewProvider {
    static var previews: some View { TunerView(isActive: false) }
}
