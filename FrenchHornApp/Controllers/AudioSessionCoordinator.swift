import AVFoundation
import AudioKit

/// Keeps output-only tools usable when microphone permission is denied.
/// Called on the main thread, after stopping engines when releasing their leases.
final class AudioSessionCoordinator {
    static let shared = AudioSessionCoordinator()
    private var recordingClients = Set<UUID>()
    private var playbackClients = Set<UUID>()
    private var recording: Bool { !recordingClients.isEmpty }

    func beginRecording(for client: UUID) throws {
        try configure(recording: true)
        recordingClients.insert(client)
    }

    func endRecording(for client: UUID) {
        guard recordingClients.remove(client) != nil else { return }
        releaseOrReconfigure()
    }

    func beginPlayback(for client: UUID) throws {
        try configure(recording: recording)
        playbackClients.insert(client)
    }

    func endPlayback(for client: UUID) {
        guard playbackClients.remove(client) != nil else { return }
        releaseOrReconfigure()
    }

    private func configure(recording: Bool) throws {
        let session = AVAudioSession.sharedInstance()
        let category: AVAudioSession.Category = recording ? .playAndRecord : .playback
        let options: AVAudioSession.CategoryOptions = recording
            ? [.defaultToSpeaker, .mixWithOthers, .allowBluetoothHFP, .allowBluetoothA2DP]
            : [.mixWithOthers]
        if session.category != category || session.categoryOptions != options || session.mode != .default {
            try session.setCategory(category, mode: .default, options: options)
        }
        try session.setPreferredIOBufferDuration(Settings.bufferLength.duration)
        try session.setActive(true)
    }

    private func releaseOrReconfigure() {
        do {
            if recording || !playbackClients.isEmpty {
                try configure(recording: recording)
            } else {
                try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            }
        } catch {
            // Releasing a lease must still succeed; the next explicit start can retry activation.
            Log("Could not update the audio session: \(error.localizedDescription)")
        }
    }
}
