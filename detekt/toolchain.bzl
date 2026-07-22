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
            doc = "Default value for the build_upon_default_config rule attribute.",
        ),
        "cfgs": attr.label_list(
            default = [],
            allow_files = [".yml"],
            doc = "Default config files used when a rule does not set cfgs.",
        ),
        "detekt_wrapper": attr.label(
            default = Label("//detekt/wrapper:bin"),
            executable = True,
            cfg = "exec",
            doc = "Executable wrapper used to run Detekt.",
        ),
        "disable_default_rulesets": attr.bool(
            default = False,
            doc = "Default value for the disable_default_rulesets rule attribute.",
        ),
        "jvm_target": attr.string(
            default = "1.8",
            values = ["1.8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20"],
            doc = "Default JVM bytecode target used when a rule does not set jvm_target.",
        ),
        "language_version": attr.string(
            default = "",
            values = ["", "1.0", "1.1", "1.2", "1.3", "1.4", "1.5", "1.6", "1.7", "1.8", "1.9", "2.0", "2.1", "2.2"],
            doc = "Default Kotlin language version used when a rule does not set language_version.",
        ),
        "max_issues": attr.int(
            default = -1,
            doc = "Default max issues threshold used when a rule does not set max_issues.",
        ),
        "parallel": attr.bool(
            default = False,
            doc = "Default value for the parallel rule attribute.",
        ),
        "plugins": attr.label_list(
            default = [],
            providers = [JavaInfo],
            doc = "Default plugin targets used when a rule does not set plugins.",
        ),
    },
)
