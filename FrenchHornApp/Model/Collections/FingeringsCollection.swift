//
//  FingeringsCollection.swift
//  FrenchHornApp
//
//  Created by Lorenzo Brown on 8/30/22.
//

import Foundation



let open = DoubleHornFingering( id: 0, trigger: false, valve1: false, valve2: false, valve3: false)
let o010 = DoubleHornFingering(id: 1, trigger: false, valve1: false, valve2: true, valve3: false)
let o011 = DoubleHornFingering(id: 2, trigger: false, valve1: false, valve2: true, valve3: true)
let o100 = DoubleHornFingering(id: 3, trigger: false, valve1: true, valve2: false, valve3: false)
let o101 = DoubleHornFingering(id: 4, trigger: false, valve1: true, valve2: false, valve3: true)
let o110 = DoubleHornFingering(id: 5, trigger: false, valve1: true, valve2: true, valve3: false)
let o111 = DoubleHornFingering(id: 6, trigger: false, valve1: true, valve2: true, valve3: true)

let t000 = DoubleHornFingering(id: 7, trigger: true, valve1: false, valve2: false, valve3: false)
let t010 = DoubleHornFingering(id: 8, trigger: true, valve1: false, valve2: true, valve3: false)
let t011 = DoubleHornFingering(id: 9, trigger: true, valve1: false, valve2: true, valve3: true)
let t100 = DoubleHornFingering(id: 10, trigger: true, valve1: true, valve2: false, valve3: false)
let t110 = DoubleHornFingering(id: 11, trigger: true, valve1: true, valve2: true, valve3: false)

