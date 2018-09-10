#!/usr/bin/env bash

#
# Updates the dashboard with the current dialyzer,build,etc. results
# Param $1: Name of column (dialyzer, build, eunit, common_test or coverage)
# Param $2: Number of dialyzer warnings; fail/success; number of failed tests; % of code covered
# Param $3: If $1 is common_test or eunit, number of all tests. If $1 is build, the number of warnings
# Param $4: If $1 is common_test, the number of skipped tests.
#

if [ "$TRAVIS_BRANCH" != "master" ]; then
    echo "Not updating dashboard for $TRAVIS_BRANCH branch!"
    exit 0
fi

BIN_DIR=`dirname "$(readlink -f "$0")"`

dashboard_filename="$BIN_DIR/../README.md"

if [ ! -f ${dashboard_filename} ] ; then
    echo "No README.md, bail out"
    exit 1
fi

if [ "$#" -lt 2 -o "$#" -gt 4 ]; then
    echo "Invalid number of parameters"
    exit 1
fi

HISTORY_URL=https://github.com/NAR/dashboard/blob/master

case $1 in
    ("dialyzer")
        warnings="$2"
        if [ "$2" == "failed" ]; then
            text="failed"
            color="red"
        else
            if [ "$warnings" -eq 0 ]; then
                color="green"
            else
                color="yellow"
            fi
            text="$warnings warnings"
        fi
        url_text=`echo $text | sed 's/ /%20/g'`
        dialyzer_log_url="$HISTORY_URL/dialyzer-output-$PROJECT_NAME.txt"
        cell="[\![$text](https://img.shields.io/badge/dialyzer-$url_text-$color.svg)]($dialyzer_log_url)"
        sed -i "/$PROJECT_NAME/s,\(|[^|]*|\)[^|]*|,\1 $cell |," $dashboard_filename
        ;;
    ("build")
        if [ "$2" == "failed" ]; then
            color="red"
            text="failed"
        else
            if [ "$3" -eq 0 ]; then
                color="green"
                text="success"
            else
                color="yellow"
                text="$3 warnings"
            fi
        fi
        url_text=`echo $text | sed 's/ /%20/g'`
        build_log_url="$HISTORY_URL/compile-output-$PROJECT_NAME.txt"
        cell="[\![$text](https://img.shields.io/badge/build-$url_text-$color.svg)]($build_log_url)"
        sed -i "/$PROJECT_NAME/s,\(|[^|]*|[^|]*|\)[^|]*|,\1 $cell |," $dashboard_filename
        ;;
    ("eunit")
        if [ "$2" == "failed" ]; then
            text="failed"
            color="red"
        else
            if [ -z "$3" ]; then
                echo "No total number of tests!"
                exit 1
            fi
            if [ "$2" -eq 0 ]; then
                color="green"
                text="All $3 tests passed"
	    else
                color="red"
                text="$2 tests failed out of $3"
            fi
        fi
        url_text=`echo $text | sed 's/ /%20/g'`
        eunit_log_url="$HISTORY_URL/eunit-output-$PROJECT_NAME.txt"
        cell="[\![$text](https://img.shields.io/badge/eunit-$url_text-$color.svg)]($eunit_log_url)"
        sed -i "/$PROJECT_NAME/s,\(|[^|]*|[^|]*|[^|]*|\)[^|]*|,\1 $cell |," $dashboard_filename
        ;;
    ("common_test")
        if [ "$2" == "failed" ]; then
            text="build failed"
            color="red"
        else
            if [ -z "$3" ]; then
                echo "No total number of tests!"
                exit 1
            fi
            if [ -z "$4" ]; then
                echo "No skipped number of tests!"
                exit 1
            fi
            if [ "$2" -eq 0 ]; then # no failed tests
                if [ "$4" -eq 0 ]; then # no skipped either
                    color="green"
                    text="All $3 tests passed"
                else
                    color="orange"
                    text="$2 failed and $4 skipped out of $3"
                fi
            else # some failed tests
                color="red"
                if [ "$4" -eq 0 ]; then # no skipped tests
                    text="$2 failed out of $3"
                else
                    text="$2 failed and $4 skipped out of $3"
                fi
            fi
        fi
        url_text=`echo $text | sed 's/ /%20/g'`
        test_log_url="$HISTORY_URL/ct-output-$PROJECT_NAME.txt"
        cell="[\![$text](https://img.shields.io/badge/common_tests-$url_text-$color.svg)]($test_log_url)"
        sed -i "/$PROJECT_NAME/s,\(|[^|]*|[^|]*|[^|]*|[^|]*|\)[^|]*|,\1 $cell |," $dashboard_filename
        ;;
    ("coverage")
        if [ "$2" == "failed" ]; then
            text="build failed"
            color="red"
        else
            coverage="$2"
            if [ $coverage -lt 50 ]; then
                color="red"
            elif [ $coverage -lt 75 ]; then
                color="orange"
            elif [ $coverage -lt 90 ]; then
                color="yellow"
            else
                color="green"
            fi
            text="$coverage %"
        fi
        url_text=`echo $text | sed 's/%/%25/' | sed 's/ /%20/g'`
        cover_log_url="$HISTORY_URL/cover-output-$PROJECT_NAME.txt"
        cell="[\![$text](https://img.shields.io/badge/coverage-$url_text-$color.svg)]($cover_log_url)"
        sed -i "/$PROJECT_NAME/s,\(|[^|]*|[^|]*|[^|]*|[^|]*|[^|]*|[^|]*|\)[^|]*|,\1 $cell |," $dashboard_filename
        ;;
    (*)
        echo "Invalid first parameter: $1"
        exit 1
esac

date=`TZ=UTC date "+%F %H:%M:%S %Z"`
sed -i "/$PROJECT_NAME/s,\(|[^|]*|[^|]*|[^|]*|[^|]*|[^|]*|[^|]*|[^|]*|[^|]*|\)[^|]*|,\1 $date |," $dashboard_filename

