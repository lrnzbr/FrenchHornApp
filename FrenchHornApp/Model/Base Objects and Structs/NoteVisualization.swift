//
//  NoteVisualization.swift
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
