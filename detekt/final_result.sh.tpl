#!/bin/bash
set -euo pipefail
exit_code=$(cat {execution_result})
report=$(cat {text_report})
if [ ! -z "$report" ]; then
    echo "$report"
fi
{baseline_script}
exit "$exit_code"
