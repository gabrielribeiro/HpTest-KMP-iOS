//
//  ContentView.swift
//  HpTest
//
//  Created by Gabriel Ribeiro on 13/05/26.
//

import SwiftUI

struct ContentView: View {
    
    @State private var selectedCharacter: Character?
    @Environment(\.favoritesManager) private var favoritesManager
    @Environment(\.houseManager) private var houseManager

    var body: some View {
        NavigationSplitView {
            CharactersListView(
                favoritesManager: favoritesManager,
                houseManager: houseManager,
                selectedCharacter: $selectedCharacter
            )
        } detail: {
            NavigationStack {
                if let selectedCharacter {
                    CharacterDetailView(favoritesManager: favoritesManager, character: selectedCharacter)
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
}

#Preview {
    ContentView()
}
