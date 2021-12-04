#!/bin/bash

# Remotes: 
#   encrypted:  offsite:/mnt/hdd/
#   offsite:    
# --bwlimit "08:00,300 22:00,off" The transfer bandwidth will be every day set to 375kBytes/sec (3Mbps) at 8am. Anything between 11pm and 7am will remain unlimited.

UNRAID_PATH=/mnt/user/backup            # Path to unraid which is the root backup 
BACKUP_PATH=$UNRAID_PATH/AppData   # Full path to be backed up

# APPDATA 

# Clean up temp extracted files. 
rm -rf $BACKUP_PATH/tmp/

# Check if script is running
FLAG="$UNRAID_PATH/logs/rclone.flag"

# Cleanup flag.
if [ -f $FLAG ]; then
    rm $FLAG
fi