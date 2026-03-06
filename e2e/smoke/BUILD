"""Provides a simple way to test rule installation as an external workspace."""

load("@bazel_skylib//rules:build_test.bzl", "build_test")

filegroup(name = "empty")

build_test(
    name = "smoke_test",
    targets = [":empty"],
)
