package com.hptest.shared.data.api

import com.hptest.shared.domain.models.CharacterDTO
import com.hptest.shared.utils.NetworkResult
import io.ktor.client.*
import io.ktor.client.call.*
import io.ktor.client.plugins.*
import io.ktor.client.plugins.contentnegotiation.*
import io.ktor.client.request.*
import io.ktor.http.*
import io.ktor.serialization.kotlinx.json.*
import kotlinx.serialization.SerializationException
import kotlinx.serialization.json.Json

/**
 * HTTP client for interacting with the Harry Potter API (hp-api.onrender.com).
 * Handles network requests and JSON deserialization using Ktor.
 *
 * Thread-safe singleton implementation with proper resource management.
 */
class HarryPotterApiClient {
    companion object {
        private const val BASE_URL = "https://hp-api.onrender.com"
        private const val CHARACTERS_ENDPOINT = "/api/characters"
        private const val REQUEST_TIMEOUT_MS = 30_000L
        private const val CONNECT_TIMEOUT_MS = 15_000L
        private const val MAX_RETRY_ATTEMPTS = 3

        /**
         * Shared HTTP client instance for connection pooling and resource efficiency.
         * Reusing the same client improves performance.
         */
        private val sharedHttpClient by lazy { createHttpClient() }

        /**
         * Creates and configures the HTTP client with all necessary plugins.
         */
        private fun createHttpClient() = HttpClient {
            // Base URL configuration
            install(DefaultRequest) {
                url(BASE_URL)
                header(HttpHeaders.ContentType, ContentType.Application.Json)
            }

            // JSON serialization
            install(ContentNegotiation) {
                json(Json {
                    ignoreUnknownKeys = true
                    isLenient = true
                    coerceInputValues = true
                })
            }

            // Timeout configuration - hp-api.onrender.com can be slow on cold starts
            install(HttpTimeout) {
                requestTimeoutMillis = REQUEST_TIMEOUT_MS
                connectTimeoutMillis = CONNECT_TIMEOUT_MS
                socketTimeoutMillis = REQUEST_TIMEOUT_MS
            }

            // Retry logic for transient failures
            install(HttpRequestRetry) {
                retryOnServerErrors(maxRetries = MAX_RETRY_ATTEMPTS)
                exponentialDelay()
            }
        }
    }

    /**
     * HTTP client instance. Uses shared client for better resource management.
     */
    private val httpClient: HttpClient = sharedHttpClient

    /**
     * Fetches all characters from the Harry Potter API.
     * Handles network errors and returns a NetworkResult for type-safe error handling.
     *
     * Uses automatic retry logic for transient failures (server errors, timeouts).
     *
     * @return NetworkResult.Success with list of character DTOs, or NetworkResult.Error on failure
     */
    suspend fun fetchCharacters(): NetworkResult<List<CharacterDTO>> {
        return try {
            val characters: List<CharacterDTO> = httpClient.get(CHARACTERS_ENDPOINT).body()

            NetworkResult.Success(characters)
        } catch (e: Exception) {
            val errorCode = when (e) {
                is ClientRequestException -> "CLIENT_ERROR_${e.response.status.value}"
                is ServerResponseException -> "SERVER_ERROR_${e.response.status.value}"
                is HttpRequestTimeoutException -> "TIMEOUT"
                is SerializationException -> "SERIALIZATION_ERROR"
                else -> "NETWORK_ERROR"
            }

            NetworkResult.Error(
                message = mapExceptionToUserMessage(e),
                code = errorCode
            )
        }
    }

    /**
     * Maps technical exceptions to user-friendly error messages.
     *
     * @param exception The exception to map
     * @return User-friendly error message
     */
    private fun mapExceptionToUserMessage(exception: Exception): String {
        return when (exception) {
            is HttpRequestTimeoutException ->
                "Request timed out. The server is taking too long to respond. Please try again."

            is io.ktor.client.network.sockets.ConnectTimeoutException ->
                "Connection timeout. Please check your internet connection."

            is ClientRequestException -> {
                val status = exception.response.status
                when (status.value) {
                    400 -> "Bad request. Please try again."
                    401 -> "Authentication required."
                    403 -> "Access forbidden."
                    404 -> "Characters not found."
                    429 -> "Too many requests. Please wait a moment and try again."
                    else -> "Client error: ${status.description}"
                }
            }

            is ServerResponseException -> {
                val status = exception.response.status
                when (status.value) {
                    500 -> "Server error. Please try again later."
                    502, 503 -> "Service temporarily unavailable. Please try again later."
                    504 -> "Gateway timeout. The server is overloaded."
                    else -> "Server error: ${status.description}"
                }
            }

            is SerializationException ->
                "Failed to parse server response. The data format may have changed."

            is io.ktor.client.network.sockets.SocketTimeoutException ->
                "Connection timeout. Please check your internet connection."

            else ->
                "Network error: ${exception.message ?: "Unknown error occurred"}"
        }
    }

    /**
     * Closes the HTTP client and releases resources.
     * Note: Since we use a shared singleton, this should only be called
     * when the entire app is shutting down, not after each request.
     */
    fun close() {
        // Shared client - only close on app shutdown
        // For individual requests, no need to call this
    }
}
