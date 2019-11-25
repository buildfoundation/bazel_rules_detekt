workspace(name = "rules_detekt")

local_repository(
    name = "rules_detekt",
    path = ".",
)

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_file")

http_archive(
    name = "rules_java",
    url = "https://github.com/bazelbuild/rules_java/releases/download/0.1.0/rules_java-0.1.0.tar.gz",
    sha256 = "52423cb07384572ab60ef1132b0c7ded3a25c421036176c0273873ec82f5d2b2",
)

load("@rules_java//java:repositories.bzl", "remote_jdk11_repos")

remote_jdk11_repos()

http_file(
    name = "detekt_cli",
    urls = [
        "https://github.com/arturbosch/detekt/releases/download/1.0.1/detekt-cli-1.0.1-all.jar",
    ],
    sha256 = "7d84f61d3f9f8119addeac7a51542e101d7fc3051b4b82762d3b7baa3bbc309e",
)
