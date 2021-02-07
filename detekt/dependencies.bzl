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

    rules_java_version = "4.0.0"
    rules_java_sha = "34b41ec683e67253043ab1a3d1e8b7c61e4e8edefbcad485381328c934d072fe"

    maybe(
        repo_rule = http_archive,
        name = "rules_java",
        url = "https://github.com/bazelbuild/rules_java/releases/download/{v}/rules_java-{v}.tar.gz".format(v = rules_java_version),
        sha256 = rules_java_sha,
    )

    # JVM External

    rules_jvm_external_version = "4.0"
    rules_jvm_external_sha = "31d226a6b3f5362b59d261abf9601116094ea4ae2aa9f28789b6c105e4cada68"

    maybe(
        repo_rule = http_archive,
        name = "rules_jvm_external",
        url = "https://github.com/bazelbuild/rules_jvm_external/archive/{v}.tar.gz".format(v = rules_jvm_external_version),
        strip_prefix = "rules_jvm_external-{v}".format(v = rules_jvm_external_version),
        sha256 = rules_jvm_external_sha,
    )
