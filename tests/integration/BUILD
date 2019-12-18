load("@rules_detekt//detekt:defs.bzl", "detekt")

detekt(
    name = "detekt_with_default_attributes",
    srcs = glob(["src/main/kotlin/**/*.kt"]),
)

detekt(
    name = "detekt_with_strict_config",
    srcs = glob(["src/main/kotlin/**/*.kt"]),
    config = "strict-config.yml",
)

detekt(
    name = "detekt_with_strict_config_and_baseline",
    srcs = glob(["src/main/kotlin/**/*.kt"]),
    config = "strict-config.yml",
    baseline = "strict-config-baseline.xml",
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
