#!/bin/bash
set -eou pipefail

TARGET="detekt_without_config_with_baseline"
OUTPUT_DIR="$(bazel info bazel-bin)/tests/integration/"

echo ":: Target without config and with baseline should not fail and should generate text report."

bazel build //tests/integration:${TARGET}

set -x

test ! -f "${OUTPUT_DIR}/${TARGET}_detekt_report.html"
test -f "${OUTPUT_DIR}/${TARGET}_detekt_report.txt"
test ! -f "${OUTPUT_DIR}/${TARGET}_detekt_report.xml"
