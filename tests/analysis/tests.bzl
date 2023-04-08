"""
The rule analysis tests.
"""

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts", "unittest")
load("@rules_detekt//detekt:defs.bzl", "detekt")

def _expand_path(ctx, value):
    source_dir = ctx.build_file_path.replace("/BUILD", "")
    output_dir = ctx.bin_dir.path
    return value.replace("{{source_dir}}", source_dir).replace("{{output_dir}}", output_dir)

def _expand_paths(ctx, values):
    return [
        _expand_path(ctx, value)
        for value in values
    ]

def assert_argv_contains_prefix_suffix(env, action, prefix, suffix):
    for arg in action.argv:
        if arg.startswith(prefix) and arg.endswith(suffix):
            return
    unittest.fail(
        env,
        "Expected an arg with prefix '{prefix}' and suffix '{suffix}' in {args}".format(
            prefix = prefix,
            suffix = suffix,
            args = action.argv,
        ),
    )

def assert_argv_contains(env, action, flag):
    asserts.true(
        env,
        flag in action.argv,
        "Expected {args} to contain {flag}".format(args = action.argv, flag = flag),
    )

# Action full contents test

def _action_full_contents_test_impl(ctx):
    env = analysistest.begin(ctx)

    actions = analysistest.target_actions(env)
    asserts.equals(env, 1, len(actions))

    action = actions[0]
    assert_argv_contains_prefix_suffix(env, action, "bazel-out/", "/detekt/wrapper/bin")
    assert_argv_contains(env, action, "--jvm_flag=-Xms16m")
    assert_argv_contains(env, action, "--jvm_flag=-Xmx128m")
    assert_argv_contains(env, action, "--input")
    assert_argv_contains(env, action, _expand_path(ctx, "{{source_dir}}/path A.kt,{{source_dir}}/path B.kt,{{source_dir}}/path C.kt"))
    assert_argv_contains(env, action, "--config")
    assert_argv_contains(env, action, _expand_path(ctx, "{{source_dir}}/config A.yml,{{source_dir}}/config B.yml,{{source_dir}}/config C.yml"))
    assert_argv_contains(env, action, "--baseline")
    assert_argv_contains(env, action, _expand_path(ctx, "{{source_dir}}/baseline.xml"))
    assert_argv_contains(env, action, "--report")
    assert_argv_contains(env, action, _expand_path(ctx, "html:{{output_dir}}/{{source_dir}}/test_target_full_detekt_report.html"))
    assert_argv_contains(env, action, "--report")
    assert_argv_contains(env, action, _expand_path(ctx, "txt:{{output_dir}}/{{source_dir}}/test_target_full_detekt_report.txt"))
    assert_argv_contains(env, action, "--report")
    assert_argv_contains(env, action, _expand_path(ctx, "xml:{{output_dir}}/{{source_dir}}/test_target_full_detekt_report.xml"))
    assert_argv_contains(env, action, "--build-upon-default-config")
    assert_argv_contains(env, action, "--disable-default-rulesets")
    assert_argv_contains(env, action, "--fail-fast")
    assert_argv_contains(env, action, "--parallel")

    expected_inputs = _expand_paths(env.ctx, [
        "{{source_dir}}/path A.kt",
        "{{source_dir}}/path B.kt",
        "{{source_dir}}/path C.kt",
        "{{source_dir}}/config A.yml",
        "{{source_dir}}/config B.yml",
        "{{source_dir}}/config C.yml",
        "{{source_dir}}/baseline.xml",
        "_middlemen/detekt_Swrapper_Sbin-runfiles",
        "detekt/wrapper/bin.jar",
        "detekt/wrapper/bin",
    ])

    expected_outputs = _expand_paths(env.ctx, [
        "{{source_dir}}/test_target_full_detekt_report.html",
        "{{source_dir}}/test_target_full_detekt_report.txt",
        "{{source_dir}}/test_target_full_detekt_report.xml",
    ])

    asserts.equals(env, expected_inputs, [file.short_path for file in action.inputs.to_list()])
    asserts.equals(env, expected_outputs, [file.short_path for file in action.outputs.to_list()])

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

    action = actions[0]
    assert_argv_contains_prefix_suffix(env, action, "bazel-out/", "/detekt/wrapper/bin")
    assert_argv_contains(env, action, "--jvm_flag=-Xms16m")
    assert_argv_contains(env, action, "--jvm_flag=-Xmx128m")
    assert_argv_contains(env, action, "--input")
    assert_argv_contains(env, action, _expand_path(ctx, "{{source_dir}}/path A.kt,{{source_dir}}/path B.kt,{{source_dir}}/path C.kt"))
    assert_argv_contains(env, action, "--report")
    assert_argv_contains_prefix_suffix(env, action, "txt:", _expand_path(ctx, "{{source_dir}}/test_target_blank_detekt_report.txt"))

    expected_inputs = _expand_paths(env.ctx, [
        "{{source_dir}}/path A.kt",
        "{{source_dir}}/path B.kt",
        "{{source_dir}}/path C.kt",
        "_middlemen/detekt_Swrapper_Sbin-runfiles",
        "detekt/wrapper/bin.jar",
        "detekt/wrapper/bin",
    ])

    expected_outputs = _expand_paths(env.ctx, [
        "{{source_dir}}/test_target_blank_detekt_report.txt",
    ])

    asserts.equals(env, expected_inputs, [file.short_path for file in action.inputs.to_list()])
    asserts.equals(env, expected_outputs, [file.short_path for file in action.outputs.to_list()])

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
