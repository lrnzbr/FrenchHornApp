//
//  TrebleClefNoteVisualizations.swift
//  FrenchHornApp
//
//  Created by Lorenzo Brown on 8/30/22.
//

import Foundation
import SwiftUI

protocol NoteVisualization {
	var notePosition: CGFloat { get }
	var ledgerLines: [LedgerLine]? { get }
	var incidental: Tuning { get }
}


enum Tuning {
	case sharp
	case flat
	case natural
}

struct TrebleClefNoteVisualization: NoteVisualization {
	let notePosition: CGFloat
	let ledgerLines: [LedgerLine]?
	let incidental: Tuning

	init(stepsFromMidpoint:Int, ledgerLines: [LedgerLine]?=nil, incidental: Tuning) {
		self.notePosition = CGFloat(Double(stepsFromMidpoint)/2.0) * staffHeight * -1.0
		self.ledgerLines = ledgerLines
		self.incidental = incidental
	}
}






//let TCC4 = TrebleClefNoteVisualization(stepsFromMidpoint: -6, incidental: .natural)
//let TCCSharp4 = TrebleClefNoteVisualization(stepsFromMidpoint: -6, incidental: .sharp)
//let TCDFlat4 = TrebleClefNoteVisualization(stepsFromMidpoint: -5, incidental: .flat)
//let TCD4 = TrebleClefNoteVisualization(stepsFromMidpoint: -5, incidental: .natural)
//let TCDSharp4 = TrebleClefNoteVisualization(stepsFromMidpoint: -5, incidental: .sharp)
//let TCEFlat4 = TrebleClefNoteVisualization(stepsFromMidpoint: -4, incidental: .flat)
//let TCE4 = TrebleClefNoteVisualization(stepsFromMidpoint: -4, incidental: .natural)
//let TCF4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -3, incidental: .natural)
//let TCFSharp4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -3, incidental: .sharp)
//let TCGFlat4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -2, incidental: .flat)
//let TCG4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -2, incidental: .natural)
//let TCGSharp4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -2, incidental: .sharp)
//let TCAFlat4 = TrebleClefNoteVisualization(stepsFromMidpoint: -1, incidental: .flat)
//let TCA4 = TrebleClefNoteVisualization(stepsFromMidpoint: -1, incidental: .natural)
//let TCASharp4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -1, incidental: .sharp)
//let TCBFlat4 =  TrebleClefNoteVisualization(stepsFromMidpoint: 0, incidental: .flat)
//let TCB4 =  TrebleClefNoteVisualization(stepsFromMidpoint: 0, incidental: .natural)


//let TCC4 = TrebleClefNoteVisualization(stepsFromMidpoint: -6, incidental: .natural)
//let TCCSharp4 = TrebleClefNoteVisualization(stepsFromMidpoint: -6, incidental: .sharp)
//let TCDFlat4 = TrebleClefNoteVisualization(stepsFromMidpoint: -5, incidental: .flat)
//let TCD4 = TrebleClefNoteVisualization(stepsFromMidpoint: -5, incidental: .natural)
//let TCDSharp4 = TrebleClefNoteVisualization(stepsFromMidpoint: -5, incidental: .sharp)
//let TCEFlat4 = TrebleClefNoteVisualization(stepsFromMidpoint: -4, incidental: .flat)
//let TCE4 = TrebleClefNoteVisualization(stepsFromMidpoint: -4, incidental: .natural)
//let TCF4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -3, incidental: .natural)
//let TCFSharp4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -3, incidental: .sharp)
//let TCGFlat4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -2, incidental: .flat)
//let TCG4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -2, incidental: .natural)
//let TCGSharp4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -2, incidental: .sharp)
//let TCAFlat4 = TrebleClefNoteVisualization(stepsFromMidpoint: -1, incidental: .flat)
//let TCA4 = TrebleClefNoteVisualization(stepsFromMidpoint: -1, incidental: .natural)
//let TCASharp4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -1, incidental: .sharp)
//let TCBFlat4 =  TrebleClefNoteVisualization(stepsFromMidpoint: 0, incidental: .flat)
//let TCB4 =  TrebleClefNoteVisualization(stepsFromMidpoint: 0, incidental: .natural)

