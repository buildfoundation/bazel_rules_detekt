"""
The rule analysis tests.
"""

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts", "unittest")
load("//detekt:defs.bzl", "detekt", "detekt_create_baseline")

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
    path = file.short_path.replace("\\", "/")
    prefix = "_middlemen/"
    suffix = "-runfiles"
    if path.startswith(prefix) and path.endswith(suffix):
        # Bazel 8: _middlemen/detekt_Swrapper_Sbin-runfiles
        # Bazel 9: detekt/wrapper/bin.runfiles
        path = path[len(prefix):len(path) - len(suffix)].replace("_S", "/") + ".runfiles"
    if path.endswith(".exe.runfiles"):
        return path[:-len(".exe.runfiles")] + ".runfiles"
    if path.endswith(".exe.runfiles_manifest"):
        return path[:-len(".exe.runfiles_manifest")] + ".runfiles_manifest"
    if path.endswith(".exe"):
        return path[:-len(".exe")]
    return path

def _input_short_paths(files):
    return [
        _input_short_path(file)
        for file in files.to_list()
    ]

def _normalize_path(value):
    return value.replace("\\", "/")

def _assert_wrapper_inputs(env, action):
    wrapper_paths = [
        _input_short_path(file)
        for file in action.inputs.to_list()
        if _normalize_path(file.short_path).startswith("detekt/wrapper/bin") or _normalize_path(file.short_path).startswith("_middlemen/detekt_Swrapper_Sbin")
    ]
    asserts.true(
        env,
        "detekt/wrapper/bin" in wrapper_paths,
        "Expected the Detekt wrapper executable in {paths}".format(paths = wrapper_paths),
    )
    asserts.true(
        env,
        "detekt/wrapper/bin.jar" in wrapper_paths,
        "Expected the Detekt wrapper jar in {paths}".format(paths = wrapper_paths),
    )
    asserts.true(
        env,
        any([path.endswith(".runfiles") for path in wrapper_paths]) or any([path.endswith(".runfiles_manifest") for path in wrapper_paths]),
        "Expected wrapper runfiles in {paths}".format(paths = wrapper_paths),
    )
    allowed_wrapper_paths = [
        "detekt/wrapper/bin",
        "detekt/wrapper/bin.jar",
        "detekt/wrapper/bin.runfiles",
        "detekt/wrapper/bin.runfiles_manifest",
    ]
    asserts.equals(
        env,
        sorted([path for path in wrapper_paths if path in allowed_wrapper_paths]),
        sorted(wrapper_paths),
    )

def assert_argv_contains_prefix_suffix(env, action, prefix, suffix):
    """Fails unless an action argument has the requested prefix and suffix.

    Args:
      env: Analysis test environment.
      action: Action whose arguments are inspected.
      prefix: Required argument prefix.
      suffix: Required argument suffix.
    """
    for arg in action.argv:
        normalized = _normalize_path(arg)
        if normalized.startswith(_normalize_path(prefix)) and normalized.endswith(_normalize_path(suffix)):
            return
    unittest.fail(
        env,
        "Expected an arg with prefix '{prefix}' and suffix '{suffix}' in {args}".format(
            prefix = prefix,
            suffix = suffix,
            args = action.argv,
        ),
    )

def _assert_argv_contains_executable(env, action, prefix, suffix):
    for arg in action.argv:
        normalized = _normalize_path(arg)
        if (normalized.startswith(_normalize_path(prefix)) or "/" + _normalize_path(prefix) in normalized) and (normalized.endswith(_normalize_path(suffix)) or normalized.endswith(_normalize_path(suffix + ".exe"))):
            return
    unittest.fail(
        env,
        "Expected an executable arg with prefix '{prefix}' and suffix '{suffix}' in {args}".format(
            prefix = prefix,
            suffix = suffix,
            args = action.argv,
        ),
    )

def assert_argv_contains(env, action, flag):
    asserts.true(
        env,
        flag in [_normalize_path(arg) for arg in action.argv],
        "Expected {args} to contain {flag}".format(args = action.argv, flag = flag),
    )

# Action full contents test

