"""Bzlmod extensions for detekt
"""

load(
    "@bazel_tools//tools/build_defs/repo:http.bzl",
    "http_jar",
)
load(
    ":versions.bzl",
    _DEFAULT_DETEKT_RELEASE = "DEFAULT_DETEKT_RELEASE",
    _detekt_version = "detekt_version",
)

_version_tag = tag_class(
    attrs = {
        "version": attr.string(mandatory = True),
        "sha256": attr.string(mandatory = True),
        "url_templates": attr.string_list(),
    },
)

def _download_detekt_cli_all(detekt):
    http_jar(
        name = "detekt_cli_all",
        sha256 = detekt.sha256,
        urls = [url.format(version = detekt.version) for url in detekt.url_templates],
    )

def _detekt_impl(mctx):
    # Only the root module picks the Detekt version, so dependencies cannot change it or conflict with it.
    overrides = [tag for mod in mctx.modules if mod.is_root for tag in mod.tags.detekt_version]
    if len(overrides) > 1:
        fail("Only a single detekt_version at once is supported right now!")

    detekt = _DEFAULT_DETEKT_RELEASE
    for override in overrides:
        detekt = _detekt_version(
            version = override.version,
            sha256 = override.sha256,
            url_templates = override.url_templates if override.url_templates else None,
        )
    _download_detekt_cli_all(detekt = detekt)

detekt = module_extension(
    _detekt_impl,
    tag_classes = {"detekt_version": _version_tag},
)
