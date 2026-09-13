"""
The rule analysis tests.
"""

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts", "unittest")
load("//detekt:config.bzl", "detekt_config")
load("//detekt:defs.bzl", "detekt", "detekt_create_baseline", "detekt_test")

def _assert_rule_kind(name, expected):
    rule = native.existing_rule(name)
    if rule == None or rule["kind"] != expected:
        fail("Expected {} to have kind {}, got {}".format(name, expected, rule))
    for option in [
        "cfgs",
        "plugins",
        "build_upon_default_config",
        "disable_default_rulesets",
        "jvm_target",
        "language_version",
        "max_issues",
        "fail_on_severity",
        "parallel",
    ]:
        if option in rule:
            fail("{} must be configured on detekt_config, not {}".format(option, expected))

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
    detekt_config(
        name = "full_config",
        cfgs = ["config A.yml", "config B.yml", "config C.yml"],
        build_upon_default_config = True,
        disable_default_rulesets = True,
        jvm_target = "11",
        language_version = "2.0",
        max_issues = 7,
        parallel = True,
    )
    detekt(
        name = "test_target_full",
        srcs = ["path A.kt", "path B.kt", "path C.kt"],
        config = ":full_config",
        baseline = "baseline.xml",
        html_report = True,
        xml_report = True,
        # The "plugins" option is skipped here since the path includes a declared Detekt version
        # and we do not want to change the test every time the Detekt artifact is updated.
        tags = ["manual"],
    )
    _assert_rule_kind("test_target_full", "detekt")

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
    detekt_config(name = "info_config", fail_on_severity = "Info")
    detekt(
        name = "test_target_failure_policy",
        srcs = ["path A.kt", "path B.kt", "path C.kt"],
        config = ":info_config",
        tags = ["manual"],
    )

    action_failure_policy_test(
        name = "action_failure_policy_test",
        target_under_test = ":test_target_failure_policy",
    )

# Action toolchain configuration and selection tests

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

# A second toolchain has independent configuration and failure policy.

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
    assert_argv_lacks(env, action, "--max-issues")
    assert_argv_contains(env, action, "--fail-on-severity")
    assert_argv_contains(env, action, "Warning")
    assert_argv_lacks(env, action, "--parallel")
    assert_argv_lacks(env, action, "--build-upon-default-config")
    assert_argv_lacks(env, action, "--disable-default-rulesets")
    assert_argv_contains(env, action, "--run-as-test-target")
    assert_input_contains(env, action, _expand_path(ctx, "{{source_dir}}/config B.yml"))
    assert_input_lacks(env, action, _expand_path(ctx, "{{source_dir}}/config A.yml"))
    assert_input_lacks_suffix(env, action, "/libanalysis_plugin.jar")

    return analysistest.end(env)

action_toolchain_b_test = analysistest.make(
    _action_toolchain_b_test_impl,
    config_settings = {
        "//command_line_option:compilation_mode": "fastbuild",
    },
)

def _test_action_toolchain_b():
    detekt_test(
        name = "test_target_toolchain_b",
        srcs = ["path A.kt", "path B.kt", "path C.kt"],
        detekt_toolchain = ":toolchain_b_impl",
        tags = ["manual"],
    )
    _assert_rule_kind("test_target_toolchain_b", "detekt_test")

    action_toolchain_b_test(
        name = "action_toolchain_b_test",
        target_under_test = ":test_target_toolchain_b",
    )

# Toolchain selection can be configurable without mixing profile options.

def _action_select_test_impl(ctx):
    env = analysistest.begin(ctx)

    actions = analysistest.target_actions(env)
    asserts.equals(env, 6, len(actions))

    action = actions[0]
    assert_argv_contains_prefix_suffix(env, action, "bazel-out/", "/detekt/wrapper/bin")
    assert_argv_contains(env, action, "--config")
    assert_argv_contains(env, action, _expand_path(ctx, "{{source_dir}}/config B.yml"))
    assert_argv_contains(env, action, "--jvm-target")
    assert_argv_contains(env, action, "11")
    assert_argv_contains(env, action, "--language-version")
    assert_argv_contains(env, action, "1.8")
    assert_argv_lacks(env, action, "--max-issues")
    assert_argv_contains(env, action, "--fail-on-severity")
    assert_argv_contains(env, action, "Warning")
    assert_argv_lacks(env, action, "--parallel")
    assert_input_contains(env, action, _expand_path(ctx, "{{source_dir}}/config B.yml"))
    assert_input_lacks(env, action, _expand_path(ctx, "{{source_dir}}/config A.yml"))
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
        detekt_toolchain = select({
            ":select_toolchain_b": ":toolchain_b_impl",
            "//conditions:default": ":toolchain_a_impl",
        }),
        tags = ["manual"],
    )

    action_select_test(
        name = "action_select_test",
        target_under_test = ":test_target_select",
    )

# A config cannot activate both failure policies at once.

def _action_failure_policy_conflict_impl(ctx):
    env = analysistest.begin(ctx)
    asserts.expect_failure(env, "max_issues and fail_on_severity")
    return analysistest.end(env)

action_failure_policy_conflict_test = analysistest.make(
    _action_failure_policy_conflict_impl,
    expect_failure = True,
)

def _test_action_failure_policy_conflict():
    detekt_config(
        name = "conflicting_config",
        max_issues = 0,
        fail_on_severity = "Error",
        tags = ["manual"],
    )
    detekt(
        name = "test_target_failure_policy_conflict",
        srcs = ["path A.kt"],
        config = ":conflicting_config",
        tags = ["manual"],
    )

    action_failure_policy_conflict_test(
        name = "action_failure_policy_conflict_test",
        target_under_test = ":test_target_failure_policy_conflict",
    )

