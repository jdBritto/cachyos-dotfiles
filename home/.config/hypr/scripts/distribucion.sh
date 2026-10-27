#!/bin/bash
# Distribucion de ventanas: mosaico -> columnas (como Niri) -> principal y pila.
#   distribucion.sh siguiente | poner dwindle|scrolling|master
source "$(dirname "$0")/comun.sh"
actual=$(cat "$ESTADO/distribucion" 2>/dev/null || echo dwindle)
case ${1:-siguiente} in
  poner) n=$2 ;;
  *) case $actual in dwindle) n=scrolling ;; scrolling) n=master ;; *) n=dwindle ;; esac ;;
esac
echo "$n" > "$ESTADO/distribucion"
hyprctl reload >/dev/null
case $n in
  dwindle)   avisar "Distribución: mosaico" "Las ventanas se reparten la pantalla" view-grid ;;
  scrolling) avisar "Distribución: columnas" "Como en Niri: columnas que se desplazan" view-grid ;;
  master)    avisar "Distribución: principal" "Una ventana grande y el resto en pila" view-grid ;;
esac
