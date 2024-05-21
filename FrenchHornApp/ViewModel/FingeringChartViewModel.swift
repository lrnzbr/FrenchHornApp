//
//  FingeringChartViewModel.swift
//  FrenchHornApp
//
//  Created by Lorenzo Brown on 8/16/23.
//

import Foundation
class FingeringChartViewModel: ObservableObject {
    static var shared = FingeringChartViewModel()
    @Published var selectedNotes: [Note]
    init(){
        self.selectedNotes = instruments[0].availableNotes[0]
    }
}
