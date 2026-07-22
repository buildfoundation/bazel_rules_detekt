"""
The rule analysis tests.
"""

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts", "unittest")
load("//detekt:defs.bzl", "detekt")

def _expand_path(ctx, value):
    source_dir = ctx.build_file_path.replace("/BUILD", "")
    output_dir = ctx.bin_dir.path
    return value.replace("{{source_dir}}", source_dir).replace("{{output_dir}}", output_dir)

def _expand_paths(ctx, values):
    return [
        _expand_path(ctx, value)
        for value in values
    ]

def _input_short_path(file):
    path = file.short_path
    prefix = "_middlemen/"
    suffix = "-runfiles"
    if path.startswith(prefix) and path.endswith(suffix):
        # Bazel 8: _middlemen/detekt_Swrapper_Sbin-runfiles
        # Bazel 9: detekt/wrapper/bin.runfiles
        return path[len(prefix):len(path) - len(suffix)].replace("_S", "/") + ".runfiles"
    return path

def _input_short_paths(files):
    return [
        _input_short_path(file)
        for file in files.to_list()
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

def assert_argv_lacks(env, action, flag):
    asserts.false(
        env,
        flag in action.argv,
        "Expected {args} to not contain {flag}".format(args = action.argv, flag = flag),
    )

def assert_argv_lacks_prefix(env, action, prefix):
    for arg in action.argv:
        asserts.false(
            env,
            arg.startswith(prefix),
            "Expected {args} to contain no arg starting with {prefix}".format(args = action.argv, prefix = prefix),
        )

# Action full contents test

def _action_full_contents_test_impl(ctx):
    env = analysistest.begin(ctx)

    actions = analysistest.target_actions(env)
    asserts.equals(env, 6, len(actions))

    action = actions[0]
    assert_argv_contains_prefix_suffix(env, action, "bazel-out/", "/detekt/wrapper/bin")
    assert_argv_lacks_prefix(env, action, "--jvm_flag=")
    assert_argv_contains(env, action, "--input")
    assert_argv_contains(env, action, _expand_path(ctx, "{{source_dir}}/path A.kt,{{source_dir}}/path B.kt,{{source_dir}}/path C.kt"))

    # These values are supplied by custom_defaults_toolchain, not the target.
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
    assert_argv_contains(env, action, "--execution-result")
    assert_argv_contains(env, action, _expand_path(ctx, "{{output_dir}}/{{source_dir}}/test_target_full_exit_code.txt"))
    assert_argv_contains(env, action, "--build-upon-default-config")
    assert_argv_contains(env, action, "--disable-default-rulesets")
    assert_argv_contains(env, action, "--jvm-target")
    assert_argv_contains(env, action, "11")
    assert_argv_contains(env, action, "--language-version")
    assert_argv_contains(env, action, "2.0")
    assert_argv_contains(env, action, "--max-issues")
    assert_argv_contains(env, action, "7")
    assert_argv_contains(env, action, "--parallel")

    expected_inputs = _expand_paths(env.ctx, [
        "tests/analysis/path A.kt",
        "tests/analysis/path B.kt",
        "tests/analysis/path C.kt",
        "tests/analysis/config A.yml",
        "tests/analysis/config B.yml",
        "tests/analysis/config C.yml",
        "tests/analysis/baseline.xml",
        "detekt/wrapper/bin",
        "detekt/wrapper/bin.jar",
        "detekt/wrapper/bin.runfiles",
    ])

    expected_outputs = _expand_paths(env.ctx, [
        "{{source_dir}}/test_target_full_detekt_report.txt",
        "{{source_dir}}/test_target_full_detekt_report.html",
        "{{source_dir}}/test_target_full_detekt_report.xml",
        "{{source_dir}}/test_target_full_exit_code.txt",
    ])

    asserts.equals(env, expected_inputs, _input_short_paths(action.inputs))
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
        jvm_target = "11",
        language_version = "2.0",
        max_issues = 7,
        parallel = True,
        # The "plugins" option is skipped here since the path includes a declared Detekt version
        # and we do not want to change the test every time the Detekt artifact is updated.
        tags = ["manual"],
    )

    action_full_contents_test(
        name = "action_full_contents_test",
        target_under_test = ":test_target_full",
    )

# Action blank contents test

