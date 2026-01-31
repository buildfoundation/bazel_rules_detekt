load("@rules_java//java:defs.bzl", "java_binary", "java_library", "java_test")

java_library(
    name = "wrapper",
    srcs = glob(["src/main/java/**/*.java"]),
    deps = [
        "@bazel_worker_java//src/main/java/com/google/devtools/build/lib/worker:work_request_handlers",
        "@detekt_cli_all//jar",
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
        "@rules_detekt_dependencies//:junit_junit",
    ],
)
