//
//  CharactersListView.swift
//  HpTest
//
//  Created by Gabriel Ribeiro on 13/05/26.
//

import SwiftUI
import PhotosUI
import shared

struct CharactersListView: View {

    @Binding var selectedCharacter: Character?
    @State private var viewModel: CharactersViewModel

    @State private var showPhotoOptions: Bool = false
    @State private var showPhotoLibrary = false
    @State private var showCamera = false
    @State private var selectedPhotoItem: PhotosPickerItem?

    @Environment(\.houseManager) private var houseManager
    @Environment(\.profileImageStore) private var profileImageStore

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
            .navigationBarTitleDisplayMode(.inline)
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

                ToolbarItem(placement: .topBarTrailing)  {
                    profileImageButton
                        .confirmationDialog("Profile Picture", isPresented: $showPhotoOptions) {
                            Button("Take Picture") {
                                showCamera = true
                            }
                            .disabled(!CameraPicker.isAvailable)

                            Button("Choose from Library") {
                                showPhotoLibrary = true
                            }

                            if profileImageStore.profileImage != nil {
                                Button("Remove Picture", role: .destructive) {
                                    profileImageStore.clearProfileImage()
                                }
                            }

                            Button("Cancel", role: .cancel) { }
                        } message: {
                            Text("Set your profile picture")
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
            .fullScreenCover(isPresented: $showCamera) {
                CameraPicker { image in
                    profileImageStore.saveProfileImage(image)
                }
                .ignoresSafeArea()
            }
            .photosPicker(isPresented: $showPhotoLibrary, selection: $selectedPhotoItem, matching: .images)
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    if let newItem = newItem,
                       let data = try? await newItem.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        profileImageStore.saveProfileImage(uiImage)
                    }
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
                isSelected: selectedCharacter?.id == character.id,
                onFavoriteToggle: {
                    viewModel.toggleFavorite(for: character.id)
                }
            )
            .contentShape(Rectangle())
            .listRowSeparator(.hidden)
            .listRowInsets(.vertical, 4)
            .listRowBackground(Color.clear)
            .onTapGesture {
                withAnimation {
                    selectedCharacter = character
                }
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

    @ViewBuilder
    private var profileImageButton: some View {
        Button(action: {
            showPhotoOptions = true
        }) {
            Group {
                if let profileImage = profileImageStore.profileImage {
                    Image(uiImage: profileImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person")
                }
            }
        }
        .buttonStyle(.plain)
    }
}
