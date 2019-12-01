load("@io_bazel_rules_kotlin//kotlin:kotlin.bzl", "kt_jvm_library")

kt_jvm_library(
    name = "_lib",
    srcs = glob(["src/main/kotlin/**/*.kt"]),
)

java_binary(
    name = "bin",
    main_class = "io.buildfoundation.bazel.rulesdetekt.wrapper.Main",
    visibility = ["//visibility:public"],
    runtime_deps = [":_lib"],
)
