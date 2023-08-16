//
//  TransposerView.swift
//  FrenchHornApp
//
//  Created by Lorenzo Brown on 7/3/23.
//

import SwiftUI

struct TransposerView: View {
	@State var inputInstrument: MusicalInstrument = musicalInstruments[1]
	@State var outputInstrument: MusicalInstrument = musicalInstruments[0]

    var body: some View {
		VStack {
			Text("Transposer")
			HStack {
				InputView(musicalInstrument: $inputInstrument)
				OutputView(musicalInstrument: $outputInstrument)
			}
			Text("How to use Transposer")
		}
    }
}

struct InputView : View {
	@Binding var musicalInstrument:MusicalInstrument
	var body: some View {
		VStack {
			Text("Input")
			InstrumentPicker(musicalInstrument: musicalInstrument)
			AssembledStaffView(notes: noteNameMapping["G5 / G5"])
		}
	}
}

struct OutputView : View {
	@Binding var musicalInstrument:MusicalInstrument

	var body: some View {
		VStack {
			Text("Output")
			InstrumentPicker(musicalInstrument: musicalInstrument)
			AssembledStaffView(notes: noteNameMapping["D♯6 / E♭6"])
		}
	}
}

struct TransposerView_Previews: PreviewProvider {
    static var previews: some View {
        TransposerView()
    }
}


struct InstrumentPicker: View {
	@State var musicalInstrument: MusicalInstrument

	var body: some View {
		Picker("Input: \(musicalInstrument.name)", selection: $musicalInstrument) {
			ForEach(musicalInstruments, id: \.self) {
				Text($0.name)
			}
		}
		.pickerStyle(MenuPickerStyle())
		//.onChange(of: key, perform: setKey)


		//	func setKey(to: KeyChangeOption) {
		//		do {
		//			try self.key = key
		//		}
		//	}
	}
}
struct MusicalInstrument: Identifiable , Hashable {
	var id: Int
	var name: String
}

let musicalInstruments = [
	MusicalInstrument(id: 0, name: "Piano"),
	MusicalInstrument(id: 1, name: "Horn in F"),
	MusicalInstrument(id: 2, name: "Soprano Clarinet B♭"),
	MusicalInstrument(id: 3, name: "Alto Saxophone in E♭"),
	MusicalInstrument(id: 4, name: "Soprano Clarinet in A"),
	MusicalInstrument(id: 5, name: "Alto Flute in G"),
]
