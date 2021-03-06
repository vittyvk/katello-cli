#!/bin/bash
# Helpers for common steps in cli system tests

KATELLO_URL=${KATELLO_URL:-"http://localhost:3000/katello/api/"}
PULP_URL=${PULP_URL:-"https://$SERVICES_HOST/pulp/api/"}
CP_URL=${CP_URL:-"https://$SERVICES_HOST:8443/candlepin/"}

function nospace(){
  echo "$@" | sed 's/ /_/g'
}

function get_repo_id() {
    echo `$CMD repo list --org="$TEST_ORG" -g | grep "$FEWUPS_REPO" | awk '{print $1}'`
}

function get_pulp_repo_id() {
    echo `curl -k -s -u admin:admin -H "Content-Type: application/json" -H "Accept: application/json" \
    $KATELLO_URL/repositories/$REPO_ID/ | json_reformat | grep "pulp_id" | awk '{print $2}' | sed -e 's/[,"]//g'`
}

function get_repo_name() {
    echo `$CMD repo list --org="$TEST_ORG" -g -d "##" | grep "$FEWUPS_REPO" | awk -F '##' '{print $2}'`
}

function valid_id() {
    if [ -z "$1" ]; then
        return 0
    fi

    #id=`echo $1 | egrep '\+-+\+'`
    id=`echo $1 | egrep '\-{5,}'`
    if [ -z "$id" ]; then
        return 0
    else
        return 1
    fi
}

function jobs_running() {
    jobs_rake=`ps aux | grep -v grep | grep "rake jobs:work" > /dev/null; echo $?`
    jobs_service=`service katello-jobs status &> /dev/null; echo $?`

    if [ "$jobs_rake" == "0" ] || [ "$jobs_service" == "0" ]; then
        return 0
    else
        return 1
    fi
}

function check_delayed_jobs_running() {
    if ! jobs_running; then
        printf "${txtred}Warning: Jobs daemon is not running, the promotion will hang!${txtrst}\n"
        printf "${txtred}Run 'service katello-jobs start' or 'rake jobs:work' to proceed.${txtrst}\n"
    fi
}
