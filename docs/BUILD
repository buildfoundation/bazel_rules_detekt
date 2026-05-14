load("@io_bazel_stardoc//stardoc:stardoc.bzl", "stardoc")

stardoc(
    name = "docs",
    out = "attrs.md",
    header_template = "//docs:header_template.vm",
    input = "//detekt:defs.bzl",
    rule_template = "//docs:rule_template.vm",
    symbol_names = ["detekt"],
    deps = [
        "@rules_java//java:rules",
        "@rules_java//java/private:proto_support",
    ],
)
