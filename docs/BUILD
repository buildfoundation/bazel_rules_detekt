load("@io_bazel_stardoc//stardoc:stardoc.bzl", "stardoc")

_DOCS = [
    "defs",
    "toolchain",
    "toolchains",
    "versions",
]

stardoc(
    name = "defs",
    out = "defs.md",
    header_template = "//docs:header_template.vm",
    input = "//detekt:defs.bzl",
    tags = ["manual"],
    deps = [
        "@rules_android//providers:providers.bzl",
        "@rules_android//rules:utils.bzl",
        "@rules_android//rules:visibility.bzl",
        "@rules_java//java:rules",
        "@rules_java//java/private:proto_support",
    ],
)

stardoc(
    name = "toolchain",
    out = "toolchain.md",
    header_template = "//docs:header_template.vm",
    input = "//detekt:toolchain.bzl",
    tags = ["manual"],
)

stardoc(
    name = "toolchains",
    out = "toolchains.md",
    header_template = "//docs:header_template.vm",
    input = "//detekt:toolchains.bzl",
    tags = ["manual"],
)

stardoc(
    name = "versions",
    out = "versions.md",
    header_template = "//docs:header_template.vm",
    input = "//detekt:versions.bzl",
    tags = ["manual"],
)

genrule(
    name = "docs",
    srcs = [":" + doc for doc in _DOCS],
    outs = ["rules_detekt.md.generated"],
    cmd = "cat $(SRCS) > $@",
    tags = ["manual"],
)
