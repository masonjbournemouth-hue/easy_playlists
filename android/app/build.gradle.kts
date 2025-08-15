import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// --- Load signing props written by CI (android/key.properties) ---
// From the app/ module, that file is one level up at ../key.properties
val keystoreProperties = Properties()
val keystorePropertiesFile = file("../key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.example.easy_playlists" // change later to your final package id
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // matches CI workflow and plugins

    defaultConfig {
        applicationId = "com.example.easy_playlists" // update to your final id (e.g., com.yourdomain.easyplaylists)
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    // Use Java 17 with current AGP/Kotlin toolchains
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    signingConfigs {
        create("release") {
            val storeFilePath = keystoreProperties.getProperty("storeFile") ?: ""
            if (storeFilePath.isNotBlank()) {
                storeFile = file(storeFilePath)
            }
            storePassword = keystoreProperties.getProperty("storePassword")
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            // Keep “light” to reduce CI memory pressure; you can enable later if desired.
            isMinifyEnabled = false
            isShrinkResources = false
        }
        getByName("debug") {
            // no special debug tweaks
        }
    }

    // Ensure duplicate native/metadata files don’t break packaging
    packaging {
        resources {
            excludes += setOf(
                "META-INF/AL2.0",
                "META-INF/LGPL2.1",
                "META-INF/DEPENDENCIES",
                "META-INF/NOTICE",
                "META-INF/LICENSE",
                "META-INF/LICENSE.txt",
                "META-INF/NOTICE.txt"
            )
        }
    }
}

// Flutter source location
flutter {
    source = "../.."
}

dependencies {
    // Desugaring for some Java 8+ APIs on older Androids
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.2")
    // (No other explicit deps needed; Flutter/Plugins handle theirs)
}
