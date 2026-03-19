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
    doc = "Defines a Detekt toolchain, configuring the JVM settings used when running Detekt.",
    implementation = _impl,
    attrs = {
        "jvm_flags": attr.string_list(
            default = ["-Xms16m", "-Xmx128m"],
            doc = "JVM flags used for Detekt execution.",
            allow_empty = False,
        ),
        "language_version": attr.string(
            doc = "Kotlin language version compatibility mode. Detekt reports errors for language features introduced after the specified version.",
            default = "2.0",
            values = ["1.0", "1.1", "1.2", "1.3", "1.4", "1.5", "1.6", "1.7", "1.8", "1.9", "2.0", "2.1", "2.2"],
        ),
        "jvm_target": attr.string(
            doc = "Target JVM bytecode version used by Detekt during analysis.",
            default = "1.8",
            values = ["1.8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20"],
        ),
    },
)
