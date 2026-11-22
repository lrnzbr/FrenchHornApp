//
//  InstrumentViewModel.swift
//  FrenchHornApp
//
//  Created by Lorenzo Brown on 8/9/23.
//

import Foundation

class InstrumentViewModel: ObservableObject {
    static var shared = InstrumentViewModel()
    @Published var selectedInstrument: Instrument?

    init(){
        let instrumentID = UserDefaults.standard.integer(forKey: "selectedInstrument")
        if instrumentID != 0 {
            setSelectedInstrument(instrumentID: instrumentID)
        } else if AppEdition.current.instruments.count == 1 {
            // Nothing to choose between (the flute app), so skip the chooser.
            setSelectedInstrument(instrumentID: AppEdition.current.instruments[0].id)
        }
    }
    let defaults = UserDefaults.standard

    func setSelectedInstrument(instrumentID:Int){
        selectedInstrument = findInstrument(instrumentID)
        UserDefaults.standard.set(instrumentID, forKey: "selectedInstrument")
    }
    private func findInstrument(_ id:Int)->Instrument{
        let available = AppEdition.current.instruments
        return available.first { $0.id == id } ?? available[0]
    }
}
