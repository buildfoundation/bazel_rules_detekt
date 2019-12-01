load("@rules_detekt//detekt:detekt.bzl", "detekt")

detekt(
    name = "detekt_with_default_attributes",
    srcs = glob(["src/main/kotlin/**/*.kt"]),
)

detekt(
    name = "detekt_with_strict_config",
    srcs = glob(["src/main/kotlin/**/*.kt"]),
    config = "strict-config.yml",
)
