#!/bin/bash
set -eou pipefail

GENERATED_CODE_DIR="tests/integration/src/main/kotlin/generated"

BAZEL_RC=".bazelrc"
BAZEL_RC_ORIGINAL=".bazelrc.original"

cp "${BAZEL_RC}" "${BAZEL_RC_ORIGINAL}"

for STRATEGY in "local" "worker"; do
    echo ":: Executing with the [${STRATEGY}] strategy."
    cp "${BAZEL_RC_ORIGINAL}" "${BAZEL_RC}"
    echo "build --strategy=Detekt=${STRATEGY}" >> "${BAZEL_RC}"

    # Generate a bit of code to keep Bazel working instead of pulling from cache to check strategies execution.
    rm -rf "${GENERATED_CODE_DIR}" && mkdir -p "${GENERATED_CODE_DIR}"
    touch "${GENERATED_CODE_DIR}/${STRATEGY}.kt"

    find "tests/integration" -type f -name "test_*.sh" -exec bash {} \;

    rm -rf "${GENERATED_CODE_DIR}"
done

cp "${BAZEL_RC_ORIGINAL}" "${BAZEL_RC}"
rm "${BAZEL_RC_ORIGINAL}"
