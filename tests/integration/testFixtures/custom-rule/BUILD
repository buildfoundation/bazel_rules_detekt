load("@rules_kotlin//kotlin:jvm.bzl", "kt_jvm_library")

package(default_visibility = ["//tests/integration:__pkg__"])

filegroup(
    name = "custom_rule_violation_srcs",
    srcs = ["src/custom/tests/integration/custom/CustomRuleViolation.kt"],
)

filegroup(
    name = "custom_rule_config",
    srcs = ["detekt_custom_rule.yml"],
)

kt_jvm_library(
    name = "custom_rules",
    srcs = glob(["custom_rules/src/main/kotlin/**/*.kt"]),
    resources = glob(["custom_rules/src/main/resources/**"]),
    deps = ["@detekt_cli_all//jar"],
)
