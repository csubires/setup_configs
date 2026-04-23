#!/usr/bin/env bash
# 2023/03/09

# xhost +
# xhost si:localuser:root
ps -eo "user,group,args" | grep firefox
sg internet -c firefox > /dev/null 2>&1 &
ps -eo "user,group,args" | grep firefox
# xhost -si:localuser:root
read -p "Press [Enter] key to continue..."
