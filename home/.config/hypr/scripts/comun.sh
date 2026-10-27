#!/bin/bash
# Funciones compartidas por los scripts de Hyprland Parrot.

HYPR="$HOME/.config/hypr"
GEN="$HYPR/generado"
TEMAS="$HYPR/temas"
SCRIPTS="$HYPR/scripts"
mkdir -p "$GEN"

# Menu con fuzzel. Uso: menu "Titulo" [opciones extra de fuzzel] < lineas
menu() {
  local titulo=$1; shift
  pkill -x fuzzel 2>/dev/null
  fuzzel --dmenu --config "$GEN/fuzzel.ini" -p "$titulo  " "$@"
}

avisar() { # avisar "Titulo" "Texto" [icono]
  notify-send -a "Parrot" -h "string:x-dunst-stack-tag:${3:-parrot}" -i "${3:-parrot}" "$1" "${2:-}"
}

tema_actual() { cat "$GEN/tema" 2>/dev/null || echo parrot; }

# Carga las variables de un tema (bg, fg, acento, fondo...) en el shell.
cargar_tema() {
  local f="$TEMAS/$1.tema"
  [[ -f $f ]] || return 1
  # shellcheck disable=SC1090
  source "$f"
}

esquema_gtk() { # oscuro | claro (no se toca en modo prueba)
  [[ -n ${PARROT_PRUEBA:-} ]] && return
  local actual
  actual=$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null)
  if [[ $1 == claro ]]; then
    gsettings set org.gnome.desktop.interface color-scheme prefer-light 2>/dev/null
    # Solo si usas Adwaita (CachyOS); en Parrot el tema GTK lo pone Plasma
    [[ $actual == "'Adwaita-dark'" ]] && gsettings set org.gnome.desktop.interface gtk-theme Adwaita
  else
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark 2>/dev/null
    [[ $actual == "'Adwaita'" ]] && gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark
  fi
  return 0
}

# Ruta real de un fondo: si no esta en el sistema (por ejemplo, los fondos de
# Parrot en CachyOS), se busca con el mismo nombre en ~/.local/share/backgrounds.
ruta_fondo() {
  local f=$1 n
  [[ -f $f ]] && { echo "$f"; return; }
  n=$(basename "$f")
  for d in "$HOME/.local/share/backgrounds/parrot" "$HOME/.local/share/backgrounds" /usr/share/backgrounds; do
    [[ -f $d/$n ]] && { echo "$d/$n"; return; }
  done
  # Ninguno: el primero que haya
  find -L "$HOME/.local/share/backgrounds" /usr/share/backgrounds -maxdepth 2 -type f \
    \( -iname '*.jpg' -o -iname '*.png' \) 2>/dev/null | head -n1
}

# Tema de iconos para el lanzador y las notificaciones
tema_iconos() {
  local t
  for t in Flat-Remix-Green-Dark Papirus-Dark Papirus Adwaita; do
    [[ -d /usr/share/icons/$t || -d $HOME/.local/share/icons/$t ]] && { echo "$t"; return; }
  done
  echo hicolor
}

# Miniatura cuadrada con esquinas redondeadas: miniatura ORIGEN DESTINO
miniatura() {
  [[ -f $2 ]] && return
  magick "$1[0]" -thumbnail 128x128^ -gravity center -extent 128x128 \
    \( +clone -alpha extract -fill black -colorize 100 -fill white \
       -draw "roundrectangle 0,0 127,127 22,22" \) -alpha off -compose CopyOpacity -composite \
    "$2" 2>/dev/null
}
