<!-- Generated with Stardoc: http://skydoc.bazel.build -->

# Attributes

Name           | Type                               | Default            | Description
---------------|------------------------------------|--------------------|------------
`name` | [`name`](https://docs.bazel.build/versions/master/build-ref.html#name) | — | A unique name for this target.
`default_config` | [`Label`](https://docs.bazel.build/versions/master/skylark/lib/Label.html) | `"@rules_detekt//detekt:default_config"` | Analysis configuration used when a Detekt target omits config.
`detekt_wrapper` | [`Label`](https://docs.bazel.build/versions/master/skylark/lib/Label.html) | `"@rules_detekt//detekt/wrapper:bin"` | Executable wrapper used to run Detekt.
