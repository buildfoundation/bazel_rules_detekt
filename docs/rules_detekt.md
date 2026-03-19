<!-- Generated with Stardoc: http://skydoc.bazel.build -->

<a id="detekt"></a>

## detekt

<pre>
load("@rules_detekt//detekt:defs.bzl", "detekt")

detekt(<a href="#detekt-name">name</a>, <a href="#detekt-deps">deps</a>, <a href="#detekt-srcs">srcs</a>, <a href="#detekt-all_rules">all_rules</a>, <a href="#detekt-auto_correct">auto_correct</a>, <a href="#detekt-base_path">base_path</a>, <a href="#detekt-baseline">baseline</a>, <a href="#detekt-build_upon_default_config">build_upon_default_config</a>,
       <a href="#detekt-cfgs">cfgs</a>, <a href="#detekt-config_resource">config_resource</a>, <a href="#detekt-disable_default_rulesets">disable_default_rulesets</a>, <a href="#detekt-enable_type_resolution">enable_type_resolution</a>, <a href="#detekt-excludes">excludes</a>, <a href="#detekt-html_report">html_report</a>,
       <a href="#detekt-includes">includes</a>, <a href="#detekt-max_issues">max_issues</a>, <a href="#detekt-md_report">md_report</a>, <a href="#detekt-parallel">parallel</a>, <a href="#detekt-plugins">plugins</a>, <a href="#detekt-sarif_report">sarif_report</a>, <a href="#detekt-txt_report">txt_report</a>, <a href="#detekt-xml_report">xml_report</a>)
</pre>

Runs Detekt static analysis on the given Kotlin and Java sources, failing the build if issues are found.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="detekt-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="detekt-deps"></a>deps |  Dependencies to provide to Detekt for classpath type resolution.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="detekt-srcs"></a>srcs |  Kotlin and Java source code files to analyze. Java files are included to support type resolution in mixed-language projects.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | required |  |
| <a id="detekt-all_rules"></a>all_rules |  Activates all available (even unstable) rules.   | Boolean | optional |  `False`  |
| <a id="detekt-auto_correct"></a>auto_correct |  Allow rules to auto correct code if they support it. The default rule sets do NOT support auto correcting and won't change any line in the users code base. However custom rules can be written to support auto correcting. The additional 'formatting' rule set, added with `--plugins`, does support it and needs this flag.   | Boolean | optional |  `False`  |
| <a id="detekt-base_path"></a>base_path |  Specifies a directory as the base path. Affects all file paths in formatted reports. File paths in console output and txt report are not affected and remain as absolute paths.   | String | optional |  `""`  |
| <a id="detekt-baseline"></a>baseline |  If a baseline xml file is passed in, only new code smells not in the baseline are printed in the console.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="detekt-build_upon_default_config"></a>build_upon_default_config |  Preconfigures detekt with a set of rules and opinionated defaults. Allows additional provided configurations to override the defaults.   | Boolean | optional |  `False`  |
| <a id="detekt-cfgs"></a>cfgs |  Path to the config file (`path/to/config.yml`). Multiple configuration files can be specified.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="detekt-config_resource"></a>config_resource |  Path to the config resource on detekt's classpath (`path/to/config.yml`).   | String | optional |  `""`  |
| <a id="detekt-disable_default_rulesets"></a>disable_default_rulesets |  Disables default rule sets.   | Boolean | optional |  `False`  |
| <a id="detekt-enable_type_resolution"></a>enable_type_resolution |  Enables type resolution for more advanced static analysis. When enabled, the classpath is constructed from `deps` and the appropriate bootclasspath (Android SDK or JDK) is included. When disabled, no classpath is passed to Detekt and only syntax-based rules are applied.   | Boolean | optional |  `False`  |
| <a id="detekt-excludes"></a>excludes |  Globbing patterns describing paths to exclude from the analysis.   | List of strings | optional |  `[]`  |
| <a id="detekt-html_report"></a>html_report |  Enables / disables the HTML report generation. The report file name is `{target_name}_detekt_report.html`.   | Boolean | optional |  `False`  |
| <a id="detekt-includes"></a>includes |  Globbing patterns describing paths to include in the analysis. Useful in combination with `excludes` patterns.   | List of strings | optional |  `[]`  |
| <a id="detekt-max_issues"></a>max_issues |  Passes only when found issues count does not exceed specified issues count. A negative value disables the limit.   | Integer | optional |  `-1`  |
| <a id="detekt-md_report"></a>md_report |  Enables / disables the Markdown report generation. The report file name is `{target_name}_detekt_report.md`.   | Boolean | optional |  `False`  |
| <a id="detekt-parallel"></a>parallel |  Enables parallel compilation and analysis of source files. Do some benchmarks first before enabling this flag. Heuristics show performance benefits starting from 2,000 lines of Kotlin code.   | Boolean | optional |  `False`  |
| <a id="detekt-plugins"></a>plugins |  Extra paths to plugin jars.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="detekt-sarif_report"></a>sarif_report |  Enables / disables the SARIF report generation. The report file name is `{target_name}_detekt_report.sarif`.   | Boolean | optional |  `False`  |
| <a id="detekt-txt_report"></a>txt_report |  Enables / disables the text report generation. The report file name is `{target_name}_detekt_report.txt`.   | Boolean | optional |  `False`  |
| <a id="detekt-xml_report"></a>xml_report |  Enables / disables the XML report generation. The report file name is `{target_name}_detekt_report.xml`. Detekt uses the Checkstyle XML reporting format which makes it compatible with tools like SonarQube.   | Boolean | optional |  `False`  |


