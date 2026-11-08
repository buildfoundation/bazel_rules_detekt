#!/bin/bash
set -eou pipefail

bazel build //docs:docs //docs:config_docs //docs:toolchain_docs

for doc in attrs config_attrs toolchain_attrs; do
    mv "bazel-bin/docs/$doc.md" "docs/$doc.md"
    chmod -x "docs/$doc.md"
    chmod u+w "docs/$doc.md"
done
