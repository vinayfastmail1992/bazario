// App-level build.gradle.kts

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("com.google.gms.google-services") // ✅ Firebase Plugin
}

android {
    namespace = "com.company.bazario" // ✅ यही namespace होनी चाहिए जो JSON में है
    compileSdk = 34

    defaultConfig {
        applicationId = "com.company.bazario" // ✅ Firebase से match करे
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.6.2")
    implementation("androidx.activity:activity-compose:1.8.2")
    implementation("com.google.firebase:firebase-analytics:21.6.1") // ✅ Firebase Analytics
    // Add more Firebase dependencies as needed (Auth, Firestore, etc.)
}
