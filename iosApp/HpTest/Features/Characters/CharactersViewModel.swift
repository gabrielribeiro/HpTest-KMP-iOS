//
//  CharactersViewModel.swift
//  HpTest
//
//  Created by Gabriel Ribeiro on 13/05/26.
//

import SwiftUI
import shared

@MainActor
@Observable
final class CharactersViewModel {

    // MARK: - Properties

    /// State fetched from the API (unfiltered).
    private(set) var dataState: DataState<[Character]> = .initial

    var activeFilter: CharacterFilter = .all

    // MARK: - Dependencies

    /// KMP repository
    private let repository: CharacterRepository
    private let favoritesManager: FavoritesManager

    // MARK: - Initialization

    /// Creates a new CharactersViewModel.
    ///
    /// - Parameters:
    ///   - repository: The KMP repository for fetching characters
    ///   - favoritesManager: Manager for tracking favorite characters
    init(repository: CharacterRepository = CharacterRepository(), favoritesManager: FavoritesManager) {
        self.repository = repository
        self.favoritesManager = favoritesManager
    }

    // MARK: - Public Methods

    /// Fetches all characters from the API
    func fetchCharacters() async {
        let loadingTask = Task {
            guard self.dataState == .initial else {
                return
            }

            try await Task.sleep(nanoseconds: 150_000_000)

            self.dataState = .loading
        }

        do {
            let result: NetworkResult<NSArray> = try await repository.fetchCharacters(filter: activeFilter)

            if let data = result.successData {
                let dtos: [CharacterDTO] = data.compactMap { $0 as? CharacterDTO }

                guard !dtos.isEmpty else {
                    dataState = .error("No characters available.")
                    return
                }

                let characters = dtos.compactMap(Character.init)

                withAnimation {
                    dataState = .ready(characters)
                }
            } else if let message = result.errorMessage {
                dataState = .error(message)
            } else {
                dataState = .error("Unknown response from server.")
            }
        } catch is CancellationError {
            dataState = .error("Operation has been cancelled.")
        } catch {
            dataState = .error("Failed to fetch characters: \(error.localizedDescription)")
        }

        loadingTask.cancel()
    }

    /// Toggles the favorite status of a character.
    ///
    /// - Parameter characterId: The unique identifier of the character
    func toggleFavorite(for characterId: String) {
        favoritesManager.toggleFavorite(characterId: characterId)
    }

    /// Checks if a character is marked as favorite.
    ///
    /// - Parameter characterId: The unique identifier of the character
    /// - Returns: true if the character is favorited
    func isFavorite(characterId: String) -> Bool {
        favoritesManager.isFavorite(characterId: characterId)
    }
}

extension CharacterFilter: CaseIterable {
    public static var allCases: [CharacterFilter] {
        [.all, .students, .staff]
    }

    var title: String {
        switch self {
            case .all: "All"
            case .students: "Students"
            case .staff: "Staff"
            default: "Unknown"
        }
    }
}