# Baseline creation uses the selected toolchain executable and configuration.

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

action_baseline_test = analysistest.make(
    _action_baseline_test_impl,
    config_settings = {
        "//command_line_option:compilation_mode": "fastbuild",
    },
)

def _test_action_baseline():
    detekt_create_baseline(
        name = "test_target_baseline",
        srcs = ["path A.kt"],
        detekt_toolchain = ":toolchain_a_impl",
        tags = ["manual"],
    )
    _assert_rule_kind("test_target_baseline", "detekt_create_baseline")

    action_baseline_test(
        name = "action_baseline_test",
        target_under_test = ":test_target_baseline",
    )

# Explicit profiles replace all defaults without changing the executable.

def _action_config_override_impl(ctx):
    env = analysistest.begin(ctx)
    action = [a for a in analysistest.target_actions(env) if a.mnemonic == "Detekt"][0]
    assert_argv_contains_prefix_suffix(env, action, "bazel-out/", "/tests/analysis/custom_detekt_wrapper")
    for flag in [
        "--build-upon-default-config",
        "--disable-default-rulesets",
        "--parallel",
        "--max-issues",
    ]:
        assert_argv_lacks(env, action, flag)
    assert_input_lacks(env, action, _expand_path(ctx, "{{source_dir}}/config A.yml"))
    assert_input_lacks_suffix(env, action, "/libanalysis_plugin.jar")
    if ctx.attr.empty:
        assert_argv_contains(env, action, "1.8")
        assert_argv_lacks(env, action, "--config")
        assert_argv_lacks(env, action, "--plugins")
        assert_argv_lacks(env, action, "--language-version")
        assert_argv_lacks(env, action, "--fail-on-severity")
    else:
        assert_argv_contains(env, action, "11")
        assert_argv_contains(env, action, "--fail-on-severity")
        assert_argv_contains(env, action, "Warning")
        assert_input_contains(env, action, _expand_path(ctx, "{{source_dir}}/config B.yml"))
    return analysistest.end(env)

action_config_override_test = analysistest.make(
    _action_config_override_impl,
    attrs = {"empty": attr.bool()},
    config_settings = {
        "//command_line_option:extra_toolchains": ["//tests/analysis:custom_defaults_toolchain"],
        "//command_line_option:compilation_mode": "fastbuild",
    },
)

action_config_none_test = analysistest.make(
    _action_toolchain_a_test_impl,
    config_settings = {
        "//command_line_option:extra_toolchains": ["//tests/analysis:custom_defaults_toolchain"],
        "//command_line_option:compilation_mode": "opt",
    },
)

def _action_target_config_impl(ctx):
    env = analysistest.begin(ctx)
    action = [a for a in analysistest.target_actions(env) if a.mnemonic == "Detekt"][0]
    assert_argv_contains(env, action, "--jvm-target")
    assert_argv_contains(env, action, "17")
    assert_argv_lacks(env, action, "11")
    return analysistest.end(env)

action_target_config_test = analysistest.make(
    _action_target_config_impl,
    config_settings = {
        "//command_line_option:extra_toolchains": ["//tests/analysis:target_config_toolchain"],
        "//command_line_option:compilation_mode": "fastbuild",
    },
)

def _test_config_profiles():
    tests = []
    for name, attrs in {
        "explicit_config": {"config": ":target_config"},
        "direct_toolchain_config": {"detekt_toolchain": ":target_config_toolchain_impl"},
        "registered_toolchain_config": {},
    }.items():
        detekt(
            name = name,
            srcs = ["path A.kt"],
            tags = ["manual"],
            **attrs
        )
        action_target_config_test(
            name = name + "_test",
            target_under_test = ":" + name,
        )
        tests.append(":" + name + "_test")

    for kind, rule in [
        ("detekt", detekt),
        ("detekt_test", detekt_test),
        ("detekt_create_baseline", detekt_create_baseline),
    ]:
        for profile in ["config_b", "empty_config"]:
            name = kind + "_" + profile
            rule(
                name = name,
                srcs = ["path A.kt", "path B.kt", "path C.kt"],
                config = ":" + profile,
                detekt_toolchain = ":toolchain_a_impl" if kind == "detekt_create_baseline" else None,
                tags = ["manual"],
            )
            action_config_override_test(
                name = name + "_test",
                target_under_test = ":" + name,
                empty = profile == "empty_config",
            )
            tests.append(":" + name + "_test")

    # Both branches exercise the same target: None inherits, a label replaces.
    detekt(
        name = "conditional_config",
        srcs = ["path A.kt", "path B.kt", "path C.kt"],
        config = select({
            ":select_toolchain_b": None,
            "//conditions:default": ":config_b",
        }),
        tags = ["manual"],
    )
    action_config_none_test(
        name = "conditional_config_none_test",
        target_under_test = ":conditional_config",
    )
    action_config_override_test(
        name = "conditional_config_label_test",
        target_under_test = ":conditional_config",
    )
    tests.extend([":conditional_config_none_test", ":conditional_config_label_test"])
    return tests

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
    _test_action_toolchain_b()
    _test_action_select()
    _test_action_failure_policy_conflict()
    _test_action_baseline()
    config_tests = _test_config_profiles()

    native.test_suite(
        name = name,
        tests = config_tests + [
            ":action_full_contents_test",
            ":action_blank_contents_test",
            ":action_failure_policy_test",
            ":action_toolchain_a_registered_test",
            ":action_toolchain_a_direct_test",
            ":action_toolchain_b_test",
            ":action_select_test",
            ":action_failure_policy_conflict_test",
            ":action_baseline_test",
        ],
    )
