//
//  CharacterDetailView.swift
//  HpTest
//
//  Created by Gabriel Ribeiro on 14/05/26.
//

import SwiftUI

struct CharacterDetailView: View {

    let favoritesManager: FavoritesManager
    let character: Character

    @State private var isFavorite: Bool = false

    var body: some View {
        ScrollView {
            VStack {
                Text(character.name)
            }
        }
        .navigationTitle(character.name)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Favorite", systemImage: isFavorite ? "heart.fill" : "heart") {
                    toggleFavorite()
                }
                .buttonStyle(.plain)
                .labelStyle(.iconOnly)
                .foregroundStyle(.pink)
            }
        }
        .onAppear {
            isFavorite = favoritesManager.isFavorite(characterId: character.id)
        }
    }

    private func toggleFavorite() {
        isFavorite = favoritesManager.toggleFavorite(characterId: character.id)
    }
}

#Preview {
    CharacterDetailView(favoritesManager: FavoritesManager(), character: .init(name: "Harry Mocker"))
}
