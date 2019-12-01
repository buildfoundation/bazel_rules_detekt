workspace(name = "rules_detekt")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_file")

http_archive(
    name = "rules_java",
    sha256 = "52423cb07384572ab60ef1132b0c7ded3a25c421036176c0273873ec82f5d2b2",
    url = "https://github.com/bazelbuild/rules_java/releases/download/0.1.0/rules_java-0.1.0.tar.gz",
)

load("@rules_java//java:repositories.bzl", "remote_jdk11_repos")

remote_jdk11_repos()

http_file(
    # Name is specifically _jar because we want to add JVM Persistent Worker support,
    # thus we rely on binary to be .jar rather than some sort of executable.
    name = "detekt_cli_jar",
    sha256 = "e9710fb9260c0824b3a9ae7d8326294ab7a01af68cfa510cab66de964da80862",
    urls = [
        # TODO: Add more mirrors, JCenter/Bintray is notoriously bad with 5xx and all sorts of timeouts.
        "https://jcenter.bintray.com/io/gitlab/arturbosch/detekt/detekt-cli/1.2.0/detekt-cli-1.2.0-all.jar",
    ],
)

rules_kotlin_version = "legacy-1.3.0-rc1"

rules_kotlin_sha = "9de078258235ea48021830b1669bbbb678d7c3bdffd3435f4c0817c921a88e42"

http_archive(
    name = "io_bazel_rules_kotlin",
    sha256 = rules_kotlin_sha,
    strip_prefix = "rules_kotlin-%s" % rules_kotlin_version,
    type = "zip",
    urls = ["https://github.com/bazelbuild/rules_kotlin/archive/%s.zip" % rules_kotlin_version],
)

load("@io_bazel_rules_kotlin//kotlin:kotlin.bzl", "kotlin_repositories", "kt_register_toolchains")

kotlin_repositories()

kt_register_toolchains()
