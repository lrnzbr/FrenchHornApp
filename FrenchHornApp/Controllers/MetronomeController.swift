import Foundation
import Combine
import AVFoundation

private final class NativeMetronomeOutput: MetronomeOutput {
    private let playbackClient = UUID()
    private var engine: AVAudioEngine?
    private var renderer: MetronomeAudioRenderer?
    private var configurationObserver: NSObjectProtocol?

    func start(settings: MetronomeSettings, failure: @escaping (String) -> Void) throws {
        stop()
        do {
            try AudioSessionCoordinator.shared.beginPlayback(for: playbackClient)
            let engine = AVAudioEngine()
            let sampleRate = engine.outputNode.inputFormat(forBus: 0).sampleRate
            guard let renderer = MetronomeAudioRenderer(sampleRate: sampleRate, settings: settings) else {
                throw NSError(domain: "MetronomeOutput", code: 1)
            }
            let source = renderer.makeSourceNode()
            engine.attach(source)
            engine.connect(source, to: engine.mainMixerNode, format: renderer.format)
            self.engine = engine
            self.renderer = renderer
            engine.prepare()
            try engine.start()
            guard engine.isRunning else { throw NSError(domain: "MetronomeOutput", code: 2) }
            configurationObserver = NotificationCenter.default.addObserver(
                forName: .AVAudioEngineConfigurationChange, object: engine, queue: .main
            ) { [weak self, weak engine] _ in
                guard let self = self, let engine = engine, self.engine === engine, !engine.isRunning else { return }
                failure("Audio output changed. Tap Play to restart the metronome.")
            }
        } catch {
            stop()
            throw error
        }
    }

    func update(settings: MetronomeSettings) { renderer?.update(settings: settings) }

    func stop() {
        if let observer = configurationObserver { NotificationCenter.default.removeObserver(observer) }
        configurationObserver = nil
        engine?.stop()
        engine = nil
        renderer = nil
        AudioSessionCoordinator.shared.endPlayback(for: playbackClient)
    }

    deinit { stop() }
}

final class MetronomeController: ObservableObject {
    @Published var bpm: Double { didSet { settingsChanged() } }
    @Published var meter: MetronomeMeter { didSet { settingsChanged() } }
    @Published var accentFirstBeat: Bool { didSet { settingsChanged() } }
    @Published private(set) var isPlaying = false
    @Published private(set) var errorMessage: String?
    private let playback = MetronomePlayback(output: NativeMetronomeOutput())
    private let preferences: MetronomePreferences

    init(preferences: MetronomePreferences = MetronomePreferences()) {
        self.preferences = preferences
        let restored = preferences.load()
        bpm = restored.bpm
        meter = restored.meter
        accentFirstBeat = restored.accentFirstBeat
        playback.onStateChange = { [weak self] state in
            guard let self = self else { return }
            self.isPlaying = state == .playing
            if case .failed(let message) = state { self.errorMessage = message }
            else { self.errorMessage = nil }
        }
    }

    private var settings: MetronomeSettings? {
        MetronomeSettings(bpm: bpm, meter: meter, accentFirstBeat: accentFirstBeat)
    }

    private func settingsChanged() {
        guard let settings = settings else {
            stop()
            errorMessage = "Choose a tempo between 40 and 208 BPM."
            return
        }
        errorMessage = nil
        playback.update(settings: settings)
        preferences.save(settings)
    }

    func start() {
        guard let settings = settings else {
            errorMessage = "Choose a tempo between 40 and 208 BPM."
            return
        }
        playback.start(settings: settings)
    }

    func stop() { playback.stop() }
    deinit { playback.stop() }
}
