# Backup Schedule

## Items backed up 
* Appdata 
* Flash 
* Network 
* Veeam 

| Directory      | Local                | Offsite        |
| :---           | :----:               |   ---:         |   
| Appdata        | Weekly (sun 2am)     | Weekly         |
| Libvirt        | Weekly (sun 2am)     | Weekly         |
| Flash          | Weekly (sun 2am)     | Weekly         |
| Network        |                      | Weekly         |
| Veeam          | MWF                  | Weekly         |
| Manual          | MWF                  | Weekly         |


#
## Script Example


```bash
#!/bin/bash

BACKUP_NAME="backupDir"                   # Folder under UNRAID_PATH which will be backed up

UNRAID_PATH=/mnt/user/backup            # Path to unraid which is the root backup 
BACKUP_PATH=$UNRAID_PATH/$BACKUP_NAME   # Full path to be backed up
LOGFILE=$UNRAID_PATH/logs/rclone-$BACKUP_NAME-$(date +"%Y-%m-%d").log 
callNotify=/usr/local/emhttp/webGui/scripts/notify
LOG_LEVEL='INFO'
Rclone_Remote='encrypted'

# Check if script is running
#FLAG="$UNRAID_PATH/logs/$BACKUP_NAME-running"
FLAG="$UNRAID_PATH/logs/rclone.flag"

if [[ -f $FLAG ]]; then
    echo "$(date "+%d.%m.%Y %T") INFO: Exiting script as already running."
    CURRENTLY_RUNNING=$(cut -d "-" -f2- <<< $(echo $(cat $FLAG)))
    $callNotify -i "warning" -s "Rclone - $BACKUP_NAME Attempted to run" -d "$CURRENTLY_RUNNING is already running. $(echo $(cat $FLAG))" 
    exit
else
    echo "$(date "+%d.%m.%Y %T") INFO: Script not running - proceeding."
    echo "$(date "+%d.%m.%Y %T")-$BACKUP_NAME" >> $FLAG
fi

rclone sync $BACKUP_PATH $Rclone_Remote:/$BACKUP_NAME --bwlimit "08:00,250 22:00,off" --log-level $LOG_LEVEL --log-file=$LOGFILE #--progress #--dry-run

# Cleanup flag.
if [[ -f $FLAG ]]; then
    rm $FLAG
fi

DETAILS=$(echo $(cat $LOGFILE | tail -4))

# Send notification 
if [ $? = 0 ] ; then
    $callNotify -i "normal" -s "Rclone - $BACKUP_NAME backup Completed!" -d "Details: $DETAILS Full log can be found here: $LOGFILE" 
else 
    $callNotify -i "alert" -s "Rclone - $BACKUP_NAME backup Failed! :("  -d "Details: $DETAILS Full log can be found here: $LOGFILE" 
fi
```
