//
//  NotesCollection.swift
//  FrenchHornApp
//
//  Created by Lorenzo Brown on 8/30/22.
//

import Foundation
import SwiftUI

//let C0 = Note(id: -81, name: "C")
//let CSharp0 = Note(id: -80, name: "C♯")
//let DFlat0 = Note(id: -79, name: "D♭")
//let D0 = Note(id: -78, name: "D")
//let DSharp0 = Note(id: -77, name: "D♯")
//let EFlat0 = Note(id: -76, name: "E♭")
//let E0 = Note(id: -75, name: "E")
//let F0 = Note(id: -74, name: "F")
//let FSharp0 = Note(id: -73, name: "F♯")
//let GFlat0 = Note(id: -72, name: "G♭")
//let G0 = Note(id: -71, name: "G")
//let GSharp0 = Note(id: -70, name: "G♯")
//let AFlat0 = Note(id: -69, name: "A♭")
//let A0 = Note(id: -68, name: "A")
//let ASharp0 = Note(id: -67, name: "A♯")
//let BFlat0 = Note(id: -66, name: "B♭")
//let B0 = Note(id:-65, name: "B")

//
//let C1 = Note(id: -64, name: "C")
//let CSharp1 = Note(id: -63, name: "C♯")
//let DFlat1 = Note(id: -62, name: "D♭")
//let D1 = Note(id: -61, name: "D")
//let DSharp1 = Note(id: -60, name: "D♯")
//let EFlat1 = Note(id: -59, name: "E♭")
//let E1 = Note(id: -58, name: "E")
//let F1 = Note(id: -57, name: "F")
//let FSharp1 = Note(id: -56, name: "F♯")
//let GFlat1 = Note(id: -55, name: "G♭")
//let G1 = Note(id: -54, name: "G")
//let GSharp1 = Note(id: -53, name: "G♯")
//let AFlat1 = Note(id: -52, name: "A♭")
//let A1 = Note(id: -51, name: "A")
//let ASharp1 = Note(id: -50, name: "A♯")
//let BFlat1 = Note(id: -49, name: "B♭")
//let B1 = Note(id: -48, name: "B")
//
//let C2 = Note(id: -47, name: "C")
//let CSharp2 = Note(id: -46, name: "C♯")
//let DFlat2 = Note(id: -45, name: "D♭")
//let D2 = Note(id: -44, name: "D")
//let DSharp2 = Note(id: -43, name: "D♯")
//let EFlat2 = Note(id: -42, name: "E♭")
//let E2 = Note(id: -41, name: "E") /// DUPLICATE
//let F2 = Note(id: -40, name: "F")
//let FSharp2 = Note(id:-39, name: "F♯")
//let GFlat2 = Note(id: -38, name: "G♭")
//let G2 = Note(id: -37, name: "G")
//let GSharp2 = Note(id: -36, name: "G♯")
//let AFlat2 = Note(id: -35, name: "A♭")
//let A2 = Note(id: -34, name: "A")
//let ASharp2 = Note(id: -33, name: "A♯")
//let BFlat2 = Note(id: -32 ,name: "B♭")
//let B2 = Note(id: -31, name: "B")
//
//
//let C3 = Note(id: -30, name: "C")
//let CSharp3 = Note(id: -29, name: "C♯")
//let DFlat3 = Note(id: -28, name: "D♭")
//let D3 = Note(id: -27, name: "D")
//let DSharp3 = Note(id: -26, name: "D♯")
//let EFlat3 = Note(id: -25, name: "E♭")
//let E3 = Note(id: -24, name: "E")
//let F3 = Note(id: -23, name: "F")
//let FSharp3 = Note(id: -22, name: "F♯")
//let GFlat3 = Note(id: -21, name: "G♭")
//let G3 = Note(id: -20, name: "G")
//let GSharp3 = Note(id: -19, name: "G♯")
//let AFlat3 = Note(id: -18, name: "A♭")
//let A3 = Note(id: -17, name: "A" )
//let ASharp3 = Note(id: -16, name: "A♯")
//let BFlat3 = Note(id: -15, name: "B♭")
//let B3 = Note(id: -14, name: "B")
//
//
//let C4 = Note(id: -13, name: "C")
//let CSharp4 = Note(id: -12, name: "C♯")
//let DFlat4 = Note(id: -11, name: "D♭")
//let D4 = Note(id: -10, name : "D")
//let DSharp4 = Note(id: -9, name: "D♯")
//let EFlat4 = Note(id: -8, name: "E♭")
//let E4 = Note(id:-7, name: "E")
//let F4 = Note(id: -6, name: "F")
//let FSharp4 = Note(id: -5, name: "F♯")
//let GFlat4 = Note(id: -4 , name: "G♭")
//let G4 = Note(id: -3, name: "G")
//let GSharp4 = Note(id: -2, name: "G♯")
//let AFlat4 = Note(id: -1, name: "A♭")
//let A4 = Note(id: 0, name: "A")
//let ASharp4 = Note(id: 1, name: "A♯")
//let BFlat4 = Note(id: 2, name: "B♭")
//let B4 = Note(id: 3, name: "B")
//
//
//
//let C5 = Note(id: 4, name: "C")
//let CSharp5 = Note(id: 5, name: "C♯")
//let DFlat5 = Note(id: 6, name: "D♭")
//let D5 = Note(id:7, name: "D")
//let DSharp5 = Note(id: 8, name: "D♯")
//let EFlat5 = Note(id: 9, name: "E♭")
//let E5 = Note(id: 10, name: "E")
//let F5 = Note(id: 11, name: "F")
//let FSharp5 = Note(id: 12, name: "F♯")
//let GFlat5 = Note(id: 13, name: "G♭")
//let G5 = Note(id: 14, name: "G")
//let GSharp5 = Note(id: 15, name: "G♯")
//let AFlat5 = Note(id: 16, name: "A♭")
//let A5 = Note(id: 17, name: "A")
//let ASharp5 = Note(id: 18, name: "A♯")
//let BFlat5 = Note(id: 19, name: "B♭")
//let B5 = Note(id: 20, name: "B")
//
//
//let C6 = Note(id: 21, name: "C")
//let CSharp6 = Note(id: 22, name: "C♯")
//let DFlat6 = Note(id: 23, name: "D♭")
//let D6 = Note(id: 24, name: "D")
//let DSharp6 = Note(id: 25, name: "D♯")
//let EFlat6 = Note(id: 26, name: "E♭")
//let E6 = Note(id: 27, name: "E")
//let F6 = Note(id: 28, name: "F")
//let FSharp6 = Note(id: 29, name: "F♯")
//let GFlat6 = Note(id: 30, name: "G♭")
//let G6 = Note(id: 31, name: "G")
//let GSharp6 = Note(id: 32, name: "G♯")
//let AFlat6 = Note(id: 33, name: "A♭")
//let A6 = Note(id: 34, name: "A")
//let ASharp6 = Note(id: 35, name: "A♯")
//let BFlat6 = Note(id: 36, name: "B♭")
//let B6 = Note(id:37, name: "B")
//
//
//let C7 = Note(id: 38, name: "C")
//let CSharp7 = Note(id: 39, name: "C♯")
//let DFlat7 = Note(id:40, name: "D♭")
//let D7 = Note(id:41, name: "D")
//let DSharp7 = Note(id: 42, name: "D♯")
//let EFlat7 = Note(id: 43, name: "E♭")
//let E7 = Note(id: 44, name: "E")
//let F7 = Note(id: 45, name: "F")
//let FSharp7 = Note(id: 46, name: "F♯")
//let GFlat7 = Note(id: 47, name: "G♭")
//let G7 = Note(id: 48, name: "G")
//let GSharp7 = Note(id: 49, name: "G♯")
//let AFlat7 = Note(id: 50, name: "A♭")
//let A7 = Note(id: 51, name: "A")
//let ASharp7 = Note(id: 52, name: "A♯")
//let BFlat7 = Note(id: 53, name: "B♭")
//let B7 = Note(id: 54, name: "B")
//
//
//let C8 = Note(id: 55, name: "C")
//let CSharp8 = Note(id: 56, name: "C♯")
//let DFlat8 = Note(id: 57, name: "D♭")
//let D8 = Note(id: 58, name: "D")
//let DSharp8 = Note(id: 59, name: "D♯")
//let EFlat8 = Note(id: 60,name: "E♭")
//let E8 = Note(id: 61, name: "E")
//let F8 = Note(id: 62, name: "F")
//let FSharp8 = Note(id: 63, name: "F♯")
//let GFlat8 = Note(id: 64, name: "G♭")
//let G8 = Note(id: 65, name: "G")
//let GSharp8 = Note(id: 66, name: "G♯")
//let AFlat8 = Note(id: 67, name: "A♭")
//let A8 = Note(id: 68, name: "A")
//let ASharp8 = Note(id: 69, name: "A♯")
//let BFlat8 = Note(id: 70, name: "B♭")
//let B8 = Note(id: 71, name: "B")


