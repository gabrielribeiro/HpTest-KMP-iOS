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

    /// KMP repository
    private let repository: CharacterRepository

    // MARK: - Initialization

    init(repository: CharacterRepository = CharacterRepository()) {
        self.repository = repository
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

