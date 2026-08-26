load("@rules_java//java:defs.bzl", "java_library")
load("//detekt:toolchain.bzl", "detekt_toolchain")
load(":tests.bzl", "test_suite")

java_library(
    name = "analysis_plugin",
    srcs = ["AnalysisPlugin.java"],
)

genrule(
    name = "custom_wrapper_bin",
    outs = ["custom_detekt_wrapper"],
    cmd = "printf '#!/bin/sh\\nexit 0\\n' > $@ && chmod +x $@",
    executable = True,
)

detekt_toolchain(
    name = "toolchain_a_impl",
    build_upon_default_config = True,
    cfgs = ["config A.yml"],
    detekt_wrapper = ":custom_wrapper_bin",
    disable_default_rulesets = True,
    jvm_target = "17",
    language_version = "1.9",
    max_issues = 3,
    parallel = True,
    plugins = [":analysis_plugin"],
)

detekt_toolchain(
    name = "toolchain_b_impl",
    cfgs = ["config B.yml"],
    fail_on_severity = "Warning",
    jvm_target = "11",
    language_version = "1.8",
)

toolchain(
    name = "custom_defaults_toolchain",
    toolchain = ":toolchain_a_impl",
    toolchain_type = "//detekt:toolchain_type",
)

config_setting(
    name = "select_toolchain_b",
    values = {"compilation_mode": "opt"},
)

test_suite(
    name = "tests",
)
