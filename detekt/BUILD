load("//detekt:toolchain.bzl", "detekt_toolchain")
load("@io_bazel_stardoc//stardoc:stardoc.bzl", "stardoc")

toolchain_type(
    name = "toolchain_type",
)

detekt_toolchain(
    name = "default_toolchain_impl",
)

toolchain(
    name = "default_toolchain",
    toolchain = ":default_toolchain_impl",
    toolchain_type = "//detekt:toolchain_type",
)

stardoc(
    name = "docs",
    out = "rule.md",
    input = "defs.bzl",
    rule_template = "//docs:rule_template.vm",
)
