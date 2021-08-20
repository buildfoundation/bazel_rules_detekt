"""
Macros for defining prebuilt release dependencies.
See https://docs.bazel.build/versions/master/skylark/deploying.html#dependencies
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def rules_detekt_dependencies(detekt_cli_all_release = versions.DETEKT_CLI_ALL_RELEASE):
    """Fetches `rules_detekt` dependencies.

    Declares dependencies of the `rules_detekt` workspace.
    Users should call this macro in their `WORKSPACE` file.

    Args:
        detekt_cli_all_release: "detekt_cli_all" URL and download link.
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

    # Detekt CLI

    maybe(
        repo_rule = http_jar,
        name = "rules_detekt_detekt_cli",
        urls = detekt_cli_all_release["urls"],
        sha256 = detekt_cli_all_release["sha256"],
    )

    # JVM External

    rules_jvm_external_version = "4.1"
    rules_jvm_external_sha = "995ea6b5f41e14e1a17088b727dcff342b2c6534104e73d6f06f1ae0422c2308"

    maybe(
        repo_rule = http_archive,
        name = "rules_jvm_external",
        url = "https://github.com/bazelbuild/rules_jvm_external/archive/{v}.tar.gz".format(v = rules_jvm_external_version),
        strip_prefix = "rules_jvm_external-{v}".format(v = rules_jvm_external_version),
        sha256 = rules_jvm_external_sha,
    )