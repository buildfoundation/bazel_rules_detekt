"""
The rule analysis tests.
"""

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts", "unittest")
load("//detekt:defs.bzl", "detekt", "detekt_create_baseline", "detekt_test")

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

def assert_input_contains(env, action, path):
    asserts.true(
        env,
        path in _input_short_paths(action.inputs),
        "Expected action inputs to contain {path}: {inputs}".format(
            path = path,
            inputs = _input_short_paths(action.inputs),
        ),
    )

def assert_input_lacks(env, action, path):
    asserts.false(
        env,
        path in _input_short_paths(action.inputs),
        "Expected action inputs to omit {path}: {inputs}".format(
            path = path,
            inputs = _input_short_paths(action.inputs),
        ),
    )

def assert_input_contains_suffix(env, action, suffix):
    for path in _input_short_paths(action.inputs):
        if path.endswith(suffix):
            return
    unittest.fail(
        env,
        "Expected action inputs to contain a path ending with '{suffix}': {inputs}".format(
            suffix = suffix,
            inputs = _input_short_paths(action.inputs),
        ),
    )

def assert_input_lacks_suffix(env, action, suffix):
    for path in _input_short_paths(action.inputs):
        asserts.false(
            env,
            path.endswith(suffix),
            "Expected action inputs to contain no path ending with '{suffix}': {inputs}".format(
                suffix = suffix,
                inputs = _input_short_paths(action.inputs),
            ),
        )

# Action full contents test

def _action_full_contents_test_impl(ctx):
    env = analysistest.begin(ctx)

    actions = analysistest.target_actions(env)
    asserts.equals(env, 6, len(actions))

    action = actions[0]
    assert_argv_contains_prefix_suffix(env, action, "bazel-out/", "/detekt/wrapper/bin")
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

# Version-specific failure policy

def _action_failure_policy_impl(ctx):
    env = analysistest.begin(ctx)

    actions = analysistest.target_actions(env)
    asserts.equals(env, 6, len(actions))

    action = actions[0]
    assert_argv_contains(env, action, "--fail-on-severity")
    assert_argv_contains(env, action, "Info")

    return analysistest.end(env)

action_failure_policy_test = analysistest.make(_action_failure_policy_impl)

def _test_action_failure_policy():
    detekt(
        name = "test_target_failure_policy",
        srcs = ["path A.kt", "path B.kt", "path C.kt"],
        fail_on_severity = "Info",
        tags = ["manual"],
    )

    action_failure_policy_test(
        name = "action_failure_policy_test",
        target_under_test = ":test_target_failure_policy",
    )

# Action toolchain inheritance and selection tests

def _action_toolchain_a_test_impl(ctx):
    env = analysistest.begin(ctx)

    actions = analysistest.target_actions(env)
    asserts.equals(env, 6, len(actions))

    action = actions[0]
    assert_argv_contains_prefix_suffix(env, action, "bazel-out/", "/tests/analysis/custom_detekt_wrapper")
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
    assert_argv_contains_prefix_suffix(env, action, "bazel-out/", "/libanalysis_plugin.jar")
    assert_argv_contains(env, action, "--report")
    assert_input_contains(env, action, _expand_path(ctx, "{{source_dir}}/config A.yml"))
    assert_input_lacks(env, action, _expand_path(ctx, "{{source_dir}}/config B.yml"))
    assert_input_contains_suffix(env, action, "/libanalysis_plugin.jar")
    assert_input_lacks_suffix(env, action, "/detekt/wrapper/bin")

    return analysistest.end(env)

action_toolchain_a_test = analysistest.make(
    _action_toolchain_a_test_impl,
    config_settings = {
        "//command_line_option:extra_toolchains": ["//tests/analysis:custom_defaults_toolchain"],
    },
)

def _test_action_toolchain_a():
    detekt(
        name = "test_target_toolchain_a_registered",
        srcs = ["path A.kt", "path B.kt", "path C.kt"],
        tags = ["manual"],
    )

    action_toolchain_a_test(
        name = "action_toolchain_a_registered_test",
        target_under_test = ":test_target_toolchain_a_registered",
    )

    detekt(
        name = "test_target_toolchain_a_direct",
        srcs = ["path A.kt", "path B.kt", "path C.kt"],
        detekt_toolchain = ":toolchain_a_impl",
        tags = ["manual"],
    )

    action_toolchain_a_test(
        name = "action_toolchain_a_direct_test",
        target_under_test = ":test_target_toolchain_a_direct",
    )

# Rule-level values explicitly clear or replace toolchain values.

