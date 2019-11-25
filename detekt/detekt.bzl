def _java():
    return  

def _impl(ctx):
    java = _java(ctx)
    fail("Java path is " + java)

detekt = rule(
    implementation = _impl,
    attrs = {
        # Vendor Detekt CLI.
        # This is not public API yet because ideally Detekt should run as Persistent Worker which will change how we integrate it.
        "_detekt_cli": attr.label(default = "@detekt_cli//file"),
        "srcs": attr.label_list(),
    },
)
