workspace(name = "rules_detekt")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

# Runtime

## Dependencies

### Java
rules_java_version = "0.1.1"

rules_java_sha = "220b87d8cfabd22d1c6d8e3cdb4249abd4c93dcc152e0667db061fb1b957ee68"

maybe(
    name = "rules_java",
    repo_rule = http_archive,
    sha256 = rules_java_sha,
    url = "https://github.com/bazelbuild/rules_java/releases/download/{v}/rules_java-{v}.tar.gz".format(v = rules_java_version),
)

### JVM External
rules_jvm_external_version = "3.0"

rules_jvm_external_sha = "baa842cbc67aec78408aec3e480b2e94dbdd14d6b0170d3a3ee14a0e1a5bb95f"

maybe(
    name = "rules_jvm_external",
    repo_rule = http_archive,
    sha256 = rules_jvm_external_sha,
    strip_prefix = "rules_jvm_external-{v}".format(v = rules_jvm_external_version),
    url = "https://github.com/bazelbuild/rules_jvm_external/archive/{v}.tar.gz".format(v = rules_jvm_external_version),
)

### Protocol Buffers
rules_proto_version = "97d8af4dc474595af3900dd85cb3a29ad28cc313"

rules_proto_sha = "602e7161d9195e50246177e7c55b2f39950a9cf7366f74ed5f22fd45750cd208"

maybe(
    name = "rules_proto",
    repo_rule = http_archive,
    sha256 = rules_proto_sha,
    strip_prefix = "rules_proto-{v}".format(v = rules_proto_version),
    url = "https://github.com/bazelbuild/rules_proto/archive/{v}.tar.gz".format(v = rules_proto_version),
)

### Kotlin
rules_kotlin_version = "legacy-1.3.0-rc3"

rules_kotlin_sha = "7cee5bd86d44ec7f643241197c28a2bced85614955adf0ed52a935296beb85b7"

maybe(
    name = "io_bazel_rules_kotlin",
    repo_rule = http_archive,
    sha256 = rules_kotlin_sha,
    strip_prefix = "rules_kotlin-{v}".format(v = rules_kotlin_version),
    url = "https://github.com/bazelbuild/rules_kotlin/archive/{v}.tar.gz".format(v = rules_kotlin_version),
)

## Toolchains

load("//detekt:defs.bzl", "rules_detekt_toolchains")

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

## Stardoc

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
