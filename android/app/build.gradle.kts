plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.soulmate.soul_mate"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.soulmate.soul_mate"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        debug {
            externalNativeBuild {
                cmake {
                    arguments("-Wno-dev", "--no-warn-unused-cli", "-DCMAKE_BUILD_TYPE=debug", "-DCMAKE_CROSSCOMPILING=TRUE", "-DCMAKE_C_COMPILER_WORKS=TRUE", "-DCMAKE_CXX_COMPILER_WORKS=TRUE", "-DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY")
                }
            }
        }
        release {
            signingConfig = signingConfigs.getByName("debug")
            externalNativeBuild {
                cmake {
                    arguments("-Wno-dev", "--no-warn-unused-cli", "-DCMAKE_BUILD_TYPE=release", "-DCMAKE_CROSSCOMPILING=TRUE", "-DCMAKE_C_COMPILER_WORKS=TRUE", "-DCMAKE_CXX_COMPILER_WORKS=TRUE", "-DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY")
                }
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}