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

temperature_state() {
    local temperature="$1"
    local warning="$2"
    local critical="$3"
    local state="normal"

    if ((temperature >= critical)); then
        state="critical"
    elif ((temperature >= warning)); then
        state="warning"
    fi

    printf '%s\n' "$state"
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
    printf '{"text":"%d°C","tooltip":"CPU temperature: %d°C via %s","class":"%s"}\n' \
        "$temperature" "$temperature" "$source" "$(temperature_state "$temperature" 80 90)"
}

read_gpu_temperature() {
    local telemetry=""
    local gpu_name=""
    local utilization=""
    local temperature=""
    local input=""
    local busy_file=""
    local state=""

    if command -v nvidia-smi >/dev/null 2>&1; then
        telemetry="$(timeout 2 nvidia-smi --query-gpu=name,utilization.gpu,temperature.gpu --format=csv,noheader,nounits 2>/dev/null | head -n 1)"
        if [[ "$telemetry" == *,* ]]; then
            IFS=',' read -r gpu_name utilization temperature <<<"$telemetry"
            gpu_name="${gpu_name#${gpu_name%%[![:space:]]*}}"
            gpu_name="${gpu_name%${gpu_name##*[![:space:]]}}"
            utilization="${utilization//[[:space:]]/}"
            temperature="${temperature//[[:space:]]/}"
        fi
    fi

    if [[ "$utilization" =~ ^[0-9]+$ && "$temperature" =~ ^[0-9]+$ ]]; then
        state="$(temperature_state "$temperature" 80 90)"
        printf '{"text":" %d%% %d°C","tooltip":"%s\\nUtilization: %d%%\\nTemperature: %d°C","class":"%s"}\n' \
            "$utilization" "$temperature" "$gpu_name" "$utilization" "$temperature" "$state"
        return
    fi

    if input="$(find_hwmon_input amdgpu edge)"; then
        temperature="$(read_millidegrees "$input")" || return 1
        busy_file="${input%/*}/device/gpu_busy_percent"
        utilization=""
        [[ ! -r "$busy_file" ]] || utilization="$(<"$busy_file")"
        [[ "$utilization" =~ ^[0-9]+$ ]] || utilization=0
        state="$(temperature_state "$temperature" 80 90)"
        printf '{"text":" %d%% %d°C","tooltip":"AMD GPU\\nUtilization: %d%%\\nTemperature: %d°C","class":"%s"}\n' \
            "$utilization" "$temperature" "$utilization" "$temperature" "$state"
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
