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
    version = "1.23.1",
    sha256 = "089c15405ec5563adba285d09ceccff047ebc7888b8bbc3a386bbc6c6744d788",
)
