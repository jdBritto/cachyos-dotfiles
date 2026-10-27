#!/bin/bash
# Capturas de pantalla: se guardan en ~/Pictures/Capturas y se copian.
#   captura.sh area | pantalla | ventana | editar | menu
source "$(dirname "$0")/comun.sh"
DIR="$(xdg-user-dir PICTURES 2>/dev/null || echo "$HOME/Pictures")/Capturas"
mkdir -p "$DIR"
ARCH="$DIR/captura-$(date +%Y%m%d-%H%M%S).png"

hecho() {
  wl-copy < "$ARCH"
  notify-send -a Capturas -i "$ARCH" "Captura guardada" "Copiada al portapapeles\n$(basename "$ARCH")"
}

op=${1:-menu}
if [[ $op == menu ]]; then
  op=$(printf '󰩭  Zona\tarea\n󰍹  Pantalla\tpantalla\n󰖯  Ventana\tventana\n󰏫  Zona y editar\teditar\n' |
       menu "Captura" --width 30 --lines 4 --with-nth 1 --accept-nth 2) || exit 0
  sleep 0.3
fi
case $op in
  area)     g=$(slurp -d) || exit 0; grim -g "$g" "$ARCH" && hecho ;;
  pantalla) mon=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name'); grim -o "$mon" "$ARCH" && hecho ;;
  ventana)  g=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"'); grim -g "$g" "$ARCH" && hecho ;;
  editar)   g=$(slurp -d) || exit 0; grim -g "$g" - | swappy -f - -o "$ARCH" ;;
esac
