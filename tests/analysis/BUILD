load("@rules_java//java:defs.bzl", "java_library")
load("//detekt:config.bzl", "detekt_config")
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

detekt_config(
    name = "config_a",
    build_upon_default_config = True,
    cfgs = ["config A.yml"],
    disable_default_rulesets = True,
    jvm_target = "17",
    language_version = "1.9",
    max_issues = 3,
    parallel = True,
    plugins = [":analysis_plugin"],
)

detekt_config(
    name = "config_b",
    cfgs = ["config B.yml"],
    fail_on_severity = "Warning",
    jvm_target = "11",
    language_version = "1.8",
)

detekt_config(name = "empty_config")

detekt_config(
    name = "target_config",
    jvm_target = select({
        ":target_fastbuild": "17",
        "//conditions:default": "11",
    }),
)

config_setting(
    name = "target_fastbuild",
    values = {"compilation_mode": "fastbuild"},
)

detekt_toolchain(
    name = "target_config_toolchain_impl",
    default_config = ":target_config",
)

toolchain(
    name = "target_config_toolchain",
    toolchain = ":target_config_toolchain_impl",
    toolchain_type = "//detekt:toolchain_type",
)

detekt_toolchain(
    name = "toolchain_a_impl",
    default_config = ":config_a",
    detekt_wrapper = ":custom_wrapper_bin",
)

detekt_toolchain(
    name = "toolchain_b_impl",
    default_config = ":config_b",
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
