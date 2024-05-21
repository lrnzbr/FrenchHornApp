//
//  MarchingBFlatHornFingerings.swift
//  FrenchHornApp
//
//  Created by Lorenzo Brown on 7/4/23.
//

import Foundation
struct MarchingBFlatHornFingering: Identifiable {
	var id: Int
	let valve1: Bool
	let valve2: Bool
	let valve3: Bool
}
private let open = MarchingBFlatHornFingering(id: 0, valve1: false, valve2: false, valve3: false)
private let o010 = MarchingBFlatHornFingering(id: 1, valve1: false, valve2: true, valve3: false)
private let o011 = MarchingBFlatHornFingering(id: 2, valve1: false, valve2: true, valve3: true)
private let o100 = MarchingBFlatHornFingering(id: 3, valve1: true, valve2: false, valve3: false)
private let o101 = MarchingBFlatHornFingering(id: 4, valve1: true, valve2: false, valve3: true)
private let o110 = MarchingBFlatHornFingering(id: 5, valve1: true, valve2: true, valve3: false)
private let o111 = MarchingBFlatHornFingering(id: 6, valve1: true, valve2: true, valve3: true)


let MarchingBFlatHornFingeringsBFlatWritten: [Note : [MarchingBFlatHornFingering]] = [
	F3 : [o100],
	FSharp3 : [o010],
	GFlat3 : [o010],
	G3 : [open],
	GSharp3 : [o011],
	AFlat3 : [o011],
	A3 : [o110],
	ASharp3 : [o100],
	BFlat3 : [o100],
	B3 : [o010],

	C4 : [open],
	CSharp4 : [o110],
	DFlat4 : [o110],
	D4 : [o100],
	DSharp4 : [o010],
	EFlat4 : [o010],
	E4 : [open],
	F4 : [o100],
	FSharp4 : [o010],
	GFlat4 : [o010],
	G4 : [open],
	GSharp4 : [o011],
	AFlat4 : [o011],
	A4 : [o011],
	ASharp4 : [o100],
	BFlat4 : [o100],
	B4 : [o010],

	C5 : [open],
	CSharp5 : [o110, o010],
	DFlat5 : [o110, o010],
	D5 : [o110, o010],
	DSharp5 : [o010],
	EFlat5 : [o010],
	E5 : [open],
	F5 : [o100],
	FSharp5 : [o010],
	GFlat5 : [o010],
	G5 : [open],
	GSharp5 : [o011],
	AFlat5 : [o011],
	A5 : [o110],
	ASharp5 : [o100],
	BFlat5 : [o100],
	B5 : [o010],

	C6 : [open]

]

let MarchingBFlatHornFingeringsFWritten: [Note : [MarchingBFlatHornFingering]] = [
	F3 : [o100],
	FSharp3 : [o010],
	GFlat3 : [o010],
	G3 : [open],
	GSharp3 : [o011],
	AFlat3 : [o011],
	A3 : [o110],
	ASharp3 : [o100],
	BFlat3 : [o100],
	B3 : [o010],

	C4 : [open],
	CSharp4 : [o110],
	DFlat4 : [o110],
	D4 : [o100],
	DSharp4 : [o010],
	EFlat4 : [o010],
	E4 : [open],
	F4 : [o100],
	FSharp4 : [o010],
	GFlat4 : [o010],
	G4 : [open],
	GSharp4 : [o011],
	AFlat4 : [o011],
	A4 : [o011],
	ASharp4 : [o100],
	BFlat4 : [o100],
	B4 : [o010],

	C5 : [open],
	CSharp5 : [o110, o010],
	DFlat5 : [o110, o010],
	D5 : [o110, o010],
	DSharp5 : [o010],
	EFlat5 : [o010],
	E5 : [open],
	F5 : [o100],
	FSharp5 : [o010],
	GFlat5 : [o010],
	G5 : [open],
	GSharp5 : [o011],
	AFlat5 : [o011],
	A5 : [o110],
	ASharp5 : [o100],
	BFlat5 : [o100],
	B5 : [o010],

	C6 : [open]
]
