load("@rules_kotlin//kotlin:jvm.bzl", "kt_jvm_library")

package(default_visibility = ["//tests/integration:__pkg__"])

JVM_STATIC_SRCS = ["src/jvm/tests/integration/jvm/JvmStatic.kt"]

JVM_CLASSPATH_SRCS = ["src/jvm/tests/integration/jvm/JvmClasspath.kt"]

filegroup(
    name = "jvm_static_srcs",
    srcs = JVM_STATIC_SRCS,
)

filegroup(
    name = "jvm_classpath_srcs",
    srcs = JVM_CLASSPATH_SRCS,
)

kt_jvm_library(
    name = "jvm_static_lib",
    srcs = JVM_STATIC_SRCS,
)

kt_jvm_library(
    name = "jvm_api",
    srcs = ["src/jvm/tests/integration/jvm/JvmApi.kt"],
)

kt_jvm_library(
    name = "jvm_classpath_lib",
    srcs = JVM_CLASSPATH_SRCS,
    deps = [":jvm_api"],
)
