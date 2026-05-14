//
//  FavoritesManager.swift
//  HpTest
//
//  Created by Gabriel Ribeiro on 14/05/26.
//

import Foundation
import SwiftUI

/// Manages the user's favorite characters with persistence to UserDefaults.
@Observable
final class FavoritesManager {

    // MARK: - Properties

    private static let favoriteCharacterIds = "favoriteCharacterIds"

    /// Set of character IDs that have been favorited by the user.
    private(set) var favoriteCharacterIds: Set<String> {
        didSet {
            saveFavorites()
        }
    }

    private let userDefaults: UserDefaults

    // MARK: - Initialization

    /// Creates a new FavoritesManager with optional custom UserDefaults.
    ///
    /// - Parameter userDefaults: The UserDefaults instance to use (default: .standard)
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.favoriteCharacterIds = Self.loadFavorites(from: userDefaults)
    }

    // MARK: - Public Methods

    /// Checks if a character is marked as favorite.
    ///
    /// - Parameter characterId: The unique identifier of the character
    /// - Returns: true if the character is in the favorites set
    func isFavorite(characterId: String) -> Bool {
        favoriteCharacterIds.contains(characterId)
    }

    /// Toggles the favorite status of a character.
    /// If the character is currently favorited, it will be unfavorited, and vice versa.
    ///
    /// - Parameter characterId: The unique identifier of the character
    /// - Returns: true if the character is in the favorites set
    @discardableResult
    func toggleFavorite(characterId: String) -> Bool{
        if favoriteCharacterIds.contains(characterId) {
            favoriteCharacterIds.remove(characterId)
            return false
        } else {
            favoriteCharacterIds.insert(characterId)
            return true
        }
    }

    // MARK: - Private Methods

    /// Loads favorites from UserDefaults.
    private static func loadFavorites(from userDefaults: UserDefaults) -> Set<String> {
        let array = userDefaults.array(forKey: Self.favoriteCharacterIds) as? [String] ?? []
        return Set(array)
    }

    /// Saves the current favorites to UserDefaults.
    /// Called automatically whenever favoriteCharacterIds changes.
    private func saveFavorites() {
        let array = Array(favoriteCharacterIds)
        userDefaults.set(array, forKey: Self.favoriteCharacterIds)
    }
}

// MARK: - Environment Key

/// Custom environment key for injecting FavoritesManager into the SwiftUI environment.
private struct FavoritesManagerKey: EnvironmentKey {
    static let defaultValue = FavoritesManager()
}

extension EnvironmentValues {
    /// Access the FavoritesManager from the environment.
    /// Usage: @Environment(\.favoritesManager) var favoritesManager
    var favoritesManager: FavoritesManager {
        get { self[FavoritesManagerKey.self] }
        set { self[FavoritesManagerKey.self] = newValue }
    }
}
