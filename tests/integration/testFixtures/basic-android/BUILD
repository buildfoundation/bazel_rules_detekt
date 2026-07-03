load("@rules_kotlin//kotlin:android.bzl", "kt_android_library")

package(default_visibility = ["//tests/integration:__pkg__"])

ANDROID_STATIC_SRCS = ["src/android/tests/integration/android/AndroidStatic.kt"]

ANDROID_CLASSPATH_SRCS = ["src/android/tests/integration/android/AndroidClasspath.kt"]

filegroup(
    name = "android_static_srcs",
    srcs = ANDROID_STATIC_SRCS,
)

filegroup(
    name = "android_classpath_srcs",
    srcs = ANDROID_CLASSPATH_SRCS,
)

kt_android_library(
    name = "android_static_lib",
    srcs = ANDROID_STATIC_SRCS,
    custom_package = "tests.integration.android",
    manifest = "AndroidManifest.xml",
)

kt_android_library(
    name = "android_api",
    srcs = ["src/android/tests/integration/android/AndroidApi.kt"],
    custom_package = "tests.integration.android",
    manifest = "AndroidManifest.xml",
)

kt_android_library(
    name = "android_classpath_lib",
    srcs = ANDROID_CLASSPATH_SRCS,
    custom_package = "tests.integration.android",
    manifest = "AndroidManifest.xml",
    deps = [":android_api"],
)