def _action_toolchain_override_test_impl(ctx):
    env = analysistest.begin(ctx)

    actions = analysistest.target_actions(env)
    asserts.equals(env, 6, len(actions))

    action = actions[0]
    assert_argv_contains_prefix_suffix(env, action, "bazel-out/", "/tests/analysis/custom_detekt_wrapper")
    assert_argv_contains(env, action, "--jvm-target")
    assert_argv_contains(env, action, "11")
    assert_argv_contains(env, action, "--fail-on-severity")
    assert_argv_contains(env, action, "Info")
    assert_argv_lacks(env, action, "--config")
    assert_argv_lacks(env, action, "--build-upon-default-config")
    assert_argv_lacks(env, action, "--disable-default-rulesets")
    assert_argv_lacks(env, action, "--language-version")
    assert_argv_lacks(env, action, "--max-issues")
    assert_argv_lacks(env, action, "--parallel")
    assert_argv_lacks(env, action, "--plugins")
    assert_input_lacks(env, action, _expand_path(ctx, "{{source_dir}}/config A.yml"))
    assert_input_lacks_suffix(env, action, "/libanalysis_plugin.jar")

    return analysistest.end(env)

action_toolchain_override_test = analysistest.make(_action_toolchain_override_test_impl)

def _test_action_toolchain_override():
    detekt(
        name = "test_target_toolchain_override",
        srcs = ["path A.kt", "path B.kt", "path C.kt"],
        cfgs = [],
        detekt_toolchain = ":toolchain_a_impl",
        build_upon_default_config = False,
        disable_default_rulesets = False,
        jvm_target = "11",
        language_version = "",
        max_issues = -1,
        parallel = False,
        plugins = [],
        fail_on_severity = "Info",
        tags = ["manual"],
    )

    action_toolchain_override_test(
        name = "action_toolchain_override_test",
        target_under_test = ":test_target_toolchain_override",
    )

# The failure option selected on the rule replaces the toolchain's option.

def _action_toolchain_b_test_impl(ctx):
    env = analysistest.begin(ctx)

    actions = [
        action
        for action in analysistest.target_actions(env)
        if action.mnemonic == "Detekt"
    ]
    asserts.equals(env, 1, len(actions))

    action = actions[0]
    assert_argv_contains_prefix_suffix(env, action, "bazel-out/", "/detekt/wrapper/bin")
    assert_argv_contains(env, action, "--config")
    assert_argv_contains(env, action, _expand_path(ctx, "{{source_dir}}/config B.yml"))
    assert_argv_contains(env, action, "--jvm-target")
    assert_argv_contains(env, action, "11")
    assert_argv_contains(env, action, "--language-version")
    assert_argv_contains(env, action, "1.8")
    assert_argv_contains(env, action, "--max-issues")
    assert_argv_contains(env, action, "0")
    assert_argv_lacks(env, action, "--fail-on-severity")
    assert_argv_lacks(env, action, "--parallel")
    assert_argv_contains(env, action, "--run-as-test-target")
    assert_input_contains(env, action, _expand_path(ctx, "{{source_dir}}/config B.yml"))
    assert_input_lacks(env, action, _expand_path(ctx, "{{source_dir}}/config A.yml"))
    assert_input_lacks_suffix(env, action, "/libanalysis_plugin.jar")

    return analysistest.end(env)

action_toolchain_b_test = analysistest.make(_action_toolchain_b_test_impl)

def _test_action_toolchain_b():
    detekt_test(
        name = "test_target_toolchain_b",
        srcs = ["path A.kt", "path B.kt", "path C.kt"],
        detekt_toolchain = ":toolchain_b_impl",
        max_issues = 0,
        tags = ["manual"],
    )

    action_toolchain_b_test(
        name = "action_toolchain_b_test",
        target_under_test = ":test_target_toolchain_b",
    )

# Selectable rule values are resolved before applying the same precedence rules.

def _action_select_test_impl(ctx):
    env = analysistest.begin(ctx)

    actions = analysistest.target_actions(env)
    asserts.equals(env, 6, len(actions))

    action = actions[0]
    assert_argv_contains_prefix_suffix(env, action, "bazel-out/", "/detekt/wrapper/bin")
    assert_argv_contains(env, action, "--config")
    assert_argv_contains(env, action, _expand_path(ctx, "{{source_dir}}/config C.yml"))
    assert_argv_contains(env, action, "--jvm-target")
    assert_argv_contains(env, action, "17")
    assert_argv_contains(env, action, "--language-version")
    assert_argv_contains(env, action, "1.9")
    assert_argv_contains(env, action, "--max-issues")
    assert_argv_contains(env, action, "0")
    assert_argv_lacks(env, action, "--fail-on-severity")
    assert_argv_lacks(env, action, "--parallel")
    assert_input_contains(env, action, _expand_path(ctx, "{{source_dir}}/config C.yml"))
    assert_input_lacks(env, action, _expand_path(ctx, "{{source_dir}}/config B.yml"))
    assert_input_lacks_suffix(env, action, "/libanalysis_plugin.jar")

    return analysistest.end(env)

