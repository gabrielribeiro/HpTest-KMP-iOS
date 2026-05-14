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

    private func loadRocketSimConnect() {
#if DEBUG
        guard (Bundle(path: "/Applications/RocketSim.app/Contents/Frameworks/RocketSimConnectLinker.nocache.framework")?.load() == true) else {
            print("Failed to load linker framework")
            return
        }
        print("RocketSim Connect successfully linked")
#endif
    }

    init() {
        loadRocketSimConnect()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .environment(\.favoritesManager, favoritesManager)
                .environment(\.houseManager, houseManager)
        }
    }
}
