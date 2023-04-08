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

skylib_version = "1.4.1"

skylib_sha = "b8a1527901774180afc798aeb28c4634bdccf19c4d98e7bdd1ce79d1fe9aaad7"

http_archive(
    name = "bazel_skylib",
    sha256 = skylib_sha,
    url = "https://github.com/bazelbuild/bazel-skylib/releases/download/{v}/bazel-skylib-{v}.tar.gz".format(v = skylib_version),
)

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

# Documenting

## Stardoc

stardoc_version = "0.5.3"

stardoc_sha = "3fd8fec4ddec3c670bd810904e2e33170bedfe12f90adf943508184be458c8bb"

http_archive(
    name = "io_bazel_stardoc",
    sha256 = stardoc_sha,
    url = "https://github.com/bazelbuild/stardoc/releases/download/{v}/stardoc-{v}.tar.gz".format(v = stardoc_version),
)

load("@io_bazel_stardoc//:setup.bzl", "stardoc_repositories")

stardoc_repositories()

# Linting

## Buildifier

http_archive(
    name = "buildifier_prebuilt",
    sha256 = "e46c16180bc49487bfd0f1ffa7345364718c57334fa0b5b67cb5f27eba10f309",
    strip_prefix = "buildifier-prebuilt-6.1.0",
    url = "http://github.com/keith/buildifier-prebuilt/archive/6.1.0.tar.gz",
)

load("@buildifier_prebuilt//:deps.bzl", "buildifier_prebuilt_deps")

buildifier_prebuilt_deps()

load("@buildifier_prebuilt//:defs.bzl", "buildifier_prebuilt_register_toolchains")

buildifier_prebuilt_register_toolchains()
