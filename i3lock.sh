#!/usr/bin/env bash
#
# i3lock wrapper script for nice lockscreens
#
# Requires two systemd service wrappers to trigger:
#
# i3lock-suspend.service:
#   [Unit]
#   Description=i3lock on suspend
#   Before=sleep.target
#
#   [Service]
#   User=pospi
#   Type=forking
#   Environment=DISPLAY=:0
#   ExecStart=/home/pospi/.config/i3/i3lock.sh suspend
#
#   [Install]
#   WantedBy=sleep.target
#
# i3lock-resume.service:
#   [Unit]
#   Description=i3lock on resume
#   After=suspend.target
#
#   [Service]
#   User=pospi
#   Type=forking
#   Environment=DISPLAY=:0
#   ExecStart=/home/pospi/.config/i3/i3lock.sh resume
#
#   [Install]
#   WantedBy=suspend.target
#
# To execute the script under normal conditions, just run without arguments.
#
# @author:  pospi <pospi@spadgos.com>
# @since:   2019-01-18
#
##

MONITOR_IDLE_TIMEOUT=1200

# lock image helper
makeLockImage() {
  # this takes a while... indicate things are moving
  notify-send --icon=gtk-info "Locking system..." "Enter password and press [enter] to unlock"
  # blend blurred image w. desktop background
  import -silent -window root png:- | \
  mogrify -blur 0x16 png:- | \
  composite -gravity South -geometry -20x1200 ~/Pictures/lockscreen.png png:- png:- \
    >> /tmp/i3screen_.png
}

# set power mgmt to dim & turn monitor off shortly hereafter
enableMonitorPowerSaving() {
  xset +dpms dpms 0 5 20
}

################################################################################

# setup to restore monitor DPMS settings after exit
revert() {
  rm /tmp/i3screen_*.png
  xset dpms 0 0 $MONITOR_IDLE_TIMEOUT
}
trap revert HUP INT TERM

case "$1" in
  suspend)
    # create lock image first (interrupts suspend tasks)
    makeLockImage
    # now we have image, run i3lock in forked mode
    enableMonitorPowerSaving
    i3lock -i /tmp/i3screen_.png
  ;;
  resume)
    # wait a bit before starting on resume, so that i3lock can get a handle on the window
    sleep 1
    enableMonitorPowerSaving
    # only use the lock image if it's already there
    if [[ -f /tmp/i3screen_.png ]]; then
      i3lock -n -i /tmp/i3screen_.png
    else
      i3lock -n -c 330033
    fi
  ;;
  *)
    # under normal usage (triggered by script), run non-forked so this process can watch exit to cleanup
    makeLockImage
    enableMonitorPowerSaving
    i3lock -n -i /tmp/i3screen_.png
  ;;
esac

# reset monitor power settings & cleanup temp images
revert
