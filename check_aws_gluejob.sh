#!/bin/bash

# check_gluejob.sh version 1.0
# usage:  ./check_gluejob.sh jobname
# Nagios check to check aws glue job status.
# requires aws-cli and access to check the glue service
# run run status based on these statuses https://docs.aws.amazon.com/glue/latest/dg/job-run-statuses.html

if [[ -z "$1" ]]; then
    echo "Missing Parameters! Syntax: $0 jobname"
        exit 3
fi

#define variables
jobname=$1
checkjob=$(aws glue get-job-runs --job-name $jobname --max-items 1 | grep JobRunState | sed 's/"//g' | sed 's/,//g' | awk 'NF{ print $NF }')
date=$(date)

# run logic
if [ "$checkjob" = "FAILED" ] || [ "$checkjob" = "ERROR" ] || [ "$checkjob" = "TIMEOUT" ]; then
    echo "CRITICAL - $jobname Job is in $checkjob status"
    exit 1
elif [ "$checkjob" = "WAITING" ]; then
    echo "WARNING - $jobname Job is in $checkjob status"
    exit 2
elif [ "$checkjob" = "STARTING" ] || [ "$checkjob" = "RUNNING" ] || [ "$checkjob" = "STOPPING" ] || [ "$checkjob" = "STOPPED" ] || [ "$checkjob" = "SUCCEEDED" ]; then
    echo "OK -  $jobname Job is in $checkjob status"
    exit 0
else
    echo "UNKNOWN $checkjob"
    exit 3
fi
