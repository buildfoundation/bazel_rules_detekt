load("@rules_java//java:defs.bzl", "java_binary", "java_library")

filegroup(
    name = "sources",
    srcs = glob(["src/main/java/**/*.java"]),
    visibility = ["//tests/unit:__pkg__"],
)

java_library(
    name = "wrapper",
    srcs = glob(["src/main/java/**/*.java"]),
    visibility = ["//tests/unit:__pkg__"],
    deps = [
        "@bazel_worker_java//src/main/java/com/google/devtools/build/lib/worker:work_request_handlers",
        "@detekt_cli_all//jar",
    ],
)

java_binary(
    name = "bin",
    main_class = "io.buildfoundation.bazel.detekt.Main",
    visibility = ["//visibility:public"],
    runtime_deps = [":wrapper"],
)
