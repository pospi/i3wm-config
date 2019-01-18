#!/usr/bin/env bash

case "$1" in
    lock)
        $HOME/.config/i3/i3lock.sh
        ;;
    logout)
        i3-msg exit
        ;;
    suspend)
        # lock && dbus-send --system --print-reply --dest=org.freedesktop.login1 /org/freedesktop/login1 "org.freedesktop.login1.Manager.Suspend" boolean:true
        systemctl suspend -i
        ;;
    # hibernate)
    #     lock && dbus-send --system --print-reply --dest=org.freedesktop.login1 /org/freedesktop/login1 "org.freedesktop.login1.Manager.Hibernate" boolean:true
    #     ;;
    reboot)
        # dbus-send --system --print-reply --dest=org.freedesktop.login1 /org/freedesktop/login1 "org.freedesktop.login1.Manager.Reboot" boolean:true
        systemctl reboot
        ;;
    shutdown)
        # dbus-send --system --print-reply --dest="org.freedesktop.ConsoleKit" /org/freedesktop/ConsoleKit/Manager org.freedesktop.ConsoleKit.Manager.Stop
        systemctl poweroff
        ;;
    *)
        echo "Usage: $0 {lock|logout|suspend|hibernate|reboot|shutdown}"
        exit 2
esac

exit 0
