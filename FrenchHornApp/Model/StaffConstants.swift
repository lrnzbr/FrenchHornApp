//
//  StaffConstants.swift
//  FrenchHornApp
//
//  Created by Lorenzo Brown on 8/30/22.
//

import Foundation
import SwiftUI

struct LedgerLine: Codable, Identifiable {
	var id = UUID()
	let offset: CGFloat
}

let staffHeight:CGFloat = 12

let ledger1down = LedgerLine(offset: staffHeight * 3)
let ledger2down = LedgerLine(offset: staffHeight * 4)
let ledger3down = LedgerLine(offset: staffHeight * 5)
let ledger4down = LedgerLine(offset: staffHeight * 6)
let ledger5down = LedgerLine(offset: staffHeight * 7)
let ledger6down = LedgerLine(offset: staffHeight * 8)
let ledger7down = LedgerLine(offset: staffHeight * 9)
let ledger8down = LedgerLine(offset: staffHeight * 10)
let ledger9down = LedgerLine(offset: staffHeight * 11)
let ledger10down = LedgerLine(offset: staffHeight * 12)
let ledger11down = LedgerLine(offset: staffHeight * 13)
let ledger12down = LedgerLine(offset: staffHeight * 14)
let ledger13down = LedgerLine(offset: staffHeight * 15)
let ledger14down = LedgerLine(offset: staffHeight * 16)

let ledger1up = LedgerLine(offset: staffHeight * -3)
let ledger2up = LedgerLine(offset: staffHeight * -4)
let ledger3up = LedgerLine(offset: staffHeight * -5)
let ledger4up = LedgerLine(offset: staffHeight * -6)
let ledger5up = LedgerLine(offset: staffHeight * -7)
let ledger6up = LedgerLine(offset: staffHeight * -8)
let ledger7up = LedgerLine(offset: staffHeight * -9)
let ledger8up = LedgerLine(offset: staffHeight * -10)
let ledger9up = LedgerLine(offset: staffHeight * -11)
let ledger10up = LedgerLine(offset: staffHeight * -12)
let ledger11up = LedgerLine(offset: staffHeight * -13)
let ledger12up = LedgerLine(offset: staffHeight * -14)



let upledgers = [ledger1up, ledger2up, ledger3up, ledger4up, ledger5up, ledger6up, ledger7up, ledger8up, ledger9up, ledger10up, ledger11up, ledger12up]
let downledgers = [ledger1down, ledger2down, ledger3down, ledger4down, ledger5down, ledger6down, ledger7down, ledger8down, ledger9down, ledger10down, ledger11down, ledger12down, ledger13down, ledger14down]
