<!-- Generated with Stardoc: http://skydoc.bazel.build -->

# Attributes

Name           | Type                               | Default            | Description
---------------|------------------------------------|--------------------|------------
`name` | [`name`](https://docs.bazel.build/versions/master/build-ref.html#name) | — | A unique name for this target.
`deps` | [`[Label]`](https://docs.bazel.build/versions/master/skylark/lib/list.html) | `[]` | Dependencies to provide to Detekt for classpath type resolution.
`srcs` | [`[Label]`](https://docs.bazel.build/versions/master/skylark/lib/list.html) | — | Kotlin source code files to analyze.
`all_rules` | [`bool`](https://docs.bazel.build/versions/master/skylark/lib/bool.html) | `False` | Activates all available (even unstable) rules.
`auto_correct` | [`bool`](https://docs.bazel.build/versions/master/skylark/lib/bool.html) | `False` | Allow rules to auto correct code if they support it. The default rule sets do NOT support auto correcting and won't change any line in the users code base. However custom rules can be written to support auto correcting. The additional 'formatting' rule set, added with '--plugins', does support it and needs this flag.
`base_path` | [`string`](https://docs.bazel.build/versions/master/skylark/lib/string.html) | `""` | Specifies a directory as the base path. Currently it impacts all file paths in the formatted reports. File paths in console output and txt report are not affected and remain as absolute paths.
`baseline` | [`Label`](https://docs.bazel.build/versions/master/skylark/lib/Label.html) | `None` | If a baseline xml file is passed in, only new code smells not in the baseline are printed in the console.
`config_resource` | [`string`](https://docs.bazel.build/versions/master/skylark/lib/string.html) | `""` | Path to the config resource on detekt's classpath (path/to/config.yml).
`detekt_toolchain` | [`Label`](https://docs.bazel.build/versions/master/skylark/lib/Label.html) | `None` | Optional label of a target providing platform_common.ToolchainInfo. If omitted, uses the registered detekt toolchain.
`excludes` | [`[string]`](https://docs.bazel.build/versions/master/skylark/lib/list.html) | `[]` | Globbing patterns describing paths to exclude from the analysis.
`html_report` | [`bool`](https://docs.bazel.build/versions/master/skylark/lib/bool.html) | `False` | Enables / disables the HTML report generation. The report file name is `{target_name}_detekt_report.html`.
`includes` | [`[string]`](https://docs.bazel.build/versions/master/skylark/lib/list.html) | `[]` | Globbing patterns describing paths to include in the analysis. Useful in combination with 'excludes' patterns.
`is_android` | [`bool`](https://docs.bazel.build/versions/master/skylark/lib/bool.html) | `False` | Whether detekt target corresponds to android kotlin library or regular jvm library
`md_report` | [`bool`](https://docs.bazel.build/versions/master/skylark/lib/bool.html) | `False` | Enables / disables the Markdown report generation. The report file name is `{target_name}_detekt_report.md`.
`sarif_report` | [`bool`](https://docs.bazel.build/versions/master/skylark/lib/bool.html) | `False` | Enables / disables the SARIF report generation. The report file name is `{target_name}_detekt_report.sarif`.
`txt_report` | [`bool`](https://docs.bazel.build/versions/master/skylark/lib/bool.html) | `False` | Enables / disables the text report generation. The report file name is `{target_name}_detekt_report.txt`; Detekt 2.x uses captured console output for this artifact.
`xml_report` | [`bool`](https://docs.bazel.build/versions/master/skylark/lib/bool.html) | `False` | Enables / disables the XML report generation. The report file name is `{target_name}_detekt_report.xml`. Detekt 2.x maps this output to its `checkstyle` report ID; the format is compatible with tools like SonarQube.
