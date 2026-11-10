import SwiftUI
import UIKit

struct MicrophoneStatusView: View {
    let state: MicrophoneState
    let retry: () -> Void
    @Environment(\.openURL) private var openURL

    var body: some View {
        if state != .running {
            statusContent
                .frame(maxWidth: .infinity)
                .adagioSurface()
        }
    }

    private var statusContent: some View {
        VStack(spacing: 8) {
            switch state {
            case .running:
                EmptyView()
            case .idle:
                Text("Microphone is off.")
            case .requestingPermission:
                ProgressView("Waiting for microphone permission…")
            case .permissionDenied:
                Text("Allow microphone access in Settings to use the tuner.")
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
                }
            case .inputUnavailable:
                Text("No microphone input is available. Connect a microphone or check your audio device.")
                Button("Try Again", action: retry)
            case .interrupted:
                Text("Listening is paused while another app uses audio.")
                Button("Resume Listening", action: retry)
            case .resumeRequired:
                Text("Listening is paused.")
                Button("Resume Listening", action: retry)
            case .background:
                Text("Listening is paused while the app is in the background.")
            case .mediaServicesUnavailable:
                Text("Audio is temporarily unavailable. Waiting for the system to restore it…")
            case .failed:
                Text("The microphone could not start. Check your audio device and try again.")
                Button("Try Again", action: retry)
            }
        }
        .font(.callout)
        .buttonStyle(AdagioSecondaryButtonStyle())
        .multilineTextAlignment(.center)
        .padding(.horizontal)
        .accessibilityElement(children: .contain)
    }
}
