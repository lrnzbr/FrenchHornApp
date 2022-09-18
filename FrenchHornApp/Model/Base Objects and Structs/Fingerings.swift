//
//  Fingerings.swift
//  FrenchHornApp
//
//  Created by Lorenzo Brown on 8/30/22.
//

import Foundation

struct DoubleHornFingering : Identifiable {
	var id: Int
	let trigger: Bool
	let valve1: Bool
	let valve2: Bool
	let valve3: Bool
}
	
struct SingleFHornFingering {
	let valve1: Bool
	let valve2: Bool
	let valve3: Bool
}


struct SingleBFlatHornFingering {
	let valve1: Bool
	let valve2: Bool
	let valve3: Bool
}