action_select_test = analysistest.make(
    _action_select_test_impl,
    config_settings = {
        "//command_line_option:compilation_mode": "opt",
    },
)

def _test_action_select():
    detekt(
        name = "test_target_select",
        srcs = ["path A.kt", "path B.kt", "path C.kt"],
        cfgs = select({
            ":select_toolchain_b": ["config C.yml"],
            "//conditions:default": ["config A.yml"],
        }),
        detekt_toolchain = select({
            ":select_toolchain_b": ":toolchain_b_impl",
            "//conditions:default": ":toolchain_a_impl",
        }),
        jvm_target = select({
            ":select_toolchain_b": "17",
            "//conditions:default": "11",
        }),
        language_version = select({
            ":select_toolchain_b": "1.9",
            "//conditions:default": "1.8",
        }),
        max_issues = select({
            ":select_toolchain_b": 0,
            "//conditions:default": -1,
        }),
        parallel = select({
            ":select_toolchain_b": False,
            "//conditions:default": True,
        }),
        tags = ["manual"],
    )

    action_select_test(
        name = "action_select_test",
        target_under_test = ":test_target_select",
    )

# A rule cannot activate both failure policies at once.

def _action_failure_policy_conflict_impl(ctx):
    env = analysistest.begin(ctx)
    asserts.expect_failure(env, "max_issues and fail_on_severity")
    return analysistest.end(env)

action_failure_policy_conflict_test = analysistest.make(
    _action_failure_policy_conflict_impl,
    expect_failure = True,
)

def _test_action_failure_policy_conflict():
    detekt(
        name = "test_target_failure_policy_conflict",
        srcs = ["path A.kt"],
        detekt_toolchain = ":toolchain_a_impl",
        max_issues = 0,
        fail_on_severity = "Error",
        tags = ["manual"],
    )

    action_failure_policy_conflict_test(
        name = "action_failure_policy_conflict_test",
        target_under_test = ":test_target_failure_policy_conflict",
    )

# Baseline creation uses the selected toolchain executable and inherited values.

def _action_baseline_test_impl(ctx):
    env = analysistest.begin(ctx)

    actions = analysistest.target_actions(env)
    asserts.equals(env, 6, len(actions))

    action = actions[0]
    assert_argv_contains_prefix_suffix(env, action, "bazel-out/", "/tests/analysis/custom_detekt_wrapper")
    assert_argv_contains(env, action, "--config")
    assert_argv_contains(env, action, _expand_path(ctx, "{{source_dir}}/config A.yml"))
    assert_argv_contains(env, action, "--create-baseline")
    assert_argv_contains_prefix_suffix(env, action, "", "_baseline.xml")
    assert_input_contains(env, action, _expand_path(ctx, "{{source_dir}}/config A.yml"))
    assert_input_contains_suffix(env, action, "/libanalysis_plugin.jar")

    return analysistest.end(env)

action_baseline_test = analysistest.make(_action_baseline_test_impl)

def _test_action_baseline():
    detekt_create_baseline(
        name = "test_target_baseline",
        srcs = ["path A.kt"],
        detekt_toolchain = ":toolchain_a_impl",
        tags = ["manual"],
    )

    action_baseline_test(
        name = "action_baseline_test",
        target_under_test = ":test_target_baseline",
    )

# Suite

def test_suite(name):
    """Declare the rule analysis test suite.

    Args:
      name: Name of the test suite target.
    """
    _test_action_full_contents()
    _test_action_blank_contents()
    _test_action_failure_policy()
    _test_action_toolchain_a()
    _test_action_toolchain_override()
    _test_action_toolchain_b()
    _test_action_select()
    _test_action_failure_policy_conflict()
    _test_action_baseline()

    native.test_suite(
        name = name,
        tests = [
            ":action_full_contents_test",
            ":action_blank_contents_test",
            ":action_failure_policy_test",
            ":action_toolchain_a_registered_test",
            ":action_toolchain_a_direct_test",
            ":action_toolchain_override_test",
            ":action_toolchain_b_test",
            ":action_select_test",
            ":action_failure_policy_conflict_test",
            ":action_baseline_test",
        ],
    )
