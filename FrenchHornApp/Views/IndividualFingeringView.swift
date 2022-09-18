//
//  IndividualFingeringView.swift
//  FrenchHornApp
//
//  Created by Lorenzo Brown on 9/13/22.
//

import SwiftUI

struct IndividualFingeringView: View {
		let notes:[Note]
		let fingerings : [DoubleHornFingering]
		init(notes: [Note]){
			self.notes = notes
			self.fingerings = doubleHornFingerings[notes[0].id]!
		}
		var body: some View {
			VStack() {
				AssembledStaffView(notes: notes)
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

			}.frame(height: 390, alignment: .top)
				.padding()
				.border(.black, width: 4)
		}
    }

struct IndividualFingeringView_Previews: PreviewProvider {
    static var previews: some View {
		IndividualFingeringView(notes: [B4])
			.previewLayout(.sizeThatFits)
			.padding()
    }
}
