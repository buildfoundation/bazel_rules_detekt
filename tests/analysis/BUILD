load(":tests.bzl", "test_suite")

platform(
    name = "windows_platform",
    constraint_values = [
        "@platforms//cpu:x86_64",
        "@platforms//os:windows",
    ],
)

test_suite(
    name = "tests",
)
