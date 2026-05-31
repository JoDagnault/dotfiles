#!/usr/bin/env bash

# watch-waybar.sh
# Starts Waybar and keeps it healthy inside a Hyprland session.

WAYBAR_CONFIG="$HOME/.config/waybar/config.jsonc"
WAYBAR_STYLE="$HOME/.config/waybar/style.css"
WAYBAR_CONFIG_DIR="$HOME/.config/waybar"

CHECK_INTERVAL=10
STARTUP_GRACE=5

hypr_socket2() {
    printf '%s/hypr/%s/.socket2.sock' "$XDG_RUNTIME_DIR" "$HYPRLAND_INSTANCE_SIGNATURE"
}

hyprland_ready() {
    [[ -n "$XDG_RUNTIME_DIR" ]] || return 1
    [[ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]] || return 1
    [[ -S "$(hypr_socket2)" ]] || return 1
}

start_waybar() {
    if ! pgrep -x waybar >/dev/null; then
        waybar &
    fi
}

stop_waybar() {
    pkill -x waybar 2>/dev/null || true
    sleep 0.5
}

restart_waybar() {
    stop_waybar
    start_waybar
}

check_ipc() {
    hyprland_ready || return 1

    local socket2
    socket2="$(hypr_socket2)"

    grep -q " 03 [0-9]* ${socket2}$" /proc/net/unix 2>/dev/null
}

watch_config() {
    while true; do
        inotifywait -q \
            -e close_write \
            -e moved_to \
            "$WAYBAR_CONFIG_DIR" >/dev/null 2>&1

        restart_waybar
        sleep "$STARTUP_GRACE"
    done
}

cleanup() {
    stop_waybar
}

trap cleanup EXIT INT TERM

if ! hyprland_ready; then
    echo "Hyprland socket is not ready. Start this script from inside Hyprland."
    exit 1
fi

start_waybar
watch_config &

sleep "$STARTUP_GRACE"

while true; do
    if ! hyprland_ready; then
        exit 0
    fi

    if ! pgrep -x waybar >/dev/null; then
        start_waybar
        sleep "$STARTUP_GRACE"
    elif ! check_ipc; then
        restart_waybar
        sleep "$STARTUP_GRACE"
    fi

    sleep "$CHECK_INTERVAL"
done
