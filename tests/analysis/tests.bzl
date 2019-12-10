"""
The rule analysis tests.
"""

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")
load("@rules_detekt//detekt:detekt.bzl", "detekt")

def expand_paths(ctx, values):
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

    expected_arguments = expand_paths(env.ctx, [
        "java",
        "-Xms16m",
        "-Xmx128m",
        "-cp",
        "external/detekt_cli_jar/file/downloaded:{{output_dir}}/external/rules_detekt/detekt/wrapper/bin_deploy.jar",
        "io.buildfoundation.bazel.rulesdetekt.wrapper.Main",
        "--config",
        "{{source_dir}}/config.yml",
        "--input",
        "{{source_dir}}/path A,{{source_dir}}/path B,{{source_dir}}/path C",
        "--report",
        "txt:{{output_dir}}/{{source_dir}}/test_target_full_detekt_report.txt",
        "--report",
        "xml:{{output_dir}}/{{source_dir}}/test_target_full_detekt_report.xml",
        "--report",
        "html:{{output_dir}}/{{source_dir}}/test_target_full_detekt_report.html",
        "--build-upon-default-config",
        "--disable-default-rulesets",
        "--fail-fast",
        "--parallel",
    ])

    expected_inputs = expand_paths(env.ctx, [
        "{{source_dir}}/path A",
        "{{source_dir}}/path B",
        "{{source_dir}}/path C",
        "{{source_dir}}/config.yml",
        "{{output_dir}}/external/rules_detekt/detekt/wrapper/bin_deploy.jar",
        "external/detekt_cli_jar/file/downloaded",
    ])

    expected_outputs = expand_paths(env.ctx, [
        "{{output_dir}}/{{source_dir}}/test_target_full_detekt_report.txt",
        "{{output_dir}}/{{source_dir}}/test_target_full_detekt_report.xml",
        "{{output_dir}}/{{source_dir}}/test_target_full_detekt_report.html",
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
        srcs = ["path A", "path B", "path C"],
        config = "config.yml",
        html_report = True,
        xml_report = True,
        build_upon_default_config = True,
        disable_default_rulesets = True,
        fail_fast = True,
        parallel = True,
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

    expected_arguments = expand_paths(env.ctx, [
        "java",
        "-Xms16m",
        "-Xmx128m",
        "-cp",
        "external/detekt_cli_jar/file/downloaded:{{output_dir}}/external/rules_detekt/detekt/wrapper/bin_deploy.jar",
        "io.buildfoundation.bazel.rulesdetekt.wrapper.Main",
        "--input",
        "{{source_dir}}/path A,{{source_dir}}/path B,{{source_dir}}/path C",
        "--report",
        "txt:{{output_dir}}/{{source_dir}}/test_target_blank_detekt_report.txt",
    ])

    expected_inputs = expand_paths(env.ctx, [
        "{{source_dir}}/path A",
        "{{source_dir}}/path B",
        "{{source_dir}}/path C",
        "{{output_dir}}/external/rules_detekt/detekt/wrapper/bin_deploy.jar",
        "external/detekt_cli_jar/file/downloaded",
    ])

    expected_outputs = expand_paths(env.ctx, [
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
        srcs = ["path A", "path B", "path C"],
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
