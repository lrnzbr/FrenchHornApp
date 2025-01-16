//
//  SettingsViewModel.swift
//  FrenchHornApp
//
//  Created by Lorenzo Brown on 8/16/23.
//

import Foundation
import AudioKit
import AudioKitEX
import AudioKitUI
import AudioToolbox
import SoundpipeAudioKit
import AVFoundation

struct TunerData {
    var pitch: Float = 0.0
    var amplitude: Float = 0.0
    var cents: Float = 0.0
    var noteNameWithSharps = ""
    var noteNameWithFlats = ""
}

class TunerConductor: ObservableObject {
    @Published var data = TunerData()
    @Published var micSensitivity: Float = 0.2
    static var shared = TunerConductor()

    let engine = AudioEngine()
    let initialDevice: Device
    let mic: AudioEngine.InputNode
    let tappableNodeA: Fader
    let tappableNodeB: Fader
    let tappableNodeC: Fader
    let silence: Fader

    var tracker: PitchTap!
    let noteFrequencies = [16.35, 17.32, 18.35, 19.45, 20.6, 21.83, 23.12, 24.5, 25.96, 27.5, 29.14, 30.87]
    let noteNamesWithSharps = ["C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B"]
    let noteNamesWithFlats = ["C", "D♭", "D", "E♭", "E", "F", "G♭", "G", "A♭", "A", "B♭", "B"]


    init() {
        guard let input = engine.input else { fatalError() }
        guard let device = engine.inputDevice else { fatalError() }
        initialDevice = device

        mic = input
        tappableNodeA = Fader(mic)
        tappableNodeB = Fader(tappableNodeA)
        tappableNodeC = Fader(tappableNodeB)
        silence = Fader(tappableNodeC, gain: 0)
        engine.output = silence

        tracker = PitchTap(mic) { pitch, amp in
            DispatchQueue.main.async {
                self.update(pitch[0], amp[0])
            }
        }
    }


    func update(_ pitch: AUValue, _ amp: AUValue) {
        // Reduces sensitivity to background noise to prevent random / fluctuating data.

        guard amp > micSensitivity else { return }
        var transposition = 0
        let instrument = InstrumentViewModel.shared.selectedInstrument ?? instruments[0]
        switch instrument.key {
            case .F:
                transposition = 7
            case .Bflat:
                transposition = 2
        }
        data.pitch = pitch
        data.amplitude = amp
        let noteNamesWithSharps = noteNamesWithSharps.shift(withDistance: transposition)
        let noteNamesWithFlats = noteNamesWithFlats.shift(withDistance: transposition)


        var frequency = pitch
        while frequency > Float(noteFrequencies[noteFrequencies.count - 1]) {
            frequency /= 2.0
        }
        while frequency < Float(noteFrequencies[0]) {
            frequency *= 2.0
        }

        var minDistance: Float = 10000.0
        var index = 0

        for possibleIndex in 0 ..< noteFrequencies.count {
            let distance = fabsf(Float(noteFrequencies[possibleIndex]) - frequency)
            if distance < minDistance {
                index = possibleIndex
                minDistance = distance
            }
        }
        
        // Calculate cents deviation
        let closestNoteFrequency = Float(noteFrequencies[index])
        var adjustedPitch = pitch
        
        // Adjust pitch to be in the same octave range as the closest note
        while adjustedPitch > closestNoteFrequency * 2 {
            adjustedPitch /= 2
        }
        while adjustedPitch < closestNoteFrequency / 2 {
            adjustedPitch *= 2
        }
        
        data.cents = 1200 * log2f(adjustedPitch / closestNoteFrequency)
        
        // Normalize cents to be between -50 and +50
        data.cents = data.cents.remainder(dividingBy: 100)
        if data.cents > 50 {
            data.cents -= 100
        } else if data.cents < -50 {
            data.cents += 100
        }
        
        var octave = Int(log2f(pitch / frequency))
        if index >= noteNamesWithFlats.count - transposition {
            octave += 1
        }
        data.noteNameWithSharps = "\(noteNamesWithSharps[index])\(octave)"
        data.noteNameWithFlats = "\(noteNamesWithFlats[index])\(octave)"
    }

    func start() {
        do {
            try engine.start()
            tracker.start()
        } catch let err {
            Log(err)
        }
    }

    func stop() {
        engine.stop()
    }
}

