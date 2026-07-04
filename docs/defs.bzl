"""Stardoc facade for the public Detekt rule attributes.

The executable rules are legacy macros backed by private native rules.  Stardoc
0.7.2 renders native rule metadata, so this file exposes a non-runnable native
facade using the attribute objects exported by detekt/defs.bzl.  Keep this file
private to the documentation package.
"""

load("//detekt:defs.bzl", "DETEKT_ATTRIBUTES")

def _docs_impl(_ctx):
    return []

_DOC_ATTRS = {
    name: attribute
    for name, attribute in DETEKT_ATTRIBUTES.items()
    if name != "detekt_explicit_attrs"
}

detekt = rule(
    implementation = _docs_impl,
    attrs = _DOC_ATTRS,
)
