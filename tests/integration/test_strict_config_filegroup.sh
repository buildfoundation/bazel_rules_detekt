#!/bin/bash
set -eou pipefail

echo ":: Target with strict config filegroup should fail."

set +e
bazel build //tests/integration:detekt_with_strict_config_filegroup > /tmp/bazel.log > /dev/null
BAZEL_EXIT_CODE=$?
set -e

test BAZEL_EXIT_CODE != 0
