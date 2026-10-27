#!/bin/bash
# Distribucion de ventanas: mosaico -> columnas (como Niri) -> principal y pila.
#   distribucion.sh [siguiente] | poner dwindle|scrolling|master
# Se guarda en los ajustes de end4-pC (Hyprland > Distribucion), asi los dos coinciden.
source "$(dirname "$0")/comun.sh"
AJ="$SCRIPTS/ajustes-end4.py"
actual=$("$AJ" ver general.layout 2>/dev/null || echo dwindle)
case ${1:-siguiente} in
  poner) n=$2 ;;
  *) case $actual in dwindle) n=scrolling ;; scrolling) n=master ;; *) n=dwindle ;; esac ;;
esac
case $n in dwindle|scrolling|master) ;; *) echo "Distribucion desconocida: $n" >&2; exit 1 ;; esac
"$AJ" poner general.layout "$n"
case $n in
  dwindle)   avisar "Distribución: mosaico" "Las ventanas se reparten la pantalla" view-grid ;;
  scrolling) avisar "Distribución: columnas" "Como en Niri: columnas que se desplazan" view-grid ;;
  master)    avisar "Distribución: principal" "Una ventana grande y el resto en pila" view-grid ;;
esac
