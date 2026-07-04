"""
Toolchain declaration.
"""

load("@rules_java//java:defs.bzl", "JavaInfo")

def _impl(ctx):
    toolchain = platform_common.ToolchainInfo(
        build_upon_default_config = ctx.attr.build_upon_default_config,
        cfgs = ctx.files.cfgs,
        detekt_wrapper = ctx.attr.detekt_wrapper,
        disable_default_rulesets = ctx.attr.disable_default_rulesets,
        jvm_target = ctx.attr.jvm_target,
        language_version = ctx.attr.language_version,
        max_issues = ctx.attr.max_issues,
        parallel = ctx.attr.parallel,
        plugins = ctx.files.plugins,
    )

    return [toolchain]

detekt_toolchain = rule(
    implementation = _impl,
    attrs = {
        "build_upon_default_config": attr.bool(
            default = False,
        ),
        "cfgs": attr.label_list(
            default = [],
            allow_files = [".yml"],
        ),
        "detekt_wrapper": attr.label(
            default = Label("//detekt/wrapper:bin"),
            executable = True,
            cfg = "exec",
        ),
        "disable_default_rulesets": attr.bool(
            default = False,
        ),
        "jvm_target": attr.string(
            default = "1.8",
            values = ["1.8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20"],
        ),
        "language_version": attr.string(
            default = "",
            values = ["", "1.0", "1.1", "1.2", "1.3", "1.4", "1.5", "1.6", "1.7", "1.8", "1.9", "2.0", "2.1", "2.2"],
        ),
        "max_issues": attr.int(
            default = -1,
        ),
        "parallel": attr.bool(
            default = False,
        ),
        "plugins": attr.label_list(
            default = [],
            providers = [JavaInfo],
        ),
    },
)
