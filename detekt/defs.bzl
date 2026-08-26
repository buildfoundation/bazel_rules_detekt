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
    "_result_script_template": attr.label(
        default = Label("//detekt:result_script.sh.tpl"),
        allow_single_file = True,
    ),
    "_result_script_bat_template": attr.label(
        default = Label("//detekt:result_script.bat.tpl"),
        allow_single_file = True,
    ),
    "_windows_constraint": attr.label(
        default = Label("@platforms//os:windows"),
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
        doc = "EXPERIMENTAL: Target version of the generated JVM bytecode that was generated during compilation and is now being used for type resolution (1.8, 9, 10, ..., 26). The selected Detekt version validates this value.",
    ),
    "language_version": attr.string(
        default = "",
        doc = "EXPERIMENTAL: Compatibility mode for Kotlin language version X.Y, reports errors for all language features that came out later. The selected Detekt version validates this value.",
    ),
    "max_issues": attr.int(
        default = -1,
        doc = "Passes only when found issues count does not exceed specified issues count.",
    ),
    "fail_on_severity": attr.string(
        default = "",
        doc = "Detekt 2.x failure threshold (Error, Warning, Info, or Never). Mutually exclusive with max_issues.",
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
    "deps": attr.label_list(
        default = [],
        doc = "Dependencies to provide to Detekt for classpath type resolution.",
        providers = [JavaInfo],
    ),
    "is_android": attr.bool(
        doc = "Whether detekt target corresponds to android kotlin library or regular jvm library",
        default = False,
    ),
}

TOOLCHAIN_TYPE = Label("//detekt:toolchain_type")
ANDROID_SDK_TOOLCHAIN_TYPE = Label("@rules_android//toolchains/android_sdk:toolchain_type")
JDK_TOOLCHAIN_TYPE = Label("@bazel_tools//tools/jdk:toolchain_type")

def _runfiles_path(ctx, file):
    """Returns the manifest key for a file in this target's runfiles."""
    short_path = file.short_path
    if short_path.startswith("../"):
        # External repository paths already contain Bazel's canonical runfiles
        # repository name (for example, ../+repo+extension/path).
        return short_path[3:]
    if ctx.workspace_name:
        return "{}/{}".format(ctx.workspace_name, short_path)
    return short_path

