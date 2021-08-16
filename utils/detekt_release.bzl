"""Helper macro for creating prebuilt release packages
"""

load("@rules_pkg//:pkg.bzl", "pkg_tar")
load("@bazel_skylib//rules:copy_file.bzl", "copy_file")

def detekt_release_pkg_tar(
        name,
        srcs = None,
        srcs_map = None,
        strip_prefix = None,
        package_dir = None,
        extension = "tgz",
        deps = [],
        visibility = ["//visibility:public"]):
    """Macro for creating release archives

    Args:
        name: name of target to create
        srcs: srcs to include in the archive
        srcs_map: dict of files to include where keys are the original file, and values are final
            name within the archive
        strip_prefix: prefix to strip from entries in the archive
        package_dir: name of the directory to create within the archive
        extension: file extension to apply to the final tar archive
        deps: dependencies to pass to pkg_tar
        visibility: visibility to apply to the release package target
    """

    if srcs == None:
        srcs = []
    if srcs_map == None:
        srcs = {}

    for src, dst in srcs_map.items():
        if dst in srcs:
            fail("Cannot rename {src} to {dst} because it already exists in the provided srcs: {srcs}".format(src = src, dst = dst, srcs = srcs))
        rename_name = "{name}_rename_{src}_to_{dst}".format(name = name, src = src, dst = dst, visibility = ["//visibility:private"])
        copy_file(name = rename_name, src = src, out = name + "/" + dst)
        srcs.append(rename_name)

    pkg_tar(
        name = name,
        srcs = srcs,
        extension = extension,
        package_dir = package_dir,
        visibility = visibility,
        strip_prefix = strip_prefix,
        deps = deps,
    )
