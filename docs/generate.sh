#!/bin/bash
set -eou pipefail

bazel build //docs:docs --check_visibility=false

mv bazel-bin/docs/rules_detekt.md.generated docs/rules_detekt.md

chmod -x docs/rules_detekt.md
chmod u+w docs/rules_detekt.md
