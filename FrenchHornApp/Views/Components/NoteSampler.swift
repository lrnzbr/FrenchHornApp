import SwiftUI

struct NoteSampler: View {
    @StateObject private var conductor = InstrumentEXSConductor()
    var pitch: Pitch
    var isActive = true
    var contextID = 0
    @State private var isPlaying = false
    @Environment(\.sizeCategory) private var sizeCategory

    var body: some View {
        VStack {
            Button {
                if isPlaying {
                    stop()
                } else if isActive && conductor.start() {
                    conductor.noteOn(pitch: pitch, point: CGPoint())
                    isPlaying = true
                }
            } label: {
                Label(sizeCategory.isAccessibilityCategory ? (isPlaying ? "Stop" : "Play") : (isPlaying ? "Stop reference" : "Play reference"),
                      systemImage: isPlaying ? "stop.fill" : "play.fill")
            }
            .buttonStyle(AdagioPrimaryButtonStyle())
            .disabled(!isActive)
            .accessibilityLabel(isPlaying ? "Stop reference" : "Play reference")
            .accessibilityIdentifier("reference.transport")
            if let message = conductor.errorMessage {
                Text(message).font(.callout).multilineTextAlignment(.center)
            }
        }
        .onChange(of: pitch) { _ in stop() }
        .onChange(of: contextID) { _ in stop() }
        .onChange(of: isActive) { active in if !active { stop() } }
        .stopPlaybackOnAudioChange(perform: stop)
    }

    private func stop() {
        conductor.stop()
        isPlaying = false
    }
}
