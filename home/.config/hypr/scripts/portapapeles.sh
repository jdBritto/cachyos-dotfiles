#!/bin/bash
# Historial del portapapeles (cliphist). Enter copia; "Borrar historial" al final.
source "$(dirname "$0")/comun.sh"
sel=$( { cliphist list; printf '󰆴  Borrar historial\n'; } | menu "Portapapeles" --width 70 ) || exit 0
if [[ $sel == "󰆴  Borrar historial" ]]; then
  cliphist wipe && avisar "Portapapeles" "Historial borrado" edit-clear
else
  printf '%s' "$sel" | cliphist decode | wl-copy
fi
