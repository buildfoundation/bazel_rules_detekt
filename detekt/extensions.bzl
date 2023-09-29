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
    },
)

def _download_detekt_cli_all(detekt):
    http_jar(
        name = "detekt_cli_all",
        sha256 = detekt.sha256,
        urls = [url.format(version = detekt.version) for url in detekt.url_templates],
    )

def _detekt_impl(mctx):
    detekt_version = None
    for mod in mctx.modules:
        for override in mod.tags.detekt_version:
            if detekt_version:
                fail("Only one detekt_version is supported right now!")
            detekt_version = _detekt_version(version = override.version, sha256 = override.sha256)

    kwargs = dict(detekt = _DEFAULT_DETEKT_RELEASE)
    if detekt_version:
        kwargs["detekt"] = detekt_version
    _download_detekt_cli_all(**kwargs)

detekt = module_extension(
    _detekt_impl,
    tag_classes = {"detekt_version": _version_tag},
)
