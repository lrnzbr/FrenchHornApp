//
//  Instrument.swift
//  FrenchHornApp
//
//  Created by Lorenzo Brown on 7/3/23.
//

import Foundation

enum InstrumentKey {
	case F
	case Bflat
}

struct Instrument: Hashable {
	var id: Int
	var name: String
	var key: InstrumentKey
	var imageName: String
    var availableNotes: [[Note]]
    var fingerings:[Note: [Fingering]]
    var hasPistons: Bool
    var hasTrigger1: Bool
    var hasTrigger2: Bool
    var instrumentGuideImage: String
    var handImage:String
}
struct Fingering: Hashable {
    var id: Int
    var trigger1:Bool = false
    var trigger2:Bool = false
    let valve1: Bool
    let valve2: Bool
    let valve3: Bool
}

// Available Note Range for each Instrument
private let availableNotesSingleHornInF =  [[F3], [FSharp3, GFlat3], [G3], [GSharp3, AFlat3], [A3], [ASharp3, BFlat3], [B3],
		[C4], [CSharp4, DFlat4], [D4], [DSharp4, EFlat4], [E4], [F4], [FSharp4, GFlat4], [G4], [GSharp4, AFlat4], [A4], [ASharp4, BFlat4], [B4],
		[C5], [CSharp5, DFlat5], [D5], [DSharp5, EFlat5], [E5], [F5], [FSharp5, GFlat5], [G5], [GSharp5, AFlat5], [A5], [ASharp5, BFlat5], [B5],
		[C6]]
private let availableNotesDoubleHorn =   [[C2], [CSharp2, DFlat2], [D2], [DSharp2, EFlat2], [E2], [F2], [FSharp2, GFlat2], [G2], [GSharp2, AFlat2], [A2], [ASharp2, BFlat2], [B2],
							 [C3], [CSharp3, DFlat3], [D3], [DSharp3, EFlat3], [E3], [F3], [FSharp3, GFlat3], [G3], [GSharp3, AFlat3], [A3], [ASharp3, BFlat3], [B3],
							 [C4], [CSharp4, DFlat4], [D4], [DSharp4, EFlat4], [E4], [F4], [FSharp4, GFlat4], [G4], [GSharp4, AFlat4], [A4], [ASharp4, BFlat4], [B4],
							 [C5], [CSharp5, DFlat5], [D5], [DSharp5, EFlat5], [E5], [F5], [FSharp5, GFlat5], [G5], [GSharp5, AFlat5], [A5], [ASharp5, BFlat5], [B5],
							 [C6]]

private let availableNotesTripleHorn =  [[C2], [CSharp2, DFlat2], [D2], [DSharp2, EFlat2], [E2], [F2], [FSharp2, GFlat2], [G2], [GSharp2, AFlat2], [A2], [ASharp2, BFlat2], [B2],
		[C3], [CSharp3, DFlat3], [D3], [DSharp3, EFlat3], [E3], [F3], [FSharp3, GFlat3], [G3], [GSharp3, AFlat3], [A3], [ASharp3, BFlat3], [B3],
		[C4], [CSharp4, DFlat4], [D4], [DSharp4, EFlat4], [E4], [F4], [FSharp4, GFlat4], [G4], [GSharp4, AFlat4], [A4], [ASharp4, BFlat4], [B4],
		[C5], [CSharp5, DFlat5], [D5], [DSharp5, EFlat5], [E5], [F5], [FSharp5, GFlat5], [G5], [GSharp5, AFlat5], [A5], [ASharp5, BFlat5], [B5],
		[C6]]
private let availableNotesMellophone =  [[F3], [FSharp3, GFlat3], [G3], [GSharp3, AFlat3], [A3], [ASharp3, BFlat3], [B3],
		[C4], [CSharp4, DFlat4], [D4], [DSharp4, EFlat4], [E4], [F4], [FSharp4, GFlat4], [G4], [GSharp4, AFlat4], [A4], [ASharp4, BFlat4], [B4],
		[C5], [CSharp5, DFlat5], [D5], [DSharp5, EFlat5], [E5], [F5], [FSharp5, GFlat5], [G5], [GSharp5, AFlat5], [A5], [ASharp5, BFlat5], [B5],
		[C6]]
