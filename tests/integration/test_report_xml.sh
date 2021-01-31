#!/bin/bash
set -eou pipefail

TARGET="detekt_without_config_with_report_xml"
OUTPUT_DIR="$(bazel info bazel-bin)/tests/integration"

echo ":: Target without config and with XML report attribute should generate text and XML reports."

set +e
bazel build //tests/integration:${TARGET} > /dev/null
BAZEL_EXIT_CODE=$?
set -e

set -x

test $BAZEL_EXIT_CODE != 0

test ! -f "${OUTPUT_DIR}/${TARGET}_detekt_report.html"
test -f "${OUTPUT_DIR}/${TARGET}_detekt_report.txt"
test -f "${OUTPUT_DIR}/${TARGET}_detekt_report.xml"
