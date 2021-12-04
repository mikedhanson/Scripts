#!/bin/bash


SECONDS=0
BACKUP_NAME="AppData"                   # Folder under UNRAID_PATH which will be backed up
UNRAID_PATH=/mnt/user/backup            # Path to unraid which is the root backup 
BACKUP_PATH=$UNRAID_PATH/$BACKUP_NAME   # Full path to be backed up
LOGFILE=$UNRAID_PATH/logs/rclone-$BACKUP_NAME-$(date +"%Y-%m-%d").log 
callNotify=/usr/local/emhttp/webGui/scripts/notify
LOG_LEVEL='INFO'
RCLONE_REMOTE='encrypted'

TEMP_DIR=$BACKUP_PATH/tmp/

#-t orders by time -d - directories folder */ only lists directories 
LAST_MODIFIED=$(ls -td $BACKUP_PATH/*/* | head -1)

# Check if script is running
FLAG="$UNRAID_PATH/logs/rclone.flag"

if [ -f $FLAG ]; then
    echo "$(date "+%d.%m.%Y %T") INFO: Exiting script as already running."
    CURRENTLY_RUNNING=$(cut -d "-" -f2- <<< $(echo $(cat $FLAG)))
    $callNotify -i "warning" -s "Rclone - [$BACKUP_NAME] Attempted to run" -d "[$CURRENTLY_RUNNING] is already running. $(echo $(cat $FLAG))" 
    exit

else
    # Script not running, extract files and start transfer. 
    # if $TEMP_DIR doesnt exist create it. 
    if [ ! -d "$TEMP_DIR" ]; then
        mkdir $TEMP_DIR
    fi


    tar -xf $LAST_MODIFIED -C $TEMP_DIR --exclude="PlexMediaServer"
    EXTRACTED_SIZE=$( du -sh --apparent-size $TEMP_DIR | cut -f1 )

    echo "$(date "+%d.%m.%Y %T") INFO: Script not running - proceeding."
    echo "$(date "+%d.%m.%Y %T")-$BACKUP_NAME" >> $FLAG
    $callNotify -i "normal" -s "rclone: [$BACKUP_NAME] backup started" -d "Backing up [$EXTRACTED_SIZE]"
fi

rclone sync $TEMP_DIR $RCLONE_REMOTE:/$BACKUP_NAME --bwlimit "08:00,250 22:00,off" --log-level $LOG_LEVEL --log-file=$LOGFILE  --progress #--progress #--dry-run
#rclone sync $TEMP_DIR /tmp/test/ --log-level $LOG_LEVEL --log-file=$LOGFILE  #--dry-run

# Cleanup flag.
if [ -f $FLAG ]; then
    rm $FLAG
fi

DETAILS=$(echo $(cat $LOGFILE | tail -4))
REMOTE_SIZE=$(echo $(rclone size $RCLONE_REMOTE:/$BACKUP_NAME) | cut -d':' -f 3)

ELAPSED="Execution Time: $(($SECONDS / 3600)) hrs $((($SECONDS / 60) % 60)) min $(($SECONDS % 60)) sec"

# Send notification 
if [ $? = 0 ] ; then
    # Clean up temp extracted files. 
    #rm -rf $BACKUP_PATH/tmp/
    $callNotify -i "normal" -s "rclone: [$BACKUP_NAME] backup Completed!" -d "Details: [$DETAILS] | Remote Size: [$REMOTE_SIZE] | Full log here: [$LOGFILE] "
else 
    $callNotify -i "alert" -s "rclone: [$BACKUP_NAME] backup Failed! :("  -d "Details: [$DETAILS] | Full log here: [$LOGFILE]"
fi