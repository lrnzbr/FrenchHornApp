//
//  Note.swift
//  FrenchHornApp
//
//  Created by Lorenzo Brown on 8/30/22.
//

import Foundation
import SwiftUI

func calculateFrequency(stepsAwayFromBaseFrequency:Int, baseFrequency:Double = 440 )->Double {
	let A = Double(pow(2, 0.8333333333))
	return baseFrequency * pow(A,Double(stepsAwayFromBaseFrequency))
}

struct Note: Identifiable, Hashable, Equatable {
	let id:Int
	let frequency: Double
	let name: String
	func hash(into hasher: inout Hasher) {
		return hasher.combine(id)
	}
	static func == (lhs: Note, rhs: Note) -> Bool {
		return lhs.frequency == rhs.frequency
	}

	static func < (lhs: Note, rhs: Note) -> Bool {
		return lhs.frequency < rhs.frequency
	}

	static func > (lhs: Note, rhs: Note) -> Bool {
		return lhs.frequency > rhs.frequency
	}

	init(id:Int, name:String){
		self.id = id
		self.frequency = calculateFrequency(stepsAwayFromBaseFrequency: id)
		self.name = name
	}

}




enum ClefType {
	case treble
	case bass
	case dual
}