<a id="detekt_create_baseline"></a>

## detekt_create_baseline

<pre>
load("@rules_detekt//detekt:defs.bzl", "detekt_create_baseline")

detekt_create_baseline(<a href="#detekt_create_baseline-name">name</a>, <a href="#detekt_create_baseline-deps">deps</a>, <a href="#detekt_create_baseline-srcs">srcs</a>, <a href="#detekt_create_baseline-all_rules">all_rules</a>, <a href="#detekt_create_baseline-auto_correct">auto_correct</a>, <a href="#detekt_create_baseline-base_path">base_path</a>, <a href="#detekt_create_baseline-baseline">baseline</a>,
                       <a href="#detekt_create_baseline-build_upon_default_config">build_upon_default_config</a>, <a href="#detekt_create_baseline-cfgs">cfgs</a>, <a href="#detekt_create_baseline-config_resource">config_resource</a>, <a href="#detekt_create_baseline-disable_default_rulesets">disable_default_rulesets</a>,
                       <a href="#detekt_create_baseline-enable_type_resolution">enable_type_resolution</a>, <a href="#detekt_create_baseline-excludes">excludes</a>, <a href="#detekt_create_baseline-html_report">html_report</a>, <a href="#detekt_create_baseline-includes">includes</a>, <a href="#detekt_create_baseline-max_issues">max_issues</a>, <a href="#detekt_create_baseline-md_report">md_report</a>,
                       <a href="#detekt_create_baseline-parallel">parallel</a>, <a href="#detekt_create_baseline-plugins">plugins</a>, <a href="#detekt_create_baseline-sarif_report">sarif_report</a>, <a href="#detekt_create_baseline-txt_report">txt_report</a>, <a href="#detekt_create_baseline-xml_report">xml_report</a>)
</pre>

