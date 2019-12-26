"""
Toolchain declaration.
"""

def _impl(ctx):
    toolchain = platform_common.ToolchainInfo(
        jvm_flags = ctx.attr.jvm_flags,
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
    },
)
