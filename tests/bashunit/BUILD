load("@rules_shell//shell:sh_library.bzl", "sh_library")

# Materialize both bashunit files next to each other so unittest.bash can
# source unittest_utils.sh via its relative path lookup.
genrule(
    name = "bashunit_sources",
    srcs = [
        "@bazel_unittest_bash//file:unittest.bash",
        "@bazel_unittest_utils_sh//file:unittest_utils.sh",
    ],
    outs = [
        "unittest.bash",
        "unittest_utils.sh",
    ],
    cmd = """
cp $(location @bazel_unittest_bash//file:unittest.bash) $(location :unittest.bash)
cp $(location @bazel_unittest_utils_sh//file:unittest_utils.sh) $(location :unittest_utils.sh)
""",
)

sh_library(
    name = "bashunit",
    testonly = True,
    srcs = [":bashunit_sources"],
    visibility = ["//tests:__subpackages__"],
)
