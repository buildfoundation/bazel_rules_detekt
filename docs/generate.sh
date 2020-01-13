#!/bin/bash
set -eou pipefail

bazel build //docs:docs

mv bazel-bin/docs/rule.md docs/rule.md

chmod -x docs/rule.md
chmod u+w docs/rule.md

