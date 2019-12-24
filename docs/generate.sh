#!/bin/bash
set -eou pipefail

bazelisk build //docs:docs

mv bazel-bin/docs/rule.md docs/rule.md

chmod -x docs/rule.md
chmod u+w docs/rule.md

