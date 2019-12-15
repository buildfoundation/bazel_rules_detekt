#!/bin/bash
set -eou pipefail

TARGET="detekt_html_report"
OUTPUT_DIR="$(bazelisk info bazel-bin)/tests/integration/"

echo ":: Target with HTML report attribute should generate text and HTML reports."

bazelisk build //tests/integration:${TARGET}

set -x

test -f "${OUTPUT_DIR}/${TARGET}_detekt_report.html"
test -f "${OUTPUT_DIR}/${TARGET}_detekt_report.txt"
test ! -f "${OUTPUT_DIR}/${TARGET}_detekt_report.xml"
