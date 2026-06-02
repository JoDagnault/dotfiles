#!/usr/bin/env bash

# Session power actions via wofi.
# Bound to mainMod + Shift + R in hyprland.lua.
# Uses dmenu mode so the list is fixed and does not pull app entries.

options="  Lock
  Logout
  Suspend
  Reboot
  Shutdown"

logout() {
    if uwsm check is-active >/dev/null 2>&1; then
        uwsm stop
    else
        hyprctl dispatch exit
    fi
}

choice=$(printf '%s\n' "$options" | wofi \
    --dmenu \
    --prompt "Power" \
    --width 220 \
    --height 250 \
    --cache-file /dev/null)

case "$choice" in
    *Lock)     hyprlock ;;
    *Logout)   logout ;;
    *Suspend)  systemctl suspend ;;
    *Reboot)   systemctl reboot ;;
    *Shutdown) systemctl poweroff ;;
esac
