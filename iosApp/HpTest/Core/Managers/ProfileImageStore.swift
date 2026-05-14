//
//  ProfileImageStore.swift
//  HpTest
//
//  Created by Gabriel Ribeiro on 14/05/26.
//


import SwiftUI
import UIKit

/// Manages storage and retrieval of the user's profile image.
/// Images are compressed and stored in UserDefaults as JPEG data.
@Observable
final class ProfileImageStore {
    // MARK: - Properties

    private static let profileImageKey = "profileImage"

    /// The current profile image, if one has been set.
    /// Loaded from UserDefaults on initialization and updated when a new image is saved.
    private(set) var profileImage: UIImage?

    private let userDefaults: UserDefaults

    /// JPEG compression quality (0.0 - 1.0).
    /// Set to 0.7 to balance image quality with storage size.
    private let compressionQuality: CGFloat = 0.7

    // MARK: - Initialization

    /// Creates a new ProfileImageStore with optional custom UserDefaults.
    ///
    /// - Parameter userDefaults: The UserDefaults instance to use (default: .standard)
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.profileImage = Self.loadImage(from: userDefaults)
    }

    // MARK: - Public Methods

    /// Saves a new profile image to persistent storage.
    /// The image is compressed to JPEG format before storage to reduce size.
    ///
    /// - Parameter image: The UIImage to save as the profile picture
    func saveProfileImage(_ image: UIImage) {
        // Compress image to JPEG data
        guard let imageData = image.jpegData(compressionQuality: compressionQuality) else {
            print("Failed to compress profile image")
            return
        }

        // Save to UserDefaults
        userDefaults.set(imageData, forKey: Self.profileImageKey)

        // Update the in-memory image
        self.profileImage = image
    }

    /// Removes the profile image from storage.
    func clearProfileImage() {
        userDefaults.removeObject(forKey: Self.profileImageKey)
        self.profileImage = nil
    }

    /// Returns true if a profile image has been set.
    var hasProfileImage: Bool {
        profileImage != nil
    }

    // MARK: - Private Methods

    /// Loads the profile image from UserDefaults.
    private static func loadImage(from userDefaults: UserDefaults) -> UIImage? {
        guard let imageData = userDefaults.data(forKey: Self.profileImageKey) else {
            return nil
        }

        return UIImage(data: imageData)
    }
}

// MARK: - Environment Key

/// Custom environment key for injecting ProfileImageStore into the SwiftUI environment.
private struct ProfileImageStoreKey: EnvironmentKey {
    static let defaultValue = ProfileImageStore()
}

extension EnvironmentValues {
    /// Access the ProfileImageStore from the environment.
    /// Usage: @Environment(\.profileImageStore) var profileImageStore
    var profileImageStore: ProfileImageStore {
        get { self[ProfileImageStoreKey.self] }
        set { self[ProfileImageStoreKey.self] = newValue }
    }
}
