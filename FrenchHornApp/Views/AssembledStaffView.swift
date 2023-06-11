//
//  AssembledStaffView.swift
//  FrenchHornApp
//
//  Created by Lorenzo Brown on 9/13/22.
//

import SwiftUI

struct AssembledStaffView: View {
	let notes: [Note]?

	var body: some View {
		ZStack{
			ClefView()
			StaffLinesView()
			if notes != nil {
				NoteNameView(notes: notes!)
				HStack{
					AssembledNoteView(note: notes![0])
					if notes?.count == 2 {
						AssembledNoteView(note: notes![1])
					}
				}
			}
		}
	}
}

struct AssembledStaffView_Previews: PreviewProvider {
	static var previews: some View {
		AssembledStaffView(notes: [A4])
			.previewLayout(.sizeThatFits)
			.padding()
	}
}

