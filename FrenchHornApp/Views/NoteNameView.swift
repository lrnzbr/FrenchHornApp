//
//  NoteNameView.swift
//  FrenchHornApp
//
//  Created by Lorenzo Brown on 9/13/22.
//

import SwiftUI

struct NoteNameView: View {
	let notes:[Note]

	var body: some View {

		VStack{
			if notes.count == 1 {
				Text(notes[0].name)
					.font(.headline)
					.fontWeight(.black)

			} else {
				Text(notes[0].name + "/" + notes[1].name)
					.font(.headline)
					.fontWeight(.black)
			}
			Spacer()
		}

	}
}
struct NoteNameView_Previews: PreviewProvider {
	static var previews: some View {
		NoteNameView(notes: [ASharp4, BFlat4] )
			.previewLayout(.sizeThatFits)
			.padding()
	}
}
