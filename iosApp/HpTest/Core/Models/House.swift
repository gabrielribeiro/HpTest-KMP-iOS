//
//  House.swift
//  HpTest
//
//  Created by Gabriel Ribeiro on 14/05/26.
//

import SwiftUI

enum House: String, CaseIterable {
    case gryffindor = "Gryffindor"
    case slytherin = "Slytherin"
    case ravenclaw = "Ravenclaw"
    case hufflepuff = "Hufflepuff"

    /// Primary color representing the house (used for accents, buttons, etc.)
    var primaryColor: Color {
        switch self {
            case .gryffindor:
                return Color(red: 0.5, green: 0.03, blue: 0.03) // Scarlet #7F0909
            case .slytherin:
                return Color(red: 0.1, green: 0.28, blue: 0.16) // Emerald #1A472A
            case .ravenclaw:
                return Color(red: 0.05, green: 0.1, blue: 0.25) // Blue #0E1A40
            case .hufflepuff:
                return Color(red: 1.0, green: 0.84, blue: 0.0) // Yellow #FFD700
        }
    }

    /// Secondary color representing the house (used for complementary elements)
    var secondaryColor: Color {
        switch self {
            case .gryffindor:
                return Color(red: 1.0, green: 0.77, blue: 0.0) // Gold #FFC500
            case .slytherin:
                return Color(red: 0.67, green: 0.67, blue: 0.67) // Silver #AAAAAA
            case .ravenclaw:
                return Color(red: 0.8, green: 0.5, blue: 0.2) // Bronze #CD7F32
            case .hufflepuff:
                return Color(red: 0.0, green: 0.0, blue: 0.0) // Black #000000
        }
    }

    /// Gradient background for hero sections and prominent UI elements.
    /// Creates a visual identity unique to each house.
    var gradientBackground: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [primaryColor, secondaryColor.opacity(0.6)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Lighter tint of the primary color for card backgrounds and subtle theming.
    var cardBackgroundColor: Color {
        primaryColor.opacity(0.4)
    }

    /// Text color that provides good contrast against the primary color.
    /// Gryffindor, Slytherin, and Ravenclaw use white; Hufflepuff uses black.
    var textColor: Color {
        switch self {
            case .gryffindor, .slytherin, .ravenclaw:
                return .white
            case .hufflepuff:
                return .black
        }
    }

    /// Text color that provides good contrast against the primary color.
    /// Gryffindor, Slytherin, and Ravenclaw use white; Hufflepuff uses black.
    var secondaryTextColor: Color {
        textColor.opacity(0.8)
    }

    /// Emoji that represent the house
    var emoji: String {
        switch self {
            case .gryffindor:
                "🦁"
            case .slytherin:
                "🐍"
            case .hufflepuff:
                "🦡"
            case .ravenclaw:
                "🦅"
        }
    }

    // House title with emoji
    var title: String {
        "\(emoji) \(rawValue.localizedCapitalized)"
    }
}
