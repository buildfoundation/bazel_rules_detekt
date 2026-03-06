"""
Rule declarations.
"""

load("@rules_java//java:defs.bzl", "JavaInfo")

_ATTRS = {
    "_detekt_wrapper": attr.label(
        default = "//detekt/wrapper:bin",
        executable = True,
        cfg = "exec",
    ),
    "srcs": attr.label_list(
        mandatory = True,
        allow_files = [".kt", ".kts"],
        allow_empty = False,
        doc = "Kotlin source code files to analyze.",
    ),
    "plugins": attr.label_list(
        default = [],
        providers = [JavaInfo],
        doc = "Extra paths to plugin jars.",
    ),
    "cfgs": attr.label_list(
        default = [],
        allow_files = [".yml"],
        doc = "Path to the config file (path/to/config.yml). Multiple configuration files can be specified.",
    ),
    "config_resource": attr.string(
        default = "",
        doc = "Path to the config resource on detekt's classpath (path/to/config.yml).",
    ),
    "baseline": attr.label(
        default = None,
        allow_single_file = [".xml"],
        doc = "If a baseline xml file is passed in, only new code smells not in the baseline are printed in the console.",
    ),
    "all_rules": attr.bool(
        default = False,
        doc = "Activates all available (even unstable) rules.",
    ),
    "auto_correct": attr.bool(
        default = False,
        doc = "Allow rules to auto correct code if they support it. The default rule sets do NOT support auto correcting and won't change any line in the users code base. However custom rules can be written to support auto correcting. The additional 'formatting' rule set, added with '--plugins', does support it and needs this flag.",
    ),
    "base_path": attr.string(
        default = "",
        doc = "Specifies a directory as the base path. Currently it impacts all file paths in the formatted reports. File paths in console output and txt report are not affected and remain as absolute paths.",
    ),
    "build_upon_default_config": attr.bool(
        default = False,
        doc = "Preconfigures detekt with a bunch of rules and some opinionated defaults for you. Allows additional provided configurations to override the defaults.",
    ),
    "disable_default_rulesets": attr.bool(
        default = False,
        doc = "Disables default rule sets.",
    ),
    "excludes": attr.string_list(
        default = [],
        doc = "Globbing patterns describing paths to exclude from the analysis.",
    ),
    "includes": attr.string_list(
        default = [],
        doc = "Globbing patterns describing paths to include in the analysis. Useful in combination with 'excludes' patterns.",
    ),
    "jvm_target": attr.string(
        default = "1.8",
        values = ["1.8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20"],
        doc = "EXPERIMENTAL: Target version of the generated JVM bytecode that was generated during compilation and is now being used for type resolution (1.8, 9, 10, ..., 20)",
    ),
    "language_version": attr.string(
        default = "",
        values = ["", "1.0", "1.1", "1.2", "1.3", "1.4", "1.5", "1.6", "1.7", "1.8", "1.9", "2.0", "2.1", "2.2"],
        doc = "EXPERIMENTAL: Compatibility mode for Kotlin language version X.Y, reports errors for all language features that came out later",
    ),
    "max_issues": attr.int(
        default = -1,
        doc = "Passes only when found issues count does not exceed specified issues count.",
    ),
    "parallel": attr.bool(
        default = False,
        doc = "Enables parallel compilation and analysis of source files. Do some benchmarks first before enabling this flag. Heuristics show performance benefits starting from 2000 lines of Kotlin code.",
    ),
    "txt_report": attr.bool(
        default = False,
        doc = "Enables / disables the text report generation. The report file name is `{target_name}_detekt_report.txt`.",
    ),
    "html_report": attr.bool(
        default = False,
        doc = "Enables / disables the HTML report generation. The report file name is `{target_name}_detekt_report.html`.",
    ),
    "xml_report": attr.bool(
        default = False,
        doc = "Enables / disables the XML report generation. The report file name is `{target_name}_detekt_report.xml`. FYI Detekt uses the Checkstyle XML reporting format which makes it compatible with tools like SonarQube.",
    ),
    "md_report": attr.bool(
        default = False,
        doc = "Enables / disables the Markdown report generation. The report file name is `{target_name}_detekt_report.md`.",
    ),
    "sarif_report": attr.bool(
        default = False,
        doc = "Enables / disables the SARIF report generation. The report file name is `{target_name}_detekt_report.sarif`.",
    ),
}

TOOLCHAIN_TYPE = Label("//detekt:toolchain_type")

