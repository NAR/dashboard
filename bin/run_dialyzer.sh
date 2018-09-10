#!/usr/bin/env bash
#
# Runs dialyzer on the project and updates the dashboard with the number of
# compilation warnings (or sets it to "failed" if dialyzer crashes).
#

BIN_DIR=`dirname "$(readlink -f "$0")"`

output_name="$BIN_DIR/../dialyzer-output-${PROJECT_NAME}.txt"
set -o pipefail
if rebar3 as test dialyzer | tee ${output_name} ; then
    x_warn=`tail -n 5 ${output_name} | awk '/Warnings occurred/ {print $NF}'`
    if [ -z "$x_warn" ]; then
      x_warn=0
    fi
    echo "Dialyzer finished. warnings: ${x_warn}"

    $BIN_DIR/history_update_dashboard.sh dialyzer ${x_warn}
    exit 0
#    exit ${x_warn}
else
    $BIN_DIR/history_update_dashboard.sh dialyzer failed
    exit 1
fi
