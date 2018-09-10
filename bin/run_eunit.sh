#!/bin/bash

#
# Runs EUnit tests from the project and updates the dashboard with the
# number of failed testcases.
#

BIN_DIR=`dirname "$(readlink -f "$0")"`

output_name="$BIN_DIR/../eunit-output-${PROJECT_NAME}.txt"
(bin/kill_test_nodes.sh || true) &> /dev/null
if rebar3 eunit --sname ctnode$$ --cover | tee ${output_name} ; then
    x_total=`grep "[0-9]* tests, [0-9]* failures" ${output_name} | perl -nle 'm/(\d+) tests, (\d+) failures/; print $1;'`
    x_failed=`grep "[0-9]* tests, [0-9]* failures" ${output_name} | perl -nle 'm/(\d+) tests, (\d+) failures/; print $2;'`

    $BIN_DIR/history_update_dashboard.sh eunit "$x_failed" "$x_total"
    return_value=$x_failed
else
    $BIN_DIR/history_update_dashboard.sh eunit failed
    echo "Test failed!"
    return_value=1
fi

exit ${return_value}
