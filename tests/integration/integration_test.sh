#!/bin/bash
#
# Integration tests for rules_detekt. Each test function builds a detekt()
# target inside an isolated inner Bazel workspace (driven by ${BIT_BAZEL_BINARY}
# from rules_bazel_integration_test) and asserts on the generated reports.
# Tests are executed twice — once with the "local" Detekt strategy and once
# with the "worker" strategy — to cover both execution paths.

# --- begin runfiles.bash initialization v2 ---
set -uo pipefail; f=bazel_tools/tools/bash/runfiles/runfiles.bash
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
  source "$0.runfiles/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  { echo>&2 "ERROR: cannot find $f"; exit 1; }; f=; set -e
# --- end runfiles.bash initialization v2 ---

# The main repo's runfiles apparent name under bzlmod is the MODULE.bazel
# repo_name = "bazel_rules_detekt". rlocation returns 1 when a path is
# unresolvable, which would kill the script under set -e.
_helper="$(rlocation bazel_rules_detekt/tests/integration/integration_helper.sh 2>/dev/null || true)"
if [[ -z "${_helper}" ]]; then
  echo >&2 "Failed to locate integration_helper.sh"
  exit 1
fi
source "${_helper}"
unset _helper

function set_up() {
  set_up_workspace

  mkdir -p src/main/kotlin/io/buildfoundation/bazel/detekt

  cat > src/main/kotlin/io/buildfoundation/bazel/detekt/main.kt <<'EOF'
package bazel.detekt

fun main(args: Array<String>) {

}
EOF

  cat > src/main/kotlin/io/buildfoundation/bazel/detekt/A.kt <<'EOF'
package bazel.detekt

class A
EOF

  cat > src/main/kotlin/io/buildfoundation/bazel/detekt/B.kt <<'EOF'
package bazel.detekt

class B
EOF

  cat > src/main/kotlin/io/buildfoundation/bazel/detekt/C.kt <<'EOF'
package bazel.detekt

class C
EOF

  cat > detekt_baseline.xml <<'EOF'
<?xml version="1.0" ?>
<SmellBaseline>
  <Whitelist>
    <ID>EmptyFunctionBlock:main.kt${ }</ID>
  </Whitelist>
</SmellBaseline>
EOF

  cat > detekt_config_lenient.yml <<'EOF'
build:
  maxIssues: 10
EOF
}

# Target without config should fail and generate a text report.
function test_report_text() {
  local target="detekt_without_config"
  write_build "${target}" ""

  _test_report_text_one_strategy() {
    local strategy="$1"
    bazel_build_expect_failure "${target}" "--strategy=Detekt=${strategy}"
    expect_report_absent "${target}" html
    expect_report_exists "${target}" txt
    expect_report_absent "${target}" xml
  }
  for_each_strategy _test_report_text_one_strategy
}

# html_report = True should emit both text and HTML reports.
function test_report_html() {
  local target="detekt_without_config_with_report_html"
  write_build "${target}" "html_report = True,"

  _test_report_html_one_strategy() {
    local strategy="$1"
    bazel_build_expect_failure "${target}" "--strategy=Detekt=${strategy}"
    expect_report_exists "${target}" html
    expect_report_exists "${target}" txt
    expect_report_absent "${target}" xml
  }
  for_each_strategy _test_report_html_one_strategy
}

# xml_report = True should emit both text and XML reports.
function test_report_xml() {
  local target="detekt_without_config_with_report_xml"
  write_build "${target}" "xml_report = True,"

  _test_report_xml_one_strategy() {
    local strategy="$1"
    bazel_build_expect_failure "${target}" "--strategy=Detekt=${strategy}"
    expect_report_absent "${target}" html
    expect_report_exists "${target}" txt
    expect_report_exists "${target}" xml
  }
  for_each_strategy _test_report_xml_one_strategy
}

# Baseline alone should suppress all issues and the build should succeed.
function test_baseline() {
  local target="detekt_without_config_with_baseline"
  write_build "${target}" 'baseline = "detekt_baseline.xml",'

  _test_baseline_one_strategy() {
    local strategy="$1"
    bazel_build "${target}" "--strategy=Detekt=${strategy}"
    expect_report_absent "${target}" html
    expect_report_exists "${target}" txt
    expect_report_absent "${target}" xml
  }
  for_each_strategy _test_baseline_one_strategy
}

# Baseline combined with the formatting plugin should still surface new issues
# the plugin adds, causing the build to fail.
function test_baseline_with_plugin() {
  local target="detekt_without_config_with_baseline_with_plugin"
  write_build "${target}" \
'baseline = "detekt_baseline.xml",
    plugins = ["@rules_detekt_dependencies//:io_gitlab_arturbosch_detekt_detekt_formatting"],'

  _test_baseline_plugin_one_strategy() {
    local strategy="$1"
    bazel_build_expect_failure "${target}" "--strategy=Detekt=${strategy}"
    expect_report_absent "${target}" html
    expect_report_exists "${target}" txt
    expect_report_absent "${target}" xml
  }
  for_each_strategy _test_baseline_plugin_one_strategy
}

# Lenient config file should let the build pass.
function test_config_file_lenient() {
  local target="detekt_with_config_file_lenient"
  write_build "${target}" 'cfgs = ["detekt_config_lenient.yml"],'

  _test_config_file_lenient_one_strategy() {
    local strategy="$1"
    bazel_build "${target}" "--strategy=Detekt=${strategy}"
    expect_report_absent "${target}" html
    expect_report_exists "${target}" txt
    expect_report_absent "${target}" xml
  }
  for_each_strategy _test_config_file_lenient_one_strategy
}

# Config provided via a filegroup label should be treated the same as a direct
# file reference.
function test_config_filegroup_lenient() {
  local target="detekt_with_config_filegroup_lenient"
  write_build "${target}" 'cfgs = ["//:detekt_config_lenient"],'

  _test_config_filegroup_lenient_one_strategy() {
    local strategy="$1"
    bazel_build "${target}" "--strategy=Detekt=${strategy}"
    expect_report_absent "${target}" html
    expect_report_exists "${target}" txt
    expect_report_absent "${target}" xml
  }
  for_each_strategy _test_config_filegroup_lenient_one_strategy
}

run_suite "rules_detekt integration tests"
