import Foundation
import Combine
import UIKit
import AVFoundation
import AudioKit
import AudioKitEX
import SoundpipeAudioKit

struct TunerAudioGraph {
    let engine: AudioEngine
    let waveform: Fader
    let output: Fader
    let spectrum: Fader
    let silence: Fader
    let tracker: PitchTap
}

/// Builds a fresh graph only after permission and a usable route have been established.
private final class AudioKitMicrophoneInput: MicrophoneInput {
    private let recordingClient = UUID()
    private(set) var graph: TunerAudioGraph?
    var preferredInputID: String?

    var permission: MicrophonePermission {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted: return .granted
        case .denied: return .denied
        case .undetermined: return .undetermined
        @unknown default: return .denied
        }
    }

    func requestPermission(_ completion: @escaping () -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { _ in
            DispatchQueue.main.async(execute: completion)
        }
    }

    func start(measurement: @escaping (Float, Float) -> Void) throws {
        stop()
        do {
            try AudioSessionCoordinator.shared.beginRecording(for: recordingClient)
            let session = AVAudioSession.sharedInstance()
            if let id = preferredInputID,
               let device = AudioEngine.inputDevices.first(where: { $0.deviceID == id }) {
                try AudioEngine.setInputDevice(device)
            } else {
                preferredInputID = nil
                try session.setPreferredInput(nil)
            }
            guard session.isInputAvailable, !session.currentRoute.inputs.isEmpty,
                  session.sampleRate > 0, session.inputNumberOfChannels > 0 else {
                throw MicrophoneInputError.unavailable
            }

            let engine = AudioEngine()
            let format = engine.avEngine.inputNode.inputFormat(forBus: 0)
            guard format.channelCount > 0, format.sampleRate > 0 else {
                throw MicrophoneInputError.unavailable
            }
            guard let mic = engine.input else { throw MicrophoneInputError.unavailable }
            let waveform = Fader(mic)
            let output = Fader(waveform)
            let spectrum = Fader(output)
            let silence = Fader(spectrum, gain: 0)
            engine.output = silence
            let tracker = PitchTap(mic) { pitches, amplitudes in
                guard let pitch = pitches.first, let amplitude = amplitudes.first else { return }
                DispatchQueue.main.async { measurement(pitch, amplitude) }
            }
            graph = TunerAudioGraph(engine: engine, waveform: waveform, output: output,
                                    spectrum: spectrum, silence: silence, tracker: tracker)
            try engine.start()
            guard engine.avEngine.isRunning else { throw MicrophoneInputError.unavailable }
            tracker.start()
        } catch {
            stop()
            throw error
        }
    }

    func stop() {
        graph?.tracker.stop()
        graph?.engine.stop()
        graph = nil
        AudioSessionCoordinator.shared.endRecording(for: recordingClient)
    }
}

final class TunerConductor: ObservableObject {
    static let shared = TunerConductor()
    @Published private(set) var data = TunerData()
    @Published private(set) var displayData = TunerData()
    @Published private(set) var isHoldingReading = false
    @Published private(set) var state: MicrophoneState = .idle
    @Published private(set) var graph: TunerAudioGraph?
    @Published private(set) var inputDevices: [Device] = []
    @Published private(set) var preferredInputID: String?
    @Published var micSensitivity: Float = 0.2

    private let input: AudioKitMicrophoneInput
    private let recovery: MicrophoneRecovery
    private var observers: [NSObjectProtocol] = []
    private var recoveryWork: DispatchWorkItem?
    private var routeSignature = ""
    private var displayHold = TunerDisplayHold()
    private var displayExpiryWork: DispatchWorkItem?

    init() {
        let input = AudioKitMicrophoneInput()
        self.input = input
        recovery = MicrophoneRecovery(input: input)
        recovery.onMeasurement = { [weak self] pitch, amplitude in self?.update(pitch, amplitude) }
        recovery.onStateChange = { [weak self] state in
            guard let self = self else { return }
            self.state = state
            self.graph = state == .running ? input.graph : nil
            self.data = TunerData()
            self.clearDisplay()
            self.refreshInputs()
            self.routeSignature = self.currentRouteSignature
        }
        observeAudioChanges()
        recovery.setForeground(UIApplication.shared.applicationState != .background)
    }

    deinit {
        recoveryWork?.cancel()
        displayExpiryWork?.cancel()
        observers.forEach(NotificationCenter.default.removeObserver)
        input.stop()
    }

    func start(for client: MicrophoneRecovery.Client) { recovery.start(for: client) }
    func stop(for client: MicrophoneRecovery.Client) {
        recovery.stop(for: client)
    }
    func retry() {
        recoveryWork?.cancel()
        recovery.retry()
    }

    func selectInput(_ id: String?) {
        input.preferredInputID = id
        retry()
    }

    func inputName(_ device: Device) -> String {
        let sources = AVAudioSession.sharedInstance().availableInputs?.flatMap { $0.dataSources ?? [] } ?? []
        let source = sources.first { device.deviceID.hasSuffix(" " + $0.dataSourceName) }
        return [device.name, source?.dataSourceName].compactMap { $0 }.joined(separator: " · ")
    }

