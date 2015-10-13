#!/usr/bin/env bash

# ---------------------------------------------------------------------------------
# AWS EC2 Backup Script
# Version:  1.5
# Developed by: http://aximcloud.com (aivanov@aximcloud.com)
# 
# Description:
# Script searching all instances with defined Tag Name and creates snapshots
# of all attached volumes. All snapshots will get similar name:
# "Automated backup :: backup_type :: instance_id :: :: volume_id :: serial number 
# ---------------------------------------------------------------------------------

    #Include

. $(dirname $0)/aws-lib.sh
. $(dirname $0)/.config

while getopts ":t:l:r:s:" opt; do
    case $opt in
        t)
            snapshot_type=$OPTARG
            ;;
        l)
            backup_level=$OPTARG
            ;;
        r)
            ec2_region=$OPTARG
            ;;
        s)
            search_tag=$OPTARG
            ;;

        :)
            echo "error: option -$OPTARG requires an argument" >&2
            usage
            ;;
        \?)
            echo "error: invalid option -$OPTARG" >&2
            usage
            ;;
    esac
done

if [ $# -eq 0 ]; then
    usage
fi

cur_date=$(date +%Y%m%d%H%M)

    # Begin

instance_id=( $(aws-lib_instance_get_id $ec2_region $search_tag) )

for (( i=0; i<${#instance_id[*]}; i++ ))
{
    serial=$cur_date

    echo -e "\n  Instance ID: ${instance_id[$i]}"

    keep_snapshots=$backup_level

    volume_id=( $(aws-lib_volume_get_id $ec2_region ${instance_id[$i]}) )

    echo -e "  Attached volumes: ${#volume_id[*]}"

    echo -e "  Keep Snapshots: $keep_snapshots"

    for (( j=0; j<${#volume_id[*]}; j++ ))
    {
        echo -e "\n    Volume ID: ${volume_id[$j]}"

        aws-lib_snapshot_create $ec2_region $snapshot_type ${instance_id[$i]} ${volume_id[$j]} $serial

        aws-lib_snapshot_create_wait $ec2_region $serial

        snapshot_id_list=( $(aws-lib_snapshot_get_id $ec2_region $snapshot_type ${instance_id[$i]} ${volume_id[$j]}) )

        echo -e "    Backup snapshots: ${#snapshot_id_list[*]}\n"

        while [ ${#snapshot_id_list[*]} -gt $keep_snapshots ]; do

            echo -e "      - deleting backup snapshot ${snapshot_id_list[0]}"

            aws-lib_snapshot_delete $ec2_region ${snapshot_id_list[0]}

            snapshot_id_list=( $(aws-lib_snapshot_get_id $ec2_region $snapshot_type ${instance_id[$i]} ${volume_id[$j]}) )

        done
    }
}
