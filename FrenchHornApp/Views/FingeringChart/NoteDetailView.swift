//
//  NoteDetailView.swift
//  FrenchHornApp
//
//  Created by Lorenzo Brown on 6/14/23.
//

import SwiftUI
import AudioKit
import AudioKitEX
import AudioKitUI
import AudioToolbox
import SoundpipeAudioKit
import AVFoundation

struct NoteDetailView: View {
    //let notes:[Note]
    @StateObject private var viewModel = FingeringChartViewModel.shared
    @Binding var isDetailScreenShown: Bool
    var instrument: Instrument

    init(isDetailScreenShown: Binding<Bool>, instrument: Instrument){
        self._isDetailScreenShown = isDetailScreenShown
        self.instrument = instrument
    }

    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Spacer()
                Text("Close")
                    .font(AppFont.caption1)
                    .foregroundColor(.blue)
                    .onTapGesture {
                    isDetailScreenShown = false
                }
            }.padding()
            NoteSampler(pitch: viewModel.selectedNotes[0].pitch(instrument.key.soundingSemitoneOffset))
            AssembledStaffView(notes: viewModel.selectedNotes)
            VStack(alignment: .leading){
            Text("Fingerings: ")
                .font(AppFont.body).bold()
                ScrollView(.horizontal){
                    HStack(alignment: .center, spacing: 6){
                        ForEach(instrument.fingerings[viewModel.selectedNotes[0]]! , id: \.self){ fingering in
                            FingeringView(instrument: instrument, fingering: fingering)
                                .padding()
                                .border(.black, width: 2)

                        }
                    }
                }
            }.padding()

        }
    }

}
struct InputDevicePicker: View {
    @ObservedObject var conductor: TunerConductor

    var body: some View {
        Picker("Microphone Input", selection: Binding(
            get: { conductor.preferredInputID },
            set: { conductor.selectInput($0) }
        )) {
            Text("System Default").tag(String?.none)
            ForEach(conductor.inputDevices, id: \.deviceID) { device in
                Text(conductor.inputName(device)).tag(Optional(device.deviceID))
            }
        }
        .pickerStyle(MenuPickerStyle())
    }
}

struct NoteDetailView_Previews: PreviewProvider {
    static var previews: some View {
		NoteDetailView(isDetailScreenShown: .constant(true), instrument: instruments[0])
			.previewLayout(.sizeThatFits)
			.padding()
    }
}

//struct TunerData {
//	var pitch: Float = 0.0
//	var amplitude: Float = 0.0
//	var noteNameWithSharps = "-"
//	var noteNameWithFlats = "-"
//}


