# `bazel_rules_detekt`

The [Detekt](https://github.com/arturbosch/detekt) (a Kotlin static analysis tool) integration
for [the Bazel build system](https://bazel.build).

## Features

- configuration files;
- baseline files;
- HTML, text and XML reports;
- customizable Detekt version;
- customizable JVM flags;
- [persistent workers](https://blog.bazel.build/2015/12/10/java-workers.html) support;
- [and more](docs/rule.md).

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
    sha256 = rules_detekt_sha256,
    strip_prefix = "bazel_rules_detekt-{v}".format(v = rules_detekt_version),
    url = "https://github.com/buildfoundation/bazel_rules_detekt/archive/{v}.tar.gz".format(v = rules_detekt_version),
)

load("@rules_detekt//detekt:dependencies.bzl", "rules_detekt_dependencies")
rules_detekt_dependencies()

load("@rules_detekt//detekt:toolchains.bzl", "rules_detekt_toolchains")
rules_detekt_toolchains()
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

### Advanced Configuration

#### Detekt Version

Change the `WORKSPACE` file:

```diff
- rules_detekt_toolchains()
+ rules_detekt_toolchains(detekt_version = "x.y.z")
```

#### JVM Flags

Define a toolchain in a `BUILD` file:

```python
load("@rules_detekt//detekt:toolchain.bzl", "detekt_toolchain")

detekt_toolchain(
    name = "my_detekt_toolchain_impl",
    jvm_flags = ["-Xms16m", "-Xmx128m"],
)

toolchain(
    name = "my_detekt_toolchain",
    toolchain = "my_detekt_toolchain_impl",
    toolchain_type = "@rules_detekt//detekt:toolchain_type",
)
```

Change the `WORKSPACE` file:

```python
- rules_detekt_toolchains()
+ rules_detekt_toolchains(toolchain = "//mypackage:my_detekt_toolchain")
```
