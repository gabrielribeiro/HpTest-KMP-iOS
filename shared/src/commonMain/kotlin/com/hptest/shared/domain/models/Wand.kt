package com.hptest.shared.domain.models

import kotlinx.serialization.Serializable

/**
 * Represents a wizard's wand with its magical properties.
 *
 * @property wood The type of wood the wand is made from
 * @property core The magical core material of the wand
 * @property length The length of the wand in inches (nullable as some wands don't specify)
 */
@Serializable
data class Wand(
    val wood: String?,
    val core: String?,
    val length: Double?
)
