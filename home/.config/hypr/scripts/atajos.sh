#!/bin/bash
# Muestra todos los atajos con su descripcion (se leen de Hyprland).
source "$(dirname "$0")/comun.sh"
hyprctl binds -j | jq -r '
  def mods: [ (if .modmask/64|floor%2==1 then "Super" else empty end),
              (if .modmask/4|floor%2==1  then "Ctrl"  else empty end),
              (if .modmask/8|floor%2==1  then "Alt"   else empty end),
              (if .modmask%2==1          then "Shift" else empty end) ];
  .[] | select(.has_description) |
  ((mods + [ (({"bar":"|","grave":"`","mouse:272":"Clic izq.","mouse:273":"Clic der.","mouse_down":"Rueda abajo","mouse_up":"Rueda arriba","RETURN":"Enter","SPACE":"Espacio","ESCAPE":"Esc","PRINT":"ImprPant","COMMA":",","PAGE_UP":"RePág","PAGE_DOWN":"AvPág","TAB":"Tab","LEFT":"←","RIGHT":"→","UP":"↑","DOWN":"↓","XF86PowerOff":"Encendido","XF86AudioRaiseVolume":"Vol+","XF86AudioLowerVolume":"Vol-","XF86AudioMute":"Silencio","XF86AudioMicMute":"Mic","XF86MonBrightnessUp":"Brillo+","XF86MonBrightnessDown":"Brillo-","XF86AudioNext":"Siguiente","XF86AudioPrev":"Anterior","XF86AudioPlay":"Play","XF86AudioPause":"Pausa"}[.key] // (.key | (.[0:1]|ascii_upcase) + .[1:]))) ]) | join(" + ")) as $k |
  "\($k)\t\(.description)"' |
  awk -F'\t' '!visto[$2 FS $1]++ { printf "%-26s  %s\n", $1, $2 }' |
  menu "Atajos" --width 72 --lines 18 --no-run-if-empty >/dev/null
