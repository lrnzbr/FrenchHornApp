import SwiftUI
import AVFoundation

/// Output does not restart unexpectedly after a call, reset, or unplugged headphones.
private struct AudioPlaybackLifecycle: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase
    let stop: () -> Void

    func body(content: Content) -> some View {
        content
            .onDisappear(perform: stop)
            .onChange(of: scenePhase) { phase in
                if phase == .background { stop() }
            }
            .onReceive(NotificationCenter.default.publisher(for: AVAudioSession.interruptionNotification)) { notification in
                if notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt == AVAudioSession.InterruptionType.began.rawValue {
                    stop()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: AVAudioSession.routeChangeNotification)) { notification in
                if notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt == AVAudioSession.RouteChangeReason.oldDeviceUnavailable.rawValue {
                    stop()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: AVAudioSession.mediaServicesWereLostNotification)) { _ in stop() }
            .onReceive(NotificationCenter.default.publisher(for: AVAudioSession.mediaServicesWereResetNotification)) { _ in stop() }
    }
}

extension View {
    func stopPlaybackOnAudioChange(perform stop: @escaping () -> Void) -> some View {
        modifier(AudioPlaybackLifecycle(stop: stop))
    }
}
