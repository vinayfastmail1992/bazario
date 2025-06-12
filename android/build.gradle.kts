// Project-level build.gradle.kts

buildscript {
    dependencies {
        // Add Google Services plugin classpath here if needed for older Gradle
    }
}

plugins {
    id("com.android.application") version "8.3.1" apply false
    id("org.jetbrains.kotlin.android") version "1.9.22" apply false
    id("com.google.gms.google-services") version "4.4.2" apply false // ✅ Firebase Plugin
}


signingConfigs {
    create("release") {
        storeFile = file("../bazario.jks")
        storePassword = "yourpassword"
        keyAlias = "bazario"
        keyPassword = "yourpassword"
    }
}

buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
        isMinifyEnabled = false
        proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
    }
}
