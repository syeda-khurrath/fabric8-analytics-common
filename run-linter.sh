#!/bin/bash

directories="integration-tests ui-tests perf-tests dashboard reproducers load-tests db-integrity-tests taas job-checker baf e2e_tests_bot vscode-visual-tests"
pass=0
fail=0

function prepare_venv() {
    VIRTUALENV=$(which virtualenv)
    if [ $? -eq 1 ]; then
        # python36 which is in CentOS does not have virtualenv binary
        VIRTUALENV=$(which virtualenv-3)
    fi
    if [ $? -eq 1 ]; then
        # still don't have virtual environment -> use python3.6 directly
        python3.6 -m venv venv && source venv/bin/activate && python3 "$(which pip3)" install pycodestyle
    else
        ${VIRTUALENV} -p python3 venv && source venv/bin/activate && python3 "$(which pip3)" install pycodestyle
    fi
}

echo "----------------------------------------------------"
echo "Running Python linter against following directories:"
echo "$directories"
echo "----------------------------------------------------"
echo

[ "$NOVENV" == "1" ] || prepare_venv || exit 1

# checks for the whole directories
for directory in $directories
do
    files=$(find "$directory" -path "$directory/venv" -prune -o -name '*.py' -print)

    for source in $files
    do
        echo "$source"
        pycodestyle "$source"
        if [ $? -eq 0 ]
        then
            echo "    Pass"
            let "pass++"
        else
            echo "    Fail"
            let "fail++"
        fi
    done
done


if [ $fail -eq 0 ]
then
    echo "All checks passed for $pass source files"
else
    let total=$pass+$fail
    echo "Linter fail, $fail source files out of $total source files need to be fixed"
    exit 1
fi
