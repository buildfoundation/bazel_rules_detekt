"""Detekt executable selection and default configuration."""

load(":config.bzl", "DetektConfigInfo")

def _impl(ctx):
    return [platform_common.ToolchainInfo(
        default_config = ctx.attr.default_config[DetektConfigInfo],
        detekt_wrapper = ctx.attr.detekt_wrapper[DefaultInfo],
    )]

detekt_toolchain = rule(
    implementation = _impl,
    attrs = {
        "default_config": attr.label(
            default = Label("//detekt:default_config"),
            providers = [DetektConfigInfo],
            doc = "Analysis configuration used when a Detekt target omits config.",
        ),
        "detekt_wrapper": attr.label(
            default = Label("//detekt/wrapper:bin"),
            executable = True,
            cfg = "exec",
            doc = "Executable wrapper used to run Detekt.",
        ),
    },
)
