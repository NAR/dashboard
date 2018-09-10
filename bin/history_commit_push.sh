#!/usr/bin/env bash

#
# Commit and push changes to the history repository
#
# Assumption: Private key `updater.key` has been `ssh-add`-ed before running
# this script 
#
set -x
cd _build/test/lib/dashboard

git config --local user.email "attila.nohl@erlang-solutions.com"
git config --local user.name "Dashboard updater"
git config --global push.default simple

git fetch origin
git stash
git pull origin
git stash pop
git add *
git commit -m "Add job ${TRAVIS_JOB_ID} for ${PROJECT_NAME}"
git push origin master

cd -

