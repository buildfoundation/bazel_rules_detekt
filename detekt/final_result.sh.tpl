#!/bin/bash
set -euo pipefail
exit_code="$(<"{execution_result}")"
if [ -s "{text_report}" ]; then
    cat "{text_report}"
fi
{baseline_script}
exit "$exit_code"