let C0 = Note(.C, accidental: .natural, octave: -1)
let CSharp0 = Note(.C, accidental: .sharp, octave: -1)
let DFlat0 = Note(.D, accidental: .flat, octave: -1)
let D0 = Note(.D, accidental: .natural, octave: -1)
let DSharp0 = Note(.D, accidental: .sharp, octave: -1)
let EFlat0 = Note(.E, accidental: .flat, octave: -1)
let E0 = Note(.E, accidental: .natural, octave: -1)
let F0 = Note(.F, accidental: .natural, octave: -1)
let FSharp0 = Note(.F, accidental: .sharp, octave: -1)
let GFlat0 = Note(.G, accidental: .flat, octave: -1)
let G0 = Note(.G, accidental: .natural, octave: -1)
let GSharp0 = Note(.G, accidental: .sharp, octave: -1)
let AFlat0 = Note(.A, accidental: .flat, octave: -1)
let A0 = Note(.A, accidental: .natural, octave: -1)
let ASharp0 = Note(.A, accidental: .sharp, octave: -1)
let BFlat0 = Note(.B, accidental: .flat, octave: -1)
let B0 = Note(.B, accidental: .natural, octave: -1)


let C1 = Note(.C, accidental: .natural, octave: 0)
let CSharp1 = Note(.C, accidental: .sharp, octave: 0)
let DFlat1 = Note(.D, accidental: .flat, octave: 0)
let D1 = Note(.D, accidental: .natural, octave: 0)
let DSharp1 = Note(.D, accidental: .sharp, octave: 0)
let EFlat1 = Note(.E, accidental: .flat, octave: 0)
let E1 = Note(.E, accidental: .natural, octave: 0)
let F1 = Note(.F, accidental: .natural, octave: 0)
let FSharp1 = Note(.F, accidental: .sharp, octave: 0)
let GFlat1 = Note(.G, accidental: .flat, octave: 0)
let G1 = Note(.G, accidental: .natural, octave: 0)
let GSharp1 = Note(.G, accidental: .sharp, octave: 0)
let AFlat1 = Note(.A, accidental: .flat, octave: 0)
let A1 = Note(.A, accidental: .natural, octave: 0)
let ASharp1 = Note(.A, accidental: .sharp, octave: 0)
let BFlat1 = Note(.B, accidental: .flat, octave: 0)
let B1 = Note(.B, accidental: .natural, octave: 0)


