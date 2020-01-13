load("@io_bazel_rules_kotlin//kotlin:kotlin.bzl", "kt_jvm_library", "kt_jvm_test")
load("@rules_java//java:defs.bzl", "java_binary", "java_proto_library")
load("@rules_proto//proto:defs.bzl", "proto_library")

proto_library(
    name = "worker_protocol_proto",
    srcs = ["src/main/proto/worker_protocol.proto"],
)

java_proto_library(
    name = "worker_protocol_java_proto",
    deps = [":worker_protocol_proto"],
)

kt_jvm_library(
    name = "lib",
    srcs = glob(["src/main/kotlin/**/*.kt"]),
    deps = [
        ":worker_protocol_java_proto",
        "@rules_detekt_dependencies//:io_gitlab_arturbosch_detekt_detekt_cli",
        "@rules_detekt_dependencies//:io_reactivex_rxjava2_rxjava",
    ],
)

java_binary(
    name = "bin",
    main_class = "bazel.detekt.Main",
    visibility = ["//visibility:public"],
    runtime_deps = [":lib"],
)

kt_jvm_test(
    name = "tests",
    srcs = glob([
        "src/test/kotlin/**/*.kt",
        "src/testFixtures/kotlin/**/*.kt",
    ]),
    friends = [":lib"],
    test_class = "bazel.detekt.TestsSuite",
    deps = [
        ":lib",
        "@rules_detekt_dependencies//:junit_junit",
    ],
)
