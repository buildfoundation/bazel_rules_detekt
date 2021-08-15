load("@rules_detekt//utils:detekt_release.bzl", "detekt_release_pkg_tar")

detekt_release_pkg_tar(
    name = "rules_detekt_release",
    srcs = ["README.md", "LICENSE"],
    srcs_map = {
        "BUILD.release.bazel": "BUILD",
        "WORKSPACE.release.bazel": "WORKSPACE",
    },
    visibility = ["//visibility:public"],
    deps = [
        "//detekt:pkg",
    ],
)
