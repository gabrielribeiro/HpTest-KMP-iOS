//
//  CharactersViewModel.swift
//  HpTest
//
//  Created by Gabriel Ribeiro on 13/05/26.
//

import Observation
import shared

@MainActor
@Observable
final class CharactersViewModel {

    // MARK: - Properties

    /// All characters fetched from the API (unfiltered).
    private(set) var allCharacters: [Character] = []

    /// Current loading state.
    private(set) var isLoading: Bool = false

    /// Error message if the fetch failed.
    private(set) var errorMessage: String?

    /// KMP repository
    private let repository: CharacterRepository

    // MARK: - Initialization

    init(repository: CharacterRepository = CharacterRepository()) {
        self.repository = repository
    }

    // MARK: - Public Methods

    /// Fetches all characters from the API
    func fetchCharacters() async {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            let result: NetworkResult<NSArray> = try await repository.fetchCharacters()

            if let data = result.successData {
                let dtos: [CharacterDTO] = data.compactMap { $0 as? CharacterDTO }

                guard !dtos.isEmpty else {
                    errorMessage = "No characters available."
                    allCharacters = []
                    return
                }

                let characters = dtos.compactMap(Character.init)

                allCharacters = characters
                errorMessage = nil
            } else if let message = result.errorMessage {
                errorMessage = message
                allCharacters = []
            } else {
                errorMessage = "Unknown response from server."
                allCharacters = []
            }
        } catch is CancellationError {
            allCharacters = []
            errorMessage = "Operation has been cancelled."
        } catch {
            errorMessage = "Failed to fetch characters: \(error.localizedDescription)"
            allCharacters = []
        }
    }
}

