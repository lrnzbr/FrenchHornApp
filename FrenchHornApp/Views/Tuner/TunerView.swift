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
    }
}

struct TunerView_Previews: PreviewProvider {
    static var previews: some View {
        TunerView()
    }
}
