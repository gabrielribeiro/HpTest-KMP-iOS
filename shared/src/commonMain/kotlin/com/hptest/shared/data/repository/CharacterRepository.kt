package com.hptest.shared.data.repository

import com.hptest.shared.data.api.HarryPotterApiClient
import com.hptest.shared.domain.filters.CharacterFilter
import com.hptest.shared.domain.models.CharacterDTO
import com.hptest.shared.utils.NetworkResult

/**
 * Repository for managing Harry Potter character data.
 * Implements the repository pattern to abstract data source details from business logic.
 *
 * This class serves as the single source of truth for character data and provides
 * a clean API for fetching and filtering characters. In a production app, this would
 * also handle caching, offline support, and data synchronization.
 */
class CharacterRepository {
    /**
     * API client for fetching character data from the remote server.
     * Initialized lazily to avoid unnecessary HTTP client creation.
     */
    private val apiClient: HarryPotterApiClient by lazy { HarryPotterApiClient() }

    /**
     * Fetches all characters from the API.
     * This is a suspend function that should be called from a coroutine scope.
     *
     * @return NetworkResult.Success containing a list of all character DTOs,
     *         or NetworkResult.Error if the request fails
     *
     * Example usage:
     * ```
     * val repository = CharacterRepository()
     * when (val result = repository.fetchCharacters()) {
     *     is NetworkResult.Success -> displayCharacters(result.data)
     *     is NetworkResult.Error -> showError(result.message)
     * }
     * ```
     */
    suspend fun fetchCharacters(): NetworkResult<List<CharacterDTO>> {
        return apiClient.fetchCharacters()
    }

    /**
     * Fetches characters and applies a filter.
     * Convenience method that combines fetching and filtering in one operation.
     *
     * @param filter The filter to apply (ALL, STUDENTS, or STAFF)
     * @return NetworkResult.Success containing filtered list of characters,
     *         or NetworkResult.Error if the request fails
     *
     * Example usage:
     * ```
     * val repository = CharacterRepository()
     * when (val result = repository.fetchCharacters(CharacterFilter.STUDENTS)) {
     *     is NetworkResult.Success -> displayCharacters(result.data)
     *     is NetworkResult.Error -> showError(result.message)
     * }
     * ```
     */
    suspend fun fetchCharacters(filter: CharacterFilter): NetworkResult<List<CharacterDTO>> {
        return when (val result = apiClient.fetchCharacters()) {
            is NetworkResult.Success -> {
                val filteredCharacters = filter.apply(result.data)
                NetworkResult.Success(filteredCharacters)
            }
            is NetworkResult.Error -> result
        }
    }

    /**
     * Filters an existing list of characters without making a new API request.
     * Useful when you already have the data and want to apply different filters.
     *
     * @param characters The list of characters to filter
     * @param filter The filter to apply
     * @return A new list containing only characters matching the filter criteria
     *
     * Example usage:
     * ```
     * val allCharacters = fetchCharacters().getOrNull() ?: emptyList()
     * val students = filterCharacters(allCharacters, CharacterFilter.STUDENTS)
     * val staff = filterCharacters(allCharacters, CharacterFilter.STAFF)
     * ```
     */
    fun filterCharacters(characters: List<CharacterDTO>, filter: CharacterFilter): List<CharacterDTO> {
        return filter.apply(characters)
    }

    /**
     * Closes the repository and releases all resources.
     * Should be called when the repository is no longer needed to prevent memory leaks.
     */
    fun close() {
        apiClient.close()
    }
}
