#!/bin/bash
# Runs the auto-correct target the way `bazel run` does, against a fake workspace with a space in its path.
set -euo pipefail

src=tests/integration/testFixtures/basic-jvm/src/jvm/tests/integration/jvm/JvmStatic.kt
export BUILD_WORKSPACE_DIRECTORY="$TEST_TMPDIR/my ws"
mkdir -p "$BUILD_WORKSPACE_DIRECTORY/$(dirname "$src")"
sed 's/fun greeting(name: String)/fun   greeting( name:String )/' "$src" >"$BUILD_WORKSPACE_DIRECTORY/$src"
if cmp -s "$BUILD_WORKSPACE_DIRECTORY/$src" "$src"; then
    echo "fixture was not unformatted" >&2
    exit 1
fi

tests/integration/jvm_auto_correct.sh

# The workspace copy is fixed back to the formatted fixture.
cmp "$BUILD_WORKSPACE_DIRECTORY/$src" "$src"
