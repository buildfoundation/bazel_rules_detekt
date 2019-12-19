<!-- Generated with Stardoc: http://skydoc.bazel.build -->

# Attributes

Name           | Type                               | Default            | Description
---------------|------------------------------------|--------------------|------------
`name` | [`name`](https://docs.bazel.build/versions/master/build-ref.html#name) | — | A unique name for this target.
`baseline` | [`Label`](https://docs.bazel.build/versions/master/skylark/lib/Label.html) | `None` | [Detekt baseline file](https://arturbosch.github.io/detekt/baseline.html).
`build_upon_default_config` | [`bool`](https://docs.bazel.build/versions/master/skylark/lib/bool.html) | `False` | See [Detekt `--build-upon-default-config` option](https://arturbosch.github.io/detekt/cli.html).
`cfgs` | [`[Label]`](https://docs.bazel.build/versions/master/skylark/lib/list.html) | `[]` | [Detekt configuration files](https://arturbosch.github.io/detekt/configurations.html). Otherwise [the default configuration](https://github.com/arturbosch/detekt/blob/master/detekt-cli/src/main/resources/default-detekt-config.yml) is used.
`disable_default_rulesets` | [`bool`](https://docs.bazel.build/versions/master/skylark/lib/bool.html) | `False` | See [Detekt `--disable-default-rulesets` option](https://arturbosch.github.io/detekt/cli.html).
`fail_fast` | [`bool`](https://docs.bazel.build/versions/master/skylark/lib/bool.html) | `False` | See [Detekt `--fail-fast` option](https://arturbosch.github.io/detekt/cli.html).
`html_report` | [`bool`](https://docs.bazel.build/versions/master/skylark/lib/bool.html) | `False` | Enables / disables the HTML report generation. The report file name is `{target_name}_detekt_report.html`.
`parallel` | [`bool`](https://docs.bazel.build/versions/master/skylark/lib/bool.html) | `False` | See [Detekt `--parallel` option](https://arturbosch.github.io/detekt/cli.html).
`srcs` | [`[Label]`](https://docs.bazel.build/versions/master/skylark/lib/list.html) | — | Kotlin source code files.
`xml_report` | [`bool`](https://docs.bazel.build/versions/master/skylark/lib/bool.html) | `False` | Enables / disables the XML report generation. The report file name is `{target_name}_detekt_report.xml`. FYI Detekt uses the Checkstyle XML reporting format which makes it compatible with tools like SonarQube.

