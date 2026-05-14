//
//  CharactersListView.swift
//  HpTest
//
//  Created by Gabriel Ribeiro on 13/05/26.
//

import SwiftUI
import shared

struct CharactersListView: View {

    @Binding var selectedCharacter: Character?
    @State private var viewModel: CharactersViewModel
    @Environment(\.houseManager) private var houseManager

    init(
        favoritesManager: FavoritesManager,
        houseManager: HouseManager,
        selectedCharacter: Binding<Character?>
    ) {
        self._viewModel = State(initialValue: CharactersViewModel(
            favoritesManager: favoritesManager,
            houseManager: houseManager
        ))
        self._selectedCharacter = selectedCharacter
    }

    var body: some View {
        stateView
            .background(houseManager.gradientBackground)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu(viewModel.preferredHouseTitle) {
                        ForEach(House.allCases, id: \.self) { house in
                            Button {
                                viewModel.setPreferredHouse(house)
                            } label: {
                                Text(house.title)
                            }
                        }
                    }
                }
            }
            .task {
                if viewModel.dataState.isInitial {
                    await viewModel.fetchCharacters()
                }
                await viewModel.fetchPreferredHouse()
            }
            .onChange(of: viewModel.activeFilter) { old, new in
                guard old != new else { return }
                
                Task {
                    await viewModel.fetchCharacters()
                }
            }
    }

    @ViewBuilder
    private var stateView: some View {
        switch viewModel.dataState {
            case .initial:
                Color.clear
            case .loading:
                loadingView
            case .ready:
                listView
            case .error(let errorMessage):
                errorView(errorMessage)
        }
    }

    @ViewBuilder
    private var listView: some View {
        List(viewModel.dataState.data ?? [], selection: $selectedCharacter) { character in
            CharacterRowView(
                character: character,
                isFavorite: viewModel.isFavorite(characterId: character.id),
                onFavoriteToggle: {
                    viewModel.toggleFavorite(for: character.id)
                }
            )
            .contentShape(Rectangle())
            .listRowSeparator(.hidden)
            .listRowInsets(.vertical, 4)
            .listRowBackground(Color.clear)
            .onTapGesture {
                selectedCharacter = character
            }
        }
        .listStyle(.plain)
        .safeAreaBar(edge: .top) {
            Picker("Characters filter", selection: $viewModel.activeFilter) {
                ForEach(ListFilter.allCases, id: \.self) {
                    Text($0.title)
                        .tag($0)
                }
            }
            .pickerStyle(.segmented)
            .padding()
        }
        .overlay {
            if (viewModel.dataState.data ?? []).isEmpty {
                emptyView
            }
        }
        .refreshable {
            await viewModel.fetchCharacters()
        }
    }

    @ViewBuilder
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading characters...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func errorView(_ message: String) -> some View {
        ContentUnavailableView {
            Label("Failed to Load", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
                .multilineTextAlignment(.center)
        } actions: {
            Button("Retry") {
                Task {
                    await viewModel.fetchCharacters()
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }

    @ViewBuilder
    private var emptyView: some View {
        ContentUnavailableView(
            "No Characters Found",
            systemImage: "person.slash",
            description: Text("Try changing your filter")
        )
    }
}
