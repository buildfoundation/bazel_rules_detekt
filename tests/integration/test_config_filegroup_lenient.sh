#!/bin/bash
set -eou pipefail

TARGET="detekt_with_config_filegroup_lenient"
OUTPUT_DIR="$(bazel info bazel-bin)/tests/integration"

echo ":: Target with lenient config file group should not fail and should generate text report."

bazel build //tests/integration:${TARGET}

set -x

test ! -f "${OUTPUT_DIR}/${TARGET}_detekt_report.html"
test -f "${OUTPUT_DIR}/${TARGET}_detekt_report.txt"
test ! -f "${OUTPUT_DIR}/${TARGET}_detekt_report.xml"
