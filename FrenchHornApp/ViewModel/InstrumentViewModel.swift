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
        }
    }
    let defaults = UserDefaults.standard

    func setSelectedInstrument(instrumentID:Int){
        selectedInstrument = findInstrument(instrumentID)
        UserDefaults.standard.set(instrumentID, forKey: "selectedInstrument")
    }
    private func findInstrument(_ id:Int)->Instrument{
        for instrument in instruments {
            if instrument.id == id {
                return instrument
            }
        }
        return instruments[0]
    }
}
