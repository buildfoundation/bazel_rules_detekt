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

    rules_kotlin_version = "legacy-1.3.0"
    rules_kotlin_sha = "2ba27f0fa8305a28bc1b9b3a3f4e6b91064b3c0021365fa9344ba3af88657e1b"

    maybe(
        repo_rule = http_archive,
        name = "io_bazel_rules_kotlin",
        url = "https://github.com/bazelbuild/rules_kotlin/archive/{v}.tar.gz".format(v = rules_kotlin_version),
        strip_prefix = "rules_kotlin-{v}".format(v = rules_kotlin_version),
        sha256 = rules_kotlin_sha,
    )

    # JVM External

    rules_jvm_external_version = "3.1"
    rules_jvm_external_sha = "19c5c43a84d3c631a047b8e499b00b3ffca2e6784a1e4abfe2facdf865951e43"

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
