workspace(name = "rules_detekt")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# Runtime

## Dependencies

load("//detekt:dependencies.bzl", "rules_detekt_dependencies")

rules_detekt_dependencies()

## Toolchains

load("//detekt:toolchains.bzl", "rules_detekt_toolchains")

rules_detekt_toolchains()

# Testing

## Skylib

skylib_version = "1.0.2"

skylib_sha = "97e70364e9249702246c0e9444bccdc4b847bed1eb03c5a3ece4f83dfe6abc44"

http_archive(
    name = "bazel_skylib",
    sha256 = skylib_sha,
    url = "https://github.com/bazelbuild/bazel-skylib/releases/download/{v}/bazel-skylib-{v}.tar.gz".format(v = skylib_version),
)

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

# Documenting

# Stardoc

stardoc_version = "0.4.0"

stardoc_sha = "6d07d18c15abb0f6d393adbd6075cd661a2219faab56a9517741f0fc755f6f3c"

http_archive(
    name = "io_bazel_stardoc",
    sha256 = stardoc_sha,
    strip_prefix = "stardoc-{v}".format(v = stardoc_version),
    url = "https://github.com/bazelbuild/stardoc/archive/{v}.tar.gz".format(v = stardoc_version),
)

load("@io_bazel_stardoc//:setup.bzl", "stardoc_repositories")

stardoc_repositories()
