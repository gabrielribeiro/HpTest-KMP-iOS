package com.hptest.shared.data.repository

import com.hptest.shared.data.api.HarryPotterApiClient
import com.hptest.shared.domain.filters.CharacterFilter
import com.hptest.shared.domain.models.Character
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
     * @return NetworkResult.Success containing a list of all characters,
     *         or NetworkResult.Error if the request fails
     *
     * Example usage:
     * ```
     * val repository = CharacterRepository()
     * when (val result = repository.fetchCharacters()) {
     *     is NetworkResult.Success -> displayCharacters(result.data)
     *     is NetworkResult.Error -> showError(result.message)
     *     is NetworkResult.Loading -> showLoading()
     * }
     * ```
     */
    suspend fun fetchCharacters(): NetworkResult<List<Character>> {
        return apiClient.fetchCharacters()
    }

    /**
     * Closes the repository and releases all resources.
     * Should be called when the repository is no longer needed to prevent memory leaks.
     */
    fun close() {
        apiClient.close()
    }
}
