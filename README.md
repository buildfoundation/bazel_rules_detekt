# `bazel_rules_detekt`

The [Detekt](https://github.com/detekt/detekt) (a Kotlin static analysis tool) integration
for the [Bazel build system](https://bazel.build).

## Features

- configuration and baseline files;
- HTML, XML, Markdown, and SARIF reports;
- [plugins](https://detekt.dev/docs/extensions/extensions/);
- customizable Detekt version and JVM flags;
- [type resolution](https://detekt.dev/docs/gettingstarted/type-resolution/) with JVM and Android classpath support;
- baseline generation via `detekt_create_baseline`;
- configuration options via [attributes](docs/attrs.md).

## Compatibility

> **Breaking change:** `bazel_rules_detekt` v2.0+ requires **Detekt 2.0 or later**. It is not compatible with Detekt 1.x. If you need Detekt 1.x support, use `bazel_rules_detekt` v0.8.x.

| `bazel_rules_detekt`        | Default Detekt  | Kotlin compiler | `language_version` | JDK        | Bazel     |
|-----------------------------| --------------- | --------------- | ------------------- | ---------- | --------- |
| **v1.0-alpha.2** _(latest)_ | 2.0.0-alpha.2   | 2.2.x           | `1.0` – `2.3`       | 8 – 21     | 9.x       |
| v0.8.1.9 – v0.8.1.13        | 1.23.8          | 2.0.21          | `1.0` – `2.0`       | 8 – 21     | 9.x       |
| v0.8.1.3 – v0.8.1.8         | 1.23.5          | 1.9.22          | `1.0` – `1.9`       | 8 – 17     | 7.x – 9.x |
| v0.8.1 – v0.8.1.2           | 1.23.1          | 1.9.0           | `1.0` – `1.9`       | 8 – 17     | 6.x       |
| v0.7.0                      | 1.22.0          | —               | —                   | 8+         | 5.x       |
| v0.6.0 – v0.6.1             | 1.19.0 – 1.21.0 | —               | —                   | 8+         | 5.x       |
| v0.4.0 – v0.5.0             | 1.15.0          | —               | —                   | —          | 4.x       |
| v0.3.0                      | 1.7.4           | —               | —                   | —          | 3.x       |
| v0.1.0 – v0.2.0             | 1.2.0           | —               | —                   | —          | 1.x       |

For detailed per-Detekt-version Kotlin and JDK compatibility, see the [Detekt compatibility table](https://detekt.dev/docs/introduction/compatibility/).

> **Note:** The Kotlin compiler bundled with Detekt determines which `language_version` values are valid — setting it higher than what the bundled compiler supports will cause Detekt to fail. The default Detekt version can always be overridden — see [Detekt Version](#detekt-version).

> **Important:** Detekt 2.x is currently in alpha (targeting Kotlin 2.2+) and is not yet recommended for production use.

### Bazel

| Bazel version | `MODULE.bazel` (Bzlmod) | `WORKSPACE`                                              |
| ------------- | ----------------------- | -------------------------------------------------------- |
| 9.x           | ✅                      | ✅ requires `--enable_workspace`                         |
| 8.x           | ✅                      | ⚠️ disabled by default; opt-in with `--enable_workspace` |
| 7.x           | ✅                      | ✅ (deprecated; bzlmod recommended)                      |
| 6.x           | ✅                      | ✅                                                       |
| < 6           | ❌                      | ✅                                                       |

The project is developed and tested against **Bazel 9**. Older versions may work but are not actively tested.

## Usage

Refer to [GitHub releases](https://github.com/buildfoundation/bazel_rules_detekt/releases) for the version and the SHA-256 hashsum.

### `MODULE.bazel` Configuration

```python
bazel_dep(name = "rules_detekt", version = "...")
```

### `WORKSPACE` Configuration

```python
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

rules_detekt_version = "see-github-releases-page"
rules_detekt_sha = "see-github-releases-page"

http_archive(
    name = "rules_detekt",
    sha256 = rules_detekt_sha,
    strip_prefix = "bazel_rules_detekt-{v}".format(v = rules_detekt_version),
    url = "https://github.com/buildfoundation/bazel_rules_detekt/archive/v{v}.tar.gz".format(v = rules_detekt_version),
)

load("@rules_detekt//detekt:dependencies.bzl", "rules_detekt_dependencies")
rules_detekt_dependencies()

load("@rules_detekt//detekt:toolchains.bzl", "rules_detekt_toolchains")
rules_detekt_toolchains()
```

### `BUILD` Configuration

Once declared in the `WORKSPACE` or `MODULE.bazel` file, the rules can be loaded in the `BUILD` file.

## Rules

### `detekt`

`detekt` is a regular Bazel build rule. When Detekt reports findings, the **build action itself
fails**, stopping `bazel build` immediately with an error. This makes it behave like a compiler
error — findings block the build.

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

`detekt_test` is a Bazel test rule. The build action always succeeds (even when findings are
reported), and Bazel then runs a test script that reads the real Detekt exit code and prints findings
to the test output. Findings cause the **test** to fail rather than the build action.

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

|                     | `detekt`                  | `detekt_test`                                                         |
| ------------------- | ------------------------- |-----------------------------------------------------------------------|
| Bazel rule type     | build rule                | test rule                                                             |
| Run with            | `bazel build`             | `bazel test`                                                          |
| Included in         | `bazel build //...`       | `bazel test //...`                                                    |
| Finding behavior    | build action fails        | test fails; build action always passes even if findings are reported  |
| Console output      | printed when action fails | printed to test output when test fails                                |
| Result caching      | yes                       | yes                                                                   |
| Bazel test flags    | n/a                       | yes (`--test_output`, etc.)                                           |

Use `detekt` when you want findings to block builds the same way a compiler error does. Use
`detekt_test` when you want Detekt to run alongside your test suite and report results through
the test framework.

### `detekt_create_baseline`

`detekt_create_baseline` is an executable rule that generates or updates a
[Detekt baseline](https://detekt.dev/docs/introduction/baseline/) file. The baseline suppresses
existing findings so that only new findings fail the build going forward.

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

All three rules share the same configuration options. In addition to `srcs`, `deps`, `cfgs`,
`baseline`, `plugins`, `analysis_mode`, `is_android`, and report options, most attributes
correspond directly to
[Detekt CLI flags](https://detekt.dev/docs/gettingstarted/cli/#use-the-cli) and pass them
through when explicitly set.

More information can be found in the [attributes](docs/attrs.md).

### Reports

Findings are printed directly to the console. Report files can be enabled for export as build outputs via attributes.

## Type Resolution

Type resolution enables more advanced static analysis by giving Detekt access to the full
compilation classpath — including return types, nullability, and symbol information. Rules
requiring it extend the `RequiresAnalysisApi` interface.

Type resolution is controlled by the `analysis_mode` attribute:

- `"light"` *(default)* — syntax-based analysis only; no classpath is passed to Detekt:

```python
load("@rules_detekt//detekt:defs.bzl", "detekt_test")

detekt_test(
    name = "my_detekt",
    srcs = glob(["src/main/kotlin/**/*.kt"]),
    analysis_mode = "light",
)
```

- `"full"` — passes the compilation classpath to Detekt and enables type-aware rules. The
  appropriate bootclasspath (JDK or Android SDK) is always included. To also include your
  project's library dependencies, pass them via `deps`:

```python
detekt_test(
    name = "my_detekt",
    srcs = glob(["src/main/kotlin/**/*.kt"]),
    analysis_mode = "full",
    deps = [":my_library"],  # used to construct the classpath for type resolution
)
```

For **Android targets**, set `is_android = True` to include the Android SDK jar in the classpath
(requires `analysis_mode = "full"`):

```python
detekt_test(
    name = "my_detekt",
    srcs = glob(["src/main/kotlin/**/*.kt"]),
    analysis_mode = "full",
    deps = [":my_android_library"],
    is_android = True,
)
```

`jvm_target` and `language_version` are toolchain-level settings — see
[Toolchain](#toolchain) for how to configure them.

## Advanced Configuration

### Detekt Version

The default bundled version is **2.0.0-alpha.2**. To override it:

#### `MODULE.bazel` Configuration

```python
detekt = use_extension("@rules_detekt//detekt:extensions.bzl", "detekt")
detekt.detekt_version(
    version = "...",
    sha256 = "...",
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

#### `WORKSPACE` Configuration

```python
load("@rules_detekt//detekt:versions.bzl", "detekt_version")
load("@rules_detekt//detekt:dependencies.bzl", "rules_detekt_dependencies")

rules_detekt_dependencies(
    detekt_version = detekt_version(
        version = "...",
        sha256 = "...",
    )
)
```

To download Detekt from a custom location (e.g., an internal mirror), use the `url_templates` parameter:

```python
rules_detekt_dependencies(
    detekt_version = detekt_version(
        version = "...",
        sha256 = "...",
        url_templates = [
            "https://my-mirror.example.com/detekt/detekt-cli-{version}-all.jar",
        ],
    )
)
```

Each template may contain `{version}` which will be replaced with the version string.

### Toolchain

The detekt toolchain controls JVM flags, the JVM bytecode target version, and the Kotlin language
version compatibility. The defaults are:

| Setting            | Default            |
| ------------------ |--------------------|
| `jvm_flags`        | `-Xms16m -Xmx128m` |
| `jvm_target`       | `1.8`              |
| `language_version` | `2.3`              |

To override any of these, define a custom toolchain in a `BUILD` file:

```python
load("@rules_detekt//detekt:toolchain.bzl", "detekt_toolchain")

detekt_toolchain(
    name = "my_detekt_toolchain_impl",
    jvm_flags = ["-Xms16m", "-Xmx512m"],
    jvm_target = "11",
    language_version = "2.1",
)

toolchain(
    name = "my_detekt_toolchain",
    toolchain = ":my_detekt_toolchain_impl",
    toolchain_type = "@rules_detekt//detekt:toolchain_type",
)
```

Then register it in `WORKSPACE`:

```python
load("@rules_detekt//detekt:toolchains.bzl", "rules_detekt_toolchains")

rules_detekt_toolchains(toolchain = "//mypackage:my_detekt_toolchain")
```

Or `MODULE.bazel`:

```python
register_toolchains("//mypackage:my_detekt_toolchain")
```

### Plugins

The `plugins` attribute accepts any Bazel label that provides `JavaInfo`. This covers both
published Maven artifacts and locally built JARs.

**Maven artifact** (e.g., the [ktlint wrapper plugin](https://detekt.dev/docs/rules/formatting/)):

```python
maven = use_extension("@rules_jvm_external//:extensions.bzl", "maven")
maven.install(
    artifacts = [
        "dev.detekt:detekt-rules-ktlint-wrapper:2.0.0-alpha.2",
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

To extend Detekt's built-in configuration defaults rather than replace them, also set `build_upon_default_config = True`:

```python
detekt_test(
    ...
    build_upon_default_config = True,
    ...
)
```

### Reports

Findings are always printed to the console via Detekt's built-in console reporter. To also export
reports as build outputs, enable them explicitly:

```python
detekt_test(
    name = "my_detekt",
    srcs = glob(["src/main/kotlin/**/*.kt"]),
    html_report = True,  # {target_name}_detekt_report.html
    xml_report = True,   # {target_name}_detekt_report.xml  (Checkstyle format, compatible with SonarQube)
    md_report = True,    # {target_name}_detekt_report.md
    sarif_report = True, # {target_name}_detekt_report.sarif
)
```

Any combination of reports may be enabled.
