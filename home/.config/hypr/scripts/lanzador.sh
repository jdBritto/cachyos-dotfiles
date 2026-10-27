#!/bin/bash
# Buscador de aplicaciones (fuzzel). Pulsa otra vez Super + Espacio para cerrarlo.
# Oculta las ~200 entradas "[not installed]" del menu de Parrot (solo aqui;
# el menu de Plasma no cambia).
source "$(dirname "$0")/comun.sh"
pkill -x fuzzel && exit 0

OCULTAS="$GEN/lanzador/applications"
if [[ ! -d $OCULTAS || /usr/share/applications -nt $OCULTAS ]]; then
  rm -rf "$OCULTAS"; mkdir -p "$OCULTAS"
  grep -l '^Name=\[not installed\]' /usr/share/applications/*.desktop 2>/dev/null |
    while read -r f; do
      printf '[Desktop Entry]\nType=Application\nName=oculta\nNoDisplay=true\n' > "$OCULTAS/$(basename "$f")"
    done
  touch "$OCULTAS"
fi
XDG_DATA_DIRS="$GEN/lanzador:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}" \
  exec fuzzel --config "$GEN/fuzzel.ini" -p "󰍉  " --placeholder "Buscar aplicaciones..."
