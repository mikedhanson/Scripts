#!/bin/bash
#----------------------------------------------------------------------------

mkdir -p /mnt/disks/offsite_files
mkdir -p /mnt/disks/encrypted_files

rclone mount --max-read-ahead 1024k --allow-other offsite:/mnt/hdd/rclone/files/ /mnt/disks/offsite_files &
rclone mount --max-read-ahead 1024k --allow-other offsite:/mnt/hdd/rclone/encrypted/ /mnt/disks/encrypted_files &
