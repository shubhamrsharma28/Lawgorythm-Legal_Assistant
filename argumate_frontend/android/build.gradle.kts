// argumate_frontend/android/build.gradle.kts
plugins {
    id("com.android.application") apply false
    id("dev.flutter.flutter-gradle-plugin") apply false
    id("org.jetbrains.kotlin.android") apply false
    // Add the Google Services plugin to the plugins block
    id("com.google.gms.google-services") version "4.4.1" apply false // <--- ADD THIS LINE
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}