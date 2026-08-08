#!/usr/bin/env bash

set -u

temperature_file=""

for name_file in /sys/class/hwmon/hwmon*/name; do
    [[ "$(<"$name_file")" == "k10temp" ]] || continue
    for label_file in "${name_file%/*}"/temp*_label; do
        [[ "$(<"$label_file")" == "Tctl" ]] || continue
        temperature_file="${label_file%_label}_input"
        break 2
    done
done

if [[ ! -r "$temperature_file" ]]; then
    printf '{"text":"","tooltip":"CPU temperature sensor unavailable","class":"unavailable"}\n'
    exit 0
fi

temperature="$(( $(<"$temperature_file") / 1000 ))"
class="normal"
((temperature >= 80)) && class="warning"
((temperature >= 90)) && class="critical"

printf '{"text":"%d°C ","tooltip":"CPU temperature: %d°C","class":"%s"}\n' \
    "$temperature" "$temperature" "$class"
