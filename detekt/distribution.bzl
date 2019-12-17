"""
A macro for changing Detekt distribution.
"""

load("@rules_jvm_external//:defs.bzl", _maven_install = "maven_install")

def detekt_distribution(version = "1.2.2"):
    _maven_install(
        artifacts = [
            "io.gitlab.arturbosch.detekt:detekt-cli:{v}".format(v = version),
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
