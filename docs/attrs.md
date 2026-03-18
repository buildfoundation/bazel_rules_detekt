<!-- Generated with Stardoc: http://skydoc.bazel.build -->

# Attributes

Name           | Type                               | Default            | Description
---------------|------------------------------------|--------------------|------------
`name` | [`name`](https://docs.bazel.build/versions/master/build-ref.html#name) | — | A unique name for this target.
`deps` | [`[Label]`](https://docs.bazel.build/versions/master/skylark/lib/list.html) | `[]` | Dependencies providing user class files and jar files used to construct the classpath for type resolution. Only used when `analysis_mode = 'full'`.
`srcs` | [`[Label]`](https://docs.bazel.build/versions/master/skylark/lib/list.html) | — | Kotlin and Java source code files to analyze. Java files are included to support type resolution in mixed-language projects.
`all_rules` | [`bool`](https://docs.bazel.build/versions/master/skylark/lib/bool.html) | `False` | Activates all available (even unstable) rules.
`analysis_mode` | [`string`](https://docs.bazel.build/versions/master/skylark/lib/string.html) | `"light"` | Analysis mode used by detekt. 'full' analysis mode is comprehensive and enables more advanced analysis with type resolution, but requires the correct compiler options to be provided. The classpath is constructed from `deps` and the appropriate bootclasspath (Android SDK or JDK). 'light' runs a faster, syntax-based analysis only and cannot utilise compiler information; some rules cannot be run in 'light' mode.
`auto_correct` | [`bool`](https://docs.bazel.build/versions/master/skylark/lib/bool.html) | `False` | Allow rules to auto correct code if they support it. Custom rules can be written to support auto correcting. The default rule sets do NOT support auto correcting.
`base_path` | [`string`](https://docs.bazel.build/versions/master/skylark/lib/string.html) | `""` | Specifies a directory as the base path. Currently it impacts all file paths in formatted reports.
`baseline` | [`Label`](https://docs.bazel.build/versions/master/skylark/lib/Label.html) | `None` | If a baseline xml file is passed in, only new findings not in the baseline are printed.
`build_upon_default_config` | [`bool`](https://docs.bazel.build/versions/master/skylark/lib/bool.html) | `False` | Preconfigures detekt with a bunch of rules and some opinionated defaults for you. Allows additional provided configurations to override the defaults.
`cfgs` | [`[Label]`](https://docs.bazel.build/versions/master/skylark/lib/list.html) | `[]` | Path to the config file (`path/to/config.yml`). Multiple configuration files can be specified.
`config_resource` | [`string`](https://docs.bazel.build/versions/master/skylark/lib/string.html) | `""` | Path to the config resource on detekt's classpath (`path/to/config.yml`).
`disable_default_rulesets` | [`bool`](https://docs.bazel.build/versions/master/skylark/lib/bool.html) | `False` | Disables default rule sets.
`excludes` | [`[string]`](https://docs.bazel.build/versions/master/skylark/lib/list.html) | `[]` | Globbing patterns describing paths to exclude from the analysis.
`fail_on_severity` | [`string`](https://docs.bazel.build/versions/master/skylark/lib/string.html) | `"Error"` | Specifies the minimum severity that causes the build to fail. Severity levels from highest to lowest: 'Error', 'Warning', 'Info'. Use 'Never' to always pass regardless of findings.
`html_report` | [`bool`](https://docs.bazel.build/versions/master/skylark/lib/bool.html) | `False` | Enables / disables the HTML report generation. The report file name is `{target_name}_detekt_report.html`.
`includes` | [`[string]`](https://docs.bazel.build/versions/master/skylark/lib/list.html) | `[]` | Globbing patterns describing paths to include in the analysis. Useful in combination with `excludes` patterns.
`is_android` | [`bool`](https://docs.bazel.build/versions/master/skylark/lib/bool.html) | `False` | Whether the target is an Android target. When `True`, the Android SDK jar is included in the classpath for type resolution.
`md_report` | [`bool`](https://docs.bazel.build/versions/master/skylark/lib/bool.html) | `False` | Enables / disables the Markdown report generation. The report file name is `{target_name}_detekt_report.md`.
`parallel` | [`bool`](https://docs.bazel.build/versions/master/skylark/lib/bool.html) | `False` | Enables concurrent file processing during analysis. Beneficial for codebases over 2,000 lines of Kotlin code.
`plugins` | [`[Label]`](https://docs.bazel.build/versions/master/skylark/lib/list.html) | `[]` | Extra paths to plugin jars.
`sarif_report` | [`bool`](https://docs.bazel.build/versions/master/skylark/lib/bool.html) | `False` | Enables / disables the SARIF report generation. The report file name is `{target_name}_detekt_report.sarif`.
`xml_report` | [`bool`](https://docs.bazel.build/versions/master/skylark/lib/bool.html) | `False` | Enables / disables the XML report generation. The report file name is `{target_name}_detekt_report.xml`. Detekt uses the Checkstyle XML reporting format which makes it compatible with tools like SonarQube.


