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

    init(note: Note) {
        // B4 is the middle staff line. Each letter step moves half a staff space.
        let steps = (note.octave - 4) * 7 + note.letter.rawValue - Letter.B.rawValue
        notePosition = CGFloat(-steps) * staffHeight / 2

        let ledgerSteps: [Int]
        if steps <= -6 {
            ledgerSteps = Array(stride(from: -6, through: steps, by: -2))
        } else if steps >= 6 {
            ledgerSteps = Array(stride(from: 6, through: steps, by: 2))
        } else {
            ledgerSteps = []
        }
        ledgerLines = ledgerSteps.isEmpty ? nil : ledgerSteps.map {
            LedgerLine(offset: CGFloat(-$0) * staffHeight / 2)
        }
        switch note.accidental {
        case .sharp, .doubleSharp: incidental = .sharp
        case .flat, .doubleFlat: incidental = .flat
        case .natural: incidental = .natural
        }
    }

	init(stepsFromMidpoint:Int, ledgerLines: [LedgerLine]?=nil, incidental: Tuning) {
		self.notePosition = CGFloat(Double(stepsFromMidpoint)/2.0) * staffHeight * -1.0
		self.ledgerLines = ledgerLines
		self.incidental = incidental
	}
}
