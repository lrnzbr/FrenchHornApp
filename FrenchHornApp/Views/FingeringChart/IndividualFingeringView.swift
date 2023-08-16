//
//  IndividualFingeringView.swift
//  FrenchHornApp
//
//  Created by Lorenzo Brown on 9/13/22.
//

import AudioKit
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

class InstrumentEXSConductor: ObservableObject {
	let engine = AudioEngine()
	private var instrument = MIDISampler(name: "Instrument 1")

	func noteOn(pitch: Pitch, point _: CGPoint) {
		instrument.play(noteNumber: MIDINoteNumber(pitch.midiNoteNumber), velocity: 90, channel: 0)
	}

	func noteOff(pitch: Pitch) {
		instrument.stop(noteNumber: MIDINoteNumber(pitch.midiNoteNumber), channel: 0)
	}

	init() {
		engine.output = instrument
	}

	func start() {
		// Load EXS file (you can also load SoundFonts and WAV files too using the AppleSampler Class)
		do {
			if let fileURL = Bundle.main.url(forResource: "Sounds/FrenchHorn", withExtension: "aupreset") {
				try instrument.loadInstrument(url: fileURL)
			} else {
				Log("Could not find file")
			}
		} catch {
			Log("Could not load instrument")
		}
		do {
			try engine.start()
		} catch {
			Log("AudioKit did not start!")
		}
	}

	func stop() {
		engine.stop()
	}
}



struct IndividualFingeringView: View {
	let notes:[Note]
	let instrument:Instrument
    init(notes: [Note], instrument:Instrument){
		self.notes = notes
		self.instrument = instrument
	}
    var body: some View {
        VStack() {
                        AssembledStaffView(notes: notes)
                    FingeringView(instrument: instrument, fingering: instrument.fingerings[notes[0]]![0])
                    }
                    .frame(height: 390, alignment: .top)
                    .padding()
                    .border(.black, width: 4)
                    .background(.white)
                }
    }


struct IndividualFingeringView_Previews: PreviewProvider {
    static var previews: some View {
		IndividualFingeringView(notes: [B4], instrument: instruments[0])
			.previewLayout(.sizeThatFits)
			.padding()
    }
}


extension View {
	/// A convenience method for applying `TouchDownUpEventModifier.`
	func onTouchDownUp(pressed: @escaping ((Bool) -> Void)) -> some View {
		self.modifier(TouchDownUpEventModifier(pressed: pressed))
	}
}

struct TouchDownUpEventModifier: ViewModifier {
	/// Keep track of the current dragging state. To avoid using `onChange`, we won't use `GestureState`
	@State var dragged = false

	/// A closure to call when the dragging state changes.
	var pressed: (Bool) -> Void
	func body(content: Content) -> some View {
		content
			.gesture(
				DragGesture(minimumDistance: 0)
					.onChanged { _ in
						if !dragged {
							dragged = true
							pressed(true)
						}
					}
					.onEnded { _ in
						dragged = false
						pressed(false)
					}
			)
	}
}


struct  FingeringView:View {
    let pistons:Bool
    let trigger1:Bool
    let trigger2:Bool
    let instrument: Instrument
    let fingering: Fingering
    let imageWidthSize:CGFloat = 40
    let imageHeightSize:CGFloat = 40

    init(instrument: Instrument, fingering: Fingering) {
        self.instrument = instrument
        self.fingering = fingering
        self.pistons = instrument.hasPistons
        self.trigger1 = instrument.hasTrigger1
        self.trigger2 = instrument.hasTrigger2
    }

    var body: some View {
        HStack(spacing: 2){
            if !pistons {
                if trigger1 {
                    ZStack{
                        if fingering.trigger1{
                            Image("trigger_on")
                                .resizable()
                                .scaledToFit()
                                .frame(width: imageWidthSize, height: imageHeightSize)
                        } else {
                            Image("trigger_off")
                                .resizable()
                                .scaledToFit()
                                .frame(width: imageWidthSize, height: imageHeightSize)
                        }
                        //Text("T").foregroundColor(fingering.trigger1 ? .white : .black)
                    }
                }
                if trigger2 {
                    ZStack {
                    if fingering.trigger2 {
                        Image("high_trigger")
                            .resizable()
                            .scaledToFit()
                            .frame(width: imageWidthSize, height: imageHeightSize)
                    } else {
                        Image("trigger_off")
                            .resizable()
                            .scaledToFit()
                            .frame(width: imageWidthSize, height: imageHeightSize)
                    }
                        //Text("T").foregroundColor(fingering.trigger2 ? .white : .black)
                    }
                }
                ZStack {
                if fingering.valve1 {
                        Image("V_on")
                            .resizable()
                            .scaledToFit()
                            .frame(width: imageWidthSize, height: imageHeightSize)
                } else {
                    Image("V_off")
                        .resizable()
                        .scaledToFit()
                        .frame(width: imageWidthSize, height: imageHeightSize)
                }
                    Text("1").foregroundColor(fingering.valve1 ? .white : .black)
                }
                ZStack {
                if fingering.valve2 {
                    Image("V_on")
                        .resizable()
                        .scaledToFit()
                        .frame(width: imageWidthSize, height: imageHeightSize)
                } else {
                    Image("V_off")
                        .resizable()
                        .scaledToFit()
                        .frame(width: imageWidthSize, height: imageHeightSize)
                }
                    Text("2").foregroundColor(fingering.valve2 ? .white : .black)
                }
                ZStack {
                if fingering.valve3 {
                    Image("V_on")
                        .resizable()
                        .scaledToFit()
                        .frame(width: imageWidthSize, height: imageHeightSize)
                } else {
                    Image("V_off")
                        .resizable()
                        .scaledToFit()
                        .frame(width: imageWidthSize, height: imageHeightSize)
                }
                    Text("3").foregroundColor(fingering.valve3 ? .white : .black)
                }
            } else {
                ZStack {
                    if fingering.valve1 {
                        Image("ValveDown")
                            .resizable()
                            .scaledToFit()
                            .frame(width: imageWidthSize, height: imageHeightSize)
                    } else {
                        Image("ValveUp")
                            .resizable()
                            .scaledToFit()
                            .frame(width: imageWidthSize, height: imageHeightSize)
                    }
                    Text("1").foregroundColor(fingering.valve1 ? .white : .black)
                }
                ZStack {
                if fingering.valve2 {
                    Image("ValveDown")
                        .resizable()
                        .scaledToFit()
                        .frame(width: imageWidthSize, height: imageHeightSize)
                } else {
                    Image("ValveUp")
                        .resizable()
                        .scaledToFit()
                        .frame(width: imageWidthSize, height: imageHeightSize)
                }
                    Text("2").foregroundColor(fingering.valve2 ? .white : .black)
                }
                ZStack {
                if fingering.valve3 {
                    Image("ValveDown")
                        .resizable()
                        .scaledToFit()
                        .frame(width: imageWidthSize, height: imageHeightSize)
                } else {
                    Image("ValveUp")
                        .resizable()
                        .scaledToFit()
                        .frame(width: imageWidthSize, height: imageHeightSize)
                }
                    Text("3").foregroundColor(fingering.valve3 ? .white : .black)
                }

            }

        }//.frame(idealWidth: 120)
    }
}
