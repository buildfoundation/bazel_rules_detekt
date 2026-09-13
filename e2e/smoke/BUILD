load("@rules_detekt//detekt:config.bzl", "detekt_config")
load("@rules_detekt//detekt:defs.bzl", "detekt_test")

detekt_config(
    name = "smoke_config",
    fail_on_severity = "Never",
    jvm_target = "11",
    parallel = True,
)

detekt_test(
    name = "smoke_test",
    srcs = ["Smoke.kt"],
    config = ":smoke_config",
)

detekt_config(
    name = "strict_config",
    fail_on_severity = "Warning",
    jvm_target = "1.8",
    parallel = False,
)

detekt_test(
    name = "expected_failure_test",
    srcs = ["Smoke.kt"],
    all_rules = True,
    config = ":strict_config",
    tags = ["manual"],
)
