#!/bin/bash
# Menu de apagado (wlogout) con los colores del tema.
source "$(dirname "$0")/comun.sh"
pkill -x wlogout && exit 0
if ! command -v wlogout >/dev/null; then
  op=$(printf '󰌾  Bloquear\tloginctl lock-session\n󰍃  Cerrar sesión\thyprctl dispatch "hl.dsp.exit()"\n󰤄  Suspender\tsystemctl suspend\n󰜉  Reiniciar\tsystemctl reboot\n󰐥  Apagar\tsystemctl poweroff\n' |
       menu "Energía" --width 28 --lines 5 --with-nth 1 --accept-nth 2) || exit 0
  exec bash -c "$op"
fi
cat > "$GEN/wlogout-layout" <<'L'
{ "label": "lock",     "action": "loginctl lock-session", "text": "Bloquear",   "keybind": "b" }
{ "label": "logout",   "action": "hyprctl dispatch 'hl.dsp.exit()'", "text": "Cerrar sesión", "keybind": "c" }
{ "label": "suspend",  "action": "systemctl suspend",     "text": "Suspender",  "keybind": "s" }
{ "label": "reboot",   "action": "systemctl reboot",      "text": "Reiniciar",  "keybind": "r" }
{ "label": "shutdown", "action": "systemctl poweroff",    "text": "Apagar",     "keybind": "a" }
L
alto=$(hyprctl monitors -j | jq '.[] | select(.focused) | (.height / .scale) | floor')
m=$(( ${alto:-1080} * 32 / 100 ))
exec wlogout -l "$GEN/wlogout-layout" -C "$GEN/wlogout.css" -b 5 -T $m -B $m -c 0 -r 0 --protocol layer-shell
