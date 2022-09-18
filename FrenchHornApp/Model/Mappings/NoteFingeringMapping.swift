//
//  NoteFingeringMapping.swift
//  FrenchHornApp
//
//  Created by Lorenzo Brown on 8/30/22.
//

import Foundation

let doubleHornFingerings: [Int : [DoubleHornFingering]] = [
	C2.id:[open],
	CSharp2.id: [t011],
	DFlat2.id: [t011],
	D2.id: [t110],
	DSharp2.id: [t100],
	EFlat2.id: [t100],
	E2.id: [t010],
	F2.id: [t000],
	FSharp2.id: [o111],
	GFlat2.id: [o111],
	G2.id: [o101],
	GSharp2.id: [o011],
	AFlat2.id: [o011],
	A2.id: [o110],
	ASharp2.id: [o100],
	BFlat2.id: [o100],
	B2.id: [o010],

	C3.id: [open],
	CSharp3.id : [t011, o111],
	DFlat3.id: [t011, o111],
	D3.id: [t110, o101],
	DSharp3.id: [t100, o011],
	EFlat3.id: [t100, o011],
	E3.id: [t010, o110],
	F3.id: [t000, o100],
	FSharp3.id: [o010],
	GFlat3.id: [o010],
	G3.id: [open],
	GSharp3.id: [o011],
	AFlat3.id: [o011],
	A3.id: [o110],
	ASharp3.id: [o100],
	BFlat3.id: [o100],
	B3.id: [o010],

	C4.id: [open],
	CSharp4.id: [o110],
	DFlat4.id: [o110],
	D4.id: [o110],
	DSharp4.id: [o010],
	EFlat4.id: [o010],
	E4.id: [open],
	F4.id: [o100],
	FSharp4.id: [o010],
	GFlat4.id: [o010],
	G4.id: [open],
	GSharp4.id: [t011, o011],
	AFlat4.id: [t011, o011],
	A4.id: [t110, o011],
	ASharp4.id: [t100, o100],
	BFlat4.id: [t100, o100],
	B4.id: [t010, o010],

	C5.id: [t000, open],
	CSharp5.id: [t011, o110, o010],
	DFlat5.id: [t011, o110, o010],
	D5.id: [t110, o110, o010],
	DSharp5.id: [t100, o010],
	EFlat5.id: [t100, o010],
	E5.id: [t010, open],
	F5.id: [t000, o100],
	FSharp5.id: [t010, t110, o010],
	GFlat5.id: [t010, t110, o010],
	G5.id: [t000, t100, open],
	GSharp5.id: [t011, t010, o011],
	AFlat5.id: [t011, t010, o011],
	A5.id: [t110, t000, o110],
	ASharp5.id: [t100, o100],
	BFlat5.id: [t100, o100],
	B5.id: [t010, o010],

	C6.id: [t000, open]
]
