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
            switch instrument.key{
                case .F:
                    NoteSampler(pitch: viewModel.selectedNotes[0].pitch(keyOfF))
                case .Bflat:
                    NoteSampler(pitch: viewModel.selectedNotes[0].pitch(keyOfBFlat))
            }
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
	@State var device: Device

	var body: some View {
		Picker("Input: \(device.deviceID)", selection: $device) {
			ForEach(getDevices(), id: \.self) {
				Text($0.deviceID)
			}
		}
		.pickerStyle(MenuPickerStyle())
		.onChange(of: device, perform: setInputDevice)
	}

	func getDevices() -> [Device] {
		AudioEngine.inputDevices.compactMap { $0 }
	}

	func setInputDevice(to device: Device) {
		do {
			try AudioEngine.setInputDevice(device)
		} catch let err {
			print(err)
		}
	}
}


struct NoteDetailView_Previews: PreviewProvider {
    static var previews: some View {
		NoteDetailView(isDetailScreenShown: .constant(true), instrument: instruments[0])
			.previewLayout(.sizeThatFits)
			.padding()
    }
}

struct TunerData {
	var pitch: Float = 0.0
	var amplitude: Float = 0.0
	var noteNameWithSharps = "-"
	var noteNameWithFlats = "-"
}


