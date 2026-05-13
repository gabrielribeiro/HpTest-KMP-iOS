plugins {
    kotlin("multiplatform") version "1.9.21"
    kotlin("plugin.serialization") version "1.9.21"
    id("com.android.library") version "8.1.4" apply false
}

kotlin {
    // iOS targets
    listOf(
        iosX64(),
        iosArm64(),
        iosSimulatorArm64()
    ).forEach { iosTarget ->
        iosTarget.binaries.framework {
            baseName = "shared"
            isStatic = true
        }
    }

    sourceSets {
        val commonMain by getting {
            dependencies {
                // Ktor client for networking
                implementation("io.ktor:ktor-client-core:2.3.7")
                implementation("io.ktor:ktor-client-content-negotiation:2.3.7")
                implementation("io.ktor:ktor-serialization-kotlinx-json:2.3.7")

                // Kotlinx serialization for JSON parsing
                implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.6.2")

                // Coroutines for async operations
                implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.7.3")
            }
        }

        val iosX64Main by getting
        val iosArm64Main by getting
        val iosSimulatorArm64Main by getting
        val iosMain by creating {
            dependsOn(commonMain)
            iosX64Main.dependsOn(this)
            iosArm64Main.dependsOn(this)
            iosSimulatorArm64Main.dependsOn(this)
            dependencies {
                // Darwin engine for iOS HTTP client
                implementation("io.ktor:ktor-client-darwin:2.3.7")
            }
        }
    }
}

tasks.findByName("embedAndSignAppleFrameworkForXcode") ?: tasks.register("embedAndSignAppleFrameworkForXcode") {
    val mode = System.getenv("CONFIGURATION") ?: "Debug"
    val targetName = when (val sdk = System.getenv("SDK_NAME") ?: "") {
        "iphoneos" -> "iosArm64"
        "iphonesimulator" -> "iosSimulatorArm64"
        else -> "iosX64"
    }

    val framework = kotlin.targets
        .getByName<org.jetbrains.kotlin.gradle.plugin.mpp.KotlinNativeTarget>(targetName)
        .binaries.getFramework(mode)

    dependsOn(framework.linkTask)

    doLast {
        val frameworkDir = framework.outputDirectory
        val targetDir = System.getenv("TARGET_BUILD_DIR")
        val frameworksFolder = System.getenv("FRAMEWORKS_FOLDER_PATH")

        if (targetDir != null && frameworksFolder != null) {
            val destination = file("$targetDir/$frameworksFolder")
            destination.mkdirs()
            copy {
                from(frameworkDir)
                into(destination)
            }
        }
    }
}
