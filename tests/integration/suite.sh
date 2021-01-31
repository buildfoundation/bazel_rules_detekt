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
    echo '@file:Suppress("EmptyKtFile")' > "${GENERATED_CODE_DIR}/${STRATEGY}.kt"

    for TEST in tests/integration/test_*.sh; do
        bash "${TEST}"
    done

    rm -rf "${GENERATED_CODE_DIR}"
done

cp "${BAZEL_RC_ORIGINAL}" "${BAZEL_RC}"
rm "${BAZEL_RC_ORIGINAL}"
