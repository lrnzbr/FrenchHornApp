//
//  PlayPauseButton.swift
//  FrenchHornApp
//
//  Created by Lorenzo Brown on 8/9/23.
//

import SwiftUI

struct PlayPauseButton: View {
    @Binding var isPlaying:Bool
    var body: some View {
        VStack {
            if isPlaying {
                HStack {
                    Text("Pause")
                    Image(systemName: "pause.fill")
                    Image(systemName: "speaker.slash.fill")

                }
            } else {
                HStack {
                    Text("Play")
                    Image(systemName: "play.fill")
                    Image(systemName: "speaker.fill")
                }
            }
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 40)
                .stroke(Color.green, lineWidth: 1)
        )
        
    }
    
}

struct PlayPauseButton_Previews: PreviewProvider {
    static var previews: some View {
        PlayPauseButton(isPlaying: .constant(false))
    }
}
