"""
Toolchain declaration.
"""

load("@rules_java//java:defs.bzl", "JavaInfo")

def _impl(ctx):
    if ctx.attr.max_issues >= 0 and ctx.attr.fail_on_severity:
        fail("max_issues and fail_on_severity cannot both be enabled on a detekt toolchain")

    toolchain = platform_common.ToolchainInfo(
        build_upon_default_config = ctx.attr.build_upon_default_config,
        cfgs = ctx.files.cfgs,
        detekt_wrapper = ctx.attr.detekt_wrapper[DefaultInfo],
        disable_default_rulesets = ctx.attr.disable_default_rulesets,
        fail_on_severity = ctx.attr.fail_on_severity,
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
            doc = "Use Detekt's built-in configuration as a base for the supplied configuration files.",
        ),
        "cfgs": attr.label_list(
            default = [],
            allow_files = [".yml"],
            doc = "Configuration files for rules using this toolchain.",
        ),
        "detekt_wrapper": attr.label(
            default = Label("//detekt/wrapper:bin"),
            executable = True,
            cfg = "exec",
            doc = "Executable wrapper used to run Detekt.",
        ),
        "disable_default_rulesets": attr.bool(
            default = False,
            doc = "Disable Detekt's default rule sets, using only rule sets supplied by plugins.",
        ),
        "fail_on_severity": attr.string(
            default = "",
            doc = "Detekt 2.x failure threshold (Error, Warning, Info, or Never). Empty string uses the runtime default. Mutually exclusive with an active max_issues threshold.",
        ),
        "jvm_target": attr.string(
            default = "1.8",
            doc = "JVM bytecode target; the selected Detekt version validates it.",
        ),
        "language_version": attr.string(
            default = "",
            doc = "Kotlin language version; the selected Detekt version validates it.",
        ),
        "max_issues": attr.int(
            default = -1,
            doc = "Detekt 1.x issue threshold; -1 leaves it unset. Mutually exclusive with fail_on_severity.",
        ),
        "parallel": attr.bool(
            default = False,
            doc = "Enable parallel compilation and analysis of source files.",
        ),
        "plugins": attr.label_list(
            default = [],
            providers = [JavaInfo],
            doc = "Plugin targets for rules using this toolchain.",
        ),
    },
)
