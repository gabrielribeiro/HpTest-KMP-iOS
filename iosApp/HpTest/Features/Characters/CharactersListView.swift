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
    @State private var viewModel = CharactersViewModel()

    var body: some View {
        stateView
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Picker("Characters filter", selection: $viewModel.activeFilter) {
                        ForEach(CharacterFilter.allCases, id: \.self) {
                            Text($0.title)
                                .tag($0)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .task {
                if viewModel.dataState.isInitial {
                    await viewModel.fetchCharacters()
                }
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
            CharacterRowView(character: character)
                .contentShape(Rectangle())
                .listRowSeparator(.hidden)
                .listRowInsets(.vertical, 4)
                .onTapGesture {
                    selectedCharacter = character
                }
        }
        .listStyle(.plain)
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
