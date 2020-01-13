#!/bin/bash
set -eou pipefail

TARGET="detekt_with_strict_config_filegroup_and_baseline"
OUTPUT_DIR="$(bazel info bazel-bin)/tests/integration/"

echo ":: Target with strict config filegroup and baseline should not fail (like the baseline-less does) and should generate text report."

bazel build //tests/integration:${TARGET}

set -x

test ! -f "${OUTPUT_DIR}/${TARGET}_detekt_report.html"
test -f "${OUTPUT_DIR}/${TARGET}_detekt_report.txt"
test ! -f "${OUTPUT_DIR}/${TARGET}_detekt_report.xml"
