//
//  TunerView.swift
//  FrenchHornApp
//
//  Created by Lorenzo Brown on 7/3/23.
//

import SwiftUI
import AudioKit
import AudioKitEX
import AudioKitUI
import AudioToolbox
import SoundpipeAudioKit
import AVFoundation

struct TunerView: View {
    @StateObject private var conductor = TunerConductor.shared

    var body: some View {
        VStack {
            VStack{
                Text("Tuner View")
                    .font(AppFont.title1).bold()
                    .padding()
                
                let noteName = "\(conductor.data.noteNameWithSharps) / \(conductor.data.noteNameWithFlats)"
                
                VStack {
                    HStack {
                        VStack {
                            Text("Frequency")
                            Text("\(conductor.data.pitch, specifier: "%0.1f")")
                        }
                        VStack {
                            Text("Amplitude")
                            Text("\(conductor.data.amplitude, specifier: "%0.1f")")
                        }
                        VStack {
                            Text("Cents")
                            Text("\(conductor.data.cents, specifier: "%0.1f")")
                                .foregroundColor(centColor(cents: conductor.data.cents))
                                .font(.system(.body, design: .monospaced))
                        }
                    }.padding()
                    HStack {
                        AssembledStaffView(notes: noteNameMapping[noteName])
                        VStack {
                            NodeRollingView(conductor.tappableNodeA).clipped()
                            
                            NodeOutputView(conductor.tappableNodeB).clipped()
                            
                            NodeFFTView(conductor.tappableNodeC).clipped()
                            
                        }
                    }
                }.onAppear {
                    conductor.start()
                }
                .onDisappear {
                    conductor.stop()
                }
            }
            MetronomeView()
        }
    }

    private func centColor(cents: Float) -> Color {
        switch cents {
        case -2...2:  // In tune (±2 cents tolerance)
            return .green
        case ..<0:    // Flat
            return .blue
        default:      // Sharp
            return .red
        }
    }
}

struct TunerView_Previews: PreviewProvider {
    static var previews: some View {
        TunerView()
    }
}

struct MetronomeView: View {
    @StateObject private var metronome = MetronomeController()
    
    let timeSignatures = ["4/4", "3/4", "2/4", "6/8"]
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Metronome")
                .font(AppFont.title2).bold()
            
            HStack {
                Text("BPM: \(metronome.bpm)")
                Slider(value: $metronome.bpm, in: 40...208, step: 1)
                    .frame(width: 200)
            }
            
            HStack {
                Text("Time Signature:")
                Picker("Time Signature", selection: $metronome.timeSignature) {
                    ForEach(timeSignatures, id: \.self) { signature in
                        Text(signature)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            
            Toggle("Accent First Beat", isOn: $metronome.accentFirstBeat)
            
            Button(action: {
                if metronome.isPlaying {
                    metronome.stop()
                } else {
                    metronome.start()
                }
            }) {
                Image(systemName: metronome.isPlaying ? "stop.circle.fill" : "play.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(metronome.isPlaying ? .red : .green)
            }
        }
        .padding()
    }
}
