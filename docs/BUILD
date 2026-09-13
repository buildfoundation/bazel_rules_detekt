load("@bazel_skylib//:bzl_library.bzl", "bzl_library")
load("@io_bazel_stardoc//stardoc:stardoc.bzl", "stardoc")

bzl_library(
    name = "detekt_defs",
    srcs = [
        "//detekt:defs.bzl",
        "//detekt:toolchain.bzl",
    ],
    visibility = ["//docs:__pkg__"],
    deps = [
        "@rules_java//java:rules",
    ],
)

stardoc(
    name = "toolchain_docs",
    out = "toolchain_attrs.md",
    header_template = "//docs:header_template.vm",
    input = "//detekt:toolchain.bzl",
    rule_template = "//docs:rule_template.vm",
    symbol_names = ["detekt_toolchain"],
    deps = [
        ":detekt_defs",
        "@rules_java//java:rules",
        "@rules_java//java/private:proto_support",
    ],
)

stardoc(
    name = "docs",
    out = "attrs.md",
    header_template = "//docs:header_template.vm",
    input = "//detekt:defs.bzl",
    rule_template = "//docs:rule_template.vm",
    symbol_names = ["detekt"],
    deps = [
        ":detekt_defs",
        "@rules_java//java:rules",
        "@rules_java//java/private:proto_support",
    ],
)
