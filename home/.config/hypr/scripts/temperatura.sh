#!/bin/bash
# Temperatura del procesador para la barra (sirve con AMD e Intel).
for h in /sys/class/hwmon/hwmon*; do
  case $(cat "$h/name" 2>/dev/null) in
    k10temp|coretemp|zenpower|cpu_thermal|acpitz) t=$(( $(cat "$h/temp1_input") / 1000 )); break ;;
  esac
done
[[ -n ${t:-} ]] || { echo '{"text":""}'; exit 0; }
c=normal; i="󰔏"; (( t >= 70 )) && { c=caliente; i="󱃂"; }; (( t >= 85 )) && c=critico
(( t < 50 )) && i="󱃃"
printf '{"text":"%s %s°","tooltip":"Procesador: %s °C","class":"%s"}\n' "$i" "$t" "$t" "$c"