let C2 = Note(.C, accidental: .natural, octave: 1)
let CSharp2 = Note(.C, accidental: .sharp, octave: 1)
let DFlat2 = Note(.D, accidental: .flat, octave: 1)
let D2 = Note(.D, accidental: .natural, octave: 1)
let DSharp2 = Note(.D, accidental: .sharp, octave: 1)
let EFlat2 = Note(.E, accidental: .flat, octave: 1)
let E2 = Note(.E, accidental: .natural, octave: 1)
let F2 = Note(.F, accidental: .natural, octave: 1)
let FSharp2 = Note(.F, accidental: .sharp, octave: 1)
let GFlat2 = Note(.G, accidental: .flat, octave: 1)
let G2 = Note(.G, accidental: .natural, octave: 1)
let GSharp2 = Note(.G, accidental: .sharp, octave: 1)
let AFlat2 = Note(.A, accidental: .flat, octave: 1)
let A2 = Note(.A, accidental: .natural, octave: 1)
let ASharp2 = Note(.A, accidental: .sharp, octave: 1)
let BFlat2 = Note(.B, accidental: .flat, octave: 1)
let B2 = Note(.B, accidental: .natural, octave: 1)


let C3 = Note(.C, accidental: .natural, octave: 2)
let CSharp3 = Note(.C, accidental: .sharp, octave: 2)
let DFlat3 = Note(.D, accidental: .flat, octave: 2)
let D3 = Note(.D, accidental: .natural, octave: 2)
let DSharp3 = Note(.D, accidental: .sharp, octave: 2)
let EFlat3 = Note(.E, accidental: .flat, octave: 2)
let E3 = Note(.E, accidental: .natural, octave: 2)
let F3 = Note(.F, accidental: .natural, octave: 2)
let FSharp3 = Note(.F, accidental: .sharp, octave: 2)
let GFlat3 = Note(.G, accidental: .flat, octave: 2)
let G3 = Note(.G, accidental: .natural, octave: 2)
let GSharp3 = Note(.G, accidental: .sharp, octave: 2)
let AFlat3 = Note(.A, accidental: .flat, octave: 2)
let A3 = Note(.A, accidental: .natural, octave: 2)
let ASharp3 = Note(.A, accidental: .sharp, octave: 2)
let BFlat3 = Note(.B, accidental: .flat, octave: 2)
let B3 = Note(.B, accidental: .natural, octave: 2)