Creates or updates a Detekt baseline file. Run this target to record existing issues so that only new issues fail the build going forward.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="detekt_create_baseline-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="detekt_create_baseline-deps"></a>deps |  Dependencies to provide to Detekt for classpath type resolution.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="detekt_create_baseline-srcs"></a>srcs |  Kotlin and Java source code files to analyze. Java files are included to support type resolution in mixed-language projects.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | required |  |
| <a id="detekt_create_baseline-all_rules"></a>all_rules |  Activates all available (even unstable) rules.   | Boolean | optional |  `False`  |
| <a id="detekt_create_baseline-auto_correct"></a>auto_correct |  Allow rules to auto correct code if they support it. The default rule sets do NOT support auto correcting and won't change any line in the users code base. However custom rules can be written to support auto correcting. The additional 'formatting' rule set, added with `--plugins`, does support it and needs this flag.   | Boolean | optional |  `False`  |
| <a id="detekt_create_baseline-base_path"></a>base_path |  Specifies a directory as the base path. Affects all file paths in formatted reports. File paths in console output and txt report are not affected and remain as absolute paths.   | String | optional |  `""`  |
| <a id="detekt_create_baseline-baseline"></a>baseline |  If a baseline xml file is passed in, only new code smells not in the baseline are printed in the console.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="detekt_create_baseline-build_upon_default_config"></a>build_upon_default_config |  Preconfigures detekt with a set of rules and opinionated defaults. Allows additional provided configurations to override the defaults.   | Boolean | optional |  `False`  |
| <a id="detekt_create_baseline-cfgs"></a>cfgs |  Path to the config file (`path/to/config.yml`). Multiple configuration files can be specified.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="detekt_create_baseline-config_resource"></a>config_resource |  Path to the config resource on detekt's classpath (`path/to/config.yml`).   | String | optional |  `""`  |
| <a id="detekt_create_baseline-disable_default_rulesets"></a>disable_default_rulesets |  Disables default rule sets.   | Boolean | optional |  `False`  |
| <a id="detekt_create_baseline-enable_type_resolution"></a>enable_type_resolution |  Enables type resolution for more advanced static analysis. When enabled, the classpath is constructed from `deps` and the appropriate bootclasspath (Android SDK or JDK) is included. When disabled, no classpath is passed to Detekt and only syntax-based rules are applied.   | Boolean | optional |  `False`  |
| <a id="detekt_create_baseline-excludes"></a>excludes |  Globbing patterns describing paths to exclude from the analysis.   | List of strings | optional |  `[]`  |
| <a id="detekt_create_baseline-html_report"></a>html_report |  Enables / disables the HTML report generation. The report file name is `{target_name}_detekt_report.html`.   | Boolean | optional |  `False`  |
| <a id="detekt_create_baseline-includes"></a>includes |  Globbing patterns describing paths to include in the analysis. Useful in combination with `excludes` patterns.   | List of strings | optional |  `[]`  |
| <a id="detekt_create_baseline-max_issues"></a>max_issues |  Passes only when found issues count does not exceed specified issues count. A negative value disables the limit.   | Integer | optional |  `-1`  |
| <a id="detekt_create_baseline-md_report"></a>md_report |  Enables / disables the Markdown report generation. The report file name is `{target_name}_detekt_report.md`.   | Boolean | optional |  `False`  |
| <a id="detekt_create_baseline-parallel"></a>parallel |  Enables parallel compilation and analysis of source files. Do some benchmarks first before enabling this flag. Heuristics show performance benefits starting from 2,000 lines of Kotlin code.   | Boolean | optional |  `False`  |
| <a id="detekt_create_baseline-plugins"></a>plugins |  Extra paths to plugin jars.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="detekt_create_baseline-sarif_report"></a>sarif_report |  Enables / disables the SARIF report generation. The report file name is `{target_name}_detekt_report.sarif`.   | Boolean | optional |  `False`  |
| <a id="detekt_create_baseline-txt_report"></a>txt_report |  Enables / disables the text report generation. The report file name is `{target_name}_detekt_report.txt`.   | Boolean | optional |  `False`  |
| <a id="detekt_create_baseline-xml_report"></a>xml_report |  Enables / disables the XML report generation. The report file name is `{target_name}_detekt_report.xml`. Detekt uses the Checkstyle XML reporting format which makes it compatible with tools like SonarQube.   | Boolean | optional |  `False`  |


<a id="detekt_test"></a>

## detekt_test

<pre>
load("@rules_detekt//detekt:defs.bzl", "detekt_test")

