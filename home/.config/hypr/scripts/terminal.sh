#!/bin/bash
# Abre la terminal con los colores del tema: Ghostty si esta, si no Kitty.
#   terminal.sh [--title TITULO] [-e ORDEN...]
GEN="$HOME/.config/hypr/generado"
titulo=""; orden=()
while (($#)); do
  case $1 in
    --title) titulo=$2; shift 2 ;;
    -e) shift; orden=("$@"); break ;;
    *) shift ;;
  esac
done
if command -v ghostty >/dev/null; then
  args=(--config-file="?$GEN/ghostty.conf")
  [[ -n $titulo ]] && args+=(--title="$titulo")
  ((${#orden[@]})) && args+=(-e "${orden[@]}")
  exec ghostty "${args[@]}"
elif command -v kitty >/dev/null; then
  args=()
  [[ -n $titulo ]] && args+=(--title "$titulo")
  exec kitty "${args[@]}" "${orden[@]}"
else
  exec xdg-terminal-exec "${orden[@]}"
fi
