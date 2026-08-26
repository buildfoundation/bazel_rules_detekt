# `bazel_rules_detekt`

The [Detekt](https://github.com/detekt/detekt) (a Kotlin static analysis tool) integration
for the [Bazel build system](https://bazel.build).

## Features

- configuration and baseline files;
- HTML, text, XML, Markdown, and SARIF reports;
- [plugins](https://detekt.dev/docs/extensions/extensions/);
- customizable Detekt version and JVM flags;
- [persistent workers](https://blog.bazel.build/2015/12/10/java-workers.html) support;
- baseline generation via `detekt_create_baseline`;
- configuration options via [attributes](docs/attrs.md).

## Compatibility

| `bazel_rules_detekt`                | Default Detekt  | Kotlin compiler | Max `language_version` | Min JDK | Max tested JDK | Bazel     |
| ----------------------------------- | --------------- | --------------- | ---------------------- | ------- | -------------- | --------- |
| **working tree / next release**     | 2.0.0-alpha.6   | 2.4.10          | `2.5`                  | 8       | 25             | 8.x – 9.x |
| v0.8.1.9 – v0.8.2.3               | 1.23.8          | 2.0.21          | `2.0`                  | 8       | 21             | 8.x – 9.x |
| v0.8.1.3 – v0.8.1.8                 | 1.23.5          | 1.9.22          | `1.9`                  | 8       | 17             | 7.x – 9.x |
| v0.8.1 – v0.8.1.2                   | 1.23.1          | 1.9.0           | `1.9`                  | 8       | 17             | 6.x       |
| v0.7.0                              | 1.22.0          | —               | —                      | 8       | —              | 5.x       |
| v0.6.0 – v0.6.1                     | 1.19.0 – 1.21.0 | —               | —                      | 8       | —              | 5.x       |
| v0.4.0 – v0.5.0                     | 1.15.0          | —               | —                      | —       | —              | 4.x       |
| v0.3.0                              | 1.7.4           | —               | —                      | —       | —              | 3.x       |
| v0.1.0 – v0.2.0                     | 1.2.0           | —               | —                      | —       | —              | 1.x       |

For detailed per-Detekt-version Kotlin and JDK compatibility, see the [Detekt compatibility table](https://detekt.dev/docs/introduction/compatibility/).

> **Note:** The Kotlin compiler bundled with Detekt determines which `language_version` values are valid — setting it higher than what the bundled compiler supports will cause Detekt to fail. The default Detekt version can always be overridden — see [Detekt Version](#detekt-version).

> **Note:** Detekt 2.x is currently in alpha. The default is 2.0.0-alpha.6; the compatibility suite also validates a Detekt 1.23.8 override.

> **Note:** JDK 25 and above are **not** supported with Detekt 1.23.x. The bundled Kotlin compiler performs a hard version check that fails on JDK 25+. This is resolved in the Detekt 2.x series.

> **Note:** The wrapper reflects over the Detekt 1.x and 2.x CLI entry points during this alpha migration. Detekt 1.x compatibility will be deprecated after Detekt 2.x stabilizes and removed in a subsequent breaking release.

The project is developed and tested against **Bazel 8 and 9** with Bzlmod.

## Usage

Refer to [GitHub releases](https://github.com/buildfoundation/bazel_rules_detekt/releases) for the version and the SHA-256 hashsum.

### `MODULE.bazel` Configuration

```python
bazel_dep(name = "rules_detekt", version = "...")
```

### `BUILD` Configuration

Once declared in the `MODULE.bazel` file, the rules can be loaded in the `BUILD` file.

## Rules

### `detekt`

`detekt` is a regular Bazel build rule. When Detekt finds violations, the **build action itself
fails**, stopping `bazel build` immediately with an error. This makes it behave like a compiler
error — violations block the build.

```python
load("@rules_detekt//detekt:defs.bzl", "detekt")

detekt(
    name = "my_detekt",
    srcs = glob(["src/main/kotlin/**/*.kt"]),
)
```

```console
$ bazel build //mypackage:my_detekt
```

### `detekt_test`

`detekt_test` is a Bazel test rule. The build action always succeeds (even when violations are
found), and Bazel then runs a test script that reads the real Detekt exit code and prints findings
to the test output. Violations cause the **test** to fail rather than the build action.

```python
load("@rules_detekt//detekt:defs.bzl", "detekt_test")

detekt_test(
    name = "my_detekt",
    srcs = glob(["src/main/kotlin/**/*.kt"]),
)
```

```console
$ bazel test //mypackage:my_detekt
```

Because it is a test target, it is included in `bazel test //...` alongside your unit tests,
and it supports standard Bazel test flags such as `--test_output=all`.

### `detekt` vs `detekt_test`

|                     | `detekt`                  | `detekt_test`                          |
| ------------------- | ------------------------- | -------------------------------------- |
| Bazel rule type     | build rule                | test rule                              |
| Run with            | `bazel build`             | `bazel test`                           |
| Included in         | `bazel build //...`       | `bazel test //...`                     |
| Violation behaviour | build action fails        | test fails; build action always passes |
| Text report         | printed when action fails | printed to test output when test fails |
| Result caching      | yes                       | yes                                    |
| Bazel test flags    | n/a                       | yes (`--test_output`, etc.)            |

Use `detekt` when you want violations to block builds the same way a compiler error does. Use
`detekt_test` when you want Detekt to run alongside your test suite and report results through
the test framework.

### `detekt_create_baseline`

`detekt_create_baseline` is an executable rule that generates or updates a
[Detekt baseline](https://detekt.dev/docs/introduction/baseline/) file. The baseline suppresses
existing findings so that only new violations fail the build going forward.

```python
load("@rules_detekt//detekt:defs.bzl", "detekt_create_baseline")

detekt_create_baseline(
    name = "my_detekt_baseline",
    srcs = glob(["src/main/kotlin/**/*.kt"]),
    baseline = "detekt/baseline.xml",  # path where the baseline will be written
)
```

```console
$ bazel run //mypackage:my_detekt_baseline
```

Running this target writes the baseline XML file into your source tree under
`$BUILD_WORKING_DIRECTORY`. If `baseline` is not specified, the output path defaults to
`{package}/default_baseline.xml`.

Once the baseline file exists, reference it in your analysis target:

```python
detekt_test(
    name = "my_detekt",
    srcs = glob(["src/main/kotlin/**/*.kt"]),
    baseline = "detekt-baseline.xml",
)
```

### Configuration Options

All three rules share the same configuration options. In addition to `srcs`, `cfgs`, `baseline`, `plugins`,
and report options, most attributes correspond directly to Detekt CLI flags and pass them through when explicitly set.

`max_issues` is retained for Detekt 1.x. Detekt 2.x uses `fail_on_severity` (`Never`, `Info`, `Warning`, or `Error`);
the attributes are mutually exclusive and must match the selected Detekt major version.

More information can be found in the [attributes](docs/attrs.md).

### Reports

A plain-text report (`{name}_detekt_report.txt`) is **always** generated. Detekt 1.x writes its native text
report; Detekt 2.x writes captured console output to the same artifact. `xml_report` keeps the same output
name and maps to Detekt 2.x's Checkstyle report ID. Other formats are opt-in.

## Advanced Configuration

### Detekt Version

The default bundled version is **2.0.0-alpha.6**. To override it (including the supported Detekt 1.23.8
compatibility runtime):

#### `MODULE.bazel` Configuration

```python
detekt = use_extension("@rules_detekt//detekt:extensions.bzl", "detekt")
detekt.detekt_version(
    version = "...",
    sha256 = "...",
)

use_repo(detekt, "detekt_cli_all")
```

To download Detekt from a custom location (e.g. an internal mirror), use the `url_templates` parameter:

```python
detekt = use_extension("@rules_detekt//detekt:extensions.bzl", "detekt")
detekt.detekt_version(
    version = "...",
    sha256 = "...",
    url_templates = [
        "https://my-mirror.example.com/detekt/detekt-cli-{version}-all.jar",
    ],
)

use_repo(detekt, "detekt_cli_all")
```

To download Detekt from a custom location (e.g., an internal mirror), use the `url_templates` parameter:

```python
detekt = use_extension("@rules_detekt//detekt:extensions.bzl", "detekt")
detekt.detekt_version(
    version = "...",
    sha256 = "...",
    url_templates = [
        "https://my-mirror.example.com/detekt/detekt-cli-{version}-all.jar",
    ],
)

use_repo(detekt, "detekt_cli_all")
```

Each template may contain `{version}` which will be replaced with the version string.

### JVM Flags

The default toolchain uses `-Xms16m -Xmx128m`. To customize JVM flags, define your own toolchain
in a `BUILD` file:

```python
load("@rules_detekt//detekt:toolchain.bzl", "detekt_toolchain")

detekt_toolchain(
    name = "my_detekt_toolchain_impl",
    jvm_flags = ["-Xms16m", "-Xmx512m"],
)

toolchain(
    name = "my_detekt_toolchain",
    toolchain = ":my_detekt_toolchain_impl",
    toolchain_type = "@rules_detekt//detekt:toolchain_type",
)
```

Then register it in `MODULE.bazel`:

```python
register_toolchains("//mypackage:my_detekt_toolchain")
```

### Plugins

The `plugins` attribute accepts any Bazel label that provides `JavaInfo`. This covers both
published Maven artifacts and locally built JARs.

**Maven artifact** (e.g., the [formatting rule set](https://detekt.dev/docs/rules/formatting/)):

```python
maven = use_extension("@rules_jvm_external//:extensions.bzl", "maven")
maven.install(
    artifacts = [
        "dev.detekt:detekt-rules-ktlint-wrapper:2.0.0-alpha.6",
    ],
)
use_repo(maven, "maven")
```

```python
load("@rules_detekt//detekt:defs.bzl", "detekt_test")

detekt_test(
    name = "my_detekt",
    srcs = glob(["src/main/kotlin/**/*.kt"]),
    plugins = ["@maven//:dev_detekt_detekt_rules_ktlint_wrapper"],
)
```

For a Detekt 1.x override, use the matching legacy coordinate instead:
`io.gitlab.arturbosch.detekt:detekt-formatting:1.23.8`. Plugin binaries are not interchangeable
between majors because their public API packages differ (`io.gitlab.arturbosch.detekt.api` versus
`dev.detekt.api`).

**Custom local plugin** built with [`rules_kotlin`](https://github.com/bazelbuild/rules_kotlin):

```python
load("@rules_kotlin//kotlin:jvm.bzl", "kt_jvm_library")
load("@rules_detekt//detekt:defs.bzl", "detekt_test")

kt_jvm_library(
    name = "my_custom_rules",
    srcs = glob(["src/main/kotlin/**/*.kt"]),
)

detekt_test(
    name = "my_detekt",
    srcs = glob(["src/main/kotlin/**/*.kt"]),
    plugins = [":my_custom_rules"],
)
```

### Configuration File

Pass one or more Detekt YAML configuration files via `cfgs`. Files must use the `.yml` extension.
You may pass raw file labels or `filegroup` targets:

```python
detekt_test(
    name = "my_detekt",
    srcs = glob(["src/main/kotlin/**/*.kt"]),
    cfgs = [":detekt.yml"],
)
```

To extend Detekt's built-in defaults rather than replace them, also set `build_upon_default_config = True`:

```python
detekt_test(
    ...
    build_upon_default_config = True,
    ...
)
```

### JVM Target

Use `jvm_target` to set the JVM bytecode target version that matches what was used during compilation.
This defaults to `1.8` if not explicitly set:

```python
detekt_test(
    name = "my_detekt",
    srcs = glob(["src/main/kotlin/**/*.kt"]),
    jvm_target = "11",
)
```

### Language Version

Detekt will report errors for any language features introduced after the specified version if
`language_version` is specified. When unset, no compatibility restriction is applied:

```python
detekt_test(
    name = "my_detekt",
    srcs = glob(["src/main/kotlin/**/*.kt"]),
    language_version = "2.0",
)
```

### Type Resolution

Type resolution enables more advanced static analysis by giving Detekt access to the full compilation classpath,
including return types, nullability, and symbol information — capabilities that match those of the Kotlin compiler
itself. Rules requiring it are annotated with `@RequiresFullAnalysis` in Detekt's source.

Provide the compile dependencies through `deps` and use `jvm_target` and `language_version` to match the
compilation settings of your project. With Detekt 2.x, a non-empty `deps` automatically selects full analysis;
the Detekt 1.x runtime keeps its existing classpath behavior.

```python
detekt_test(
    name = "my_detekt",
    srcs = glob(["src/main/kotlin/**/*.kt"]),
    deps = [":my_compiled_library"],
    jvm_target = "11",
    language_version = "2.0",
)
```

### Reports

By default, Detekt generates a text report internally (used for console output). To export reports as build outputs,
enable them explicitly:

```python
detekt_test(
    name = "my_detekt",
    srcs = glob(["src/main/kotlin/**/*.kt"]),
    txt_report = True,   # {target_name}_detekt_report.txt
    html_report = True,  # {target_name}_detekt_report.html
    xml_report = True,   # {target_name}_detekt_report.xml  (Checkstyle format, compatible with SonarQube)
    md_report = True,    # {target_name}_detekt_report.md
    sarif_report = True, # {target_name}_detekt_report.sarif
)
```

Any combination of reports may be enabled.
