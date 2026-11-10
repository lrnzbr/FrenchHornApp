import Foundation

enum MicrophonePermission {
    case undetermined, denied, granted
}

enum MicrophoneState: Equatable {
    case idle, requestingPermission, permissionDenied, inputUnavailable, running
    case interrupted, resumeRequired, background, mediaServicesUnavailable
    case failed(String)
}

enum MicrophoneInputError: Error {
    case unavailable
}

/// Implementations and callers deliver events on the main thread.
protocol MicrophoneInput: AnyObject {
    var permission: MicrophonePermission { get }
    func requestPermission(_ completion: @escaping () -> Void)
    func start(measurement: @escaping (Float, Float) -> Void) throws
    func stop()
}

/// Owns recording intent independently of the audio graph, which can disappear at any time.
final class MicrophoneRecovery {
    enum Client: Hashable { case tuner, settings }

    private(set) var state: MicrophoneState = .idle {
        didSet { onStateChange?(state) }
    }
    var onStateChange: ((MicrophoneState) -> Void)?
    var onMeasurement: ((Float, Float) -> Void)?

    private let input: MicrophoneInput
    private var clients = Set<Client>()
    private var permissionRequestPending = false
    private var foreground = true
    private var interrupted = false
    private var manualResumeRequired = false
    private var mediaServicesAvailable = true
    private var generation = 0

    init(input: MicrophoneInput) { self.input = input }

    func start(for client: Client) {
        clients.insert(client)
        reconcile()
    }

    func stop(for client: Client) {
        clients.remove(client)
        if clients.isEmpty { manualResumeRequired = false }
        reconcile()
    }

    func retry() {
        // An explicit user action may retry even if the system omitted an interruption end.
        interrupted = false
        manualResumeRequired = false
        reconcile(rebuild: true)
    }

    func setForeground(_ active: Bool) {
        foreground = active
        reconcile()
    }

    func interruptionBegan() {
        interrupted = true
        reconcile()
    }

    func interruptionEnded(shouldResume: Bool) {
        guard interrupted else { return }
        interrupted = false
        manualResumeRequired = !shouldResume && !clients.isEmpty
        reconcile()
    }

    func routeChanged() { reconcile(rebuild: true) }

    func mediaServicesLost() {
        mediaServicesAvailable = false
        reconcile()
    }

    func mediaServicesReset() {
        mediaServicesAvailable = true
        reconcile(rebuild: true)
    }

    private func halt() {
        generation += 1
        input.stop()
    }

    private func reconcile(rebuild: Bool = false) {
        guard !clients.isEmpty else { halt(); state = .idle; return }
        guard foreground else { halt(); state = .background; return }
        guard mediaServicesAvailable else { halt(); state = .mediaServicesUnavailable; return }
        guard !interrupted else { halt(); state = .interrupted; return }
        guard !manualResumeRequired else { halt(); state = .resumeRequired; return }

        switch input.permission {
        case .denied:
            halt()
            state = .permissionDenied
        case .undetermined:
            halt()
            state = .requestingPermission
            guard !permissionRequestPending else { return }
            permissionRequestPending = true
            input.requestPermission { [weak self] in
                guard let self = self else { return }
                self.permissionRequestPending = false
                self.reconcile()
            }
        case .granted:
            if state == .running && !rebuild { return }
            halt()
            let currentGeneration = generation
            do {
                try input.start { [weak self] pitch, amplitude in
                    guard let self = self, self.generation == currentGeneration, self.state == .running else { return }
                    self.onMeasurement?(pitch, amplitude)
                }
                state = .running
            } catch MicrophoneInputError.unavailable {
                halt()
                state = .inputUnavailable
            } catch {
                halt()
                state = .failed(error.localizedDescription)
            }
        }
    }
}
