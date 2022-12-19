load("@rules_java//java:defs.bzl", "java_binary", "java_library", "java_test")

java_library(
    name = "wrapper",
    srcs = glob(["src/main/java/**/*.java"]),
    deps = [
        "@rules_detekt_dependencies//:com_squareup_moshi_moshi",
        "@rules_detekt_dependencies//:com_squareup_okio_okio_jvm",
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
        ":wrapper",
        "@rules_detekt_dependencies//:com_squareup_okio_okio_jvm",
        "@rules_detekt_dependencies//:io_reactivex_rxjava3_rxjava",
        "@rules_detekt_dependencies//:junit_junit",
    ],
)
