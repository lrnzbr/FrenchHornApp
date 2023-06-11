//
//  NoteSampler.swift
//  FrenchHornApp
//
//  Created by Lorenzo Brown on 6/10/23.
//

import SwiftUI

 struct NoteSampler: View {
	 @StateObject var conductor = InstrumentEXSConductor()
	 var pitch: Pitch
	 @State var pausePlayToggle = false


	 var body: some View {

		 Image(systemName: "speaker.fill").onTapGesture {
			 pausePlayToggle.toggle()
			 if pausePlayToggle {
				 conductor.noteOn(pitch: pitch, point: CGPoint())
			 } else {
				 conductor.noteOff(pitch: pitch)
			 }
		 }.onAppear{
			 self.conductor.start()
		 }.onDisappear {
			 self.conductor.stop()
		 }
    }
}

