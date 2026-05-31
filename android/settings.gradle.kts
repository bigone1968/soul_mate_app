pluginManagement {
    val flutterSdkPath =
        run {
            val localProperties = java.io.File("local.properties")
            if (localProperties.exists()) {
                val properties = java.util.Properties()
                localProperties.inputStream().use { properties.load(it) }
                val sdk = properties.getProperty("flutter.sdk")
                if (sdk != null) return@run sdk
            }
            System.getenv("FLUTTER_ROOT") ?: error("flutter.sdk not found in local.properties nor FLUTTER_ROOT env")
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.7.3" apply false
    id("org.jetbrains.kotlin.android") version "2.0.21" apply false
}

include(":app")