def _action_full_contents_test_impl(ctx):
    env = analysistest.begin(ctx)

    actions = [action for action in analysistest.target_actions(env) if action.mnemonic == "Detekt"]
    asserts.equals(env, 1, len(actions))

    action = actions[0]
    _assert_argv_contains_executable(env, action, "bazel-out/", "/detekt/wrapper/bin")
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
    assert_argv_contains(env, action, "--execution-result")
    assert_argv_contains(env, action, _expand_path(ctx, "{{output_dir}}/{{source_dir}}/test_target_full_exit_code.txt"))
    assert_argv_contains(env, action, "--build-upon-default-config")
    assert_argv_contains(env, action, "--disable-default-rulesets")
    assert_argv_contains(env, action, "--parallel")

    expected_inputs = _expand_paths(env.ctx, [
        "tests/analysis/path A.kt",
        "tests/analysis/path B.kt",
        "tests/analysis/path C.kt",
        "tests/analysis/config A.yml",
        "tests/analysis/config B.yml",
        "tests/analysis/config C.yml",
        "tests/analysis/baseline.xml",
    ])

    actual_inputs = _input_short_paths(action.inputs)
    asserts.equals(
        env,
        sorted(expected_inputs),
        sorted([path for path in actual_inputs if not path.startswith("detekt/wrapper/bin")]),
    )
    _assert_wrapper_inputs(env, action)

    expected_outputs = _expand_paths(env.ctx, [
        "{{source_dir}}/test_target_full_detekt_report.txt",
        "{{source_dir}}/test_target_full_detekt_report.html",
        "{{source_dir}}/test_target_full_detekt_report.xml",
        "{{source_dir}}/test_target_full_exit_code.txt",
    ])

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

    actions = [action for action in analysistest.target_actions(env) if action.mnemonic == "Detekt"]
    asserts.equals(env, 1, len(actions))

    action = actions[0]
    _assert_argv_contains_executable(env, action, "bazel-out/", "/detekt/wrapper/bin")
    assert_argv_contains(env, action, "--jvm_flag=-Xms16m")
    assert_argv_contains(env, action, "--jvm_flag=-Xmx128m")
    assert_argv_contains(env, action, "--input")
    assert_argv_contains(env, action, _expand_path(ctx, "{{source_dir}}/path A.kt,{{source_dir}}/path B.kt,{{source_dir}}/path C.kt"))
    assert_argv_contains(env, action, "--report")
    assert_argv_contains_prefix_suffix(env, action, "txt:", _expand_path(ctx, "{{source_dir}}/test_target_blank_detekt_report.txt"))

    expected_inputs = _expand_paths(env.ctx, [
        "tests/analysis/path A.kt",
        "tests/analysis/path B.kt",
        "tests/analysis/path C.kt",
    ])

    actual_inputs = _input_short_paths(action.inputs)
    asserts.equals(
        env,
        sorted(expected_inputs),
        sorted([path for path in actual_inputs if not path.startswith("detekt/wrapper/bin")]),
    )
    _assert_wrapper_inputs(env, action)

    expected_outputs = _expand_paths(env.ctx, [
        "{{source_dir}}/test_target_blank_detekt_report.txt",
        "{{source_dir}}/test_target_blank_exit_code.txt",
    ])

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

    actions = [action for action in analysistest.target_actions(env) if action.mnemonic == "Detekt"]
    asserts.equals(env, 1, len(actions))

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

# Windows result launcher selection

def _windows_result_launcher_test_impl(ctx):
    env = analysistest.begin(ctx)
    target = analysistest.target_under_test(env)
    executable = target[DefaultInfo].files_to_run.executable

    asserts.true(env, executable.short_path.endswith(".bat"))
    asserts.false(env, executable.short_path.endswith(".sh"))

    launcher_actions = [
        action
        for action in analysistest.target_actions(env)
        if action.mnemonic == "TemplateExpand" and action.outputs.to_list()[0].short_path.endswith(".bat")
    ]
    asserts.equals(env, 1, len(launcher_actions))
    launcher_inputs = _input_short_paths(launcher_actions[0].inputs)
    asserts.equals(env, ["detekt/result_script.bat.tpl"], launcher_inputs)

    runfile_paths = [
        file.short_path
        for file in target[DefaultInfo].default_runfiles.files.to_list()
    ]
    asserts.true(env, "tests/analysis/test_target_windows_launcher_exit_code.txt" in runfile_paths)
    asserts.true(env, "tests/analysis/test_target_windows_launcher_detekt_report.txt" in runfile_paths)
    asserts.true(env, "tests/analysis/test_target_windows_launcher_baseline.xml" in runfile_paths)

    return analysistest.end(env)

windows_result_launcher_test = analysistest.make(
    _windows_result_launcher_test_impl,
    config_settings = {
        "//command_line_option:platforms": str(Label("//tests/analysis:windows_platform")),
    },
)

def _test_windows_result_launcher():
    detekt_create_baseline(
        name = "test_target_windows_launcher",
        srcs = ["path A.kt"],
        baseline = "baseline.xml",
        tags = ["manual"],
    )

    windows_result_launcher_test(
        name = "windows_result_launcher_test",
        target_under_test = ":test_target_windows_launcher",
    )

# Suite

def test_suite(name):
    """Creates the Detekt rule analysis test suite.

    Args:
      name: Name of the generated test suite.
    """
    _test_action_full_contents()
    _test_action_blank_contents()
    _test_action_failure_policy()
    _test_windows_result_launcher()

    native.test_suite(
        name = name,
        tests = [
            ":action_full_contents_test",
            ":action_blank_contents_test",
            ":action_failure_policy_test",
            ":windows_result_launcher_test",
        ],
    )
