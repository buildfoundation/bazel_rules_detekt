"""
Toolchain declaration.
"""

def _impl(ctx):
    toolchain = platform_common.ToolchainInfo(
        jvm_flags = ctx.attr.jvm_flags,
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
        "language_version": attr.string(
            doc = "Compatibility mode for Kotlin language version X.Y, reports errors for all language features that came out later.",
            default = "2.3",
            values = ["1.0", "1.1", "1.2", "1.3", "1.4", "1.5", "1.6", "1.7", "1.8", "1.9", "2.0", "2.1", "2.2", "2.3"],
        ),
        "jvm_target": attr.string(
            doc = "Target version of the generated JVM bytecode that was generated during compilation and is now being used for type resolution.",
            default = "1.8",
            values = ["1.8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24"],
        ),
    },
)
