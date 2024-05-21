//
//  InstrumentTabView.swift
//  FrenchHornApp
//
//  Created by Lorenzo Brown on 7/3/23.
//

import SwiftUI

struct InstrumentTabView: View {
	var instrument: Instrument
    var body: some View {
		HStack{
			ZStack{
				Color.white
				Image(instrument.imageName)
					.resizable()
					.aspectRatio(contentMode: .fit)
					
			}
			.frame(width: 60, height: 60)
				.cornerRadius(20)

			Text(instrument.name)
		}.frame(height: 80)
			
    }
}

struct InstrumentTabView_Previews: PreviewProvider {
    static var previews: some View {
        InstrumentTabView(instrument: instruments[0])
    }
}
