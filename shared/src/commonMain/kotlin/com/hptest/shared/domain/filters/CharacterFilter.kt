package com.hptest.shared.domain.filters

import com.hptest.shared.domain.models.CharacterDTO

/**
 * Enumeration of available character filters.
 * Used to filter the character list by role at Hogwarts.
 */
enum class CharacterFilter {
    /** Show all characters regardless of Hogwarts affiliation */
    ALL,

    /** Show only Hogwarts students (hogwartsStudent == true) */
    STUDENTS,

    /** Show only Hogwarts staff (hogwartsStaff == true) */
    STAFF;

    /**
     * Applies this filter to a list of character DTOs.
     *
     * @param characters The list of character DTOs to filter
     * @return A filtered list containing only characters matching this filter criteria
     */
    fun apply(characters: List<CharacterDTO>): List<CharacterDTO> {
        return when (this) {
            ALL -> characters
            STUDENTS -> characters.filter { it.hogwartsStudent }
            STAFF -> characters.filter { it.hogwartsStaff }
        }
    }
}
