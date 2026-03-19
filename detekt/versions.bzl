"""Macro for defining detekt versions.
"""

_DEFAULT_URL_TEMPLATES = [
    "https://github.com/detekt/detekt/releases/download/v{version}/detekt-cli-{version}-all.jar",
]

def detekt_version(version, sha256, url_templates = None):
    """Specify a custom Detekt version to use instead of the default.

    Args:
        version: The version of detekt.
        sha256: The sha256 of the detekt jar.
        url_templates: URL templates for downloading detekt. Each template
            may contain `{version}` which will be replaced with the version string.
            Defaults to the standard GitHub release URL.

    Returns:
        A struct containing the version information.
    """
    return struct(
        version = version,
        sha256 = sha256,
        url_templates = url_templates if url_templates != None else _DEFAULT_URL_TEMPLATES,
    )

DEFAULT_DETEKT_RELEASE = detekt_version(
    version = "1.23.8",
    sha256 = "2ce2ff952e150baf28a29cda70a363b0340b3e81a55f43e51ec5edffc3d066c1",
)
