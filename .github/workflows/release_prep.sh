#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

# Don't include tests in the release archive
echo >>.git/info/attributes "tests export-ignore"

# Set by GH actions, see
# https://docs.github.com/en/actions/learn-github-actions/environment-variables#default-environment-variables
TAG=${GITHUB_REF_NAME}
# The prefix is chosen to match what GitHub generates for source archives
PREFIX="bazel_rules_detekt-${TAG:1}"
ARCHIVE="bazel_rules_detekt-$TAG.tar.gz"
git archive --format=tar --prefix=${PREFIX}/ ${TAG} | gzip > $ARCHIVE

cat << EOF
## Using Bzlmod

Add to your \`MODULE.bazel\` file:

\`\`\`starlark
bazel_dep(name = "rules_detekt", version = "${TAG:1}")
\`\`\`
EOF
