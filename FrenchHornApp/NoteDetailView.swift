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
	let notes:[Note]
	@Binding var isDetailScreenShown: Bool
	@StateObject var conductor = TunerConductor()


	let fingerings : [DoubleHornFingering]

	init(notes: [Note], isDetailScreenShown: Binding<Bool>){
		self.notes = notes
		self._isDetailScreenShown = isDetailScreenShown
		self.fingerings = doubleHornFingerings[notes[0]]!
	}

	var body: some View {
		ScrollView{
			VStack() {
				Text("Close").onTapGesture {
					isDetailScreenShown = false
				}
				AssembledStaffView(notes: notes)
				NoteSampler(pitch: notes[0].pitch)



				ForEach(fingerings) { fingering in
					HStack(spacing: 2) {
						if fingering.trigger {
							Image("trigger_on")
								.resizable()
								.scaledToFit()
								.frame(width: 50, height: 50)
						} else {
							Image("trigger_off")
								.resizable()
								.scaledToFit()
								.frame(width: 50, height: 50)
						}

						if fingering.valve1 {
							Image("V_on")
								.resizable()
								.scaledToFit()
								.frame(width: 50, height: 50)
						} else {
							Image("V_off")
								.resizable()
								.scaledToFit()
								.frame(width: 50, height: 50)
						}
						if fingering.valve2 {
							Image("V_on")
								.resizable()
								.scaledToFit()
								.frame(width: 50, height: 50)
						} else {
							Image("V_off")
								.resizable()
								.scaledToFit()
								.frame(width: 50, height: 50)
						}
						if fingering.valve3 {
							Image("V_on")
								.resizable()
								.scaledToFit()
								.frame(width: 50, height: 50)
						} else {
							Image("V_off")
								.resizable()
								.scaledToFit()
								.frame(width: 50, height: 50)
						}

					}
				}

				let noteName = "\(conductor.data.noteNameWithSharps) / \(conductor.data.noteNameWithFlats)"

				VStack {
					HStack {
						Text("Frequency")
						Spacer()
						Text("\(conductor.data.pitch, specifier: "%0.1f")")
					}.padding()

					HStack {
						Text("Amplitude")
						Spacer()
						Text("\(conductor.data.amplitude, specifier: "%0.1f")")
					}.padding()

					HStack {
						Text("Note Name")
						Spacer()
						Text(noteName)
					}.padding()

					InputDevicePicker(device: conductor.initialDevice)

					NodeRollingView(conductor.tappableNodeA).clipped()

					NodeOutputView(conductor.tappableNodeB).clipped()

					NodeFFTView(conductor.tappableNodeC).clipped()

					AssembledStaffView(notes: noteNameMapping[noteName])


				}.onAppear {
					conductor.start()
				}
				.onDisappear {
					conductor.stop()
				}


			}
			//.frame(height: 390, alignment: .top)
			.padding()
			.border(.black, width: 4)
			.background(.white)
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
		NoteDetailView(notes: [B4], isDetailScreenShown: .constant(true))
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

class TunerConductor: ObservableObject {
	@Published var data = TunerData()

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
		guard amp > 0.1 else { return }
		let transposition = 7
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

