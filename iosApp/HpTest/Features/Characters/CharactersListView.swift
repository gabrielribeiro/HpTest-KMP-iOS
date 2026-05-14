//
//  CharactersListView.swift
//  HpTest
//
//  Created by Gabriel Ribeiro on 13/05/26.
//

import SwiftUI

struct CharactersListView: View {

    @Binding var selectedCharacter: Character?
    @State private var viewModel = CharactersViewModel()

    var body: some View {
        List(viewModel.allCharacters, selection: $selectedCharacter) { character in
            Text(character.name)
            .contentShape(Rectangle())
            .onTapGesture {
                selectedCharacter = character
            }
        }
        .listStyle(.plain)
        .task {
            // Fetch characters when view appears
            if viewModel.allCharacters.isEmpty {
                await viewModel.fetchCharacters()
            }
        }
    }
}
