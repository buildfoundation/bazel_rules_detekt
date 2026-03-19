<!-- Generated with Stardoc: http://skydoc.bazel.build -->

# Attributes

Name           | Type                               | Default            | Description
---------------|------------------------------------|--------------------|------------
`name` | [`name`](https://docs.bazel.build/versions/master/build-ref.html#name) | — | A unique name for this target.
`deps` | [`[Label]`](https://docs.bazel.build/versions/master/skylark/lib/list.html) | `[]` | Dependencies to provide to Detekt for classpath type resolution.
`srcs` | [`[Label]`](https://docs.bazel.build/versions/master/skylark/lib/list.html) | — | Kotlin and Java source code files to analyze. Java files are included to support type resolution in mixed-language projects.
`all_rules` | [`bool`](https://docs.bazel.build/versions/master/skylark/lib/bool.html) | `False` | Activates all available (even unstable) rules.
`auto_correct` | [`bool`](https://docs.bazel.build/versions/master/skylark/lib/bool.html) | `False` | Allow rules to auto correct code if they support it. The default rule sets do NOT support auto correcting and won't change any line in the users code base. However custom rules can be written to support auto correcting. The additional 'formatting' rule set, added with `--plugins`, does support it and needs this flag.
`base_path` | [`string`](https://docs.bazel.build/versions/master/skylark/lib/string.html) | `""` | Specifies a directory as the base path. Currently it impacts all file paths in the formatted reports. File paths in console output and txt report are not affected and remain as absolute paths.
`baseline` | [`Label`](https://docs.bazel.build/versions/master/skylark/lib/Label.html) | `None` | If a baseline xml file is passed in, only new code smells not in the baseline are printed in the console.
`build_upon_default_config` | [`bool`](https://docs.bazel.build/versions/master/skylark/lib/bool.html) | `False` | Preconfigures detekt with a bunch of rules and some opinionated defaults for you. Allows additional provided configurations to override the defaults.
`cfgs` | [`[Label]`](https://docs.bazel.build/versions/master/skylark/lib/list.html) | `[]` | Path to the config file (`path/to/config.yml`). Multiple configuration files can be specified.
`config_resource` | [`string`](https://docs.bazel.build/versions/master/skylark/lib/string.html) | `""` | Path to the config resource on detekt's classpath (`path/to/config.yml`).
`disable_default_rulesets` | [`bool`](https://docs.bazel.build/versions/master/skylark/lib/bool.html) | `False` | Disables default rule sets.
`enable_type_resolution` | [`bool`](https://docs.bazel.build/versions/master/skylark/lib/bool.html) | `False` | Enables type resolution for more advanced static analysis. When enabled, the classpath is constructed from `deps` and the appropriate bootclasspath (Android SDK or JDK) is included. When disabled, no classpath is passed to Detekt and only syntax-based rules are applied.
`excludes` | [`[string]`](https://docs.bazel.build/versions/master/skylark/lib/list.html) | `[]` | Globbing patterns describing paths to exclude from the analysis.
`html_report` | [`bool`](https://docs.bazel.build/versions/master/skylark/lib/bool.html) | `False` | Enables / disables the HTML report generation. The report file name is `{target_name}_detekt_report.html`.
`includes` | [`[string]`](https://docs.bazel.build/versions/master/skylark/lib/list.html) | `[]` | Globbing patterns describing paths to include in the analysis. Useful in combination with `excludes` patterns.
`is_android` | [`bool`](https://docs.bazel.build/versions/master/skylark/lib/bool.html) | `False` | Whether the target is an Android target. When `True`, the Android SDK jar is included in the classpath for type resolution.
`max_issues` | [`int`](https://docs.bazel.build/versions/master/skylark/lib/int.html) | `-1` | Passes only when found issues count does not exceed specified issues count.
`md_report` | [`bool`](https://docs.bazel.build/versions/master/skylark/lib/bool.html) | `False` | Enables / disables the Markdown report generation. The report file name is `{target_name}_detekt_report.md`.
`parallel` | [`bool`](https://docs.bazel.build/versions/master/skylark/lib/bool.html) | `False` | Enables parallel compilation and analysis of source files. Do some benchmarks first before enabling this flag. Heuristics show performance benefits starting from 2,000 lines of Kotlin code.
`plugins` | [`[Label]`](https://docs.bazel.build/versions/master/skylark/lib/list.html) | `[]` | Extra paths to plugin jars.
`sarif_report` | [`bool`](https://docs.bazel.build/versions/master/skylark/lib/bool.html) | `False` | Enables / disables the SARIF report generation. The report file name is `{target_name}_detekt_report.sarif`.
`txt_report` | [`bool`](https://docs.bazel.build/versions/master/skylark/lib/bool.html) | `False` | Enables / disables the text report generation. The report file name is `{target_name}_detekt_report.txt`.
`xml_report` | [`bool`](https://docs.bazel.build/versions/master/skylark/lib/bool.html) | `False` | Enables / disables the XML report generation. The report file name is `{target_name}_detekt_report.xml`. Detekt uses the Checkstyle XML reporting format which makes it compatible with tools like SonarQube.


