"""
Toolchain declaration.
"""

def _impl(ctx):
    toolchain = platform_common.ToolchainInfo(
        jvm_flags = ctx.attr.jvm_flags,
        experimental_type_resolution = ctx.attr.experimental_type_resolution,
        language_version = ctx.attr.language_version,
        jvm_target = ctx.attr.jvm_target,
    )

    return [toolchain]

detekt_toolchain = rule(
    implementation = _impl,
    attrs = {
        "jvm_flags": attr.string_list(
            default = ["-Xms16m", "-Xmx128m"],
            doc = "JVM flags used for Detekt execution.",
            allow_empty = False,
        ),
        "experimental_type_resolution": attr.bool(
            doc = """Flag for toggling experimental type resolution which is expected to be stable in
            the Detekt 2.x [see](https://detekt.github.io/detekt/type-resolution.html)
            """,
            default = True,
        ),
        "language_version": attr.string(
            doc = """Target version of the generated JVM bytecode that was generated during compilation and
            is now being used for type resolution [see](https://detekt.github.io/detekt/cli.html)
            """,
            default = "1.5",
            values = [
                "1.0",
                "1.1",
                "1.2",
                "1.3",
                "1.4",
                "1.5",
                "1.6",
                "1.7",
            ],
        ),
        "jvm_target": attr.string(
            doc = "Compatibility mode for Kotlin language version [see](https://detekt.github.io/detekt/cli.html)",
            default = "1.8",
            values = [
                "1.6",
                "1.8",
                "9",
                "10",
                "11",
                "12",
                "13",
                "14",
                "15",
                "16",
            ],
        ),
    },
)
