"""
The rule analysis tests.
"""

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")
load("@rules_detekt//detekt:defs.bzl", "detekt")

def _expand_paths(ctx, values):
    source_dir = ctx.build_file_path.replace("/BUILD", "")
    output_dir = ctx.bin_dir.path

    return [
        value
            .replace("{{source_dir}}", source_dir)
            .replace("{{output_dir}}", output_dir)
        for value in values
    ]

# Action full contents test

def _action_full_contents_test_impl(ctx):
    env = analysistest.begin(ctx)

    actions = analysistest.target_actions(env)
    asserts.equals(env, 1, len(actions))

    expected_arguments = _expand_paths(env.ctx, [
        "bazel-out/host/bin/detekt/wrapper/bin",
        "--jvm_flag=-Xms16m",
        "--jvm_flag=-Xmx128m",
        "--input",
        "{{source_dir}}/path A.kt,{{source_dir}}/path B.kt,{{source_dir}}/path C.kt",
        "--config",
        "{{source_dir}}/config A.yml,{{source_dir}}/config B.yml,{{source_dir}}/config C.yml",
        "--baseline",
        "{{source_dir}}/baseline.xml",
        "--report",
        "html:{{output_dir}}/{{source_dir}}/test_target_full_detekt_report.html",
        "--report",
        "txt:{{output_dir}}/{{source_dir}}/test_target_full_detekt_report.txt",
        "--report",
        "xml:{{output_dir}}/{{source_dir}}/test_target_full_detekt_report.xml",
        "--build-upon-default-config",
        "--disable-default-rulesets",
        "--fail-fast",
        "--parallel",
        "--classpath",
        ",".join([
            "{{output_dir}}/external/rules_detekt_dependencies/v1/https/repo1.maven.org/maven2/org/jetbrains/kotlin/kotlin-stdlib/1.5.21/header_kotlin-stdlib-1.5.21.jar",
            "{{output_dir}}/external/rules_detekt_dependencies/v1/https/repo1.maven.org/maven2/org/jetbrains/annotations/13.0/header_annotations-13.0.jar",
            "{{output_dir}}/external/rules_detekt_dependencies/v1/https/repo1.maven.org/maven2/org/jetbrains/kotlin/kotlin-stdlib-common/1.5.21/header_kotlin-stdlib-common-1.5.21.jar",
        ]),
        "--language-version",
        "1.5",
        "--jvm-target",
        "1.8",
    ])

    expected_inputs = _expand_paths(env.ctx, [
        "{{source_dir}}/path A.kt",
        "{{source_dir}}/path B.kt",
        "{{source_dir}}/path C.kt",
        "{{source_dir}}/config A.yml",
        "{{source_dir}}/config B.yml",
        "{{source_dir}}/config C.yml",
        "{{source_dir}}/baseline.xml",
        "{{output_dir}}/external/rules_detekt_dependencies/v1/https/repo1.maven.org/maven2/org/jetbrains/kotlin/kotlin-stdlib/1.5.21/header_kotlin-stdlib-1.5.21.jar",
        "{{output_dir}}/external/rules_detekt_dependencies/v1/https/repo1.maven.org/maven2/org/jetbrains/annotations/13.0/header_annotations-13.0.jar",
        "{{output_dir}}/external/rules_detekt_dependencies/v1/https/repo1.maven.org/maven2/org/jetbrains/kotlin/kotlin-stdlib-common/1.5.21/header_kotlin-stdlib-common-1.5.21.jar",
        "bazel-out/host/internal/_middlemen/detekt_Swrapper_Sbin-runfiles",
        "bazel-out/host/bin/detekt/wrapper/bin.jar",
        "bazel-out/host/bin/detekt/wrapper/bin",
    ])

    expected_outputs = _expand_paths(env.ctx, [
        "{{output_dir}}/{{source_dir}}/test_target_full_detekt_report.html",
        "{{output_dir}}/{{source_dir}}/test_target_full_detekt_report.txt",
        "{{output_dir}}/{{source_dir}}/test_target_full_detekt_report.xml",
    ])

    action = actions[0]

    asserts.equals(env, expected_arguments, action.argv)
    asserts.equals(env, expected_inputs, [file.path for file in action.inputs.to_list()])
    asserts.equals(env, expected_outputs, [file.path for file in action.outputs.to_list()])

    return analysistest.end(env)

action_full_contents_test = analysistest.make(_action_full_contents_test_impl)

def _test_action_full_contents():
    detekt(
        name = "test_target_full",
        srcs = ["path A.kt", "path B.kt", "path C.kt"],
        cfgs = ["config A.yml", "config B.yml", "config C.yml"],
        baseline = "baseline.xml",
        html_report = True,
        xml_report = True,
        build_upon_default_config = True,
        disable_default_rulesets = True,
        fail_fast = True,
        parallel = True,
        # The "plugins" option is skipped here since the path includes a declared Detekt version
        # and we do not want to change the test every time the Detekt artifact is updated.
        deps = ["@rules_detekt_dependencies//:org_jetbrains_kotlin_kotlin_stdlib"],
    )

    action_full_contents_test(
        name = "action_full_contents_test",
        target_under_test = ":test_target_full",
    )

# Action blank contents test

def _action_blank_contents_test_impl(ctx):
    env = analysistest.begin(ctx)

    actions = analysistest.target_actions(env)
    asserts.equals(env, 1, len(actions))

    expected_arguments = _expand_paths(env.ctx, [
        "bazel-out/host/bin/detekt/wrapper/bin",
        "--jvm_flag=-Xms16m",
        "--jvm_flag=-Xmx128m",
        "--input",
        "{{source_dir}}/path A.kt,{{source_dir}}/path B.kt,{{source_dir}}/path C.kt",
        "--report",
        "txt:{{output_dir}}/{{source_dir}}/test_target_blank_detekt_report.txt",
        "--language-version",
        "1.5",
        "--jvm-target",
        "1.8",
    ])

    expected_inputs = _expand_paths(env.ctx, [
        "{{source_dir}}/path A.kt",
        "{{source_dir}}/path B.kt",
        "{{source_dir}}/path C.kt",
        "bazel-out/host/internal/_middlemen/detekt_Swrapper_Sbin-runfiles",
        "bazel-out/host/bin/detekt/wrapper/bin.jar",
        "bazel-out/host/bin/detekt/wrapper/bin",
    ])

    expected_outputs = _expand_paths(env.ctx, [
        "{{output_dir}}/{{source_dir}}/test_target_blank_detekt_report.txt",
    ])

    action = actions[0]

    asserts.equals(env, expected_arguments, action.argv)
    asserts.equals(env, expected_inputs, [file.path for file in action.inputs.to_list()])
    asserts.equals(env, expected_outputs, [file.path for file in action.outputs.to_list()])

    return analysistest.end(env)

action_blank_contents_test = analysistest.make(_action_blank_contents_test_impl)

def _test_action_blank_contents():
    detekt(
        name = "test_target_blank",
        srcs = ["path A.kt", "path B.kt", "path C.kt"],
    )

    action_blank_contents_test(
        name = "action_blank_contents_test",
        target_under_test = ":test_target_blank",
    )

# Suite

def test_suite(name):
    _test_action_full_contents()
    _test_action_blank_contents()

    native.test_suite(
        name = name,
        tests = [
            ":action_full_contents_test",
            ":action_blank_contents_test",
        ],
    )