let C4 = Note(.C, accidental: .natural, octave: 3)
let CSharp4 = Note(.C, accidental: .sharp, octave: 3)
let DFlat4 = Note(.D, accidental: .flat, octave: 3)
let D4 = Note(.D, accidental: .natural, octave: 3)
let DSharp4 = Note(.D, accidental: .sharp, octave: 3)
let EFlat4 = Note(.E, accidental: .flat, octave: 3)
let E4 = Note(.E, accidental: .natural, octave: 3)
let F4 = Note(.F, accidental: .natural, octave: 3)
let FSharp4 = Note(.F, accidental: .sharp, octave: 3)
let GFlat4 = Note(.G, accidental: .flat, octave: 3)
let G4 = Note(.G, accidental: .natural, octave: 3)
let GSharp4 = Note(.G, accidental: .sharp, octave: 3)
let AFlat4 = Note(.A, accidental: .flat, octave: 3)
let A4 = Note(.A, accidental: .natural, octave: 3)
let ASharp4 = Note(.A, accidental: .sharp, octave: 3)
let BFlat4 = Note(.B, accidental: .flat, octave: 3)
let B4 = Note(.B, accidental: .natural, octave: 3)


let C5 = Note(.C, accidental: .natural, octave: 4)
let CSharp5 = Note(.C, accidental: .sharp, octave: 4)
let DFlat5 = Note(.D, accidental: .flat, octave: 4)
let D5 = Note(.D, accidental: .natural, octave: 4)
let DSharp5 = Note(.D, accidental: .sharp, octave: 4)
let EFlat5 = Note(.E, accidental: .flat, octave: 4)
let E5 = Note(.E, accidental: .natural, octave: 4)
let F5 = Note(.F, accidental: .natural, octave: 4)
let FSharp5 = Note(.F, accidental: .sharp, octave: 4)
let GFlat5 = Note(.G, accidental: .flat, octave: 4)
let G5 = Note(.G, accidental: .natural, octave: 4)
let GSharp5 = Note(.G, accidental: .sharp, octave: 4)
let AFlat5 = Note(.A, accidental: .flat, octave: 4)
let A5 = Note(.A, accidental: .natural, octave: 4)
let ASharp5 = Note(.A, accidental: .sharp, octave: 4)
let BFlat5 = Note(.B, accidental: .flat, octave: 4)
let B5 = Note(.B, accidental: .natural, octave: 4)


