"""
Contains declaration and implementation of "detekt" rule.
Detekt is a static analysis tool for Kotlin: https://github.com/arturbosch/detekt
"""

def _impl(ctx):
    # TODO: Allow customizing JVM options.
    arguments = [
        "-Xms16m",
        "-Xmx128m",
        "-jar",
        ctx.file._detekt_cli_jar.path,
    ]

    if ctx.attr.config != None:
        arguments += ["--config", ctx.file.config]

    arguments += ["--input"] + [src.path for src in ctx.files.srcs]

    if ctx.attr.parallel:
        arguments.append("--parallel")

    arguments += [
        "--report",
        "txt:{}".format(ctx.outputs.txt_report.path),
        "--report",
        "xml:{}".format(ctx.outputs.xml_report.path),
    ]

    ctx.actions.run(
        inputs = ctx.files.srcs,
        outputs = [ctx.outputs.txt_report, ctx.outputs.xml_report],
        tools = [ctx.file._detekt_cli_jar],
        executable = "java",
        arguments = arguments,
    )

detekt = rule(
    implementation = _impl,
    attrs = {
        # Vendor Detekt CLI.
        # This is not public API yet because ideally Detekt should run as Persistent Worker which will change how we integrate it.
        # Later we should allow user to customize Detekt binary.
        "_detekt_cli_jar": attr.label(default = "@detekt_cli_jar//file", allow_single_file = True),
        "srcs": attr.label_list(allow_files = True),
        "config": attr.label(default = None, allow_single_file = True),
        "parallel": attr.bool(default = False, doc = "As per Detekt documentation https://arturbosch.github.io/detekt/cli.html: Enables parallel compilation of source files. Should only be used if the analyzing project has more than ~200 Kotlin files."),
        # TODO: Add baseline support.
    },
    outputs = {
        "txt_report": "report.txt",
        "xml_report": "report.xml",
    },
)
