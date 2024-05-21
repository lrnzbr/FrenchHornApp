//
//  FingeringChartView.swift
//  FrenchHornApp
//
//  Created by Lorenzo Brown on 9/11/22.
//

import SwiftUI





struct FingeringChartView: View {
	let layout = [GridItem(.adaptive(minimum: 200, maximum: 500), spacing: 4, alignment: .center)]
	var instrument: Instrument
    @StateObject private var viewModel = FingeringChartViewModel.shared

	@State var isDetailScreenShown = false
	var availableNotes:[[Note]]

	init(instrument:Instrument){
		self.instrument = instrument
        self.availableNotes = instrument.availableNotes
	}
	var body: some View {
			ScrollView(){
				Text("\(instrument.name) Fingering Chart")
                    .font(AppFont.largeTitle)
                    .multilineTextAlignment(.center)
                HStack{
                    Image(instrument.handImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    Image(instrument.instrumentGuideImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .frame(maxHeight: 300)
				LazyVGrid(columns: layout, spacing: 4){
					ForEach(availableNotes, id: \.self){ notes in
						IndividualFingeringView(notes: notes, instrument:instrument ).onTapGesture {
                            viewModel.selectedNotes = notes
							isDetailScreenShown.toggle()
						}
				}
			}.frame(maxHeight: .infinity)
                .sheet(isPresented: $isDetailScreenShown) {
                        NoteDetailView(isDetailScreenShown: $isDetailScreenShown, instrument: instrument)
                }
            }.padding()
	}

}

struct FingeringChartView_Previews: PreviewProvider {
    static var previews: some View {
		FingeringChartView(instrument:instruments[0])
    }
}
