#!/bin/bash
# Botones de escritorios para la barra (waybar 0.12 no sabe cambiar de
# escritorio con Hyprland 0.55). Un oyente sigue los eventos de Hyprland y
# deja el estado de cada boton en generado/escritorios/N.
#
#   escritorios.sh escuchar   (lo arranca barra.sh; "parar" lo detiene)
#   escritorios.sh N          estado del escritorio N (lo lee la barra)
#   escritorios.sh extra      escritorio activo si es mayor que 5

source "$(dirname "$0")/comun.sh"
EST="$GEN/escritorios"
mkdir -p "$EST"

actualizar() {
  local activo ocupados urgentes
  activo=$(hyprctl activeworkspace -j | jq '.id')
  ocupados=" $(hyprctl workspaces -j | jq -r '[.[] | select(.id > 0 and .windows > 0) | .id] | join(" ")') "
  for n in 1 2 3 4 5; do
    if [[ $n == "$activo" ]]; then c=activo; t="󰮯"
    elif [[ $ocupados == *" $n "* ]]; then c=ocupado; t="󰊠"
    else c=vacio; t="󰑊"; fi
    printf '{"text":"%s","class":"%s","tooltip":"Escritorio %s"}\n' "$t" "$c" "$n" > "$EST/$n"
  done
  if (( activo > 5 )); then
    printf '{"text":"󰮯 %s","class":"activo","tooltip":"Escritorio %s"}\n' "$activo" "$activo" > "$EST/extra"
  else
    printf '{"text":"","class":"vacio"}\n' > "$EST/extra"
  fi
  pkill -RTMIN+11 -x waybar
}

case ${1:-escuchar} in
  parar)
    if [[ -f $GEN/escritorios.pid ]]; then
      pid=$(cat "$GEN/escritorios.pid")
      pkill -P "$pid" 2>/dev/null; kill "$pid" 2>/dev/null
      rm -f "$GEN/escritorios.pid"
    fi ;;
  escuchar)
    echo $$ > "$GEN/escritorios.pid"
    SOCK="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
    actualizar
    socat -u "UNIX-CONNECT:$SOCK" - | while read -r ev; do
      case $ev in
        workspace\>\>*|createworkspace\>\>*|destroyworkspace\>\>*|focusedmon\>\>*|openwindow\>\>*|closewindow\>\>*|movewindow\>\>*|configreloaded*)
          actualizar ;;
      esac
    done ;;
  [1-9]|extra) cat "$EST/$1" 2>/dev/null || echo '{"text":""}' ;;
esac
