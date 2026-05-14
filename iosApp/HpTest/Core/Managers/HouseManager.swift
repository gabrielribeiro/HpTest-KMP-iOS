//
//  HouseManager.swift
//  HpTest
//
//  Created by Gabriel Ribeiro on 14/05/26.
//

import Foundation
import SwiftUI

/// Manages the user's house with persistence to UserDefaults.
@Observable
final class HouseManager {

    // MARK: - Properties

    private static let houseKey = "preferredHouse"

    /// The currently selected Hogwarts house. Changes to this property trigger UI updates.
    /// Persisted to UserDefaults automatically.
    var preferredHouse: House {
        didSet {
            userDefaults.set(preferredHouse.rawValue, forKey: Self.houseKey)
        }
    }

    private let userDefaults: UserDefaults

    // MARK: - Initialization

    /// Creates a new FavoritesManager with optional custom UserDefaults.
    ///
    /// - Parameter userDefaults: The UserDefaults instance to use (default: .standard)
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.preferredHouse = userDefaults.string(forKey: Self.houseKey).flatMap(House.init(rawValue:)) ?? .gryffindor
    }

    // MARK: - Properties

    /// Returns the primary color for the current theme.
    /// Convenience accessor for the most commonly used theme property.
    var primaryColor: Color {
        preferredHouse.primaryColor
    }

    /// Returns the secondary color for the current theme.
    var secondaryColor: Color {
        preferredHouse.secondaryColor
    }

    /// Gradient background for hero sections and prominent UI elements.
    /// Creates a visual identity unique to each house.
    var gradientBackground: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [preferredHouse.primaryColor, secondaryColor.opacity(0.6)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Returns the card background color for the current theme.
    /// Used for info cards and subtle theming elements.
    var cardBackground: Color {
        preferredHouse.cardBackgroundColor
    }

    /// Returns the text color that contrasts well with the primary color.
    var textColor: Color {
        preferredHouse.textColor
    }

    /// Returns the text color that contrasts well with the primary color.
    var secondaryTextColor: Color {
        preferredHouse.secondaryTextColor
    }
}

// MARK: - Environment Key

/// Custom environment key for injecting HouseManager into the SwiftUI environment.
private struct HouseManagerKey: EnvironmentKey {
    static let defaultValue = HouseManager()
}

extension EnvironmentValues {
    /// Access the FavoritesManager from the environment.
    /// Usage: @Environment(\.houseManager) var favoritesManager
    var houseManager: HouseManager {
        get { self[HouseManagerKey.self] }
        set { self[HouseManagerKey.self] = newValue }
    }
}