let C6 = Note(.C, accidental: .natural, octave: 5)
let CSharp6 = Note(.C, accidental: .sharp, octave: 5)
let DFlat6 = Note(.D, accidental: .flat, octave: 5)
let D6 = Note(.D, accidental: .natural, octave: 5)
let DSharp6 = Note(.D, accidental: .sharp, octave: 5)
let EFlat6 = Note(.E, accidental: .flat, octave: 5)
let E6 = Note(.E, accidental: .natural, octave: 5)
let F6 = Note(.F, accidental: .natural, octave: 5)
let FSharp6 = Note(.F, accidental: .sharp, octave: 5)
let GFlat6 = Note(.G, accidental: .flat, octave: 5)
let G6 = Note(.G, accidental: .natural, octave: 5)
let GSharp6 = Note(.G, accidental: .sharp, octave: 5)
let AFlat6 = Note(.A, accidental: .flat, octave: 5)
let A6 = Note(.A, accidental: .natural, octave: 5)
let ASharp6 = Note(.A, accidental: .sharp, octave: 5)
let BFlat6 = Note(.B, accidental: .flat, octave: 5)
let B6 = Note(.B, accidental: .natural, octave: 5)


let C7 = Note(.C, accidental: .natural, octave: 6)
let CSharp7 = Note(.C, accidental: .sharp, octave: 6)
let DFlat7 = Note(.D, accidental: .flat, octave: 6)
let D7 = Note(.D, accidental: .natural, octave: 6)
let DSharp7 = Note(.D, accidental: .sharp, octave: 6)
let EFlat7 = Note(.E, accidental: .flat, octave: 6)
let E7 = Note(.E, accidental: .natural, octave: 6)
let F7 = Note(.F, accidental: .natural, octave: 6)
let FSharp7 = Note(.F, accidental: .sharp, octave: 6)
let GFlat7 = Note(.G, accidental: .flat, octave: 6)
let G7 = Note(.G, accidental: .natural, octave: 6)
let GSharp7 = Note(.G, accidental: .sharp, octave: 6)
let AFlat7 = Note(.A, accidental: .flat, octave: 6)
let A7 = Note(.A, accidental: .natural, octave: 6)
let ASharp7 = Note(.A, accidental: .sharp, octave: 6)
let BFlat7 = Note(.B, accidental: .flat, octave: 6)
let B7 = Note(.B, accidental: .natural, octave: 6)


let C8 = Note(.C, accidental: .natural, octave: 7)
let CSharp8 = Note(.C, accidental: .sharp, octave: 7)
let DFlat8 = Note(.D, accidental: .flat, octave: 7)
let D8 = Note(.D, accidental: .natural, octave: 7)
let DSharp8 = Note(.D, accidental: .sharp, octave: 7)
let EFlat8 = Note(.E, accidental: .flat, octave: 7)
let E8 = Note(.E, accidental: .natural, octave: 7)
let F8 = Note(.F, accidental: .natural, octave: 7)
let FSharp8 = Note(.F, accidental: .sharp, octave: 7)
let GFlat8 = Note(.G, accidental: .flat, octave: 7)
let G8 = Note(.G, accidental: .natural, octave: 7)
let GSharp8 = Note(.G, accidental: .sharp, octave: 7)
let AFlat8 = Note(.A, accidental: .flat, octave: 7)
let A8 = Note(.A, accidental: .natural, octave: 7)
let ASharp8 = Note(.A, accidental: .sharp, octave: 7)
let BFlat8 = Note(.B, accidental: .flat, octave: 7)
let B8 = Note(.B, accidental: .natural, octave: 7)

