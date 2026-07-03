load("@bazel_skylib//rules:diff_test.bzl", "diff_test")
load("@bazel_skylib//rules:write_file.bzl", "write_file")
load("//detekt:defs.bzl", "detekt_test")

detekt_test(
    name = "jvm_static_analysis_test",
    srcs = ["//tests/integration/testFixtures/basic-jvm:jvm_static_srcs"],
)

detekt_test(
    name = "jvm_classpath_analysis_test",
    srcs = ["//tests/integration/testFixtures/basic-jvm:jvm_classpath_srcs"],
    base_path = ".",
    cfgs = ["detekt_type_resolution.yml"],
    max_issues = 2,
    xml_report = True,
    deps = ["//tests/integration/testFixtures/basic-jvm:jvm_api"],
)

detekt_test(
    name = "android_static_analysis_test",
    srcs = ["//tests/integration/testFixtures/basic-android:android_static_srcs"],
)

detekt_test(
    name = "android_classpath_analysis_test",
    srcs = ["//tests/integration/testFixtures/basic-android:android_classpath_srcs"],
    base_path = ".",
    cfgs = ["detekt_type_resolution.yml"],
    is_android = True,
    max_issues = 2,
    xml_report = True,
    deps = ["//tests/integration/testFixtures/basic-android:android_api"],
)

detekt_test(
    name = "custom_rule_analysis_test",
    srcs = ["//tests/integration/testFixtures/custom-rule:custom_rule_violation_srcs"],
    base_path = ".",
    cfgs = ["//tests/integration/testFixtures/custom-rule:custom_rule_config"],
    max_issues = 1,
    plugins = ["//tests/integration/testFixtures/custom-rule:custom_rules"],
    xml_report = True,
)

JVM_CLASSPATH_REPORT_XML = """<?xml version="1.0" encoding="UTF-8"?>
<checkstyle version="4.3">
<file name="tests/integration/testFixtures/basic-jvm/src/jvm/tests/integration/jvm/JvmClasspath.kt">
	<error line="4" column="24" severity="warning" message="JvmApi.name()?.length contains an unnecessary safe call operator" source="detekt.UnnecessarySafeCall" />
</file>
</checkstyle>"""

write_file(
    name = "jvm_classpath_report",
    out = "jvm_classpath_report.xml",
    content = JVM_CLASSPATH_REPORT_XML.split("\n"),
    newline = "unix",
)

diff_test(
    name = "jvm_classpath_report_test",
    file1 = ":jvm_classpath_report",
    file2 = ":jvm_classpath_analysis_test",
)

ANDROID_CLASSPATH_REPORT_XML = """<?xml version="1.0" encoding="UTF-8"?>
<checkstyle version="4.3">
<file name="tests/integration/testFixtures/basic-android/src/android/tests/integration/android/AndroidClasspath.kt">
	<error line="6" column="24" severity="warning" message="AndroidApi.packageName(context)?.length contains an unnecessary safe call operator" source="detekt.UnnecessarySafeCall" />
</file>
</checkstyle>"""

write_file(
    name = "android_classpath_report",
    out = "android_classpath_report.xml",
    content = ANDROID_CLASSPATH_REPORT_XML.split("\n"),
    newline = "unix",
)

diff_test(
    name = "android_classpath_report_test",
    file1 = ":android_classpath_report",
    file2 = ":android_classpath_analysis_test",
)

CUSTOM_RULE_REPORT_XML = """<?xml version="1.0" encoding="UTF-8"?>
<checkstyle version="4.3">
<file name="tests/integration/testFixtures/custom-rule/src/custom/tests/integration/custom/CustomRuleViolation.kt">
	<error line="1" column="1" severity="warning" message="customRuleViolation is forbidden." source="detekt.ForbiddenFunctionName" />
</file>
</checkstyle>"""

write_file(
    name = "custom_rule_report",
    out = "custom_rule_report.xml",
    content = CUSTOM_RULE_REPORT_XML.split("\n"),
    newline = "unix",
)

diff_test(
    name = "custom_rule_report_test",
    file1 = ":custom_rule_report",
    file2 = ":custom_rule_analysis_test",
)
