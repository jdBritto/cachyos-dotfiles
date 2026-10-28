#!/bin/bash
# Cambia entre tema claro y oscuro con el script de colores de end4-pC (sin cambiar el fondo).
source "$(dirname "$0")/comun.sh"
SW="$HOME/.config/quickshell/end4-pC/scripts/colors/switchwall.sh"
if [ "$(gsettings get org.gnome.desktop.interface color-scheme)" = "'prefer-light'" ]; then
  modo=dark; texto="Tema oscuro"
else
  modo=light; texto="Tema claro"
fi
"$SW" --mode "$modo" --noswitch && avisar "$texto" "" weather-clear-night
