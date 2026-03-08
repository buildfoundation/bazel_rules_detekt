"""Smoke tests for rules_detekt as an external dependency."""

load("@bazel_skylib//rules:diff_test.bzl", "diff_test")
load("@rules_detekt//detekt:defs.bzl", "detekt_test")

detekt_test(
    name = "detekt_happy_target",
    srcs = glob(["src/main/kotlin/**/*.kt"]),
    cfgs = ["detekt_config_lenient.yml"],
    tags = ["manual"],
)

detekt_test(
    name = "detekt_failing_target",
    srcs = glob(["src/main/kotlin/**/*.kt"]),
    tags = ["manual"],
)

genrule(
    name = "detekt_happy_exit_code_actual",
    testonly = 1,
    srcs = [":detekt_happy_target"],
    outs = ["detekt_happy_exit_code.actual"],
    cmd = """
set -e
for f in $(SRCS); do
  case "$$f" in
    *_exit_code.txt)
      cp "$$f" "$@"
      exit 0
      ;;
  esac
done
echo "Could not locate Detekt exit code output for detekt_happy_target" >&2
exit 1
""",
    cmd_bat = """
@echo off
setlocal EnableExtensions EnableDelayedExpansion
for %%f in ($(SRCS)) do (
  echo %%~nxf | findstr /R "_exit_code.txt$" >nul
  if !ERRORLEVEL! EQU 0 (
    copy /Y "%%f" "%OUTS%" >nul
    exit /b 0
  )
)
echo Could not locate Detekt exit code output for detekt_happy_target 1>&2
exit /b 1
""",
)

genrule(
    name = "detekt_failure_exit_code_actual",
    testonly = 1,
    srcs = [":detekt_failing_target"],
    outs = ["detekt_failure_exit_code.actual"],
    cmd = """
set -e
for f in $(SRCS); do
  case "$$f" in
    *_exit_code.txt)
      cp "$$f" "$@"
      exit 0
      ;;
  esac
done
echo "Could not locate Detekt exit code output for detekt_failing_target" >&2
exit 1
""",
    cmd_bat = """
@echo off
setlocal EnableExtensions EnableDelayedExpansion
for %%f in ($(SRCS)) do (
  echo %%~nxf | findstr /R "_exit_code.txt$" >nul
  if !ERRORLEVEL! EQU 0 (
    copy /Y "%%f" "%OUTS%" >nul
    exit /b 0
  )
)
echo Could not locate Detekt exit code output for detekt_failing_target 1>&2
exit /b 1
""",
)

diff_test(
    name = "detekt_happy_path_test",
    file1 = ":detekt_happy_exit_code_actual",
    file2 = "expected_happy_exit_code.txt",
)

diff_test(
    name = "detekt_failure_path_test",
    file1 = ":detekt_failure_exit_code_actual",
    file2 = "expected_failure_exit_code.txt",
)
