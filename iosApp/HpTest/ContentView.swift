//
//  ContentView.swift
//  HpTest
//
//  Created by Gabriel Ribeiro on 13/05/26.
//

import SwiftUI

struct ContentView: View {
    
    @State private var selectedCharacter: Character?

    var body: some View {
        NavigationSplitView {
            CharactersListView(selectedCharacter: $selectedCharacter)
        } detail: {
            if let selectedCharacter {
                Text(selectedCharacter.name)
            } else {
                // Empty state when no character is selected
                ContentUnavailableView(
                    "Select a Character",
                    systemImage: "person.crop.circle",
                    description: Text("Choose a character from the list to see their details")
                )
            }
        }
    }
}

#Preview {
    ContentView()
}
