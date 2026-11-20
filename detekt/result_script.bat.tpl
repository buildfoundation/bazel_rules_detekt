@echo off
setlocal EnableExtensions DisableDelayedExpansion

if not defined RUNFILES_MANIFEST_FILE if defined TEST_SRCDIR if exist "%TEST_SRCDIR%\MANIFEST" set "RUNFILES_MANIFEST_FILE=%TEST_SRCDIR%\MANIFEST"
if not defined RUNFILES_MANIFEST_FILE if defined RUNFILES_DIR if exist "%RUNFILES_DIR%_manifest" set "RUNFILES_MANIFEST_FILE=%RUNFILES_DIR%_manifest"
if not defined RUNFILES_MANIFEST_FILE if defined RUNFILES_DIR if exist "%RUNFILES_DIR%\MANIFEST" set "RUNFILES_MANIFEST_FILE=%RUNFILES_DIR%\MANIFEST"
if not defined RUNFILES_MANIFEST_FILE if exist "%~f0.runfiles_manifest" set "RUNFILES_MANIFEST_FILE=%~f0.runfiles_manifest"
if not defined RUNFILES_MANIFEST_FILE if exist "%~f0.runfiles\MANIFEST" set "RUNFILES_MANIFEST_FILE=%~f0.runfiles\MANIFEST"
if defined RUNFILES_DIR set "RUNFILES_DIR=%RUNFILES_DIR:/=\%"
if defined RUNFILES_MANIFEST_FILE set "RUNFILES_MANIFEST_FILE=%RUNFILES_MANIFEST_FILE:/=\%"

set "execution_result="
call :rlocation "{execution_result}" execution_result
if defined execution_result set "execution_result=%execution_result:/=\%"
if not defined execution_result (
    echo Unable to locate Detekt execution result 1>&2
    exit /b 1
)

set "text_report="
call :rlocation "{text_report}" text_report
if defined text_report set "text_report=%text_report:/=\%"
if defined text_report if exist "%text_report%" type "%text_report%"

{baseline_file_lookup}
set "exit_code="
set /p "exit_code="<"%execution_result%"
if not defined exit_code set "exit_code=1"
{baseline_script}
exit /b %exit_code%

:rlocation
set "%~2="
if defined RUNFILES_DIR if exist "%RUNFILES_DIR%\%~1" set "%~2=%RUNFILES_DIR%\%~1"
set "manifest_runfile_path=%~1"
set "manifest_runfile_path=%manifest_runfile_path:\=\b%"
set "manifest_runfile_path=%manifest_runfile_path: =\s%"
if defined RUNFILES_MANIFEST_FILE if exist "%RUNFILES_MANIFEST_FILE%" if not defined %~2 (
    for /f "usebackq tokens=1,* delims= " %%A in ("%RUNFILES_MANIFEST_FILE%") do if "%%A"=="%manifest_runfile_path%" set "%~2=%%B"
)
exit /b 0