private let availableNotesBFlatHorn =  [[F3], [FSharp3, GFlat3], [G3], [GSharp3, AFlat3], [A3], [ASharp3, BFlat3], [B3],
		[C4], [CSharp4, DFlat4], [D4], [DSharp4, EFlat4], [E4], [F4], [FSharp4, GFlat4], [G4], [GSharp4, AFlat4], [A4], [ASharp4, BFlat4], [B4],
		[C5], [CSharp5, DFlat5], [D5], [DSharp5, EFlat5], [E5], [F5], [FSharp5, GFlat5], [G5], [GSharp5, AFlat5], [A5], [ASharp5, BFlat5], [B5],
		[C6]]
private let availableNotesMarchingHorn =  [[G3], [GSharp3, AFlat3], [A3], [ASharp3, BFlat3], [B3],
		[C4], [CSharp4, DFlat4], [D4], [DSharp4, EFlat4], [E4], [F4], [FSharp4, GFlat4], [G4], [GSharp4, AFlat4], [A4], [ASharp4, BFlat4], [B4],
		[C5], [CSharp5, DFlat5], [D5], [DSharp5, EFlat5], [E5], [F5], [FSharp5, GFlat5], [G5], [GSharp5, AFlat5], [A5], [ASharp5, BFlat5], [B5],
		[C6]]

private let instrument1 = Instrument(id: 1, name: "Single Horn in F", key: .F, imageName: "SingleFHorn", availableNotes: availableNotesSingleHornInF, fingerings: singleHornInFFingerings, hasPistons: false, hasTrigger1: false, hasTrigger2: false, instrumentGuideImage: "SingleFHornGuide", handImage: "left_hand")
private let instrument2 = Instrument(id: 2, name: "Double Horn in F/B♭", key: .F, imageName: "DoubleFHorn", availableNotes: availableNotesDoubleHorn, fingerings: doubleHornFingerings, hasPistons: false, hasTrigger1: true, hasTrigger2: false, instrumentGuideImage: "DoubleHornGuide", handImage: "left_hand_trigger")
private let instrument3 = Instrument(id: 3, name: "Triple Horn in F/B♭/F", key: .F , imageName: "TripleHorn", availableNotes: availableNotesTripleHorn,fingerings: tripleHornFingerings, hasPistons: false, hasTrigger1: true, hasTrigger2: true, instrumentGuideImage: "TripleHornGuide", handImage: "left_hand_trigger")
private let instrument4 = Instrument(id: 4, name: "Single Horn in B♭ (Music Written in F)", key: .F, imageName: "SingleHornBFlat", availableNotes: availableNotesBFlatHorn, fingerings: SingleBFlatHornFingeringsFWritten, hasPistons: false, hasTrigger1: true, hasTrigger2: false, instrumentGuideImage: "BFlatHornGuide", handImage: "left_hand_trigger")
private let instrument5 = Instrument(id: 5, name: "Single Horn in B♭ (Music Written in B♭)", key: .Bflat, imageName: "SingleHornBFlat", availableNotes: availableNotesBFlatHorn, fingerings: SingleBFlatHornFingeringsBFlatWritten, hasPistons: false, hasTrigger1: true, hasTrigger2: false, instrumentGuideImage: "BFlatHornGuide", handImage: "left_hand_trigger")
private let instrument6 = Instrument(id: 6, name: "Marching Mellophone in F", key: .F, imageName: "MarchingMellophoneInF", availableNotes: availableNotesMellophone, fingerings: mellophoneInFFingerings, hasPistons: true, hasTrigger1: false, hasTrigger2: false, instrumentGuideImage: "MellophoneGuide", handImage: "right_hand")
private let instrument7 = Instrument(id: 7, name: "Marching Horn in B♭ (Music Written in B♭)", key: .Bflat, imageName: "MarchingHornBb", availableNotes: availableNotesMarchingHorn, fingerings: SingleBFlatHornFingeringsFWritten ,hasPistons: true, hasTrigger1: false, hasTrigger2: false, instrumentGuideImage: "MellophoneGuide", handImage: "right_hand")
private let instrument8 = Instrument(id: 8, name: "Marching Horn in B♭ (Music Written in F)", key: .F, imageName: "MarchingHornBb", availableNotes: availableNotesMarchingHorn, fingerings: SingleBFlatHornFingeringsBFlatWritten, hasPistons: true, hasTrigger1: false, hasTrigger2: false, instrumentGuideImage: "MellophoneGuide", handImage: "right_hand")


let instruments = [instrument1, instrument2, instrument3, instrument4, instrument5, instrument6, instrument7, instrument8]
