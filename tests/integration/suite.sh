#!/bin/bash
set -eou pipefail

DIR="tests/integration"

for STRATEGY in "local" "worker"; do
    echo ":: Executing with the [${STRATEGY}] strategy."
    echo "build --strategy=Detekt=${STRATEGY}" > ".bazelrc"

    bazelisk clean

    time find ${DIR} -type f -name "test_*.sh" -exec bash {} \;
done

rm ".bazelrc"