#!/bin/bash
# Funciones compartidas por los scripts de ~/.config/hypr/scripts.

HYPR="$HOME/.config/hypr"
SCRIPTS="$HYPR/scripts"
ESTADO="$HOME/.local/state/hypr-cachyos"   # modo y distribucion guardados
mkdir -p "$ESTADO"

# Menu con fuzzel (usa los colores de end4-pC: ~/.config/fuzzel). Uso: menu "Titulo" [opciones] < lineas
menu() {
  local titulo=$1; shift
  pkill -x fuzzel 2>/dev/null
  fuzzel --dmenu -p "$titulo  " "$@"
}

avisar() { # avisar "Titulo" "Texto" [icono]
  notify-send -a "Hyprland" -i "${3:-preferences-system}" "$1" "${2:-}"
}

# Abre una orden en la terminal con un titulo (para las reglas de ventanas)
en_terminal() { # en_terminal "Titulo" orden...
  local titulo=$1; shift
  if command -v kitty >/dev/null; then exec kitty --title "$titulo" "$@"
  else exec xdg-terminal-exec "$@"; fi
}