def _action_blank_contents_test_impl(ctx):
    env = analysistest.begin(ctx)

    actions = analysistest.target_actions(env)
    asserts.equals(env, 6, len(actions))

    action = actions[0]
    assert_argv_contains_prefix_suffix(env, action, "bazel-out/", "/detekt/wrapper/bin")
    assert_argv_lacks_prefix(env, action, "--jvm_flag=")
    assert_argv_contains(env, action, "--input")
    assert_argv_contains(env, action, _expand_path(ctx, "{{source_dir}}/path A.kt,{{source_dir}}/path B.kt,{{source_dir}}/path C.kt"))
    assert_argv_contains(env, action, "--jvm-target")
    assert_argv_contains(env, action, "1.8")
    assert_argv_lacks(env, action, "--language-version")
    assert_argv_lacks(env, action, "--max-issues")
    assert_argv_lacks(env, action, "--parallel")
    assert_argv_contains(env, action, "--report")
    assert_argv_contains_prefix_suffix(env, action, "txt:", _expand_path(ctx, "{{source_dir}}/test_target_blank_detekt_report.txt"))

    expected_inputs = _expand_paths(env.ctx, [
        "tests/analysis/path A.kt",
        "tests/analysis/path B.kt",
        "tests/analysis/path C.kt",
        "detekt/wrapper/bin",
        "detekt/wrapper/bin.jar",
        "detekt/wrapper/bin.runfiles",
    ])

    expected_outputs = _expand_paths(env.ctx, [
        "{{source_dir}}/test_target_blank_detekt_report.txt",
        "{{source_dir}}/test_target_blank_exit_code.txt",
    ])

    asserts.equals(env, expected_inputs, _input_short_paths(action.inputs))
    asserts.equals(env, expected_outputs, [file.short_path for file in action.outputs.to_list()])

    return analysistest.end(env)

action_blank_contents_test = analysistest.make(_action_blank_contents_test_impl)

def _test_action_blank_contents():
    detekt(
        name = "test_target_blank",
        srcs = ["path A.kt", "path B.kt", "path C.kt"],
        tags = ["manual"],
    )

    action_blank_contents_test(
        name = "action_blank_contents_test",
        target_under_test = ":test_target_blank",
    )

# Action toolchain defaults test

def _action_toolchain_defaults_test_impl(ctx):
    env = analysistest.begin(ctx)

    actions = analysistest.target_actions(env)
    asserts.equals(env, 6, len(actions))

    action = actions[0]
    assert_argv_contains_prefix_suffix(env, action, "bazel-out/", "/detekt/wrapper/bin")
    assert_argv_lacks_prefix(env, action, "--jvm_flag=")
    assert_argv_contains(env, action, "--input")
    assert_argv_contains(env, action, _expand_path(ctx, "{{source_dir}}/path A.kt,{{source_dir}}/path B.kt,{{source_dir}}/path C.kt"))
    assert_argv_contains(env, action, "--config")
    assert_argv_contains(env, action, _expand_path(ctx, "{{source_dir}}/config A.yml"))
    assert_argv_contains(env, action, "--build-upon-default-config")
    assert_argv_contains(env, action, "--disable-default-rulesets")
    assert_argv_contains(env, action, "--jvm-target")
    assert_argv_contains(env, action, "17")
    assert_argv_contains(env, action, "--language-version")
    assert_argv_contains(env, action, "1.9")
    assert_argv_contains(env, action, "--max-issues")
    assert_argv_contains(env, action, "3")
    assert_argv_contains(env, action, "--parallel")
    assert_argv_contains(env, action, "--plugins")
    assert_argv_contains_prefix_suffix(env, action, "", "/downloaded.jar")
    assert_argv_contains(env, action, "--report")
    assert_argv_contains_prefix_suffix(env, action, "txt:", _expand_path(ctx, "{{source_dir}}/test_target_toolchain_defaults_detekt_report.txt"))

    expected_outputs = _expand_paths(env.ctx, [
        "{{source_dir}}/test_target_toolchain_defaults_detekt_report.txt",
        "{{source_dir}}/test_target_toolchain_defaults_exit_code.txt",
    ])

    asserts.equals(env, expected_outputs, [file.short_path for file in action.outputs.to_list()])

    return analysistest.end(env)

action_toolchain_defaults_test = analysistest.make(
    _action_toolchain_defaults_test_impl,
    config_settings = {
        "//command_line_option:extra_toolchains": ["//tests/analysis:custom_defaults_toolchain"],
    },
)

def _test_action_toolchain_defaults():
    detekt(
        name = "test_target_toolchain_defaults",
        srcs = ["path A.kt", "path B.kt", "path C.kt"],
        tags = ["manual"],
    )

    action_toolchain_defaults_test(
        name = "action_toolchain_defaults_test",
        target_under_test = ":test_target_toolchain_defaults",
    )

# Suite

def test_suite(name):
    _test_action_full_contents()
    _test_action_blank_contents()
    _test_action_toolchain_defaults()

    native.test_suite(
        name = name,
        tests = [
            ":action_full_contents_test",
            ":action_blank_contents_test",
            ":action_toolchain_defaults_test",
        ],
    )
