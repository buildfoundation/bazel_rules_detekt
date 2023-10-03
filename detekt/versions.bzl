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
    version = "1.22.0",
    sha256 = "34238c05c02d93b70e94fdc7f01cff85f47fdf4e63fc37daa05af0739d386ffe",
)
