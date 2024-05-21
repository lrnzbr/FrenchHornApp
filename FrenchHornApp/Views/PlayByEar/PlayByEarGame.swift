//
//  PlayByEarGame.swift
//  FrenchHornApp
//
//  Created by Lorenzo Brown on 7/4/23.
//

import SwiftUI

struct PlayByEarGame: View {
	let layout = [GridItem(.adaptive(minimum: 60, maximum: 150), spacing: 4, alignment: .leading)]
	@State var key : KeyChangeOption = keyChangeOptions[0]
    var body: some View {
		VStack {
			Text("Play By Ear").font(.title)
			Text("Your Score: 0")
			
			Text("Tap to Play sound")
            PlayPauseButton(isPlaying: .constant(false))
			KeyChangePicker(key: key)
			LazyVGrid(columns: layout, spacing: 4){
				ForEach(noteChoices, id: \.self){ note in
					NoteOption(note: note)
				}
			}.padding()

		}
    }
}

struct PlayByEarGame_Previews: PreviewProvider {
    static var previews: some View {
        PlayByEarGame()
    }
}

struct NoteOption: View {
	var note : guessableNote
	var body: some View {
		ZStack {
			Text(note.noteName)
		}.frame(width: 60, height: 60)
			.cornerRadius(25)
			.border(.blue)
			.shadow(radius: 20)
	}
}

struct guessableNote: Identifiable, Hashable {
	var id: Int
	var noteName: String
}

struct KeyChangePicker: View {
	@State var key: KeyChangeOption

	var body: some View {
		Picker("Input: \(key.name)", selection: $key) {
			ForEach(keyChangeOptions, id: \.self) {
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
struct KeyChangeOption: Identifiable , Hashable {
	var id: Int
	var name: String
}

let keyChangeOptions = [
	KeyChangeOption(id: 0, name: "Key of C"),
	KeyChangeOption(id: 1, name: "Key of F"),
	KeyChangeOption(id: 2, name: "Key of B♭"),
	KeyChangeOption(id: 3, name: "Key of E♭"),
	KeyChangeOption(id: 4, name: "Key of A"),
	KeyChangeOption(id: 5, name: "Key of G")
]

let noteChoices:[guessableNote] = [
	guessableNote(id: 0, noteName: "C"),
	guessableNote(id: 1, noteName: "C♯ / D♭"),
	guessableNote(id: 2, noteName: "D"),
	guessableNote(id: 3, noteName: "D♯ / E♭"),
	guessableNote(id: 4, noteName: "E"),
	guessableNote(id: 5, noteName: "F"),
	guessableNote(id: 6, noteName: "F♯ / G♭"),
	guessableNote(id: 7, noteName: "G"),
	guessableNote(id: 8, noteName: "G♯ / A♭"),
	guessableNote(id: 9, noteName: "A"),
	guessableNote(id: 10, noteName: "A♯ / B♭"),
	guessableNote(id: 11, noteName: "B")
]
