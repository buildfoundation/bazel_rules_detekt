load("@bazel_skylib//rules:diff_test.bzl", "diff_test")
load("@bazel_skylib//rules:write_file.bzl", "write_file")
load("@rules_detekt//detekt:defs.bzl", "detekt_create_baseline", "detekt_test")
load("@rules_kotlin//kotlin:jvm.bzl", "kt_jvm_library")

package(default_visibility = ["//visibility:public"])

detekt_test(
    name = "compat_v1_test",
    srcs = [
        "src/Compat.kt",
        "src/CompatTypeResolution.kt",
    ],
    base_path = ".",
    cfgs = ["detekt.yml"],
    max_issues = 2,
    plugins = [":custom_rules"],
    txt_report = True,
    deps = [":compat_api"],
)

detekt_test(
    name = "expected_failure_test",
    srcs = ["src/Compat.kt"],
    base_path = ".",
    cfgs = ["detekt.yml"],
    max_issues = 0,
    plugins = [":custom_rules"],
    tags = ["manual"],
)

detekt_test(
    name = "compat_v1_report",
    srcs = [
        "src/Compat.kt",
        "src/CompatTypeResolution.kt",
    ],
    base_path = ".",
    cfgs = ["detekt.yml"],
    max_issues = 2,
    plugins = [":custom_rules"],
    xml_report = True,
    deps = [":compat_api"],
)

kt_jvm_library(
    name = "custom_rules",
    srcs = glob(["custom_rules/src/main/kotlin/**/*.kt"]),
    resources = glob(["custom_rules/src/main/resources/**"]),
    deps = ["@detekt_cli_all//jar"],
)

kt_jvm_library(
    name = "compat_api",
    srcs = ["src/CompatApi.kt"],
)

detekt_create_baseline(
    name = "baseline with spaces",
    srcs = ["src/Clean.kt"],
    tags = ["manual"],
)

detekt_create_baseline(
    name = "clean_baseline",
    srcs = ["src/Clean.kt"],
)

write_file(
    name = "clean_baseline_expected",
    out = "clean_baseline_expected.xml",
    content = [
        '<?xml version="1.0" ?>',
        "<SmellBaseline>",
        "  <ManuallySuppressedIssues></ManuallySuppressedIssues>",
        "  <CurrentIssues>",
        "  </CurrentIssues>",
        "</SmellBaseline>\n",
    ],
    newline = "unix",
)

diff_test(
    name = "clean_baseline_test",
    file1 = ":clean_baseline_expected",
    file2 = ":clean_baseline",
)

write_file(
    name = "compat_v1_report_expected",
    out = "compat_v1_report_expected.xml",
    content = [
        '<?xml version="1.0" encoding="UTF-8"?>',
        '<checkstyle version="4.3">',
        '<file name="src/Compat.kt">',
        '\t<error line="1" column="1" severity="warning" message="customRuleViolation is forbidden." source="detekt.ForbiddenFunctionName" />',
        "</file>",
        '<file name="src/CompatTypeResolution.kt">',
        '\t<error line="1" column="33" severity="warning" message="CompatApi.name()?.length contains an unnecessary safe call operator" source="detekt.UnnecessarySafeCall" />',
        "</file>",
        "</checkstyle>",
    ],
    newline = "unix",
)

diff_test(
    name = "compat_v1_report_test",
    file1 = ":compat_v1_report_expected",
    file2 = ":compat_v1_report",
)

genrule(
    name = "compat_v1_txt_report_normalized",
    testonly = True,
    srcs = [":compat_v1_test"],
    outs = ["compat_v1_txt_report_normalized.txt"],
    cmd = "sed -E 's# at .*/src/# at src/#' $(location :compat_v1_test) > $@",
    cmd_ps = """
$$text = [IO.File]::ReadAllText('$(location :compat_v1_test)').Replace('\\', '/')
$$text = $$text.Replace("`r`n", "`n") -replace ' at .*/src/', ' at src/'
[IO.File]::WriteAllText('$@', $$text, [Text.UTF8Encoding]::new($$false))
""",
)

write_file(
    name = "compat_v1_txt_report_expected",
    out = "compat_v1_txt_report_expected.txt",
    content = [
        "ForbiddenFunctionName - [customRuleViolation] at src/Compat.kt:1:1 - Signature=Compat.kt$fun customRuleViolation()",
        "UnnecessarySafeCall - [typeResolutionViolation] at src/CompatTypeResolution.kt:1:33 - Signature=CompatTypeResolution.kt$CompatApi.name()?.length\n",
    ],
    newline = "unix",
)

diff_test(
    name = "compat_v1_txt_report_test",
    file1 = ":compat_v1_txt_report_expected",
    file2 = ":compat_v1_txt_report_normalized",
)
