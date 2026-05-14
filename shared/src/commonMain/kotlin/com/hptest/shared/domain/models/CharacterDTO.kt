package com.hptest.shared.domain.models

import kotlinx.serialization.Serializable

/**
 * Data Transfer Object representing a character from the Harry Potter universe.
 * Maps directly to the API response structure from hp-api.onrender.com
 *
 * This DTO should be mapped to a domain model in the presentation layer.
 *
 * @property id Unique identifier for the character
 * @property name Full name of the character
 * @property alternateNames List of alternate names or nicknames
 * @property species The species of the character (human, half-giant, werewolf, etc.)
 * @property gender Gender of the character
 * @property house Hogwarts house (Gryffindor, Slytherin, Ravenclaw, Hufflepuff, or empty)
 * @property dateOfBirth Date of birth in string format (nullable)
 * @property yearOfBirth Year of birth as integer (nullable)
 * @property wizard Whether the character has magical abilities
 * @property ancestry Blood status (pure-blood, half-blood, muggle-born, etc.)
 * @property eyeColour Eye color description
 * @property hairColour Hair color description
 * @property wand The character's wand (nullable for non-wizards)
 * @property patronus The character's patronus form (nullable)
 * @property hogwartsStudent Whether the character is/was a Hogwarts student
 * @property hogwartsStaff Whether the character is/was Hogwarts staff
 * @property actor Name of the actor who portrayed this character
 * @property alternateActors List of other actors who played this character
 * @property alive Whether the character is alive (as of series end)
 * @property image URL to character image
 */
@Serializable
data class CharacterDTO(
    val id: String,
    val name: String,
    val alternateNames: List<String> = emptyList(),
    val species: String?,
    val gender: String?,
    val house: String = "",
    val dateOfBirth: String?,
    val yearOfBirth: Int?,
    val wizard: Boolean,
    val ancestry: String?,
    val eyeColour: String?,
    val hairColour: String?,
    val wand: WandDTO?,
    val patronus: String?,
    val hogwartsStudent: Boolean,
    val hogwartsStaff: Boolean,
    val actor: String?,
    val alternateActors: List<String> = emptyList(),
    val alive: Boolean,
    val image: String
) {
    /**
     * Returns a displayable house name, or "Unknown" if no house is assigned.
     * Handles empty strings from the API response.
     */
    fun displayHouse(): String = house.ifEmpty { "Unknown" }

    /**
     * Returns true if this character has any alternate names.
     */
    fun hasAlternateNames(): Boolean = alternateNames.isNotEmpty()

    /**
     * Returns a formatted wand description, or null if no wand information is available.
     * Example: "Vine wood, Dragon heartstring core, 10.75 inches"
     */
    fun wandDescription(): String? {
        val wandData = wand ?: return null
        val parts = mutableListOf<String>()

        wandData.wood?.let { if (it.isNotEmpty()) parts.add("$it wood") }
        wandData.core?.let { if (it.isNotEmpty()) parts.add("$it core") }
        wandData.length?.let { parts.add("$it inches") }

        return if (parts.isEmpty()) null else parts.joinToString(", ")
    }
}
