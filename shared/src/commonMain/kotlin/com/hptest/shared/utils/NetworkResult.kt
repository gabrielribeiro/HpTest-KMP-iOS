package com.hptest.shared.utils

/**
 * A sealed class representing the result of a network operation.
 * This pattern provides type-safe error handling and explicit success/failure states.
 *
 * @param T The type of data returned on success
 */
sealed class NetworkResult<out T> {
    /**
     * Represents a successful network operation with data.
     *
     * @property data The successfully retrieved data
     */
    data class Success<T>(val data: T) : NetworkResult<T>()

    /**
     * Represents a failed network operation with an error.
     *
     * @property exception The exception that caused the failure
     * @property message A human-readable error message
     */
    data class Error(
        val exception: Exception,
        val message: String = exception.message ?: "An unknown error occurred"
    ) : NetworkResult<Nothing>()

    /**
     * Represents a loading state (useful for UI state management).
     * Not currently used in repository but available for future enhancements.
     */
    object Loading : NetworkResult<Nothing>()

    /**
     * Returns true if this result is a Success.
     */
    fun isSuccess(): Boolean = this is Success

    /**
     * Returns true if this result is an Error.
     */
    fun isError(): Boolean = this is Error

    /**
     * Returns the data if Success, or null if Error or Loading.
     */
    fun getOrNull(): T? = when (this) {
        is Success -> data
        else -> null
    }

    /**
     * Returns the data if Success, or throws the exception if Error.
     * @throws Exception if this is an Error result
     */
    fun getOrThrow(): T = when (this) {
        is Success -> data
        is Error -> throw exception
        is Loading -> throw IllegalStateException("Cannot get data from Loading state")
    }
}
