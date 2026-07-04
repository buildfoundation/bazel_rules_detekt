load("@rules_detekt//detekt:defs.bzl", "detekt_test")
load("@rules_detekt//detekt:toolchain.bzl", "detekt_toolchain")

detekt_toolchain(
    name = "smoke_toolchain_impl",
    fail_on_severity = "Never",
    jvm_target = "11",
    parallel = True,
)

detekt_test(
    name = "smoke_test",
    srcs = ["Smoke.kt"],
    detekt_toolchain = ":smoke_toolchain_impl",
)

detekt_test(
    name = "expected_failure_test",
    srcs = ["Smoke.kt"],
    all_rules = True,
    detekt_toolchain = ":smoke_toolchain_impl",
    fail_on_severity = "Warning",
    jvm_target = "1.8",
    parallel = False,
    tags = ["manual"],
)
