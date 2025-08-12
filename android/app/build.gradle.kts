// android/app/build.gradle.kts — Easy Playlists (Flutter, Kotlin DSL)

import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load keystore properties from android/key.properties
val keystoreProperties = Properties().apply {
    val f = rootProject.file("android/key.properties")
    if (f.exists()) {
        load(FileInputStream(f))
    } else {
        // Will still build debug; release build needs this file.
        println("WARNING: android/key.properties not found; release signing will fail.")
    }
}

android {
    namespace = "com.example.easy_playlists"  // ← optional: change package namespace if you like
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"              // ← match plugins’ requirement

    defaultConfig {
        // ***** IMPORTANT: set your final app id (reverse-DNS) before first Play release
        applicationId = "com.yourdomain.easyplaylists"  // ← CHANGE THIS
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion

        // Bump versionCode for every Play Store upload
        versionCode = 1
        versionName = "1.0.0"
    }

    // Java/Kotlin toolchains
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    signingConfigs {
        create("release") {
            // These keys must exist in android/key.properties
            if (keystoreProperties.isNotEmpty()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        getByName("debug") {
            // debug remains unsigned; fast builds
            isMinifyEnabled = false
        }
        getByName("release") {
            isMinifyEnabled = false        // you can enable R8 later
            isShrinkResources = false      // <- add this
            signingConfig = signingConfigs.getByName("release")
        }
    }

    // (Optional) shrinker config can go here later if you enable minify
}

dependencies {
    // Flutter manages most dependencies; usually nothing needed here.
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")
}