//let TCC4 = TrebleClefNoteVisualization(stepsFromMidpoint: -6, incidental: .natural)
//let TCCSharp4 = TrebleClefNoteVisualization(stepsFromMidpoint: -6, incidental: .sharp)
//let TCDFlat4 = TrebleClefNoteVisualization(stepsFromMidpoint: -5, incidental: .flat)
//let TCD4 = TrebleClefNoteVisualization(stepsFromMidpoint: -5, incidental: .natural)
//let TCDSharp4 = TrebleClefNoteVisualization(stepsFromMidpoint: -5, incidental: .sharp)
//let TCEFlat4 = TrebleClefNoteVisualization(stepsFromMidpoint: -4, incidental: .flat)
//let TCE4 = TrebleClefNoteVisualization(stepsFromMidpoint: -4, incidental: .natural)
//let TCF4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -3, incidental: .natural)
//let TCFSharp4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -3, incidental: .sharp)
//let TCGFlat4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -2, incidental: .flat)
//let TCG4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -2, incidental: .natural)
//let TCGSharp4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -2, incidental: .sharp)
//let TCAFlat4 = TrebleClefNoteVisualization(stepsFromMidpoint: -1, incidental: .flat)
//let TCA4 = TrebleClefNoteVisualization(stepsFromMidpoint: -1, incidental: .natural)
//let TCASharp4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -1, incidental: .sharp)
//let TCBFlat4 =  TrebleClefNoteVisualization(stepsFromMidpoint: 0, incidental: .flat)
//let TCB4 =  TrebleClefNoteVisualization(stepsFromMidpoint: 0, incidental: .natural)

//let TCC4 = TrebleClefNoteVisualization(stepsFromMidpoint: -6, incidental: .natural)
//let TCCSharp4 = TrebleClefNoteVisualization(stepsFromMidpoint: -6, incidental: .sharp)
//let TCDFlat4 = TrebleClefNoteVisualization(stepsFromMidpoint: -5, incidental: .flat)
//let TCD4 = TrebleClefNoteVisualization(stepsFromMidpoint: -5, incidental: .natural)
//let TCDSharp4 = TrebleClefNoteVisualization(stepsFromMidpoint: -5, incidental: .sharp)
//let TCEFlat4 = TrebleClefNoteVisualization(stepsFromMidpoint: -4, incidental: .flat)
//let TCE4 = TrebleClefNoteVisualization(stepsFromMidpoint: -4, incidental: .natural)
//let TCF4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -3, incidental: .natural)
//let TCFSharp4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -3, incidental: .sharp)
//let TCGFlat4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -2, incidental: .flat)
//let TCG4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -2, incidental: .natural)
//let TCGSharp4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -2, incidental: .sharp)
//let TCAFlat4 = TrebleClefNoteVisualization(stepsFromMidpoint: -1, incidental: .flat)
//let TCA4 = TrebleClefNoteVisualization(stepsFromMidpoint: -1, incidental: .natural)
//let TCASharp4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -1, incidental: .sharp)
//let TCBFlat4 =  TrebleClefNoteVisualization(stepsFromMidpoint: 0, incidental: .flat)
//let TCB4 =  TrebleClefNoteVisualization(stepsFromMidpoint: 0, incidental: .natural)



