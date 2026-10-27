#!/bin/bash
# Fondo de pantalla (hyprpaper). Cada tema recuerda el fondo que le elegiste.
#
#   fondo.sh menu              elegir con miniaturas
#   fondo.sh poner RUTA        poner una imagen
#   fondo.sh aleatorio         uno al azar de la galeria
#
# Galeria: ~/Pictures/Fondos, /usr/share/backgrounds y ~/.local/share/backgrounds

source "$(dirname "$0")/comun.sh"

CARPETAS=("$(xdg-user-dir PICTURES 2>/dev/null || echo "$HOME/Pictures")/Fondos" \
          "$HOME/.local/share/backgrounds" /usr/share/backgrounds /usr/share/wallpapers)

lista() {
  find -L "${CARPETAS[@]}" -maxdepth 2 -type f \
    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) 2>/dev/null |
    awk -F/ '!visto[$NF]++' | sort -t/ -k1
}

poner() {
  local img=$1 guardar=${2:-}
  [[ -f $img ]] || { echo "No existe: $img" >&2; return 1; }
  cat > "$GEN/hyprpaper.conf" <<EOF
splash = false
ipc = false

wallpaper {
    monitor =
    path = $img
    fit_mode = cover
}
EOF
  # Se arranca uno nuevo y despues se cierra el anterior: asi no parpadea
  local viejos
  viejos=$(pgrep -x hyprpaper)
  (hyprpaper -c "$GEN/hyprpaper.conf" &>/dev/null &)
  if [[ -n $viejos ]]; then sleep 0.8; kill $viejos 2>/dev/null; fi
  echo "$img" > "$GEN/fondo-actual"
  [[ $guardar == --sin-guardar ]] || echo "$img" > "$GEN/fondo-$(tema_actual)"
}

case "${1:-menu}" in
  poner) poner "$2" "${3:-}" ;;
  aleatorio) poner "$(lista | shuf -n1)" ;;
  menu)
    mkdir -p "$GEN/miniaturas"
    mapfile -t imgs < <(lista)
    actual=$(cat "$GEN/fondo-actual" 2>/dev/null)
    filas() {
      local img mini nombre
      for img in "${imgs[@]}"; do
        mini="$GEN/miniaturas/$(printf '%s' "$img" | md5sum | cut -c1-12)-v2.png"
        miniatura "$img" "$mini"
        nombre=$(basename "${img%.*}"); nombre=${nombre#backgrounds-}; nombre=${nombre#wallpapers-}; [[ $img == "$actual" ]] && nombre+="  (actual)"
        printf '%s\0icon\x1f%s\n' "$nombre" "$mini"
      done
    }
    i=$(filas | menu "Fondo" --width 40 --line-height 56 --lines 7 --index) || exit 0
    poner "${imgs[$i]}"
    ;;
  *) sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//' ;;
esac
