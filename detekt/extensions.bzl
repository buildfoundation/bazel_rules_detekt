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
    # The root module's detekt_version wins over any set by dependencies.
    overrides = [tag for mod in mctx.modules if mod.is_root for tag in mod.tags.detekt_version]
    if not overrides:
        overrides = [tag for mod in mctx.modules for tag in mod.tags.detekt_version]
    if len(overrides) > 1:
        fail("Only a single detekt_version at once is supported right now!")

    detekt = _DEFAULT_DETEKT_RELEASE
    if overrides:
        detekt = _detekt_version(
            version = overrides[0].version,
            sha256 = overrides[0].sha256,
            url_templates = overrides[0].url_templates or None,
        )
    _download_detekt_cli_all(detekt)

detekt = module_extension(
    _detekt_impl,
    tag_classes = {"detekt_version": _version_tag},
)
