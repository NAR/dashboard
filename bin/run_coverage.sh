#!/bin/bash

#
# Generates the coverage report from the EUnit and common_test tests.
#

BIN_DIR=`dirname "$(readlink -f "$0")"`

output_name="$BIN_DIR/../cover-output-${PROJECT_NAME}.txt"
rebar3 cover --verbose | tee ${output_name}

actual_coverage=`perl -ne 'print $1 if (/\|\s+total\s+\|\s+(\d+)/);' $output_name`
if [ -z "$actual_coverage" ]; then
  actual_coverage=0
fi
echo "actual coverage: $actual_coverage"

$BIN_DIR/history_update_dashboard.sh coverage $actual_coverage

exit 0
