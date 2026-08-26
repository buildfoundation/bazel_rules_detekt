load("@rules_detekt//detekt:defs.bzl", "detekt_test")

detekt_test(
    name = "smoke_test",
    srcs = ["Smoke.kt"],
)

detekt_test(
    name = "expected_failure_test",
    srcs = ["Smoke.kt"],
    all_rules = True,
    fail_on_severity = "Warning",
    tags = ["manual"],
)
