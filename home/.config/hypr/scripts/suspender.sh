#!/bin/bash
# Suspender por inactividad (hypridle), pero solo con bateria: enchufado no se suspende.
for ac in /sys/class/power_supply/{AC,ADP}*/online; do
  [[ -r $ac && $(<"$ac") == 1 ]] && exit 0
done
systemctl suspend || loginctl suspend
