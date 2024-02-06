load("//detekt:defs.bzl", "detekt")

filegroup(
    name = "detekt_config_lenient",
    srcs = ["detekt_config_lenient.yml"],
    tags = ["manual"],
)

detekt(
    name = "detekt_without_config",
    srcs = glob(["src/main/kotlin/**/*.kt"]),
    tags = ["manual"],
)

detekt(
    name = "detekt_without_config_with_report_html",
    srcs = glob(["src/main/kotlin/**/*.kt"]),
    html_report = True,
    tags = ["manual"],
)

detekt(
    name = "detekt_without_config_with_report_xml",
    srcs = glob(["src/main/kotlin/**/*.kt"]),
    tags = ["manual"],
    xml_report = True,
)

detekt(
    name = "detekt_without_config_with_baseline",
    srcs = glob(["src/main/kotlin/**/*.kt"]),
    baseline = "detekt_baseline.xml",
    tags = ["manual"],
)

detekt(
    name = "detekt_without_config_with_baseline_with_plugin",
    srcs = glob(["src/main/kotlin/**/*.kt"]),
    baseline = "detekt_baseline.xml",
    plugins = ["@rules_detekt_dependencies//:io_gitlab_arturbosch_detekt_detekt_formatting"],
    tags = ["manual"],
)

detekt(
    name = "detekt_with_config_file_lenient",
    srcs = glob(["src/main/kotlin/**/*.kt"]),
    cfgs = ["detekt_config_lenient.yml"],
    tags = ["manual"],
)

detekt(
    name = "detekt_with_config_filegroup_lenient",
    srcs = glob(["src/main/kotlin/**/*.kt"]),
    cfgs = ["//tests/integration:detekt_config_lenient"],
    tags = ["manual"],
)
