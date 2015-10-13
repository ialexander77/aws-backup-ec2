# AWS bash scripts for creation of EC2 snapshots of all attached volumes

===========================
Description and Requirement
===========================

This script will create EC2 snapshots of all attached volumes without rebooting the source instance.

    The script must be executed with the following mandatory parameters:
    
    -t -- backup type allowed values are: *daily, weekly, monthly*
    -l -- how many snaphots to keep *number*
    -r -- region name of the ec2 instances: *us-east-1, us-west-1, us-west-2 and etc.*
    -s -- search tag eg. *tag:Backup=true*

All EC2 instance must have a tag value Backup=true. This tag can be applied in AWS console or through the CLI tools.

=============
Usage example
=============

For example, if run the script with the following parameters:

    ./aws-backup.sh -t weekly -l 2 -r us-east-1 -s tag:Backup=true

Script will create a snapshot of all volumes attached to all instances which have a tag Backup=true in a defined region. All snapshot will have the similar naming: 

    Automated backup :: weekly :: i-xxxxxxxx :: vol-xxxxxxxx :: 201509241646

Script will check the numbers of existing snapshots and if number exceed value specified in '-l' it will automatically delete oldest snapshots. 

=================
Cron job examples
=================

Daily (each day at midnight, keep 7 snapshots or one week in total)

    0  0  *  *  *  /path/aws-backup.sh -t daily -l 7 -r us-east-1 -s tag:Backup=true

Weekly (each Saturday at 1 AM, keep 4 snapshots or one month in total)

    0  1  *  *  6  /path/aws-backup.sh -t weekly -l 4 -r us-east-1 -s tag:Backup=true

Monthly (each 15th of each month at 2 AM, keep 12 snapshots or 1 year in total)

    0  2  15  *  *  /path/aws-backup.sh -t monthly -l 12 -r us-east-1 -s tag:Backup=true


A few cron jobs (for example for opposite region) can be executed simultaneously.
