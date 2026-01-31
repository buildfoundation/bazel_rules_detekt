"""
Macros for defining toolchains.
See https://docs.bazel.build/versions/master/skylark/deploying.html#registering-toolchains
"""

# buildifier: disable=unnamed-macro
def rules_detekt_toolchains(toolchain = "@rules_detekt//detekt:default_toolchain"):
    """Invokes `rules_detekt` toolchains.

    Declares toolchains that are dependencies of the `rules_detekt` workspace.
    Users should call this macro in their `WORKSPACE` file.

    Args:
        toolchain: `detekt_toolchain` used by rules.
    """
    native.register_toolchains(toolchain)
