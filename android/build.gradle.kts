plugins {
    id("com.android.application")
    // id("org.jetbrains.kotlin.android") // uncomment if you use Kotlin Android
}

android {
    namespace = "com.orakl.orakl"   // ← change to your package
    compileSdk = 34                   // or your current compileSdk

    defaultConfig {
        applicationId = "com.orakl.orakl"  // ← change to your appId
        minSdk = 24
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    // --- Read properties defined in gradle.properties (project or user-level) ---
    val storeFileProp = (findProperty("MYAPP_UPLOAD_STORE_FILE") as String?) ?: ""
    val storePass = (findProperty("MYAPP_UPLOAD_STORE_PASSWORD") as String?) ?: ""
    val keyAliasProp = (findProperty("MYAPP_UPLOAD_KEY_ALIAS") as String?) ?: ""
    val keyPass = (findProperty("MYAPP_UPLOAD_KEY_PASSWORD") as String?) ?: ""

    // (Optional) fail fast if something is missing
    require(storeFileProp.isNotBlank()) { "MYAPP_UPLOAD_STORE_FILE is missing" }
    require(storePass.isNotBlank()) { "MYAPP_UPLOAD_STORE_PASSWORD is missing" }
    require(keyAliasProp.isNotBlank()) { "MYAPP_UPLOAD_KEY_ALIAS is missing" }
    require(keyPass.isNotBlank()) { "MYAPP_UPLOAD_KEY_PASSWORD is missing" }

    // --- Your signing configuration goes here ---
    signingConfigs {
        create("release") {
            storeFile = file(storeFileProp)   // path to your .jks or .keystore
            storePassword = storePass
            keyAlias = keyAliasProp
            keyPassword = keyPass
        }
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            // Use the release signing config when building release
            signingConfig = signingConfigs.getByName("release")
        }

        // debug { } // usually keep default debug config
    }

    // (optional) Java/Kotlin options, buildFeatures, etc.
    // compileOptions { sourceCompatibility = JavaVersion.VERSION_17; targetCompatibility = JavaVersion.VERSION_17 }
    // kotlinOptions { jvmTarget = "17" }
}