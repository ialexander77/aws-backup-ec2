#!/usr/bin/env bash

export aws_path
export ec2_home
export java_home
export PATH

# Instance operations

function aws-lib_instance_get_id
{
    if [ $# -ne 2 ] || [ "x$1" == 'x' ] || [ "x$2" == 'x' ]; then
        echo "Error: $funcname -- Invalid input" >&2
        exit 1
    fi

    ec2-describe-instances $ec2_auth --region $1 --filter $2 | grep INSTANCE | cut -f 2
}

#Volumes operations

function aws-lib_volume_get_id
{
    if [ $# -ne 2 ] || [ "x$1" == 'x' ] || [ "x$2" == 'x' ]; then
        echo "Error: $funcname -- Invalid input" >&2
        exit 1
    fi

    ec2-describe-volumes $ec2_auth --region $1 | grep $2 | sort -k 6 | cut -f 2
}

#Snapshot operations

function aws-lib_snapshot_get_id
{
    if [ $# -ne 4 ] || [ "x$1" == 'x' ] || [ "x$2" == 'x' ] || [ "x$3" == 'x' ] || [ "x$4" == 'x' ]; then
        echo "Error: $funcname -- Invalid input" >&2
        exit 1
    fi

    ec2-describe-snapshots $ec2_auth --region $1 | grep "Automated backup :: $2 :: $3" | sort -k 5 | grep $4 | cut -f 2
}

function aws-lib_snapshot_create
{
    if [ $# -ne 5 ] || [ "x$1" == 'x' ] || [ "x$2" == 'x' ] || [ "x$3" == 'x' ] || [ "x$4" == 'x' ] || [ "x$5" == 'x' ]; then
        echo "Error: $funcname -- Invalid input" >&2
        exit 1
    fi

    ec2-create-snapshot $ec2_auth --region $1 --description "Automated backup :: $2 :: $3 :: $4 :: $5" $4 >/dev/null 2>&1
}

function aws-lib_snapshot_create_wait
{
    if [ $# -ne 2 ] || [ "x$1" == 'x' ] || [ "x$2" == 'x' ]; then
        echo "Error: $funcname -- Invalid input" >&2
        exit 1
    fi

    while true; do
        local status=$(ec2-describe-snapshots $ec2_auth --region "$1" | grep "$2" | cut -f 4 | awk 'NR == 1')
        sleep 5
    if [ "$status" == "completed" ]; then
       break
    fi
    done
}

function aws-lib_snapshot_delete
{
    if [ $# -ne 2 ] || [ "x$1" == 'x' ] || [ "x$2" == 'x' ]; then
        echo "Error: $funcname -- Invalid input" >&2
        exit 1
    fi

    ec2-delete-snapshot $ec2_auth --region $1 $2 >/dev/null 2>&1
}

function usage
{
    echo -e "\nusage: aws-backup.sh -t daily/weekly/yearly -l level -r region -s 'search_tag'"
    echo -e ''
    echo -e 'mandatory:'
    echo -e '  -t -- backup type allowed values are: daily, weekly, monthly'
    echo -e '  -l -- how many snaphots to keep'
    echo -e '  -r -- region name of the ec2 instances'
    echo -e '  -s -- search tag eg. tag:Backup=true'
    echo -e ''
    
    exit 1
}

