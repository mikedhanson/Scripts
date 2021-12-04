#!/bin/bash

callNotify=/usr/local/emhttp/webGui/scripts/notify
RCLONE_REMOTE='encrypted'

# returns number of files and size of remotes
view_remote_sizes () {
    DATA=()
    for remote in $(rclone listremotes)
    do  
        SIZE=$(rclone size $remote:)
        echo "$remote: ${SIZE:29:12}"
        #DATA+=$($value)
    done
    #echo $DATA
}

# Get Directories in REMOTE 
#$REMOTE_PATHS=$(echo "$(rclone lsd $RCLONE_REMOTE:)")

# size 
#REMOTE_SIZE=$(rclone about $RCLONE_REMOTE:)
#echo $REMOTE_SIZE

# view individual items in RCLONE_REMOTE
view_inner_remote_sizes (){
    IFS='::'
    items=$(echo $(rclone lsd $RCLONE_REMOTE:) | tr -d '0-9- ') 

    SAVEIFS=$IFS   # Save current IFS
    IFS=$'\n'      # Change IFS to new line
    array=($items)   # split to array $items
    IFS=$SAVEIFS   # Restore IFS

    for (( i=0; i<${#array[@]}; i++ ))
    do
        #echo "$i: ${array[$i]}"    
        SIZE=$(rclone size $RCLONE_REMOTE:${array[$i]})
        echo "${array[$i]}: ${SIZE:29:12}"
    done
}

view_remote_sizes
view_inner_remote_sizes

# View contents in #RCLONE_REMOTE

# Send notification 
if [ $? = 0 ] ; then
    $callNotify -i "normal" -s "Rclone Health Check" -d "$DATA"
else 
    $callNotify -i "alert" -s "Rclone Health Check Failed" -d "Reason: $?"
fi