load("@io_bazel_stardoc//stardoc:stardoc.bzl", "stardoc")

stardoc(
    name = "docs",
    out = "rule.md",
    input = "//detekt:defs.bzl",
    rule_template = "//docs:rule_template.vm",
)
