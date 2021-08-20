"""Shared place to keep versioning information
"""

versions = struct(
    DETEKT_VERSION = "1.17.1",
    DETEKT_CLI_ALL_RELEASE = {
        "urls": [
            "https://github.com/detekt/detekt/releases/download/v{0}/detekt-cli-{0}-all.jar".format("1.17.1"),
        ],
        "sha256": "2a01bc4fe9836d08a683be268887ecd88b6f76b8832078fb153feaf126f91678",
    },
)