    private func update(_ pitch: Float, _ amplitude: Float) {
        let instrument = InstrumentViewModel.shared.selectedInstrument ?? instruments[0]
        data = TunerData.measure(pitch: pitch, amplitude: amplitude, sensitivity: micSensitivity, instrumentKey: instrument.key)
        let previousDeadline = displayHold.deadline
        displayHold.receive(data, state: state, at: ProcessInfo.processInfo.systemUptime)
        displayData = displayHold.data
        isHoldingReading = displayHold.isHolding
        if previousDeadline != displayHold.deadline { scheduleDisplayExpiry() }
    }

    private func clearDisplay() {
        displayExpiryWork?.cancel()
        displayExpiryWork = nil
        displayHold.clear()
        displayData = TunerData()
        isHoldingReading = false
    }

    private func scheduleDisplayExpiry() {
        displayExpiryWork?.cancel()
        displayExpiryWork = nil
        guard let deadline = displayHold.deadline else { return }
        let work = DispatchWorkItem { [weak self] in
            guard let self = self, self.state == .running, self.displayHold.deadline == deadline else { return }
            self.displayHold.expire(at: ProcessInfo.processInfo.systemUptime)
            self.displayData = self.displayHold.data
            self.isHoldingReading = self.displayHold.isHolding
            // A slightly early timer must not leave a held note visible indefinitely.
            if self.displayHold.deadline != nil { self.scheduleDisplayExpiry() }
            else { self.displayExpiryWork = nil }
        }
        displayExpiryWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + max(0, deadline - ProcessInfo.processInfo.systemUptime), execute: work)
    }

    private func refreshInputs() {
        inputDevices = state == .running ? AudioEngine.inputDevices : []
        preferredInputID = input.preferredInputID
    }

    private var currentRouteSignature: String {
        let session = AVAudioSession.sharedInstance()
        return (session.currentRoute.inputs + session.currentRoute.outputs)
            .map { "\($0.uid):\($0.selectedDataSource?.dataSourceID.stringValue ?? "")" }.joined(separator: ",")
            + ":" + (session.availableInputs ?? []).map(\.uid).sorted().joined(separator: ",")
            + ":\(session.sampleRate):\(session.inputNumberOfChannels)"
    }

    private func scheduleRecovery() {
        recoveryWork?.cancel()
        let engineID = input.graph.map { ObjectIdentifier($0.engine.avEngine) }
        let work = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            // Ignore delayed notifications from a graph we have already replaced or stopped.
            guard self.input.graph.map({ ObjectIdentifier($0.engine.avEngine) }) == engineID else { return }
            self.recovery.routeChanged()
        }
        recoveryWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: work)
    }

    private func observe(_ name: Notification.Name, handler: @escaping (TunerConductor, Notification) -> Void) {
        observers.append(NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main) { [weak self] notification in
            guard let self = self else { return }
            handler(self, notification)
        })
    }

    private func observeAudioChanges() {
        observe(AVAudioSession.interruptionNotification) { conductor, notification in
            guard let raw = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
                  let type = AVAudioSession.InterruptionType(rawValue: raw) else { return }
            conductor.recoveryWork?.cancel()
            if type == .began {
                conductor.recovery.interruptionBegan()
            } else {
                let rawOptions = notification.userInfo?[AVAudioSessionInterruptionOptionKey] as? UInt ?? 0
                conductor.recovery.interruptionEnded(shouldResume: AVAudioSession.InterruptionOptions(rawValue: rawOptions).contains(.shouldResume))
            }
        }
        observe(AVAudioSession.routeChangeNotification) { conductor, notification in
            let raw = notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt ?? 0
            // Our own category changes are part of rebuilding and must not trigger a restart loop.
            guard AVAudioSession.RouteChangeReason(rawValue: raw) != .categoryChange else { return }
            if conductor.currentRouteSignature != conductor.routeSignature {
                conductor.scheduleRecovery()
            }
        }
        observe(.AVAudioEngineConfigurationChange) { conductor, notification in
            guard let engine = notification.object as? AVAudioEngine,
                  engine === conductor.input.graph?.engine.avEngine else { return }
            conductor.scheduleRecovery()
        }
        observe(AVAudioSession.mediaServicesWereLostNotification) { conductor, _ in
            conductor.recoveryWork?.cancel()
            conductor.recovery.mediaServicesLost()
        }
        observe(AVAudioSession.mediaServicesWereResetNotification) { conductor, _ in
            conductor.recovery.mediaServicesReset()
        }
        observe(UIApplication.didEnterBackgroundNotification) { conductor, _ in
            conductor.recoveryWork?.cancel()
            conductor.recovery.setForeground(false)
        }
        observe(UIApplication.didBecomeActiveNotification) { conductor, _ in
            conductor.recovery.setForeground(true)
        }
    }
}