def _impl(
        ctx,
        run_as_test_target = False,
        create_baseline = False):
    is_windows = ctx.target_platform_has_constraint(ctx.attr._windows_constraint[platform_common.ConstraintValueInfo])
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
        final_baseline = ctx.files.baseline[0].short_path if len(ctx.files.baseline) != 0 else "/".join([part for part in [ctx.label.package, default_baseline] if part])

        if is_windows:
            baseline_script = """
if not defined BUILD_WORKING_DIRECTORY (
    echo BUILD_WORKING_DIRECTORY is not set 1>&2
    exit /b 1
)
set "BUILD_WORKING_DIRECTORY=%BUILD_WORKING_DIRECTORY:/=\\%"
if not defined baseline_file (
    echo Unable to locate generated baseline 1>&2
    exit /b 1
)
copy /Y "%baseline_file%" "%BUILD_WORKING_DIRECTORY%\\{target}" >nul
if errorlevel 1 exit /b 1
echo Updated "{target}"
""".format(
                target = final_baseline.replace("/", "\\"),
            )
        else:
            baseline_script = """
                    #!/bin/bash
                    cp -f "{source}" "$BUILD_WORKING_DIRECTORY/{target}"
                    echo "Updated {target}"
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
        if ctx.attr.fail_on_severity:
            fail("max_issues and fail_on_severity cannot be used together")
        detekt_arguments.add("--max-issues", ctx.attr.max_issues)

    if ctx.attr.fail_on_severity:
        detekt_arguments.add("--fail-on-severity", ctx.attr.fail_on_severity)

    if ctx.attr.parallel:
        detekt_arguments.add("--parallel")

    if run_as_test_target:
        detekt_arguments.add("--run-as-test-target")

    classpath = depset([], transitive = [dep[JavaInfo].compile_jars for dep in ctx.attr.deps]).to_list()
    if classpath:
        if ctx.attr.is_android:
            platform_jar_files = [ctx.toolchains[ANDROID_SDK_TOOLCHAIN_TYPE].android_sdk_info.android_jar]
        else:
            platform_jar_files = ctx.toolchains[JDK_TOOLCHAIN_TYPE].java.bootclasspath.to_list()

        action_inputs.extend(platform_jar_files + classpath)
        detekt_arguments.add("--classpath", ctx.configuration.host_path_separator.join([f.path for f in platform_jar_files] + [f.path for f in classpath]))

    plugin_jars = [plugin for plugin in ctx.files.plugins if plugin.extension == "jar"]
    action_inputs.extend(plugin_jars)
    detekt_arguments.add_joined("--plugins", plugin_jars, join_with = ",")

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
    detekt_arguments.add("--execution-result", "{}".format(execution_result.path))

    ctx.actions.run(
        mnemonic = "Detekt",
        progress_message = "Running Detekt for {}".format(str(ctx.label)),
        inputs = action_inputs,
        outputs = action_outputs + [execution_result],
        executable = ctx.executable._detekt_wrapper,
        execution_requirements = {
            "requires-worker-protocol": "proto",
            "supports-workers": "1",
            "supports-multiplex-workers": "1",
        },
        arguments = [java_arguments, detekt_arguments],
    )
    run_files.append(txt_report)

    execution_result_path = _runfiles_path(ctx, execution_result) if is_windows else execution_result.short_path
    text_report_path = _runfiles_path(ctx, txt_report) if is_windows else txt_report.short_path
    baseline_file_path = _runfiles_path(ctx, internal_baseline) if is_windows and internal_baseline else ""
    baseline_lookup = ""
    if baseline_file_path:
        baseline_lookup = """
set "baseline_file="
call :rlocation "{baseline_file}" baseline_file
if defined baseline_file set "baseline_file=%baseline_file:/=\\%"
""".format(baseline_file = baseline_file_path)

    # Text report contents are always printed by the launcher.
    result_script = ctx.actions.declare_file(ctx.attr.name + (".bat" if is_windows else ".sh"))
    ctx.actions.expand_template(
        output = result_script,
        template = ctx.file._result_script_bat_template if is_windows else ctx.file._result_script_template,
        substitutions = {
            "{baseline_script}": baseline_script,
            "{baseline_file_lookup}": baseline_lookup,
            "{execution_result}": execution_result_path,
            "{text_report}": text_report_path,
        },
        is_executable = True,
    )

    return [
        DefaultInfo(
            # The text report is always generated as it's the source for console output via the shell script. However,
            # only add it the report outputs if it's explicitly set.
            files = depset([f for f in action_outputs if f != txt_report or ctx.attr.txt_report]),
            executable = result_script,
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
    toolchains = [TOOLCHAIN_TYPE, ANDROID_SDK_TOOLCHAIN_TYPE, JDK_TOOLCHAIN_TYPE],
)

detekt_create_baseline = rule(
    implementation = _detekt_create_baseline_impl,
    attrs = _ATTRS,
    provides = [DefaultInfo],
    toolchains = [TOOLCHAIN_TYPE, ANDROID_SDK_TOOLCHAIN_TYPE, JDK_TOOLCHAIN_TYPE],
    executable = True,
)

detekt_test = rule(
    implementation = _detekt_test_impl,
    attrs = _ATTRS,
    provides = [DefaultInfo],
    toolchains = [TOOLCHAIN_TYPE, ANDROID_SDK_TOOLCHAIN_TYPE, JDK_TOOLCHAIN_TYPE],
    test = True,
)
