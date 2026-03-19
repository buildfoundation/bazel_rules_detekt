"""
Macros for defining toolchains.
See https://docs.bazel.build/versions/master/skylark/deploying.html#registering-toolchains
"""

# buildifier: disable=unnamed-macro
def rules_detekt_toolchains(toolchain = "@rules_detekt//detekt:default_toolchain"):
    """Registers `rules_detekt` toolchains.

    For WORKSPACE-based setups, call this macro in your `WORKSPACE` file.
    With Bzlmod (`MODULE.bazel`), toolchains are registered automatically and
    this macro is not needed.

    Args:
        toolchain: `detekt_toolchain` target to register.
    """
    native.register_toolchains(toolchain)
