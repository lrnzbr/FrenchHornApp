//
//  AboutView.swift
//  FrenchHornApp
//
//  Created by Lorenzo Brown on 7/3/23.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(alignment: .center){
            Text("Thank you for downloading \(AppEdition.current.almanacTitle)!")
            Text("If you have comments, suggestions, or concerns please feel free to reach out:")
            Spacer()
            Text("lorenzo@vydr.io")
            Spacer()
            Spacer()
        }.font(AppFont.body)
            .multilineTextAlignment(.center)
            .padding()
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
