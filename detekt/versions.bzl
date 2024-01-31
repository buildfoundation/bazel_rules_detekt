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
    version = "1.23.5",
    sha256 = "3f3f8c6998a624c0a3b463f2edca22e92484ec8740421b69daef18578b3b28b6",
)