detekt_test(<a href="#detekt_test-name">name</a>, <a href="#detekt_test-deps">deps</a>, <a href="#detekt_test-srcs">srcs</a>, <a href="#detekt_test-all_rules">all_rules</a>, <a href="#detekt_test-auto_correct">auto_correct</a>, <a href="#detekt_test-base_path">base_path</a>, <a href="#detekt_test-baseline">baseline</a>,
            <a href="#detekt_test-build_upon_default_config">build_upon_default_config</a>, <a href="#detekt_test-cfgs">cfgs</a>, <a href="#detekt_test-config_resource">config_resource</a>, <a href="#detekt_test-disable_default_rulesets">disable_default_rulesets</a>,
            <a href="#detekt_test-enable_type_resolution">enable_type_resolution</a>, <a href="#detekt_test-excludes">excludes</a>, <a href="#detekt_test-html_report">html_report</a>, <a href="#detekt_test-includes">includes</a>, <a href="#detekt_test-max_issues">max_issues</a>, <a href="#detekt_test-md_report">md_report</a>, <a href="#detekt_test-parallel">parallel</a>,
            <a href="#detekt_test-plugins">plugins</a>, <a href="#detekt_test-sarif_report">sarif_report</a>, <a href="#detekt_test-txt_report">txt_report</a>, <a href="#detekt_test-xml_report">xml_report</a>)
</pre>

Runs Detekt static analysis as a test target. Unlike `detekt`, violations fail the test but not the build, so `bazel build` succeeds even when issues are present.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="detekt_test-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="detekt_test-deps"></a>deps |  Dependencies to provide to Detekt for classpath type resolution.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="detekt_test-srcs"></a>srcs |  Kotlin and Java source code files to analyze. Java files are included to support type resolution in mixed-language projects.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | required |  |
| <a id="detekt_test-all_rules"></a>all_rules |  Activates all available (even unstable) rules.   | Boolean | optional |  `False`  |
| <a id="detekt_test-auto_correct"></a>auto_correct |  Allow rules to auto correct code if they support it. The default rule sets do NOT support auto correcting and won't change any line in the users code base. However custom rules can be written to support auto correcting. The additional 'formatting' rule set, added with `--plugins`, does support it and needs this flag.   | Boolean | optional |  `False`  |
| <a id="detekt_test-base_path"></a>base_path |  Specifies a directory as the base path. Affects all file paths in formatted reports. File paths in console output and txt report are not affected and remain as absolute paths.   | String | optional |  `""`  |
| <a id="detekt_test-baseline"></a>baseline |  If a baseline xml file is passed in, only new code smells not in the baseline are printed in the console.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="detekt_test-build_upon_default_config"></a>build_upon_default_config |  Preconfigures detekt with a set of rules and opinionated defaults. Allows additional provided configurations to override the defaults.   | Boolean | optional |  `False`  |
| <a id="detekt_test-cfgs"></a>cfgs |  Path to the config file (`path/to/config.yml`). Multiple configuration files can be specified.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="detekt_test-config_resource"></a>config_resource |  Path to the config resource on detekt's classpath (`path/to/config.yml`).   | String | optional |  `""`  |
| <a id="detekt_test-disable_default_rulesets"></a>disable_default_rulesets |  Disables default rule sets.   | Boolean | optional |  `False`  |
| <a id="detekt_test-enable_type_resolution"></a>enable_type_resolution |  Enables type resolution for more advanced static analysis. When enabled, the classpath is constructed from `deps` and the appropriate bootclasspath (Android SDK or JDK) is included. When disabled, no classpath is passed to Detekt and only syntax-based rules are applied.   | Boolean | optional |  `False`  |
| <a id="detekt_test-excludes"></a>excludes |  Globbing patterns describing paths to exclude from the analysis.   | List of strings | optional |  `[]`  |
| <a id="detekt_test-html_report"></a>html_report |  Enables / disables the HTML report generation. The report file name is `{target_name}_detekt_report.html`.   | Boolean | optional |  `False`  |
| <a id="detekt_test-includes"></a>includes |  Globbing patterns describing paths to include in the analysis. Useful in combination with `excludes` patterns.   | List of strings | optional |  `[]`  |
| <a id="detekt_test-max_issues"></a>max_issues |  Passes only when found issues count does not exceed specified issues count. A negative value disables the limit.   | Integer | optional |  `-1`  |
| <a id="detekt_test-md_report"></a>md_report |  Enables / disables the Markdown report generation. The report file name is `{target_name}_detekt_report.md`.   | Boolean | optional |  `False`  |
| <a id="detekt_test-parallel"></a>parallel |  Enables parallel compilation and analysis of source files. Do some benchmarks first before enabling this flag. Heuristics show performance benefits starting from 2,000 lines of Kotlin code.   | Boolean | optional |  `False`  |
| <a id="detekt_test-plugins"></a>plugins |  Extra paths to plugin jars.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="detekt_test-sarif_report"></a>sarif_report |  Enables / disables the SARIF report generation. The report file name is `{target_name}_detekt_report.sarif`.   | Boolean | optional |  `False`  |
| <a id="detekt_test-txt_report"></a>txt_report |  Enables / disables the text report generation. The report file name is `{target_name}_detekt_report.txt`.   | Boolean | optional |  `False`  |
| <a id="detekt_test-xml_report"></a>xml_report |  Enables / disables the XML report generation. The report file name is `{target_name}_detekt_report.xml`. Detekt uses the Checkstyle XML reporting format which makes it compatible with tools like SonarQube.   | Boolean | optional |  `False`  |


