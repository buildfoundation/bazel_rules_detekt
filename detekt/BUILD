load("//detekt:toolchain.bzl", "detekt_toolchain")
load("@rules_detekt//utils:detekt_release.bzl", "detekt_release_pkg_tar")

exports_files(["defs.bzl"])

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

detekt_release_pkg_tar(
    name = "pkg",
    srcs = [
        "defs.bzl",
        "toolchain.bzl",
        "versions.bzl",
    ],
    package_dir = "detekt",
    srcs_map = {
        "BUILD.release.bazel": "BUILD",
        "dependencies.release.bzl": "dependencies.bzl",
        "toolchains.release.bzl": "toolchains.bzl",
    },
    visibility = ["//visibility:public"],
    deps = ["//detekt/wrapper:pkg"],
)
