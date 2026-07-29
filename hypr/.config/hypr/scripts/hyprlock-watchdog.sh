#!/bin/bash
# Keeps hyprlock alive right after resume from suspend. Works around a known
# hyprlock crash (SIGABRT/segfault) caused by a GPU/monitor-reprobe race on
# wake when an external monitor is attached: hyprwm/hyprlock#1048
# Stops as soon as the session is genuinely unlocked (logind LockedHint).

session="${XDG_SESSION_ID:-$(loginctl list-sessions --no-legend | awk -v u="$USER" '$3==u{print $1; exit}')}"

for _ in $(seq 1 20); do
    locked=$(loginctl show-session "$session" -p LockedHint --value 2>/dev/null)
    [[ $locked == yes ]] || exit 0
    pidof hyprlock >/dev/null || hyprctl dispatch exec hyprlock
    sleep 2
done