<!-- Generated with Stardoc: http://skydoc.bazel.build -->

<a id="detekt_toolchain"></a>

## detekt_toolchain

<pre>
load("@rules_detekt//detekt:toolchain.bzl", "detekt_toolchain")

detekt_toolchain(<a href="#detekt_toolchain-name">name</a>, <a href="#detekt_toolchain-jvm_flags">jvm_flags</a>, <a href="#detekt_toolchain-jvm_target">jvm_target</a>, <a href="#detekt_toolchain-language_version">language_version</a>)
</pre>

Defines a Detekt toolchain, configuring the JVM settings used when running Detekt.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="detekt_toolchain-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="detekt_toolchain-jvm_flags"></a>jvm_flags |  JVM flags used for Detekt execution.   | List of strings | optional |  `["-Xms16m", "-Xmx128m"]`  |
| <a id="detekt_toolchain-jvm_target"></a>jvm_target |  Target JVM bytecode version used by Detekt during analysis.   | String | optional |  `"1.8"`  |
| <a id="detekt_toolchain-language_version"></a>language_version |  Kotlin language version compatibility mode. Detekt reports errors for language features introduced after the specified version.   | String | optional |  `"2.0"`  |


<!-- Generated with Stardoc: http://skydoc.bazel.build -->

<a id="rules_detekt_toolchains"></a>

## rules_detekt_toolchains

<pre>
load("@rules_detekt//detekt:toolchains.bzl", "rules_detekt_toolchains")

rules_detekt_toolchains(<a href="#rules_detekt_toolchains-toolchain">toolchain</a>)
</pre>

Registers `rules_detekt` toolchains.

For WORKSPACE-based setups, call this macro in your `WORKSPACE` file.
With Bzlmod (`MODULE.bazel`), toolchains are registered automatically and
this macro is not needed.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="rules_detekt_toolchains-toolchain"></a>toolchain |  `detekt_toolchain` target to register.   |  `"@rules_detekt//detekt:default_toolchain"` |


<!-- Generated with Stardoc: http://skydoc.bazel.build -->

<a id="detekt_version"></a>

## detekt_version

<pre>
load("@rules_detekt//detekt:versions.bzl", "detekt_version")

detekt_version(<a href="#detekt_version-version">version</a>, <a href="#detekt_version-sha256">sha256</a>, <a href="#detekt_version-url_templates">url_templates</a>)
</pre>

Specify a custom Detekt version to use instead of the default.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="detekt_version-version"></a>version |  The version of detekt.   |  none |
| <a id="detekt_version-sha256"></a>sha256 |  The sha256 of the detekt jar.   |  none |
| <a id="detekt_version-url_templates"></a>url_templates |  URL templates for downloading detekt. Each template may contain `{version}` which will be replaced with the version string. Defaults to the standard GitHub release URL.   |  `None` |

**RETURNS**

A struct containing the version information.


