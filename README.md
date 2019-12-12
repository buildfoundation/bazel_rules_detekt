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
load("@rules_detekt//detekt:defs.bzl", "detekt")

detekt(
    name = "my_detekt",
    srcs = glob(["src/main/kotlin/**/*.kt"]),
)
```

See [available attributes](docs/rule.md).

### Execution

```
$ bazel build //mypackage:my_detekt
```

Results will be cached on successful runs.
