"""
Macros for defining dependencies.
See https://docs.bazel.build/versions/master/skylark/deploying.html#dependencies
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_jar")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load(":versions.bzl", _DEFAULT_DETEKT_VERSION = "DEFAULT_DETEKT_RELEASE")

def rules_detekt_dependencies(detekt = _DEFAULT_DETEKT_VERSION):
    """Fetches `rules_detekt` dependencies.

    Declares dependencies of the `rules_detekt` workspace.
    Users should call this macro in their `WORKSPACE` file.

    Args:
        detekt: The version of `detekt` to use. Defaults to the latest release.
    """

    # Detekt

    http_jar(
        name = "detekt_cli_all",
        sha256 = detekt.sha256,
        urls = [url.format(version = detekt.version) for url in detekt.url_templates],
    )

    # Bazel Worker API (proto definitions)
    maybe(
        http_archive,
        name = "bazel_worker_api",
        sha256 = "2c8fb93a29f2ff68a1ac3e6e89e5d21a7cc99c0f2afe6b9bfe4c4fe78f63a3c8",
        urls = ["https://github.com/nicholasphair/bazel-worker-api/releases/download/v0.0.10/bazel-worker-api-v0.0.10.tar.gz"],
        strip_prefix = "bazel-worker-api-0.0.10/proto",
    )

    # Bazel Worker Java (WorkRequestHandler, etc.)
    maybe(
        http_archive,
        name = "bazel_worker_java",
        sha256 = "2c8fb93a29f2ff68a1ac3e6e89e5d21a7cc99c0f2afe6b9bfe4c4fe78f63a3c8",
        urls = ["https://github.com/nicholasphair/bazel-worker-api/releases/download/v0.0.10/bazel-worker-api-v0.0.10.tar.gz"],
        strip_prefix = "bazel-worker-api-0.0.10/java",
    )

    # Protocol Buffers

    rules_proto_version = "5.3.0-21.7"
    rules_proto_sha = "dc3fb206a2cb3441b485eb1e423165b231235a1ea9b031b4433cf7bc1fa460dd"

    maybe(
        repo_rule = http_archive,
        name = "rules_proto",
        url = "https://github.com/bazelbuild/rules_proto/archive/{v}.tar.gz".format(v = rules_proto_version),
        strip_prefix = "rules_proto-{v}".format(v = rules_proto_version),
        sha256 = rules_proto_sha,
    )

    # Java

    rules_java_version = "8.15.2"
    rules_java_sha = "47632cc506c858011853073449801d648e10483d4b50e080ec2549a4b2398960"

    maybe(
        repo_rule = http_archive,
        name = "rules_java",
        url = "https://github.com/bazelbuild/rules_java/releases/download/{v}/rules_java-{v}.tar.gz".format(v = rules_java_version),
        sha256 = rules_java_sha,
    )

    # JVM External

    rules_jvm_external_version = "5.3"
    rules_jvm_external_sha = "d31e369b854322ca5098ea12c69d7175ded971435e55c18dd9dd5f29cc5249ac"

    maybe(
        repo_rule = http_archive,
        name = "rules_jvm_external",
        url = "https://github.com/bazelbuild/rules_jvm_external/releases/download/{v}/rules_jvm_external-{v}.tar.gz".format(v = rules_jvm_external_version),
        strip_prefix = "rules_jvm_external-{v}".format(v = rules_jvm_external_version),
        sha256 = rules_jvm_external_sha,
    )
