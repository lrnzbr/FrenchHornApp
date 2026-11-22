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
                if instrument.imageName.isEmpty {
                    // No artwork yet for this instrument: show the key it is pitched in.
                    AdagioTheme.Colors.accentMuted
                    Text(instrument.key.keyName)
                        .font(.system(.title2, design: .serif).weight(.semibold))
                        .foregroundColor(AdagioTheme.Colors.accent)
                        .accessibilityHidden(true)
                } else {
                    Color.white
                    Image(instrument.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
			}
			.frame(width: 60, height: 60)
				.cornerRadius(20)

			Text(instrument.name)
		}.frame(minHeight: 80)
			
    }
}

struct InstrumentTabView_Previews: PreviewProvider {
    static var previews: some View {
        InstrumentTabView(instrument: instruments[0])
    }
}
