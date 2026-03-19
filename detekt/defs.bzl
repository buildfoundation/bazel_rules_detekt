"""
Rule declarations.
"""

load("@rules_android//rules:utils.bzl", "get_android_sdk")
load("@rules_java//java:defs.bzl", "JavaInfo")
load("@rules_java//java/common:java_common.bzl", "java_common")

_ATTRS = {
    "_detekt_wrapper": attr.label(
        default = "//detekt/wrapper:bin",
        executable = True,
        cfg = "exec",
    ),
    "_java_toolchain": attr.label(
        default = Label("@bazel_tools//tools/jdk:current_java_toolchain"),
    ),
    "srcs": attr.label_list(
        mandatory = True,
        allow_files = [".kt", ".kts", ".java"],
        allow_empty = False,
        doc = "Kotlin and Java source code files to analyze. Java files are included to support type resolution in mixed-language projects.",
    ),
    "deps": attr.label_list(
        default = [],
        doc = "Dependencies to provide to Detekt for classpath type resolution.",
        providers = [JavaInfo],
    ),
    "plugins": attr.label_list(
        default = [],
        providers = [JavaInfo],
        doc = "Extra paths to plugin jars.",
    ),
    "cfgs": attr.label_list(
        default = [],
        allow_files = [".yml"],
        doc = "Path to the config file (`path/to/config.yml`). Multiple configuration files can be specified.",
    ),
    "config_resource": attr.string(
        default = "",
        doc = "Path to the config resource on detekt's classpath (`path/to/config.yml`).",
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
        doc = "Allow rules to auto correct code if they support it. The default rule sets do NOT support auto correcting and won't change any line in the users code base. However custom rules can be written to support auto correcting. The additional 'formatting' rule set, added with `--plugins`, does support it and needs this flag.",
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
    # Consider moving this attribute to the toolchain.
    "enable_type_resolution": attr.bool(
        default = False,
        doc = "Enables type resolution for more advanced static analysis. When enabled, the classpath is constructed from `deps` and the appropriate bootclasspath (Android SDK or JDK) is included. When disabled, no classpath is passed to Detekt and only syntax-based rules are applied.",
    ),
    "excludes": attr.string_list(
        default = [],
        doc = "Globbing patterns describing paths to exclude from the analysis.",
    ),
    "includes": attr.string_list(
        default = [],
        doc = "Globbing patterns describing paths to include in the analysis. Useful in combination with `excludes` patterns.",
    ),
    "max_issues": attr.int(
        default = -1,
        doc = "Passes only when found issues count does not exceed specified issues count.",
    ),
    "parallel": attr.bool(
        default = False,
        doc = "Enables parallel compilation and analysis of source files. Do some benchmarks first before enabling this flag. Heuristics show performance benefits starting from 2,000 lines of Kotlin code.",
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
        doc = "Enables / disables the XML report generation. The report file name is `{target_name}_detekt_report.xml`. Detekt uses the Checkstyle XML reporting format which makes it compatible with tools like SonarQube.",
    ),
    "md_report": attr.bool(
        default = False,
        doc = "Enables / disables the Markdown report generation. The report file name is `{target_name}_detekt_report.md`.",
    ),
    "sarif_report": attr.bool(
        default = False,
        doc = "Enables / disables the SARIF report generation. The report file name is `{target_name}_detekt_report.sarif`.",
    ),
    "is_android": attr.bool(
        default = False,
        doc = "Whether the target is an Android target. When `True`, the Android SDK jar is included in the classpath for type resolution.",
    ),
}

TOOLCHAIN_TYPE = Label("//detekt:toolchain_type")

_ANDROID_SDK_TOOLCHAIN_TYPE = "@rules_android//toolchains/android_sdk:toolchain_type"

_TOOLCHAINS = [
    TOOLCHAIN_TYPE,
    config_common.toolchain_type(_ANDROID_SDK_TOOLCHAIN_TYPE, mandatory = False),
    "@bazel_tools//tools/jdk:toolchain_type",
]

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

    detekt_arguments.add("--jvm-target", ctx.toolchains[TOOLCHAIN_TYPE].jvm_target)

    if ctx.toolchains[TOOLCHAIN_TYPE].language_version:
        detekt_arguments.add("--language-version", ctx.toolchains[TOOLCHAIN_TYPE].language_version)

    if ctx.attr.max_issues >= 0:
        detekt_arguments.add("--max-issues", ctx.attr.max_issues)

    if ctx.attr.parallel:
        detekt_arguments.add("--parallel")

    if run_as_test_target:
        detekt_arguments.add("--run-as-test-target")

    # Supports android_binary() as plugins attr, which is not a jar.
    plugins = depset([], transitive = [dep[JavaInfo].transitive_runtime_jars for dep in ctx.attr.plugins])
    action_inputs.extend(plugins.to_list())
    detekt_arguments.add_joined("--plugins", plugins, join_with = ",")

    # TODO: We might be able to replace this with a provider check so that we aren't having to manage
    # these bits at the target creation level.
    if ctx.attr.enable_type_resolution:
        # TODO: This tends to be super slow in larger codebases because it results in huge classpaths.
        # We can look into solving this differently if we need to, or copy what rules_kotlin does
        # with classpath reduction.
        filtered_classpath = []

        if ctx.attr.is_android:
            # Android SDK is needed for resolving Android-specific types
            if not ctx.toolchains[_ANDROID_SDK_TOOLCHAIN_TYPE]:
                fail("'is_android = True' requires a registered Android SDK toolchain. " +
                     "See https://github.com/bazelbuild/rules_android for setup instructions.")
            android_jar = get_android_sdk(ctx).android_jar
            action_inputs.append(android_jar)
            filtered_classpath.append(android_jar.path)
        else:
            # JDK platform jar is needed for resolving core types
            bootclasspath_files = ctx.attr._java_toolchain[java_common.JavaToolchainInfo].bootclasspath.to_list()
            action_inputs.extend(bootclasspath_files)
            filtered_classpath.extend([f.path for f in bootclasspath_files])

        # compile_jars should contain mostly ijar/header jars that are faster to load onto the classpath
        classpath = depset([], transitive = [dep[JavaInfo].transitive_compile_time_jars for dep in ctx.attr.deps]).to_list()
        action_inputs.extend(classpath)
        for file in classpath:
            # Dependencies on AP may incorrectly bring guava JRE to classpath, make sure it's filtered out
            if "com/google/guava/guava/" in file.path:
                continue
            filtered_classpath.append(file.path)

        detekt_arguments.add("--classpath", ":".join(filtered_classpath))

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

    stderr_output = ctx.actions.declare_file("{}_stderr.txt".format(ctx.label.name))
    run_files.append(stderr_output)
    action_outputs.append(stderr_output)
    detekt_arguments.add("--stderr-output", "{}".format(stderr_output.path))

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
stderr_content=$(cat {stderr_output})
if [ ! -z "$stderr_content" ]; then
    echo "$stderr_content"
fi
{baseline_script}
exit "$exit_code"
""".format(execution_result = execution_result.short_path, stderr_output = stderr_output.short_path, baseline_script = baseline_script),
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
    toolchains = _TOOLCHAINS,
)

detekt_create_baseline = rule(
    implementation = _detekt_create_baseline_impl,
    attrs = _ATTRS,
    provides = [DefaultInfo],
    toolchains = _TOOLCHAINS,
    executable = True,
)

detekt_test = rule(
    implementation = _detekt_test_impl,
    attrs = _ATTRS,
    provides = [DefaultInfo],
    toolchains = _TOOLCHAINS,
    test = True,
)
