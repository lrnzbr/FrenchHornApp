//
//  TripleHornFingerings.swift
//  FrenchHornApp
//
//  Created by Lorenzo Brown on 7/4/23.
//

import Foundation
//struct TripleHornFingering : Identifiable {
//	var id: Int
//	let trigger1: Bool
//	let trigger2: Bool
//	let valve1: Bool
//	let valve2: Bool
//	let valve3: Bool
//}

private let open = Fingering( id: 0, trigger1: false, trigger2: false , valve1: false, valve2: false, valve3: false)
private let o010 = Fingering(id: 1, trigger1: false, trigger2: false , valve1: false, valve2: true, valve3: false)
private let o011 = Fingering(id: 2, trigger1: false, trigger2: false , valve1: false, valve2: true, valve3: true)
private let o100 = Fingering(id: 3, trigger1: false, trigger2: false , valve1: true, valve2: false, valve3: false)
private let o101 = Fingering(id: 4, trigger1: false, trigger2: false , valve1: true, valve2: false, valve3: true)
private let o110 = Fingering(id: 5, trigger1: false, trigger2: false , valve1: true, valve2: true, valve3: false)
private let o111 = Fingering(id: 6, trigger1: false, trigger2: false , valve1: true, valve2: true, valve3: true)

private let t000 = Fingering(id: 7, trigger1: true, trigger2: false , valve1: false, valve2: false, valve3: false)
private let t010 = Fingering(id: 8, trigger1: true, trigger2: false , valve1: false, valve2: true, valve3: false)
private let t011 = Fingering(id: 9, trigger1: true, trigger2: false , valve1: false, valve2: true, valve3: true)
private let t100 = Fingering(id: 10, trigger1: true, trigger2: false , valve1: true, valve2: false, valve3: false)
private let t110 = Fingering(id: 11, trigger1: true, trigger2: false , valve1: true, valve2: true, valve3: false)
private let t101 = Fingering(id: 12, trigger1: true, trigger2: false , valve1: true, valve2: false, valve3: true)
private let t111 = Fingering(id: 13, trigger1: true, trigger2: false , valve1: true, valve2: true, valve3: true)

private let f000 = Fingering(id: 14, trigger1: false, trigger2: true , valve1: false, valve2: false, valve3: false)
private let f010 = Fingering(id: 15, trigger1: false, trigger2: true , valve1: false, valve2: true, valve3: false)
private let f100 = Fingering(id: 16, trigger1: false, trigger2: true , valve1: true, valve2: false, valve3: false)
private let f110 = Fingering(id: 17, trigger1: false, trigger2: true , valve1: true, valve2: true, valve3: false)
private let f011 = Fingering(id: 18, trigger1: false, trigger2: true , valve1: false, valve2: true, valve3: true)
private let f111 = Fingering(id: 19, trigger1: false, trigger2: true , valve1: true, valve2: true, valve3: true)
private let f101 = Fingering(id: 20, trigger1: false, trigger2: true , valve1: true, valve2: false, valve3: true)

let tripleHornFingerings: [Note : [Fingering]] = [
	C2:[open],
   CSharp2: [t011],
	DFlat2: [t011],
		D2: [t110],
  DSharp2 : [t100],
   EFlat2 : [t100],
	   E2 : [t010],
	   F2 : [t000],
  FSharp2 : [o111, f111],
   GFlat2 : [o111, f111],
	   G2 : [o101, f101],
  GSharp2 : [o011, f011],
   AFlat2 : [o011, f011],
	   A2 : [o110, f110],
  ASharp2 : [o100, f100],
   BFlat2 : [o100, f100],
	   B2 : [o010, f010],

	   C3 : [open, t101 , f000],
 CSharp3  : [t011, o111],
   DFlat3 : [t011, o111],
	   D3 : [t110, o101],
  DSharp3 : [t100, o011],
   EFlat3 : [t100, o011],
	   E3 : [t010, o110],
	   F3 : [t000, o100],
  FSharp3 : [o010, t111, f111],
   GFlat3 : [o010, t111, f111],
	   G3 : [open, o101, t101, f101],
  GSharp3 : [o011, t011, f011],
   AFlat3 : [o011, t011, f011],
	   A3 : [o110, t110, f100],
  ASharp3 : [o100, t100, f100],
   BFlat3 : [o100, t100, f100],
	   B3 : [o010, t010, f010],

	   C4 : [open, t000, f000],
  CSharp4 : [o110, t011, f111],
   DFlat4 : [o110, t011, f111],
	   D4 : [o100, t110, f101],
  DSharp4 : [o010, o011, t010, f011],
   EFlat4 : [o010, o011, t010, f011],
	   E4 : [open, o110, t010, f110],
	   F4 : [o100, t000, t011, f100],
  FSharp4 : [o010, o111, t110, f010],
   GFlat4 : [o010, o111, t110, f010],
	   G4 : [open, o101, t100, f000],
  GSharp4 : [t011, t010, o011, o111, f011],
   AFlat4 : [t011, t010, o011, o111, f011],
	   A4 : [t110, o110, o101, t000, f110],
  ASharp4 : [t100, o100, f100],
   BFlat4 : [t100, o100, f100],
	   B4 : [t010, o010, f010],

	   C5 : [t000, open, f000],
  CSharp5 : [t011, o110, o010, f110, f111],
   DFlat5 : [t011, o110, o010, f110, f111],
	   D5 : [t110, o110, o010, f100, f111],
  DSharp5 : [t100, o010, t011, f010, f101],
   EFlat5 : [t100, o010, t011, f010, f101],
	   E5 : [f110, f000, t010, open],
	   F5 : [f100, t000, o100, t100],
  FSharp5 : [f010, f111, t010, t110, o010],
   GFlat5 : [f010, f111, t010, t110, o010],
	   G5 : [f000, f101, t000, t100, open],
  GSharp5 : [f011, t011, t010, o011],
   AFlat5 : [f011, t011, t010, o011],
	   A5 : [f110, t110, t000, o110],
  ASharp5 : [f100, t100, o100],
   BFlat5 : [f100, t100, o100],
	   B5 : [f010, t010, o010],

	   C6 : [f000, t000, open]]
