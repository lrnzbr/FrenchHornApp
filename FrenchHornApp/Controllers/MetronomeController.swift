import Foundation
import AVFoundation

class MetronomeController: ObservableObject {
    @Published var bpm: Double = 120
    @Published var timeSignature: String = "4/4"
    @Published var accentFirstBeat: Bool = true
    @Published var isPlaying: Bool = false
    
    private var timer: Timer?
    private var currentBeat: Int = 0
    private var regularBeatSound: AVAudioPlayer?
    private var accentedBeatSound: AVAudioPlayer?
    
    init() {
        setupSounds()
    }
    
    private func setupSounds() {
        if let regularPath = Bundle.main.path(forResource: "regularBeat", ofType: "mp3") {
            regularBeatSound = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: regularPath))
            regularBeatSound?.prepareToPlay()
        } else if let data = Self.syntheticClickWAV(accent: false) {
            regularBeatSound = try? AVAudioPlayer(data: data, fileTypeHint: AVFileType.wav.rawValue)
            regularBeatSound?.prepareToPlay()
        }
        
        if let accentedPath = Bundle.main.path(forResource: "accentedBeat", ofType: "mp3") {
            accentedBeatSound = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: accentedPath))
            accentedBeatSound?.prepareToPlay()
        } else if let data = Self.syntheticClickWAV(accent: true) {
            accentedBeatSound = try? AVAudioPlayer(data: data, fileTypeHint: AVFileType.wav.rawValue)
            accentedBeatSound?.prepareToPlay()
        }
        
        #if DEBUG
        if regularBeatSound == nil || accentedBeatSound == nil {
            print("MetronomeController: failed to load beat sounds (bundle MP3s missing and synthetic fallback failed).")
        }
        #endif
    }
    
    func start() {
        isPlaying = true
        currentBeat = 0
        
        let timeInterval = 60.0 / bpm
        playBeat()
        
        let t = Timer(timeInterval: timeInterval, repeats: true) { [weak self] _ in
            self?.playBeat()
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }
    
    func stop() {
        isPlaying = false
        timer?.invalidate()
        timer = nil
    }
    
    private func playBeat() {
        let beatsInMeasure = Int(timeSignature.split(separator: "/")[0]) ?? 4
        
        if currentBeat == 0 && accentFirstBeat {
            accentedBeatSound?.play()
        } else {
            regularBeatSound?.play()
        }
        
        currentBeat = (currentBeat + 1) % beatsInMeasure
    }
    
    /// Short sine burst as WAV data when `regularBeat.mp3` / `accentedBeat.mp3` are not in the app bundle.
    private static func syntheticClickWAV(accent: Bool) -> Data? {
        let sampleRate = 44_100.0
        let frequency = accent ? 1_200.0 : 880.0
        let duration = accent ? 0.055 : 0.038
        let sampleCount = Int(sampleRate * duration)
        guard sampleCount > 0 else { return nil }
        
        var samples = [Int16](repeating: 0, count: sampleCount)
        for i in 0..<sampleCount {
            let t = Double(i) / sampleRate
            let envelope = exp(-t * (accent ? 48.0 : 62.0))
            let s = sin(2.0 * Double.pi * frequency * t) * envelope * 0.88
            samples[i] = Int16(max(-32_767, min(32_767, s * 32_767.0)))
        }
        return pcmMono16WAVData(samples: samples, sampleRate: UInt32(sampleRate))
    }
    
    private static func pcmMono16WAVData(samples: [Int16], sampleRate: UInt32) -> Data? {
        let numChannels: UInt16 = 1
        let bitsPerSample: UInt16 = 16
        let byteRate = sampleRate * UInt32(numChannels) * UInt32(bitsPerSample / 8)
        let blockAlign = numChannels * (bitsPerSample / 8)
        let dataSize = UInt32(samples.count * MemoryLayout<Int16>.size)
        let riffChunkSize = 36 + dataSize
        
        var data = Data()
        data.append(contentsOf: "RIFF".utf8)
        data.append(contentsOf: riffChunkSize.leBytes)
        data.append(contentsOf: "WAVE".utf8)
        data.append(contentsOf: "fmt ".utf8)
        data.append(contentsOf: UInt32(16).leBytes)
        data.append(contentsOf: UInt16(1).leBytes)
        data.append(contentsOf: numChannels.leBytes)
        data.append(contentsOf: sampleRate.leBytes)
        data.append(contentsOf: byteRate.leBytes)
        data.append(contentsOf: blockAlign.leBytes)
        data.append(contentsOf: bitsPerSample.leBytes)
        data.append(contentsOf: "data".utf8)
        data.append(contentsOf: dataSize.leBytes)
        for s in samples {
            data.append(contentsOf: s.littleEndian.leBytes)
        }
        return data
    }
}

private extension FixedWidthInteger {
    var leBytes: [UInt8] {
        withUnsafeBytes(of: littleEndian) { Array($0) }
    }
}
