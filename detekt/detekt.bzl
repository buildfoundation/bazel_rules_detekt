"""
Contains declaration and implementation of "detekt" rule.
Detekt is a static analysis tool for Kotlin: https://github.com/arturbosch/detekt
"""

def _impl(ctx):
    action_inputs = [] + ctx.files.srcs

    # See Detekt CLI documentation: https://arturbosch.github.io/detekt/cli.html
    # TODO: Allow customizing JVM options.
    action_arguments = [
        "-Xms16m",
        "-Xmx128m",
        "-jar",
        ctx.file._detekt_cli_jar.path,
    ]

    if ctx.attr.config != None:
        action_inputs.append(ctx.file.config)
        action_arguments += ["--config", ctx.file.config.path]

    action_arguments += ["--input"] + [src.path for src in ctx.files.srcs]

    if ctx.attr._baseline != None:
        action_inputs.append(ctx.file._baseline)
        action_arguments += ["--baseline", ctx.file._baseline.path]

    if ctx.attr.parallel:
        action_arguments.append("--parallel")

    action_arguments += [
        "--report",
        "txt:{}".format(ctx.outputs.txt_report.path),
        "--report",
        "xml:{}".format(ctx.outputs.xml_report.path),
    ]

    ctx.actions.run(
        inputs = action_inputs,
        outputs = [ctx.outputs.txt_report, ctx.outputs.xml_report],
        tools = [ctx.file._detekt_cli_jar],
        executable = "java",
        arguments = action_arguments,
    )

detekt = rule(
    implementation = _impl,
    attrs = {
        # Vendor Detekt CLI.
        # This is not public API yet because ideally Detekt should run as Persistent Worker which will change how we integrate it.
        # Later we should allow user to customize Detekt binary.
        "_detekt_cli_jar": attr.label(default = "@detekt_cli_jar//file", allow_single_file = True),
        "srcs": attr.label_list(allow_files = True),
        "config": attr.label(default = None, allow_single_file = True, doc = "Custom Detekt config file (must end with .yml). If not set Detekt will use its default configuration (mind the Detekt version) https://github.com/arturbosch/detekt/blob/master/detekt-cli/src/main/resources/default-detekt-config.yml"),
        # TODO: Baselines are not fully supported yet due to Detekt relying on absolute paths which doesn't work with Bazel sandboxing.
        "_baseline": attr.label(default = None, allow_single_file = True),
        "parallel": attr.bool(default = False, doc = "As per Detekt documentation https://arturbosch.github.io/detekt/cli.html: Enables parallel compilation of source files. Should only be used if the analyzing project has more than ~200 Kotlin files."),
    },
    outputs = {
        "txt_report": "%{name}_detekt_report.txt",
        "xml_report": "%{name}_detekt_report.xml",
    },
)
