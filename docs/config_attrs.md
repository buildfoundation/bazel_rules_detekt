<!-- Generated with Stardoc: http://skydoc.bazel.build -->

# Attributes

Name           | Type                               | Default            | Description
---------------|------------------------------------|--------------------|------------
`name` | [`name`](https://docs.bazel.build/versions/master/build-ref.html#name) | — | A unique name for this target.
`build_upon_default_config` | [`bool`](https://docs.bazel.build/versions/master/skylark/lib/bool.html) | `False` | Use Detekt's built-in configuration as a base for the supplied configuration files.
`cfgs` | [`[Label]`](https://docs.bazel.build/versions/master/skylark/lib/list.html) | `[]` | Configuration files for targets using this configuration.
`disable_default_rulesets` | [`bool`](https://docs.bazel.build/versions/master/skylark/lib/bool.html) | `False` | Disable Detekt's default rule sets, using only rule sets supplied by plugins.
`fail_on_severity` | [`string`](https://docs.bazel.build/versions/master/skylark/lib/string.html) | `""` | Detekt 2.x failure threshold (Error, Warning, Info, or Never). Empty string uses the runtime default. Mutually exclusive with an active max_issues threshold.
`jvm_target` | [`string`](https://docs.bazel.build/versions/master/skylark/lib/string.html) | `"1.8"` | JVM bytecode target; the selected Detekt version validates it.
`language_version` | [`string`](https://docs.bazel.build/versions/master/skylark/lib/string.html) | `""` | Kotlin language version; the selected Detekt version validates it.
`max_issues` | [`int`](https://docs.bazel.build/versions/master/skylark/lib/int.html) | `-1` | Detekt 1.x issue threshold; -1 leaves it unset. Mutually exclusive with fail_on_severity.
`parallel` | [`bool`](https://docs.bazel.build/versions/master/skylark/lib/bool.html) | `False` | Enable parallel compilation and analysis of source files.
`plugins` | [`[Label]`](https://docs.bazel.build/versions/master/skylark/lib/list.html) | `[]` | JavaInfo plugin targets, built for the execution platform.
