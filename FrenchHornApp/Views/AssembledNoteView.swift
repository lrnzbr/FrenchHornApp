//
//  AssembledNoteView.swift
//  FrenchHornApp
//
//  Created by Lorenzo Brown on 9/13/22.
//

import SwiftUI

struct AssembledNoteView: View {
	let note: Note!
	let noteViz: NoteVisualization!
	init(note: Note){
		self.note = note
		self.noteViz = trebleClefNoteMappings[note.id]
	}
	var body: some View {
		ZStack(alignment: .center) {
			ForEach(noteViz.ledgerLines ?? []){ ledgerLine in
				LedgerLineView(offset: ledgerLine.offset)
			}
			WholeNoteView(note: noteViz)
		}
	}
}

struct AssembledNoteView_Previews: PreviewProvider {
	static var previews: some View {
		AssembledNoteView(note: BFlat4)
			.previewLayout(.sizeThatFits)
			.padding()
	}
}
