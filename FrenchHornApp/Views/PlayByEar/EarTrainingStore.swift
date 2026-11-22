import AdagioCore
import AudioKit
import AVFoundation
import SwiftUI

/// Saves ear-training progress between launches. The rules live in `AdagioCore.EarProgress`.
final class EarTrainingStore: ObservableObject {
    private static let storageKey = "adagio.earProgress.v1"

    @Published var progress: EarProgress {
        didSet { save() }
    }

    init() {
        if let data = UserDefaults.standard.data(forKey: Self.storageKey),
           let stored = try? JSONDecoder().decode(EarProgress.self, from: data) {
            progress = stored
        } else {
            progress = EarProgress()
        }
        progress.rollForward(now: Date())
    }

    private func save() {
        if let data = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }
}

/// Plays an ear-training prompt: a short run of notes, one after another, on the horn sample.
final class EarPromptPlayer: ObservableObject {
    @Published private(set) var isPlaying = false
    @Published private(set) var errorMessage: String?

    private var engine: AudioEngine?
    private var sampler: MIDISampler?
    private var pending: [DispatchWorkItem] = []
    private let playbackClient = UUID()
    private let noteLength = 0.55
    private let noteSpacing = 0.65

    /// `midiNotes` are sounding pitches.
    func play(midiNotes: [Int]) {
        stop()
        errorMessage = nil
        let notes = midiNotes.filter { (0...127).contains($0) }
        guard !notes.isEmpty else { return }
        do {
            try AudioSessionCoordinator.shared.beginPlayback(for: playbackClient)
            let engine = AudioEngine()
            let sampler = MIDISampler(name: "Ear Training")
            engine.output = sampler
            self.engine = engine
            self.sampler = sampler
            guard let url = Bundle.main.url(forResource: "Sounds/FrenchHorn", withExtension: "aupreset") else {
                throw NSError(domain: "EarPrompt", code: 1)
            }
            try sampler.loadInstrument(url: url)
            try engine.start()
            guard engine.avEngine.isRunning else {
                throw NSError(domain: "EarPrompt", code: 2)
            }
        } catch {
            stop()
            errorMessage = "The prompt could not play. Check your audio output and try again."
            return
        }

        isPlaying = true
        for (index, note) in notes.enumerated() {
            let start = Double(index) * noteSpacing
            schedule(after: start) { [weak self] in
                self?.sampler?.play(noteNumber: MIDINoteNumber(note), velocity: 90, channel: 0)
            }
            schedule(after: start + noteLength) { [weak self] in
                self?.sampler?.stop(noteNumber: MIDINoteNumber(note), channel: 0)
            }
        }
        schedule(after: Double(notes.count) * noteSpacing + 0.3) { [weak self] in
            self?.stop()
        }
    }

    func stop() {
        pending.forEach { $0.cancel() }
        pending = []
        engine?.stop()
        engine = nil
        sampler = nil
        AudioSessionCoordinator.shared.endPlayback(for: playbackClient)
        if isPlaying { isPlaying = false }
    }

    private func schedule(after delay: Double, _ work: @escaping () -> Void) {
        let item = DispatchWorkItem(block: work)
        pending.append(item)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: item)
    }

    deinit {
        pending.forEach { $0.cancel() }
        engine?.stop()
        AudioSessionCoordinator.shared.endPlayback(for: playbackClient)
    }
}
