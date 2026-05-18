load("@bazel_binaries//:defs.bzl", "bazel_binaries")
load("@rules_bazel_integration_test//bazel_integration_test:defs.bzl", "script_test")
load("@rules_shell//shell:sh_library.bzl", "sh_library")

sh_library(
    name = "integration_helper",
    testonly = True,
    srcs = ["integration_helper.sh"],
    data = ["//:MODULE.bazel"],
    visibility = ["//visibility:private"],
    deps = [
        "//tests/bashunit",
        "@rules_shell//shell/runfiles",
    ],
)

script_test(
    name = "integration_test",
    srcs = ["integration_test.sh"],
    # The inner Bazel needs ANDROID_HOME so the rules_android SDK toolchain
    # resolves to a target that provides ToolchainInfo (the detekt rule
    # declares the Android SDK toolchain unconditionally).
    additional_env_inherit = [
        "ANDROID_HOME",
        "ANDROID_SDK_ROOT",
    ],
    bazel_binaries = bazel_binaries,
    bazel_version = bazel_binaries.versions.current,
    tags = [],
    deps = [
        ":integration_helper",
        "//tests/bashunit",
        "@rules_shell//shell/runfiles",
    ],
)

test_suite(
    name = "integration_tests",
    tests = [":integration_test"],
)
