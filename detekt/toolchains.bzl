"""
Macros for defining toolchains.
See https://docs.bazel.build/versions/master/skylark/deploying.html#registering-toolchains
"""

load("@rules_jvm_external//:defs.bzl", "maven_install")
load("@rules_jvm_external//:specs.bzl", "maven")

# buildifier: disable=unnamed-macro
def rules_detekt_toolchains(toolchain = "@rules_detekt//detekt:default_toolchain"):
    """Invokes `rules_detekt` toolchains.

    Declares toolchains that are dependencies of the `rules_detekt` workspace.
    Users should call this macro in their `WORKSPACE` file.

    Args:
        toolchain: `detekt_toolchain` used by rules.
    """
    native.register_toolchains(toolchain)

    maven_install(
        name = "rules_detekt_dependencies",
        artifacts = [
            maven.artifact("junit", "junit", "4.13.2", testonly = True),
            maven.artifact("io.gitlab.arturbosch.detekt", "detekt-cli", "1.23.1", testonly = True),
        ],
        repositories = [
            "https://repo1.maven.org/maven2",
        ],
    )
