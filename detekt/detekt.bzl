"""
Contains declaration and implementation of "detekt" rule.
Detekt is a static analysis tool for Kotlin: https://github.com/arturbosch/detekt
"""

def _impl(ctx):
    action_inputs = [] + ctx.files.srcs
    action_outputs = []

    # See Detekt CLI documentation: https://arturbosch.github.io/detekt/cli.html
    # TODO: Allow customizing JVM options.
    action_arguments = [
        "-Xms16m",
        "-Xmx128m",
        "-cp",
        ":".join([jar.path for jar in [ctx.file._detekt_cli_jar, ctx.file._detekt_wrapper_jar]]),
        "io.buildfoundation.bazel.rulesdetekt.wrapper.Main",
    ]

    if ctx.attr.config != None:
        action_inputs.append(ctx.file.config)

    action_arguments += ["--input", ",".join([src.path for src in ctx.files.srcs])]

    if ctx.attr._baseline != None:
        action_inputs.append(ctx.file._baseline)

        action_arguments.append("--baseline")
        action_arguments.append(ctx.file._baseline.path)

    if ctx.attr.parallel:
        action_arguments.append("--parallel")

    if ctx.attr._txt_report:
        txt_report = ctx.outputs.txt_report
        action_outputs.append(txt_report)

        action_arguments.append("--report")
        action_arguments.append("txt:{}".format(txt_report.path))

    if ctx.attr.xml_report:
        xml_report = ctx.actions.declare_file("{}_detekt_report.xml".format(ctx.label.name))
        action_outputs.append(xml_report)

        action_arguments.append("--report")
        action_arguments.append("xml:{}".format(xml_report.path))

    if ctx.attr.html_report:
        html_report = ctx.actions.declare_file("{}_detekt_report.html".format(ctx.label.name))
        action_outputs.append(html_report)

        action_arguments.append("--report")
        action_arguments.append("html:{}".format(html_report.path))

    ctx.actions.run(
        inputs = action_inputs,
        outputs = action_outputs,
        tools = [ctx.file._detekt_wrapper_jar, ctx.file._detekt_cli_jar],
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
        "_detekt_wrapper_jar": attr.label(default = "//detekt/wrapper:bin_deploy.jar", allow_single_file = True),
        "srcs": attr.label_list(allow_files = True),
        "config": attr.label(default = None, allow_single_file = True, doc = "Custom Detekt config file (must end with .yml). If not set Detekt will use its default configuration (mind the Detekt version) https://github.com/arturbosch/detekt/blob/master/detekt-cli/src/main/resources/default-detekt-config.yml"),
        # TODO: Baselines are not fully supported yet due to Detekt relying on absolute paths which doesn't work with Bazel sandboxing.
        "_baseline": attr.label(default = None, allow_single_file = True),
        "parallel": attr.bool(default = False, doc = "As per Detekt documentation https://arturbosch.github.io/detekt/cli.html: Enables parallel compilation of source files. Should only be used if the analyzing project has more than ~200 Kotlin files."),
        "_txt_report": attr.bool(default = True),
        "xml_report": attr.bool(default = False),
        "html_report": attr.bool(default = False),
    },
    outputs = {
        # We need at least one declared output for the rule to run, thus we always generate txt report.
        "txt_report": "%{name}_detekt_report.txt",
    },
)
