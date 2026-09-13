"""Rule declarations.
"""

load(
    "//detekt:rules.bzl",
    _ANDROID_SDK_TOOLCHAIN_TYPE = "ANDROID_SDK_TOOLCHAIN_TYPE",
    _DETEKT_ATTRIBUTES = "DETEKT_ATTRIBUTES",
    _JDK_TOOLCHAIN_TYPE = "JDK_TOOLCHAIN_TYPE",
    _TOOLCHAIN_TYPE = "TOOLCHAIN_TYPE",
    _detekt_create_baseline_rule = "detekt_create_baseline",
    _detekt_rule = "detekt",
    _detekt_test = "detekt_test",
)

ANDROID_SDK_TOOLCHAIN_TYPE = _ANDROID_SDK_TOOLCHAIN_TYPE
DETEKT_ATTRIBUTES = _DETEKT_ATTRIBUTES
JDK_TOOLCHAIN_TYPE = _JDK_TOOLCHAIN_TYPE
TOOLCHAIN_TYPE = _TOOLCHAIN_TYPE

_SHARED_ATTRS = [
    "build_upon_default_config",
    "cfgs",
    "disable_default_rulesets",
    "fail_on_severity",
    "jvm_target",
    "language_version",
    "max_issues",
    "parallel",
    "plugins",
]

def _declare(native_rule, name, kwargs):
    attrs = dict(kwargs)
    attrs["detekt_explicit_attrs"] = [
        attr_name
        for attr_name in _SHARED_ATTRS
        if attr_name in kwargs and kwargs[attr_name] != None
    ]
    native_rule(name = name, **attrs)

def detekt(name, **kwargs):
    """Run Detekt analysis for the supplied Kotlin sources."""
    _declare(_detekt_rule, name, kwargs)

def detekt_create_baseline(name, **kwargs):
    """Create a Detekt baseline for the supplied Kotlin sources."""
    _declare(_detekt_create_baseline_rule, name, kwargs)

def detekt_test(name, **kwargs):
    """Run Detekt analysis as a test for the supplied Kotlin sources."""
    _declare(_detekt_test, name, kwargs)
