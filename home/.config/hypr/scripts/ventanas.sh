#!/bin/bash
# Lista de ventanas abiertas en todos los escritorios; Enter va a la elegida.
source "$(dirname "$0")/comun.sh"
datos=$(hyprctl clients -j | jq -r 'sort_by(.workspace.id) | .[] | select(.mapped) |
  "\(.address)\t\(.class)\t\(if .workspace.name == "special:minimizadas" then "minimizada" elif .workspace.name == "special:terminal" then "desplegable" else "esc. \(.workspace.name)" end)\t\(.title)"')
[[ -n $datos ]] || { avisar "Ventanas" "No hay ventanas abiertas" window; exit 0; }
filas() {
  while IFS=$'\t' read -r dir clase esc titulo; do
    printf '[%s]  %s\0icon\x1f%s\n' "$esc" "${titulo:0:70}" "$(tr 'A-Z' 'a-z' <<< "$clase")"
  done <<< "$datos"
}
i=$(filas | menu "Ventanas" --width 70 --index) || exit 0
dir=$(sed -n "$((i + 1))p" <<< "$datos" | cut -f1)
esc=$(sed -n "$((i + 1))p" <<< "$datos" | cut -f3)
if [[ $esc == minimizada ]]; then
  # La traemos de vuelta al escritorio actual
  actual=$(hyprctl activeworkspace -j | jq .id)
  hyprctl dispatch "hl.dsp.window.move({ workspace = $actual, window = \"address:$dir\" })" >/dev/null
fi
hyprctl dispatch "hl.dsp.focus({ window = \"address:$dir\" })" >/dev/null
