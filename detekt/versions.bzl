"""Macro for defining detekt versions.
"""

_DEFAULT_URL_TEMPLATES = [
    "https://github.com/detekt/detekt/releases/download/v{version}/detekt-cli-{version}-all.jar",
]

def detekt_version(version, sha256, url_templates = None):
    """Create a detekt version.

    Args:
        version (str): The version of detekt.
        sha256 (str): The sha256 of the detekt jar.
        url_templates (list, optional): URL templates for downloading detekt. Each template
            may contain `{version}` which will be replaced with the version string.
            Defaults to the standard GitHub release URL.

    Returns: A struct containing the version information.
    """
    return struct(
        version = version,
        sha256 = sha256,
        url_templates = url_templates if url_templates != None else _DEFAULT_URL_TEMPLATES,
    )

DEFAULT_DETEKT_RELEASE = detekt_version(
    version = "2.0.0-alpha.6",
    sha256 = "d46ca62ea4d62769b5d5c3ba94d49fa9b80ba11c7dba74ddb6df7fcc2c19c5fd",
)
