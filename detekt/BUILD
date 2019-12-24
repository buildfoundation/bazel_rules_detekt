load("//detekt:toolchain.bzl", "detekt_toolchain")

toolchain_type(
    name = "toolchain_type",
)

detekt_toolchain(
    name = "default_toolchain_impl",
)

toolchain(
    name = "default_toolchain",
    toolchain = ":default_toolchain_impl",
    toolchain_type = "//detekt:toolchain_type",
)

exports_files(["defs.bzl"])
