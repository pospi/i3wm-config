#!/usr/bin/env bash
#
# i3lock wrapper script for nice lockscreens
#
# To execute the script under normal conditions, just run without arguments.
#
# @author:  pospi <pospi@spadgos.com>
# @since:   2019-01-18
#
##

# :DUPE: monitor-timeout-delay
MONITOR_IDLE_TIMEOUT=900

# lock image helper
makeLockImage() {
  # this takes a while... indicate things are moving
  # notify-send --icon=gtk-info "Locking system..." "Enter password and press [enter] to unlock"

  # blend overlay image w. pixellated desktop background
  import -silent -window root bmp:- | \
    mogrify -scale 5% bmp:- | \
    mogrify -scale 2000% bmp:- | \
    composite -gravity South -geometry -20x1200 ~/Pictures/lockscreen.png bmp:- png:- \
    >> /tmp/i3screen_.png
}

# set power mgmt to dim & turn monitor off shortly hereafter
enableMonitorPowerSaving() {
  xset +dpms dpms 0 5 20
}

# detect if media is playing
isMediaPlaying() {
  mediaStatus=$(pacmd list-sink-inputs | grep state: | cut -d " " -f 2)
  if [[ $mediaStatus == *"RUNNING"* ]]; then
    return 0
  fi
  return 1
}

# detect if lockscreen is already active
needToRunLock() {
  lsStatus=$(ps cax | grep i3lock)
  if [[ -z $lsStatus ]]; then
    return 0
  fi
  return 1
}

################################################################################

# setup to restore monitor DPMS settings after exit
revert() {
  rm /tmp/i3screen_*.png
  xset +dpms dpms 0 0 $MONITOR_IDLE_TIMEOUT
}
trap revert HUP INT TERM

case "$1" in
  # triggered by xautolock before trying to suspend
  notify)
    if isMediaPlaying; then
      xautolock -restart
      exit 1
    fi

    # :NOTE: time needs to be synced with -notify param to xautolock (see config)
    notify-send -u critical -t 19750 -- 'Warning! System will suspend shortly after locking...'
  ;;

  # triggered by xautolock *BEFORE* DPMS activates and turns the monitor off (which breaks screenshotting)
  prepare)
    if isMediaPlaying; then
      xautolock -restart
      exit 1
    fi

    # activate lock now, so lock shows for a short duration before screen goes off
    makeLockImage
    i3lock -i /tmp/i3screen_.png
  ;;

  # triggered by xautolock to activate suspend (DPMS will have disabled monitor previously)
  auto)
    if isMediaPlaying; then
      xautolock -restart
      exit 1
    fi

    # suspend the machine (which triggers next step)
    systemctl suspend -i
  ;;

  # Run by systemd when suspending (either manually, or triggered by xautolock)
  suspend)
    # only run the lockscreen if it hasn't already been activated by xautolock
    if needToRunLock; then
      # create lock image first (interrupts suspend tasks, so needs to be fast)
      makeLockImage
      # now we have image, run i3lock in forked mode
      enableMonitorPowerSaving
      i3lock -i /tmp/i3screen_.png
    fi
  ;;

  # Run by systemd when resuming
  resume)
    # wait a bit before starting on resume, so that i3lock can get a handle on the window
    sleep 1
    enableMonitorPowerSaving
    # only run the lockscreen if the process hasn't persisted from before suspend
    if needToRunLock; then
      # only use the lock image if it's there- should never happen, but just in case.
      if [[ -f /tmp/i3screen_.png ]]; then
        i3lock -n -i /tmp/i3screen_.png
      else
        i3lock -n -c 330033
      fi
    fi
  ;;

  # Normal usage (triggered manually)
  *)
    # run non-forked so this process can watch exit to cleanup
    makeLockImage
    enableMonitorPowerSaving
    i3lock -n -i /tmp/i3screen_.png
  ;;
esac

# reset monitor power settings & cleanup temp images
revert
