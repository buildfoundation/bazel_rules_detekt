#!/bin/bash
set -eou pipefail

TARGET="detekt_with_default_attributes"
OUTPUT_DIR="$(bazelisk info bazel-bin)/tests/integration/"

bazelisk clean
bazelisk build //tests/integration:${TARGET}

set -x

test ! -f "${OUTPUT_DIR}/${TARGET}_detekt_report.html"
test -f "${OUTPUT_DIR}/${TARGET}_detekt_report.txt"
test ! -f "${OUTPUT_DIR}/${TARGET}_detekt_report.xml"
