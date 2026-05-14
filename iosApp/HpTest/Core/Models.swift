//
//  Models.swift
//  HpTest
//
//  Created by Gabriel Ribeiro on 13/05/26.
//

import Foundation
import shared

struct Character: Identifiable, Hashable {
    let id: String
    let name: String
    let alternateNames: [String]
    let species: String?
    let gender: String?
    let house: String
    let dateOfBirth: String?
    let yearOfBirth: Int32?
    let wizard: Bool
    let ancestry: String?
    let eyeColour: String?
    let hairColour: String?
    let wand: Wand?
    let patronus: String?
    let hogwartsStudent: Bool
    let hogwartsStaff: Bool
    let actor: String?
    let alternateActors: [String]
    let alive: Bool
    let image: String

    init(
        id: String = UUID().uuidString,
        name: String = "",
        alternateNames: [String] = [],
        species: String? = nil,
        gender: String? = nil,
        house: String = "",
        dateOfBirth: String? = nil,
        yearOfBirth: Int32? = nil,
        wizard: Bool = false,
        ancestry: String? = nil,
        eyeColour: String? = nil,
        hairColour: String? = nil,
        wand: Wand? = nil,
        patronus: String? = nil,
        hogwartsStudent: Bool = false,
        hogwartsStaff: Bool = false,
        actor: String? = nil,
        alternateActors: [String] = [],
        alive: Bool = false,
        image: String = ""
    ) {
        self.id = id
        self.name = name
        self.alternateNames = alternateNames
        self.species = species
        self.gender = gender
        self.house = house
        self.dateOfBirth = dateOfBirth
        self.yearOfBirth = yearOfBirth
        self.wizard = wizard
        self.ancestry = ancestry
        self.eyeColour = eyeColour
        self.hairColour = hairColour
        self.wand = wand
        self.patronus = patronus
        self.hogwartsStudent = hogwartsStudent
        self.hogwartsStaff = hogwartsStaff
        self.actor = actor
        self.alternateActors = alternateActors
        self.alive = alive
        self.image = image
    }

    init(from kmpCharacter: CharacterDTO) {
        self.id = kmpCharacter.id
        self.name = kmpCharacter.name
        self.alternateNames = kmpCharacter.alternateNames.compactMap { $0 as String }
        self.species = kmpCharacter.species
        self.gender = kmpCharacter.gender
        self.house = kmpCharacter.house
        self.dateOfBirth = kmpCharacter.dateOfBirth
        self.yearOfBirth = kmpCharacter.yearOfBirth?.int32Value
        self.wizard = kmpCharacter.wizard
        self.ancestry = kmpCharacter.ancestry
        self.eyeColour = kmpCharacter.eyeColour
        self.hairColour = kmpCharacter.hairColour
        self.wand = kmpCharacter.wand.map(Wand.init)
        self.patronus = kmpCharacter.patronus
        self.hogwartsStudent = kmpCharacter.hogwartsStudent
        self.hogwartsStaff = kmpCharacter.hogwartsStaff
        self.actor = kmpCharacter.actor
        self.alternateActors = kmpCharacter.alternateActors.compactMap { $0 as String }
        self.alive = kmpCharacter.alive
        self.image = kmpCharacter.image
    }

    var imageURL: URL? {
        let trimmed = image.trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            !trimmed.isEmpty,
            let url = URL(string: trimmed),
            let scheme = url.scheme?.lowercased(),
            (scheme == "https" || scheme == "http"),
            url.host != nil
        else { return nil }
        return url
    }

    var displayHouse: String {
        house.isEmpty ? "Unknown" : house
    }

    var hasAlternateNames: Bool {
        !alternateNames.isEmpty
    }

    var alternateNamesFormatted: String {
        alternateNames.joined(separator: "\n")
    }
}

struct Wand: Hashable {
    let wood: String?
    let core: String?
    let length: Double?

    init(wood: String?, core: String?, length: Double?) {
        self.wood = wood
        self.core = core
        self.length = length
    }

    init(from kmpWand: WandDTO) {
        self.wood = kmpWand.wood
        self.core = kmpWand.core
        self.length = kmpWand.length?.doubleValue
    }

    var description: String? {
        var parts: [String] = []
        if let wood = wood, !wood.isEmpty {
            parts.append("\(wood) wood")
        }
        if let core = core, !core.isEmpty {
            parts.append("\(core) core")
        }
        if let length = length {
            parts.append("\(length) inches")
        }
        return parts.isEmpty ? nil : parts.joined(separator: ", ")
    }
}

extension Character {
    static let mock: Character = {
        Character(
            id: "9e3f7ce4-b9a7-4244-b709-dae5c1f1d4a8",
            name: "Harry Potter",
            alternateNames: [
                "The Boy Who Lived",
                "The Chosen One",
                "Undesirable No. 1",
                "Potty"
            ],
            species: "human",
            gender: "male",
            house: "Gryffindor",
            dateOfBirth: "31-07-1980",
            yearOfBirth: 1980,
            wizard: true,
            ancestry: "half-blood",
            eyeColour: "green",
            hairColour: "black",
            wand: Wand(
                wood: "holly",
                core: "phoenix tail feather",
                length: 11
            ),
            patronus: "stag",
            hogwartsStudent: true,
            hogwartsStaff: false,
            actor: "Daniel Radcliffe",
            alternateActors: [],
            alive: true,
            image: "https://ik.imagekit.io/hpapi/harry.jpg"
        )
    }()
}
