//
//  SplashScreen.swift
//  FrenchHornApp
//
//  Created by Lorenzo Brown on 7/4/23.
//

import SwiftUI

struct SplashScreen: View {
	@State var isActive: Bool = false
	var body: some View {
		ZStack {
			if self.isActive {
					ChooseYourHorn()
			} else {
				Rectangle()
					.ignoresSafeArea()
                VStack {
                    Text("The Hornist's")
                        .font(AppFont.title1).bold()
                        .foregroundColor(.white)
                    Image("SingleFHorn")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                    Text("Almanac")
                        .font(AppFont.title1).bold()
                        .foregroundColor(.white)
                }
			}
		}
		.onAppear {
			DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
				withAnimation {
					self.isActive = true
				}
			}
		}
	}

}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
