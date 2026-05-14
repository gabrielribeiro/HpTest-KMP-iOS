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
     * @property message A human-readable error message for display to users
     * @property code Optional error code for programmatic handling
     */
    data class Error(
        val message: String,
        val code: String? = null
    ) : NetworkResult<Nothing>()

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
     * Returns the error message if Error, or null otherwise.
     */
    val errorMessage: String?
        get() = (this as? Error)?.message

    /**
     * Returns the error code if Error, or null otherwise.
     */
    val errorCode: String?
        get() = (this as? Error)?.code

    /**
     * Returns the success data if Success, or null otherwise.
     */
    val successData: T?
        get() = (this as? Success)?.data
}
