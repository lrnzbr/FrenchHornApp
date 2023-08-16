//
//  ChooseYourHorn.swift
//  FrenchHornApp
//
//  Created by Lorenzo Brown on 7/3/23.
//

import SwiftUI


struct ChooseYourHorn: View {
    @StateObject private var viewModel = InstrumentViewModel.shared
    var body: some View {
        NavigationView{
            if viewModel.selectedInstrument != nil {
                MainMenu(instrument: viewModel.selectedInstrument!)
            } else {
                VStack{
                    Text("Choose Your Horn")
                        .font(AppFont.title1).bold()
                        .padding()

                    List{
                        ForEach(instruments, id: \.self) { instrument in
                            NavigationLink(destination: MainMenu(instrument:instrument)){
                                InstrumentTabView(instrument: instrument)

                            }
                        }
                    }
                }
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ChooseYourHorn_Previews: PreviewProvider {
    static var previews: some View {
		ChooseYourHorn()
			.previewDevice(PreviewDevice(rawValue: "iPhone 14"))
			.previewDisplayName("iPhone 14")

		ChooseYourHorn()
			.previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (6th generation)"))
			.previewDisplayName("iPad Pro")

    }
}
