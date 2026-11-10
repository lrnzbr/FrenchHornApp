//
//  ContentView.swift
//  FrenchHornApp
//
//  Created by Lorenzo Brown on 8/29/22.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("adagio.appearance") private var appearanceID = AdagioAppearance.system.rawValue

    var body: some View {
        ChooseYourHorn()
            .tint(AdagioTheme.Colors.accent)
            .foregroundColor(AdagioTheme.Colors.ink)
            .preferredColorScheme((AdagioAppearance(rawValue: appearanceID) ?? .system).colorScheme)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
