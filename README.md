# bazel_rules_detekt

Integration of [Detekt](https://github.com/arturbosch/detekt) — Kotlin static analysis tool for [Bazel build system](https://bazel.build).

***Table of Contents***

- [Overview](#overview)
    - [Features](#features)
    - [TODOs](#todos)
- [Usage](#usage)
    - [`WORKSPACE` Configuration](#workspace-configuration)
    - [`BUILD` Configuration](#build-configuration)
    - [Executing](#executing)
    - [Supported Attributes](#supported-attributes)
        - [`srcs`](#srcs)
        - [`config`](#config)
        - [`parallel`](#parallel)
        - [`xml_report`](#xml_report)
        - [`html_report`](#html_report)

## Overview

### Features 

- User-Provided Detekt Config Files
- TXT, XML and HTML Reporting
- Parallel Detekt "Compilation" 

### TODOs

- Baseline Files (blocked by Detekt outputting and reading absolute paths in baselines, see [#3](https://github.com/buildfoundation/bazel_rules_detekt/issues/3))
- Persistent Worker Mode
- User-Provided Detekt CLI Jar (blocked by Persistent Worker Mode due to potential changes in classloading/etc, see [#14](https://github.com/buildfoundation/bazel_rules_detekt/issues/14))


## Usage

### `WORKSPACE` Configuration

First of all you need to declare `rules_detekt` in `WORKSPACE`:

(for version and sha256 see [GitHub Releases page](https://github.com/buildfoundation/bazel_rules_detekt/releases))

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

Once declared in `WORSKPACE`, `rules_detekt` can be `load`ed and applied in a `BUILD` file:

```python
load("@rules_detekt//detekt:detekt.bzl", "detekt")

detekt(
    name = "my_detekt",
    srcs = glob(["src/main/kotlin/**/*.kt"]),
)
```

### Executing

Once set up, Detekt targets can be ran with `bazel build //mypackage:my_detekt`.
Detekt targets will be cached if ran successfully.

### Supported Attributes

#### `srcs`

- Starlark type: `label_list`
- Mandatory: `True`

A glob or an explicit list of `.kt` files for Detekt analysis.

```python
detekt(
    srcs = glob(["src/main/kotlin/**/*.kt"]),
)
```

#### `config`

- Starlark type: `label`
- Mandatory: `False`
- Default value: [default Detekt configuration](https://github.com/arturbosch/detekt/blob/master/detekt-cli/src/main/resources/default-detekt-config.yml) (mind the Detekt version)  

A path or target that represents custom Detekt configuration file.
File must have `.yml` extension (expected by Detekt).
See official Detekt documentation for details https://github.com/arturbosch/detekt/blob/master/detekt-cli/src/main/resources/default-detekt-config.yml

```python
detekt(
    config = "my-detekt-config.yml",
)
```

#### `parallel`

- Starlark type: `bool`
- Mandatory: `False`
- Default value: `False`

As per Detekt documentation https://arturbosch.github.io/detekt/cli.html: Enables/disables parallel compilation of source files. 
Should only be used if the analyzing project has more than ~200 Kotlin files.

```python
detekt(
    parallel = True,
)
```

#### `xml_report`

- Starlark type: `bool`
- Mandatory: `False`
- Default value: `False`

Enables/disables XML report file generation. The report is generated with following pattern: `{target_name}_detekt_report.xml`
FYI Detekt uses Checkstyle XML reporting format which makes it compatible with tools like SonarQube and so on. 
Note that `rules_detekt` always generate txt report file: `{target_name}_detekt_report.txt`

```python
detekt(
    xml_report = True,
)
```

#### `html_report`

- Starlark type: `bool`
- Mandatory: `False`
- Default value: `False`

Enables/disables HTML report file generation. The report is generated with following pattern: `{target_name}_detekt_report.html` 
Note that `rules_detekt` always generate txt report file: `{target_name}_detekt_report.txt`

```python
detekt(
    html_report = True,
)
```
