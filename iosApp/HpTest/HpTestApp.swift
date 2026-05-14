//
//  HpTestApp.swift
//  HpTest
//
//  Created by Gabriel Ribeiro on 13/05/26.
//

import SwiftUI

@main
struct HpTestApp: App {

    /// Global favorites manager for tracking liked characters
    @State private var favoritesManager: FavoritesManager = FavoritesManager()

    /// Global house manager for tracking user's house
    @State private var houseManager: HouseManager = HouseManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .environment(\.favoritesManager, favoritesManager)
                .environment(\.houseManager, houseManager)
        }
    }
}
