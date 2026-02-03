load("@rules_java//java:defs.bzl", "java_test")
load("@rules_pmd//pmd:defs.bzl", "pmd_test")

java_test(
    name = "tests",
    srcs = glob([
        "src/test/java/**/*.java",
        "src/testFixtures/java/**/*.java",
    ]),
    test_class = "io.buildfoundation.bazel.detekt.TestsSuite",
    deps = [
        "//detekt/wrapper",
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
