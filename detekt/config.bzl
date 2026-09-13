"""
Reusable Detekt analysis configuration.
"""

load("@rules_java//java:defs.bzl", "JavaInfo")

DetektConfigInfo = provider(
    doc = "Analysis options shared by Detekt targets.",
    fields = [
        "build_upon_default_config",
        "cfgs",
        "disable_default_rulesets",
        "fail_on_severity",
        "jvm_target",
        "language_version",
        "max_issues",
        "parallel",
        "plugins",
    ],
)

def _impl(ctx):
    if ctx.attr.max_issues >= 0 and ctx.attr.fail_on_severity:
        fail("max_issues and fail_on_severity cannot both be enabled on a detekt_config")

    config = DetektConfigInfo(
        build_upon_default_config = ctx.attr.build_upon_default_config,
        cfgs = ctx.files.cfgs,
        disable_default_rulesets = ctx.attr.disable_default_rulesets,
        fail_on_severity = ctx.attr.fail_on_severity,
        jvm_target = ctx.attr.jvm_target,
        language_version = ctx.attr.language_version,
        max_issues = ctx.attr.max_issues,
        parallel = ctx.attr.parallel,
        plugins = ctx.files.plugins,
    )

    return [config]

detekt_config = rule(
    implementation = _impl,
    provides = [DetektConfigInfo],
    attrs = {
        "build_upon_default_config": attr.bool(
            default = False,
            doc = "Use Detekt's built-in configuration as a base for the supplied configuration files.",
        ),
        "cfgs": attr.label_list(
            default = [],
            allow_files = [".yml"],
            doc = "Configuration files for targets using this configuration.",
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
            cfg = "exec",
            default = [],
            providers = [JavaInfo],
            doc = "JavaInfo plugin targets, built for the execution platform.",
        ),
    },
)