def _impl(
        ctx,
        run_as_test_target = False,
        create_baseline = False):
    action_inputs = []
    action_outputs = []

    java_arguments = ctx.actions.args()

    for jvm_flag in ctx.toolchains[TOOLCHAIN_TYPE].jvm_flags:
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

    if ctx.attr.config_resource:
        detekt_arguments.add("--config-resource", ctx.attr.config_resource)

    internal_baseline = None
    baseline_script = ""
    run_files = []
    default_baseline = "default_baseline.xml"
    if create_baseline:
        detekt_arguments.add("--create-baseline")
        internal_baseline = ctx.actions.declare_file("{}_baseline.xml".format(ctx.label.name))
        run_files.append(internal_baseline)
        action_outputs.append(internal_baseline)
        detekt_arguments.add("--baseline", internal_baseline)
        final_baseline = ctx.files.baseline[0].short_path if len(ctx.files.baseline) != 0 else "%s/%s" % (ctx.label.package, default_baseline)

        baseline_script = """
                    #!/bin/bash
                    cp -rf {source} $BUILD_WORKING_DIRECTORY/{target}
                    echo "$(tput setaf 2)Updated {target} $(tput sgr0)"
                            """.format(
            source = internal_baseline.short_path,
            target = final_baseline,
        )
    elif ctx.attr.baseline != None:
        action_inputs.append(ctx.file.baseline)
        detekt_arguments.add("--baseline", ctx.file.baseline)

    if ctx.attr.all_rules:
        detekt_arguments.add("--all-rules")

    if ctx.attr.auto_correct:
        detekt_arguments.add("--auto-correct")

    if ctx.attr.base_path:
        detekt_arguments.add("--base-path", ctx.attr.base_path)

    if ctx.attr.build_upon_default_config:
        detekt_arguments.add("--build-upon-default-config")

    if ctx.attr.disable_default_rulesets:
        detekt_arguments.add("--disable-default-rulesets")

    if ctx.attr.excludes:
        detekt_arguments.add_joined("--excludes", ctx.attr.excludes, join_with = ",")

    if ctx.attr.includes:
        detekt_arguments.add_joined("--includes", ctx.attr.includes, join_with = ",")

    detekt_arguments.add("--jvm-target", ctx.attr.jvm_target)

    if ctx.attr.language_version:
        detekt_arguments.add("--language-version", ctx.attr.language_version)

    if ctx.attr.max_issues >= 0:
        detekt_arguments.add("--max-issues", ctx.attr.max_issues)

    if ctx.attr.parallel:
        detekt_arguments.add("--parallel")

    if run_as_test_target:
        detekt_arguments.add("--run-as-test-target")

    action_inputs.extend(ctx.files.plugins)
    detekt_arguments.add_joined("--plugins", ctx.files.plugins, join_with = ",")

    txt_report = ctx.actions.declare_file("{}_detekt_report.txt".format(ctx.label.name))
    action_outputs.append(txt_report)
    detekt_arguments.add("--report", "txt:{}".format(txt_report.path))

    if ctx.attr.html_report:
        html_report = ctx.actions.declare_file("{}_detekt_report.html".format(ctx.label.name))
        action_outputs.append(html_report)
        detekt_arguments.add("--report", "html:{}".format(html_report.path))

    if ctx.attr.xml_report:
        xml_report = ctx.actions.declare_file("{}_detekt_report.xml".format(ctx.label.name))
        action_outputs.append(xml_report)
        detekt_arguments.add("--report", "xml:{}".format(xml_report.path))

    if ctx.attr.md_report:
        md_report = ctx.actions.declare_file("{}_detekt_report.md".format(ctx.label.name))
        action_outputs.append(md_report)
        detekt_arguments.add("--report", "md:{}".format(md_report.path))

    if ctx.attr.sarif_report:
        sarif_report = ctx.actions.declare_file("{}_detekt_report.sarif".format(ctx.label.name))
        action_outputs.append(sarif_report)
        detekt_arguments.add("--report", "sarif:{}".format(sarif_report.path))

    execution_result = ctx.actions.declare_file("{}_exit_code.txt".format(ctx.label.name))
    run_files.append(execution_result)
    action_outputs.append(execution_result)
    detekt_arguments.add("--execution-result", "{}".format(execution_result.path))

    ctx.actions.run(
        mnemonic = "Detekt",
        progress_message = "Running Detekt for {}".format(str(ctx.label)),
        inputs = action_inputs,
        outputs = action_outputs,
        executable = ctx.executable._detekt_wrapper,
        execution_requirements = {
            "requires-worker-protocol": "proto",
            "supports-workers": "1",
            "supports-multiplex-workers": "1",
        },
        arguments = [java_arguments, detekt_arguments],
    )
    run_files.append(txt_report)

    # Note: this is not compatible with Windows, feel free to submit PR!
    # text report-contents are always printed to shell
    final_result = ctx.actions.declare_file(ctx.attr.name + ".sh")
    ctx.actions.write(
        output = final_result,
        content = """
#!/bin/bash
set -euo pipefail
exit_code=$(cat {execution_result})
report=$(cat {text_report})
if [ ! -z "$report" ]; then
    echo "$report"
fi
{baseline_script}
exit "$exit_code"
""".format(execution_result = execution_result.short_path, text_report = txt_report.short_path, baseline_script = baseline_script),
        is_executable = True,
    )

    return [
        DefaultInfo(
            # The text report is always generated as it's the source for console output via the shell script. However,
            # only add it the report outputs if it's explicitly set.
            files = depset([f for f in action_outputs if f != txt_report or ctx.attr.txt_report]),
            executable = final_result,
            runfiles = ctx.runfiles(files = run_files),
        ),
    ]

def _detekt_impl(ctx):
    return _impl(ctx = ctx, run_as_test_target = False)

def _detekt_create_baseline_impl(ctx):
    return _impl(ctx = ctx, create_baseline = True)

def _detekt_test_impl(ctx):
    return _impl(ctx = ctx, run_as_test_target = True)

detekt = rule(
    implementation = _detekt_impl,
    attrs = _ATTRS,
    provides = [DefaultInfo],
    toolchains = [TOOLCHAIN_TYPE],
)

detekt_create_baseline = rule(
    implementation = _detekt_create_baseline_impl,
    attrs = _ATTRS,
    provides = [DefaultInfo],
    toolchains = [TOOLCHAIN_TYPE],
    executable = True,
)

detekt_test = rule(
    implementation = _detekt_test_impl,
    attrs = _ATTRS,
    provides = [DefaultInfo],
    toolchains = [TOOLCHAIN_TYPE],
    test = True,
)