let TCC4 = TrebleClefNoteVisualization(stepsFromMidpoint: -6, incidental: .natural)
let TCCSharp4 = TrebleClefNoteVisualization(stepsFromMidpoint: -6, incidental: .sharp)
let TCDFlat4 = TrebleClefNoteVisualization(stepsFromMidpoint: -5, incidental: .flat)
let TCD4 = TrebleClefNoteVisualization(stepsFromMidpoint: -5, incidental: .natural)
let TCDSharp4 = TrebleClefNoteVisualization(stepsFromMidpoint: -5, incidental: .sharp)
let TCEFlat4 = TrebleClefNoteVisualization(stepsFromMidpoint: -4, incidental: .flat)
let TCE4 = TrebleClefNoteVisualization(stepsFromMidpoint: -4, incidental: .natural)
let TCF4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -3, incidental: .natural)
let TCFSharp4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -3, incidental: .sharp)
let TCGFlat4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -2, incidental: .flat)
let TCG4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -2, incidental: .natural)
let TCGSharp4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -2, incidental: .sharp)
let TCAFlat4 = TrebleClefNoteVisualization(stepsFromMidpoint: -1, incidental: .flat)
let TCA4 = TrebleClefNoteVisualization(stepsFromMidpoint: -1, incidental: .natural)
let TCASharp4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -1, incidental: .sharp)
let TCBFlat4 =  TrebleClefNoteVisualization(stepsFromMidpoint: 0, incidental: .flat)
let TCB4 =  TrebleClefNoteVisualization(stepsFromMidpoint: 0, incidental: .natural)

//let TCC4 = TrebleClefNoteVisualization(stepsFromMidpoint: -6, incidental: .natural)
//let TCCSharp4 = TrebleClefNoteVisualization(stepsFromMidpoint: -6, incidental: .sharp)
//let TCDFlat4 = TrebleClefNoteVisualization(stepsFromMidpoint: -5, incidental: .flat)
//let TCD4 = TrebleClefNoteVisualization(stepsFromMidpoint: -5, incidental: .natural)
//let TCDSharp4 = TrebleClefNoteVisualization(stepsFromMidpoint: -5, incidental: .sharp)
//let TCEFlat4 = TrebleClefNoteVisualization(stepsFromMidpoint: -4, incidental: .flat)
//let TCE4 = TrebleClefNoteVisualization(stepsFromMidpoint: -4, incidental: .natural)
//let TCF4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -3, incidental: .natural)
//let TCFSharp4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -3, incidental: .sharp)
//let TCGFlat4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -2, incidental: .flat)
//let TCG4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -2, incidental: .natural)
//let TCGSharp4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -2, incidental: .sharp)
//let TCAFlat4 = TrebleClefNoteVisualization(stepsFromMidpoint: -1, incidental: .flat)
//let TCA4 = TrebleClefNoteVisualization(stepsFromMidpoint: -1, incidental: .natural)
//let TCASharp4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -1, incidental: .sharp)
//let TCBFlat4 =  TrebleClefNoteVisualization(stepsFromMidpoint: 0, incidental: .flat)
//let TCB4 =  TrebleClefNoteVisualization(stepsFromMidpoint: 0, incidental: .natural)


//let TCC4 = TrebleClefNoteVisualization(stepsFromMidpoint: -6, incidental: .natural)
//let TCCSharp4 = TrebleClefNoteVisualization(stepsFromMidpoint: -6, incidental: .sharp)
//let TCDFlat4 = TrebleClefNoteVisualization(stepsFromMidpoint: -5, incidental: .flat)
//let TCD4 = TrebleClefNoteVisualization(stepsFromMidpoint: -5, incidental: .natural)
//let TCDSharp4 = TrebleClefNoteVisualization(stepsFromMidpoint: -5, incidental: .sharp)
//let TCEFlat4 = TrebleClefNoteVisualization(stepsFromMidpoint: -4, incidental: .flat)
//let TCE4 = TrebleClefNoteVisualization(stepsFromMidpoint: -4, incidental: .natural)
//let TCF4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -3, incidental: .natural)
//let TCFSharp4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -3, incidental: .sharp)
//let TCGFlat4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -2, incidental: .flat)
//let TCG4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -2, incidental: .natural)
//let TCGSharp4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -2, incidental: .sharp)
//let TCAFlat4 = TrebleClefNoteVisualization(stepsFromMidpoint: -1, incidental: .flat)
//let TCA4 = TrebleClefNoteVisualization(stepsFromMidpoint: -1, incidental: .natural)
//let TCASharp4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -1, incidental: .sharp)
//let TCBFlat4 =  TrebleClefNoteVisualization(stepsFromMidpoint: 0, incidental: .flat)
//let TCB4 =  TrebleClefNoteVisualization(stepsFromMidpoint: 0, incidental: .natural)

