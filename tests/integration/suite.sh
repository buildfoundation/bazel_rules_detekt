#!/bin/bash
set -eou pipefail

GENERATED_CODE_DIR="tests/integration/src/main/kotlin/generated"

for STRATEGY in "local" "worker"; do
    echo ":: Executing with the [${STRATEGY}] strategy."
    echo "build --strategy=Detekt=${STRATEGY}" > ".bazelrc"

    # Generate a bit of code to keep Bazel working instead of pulling from cache to check strategies execution.
    mkdir -p "${GENERATED_CODE_DIR}"
    touch "${GENERATED_CODE_DIR}/${STRATEGY}.kt"

    find "tests/integration" -type f -name "test_*.sh" -exec bash {} \;

    rm -rf "${GENERATED_CODE_DIR}"
done

rm ".bazelrc"
