//
//  MainMenu.swift
//  FrenchHornApp
//
//  Created by Lorenzo Brown on 7/3/23.
//

import SwiftUI

struct MainMenu: View {
    var instrument:Instrument
    @StateObject private var viewModel = InstrumentViewModel.shared

    var body: some View {
		VStack{
			Text("The Hornist's Almanac")
                .font(AppFont.title1).bold()
                .padding()
            Image(instrument.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 80)
			List{
                NavigationLink(destination: FingeringChartView(instrument:viewModel.selectedInstrument ?? instrument)){
					Text("Fingering Chart")
				}
				NavigationLink(destination: TunerView()){
					Text("Tuner")
				}
//				NavigationLink(destination: TransposerView()){
//					Text("Transposer")
//				}
//				NavigationLink(destination: PlayByEarGame()){
//					Text("Play By Ear Game")
//				}
//				NavigationLink(destination: ResourcesView()){
//					Text("Resources")
//				}
				NavigationLink(destination: SettingsView()){
					Text("Settings")
				}
				NavigationLink(destination: AboutView()){
					Text("About")
				}
			}
        }.onAppear(){
            viewModel.setSelectedInstrument(instrumentID: instrument.id)
        }
    }
}

struct MainMenu_Previews: PreviewProvider {
    static var previews: some View {
        MainMenu(instrument: instruments[0])
    }
}
