#!/bin/bash
#
# Shared helper for rules_detekt integration tests run as script_test.
#
# Each test script sources this helper, then defines bashunit-style test_*
# functions. set_up_workspace() builds an inner Bazel workspace that depends on
# the outer rules_detekt source tree via local_path_override (bzlmod) or
# local_repository (workspace mode), and provides utilities for emitting a
# BUILD file with a detekt target, generating cache-busting sources, and
# inspecting the resulting reports.

# --- begin runfiles.bash initialization v2 ---
set -uo pipefail; f=bazel_tools/tools/bash/runfiles/runfiles.bash
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
  source "$0.runfiles/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  { echo>&2 "ERROR: cannot find $f"; exit 1; }; f=; set -e
# --- end runfiles.bash initialization v2 ---

# Resolve a runfile under the rules_detekt main repo. The apparent repo name
# under bzlmod comes from MODULE.bazel's repo_name = "bazel_rules_detekt".
# rlocation returns 1 when a path is unresolvable, which would kill the
# script under set -e, so guard with `|| true`.
function rd_rlocation() {
  rlocation "bazel_rules_detekt/$1" 2>/dev/null || true
}

source "$(rd_rlocation tests/bashunit/unittest.bash)" || \
  (echo >&2 "Failed to locate unittest.bash" && exit 1)

_WORKSPACE_INITIALIZED=false

DETEKT_FORMATTING_ARTIFACT="io.gitlab.arturbosch.detekt:detekt-formatting:1.23.1"
RULES_JVM_EXTERNAL_VERSION="6.9"

function get_rules_detekt_path() {
  local module_bazel
  module_bazel="$(rd_rlocation MODULE.bazel)"
  if [[ -z "${module_bazel}" || ! -f "${module_bazel}" ]]; then
    fail "Failed to locate rules_detekt MODULE.bazel"
  fi
  local real_path
  real_path="$(python3 -c "import os, sys; print(os.path.realpath(sys.argv[1]))" "${module_bazel}")"
  dirname "${real_path}"
}

function set_up_workspace() {
  if [[ "${_WORKSPACE_INITIALIZED}" == "true" ]]; then
    reset_per_test_state
    return
  fi
  _WORKSPACE_INITIALIZED=true

  rm -rf -- *

  local rules_detekt_dir
  rules_detekt_dir="$(get_rules_detekt_path)"

  # The inner workspace always uses bzlmod. Bazel 9+ silently forces bzlmod
  # on even when --noenable_bzlmod is passed, so a separate WORKSPACE-mode
  # branch would be dead code.
  write_inner_module_bazel "${rules_detekt_dir}"
}

# Wipe per-test state so each test starts from a known BUILD file and
# without stale generated cache-buster sources from a prior test.
function reset_per_test_state() {
  rm -f BUILD
  rm -rf src/main/kotlin/generated
}

function write_inner_module_bazel() {
  local rules_dir="$1"

  cat > MODULE.bazel <<EOF
module(name = "rules_detekt_integration_test")

bazel_dep(name = "rules_detekt", version = "0.0.0")
local_path_override(
    module_name = "rules_detekt",
    path = "${rules_dir}",
)

bazel_dep(name = "rules_jvm_external", version = "${RULES_JVM_EXTERNAL_VERSION}")

maven = use_extension("@rules_jvm_external//:extensions.bzl", "maven")
maven.install(
    name = "rules_detekt_dependencies",
    artifacts = ["${DETEKT_FORMATTING_ARTIFACT}"],
)
use_repo(maven, "rules_detekt_dependencies")
EOF

  cat > .bazelrc <<EOF
common --noenable_workspace
common --enable_bzlmod
EOF
}

# Generate a fresh per-strategy Kotlin file so the inner Bazel cannot serve
# the prior strategy's action from cache. Mirrors the cache-busting trick used
# by the previous suite.sh.
function generate_cache_buster_source() {
  local label="$1"
  local gen_dir="src/main/kotlin/generated"
  rm -rf "${gen_dir}"
  mkdir -p "${gen_dir}"
  echo '@file:Suppress("EmptyKtFile")' > "${gen_dir}/${label}.kt"
}

# Emit a BUILD file at the inner workspace root with a single detekt() target.
# Usage: write_build <target_name> <extra-attr-lines>
#
# extra-attr-lines is the literal text inserted into the rule body (e.g.
# `html_report = True,` or `cfgs = ["detekt_config_lenient.yml"],`). It may be
# empty.
function write_build() {
  local target="$1"
  local extra="$2"

  cat > BUILD <<EOF
load("@rules_detekt//detekt:defs.bzl", "detekt")

filegroup(
    name = "detekt_config_lenient",
    srcs = ["detekt_config_lenient.yml"],
)

detekt(
    name = "${target}",
    srcs = glob(["src/main/kotlin/**/*.kt"]),
    ${extra}
)
EOF
}

# Run an inner bazel build that is expected to succeed.
# Usage: bazel_build <target> [extra bazel flags...]
function bazel_build() {
  local target="$1"
  shift
  "${BIT_BAZEL_BINARY}" build "$@" -- "//:${target}" >& $TEST_log || \
    fail "Expected bazel build //:${target} to succeed"
}

# Run an inner bazel build that is expected to fail (detekt found issues).
# Usage: bazel_build_expect_failure <target> [extra bazel flags...]
function bazel_build_expect_failure() {
  local target="$1"
  shift
  "${BIT_BAZEL_BINARY}" build "$@" -- "//:${target}" >& $TEST_log && \
    fail "Expected bazel build //:${target} to fail" || true
}

# Path to the inner workspace's bazel-bin directory. Resolved lazily because
# bazel-bin only exists after the first inner build.
function inner_bazel_bin() {
  "${BIT_BAZEL_BINARY}" info bazel-bin 2>/dev/null
}

function expect_report_exists() {
  local target="$1"
  local extension="$2"
  local report
  report="$(inner_bazel_bin)/${target}_detekt_report.${extension}"
  test -f "${report}" || \
    fail "Expected report ${report} to exist"
}

function expect_report_absent() {
  local target="$1"
  local extension="$2"
  local report
  report="$(inner_bazel_bin)/${target}_detekt_report.${extension}"
  test ! -f "${report}" || \
    fail "Expected report ${report} to be absent"
}

# Run a callback once per Detekt execution strategy (local, worker), with the
# cache-buster source regenerated for each iteration so the inner Bazel must
# re-execute Detekt actions instead of reading them from cache.
#
# Usage: for_each_strategy <function_name>
# The callback receives a single argument: the strategy name.
function for_each_strategy() {
  local callback="$1"
  for strategy in local worker; do
    generate_cache_buster_source "${strategy}"
    "${callback}" "${strategy}"
  done
}
