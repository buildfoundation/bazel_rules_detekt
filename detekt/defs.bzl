"""
Rule declarations.
"""

def _impl(ctx):
    action_inputs = []
    action_outputs = []

    java_arguments = ctx.actions.args()

    for jvm_flag in ctx.toolchains["@rules_detekt//detekt:toolchain_type"].jvm_flags:
        # The Bazel-generated execution script requires "=" between argument names and values.
        java_arguments.add("--jvm_flag={}".format(jvm_flag))

    detekt_arguments = ctx.actions.args()

    # Detekt arguments are passed in a file. The file path is a special @-named argument.
    # See https://docs.oracle.com/javase/8/docs/technotes/tools/windows/javac.html#BHCJEIBB
    # A worker execution replaces the @-argument with the "--persistent_worker" one.
    # A non-worker execution preserves the argument which is eventually expanded to regular arguments.

    detekt_arguments.set_param_file_format("multiline")
    detekt_arguments.use_param_file("@%s", use_always = True)

    action_inputs.extend(ctx.files.srcs)
    detekt_arguments.add_joined("--input", ctx.files.srcs, join_with = ",")

    action_inputs.extend(ctx.files.cfgs)
    detekt_arguments.add_joined("--config", ctx.files.cfgs, join_with = ",")

    if ctx.attr.baseline != None:
        action_inputs.append(ctx.file.baseline)
        detekt_arguments.add("--baseline", ctx.file.baseline)

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
        executable = ctx.executable._detekt_wrapper,
        execution_requirements = {
            "supports-workers": "1",
            "supports-multiplex-workers": "0",
        },
        arguments = [java_arguments, detekt_arguments],
    )

    return [DefaultInfo(files = depset(action_outputs))]

detekt = rule(
    implementation = _impl,
    attrs = {
        "_detekt_wrapper": attr.label(
            default = "//detekt/wrapper:bin",
            executable = True,
            cfg = "host",
        ),
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = [".kt", ".kts"],
            allow_empty = False,
            doc = "Kotlin source code files.",
        ),
        "cfgs": attr.label_list(
            allow_files = [".yml"],
            default = [],
            doc = "[Detekt configuration files](https://arturbosch.github.io/detekt/configurations.html). Otherwise [the default configuration](https://github.com/arturbosch/detekt/blob/master/detekt-cli/src/main/resources/default-detekt-config.yml) is used.",
        ),
        "baseline": attr.label(
            default = None,
            allow_single_file = [".xml"],
            doc = "[Detekt baseline file](https://arturbosch.github.io/detekt/baseline.html).",
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
            doc = "Enables / disables the XML report generation. The report file name is `{target_name}_detekt_report.xml`. FYI Detekt uses the Checkstyle XML reporting format which makes it compatible with tools like SonarQube.",
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
    toolchains = ["@rules_detekt//detekt:toolchain_type"],
)
