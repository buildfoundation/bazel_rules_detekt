"""Macro for defining detekt versions.
"""

def detekt_version(version, sha256):
    """Create a detekt version.

    Args:
        version (str): The version of detekt.
        sha256 (str): The sha256 of the detekt jar.

    Returns: A struct containing the version information.
    """
    return struct(
        version = version,
        sha256 = sha256,
        url_templates = [
            "https://github.com/detekt/detekt/releases/download/v{version}/detekt-cli-{version}-all.jar",
        ],
    )

DEFAULT_DETEKT_RELEASE = detekt_version(
    version = "1.23.8",
    sha256 = "2ce2ff952e150baf28a29cda70a363b0340b3e81a55f43e51ec5edffc3d066c1",
)
