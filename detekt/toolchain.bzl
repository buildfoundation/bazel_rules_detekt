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
            doc = "Default value for the build_upon_default_config rule attribute; explicit rule values replace it.",
        ),
        "cfgs": attr.label_list(
            default = [],
            allow_files = [".yml"],
            doc = "Default config files used when a rule omits cfgs; an explicit empty list clears them.",
        ),
        "detekt_wrapper": attr.label(
            default = Label("//detekt/wrapper:bin"),
            executable = True,
            cfg = "exec",
            doc = "Executable wrapper used to run Detekt.",
        ),
        "disable_default_rulesets": attr.bool(
            default = False,
            doc = "Default value for the disable_default_rulesets rule attribute; explicit rule values replace it.",
        ),
        "fail_on_severity": attr.string(
            default = "",
            doc = "Default Detekt 2.x failure threshold; mutually exclusive with max_issues.",
        ),
        "jvm_target": attr.string(
            default = "1.8",
            doc = "Default JVM bytecode target used when a rule omits jvm_target; the selected Detekt version validates it.",
        ),
        "language_version": attr.string(
            default = "",
            doc = "Default Kotlin language version used when a rule omits language_version; the selected Detekt version validates it.",
        ),
        "max_issues": attr.int(
            default = -1,
            doc = "Default Detekt 1.x issue threshold; mutually exclusive with fail_on_severity.",
        ),
        "parallel": attr.bool(
            default = False,
            doc = "Default value for the parallel rule attribute; explicit rule values replace it.",
        ),
        "plugins": attr.label_list(
            default = [],
            providers = [JavaInfo],
            doc = "Default plugin targets used when a rule omits plugins; an explicit empty list clears them.",
        ),
    },
)
