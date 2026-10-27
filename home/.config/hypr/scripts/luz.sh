#!/bin/bash
# Luz nocturna (hyprsunset): pantalla mas calida para la noche.
#   luz.sh alternar | estado
source "$(dirname "$0")/comun.sh"
case ${1:-estado} in
  alternar)
    if pgrep -x hyprsunset >/dev/null; then
      pkill -x hyprsunset; rm -f "$GEN/luz"
      avisar "Luz nocturna" "Desactivada" weather-clear
    else
      (hyprsunset -t 4300 &>/dev/null &); touch "$GEN/luz"
      avisar "Luz nocturna" "Activada (pantalla mas calida)" weather-clear-night
    fi
    pkill -RTMIN+9 waybar ;;
  estado)
    if pgrep -x hyprsunset >/dev/null; then
      printf '{"text":"󰖔","tooltip":"Luz nocturna activada\\nClic: desactivar","class":"activo"}\n'
    else
      printf '{"text":"󰖨","tooltip":"Luz nocturna desactivada\\nClic: activar","class":"inactivo"}\n'
    fi ;;
esac
