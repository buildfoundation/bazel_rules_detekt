load("@rules_detekt//detekt:defs.bzl", "detekt_test")
load("@rules_kotlin//kotlin:jvm.bzl", "kt_jvm_library")

package(default_visibility = ["//visibility:public"])

detekt_test(
    name = "compat_v1_test",
    srcs = ["src/Compat.kt"],
    base_path = ".",
    cfgs = ["detekt.yml"],
    max_issues = 1,
    plugins = [":custom_rules"],
    txt_report = True,
    xml_report = True,
)

kt_jvm_library(
    name = "custom_rules",
    srcs = glob(["custom_rules/src/main/kotlin/**/*.kt"]),
    resources = glob(["custom_rules/src/main/resources/**"]),
    deps = ["@detekt_cli_all//jar"],
)
