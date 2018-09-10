#!/bin/bash
#
# Compiles the project and updates the dashboard with the number of
# compilation warnings (or sets it to "failed" if there are errors).
#

BIN_DIR=`dirname "$(readlink -f "$0")"`

output_name="$BIN_DIR/../compile-output-${PROJECT_NAME}.txt"
set -o pipefail
rebar3 compile | tee $output_name
if [ $? -ne 0 ]; then
    echo "Build failed!"
    $BIN_DIR/history_update_dashboard.sh build failed
    $BIN_DIR/history_update_dashboard.sh dialyzer failed
    $BIN_DIR/history_update_dashboard.sh eunit failed
    $BIN_DIR/history_update_dashboard.sh common_test failed
    exit 1
fi
set +o pipefail

warnings_number=`grep ':[0-9]*: Warning' $output_name | wc -l`
$BIN_DIR/history_update_dashboard.sh build success "$warnings_number"
exit 0

