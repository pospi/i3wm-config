#!/usr/bin/env bash
#
# Monitor control script for xrandr commands
#
# @author:  pospi <pospi@spadgos.com>
# @since:   2019-01-09
#
##

OUTPUT=`autorandr --change --default mobile 2>&1`

echo "$OUTPUT"

SELECTED=`echo "$OUTPUT" | grep '\(detected\)' | cut -f 1 -d ' '`

notify-send "Display profile changed to ${SELECTED}"

exit 0




# From here down is all just old stuff and testing in case one day
# I can't use autorandr anymore.

#set -x

# wait on resume, for xrandr to init
if [ "$1" == "resume" ]; then
  sleep 1

  i3-dump-log > /home/pospi/Desktop/i3-debug-01.log

  xrandr --output "HDMI-0" --off
  xrandr --output "DP-0" --off
  xrandr --output "DP-1" --off
  xrandr --output "DP-2" --off
  xrandr --output "DP-3" --off
  xrandr --output "eDP-1-1" --primary

  sleep 5

  i3-dump-log > /home/pospi/Desktop/i3-debug-02.log

  exit 0
fi

# xrandr --current

MONITOR_BUILTIN="eDP-1-1"
MONITOR_LEGACY="HDMI-0"

MONITOR_LEGACY_ON=`xrandr | grep "$MONITOR_LEGACY connected"`
MONITOR_HIDEF_ON=`xrandr | grep "DP-[0-9] connected"`

MONITOR_HIDEF=`echo $MONITOR_HIDEF_ON | cut -f 1 -d " "`

if [ ! -z "$MONITOR_LEGACY_ON" ] && [ ! -z "$MONITOR_HIDEF_ON" ]; then
  # echo "3 screen setup"
  xrandr --output $MONITOR_HIDEF --primary
  xrandr --output $MONITOR_BUILTIN --auto --right-of $MONITOR_HIDEF
  xrandr --output $MONITOR_LEGACY --auto --right-of $MONITOR_BUILTIN
elif [ ! -z "$MONITOR_HIDEF_ON" ]; then
  # echo "Single main screen"
  xrandr --output $MONITOR_HIDEF --primary
  xrandr --output $MONITOR_BUILTIN --off
  xrandr --output $MONITOR_LEGACY --off
elif [ ! -z "$MONITOR_LEGACY_ON" ]; then
  # echo "HDMI presentation mode"
  xrandr --output $MONITOR_BUILTIN --primary
  xrandr --output $MONITOR_LEGACY --auto --right-of $MONITOR_BUILTIN
  xrandr --output $MONITOR_HIDEF --off
else
  # echo "Laptop screen only"
  xrandr --output $MONITOR_BUILTIN --primary
  xrandr --output $MONITOR_HIDEF --off
  xrandr --output $MONITOR_LEGACY --off
fi

# restart i3, to put workspaces on correct outputs
/home/pospi/.config/i3/switch-workspace-to-monitor.py 1

i3-dump-log > /home/pospi/Desktop/i3-debug-02.log

exit 0
