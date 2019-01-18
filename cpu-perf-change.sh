#!/bin/bash

## Script to toggle the CPU governor from powersave to performance and back again ##

query=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
statement="Permission needed to change CPU governor. Please enter password..."

if [ "$query" == "powersave" ]; then

    xterm -title "Activate \"Performance\" Governor" -class floatingWin -e "echo $statement && echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor && notify-send 'CPU Performance Enabled'"

else

    xterm -title "Activate \"Powersave\" Governor" -class floatingWin -e "echo $statement && echo powersave | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor && notify-send 'CPU Powersave Enabled'"

fi

exit 0
