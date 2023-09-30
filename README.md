# `bazel_rules_detekt`

The [Detekt](https://github.com/detekt/detekt) (a Kotlin static analysis tool) integration
for [the Bazel build system](https://bazel.build).

## Features

- configuration and baseline files;
- HTML, text and XML reports;
- [plugins](https://detekt.github.io/detekt/extensions.html);
- customizable Detekt version and JVM flags;
- [persistent workers](https://blog.bazel.build/2015/12/10/java-workers.html) support;
- [and more](docs/rule.md).

## Usage

### `MODULE.bazel` Configuration

```python
bazel_dep(name = "rules_detekt", version = "...")
```

### `WORKSPACE` Configuration

First of all you need to declare the rule in the `WORKSPACE` file.
Please refer to [GitHub releases](https://github.com/buildfoundation/bazel_rules_detekt/releases) for the version and
the SHA-256 hashsum.

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

### bazelrc Configuration

Users on Bazel releases prior to 5.1.0 need to enable the JSON Persistent Worker protocol in their `.bazelrc` like so:

```bash
build --experimental_worker_allow_json_protocol
```

This option [became stable](https://github.com/bazelbuild/bazel/commit/9e16a6484e94c358aa77a6ed7b1ded3243b65e8f)
and [enabled by default for newer Bazel releases](https://github.com/bazelbuild/bazel/commit/09df7c0a14b9bf13d4aa18f5a02b4651e626d5f4).

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

```console
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

```diff
- rules_detekt_toolchains()
+ rules_detekt_toolchains(toolchain = "//mypackage:my_detekt_toolchain")
```