//let TCC4 = TrebleClefNoteVisualization(stepsFromMidpoint: -6, incidental: .natural)
//let TCCSharp4 = TrebleClefNoteVisualization(stepsFromMidpoint: -6, incidental: .sharp)
//let TCDFlat4 = TrebleClefNoteVisualization(stepsFromMidpoint: -5, incidental: .flat)
//let TCD4 = TrebleClefNoteVisualization(stepsFromMidpoint: -5, incidental: .natural)
//let TCDSharp4 = TrebleClefNoteVisualization(stepsFromMidpoint: -5, incidental: .sharp)
//let TCEFlat4 = TrebleClefNoteVisualization(stepsFromMidpoint: -4, incidental: .flat)
//let TCE4 = TrebleClefNoteVisualization(stepsFromMidpoint: -4, incidental: .natural)
//let TCF4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -3, incidental: .natural)
//let TCFSharp4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -3, incidental: .sharp)
//let TCGFlat4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -2, incidental: .flat)
//let TCG4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -2, incidental: .natural)
//let TCGSharp4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -2, incidental: .sharp)
//let TCAFlat4 = TrebleClefNoteVisualization(stepsFromMidpoint: -1, incidental: .flat)
//let TCA4 = TrebleClefNoteVisualization(stepsFromMidpoint: -1, incidental: .natural)
//let TCASharp4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -1, incidental: .sharp)
//let TCBFlat4 =  TrebleClefNoteVisualization(stepsFromMidpoint: 0, incidental: .flat)
//let TCB4 =  TrebleClefNoteVisualization(stepsFromMidpoint: 0, incidental: .natural)

//let TCC4 = TrebleClefNoteVisualization(stepsFromMidpoint: -6, incidental: .natural)
//let TCCSharp4 = TrebleClefNoteVisualization(stepsFromMidpoint: -6, incidental: .sharp)
//let TCDFlat4 = TrebleClefNoteVisualization(stepsFromMidpoint: -5, incidental: .flat)
//let TCD4 = TrebleClefNoteVisualization(stepsFromMidpoint: -5, incidental: .natural)
//let TCDSharp4 = TrebleClefNoteVisualization(stepsFromMidpoint: -5, incidental: .sharp)
//let TCEFlat4 = TrebleClefNoteVisualization(stepsFromMidpoint: -4, incidental: .flat)
//let TCE4 = TrebleClefNoteVisualization(stepsFromMidpoint: -4, incidental: .natural)
//let TCF4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -3, incidental: .natural)
//let TCFSharp4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -3, incidental: .sharp)
//let TCGFlat4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -2, incidental: .flat)
//let TCG4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -2, incidental: .natural)
//let TCGSharp4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -2, incidental: .sharp)
//let TCAFlat4 = TrebleClefNoteVisualization(stepsFromMidpoint: -1, incidental: .flat)
//let TCA4 = TrebleClefNoteVisualization(stepsFromMidpoint: -1, incidental: .natural)
//let TCASharp4 =  TrebleClefNoteVisualization(stepsFromMidpoint: -1, incidental: .sharp)
//let TCBFlat4 =  TrebleClefNoteVisualization(stepsFromMidpoint: 0, incidental: .flat)
//let TCB4 =  TrebleClefNoteVisualization(stepsFromMidpoint: 0, incidental: .natural)
