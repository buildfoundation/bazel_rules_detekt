#!/bin/bash
# Runs Detekt with --auto-correct on the workspace sources. Only `bazel run` exposes the
# workspace, so sources are never edited during a build or test.
set -euo pipefail
if [ -z "${BUILD_WORKSPACE_DIRECTORY:-}" ]; then
    echo "Use 'bazel run' to auto-correct sources." >&2
    exit 1
fi

runfiles="$PWD"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# Keep '&' literal in the replacement on bash 5.2+.
shopt -u patsub_replacement 2>/dev/null || true
while IFS= read -r arg; do
    printf '%s\n' "${arg//@@RUNFILES@@/$runfiles}"
done <"{params}" >"$tmp/params"
printf '%s\n' --report "txt:$tmp/report.txt" --execution-result "$tmp/exit_code" --run-as-test-target >>"$tmp/params"

cd "$BUILD_WORKSPACE_DIRECTORY"
"$runfiles/{wrapper}" "@$tmp/params"
if [ -s "$tmp/report.txt" ]; then
    cat "$tmp/report.txt"
fi
exit "$(<"$tmp/exit_code")"
