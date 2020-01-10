load("@rules_detekt//detekt:defs.bzl", "detekt")

detekt(
    name = "detekt_with_default_attributes",
    srcs = glob(["src/main/kotlin/**/*.kt"]),
)

detekt(
    name = "detekt_with_strict_config",
    srcs = glob(["src/main/kotlin/**/*.kt"]),
    cfgs = [
        "strict_config_empty_blocks.yml",
        "strict_config_max_issues.yml",
    ],
)

filegroup(
    name = "strict_config",
    srcs = [
        "strict_config_empty_blocks.yml",
        "strict_config_max_issues.yml",
    ],
)

detekt(
    name = "detekt_with_strict_config_filegroup",
    srcs = glob(["src/main/kotlin/**/*.kt"]),
    cfgs = ["//tests/integration:strict_config"],
)

detekt(
    name = "detekt_with_strict_config_and_baseline",
    srcs = glob(["src/main/kotlin/**/*.kt"]),
    baseline = "strict_config_baseline.xml",
    cfgs = [
        "strict_config_empty_blocks.yml",
        "strict_config_max_issues.yml",
    ],
)

detekt(
    name = "detekt_with_strict_config_filegroup_and_baseline",
    srcs = glob(["src/main/kotlin/**/*.kt"]),
    baseline = "strict_config_baseline.xml",
    cfgs = ["//tests/integration:strict_config"],
)

detekt(
    name = "detekt_html_report",
    srcs = glob(["src/main/kotlin/**/*.kt"]),
    html_report = True,
)

detekt(
    name = "detekt_xml_report",
    srcs = glob(["src/main/kotlin/**/*.kt"]),
    xml_report = True,
)
