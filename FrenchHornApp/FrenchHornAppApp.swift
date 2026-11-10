//
//  FrenchHornAppApp.swift
//  FrenchHornApp
//
//  Created by Lorenzo Brown on 8/29/22.
//

import AudioKit
import AudioKitUI
import AVFoundation
import SwiftUI

@main
struct FrenchHornAppApp: App {
    init() {
        Settings.bufferLength = .short
        AdagioTheme.configureNavigationAppearance()
    }

	var body: some Scene {
		WindowGroup {
			ContentView()
		}
	}}
