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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.favoritesManager, favoritesManager)
        }
    }
}
