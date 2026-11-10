import Foundation

enum MetronomeMeter: String, CaseIterable {
    case twoFour = "2/4", threeFour = "3/4", fourFour = "4/4", sixEight = "6/8"

    var beatsPerBar: Int {
        switch self {
        case .twoFour: return 2
        case .threeFour: return 3
        case .fourFour: return 4
        case .sixEight: return 6
        }
    }

    var beatUnit: String { self == .sixEight ? "eighth note" : "quarter note" }
}

struct MetronomeSettings: Equatable {
    static let tempoRange = 40.0...208.0
    let bpm: Double
    let meter: MetronomeMeter
    let accentFirstBeat: Bool

    init?(bpm: Double, meter: MetronomeMeter, accentFirstBeat: Bool) {
        guard bpm.isFinite, Self.tempoRange.contains(bpm) else { return nil }
        self.bpm = bpm
        self.meter = meter
        self.accentFirstBeat = accentFirstBeat
    }
}

struct MetronomeBeat: Equatable {
    let indexInBar: Int
    let accented: Bool
}

/// Advances on the audio sample clock, never on a UI timer. Render-thread owned.
struct MetronomeClock {
    private(set) var settings: MetronomeSettings
    let sampleRate: Double
    private var framesRemaining: Double = 0
    private var nextBeatInBar = 0

    init?(sampleRate: Double, settings: MetronomeSettings) {
        guard sampleRate.isFinite, (8_000...384_000).contains(sampleRate) else { return nil }
        self.sampleRate = sampleRate
        self.settings = settings
    }

    mutating func update(_ newSettings: MetronomeSettings) {
        // Keep the completed fraction of the current beat when changing tempo.
        if newSettings.bpm != settings.bpm {
            framesRemaining *= settings.bpm / newSettings.bpm
        }
        if newSettings.meter != settings.meter { nextBeatInBar = 0 }
        settings = newSettings
    }

    mutating func nextFrame() -> MetronomeBeat? {
        var beat: MetronomeBeat?
        if framesRemaining <= 0 {
            beat = MetronomeBeat(indexInBar: nextBeatInBar,
                                 accented: settings.accentFirstBeat && nextBeatInBar == 0)
            nextBeatInBar = (nextBeatInBar + 1) % settings.meter.beatsPerBar
            // Carry fractional frames forward rather than rounding every interval.
            framesRemaining += sampleRate * 60 / settings.bpm
        }
        framesRemaining -= 1
        return beat
    }
}

/// Precomputes clicks before playback; rendering performs no allocation or trigonometry.
struct MetronomeRenderKernel {
    private var clock: MetronomeClock
    private let regularClick: [Float]
    private let accentedClick: [Float]
    private var clickFrame = Int.max
    private var accented = false

    init?(sampleRate: Double, settings: MetronomeSettings) {
        guard let clock = MetronomeClock(sampleRate: sampleRate, settings: settings) else { return nil }
        self.clock = clock
        regularClick = Self.click(sampleRate: sampleRate, frequency: 880, duration: 0.038, decay: 62)
        accentedClick = Self.click(sampleRate: sampleRate, frequency: 1_200, duration: 0.055, decay: 48)
    }

    mutating func update(_ settings: MetronomeSettings) { clock.update(settings) }

    mutating func nextSample() -> Float {
        if let beat = clock.nextFrame() {
            clickFrame = 0
            accented = beat.accented
        }
        if accented {
            guard clickFrame < accentedClick.count else { return 0 }
            let sample = accentedClick[clickFrame]
            clickFrame += 1
            return sample
        } else {
            guard clickFrame < regularClick.count else { return 0 }
            let sample = regularClick[clickFrame]
            clickFrame += 1
            return sample
        }
    }

    private static func click(sampleRate: Double, frequency: Double, duration: Double, decay: Double) -> [Float] {
        (0..<Int(sampleRate * duration)).map { frame in
            let time = Double(frame) / sampleRate
            return Float(sin(2 * .pi * frequency * time) * exp(-time * decay) * 0.88)
        }
    }
}

protocol MetronomeOutput: AnyObject {
    func start(settings: MetronomeSettings, failure: @escaping (String) -> Void) throws
    func update(settings: MetronomeSettings)
    func stop()
}

/// Main-thread transport policy, tested with a fake output rather than physical speakers.
final class MetronomePlayback {
    enum State: Equatable { case stopped, playing, failed(String) }
    private(set) var state: State = .stopped { didSet { onStateChange?(state) } }
    var onStateChange: ((State) -> Void)?
    private let output: MetronomeOutput
    private var generation = 0

    init(output: MetronomeOutput) { self.output = output }

    func start(settings: MetronomeSettings) {
        guard state != .playing else { return }
        generation += 1
        let current = generation
        do {
            try output.start(settings: settings) { [weak self] message in
                guard let self = self, self.generation == current, self.state == .playing else { return }
                self.stop()
                self.state = .failed(message)
            }
            state = .playing
        } catch {
            output.stop()
            state = .failed("The metronome could not start. Check your audio output and try again.")
        }
    }

    func update(settings: MetronomeSettings) {
        if state == .playing { output.update(settings: settings) }
    }

    func stop() {
        guard state != .stopped else { return }
        generation += 1
        output.stop()
        state = .stopped
    }
}
