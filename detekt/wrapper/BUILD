load("@rules_java//java:defs.bzl", "java_binary", "java_library", "java_test")

alias(
    name = "worker_protocol_java_proto",
    actual = "@bazel_tools//src/main/protobuf:worker_protocol_java_proto",
)

java_library(
    name = "wrapper",
    srcs = glob(["src/main/java/**/*.java"]),
    deps = [
        ":worker_protocol_java_proto",
        "@rules_detekt_dependencies//:io_gitlab_arturbosch_detekt_detekt_cli",
        "@rules_detekt_dependencies//:io_reactivex_rxjava3_rxjava",
    ],
)

java_binary(
    name = "bin",
    main_class = "io.buildfoundation.bazel.detekt.Main",
    visibility = ["//visibility:public"],
    runtime_deps = [":wrapper"],
)

java_test(
    name = "tests",
    srcs = glob([
        "src/test/java/**/*.java",
        "src/testFixtures/java/**/*.java",
    ]),
    test_class = "io.buildfoundation.bazel.detekt.TestsSuite",
    deps = [
        ":worker_protocol_java_proto",
        ":wrapper",
        "@rules_detekt_dependencies//:io_reactivex_rxjava3_rxjava",
        "@rules_detekt_dependencies//:junit_junit",
    ],
)
