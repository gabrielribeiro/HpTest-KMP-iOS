//
//  CharacterDetailView.swift
//  HpTest
//
//  Created by Gabriel Ribeiro on 14/05/26.
//

import SwiftUI
import CachedAsyncImage

struct CharacterDetailView: View {

    // MARK: - Dependencies

    let favoritesManager: FavoritesManager
    let character: Character
    @Environment(\.houseManager) private var houseManager

    // MARK: - States

    @State private var isFavorite: Bool = false

    // MARK: - Views

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                heroSection
                    .clipped()

                VStack(spacing: 30) {
                    basicInfoSection
                    magicalInfoSection
                    physicalInfoSection
                    actorInfoSection
                }
                .padding()

                Spacer(minLength: 40)
            }
        }
        .background(houseManager.gradientBackground)
        .ignoresSafeArea()
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Favorite", systemImage: isFavorite ? "heart.fill" : "heart") {
                    toggleFavorite()
                }
                .buttonStyle(.plain)
                .labelStyle(.iconOnly)
                .foregroundStyle(.pink)
            }
        }
        .onAppear {
            isFavorite = favoritesManager.isFavorite(characterId: character.id)
        }
    }

    private var heroSection: some View {
        ZStack(alignment: .bottom) {
            if let characterImageURL = character.imageURL {
                CachedAsyncImage(url: characterImageURL) { phase in
                    switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .edgesIgnoringSafeArea(.all)
                                .blur(radius: 40)
                                .overlay(Color.black.opacity(0.3))
                                .frame(maxHeight: 400)
                        default:
                            Color.clear
                    }
                }

                CachedAsyncImage(url: characterImageURL) { phase in
                    switch phase {
                        case .empty:
                            ProgressView()
                                .frame(height: 400)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 400)
                                .shadow(radius: 15)
                        case .failure:
                            VStack {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 80))
                                    .foregroundColor(houseManager.textColor.opacity(0.6))
                                Text("Image unavailable")
                                    .foregroundColor(houseManager.textColor.opacity(0.8))
                            }
                            .frame(height: 400)
                        @unknown default:
                            Color.clear
                    }
                }
            } else {
                VStack {
                    Image(systemName: "person.slash.fill")
                        .font(.system(size: 80))
                        .foregroundColor(houseManager.textColor.opacity(0.6))
                    Text("Image unavailable")
                        .foregroundColor(houseManager.textColor.opacity(0.8))
                }
                .frame(height: 400)
            }

            Text(character.name)
                .font(.largeTitle.bold())
                .foregroundStyle(houseManager.gradientBackground)
                .frame(maxWidth: .infinity, alignment: .bottom)
                .padding()
        }
    }

    // MARK: - Information Sections

    /// Basic character information
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Basic Information")

            infoRow(icon: "house.fill", label: "House", value: character.displayHouse)
            infoRow(icon: "person.fill", label: "Species", value: character.species ?? "Unknown")
            infoRow(icon: "person.badge.key.fill", label: "Gender", value: character.gender ?? "Unknown")
            infoRow(icon: "heart.text.square", label: "Status", value: character.alive ? "Alive" : "Deceased")

            if let ancestry = character.ancestry, !ancestry.isEmpty {
                infoRow(icon: "tree.fill", label: "Ancestry", value: ancestry)
            }

            if let dateOfBirth = character.dateOfBirth, !dateOfBirth.isEmpty {
                infoRow(icon: "calendar", label: "Date of Birth", value: dateOfBirth)
            }
        }
    }

    /// Magical attributes
    private var magicalInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Magical Attributes")

            infoRow(icon: "wand.and.stars", label: "Wizard", value: character.wizard ? "Yes" : "No")
            infoRow(icon: "graduationcap.fill", label: "Student", value: character.hogwartsStudent ? "Yes" : "No")
            infoRow(icon: "book.fill", label: "Staff", value: character.hogwartsStaff ? "Yes" : "No")

            if let patronus = character.patronus, !patronus.isEmpty {
                infoRow(icon: "sparkles", label: "Patronus", value: patronus.capitalized)
            }

            if let wandDescription = character.wand?.description {
                infoRow(icon: "wand.and.stars.inverse", label: "Wand", value: wandDescription)
            }
        }
    }

    /// Physical characteristics
    @ViewBuilder
    private var physicalInfoSection: some View {
        if hasPhysicalInfo {
            VStack(alignment: .leading, spacing: 16) {
                sectionHeader("Physical Characteristics")

                if let eyeColour = character.eyeColour, !eyeColour.isEmpty {
                    infoRow(icon: "eye.fill", label: "Eye Color", value: eyeColour.capitalized)
                }

                if let hairColour = character.hairColour, !hairColour.isEmpty {
                    infoRow(icon: "comb.fill", label: "Hair Color", value: hairColour.capitalized)
                }
            }
        }
    }

    /// Actor information
    @ViewBuilder
    private var actorInfoSection: some View {
        if let actor = character.actor, !actor.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                sectionHeader("Film")

                infoRow(icon: "film.fill", label: "Actor", value: actor)

                if character.hasAlternateNames {
                    infoRow(icon: "quote.bubble.fill", label: "Alternate Names", value: character.alternateNamesFormatted)
                }
            }
        }
    }

    // MARK: - Helper Views

    /// Section header with themed styling
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.title3)
            .fontWeight(.bold)
            .foregroundStyle(houseManager.textColor)
    }

    /// Information row with icon, label, and value
    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Label(label, systemImage: icon)
                .labelReservedIconWidth(24)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(houseManager.secondaryTextColor)

            Spacer()

            Text(value.localizedCapitalized)
                .font(.body)
                .foregroundColor(houseManager.textColor)
                .frame(alignment: .trailing)
                .multilineTextAlignment(.trailing)
        }
    }

    // MARK: - Computed Properties

    /// Returns true if character has any physical characteristic information
    private var hasPhysicalInfo: Bool {
        (character.eyeColour != nil && !character.eyeColour!.isEmpty) ||
        (character.hairColour != nil && !character.hairColour!.isEmpty)
    }

    // MARK: - Functions

    private func toggleFavorite() {
        isFavorite = favoritesManager.toggleFavorite(characterId: character.id)
    }
}

#Preview {
    CharacterDetailView(favoritesManager: FavoritesManager(), character: Character.mock)
}
