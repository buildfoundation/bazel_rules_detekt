# `bazel_rules_detekt`

The [Detekt](https://github.com/arturbosch/detekt) (a Kotlin static analysis tool) integration
for [the Bazel build system](https://bazel.build).

- [Overview](#overview)
- [Usage](#usage)
    - [`WORKSPACE` Configuration](#workspace-configuration)
    - [`BUILD` Configuration](#build-configuration)
    - [Execution](#execution)

## Overview

Features:

- user-provided Detekt configuration;
- text, XML and HTML report generation;
- parallel Detekt compilation.

Upcoming features:

- baseline files (blocked by Detekt outputting and reading absolute paths in baselines, see [#3](https://github.com/buildfoundation/bazel_rules_detekt/issues/3));
- Bazel persistent worker mode;
- user-provided Detekt CLI JAR (blocked by the persistent worker mode due to potential changes in classloading, see [#14](https://github.com/buildfoundation/bazel_rules_detekt/issues/14)).

## Usage

### `WORKSPACE` Configuration

First of all you need to declare the rule in the `WORKSPACE` file.

Please refer to [GitHub releases](https://github.com/buildfoundation/bazel_rules_detekt/releases) for the version and the SHA-256 hashsum.

```python
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

rules_detekt_version = "see-github-releases-page"
rules_detekt_sha256 = "see-github-releases-page"

http_archive(
    name = "rules_detekt",
    urls = ["https://github.com/buildfoundation/bazel_rules_detekt/archive/%s.zip" % rules_detekt_version],
    type = "zip",
    strip_prefix = "rules_detekt-%s" % rules_detekt_version,
    sha256 = rules_detekt_sha256,
)
```

### `BUILD` Configuration

Once declared in the `WORSKPACE` file, the rule can be loaded in the `BUILD` file.

```python
load("@rules_detekt//detekt:detekt.bzl", "detekt")

detekt(
    name = "my_detekt",
    srcs = glob(["src/main/kotlin/**/*.kt"]),
)
```

#### Attributes

Name                           | Type         | Default | Description
-------------------------------|--------------|---------|--------
`srcs`                         | `label_list` | —       | A glob or an explicit list of Kotlin files.
`config`                       | `label`      | [The Detekt one](https://github.com/arturbosch/detekt/blob/master/detekt-cli/src/main/resources/default-detekt-config.yml) | A path or a target that represents a custom [Detekt configuration file](https://arturbosch.github.io/detekt/configurations.html).
`html_report`                  | `bool`       | `False` | Enables / disables the HTML report generation. The report file name is `{target_name}_detekt_report.html`.
`xml_report`                   | `bool`       | `False` | Enables / disables the XML report generation. The report file name is `{target_name}_detekt_report.xml`. <br/><br/> FYI Detekt uses the Checkstyle XML reporting format which makes it compatible with tools like SonarQube and so on.
`build_upon_default_config`    | `bool`       | `False` | See [Detekt `--build-upon-default-config` option](https://arturbosch.github.io/detekt/cli.html).
`disable_default_rulesets`     | `bool`       | `False` | See [Detekt `--disable-default-rulesets` option](https://arturbosch.github.io/detekt/cli.html).
`fail_fast`                    | `bool`       | `False` | See [Detekt `--fail-fast` option](https://arturbosch.github.io/detekt/cli.html).
`parallel`                     | `bool`       | `False` | See [Detekt `--parallel` option](https://arturbosch.github.io/detekt/cli.html).

Note that a text report is always generated as `{target_name}_detekt_report.txt`
since Bazel requires rules to have outputs.

#### Example

```python
detekt(
    name = "my_detekt",
    srcs = glob(["src/main/kotlin/**/*.kt"]),
    config = "my-detekt-config.yml",
    html_report = True,
    xml_report = True,
    build_upon_default_config = True,
    disable_default_rulesets = True,
    fail_fast = True,
    parallel = True,
)
```

### Execution

```
$ bazel build //mypackage:my_detekt
```

Results will be cached on successful runs.
