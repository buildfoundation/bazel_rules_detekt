"""
Macros for defining toolchains.
See https://docs.bazel.build/versions/master/skylark/deploying.html#registering-toolchains
"""

load("@io_bazel_rules_kotlin//kotlin:kotlin.bzl", "kotlin_repositories", "kt_register_toolchains")
load("@rules_java//java:repositories.bzl", "rules_java_dependencies", "rules_java_toolchains")
load("@rules_jvm_external//:defs.bzl", "maven_install")
load("@rules_jvm_external//:specs.bzl", "maven")
load("@rules_proto//proto:repositories.bzl", "rules_proto_dependencies", "rules_proto_toolchains")

# buildifier: disable=unnamed-macro
def rules_detekt_toolchains(detekt_version = "1.10.0", toolchain = "@rules_detekt//detekt:default_toolchain"):
    """Invokes `rules_detekt` toolchains.

    Declares toolchains that are dependencies of the `rules_detekt` workspace.
    Users should call this macro in their `WORKSPACE` file.

    Args:
        detekt_version: "io.gitlab.arturbosch.detekt:detekt-cli" version used by rules.
        toolchain: `detekt_toolchain` used by rules.
    """

    rules_java_dependencies()
    rules_java_toolchains()

    kotlin_repositories()
    kt_register_toolchains()

    rules_proto_dependencies()
    rules_proto_toolchains()

    native.register_toolchains(toolchain)

    maven_install(
        name = "rules_detekt_dependencies",
        artifacts = [
            maven.artifact("io.gitlab.arturbosch.detekt", "detekt-cli", detekt_version),
            maven.artifact("io.gitlab.arturbosch.detekt", "detekt-formatting", detekt_version),
            maven.artifact("io.reactivex.rxjava3", "rxjava", "3.0.6"),
            # TODO: rollback "testonly = true" once JVM External resolves transitive test dependencies properly.
            maven.artifact("junit", "junit", "4.13"),
        ],
        repositories = [
            "https://repo1.maven.org/maven2",
            "https://jcenter.bintray.com/",
        ],
        excluded_artifacts = [
            "org.jetbrains.kotlin:kotlin-reflect",
            "org.jetbrains.kotlin:kotlin-stdlib",
        ],
    )
