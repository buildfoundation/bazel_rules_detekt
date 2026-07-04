load("@bazel_skylib//:bzl_library.bzl", "bzl_library")
load("@io_bazel_stardoc//stardoc:stardoc.bzl", "stardoc")

exports_files(
    [
        "defs.bzl",
    ],
    visibility = ["//docs:__pkg__"],
)

bzl_library(
    name = "detekt_defs",
    srcs = ["//detekt:defs.bzl"],
    visibility = ["//docs:__pkg__"],
    deps = [
        "@rules_java//java:rules",
    ],
)

stardoc(
    name = "docs",
    out = "attrs.md",
    header_template = "//docs:header_template.vm",
    input = "//docs:defs.bzl",
    rule_template = "//docs:rule_template.vm",
    symbol_names = ["detekt"],
    deps = [
        ":detekt_defs",
        "@rules_java//java:rules",
        "@rules_java//java/private:proto_support",
    ],
)
