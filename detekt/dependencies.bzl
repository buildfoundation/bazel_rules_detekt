"""
Macros for defining dependencies.
See https://docs.bazel.build/versions/master/skylark/deploying.html#dependencies
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def rules_detekt_dependencies():
    """Fetches `rules_detekt` dependencies.

    Declares dependencies of the `rules_detekt` workspace.
    Users should call this macro in their `WORKSPACE` file.
    """

    # Java

    rules_java_version = "0.1.1"
    rules_java_sha = "220b87d8cfabd22d1c6d8e3cdb4249abd4c93dcc152e0667db061fb1b957ee68"

    maybe(
        repo_rule = http_archive,
        name = "rules_java",
        url = "https://github.com/bazelbuild/rules_java/releases/download/{v}/rules_java-{v}.tar.gz".format(v = rules_java_version),
        sha256 = rules_java_sha,
    )

    # Kotlin

    rules_kotlin_version = "legacy-1.3.0-rc3"
    rules_kotlin_sha = "7cee5bd86d44ec7f643241197c28a2bced85614955adf0ed52a935296beb85b7"

    maybe(
        repo_rule = http_archive,
        name = "io_bazel_rules_kotlin",
        url = "https://github.com/bazelbuild/rules_kotlin/archive/{v}.tar.gz".format(v = rules_kotlin_version),
        strip_prefix = "rules_kotlin-{v}".format(v = rules_kotlin_version),
        sha256 = rules_kotlin_sha,
    )

    # JVM External

    rules_jvm_external_version = "3.0"
    rules_jvm_external_sha = "baa842cbc67aec78408aec3e480b2e94dbdd14d6b0170d3a3ee14a0e1a5bb95f"

    maybe(
        repo_rule = http_archive,
        name = "rules_jvm_external",
        url = "https://github.com/bazelbuild/rules_jvm_external/archive/{v}.tar.gz".format(v = rules_jvm_external_version),
        strip_prefix = "rules_jvm_external-{v}".format(v = rules_jvm_external_version),
        sha256 = rules_jvm_external_sha,
    )

    # Protocol Buffers

    rules_proto_version = "97d8af4dc474595af3900dd85cb3a29ad28cc313"
    rules_proto_sha = "602e7161d9195e50246177e7c55b2f39950a9cf7366f74ed5f22fd45750cd208"

    maybe(
        repo_rule = http_archive,
        name = "rules_proto",
        url = "https://github.com/bazelbuild/rules_proto/archive/{v}.tar.gz".format(v = rules_proto_version),
        strip_prefix = "rules_proto-{v}".format(v = rules_proto_version),
        sha256 = rules_proto_sha,
    )
