#!/usr/bin/env bash

set -u

telemetry=""
gpu_name=""
utilization=""
temperature=""

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

if [[ ! "$utilization" =~ ^[0-9]+$ || ! "$temperature" =~ ^[0-9]+$ ]]; then
    for name_file in /sys/class/hwmon/hwmon*/name; do
        [[ "$(<"$name_file")" == "amdgpu" ]] || continue
        directory="${name_file%/*}"
        for label_file in "$directory"/temp*_label; do
            [[ "$(<"$label_file")" == "edge" ]] || continue
            temperature="$(( $(<"${label_file%_label}_input") / 1000 ))"
            utilization="$(<"$directory/device/gpu_busy_percent")"
            gpu_name="AMD GPU"
            break 2
        done
    done
fi

if [[ ! "$utilization" =~ ^[0-9]+$ || ! "$temperature" =~ ^[0-9]+$ ]]; then
    printf '{"text":"","tooltip":"GPU sensors unavailable","class":"unavailable"}\n'
    exit 0
fi

class="normal"
((temperature >= 80)) && class="warning"
((temperature >= 90)) && class="critical"

printf '{"text":"%d%% %d°C ","tooltip":"%s\\nUtilization: %d%%\\nTemperature: %d°C","class":"%s"}\n' \
    "$utilization" "$temperature" "$gpu_name" "$utilization" "$temperature" "$class"
