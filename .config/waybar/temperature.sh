#!/usr/bin/env bash

set -u

find_hwmon_input() {
    local driver="$1"
    local preferred_label="$2"
    local directory
    local input
    local label
    local fallback=""

    shopt -s nullglob

    for directory in /sys/class/hwmon/hwmon*; do
        [[ -r "$directory/name" ]] || continue
        [[ "$(<"$directory/name")" == "$driver" ]] || continue

        for input in "$directory"/temp*_input; do
            [[ -r "$input" ]] || continue
            [[ -n "$fallback" ]] || fallback="$input"
            label=""
            [[ ! -r "${input%_input}_label" ]] || label="$(<"${input%_input}_label")"
            if [[ -n "$preferred_label" && "$label" == "$preferred_label" ]]; then
                printf '%s\n' "$input"
                return 0
            fi
        done

        if [[ -n "$fallback" ]]; then
            printf '%s\n' "$fallback"
            return 0
        fi
    done

    return 1
}

read_millidegrees() {
    local input="$1"
    local value

    value="$(<"$input")"
    [[ "$value" =~ ^-?[0-9]+$ ]] || return 1
    printf '%d\n' "$(((value + 500) / 1000))"
}

emit_temperature() {
    local label="$1"
    local temperature="$2"
    local source="$3"
    local warning="$4"
    local critical="$5"
    local state="normal"

    if ((temperature >= critical)); then
        state="critical"
    elif ((temperature >= warning)); then
        state="warning"
    fi

    printf '{"text":"%s %d°C","tooltip":"%s temperature: %d°C via %s","class":"%s"}\n' \
        "$label" "$temperature" "$label" "$temperature" "$source" "$state"
}

read_cpu_temperature() {
    local input=""
    local source=""
    local temperature

    if input="$(find_hwmon_input k10temp Tctl)"; then
        source="k10temp"
    elif input="$(find_hwmon_input coretemp 'Package id 0')"; then
        source="coretemp"
    elif input="$(find_hwmon_input zenpower Tdie)"; then
        source="zenpower"
    elif input="$(find_hwmon_input cpu_thermal '')"; then
        source="cpu_thermal"
    else
        printf '{"text":"","tooltip":"CPU temperature sensor unavailable","class":"unavailable"}\n'
        return
    fi

    temperature="$(read_millidegrees "$input")" || return 1
    emit_temperature CPU "$temperature" "$source" 80 90
}

read_gpu_temperature() {
    local telemetry=""
    local gpu_name=""
    local temperature=""
    local input=""

    if command -v nvidia-smi >/dev/null 2>&1; then
        telemetry="$(timeout 2 nvidia-smi --query-gpu=name,temperature.gpu --format=csv,noheader,nounits 2>/dev/null | head -n 1)"
        if [[ "$telemetry" == *,* ]]; then
            gpu_name="${telemetry%%,*}"
            temperature="${telemetry##*,}"
            gpu_name="${gpu_name#${gpu_name%%[![:space:]]*}}"
            gpu_name="${gpu_name%${gpu_name##*[![:space:]]}}"
            temperature="${temperature//[[:space:]]/}"
        fi
    fi

    if [[ "$temperature" =~ ^[0-9]+$ ]]; then
        emit_temperature GPU "$temperature" "$gpu_name" 80 90
        return
    fi

    if input="$(find_hwmon_input amdgpu edge)"; then
        temperature="$(read_millidegrees "$input")" || return 1
        emit_temperature GPU "$temperature" amdgpu 80 90
        return
    fi

    printf '{"text":"","tooltip":"GPU temperature sensor unavailable","class":"unavailable"}\n'
}

case "${1:-}" in
    cpu)
        read_cpu_temperature
        ;;
    gpu)
        read_gpu_temperature
        ;;
    *)
        exit 2
        ;;
esac
