load("//detekt:config.bzl", "detekt_config")
load("//detekt:toolchain.bzl", "detekt_toolchain")

detekt_config(
    name = "default_config",
    visibility = ["//visibility:public"],
)

toolchain_type(
    name = "toolchain_type",
    visibility = ["//visibility:public"],
)

detekt_toolchain(
    name = "default_toolchain_impl",
)

toolchain(
    name = "default_toolchain",
    toolchain = ":default_toolchain_impl",
    toolchain_type = "//detekt:toolchain_type",
)

exports_files([
    "config.bzl",
    "defs.bzl",
    "result_script.sh.tpl",
    "toolchain.bzl",
])
