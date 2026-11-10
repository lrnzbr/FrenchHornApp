import AVFoundation
import os

/// The UI can write parameters without ever making the audio thread wait for it.
private final class MetronomeParameterStore {
    private let lock: UnsafeMutablePointer<os_unfair_lock_s>
    private var settings: MetronomeSettings

    init(_ settings: MetronomeSettings) {
        self.settings = settings
        lock = .allocate(capacity: 1)
        lock.initialize(to: os_unfair_lock_s())
    }

    deinit {
        lock.deinitialize(count: 1)
        lock.deallocate()
    }

    func write(_ settings: MetronomeSettings) {
        os_unfair_lock_lock(lock)
        self.settings = settings
        os_unfair_lock_unlock(lock)
    }

    func readIfAvailable() -> MetronomeSettings? {
        guard os_unfair_lock_trylock(lock) else { return nil }
        let snapshot = settings
        os_unfair_lock_unlock(lock)
        return snapshot
    }
}

/// Owns DSP state exclusively on the rendering thread; main-thread updates use a mailbox.
final class MetronomeAudioRenderer {
    let format: AVAudioFormat
    private var kernel: MetronomeRenderKernel
    private let parameters: MetronomeParameterStore

    init?(sampleRate: Double, settings: MetronomeSettings) {
        guard let kernel = MetronomeRenderKernel(sampleRate: sampleRate, settings: settings),
              let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1) else { return nil }
        self.kernel = kernel
        self.format = format
        parameters = MetronomeParameterStore(settings)
    }

    func update(settings: MetronomeSettings) { parameters.write(settings) }

    func makeSourceNode() -> AVAudioSourceNode {
        AVAudioSourceNode(format: format) { [self] _, _, frameCount, audioBufferList in
            if let settings = parameters.readIfAvailable() { kernel.update(settings) }
            let buffers = UnsafeMutableAudioBufferListPointer(audioBufferList)
            for frame in 0..<Int(frameCount) {
                let sample = kernel.nextSample()
                for buffer in buffers {
                    guard let data = buffer.mData?.assumingMemoryBound(to: Float.self) else { continue }
                    for channel in 0..<Int(buffer.mNumberChannels) {
                        data[frame * Int(buffer.mNumberChannels) + channel] = sample
                    }
                }
            }
            return noErr
        }
    }
}
