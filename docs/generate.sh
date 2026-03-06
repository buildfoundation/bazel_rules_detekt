#!/bin/bash
set -eou pipefail

bazel build //docs:docs

mv bazel-bin/docs/attrs.md docs/attrs.md

chmod -x docs/attrs.md
chmod u+w docs/attrs.md
