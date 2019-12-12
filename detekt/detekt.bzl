"""
Contains declaration and implementation of "detekt" rule.
Detekt is a static analysis tool for Kotlin: https://github.com/arturbosch/detekt
"""

def _impl(ctx):
    jars = [ctx.file._detekt_wrapper_jar, ctx.file._detekt_cli_jar]

    action_inputs = [] + ctx.files.srcs
    action_outputs = []

    action_arguments = ctx.actions.args()

    # TODO: Allow customizing JVM options.
    action_arguments.add("-Xms16m")
    action_arguments.add("-Xmx128m")
    action_arguments.add_joined("-cp", jars, join_with = ":")
    action_arguments.add("io.buildfoundation.bazel.rulesdetekt.wrapper.Main")

    detekt_arguments = ctx.actions.args()

    if ctx.attr.config != None:
        action_inputs.append(ctx.file.config)
        detekt_arguments.add("--config", ctx.file.config)

    detekt_arguments.add_joined("--input", ctx.files.srcs, join_with = ",")

    if ctx.attr._baseline != None:
        action_inputs.append(ctx.file._baseline)
        detekt_arguments.add("--baseline", ctx.file._baseline)

    if ctx.attr._txt_report:
        txt_report = ctx.outputs.txt_report

        action_outputs.append(txt_report)
        detekt_arguments.add("--report", "txt:{}".format(txt_report.path))

    if ctx.attr.xml_report:
        xml_report = ctx.actions.declare_file("{}_detekt_report.xml".format(ctx.label.name))

        action_outputs.append(xml_report)
        detekt_arguments.add("--report", "xml:{}".format(xml_report.path))

    if ctx.attr.html_report:
        html_report = ctx.actions.declare_file("{}_detekt_report.html".format(ctx.label.name))

        action_outputs.append(html_report)
        detekt_arguments.add("--report", "html:{}".format(html_report.path))

    if ctx.attr.build_upon_default_config:
        detekt_arguments.add("--build-upon-default-config")

    if ctx.attr.disable_default_rulesets:
        detekt_arguments.add("--disable-default-rulesets")

    if ctx.attr.fail_fast:
        detekt_arguments.add("--fail-fast")

    if ctx.attr.parallel:
        detekt_arguments.add("--parallel")

    ctx.actions.run(
        inputs = action_inputs,
        outputs = action_outputs,
        tools = jars,
        executable = "java",
        arguments = [action_arguments, detekt_arguments],
    )

detekt = rule(
    implementation = _impl,
    attrs = {
        # Vendor Detekt CLI.
        # This is not public API yet because ideally Detekt should run as Persistent Worker which will change how we integrate it.
        # Later we should allow user to customize Detekt binary.
        "_detekt_cli_jar": attr.label(
            default = "@detekt_cli_jar//file",
            allow_single_file = True,
        ),
        "_detekt_wrapper_jar": attr.label(
            default = "//detekt/wrapper:bin_deploy.jar",
            allow_single_file = True,
        ),
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = True,
        ),
        "config": attr.label(
            default = None,
            allow_single_file = True,
            doc = "Custom Detekt config file (must end with .yml). If not set Detekt will use its default configuration (mind the Detekt version) https://github.com/arturbosch/detekt/blob/master/detekt-cli/src/main/resources/default-detekt-config.yml",
        ),
        # TODO: Baselines are not fully supported yet due to Detekt relying on absolute paths which doesn't work with Bazel sandboxing.
        "_baseline": attr.label(
            default = None,
            allow_single_file = True,
        ),
        "_txt_report": attr.bool(
            default = True,
        ),
        "xml_report": attr.bool(
            default = False,
        ),
        "html_report": attr.bool(
            default = False,
        ),
        "build_upon_default_config": attr.bool(
            default = False,
            doc = "See Detekt '--build-upon-default-config' option: https://arturbosch.github.io/detekt/cli.html",
        ),
        "disable_default_rulesets": attr.bool(
            default = False,
            doc = "See Detekt '--disable-default-rulesets' option: https://arturbosch.github.io/detekt/cli.html",
        ),
        "fail_fast": attr.bool(
            default = False,
            doc = "See Detekt '--fail-fast' option: https://arturbosch.github.io/detekt/cli.html",
        ),
        "parallel": attr.bool(
            default = False,
            doc = "See Detekt '--parallel' option: https://arturbosch.github.io/detekt/cli.html",
        ),
    },
    outputs = {
        # We need at least one declared output for the rule to run, thus we always generate txt report.
        "txt_report": "%{name}_detekt_report.txt",
    },
)
