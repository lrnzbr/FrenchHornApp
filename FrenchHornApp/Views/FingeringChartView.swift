//
//  FingeringChartView.swift
//  FrenchHornApp
//
//  Created by Lorenzo Brown on 9/11/22.
//

import SwiftUI

let availableNotes = [[C2], [CSharp2, DFlat2], [D2], [DSharp2, EFlat2], [E2], [F2], [FSharp2, GFlat2], [G2], [GSharp2, AFlat2], [A2], [ASharp2, BFlat2], [B2],
					  [C3], [CSharp3, DFlat3], [D3], [DSharp3, EFlat3], [E3], [F3], [FSharp3, GFlat3], [G3], [GSharp3, AFlat3], [A3], [ASharp3, BFlat3], [B3],
					  [C4], [CSharp4, DFlat4], [D4], [DSharp4, EFlat4], [E4], [F4], [FSharp4, GFlat4], [G4], [GSharp4, AFlat4], [A4], [ASharp4, BFlat4], [B4],
					  [C5], [CSharp5, DFlat5], [D5], [DSharp5, EFlat5], [E5], [F5], [FSharp5, GFlat5], [G5], [GSharp5, AFlat5], [A5], [ASharp5, BFlat5], [B5],
					  [C6]]

let layout = [GridItem(.adaptive(minimum: 200, maximum: 500), spacing: 4, alignment: .center)]


struct FingeringChartView: View {
	@Namespace  var fullscreenAnimation
	@State var isDetailScreenShown = false
	@State var selectedNotes: [Note] = []
	var body: some View {
		if isDetailScreenShown {
			NoteDetailView(notes: selectedNotes, isDetailScreenShown: $isDetailScreenShown)
		} else {
			ScrollView(){
				Text("Double Horn Fingering Chart")
				LazyVGrid(columns: layout, spacing: 4){
					ForEach(availableNotes, id: \.self){ notes in
						IndividualFingeringView(notes: notes ).onTapGesture {
							selectedNotes = notes
							isDetailScreenShown.toggle()
						}
					}
				}
			}.frame(maxHeight: .infinity)
		}
	}

}

struct FingeringChartView_Previews: PreviewProvider {
    static var previews: some View {
        FingeringChartView()
    }
}
