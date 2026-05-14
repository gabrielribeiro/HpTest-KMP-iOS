//
//  CharacterRowView.swift
//  HpTest
//
//  Created by Gabriel Ribeiro on 14/05/26.
//

import SwiftUI
import CachedAsyncImage

struct CharacterRowView: View {

    // MARK: - Properties
    let character: Character
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            if let characterImageURL = character.imageURL {
                CachedAsyncImage(url: characterImageURL) { phase in
                    switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 60, height: 80)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        case .failure:
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 60, height: 80)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.gray)
                                )
                        @unknown default:
                            Color.clear
                    }
                }
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 60, height: 80)
                    .overlay(
                        Image(systemName: "person.slash.fill")
                            .foregroundColor(.gray)
                    )
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(character.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)

                Text(character.house)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                if let actor = character.actor, !actor.isEmpty {
                    Text(actor)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer()
            }

            Spacer()

            Button("Favorite", systemImage: isFavorite ? "heart.fill" : "heart") {
                onFavoriteToggle()
            }
            .foregroundStyle(.pink)
            .buttonStyle(.plain)
            .controlSize(.regular)
            .labelStyle(.iconOnly)
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .padding()
        .background(Color(uiColor: .systemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .contentShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    CharacterRowView(
        character: Character.mock,
        isFavorite: false,
        onFavoriteToggle: {}
    )
}
