"""
Contains declaration and implementation of "detekt" rule.
Detekt is a static analysis tool for Kotlin: https://github.com/arturbosch/detekt
"""

def _impl(ctx):
    action_inputs = [] + ctx.files.srcs
    action_outputs = []

    action_arguments = ctx.actions.args()

    # The Bazel-generated execution script requires "=" between argument names and values.
    # TODO: Allow customizing JVM options.
    action_arguments.add("--jvm_flag=-Xms16m")
    action_arguments.add("--jvm_flag=-Xmx128m")
    action_arguments.add("--main_advice_classpath={}".format(ctx.file._detekt_cli_jar.path))

    detekt_arguments = ctx.actions.args()

    # Detekt arguments are passed in a file. The file path is a special @-named argument.
    # See https://docs.oracle.com/javase/8/docs/technotes/tools/windows/javac.html#BHCJEIBB
    # A worker execution replaces the @-argument with the "--persistent_worker" one.
    # A non-worker execution preserves the argument which is eventually expanded to regular arguments.

    detekt_arguments.set_param_file_format("multiline")
    detekt_arguments.use_param_file("@%s", use_always = True)

    if ctx.attr.config != None:
        action_inputs.append(ctx.file.config)
        detekt_arguments.add("--config", ctx.file.config)

    detekt_arguments.add_joined("--input", ctx.files.srcs, join_with = ",")

    if ctx.attr._baseline != None:
        action_inputs.append(ctx.file._baseline)
        detekt_arguments.add("--baseline", ctx.file._baseline)

    if ctx.attr.html_report:
        html_report = ctx.actions.declare_file("{}_detekt_report.html".format(ctx.label.name))

        action_outputs.append(html_report)
        detekt_arguments.add("--report", "html:{}".format(html_report.path))

    if ctx.attr._txt_report:
        txt_report = ctx.actions.declare_file("{}_detekt_report.txt".format(ctx.label.name))

        action_outputs.append(txt_report)
        detekt_arguments.add("--report", "txt:{}".format(txt_report.path))

    if ctx.attr.xml_report:
        xml_report = ctx.actions.declare_file("{}_detekt_report.xml".format(ctx.label.name))

        action_outputs.append(xml_report)
        detekt_arguments.add("--report", "xml:{}".format(xml_report.path))

    if ctx.attr.build_upon_default_config:
        detekt_arguments.add("--build-upon-default-config")

    if ctx.attr.disable_default_rulesets:
        detekt_arguments.add("--disable-default-rulesets")

    if ctx.attr.fail_fast:
        detekt_arguments.add("--fail-fast")

    if ctx.attr.parallel:
        detekt_arguments.add("--parallel")

    ctx.actions.run(
        mnemonic = "Detekt",
        inputs = action_inputs,
        outputs = action_outputs,
        tools = [ctx.file._detekt_cli_jar],
        executable = ctx.executable._detekt_wrapper,
        execution_requirements = {
            "supports-workers": "1",
        },
        arguments = [action_arguments, detekt_arguments],
    )

    return [DefaultInfo(files = depset(action_outputs))]

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
        "_detekt_wrapper": attr.label(
            default = "//detekt/wrapper:bin",
            executable = True,
            cfg = "host",
        ),
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = True,
            doc = "A glob or an explicit list of Kotlin files.",
        ),
        "config": attr.label(
            default = None,
            allow_single_file = True,
            doc = "Detekt config file. Otherwise [the default configuration](https://github.com/arturbosch/detekt/blob/master/detekt-cli/src/main/resources/default-detekt-config.yml) is used.",
        ),
        # TODO: Baselines are not fully supported yet due to Detekt relying on absolute paths which doesn't work with Bazel sandboxing.
        "_baseline": attr.label(
            default = None,
            allow_single_file = True,
        ),
        "html_report": attr.bool(
            default = False,
            doc = "Enables / disables the HTML report generation. The report file name is `{target_name}_detekt_report.html`.",
        ),
        "_txt_report": attr.bool(
            default = True,
        ),
        "xml_report": attr.bool(
            default = False,
            doc = """Enables / disables the XML report generation. The report file name is `{target_name}_detekt_report.xml`. FYI Detekt uses the Checkstyle XML reporting format which makes it compatible with tools like SonarQube and so on.
            """,
        ),
        "build_upon_default_config": attr.bool(
            default = False,
            doc = "See [Detekt `--build-upon-default-config` option](https://arturbosch.github.io/detekt/cli.html).",
        ),
        "disable_default_rulesets": attr.bool(
            default = False,
            doc = "See [Detekt `--disable-default-rulesets` option](https://arturbosch.github.io/detekt/cli.html).",
        ),
        "fail_fast": attr.bool(
            default = False,
            doc = "See [Detekt `--fail-fast` option](https://arturbosch.github.io/detekt/cli.html).",
        ),
        "parallel": attr.bool(
            default = False,
            doc = "See [Detekt `--parallel` option](https://arturbosch.github.io/detekt/cli.html).",
        ),
    },
    provides = [DefaultInfo],
)
