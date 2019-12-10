#!/bin/bash
set -eou pipefail

bazelisk clean

set +e
bazelisk build //tests/integration:detekt_with_strict_config > /tmp/bazel.log > /dev/null
BAZEL_EXIT_CODE=$?
set -e

test BAZEL_EXIT_CODE != 0
