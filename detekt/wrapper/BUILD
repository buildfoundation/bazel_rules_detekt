load("@rules_java//java:defs.bzl", "java_binary", "java_library", "java_test")
load("@rules_pmd//pmd:defs.bzl", "pmd_test")

java_library(
    name = "wrapper",
    srcs = glob(["src/main/java/**/*.java"]),
    deps = [
        "@bazel_worker_java//src/main/java/com/google/devtools/build/lib/worker:work_request_handlers",
        "@detekt_cli_all//jar",
    ],
)

pmd_test(
    name = "wrapper_pmd_test",
    srcs = glob(["src/main/java/**/*.java"]),
    rulesets = ["//:pmd_ruleset.xml"],
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

pmd_test(
    name = "tests_pmd_test",
    srcs = glob([
        "src/test/java/**/*.java",
        "src/testFixtures/java/**/*.java",
    ]),
    rulesets = ["//:pmd_ruleset.xml"],
)
