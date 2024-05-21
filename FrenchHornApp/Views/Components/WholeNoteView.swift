//
//  WholeNoteView.swift
//  FrenchHornApp
//
//  Created by Lorenzo Brown on 9/13/22.
//

import SwiftUI

struct WholeNoteView: View {
	let note: NoteVisualization
	var body: some View {
		if note.incidental == .flat{
			HStack(spacing: 0){
				Image("flat_sign").resizable()
					.frame(width: 5, height: 10)
					.offset(y: note.notePosition)

				Image("whole_note").resizable()
					.frame(width: 15, height: 15)
					.offset(y: note.notePosition)
			}
		} else if note.incidental == .sharp{
			HStack(spacing: 0){
				Image("sharp_sign").resizable()
					.frame(width: 5, height: 10)
					.offset(y: note.notePosition)

				Image("whole_note").resizable()
					.frame(width: 15, height: 15)
					.offset(y: note.notePosition)
			}
		} else {
			Image("whole_note").resizable()
				.frame(width: 20, height: 20)
				.offset(y: note.notePosition)
		}
	}
}

struct WholeNoteView_Previews: PreviewProvider {
	static var previews: some View {
		WholeNoteView(note: TCBFlat4)
			.previewLayout(.sizeThatFits)
			.padding()
	}
}
