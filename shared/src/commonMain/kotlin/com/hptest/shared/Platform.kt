package com.hptest.shared

// Simple test class to verify KMP integration
class Greeting {
    private val platform: String = "iOS"

    fun greet(): String {
        return "Hello from Kotlin Multiplatform on $platform!"
    }
}
