load("//detekt:toolchain.bzl", "detekt_toolchain")
load(":tests.bzl", "test_suite")

# This toolchain is only selected by analysis tests; it mocks toolchain defaults
# so the test can assert the rule forwards them into Detekt arguments.
detekt_toolchain(
    name = "custom_defaults_toolchain_impl",
    build_upon_default_config = True,
    cfgs = ["config A.yml"],
    disable_default_rulesets = True,
    jvm_target = "17",
    language_version = "1.9",
    max_issues = 3,
    parallel = True,
    plugins = ["@detekt_cli_all//jar"],
)

toolchain(
    name = "custom_defaults_toolchain",
    toolchain = ":custom_defaults_toolchain_impl",
    toolchain_type = "//detekt:toolchain_type",
)

test_suite(
    name = "tests",
)
