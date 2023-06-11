//
//  NoteFingeringMapping.swift
//  FrenchHornApp
//
//  Created by Lorenzo Brown on 8/30/22.
//

import Foundation

let doubleHornFingerings: [Note : [DoubleHornFingering]] = [
	C2:[open],
	CSharp2: [t011],
	DFlat2: [t011],
	D2: [t110],
	DSharp2 : [t100],
	EFlat2 : [t100],
	E2 : [t010],
	F2 : [t000],
	FSharp2 : [o111],
	GFlat2 : [o111],
	G2 : [o101],
	GSharp2 : [o011],
	AFlat2 : [o011],
	A2 : [o110],
	ASharp2 : [o100],
	BFlat2 : [o100],
	B2 : [o010],

	C3 : [open],
	CSharp3  : [t011, o111],
	DFlat3 : [t011, o111],
	D3 : [t110, o101],
	DSharp3 : [t100, o011],
	EFlat3 : [t100, o011],
	E3 : [t010, o110],
	F3 : [t000, o100],
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
	D4 : [o110],
	DSharp4 : [o010],
	EFlat4 : [o010],
	E4 : [open],
	F4 : [o100],
	FSharp4 : [o010],
	GFlat4 : [o010],
	G4 : [open],
	GSharp4 : [t011, o011],
	AFlat4 : [t011, o011],
	A4 : [t110, o011],
	ASharp4 : [t100, o100],
	BFlat4 : [t100, o100],
	B4 : [t010, o010],

	C5 : [t000, open],
	CSharp5 : [t011, o110, o010],
	DFlat5 : [t011, o110, o010],
	D5 : [t110, o110, o010],
	DSharp5 : [t100, o010],
	EFlat5 : [t100, o010],
	E5 : [t010, open],
	F5 : [t000, o100],
	FSharp5 : [t010, t110, o010],
	GFlat5 : [t010, t110, o010],
	G5 : [t000, t100, open],
	GSharp5 : [t011, t010, o011],
	AFlat5 : [t011, t010, o011],
	A5 : [t110, t000, o110],
	ASharp5 : [t100, o100],
	BFlat5 : [t100, o100],
	B5 : [t010, o010],

	C6 : [t000, open]
]
