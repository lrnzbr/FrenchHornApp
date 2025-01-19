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
        }
        
        if let accentedPath = Bundle.main.path(forResource: "accentedBeat", ofType: "mp3") {
            accentedBeatSound = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: accentedPath))
            accentedBeatSound?.prepareToPlay()
        }
    }
    
    func start() {
        isPlaying = true
        currentBeat = 0
        
        let timeInterval = 60.0 / bpm
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { [weak self] _ in
            self?.playBeat()
        }
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
} 