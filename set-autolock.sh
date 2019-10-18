#!/usr/bin/env bash
#
# Enable or disable xautolock and work around issues where the intended
# commands (`xautolock -disable` etc) can't find the running daemon
#
# @author:  pospi <pospi@spadgos.com>
# @since:   2019-02-13
#
##

systemLockPrepareTimeout=14 # minutes (slightly less than above- for preparing lock resources)
systemLockTimeout=11 # minutes (runs after prepare, so == 25 mins)

case "$1" in
  1)
    xautolock -notify 20 -notifier "$HOME/.config/i3/i3lock.sh notify" \
    -time $systemLockPrepareTimeout -locker "$HOME/.config/i3/i3lock.sh prepare" \
    -killtime $systemLockTimeout -killer "$HOME/.config/i3/i3lock.sh auto" \
    -detectsleep &

    notify-send "Enabled auto-lock"
  ;;

  0)
    killall xautolock

    notify-send "Disabled auto-lock"
  ;;

  *)
    echo "Please provide a 0 or 1 to disable or enable automatic lock"
    exit 1
  ;;
esac
