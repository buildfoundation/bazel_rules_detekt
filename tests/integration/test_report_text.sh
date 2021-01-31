#!/bin/bash
set -eou pipefail

TARGET="detekt_without_config"
OUTPUT_DIR="$(bazel info bazel-bin)/tests/integration"

echo ":: Target without config should fail and generate text report."

set +e
bazel build //tests/integration:${TARGET} > /dev/null
BAZEL_EXIT_CODE=$?
set -e

set -x

test $BAZEL_EXIT_CODE != 0

test ! -f "${OUTPUT_DIR}/${TARGET}_detekt_report.html"
test -f "${OUTPUT_DIR}/${TARGET}_detekt_report.txt"
test ! -f "${OUTPUT_DIR}/${TARGET}_detekt_report.xml"
