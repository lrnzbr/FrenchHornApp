//
//  ClefView.swift
//  FrenchHornApp
//
//  Created by Lorenzo Brown on 9/6/22.
//

import SwiftUI

struct ClefView: View {
	var body: some View {
		HStack {
			Image("treble_clef")
				.resizable()
				.scaledToFit()
				.frame(width: 50, height: 50)

			Spacer()
		}

	}
}

struct ClefView_Previews: PreviewProvider {
	static var previews: some View {
		ClefView()
			.previewLayout(.sizeThatFits)
			.padding()
	}
}
