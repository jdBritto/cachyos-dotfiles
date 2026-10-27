#!/bin/bash
# Barra (waybar). Dos estilos: "islas" (bloques flotantes) y "panel" (barra completa).
#
#   barra.sh reiniciar | ocultar | estilo [islas|panel]

source "$(dirname "$0")/comun.sh"
W="$HYPR/waybar"

estilo_actual() { cat "$GEN/barra" 2>/dev/null || echo islas; }

iniciar() {
  pkill -x waybar; "$SCRIPTS/escritorios.sh" parar; sleep 0.2
  ("$SCRIPTS/escritorios.sh" escuchar &>/dev/null &)
  (waybar -c "$W/$(estilo_actual).jsonc" -s "$W/$(estilo_actual).css" &>/dev/null &)
}

case "${1:-reiniciar}" in
  reiniciar) iniciar ;;
  ocultar) pkill -USR1 -x waybar ;;
  estilo)
    if [[ -n ${2:-} ]]; then n=$2
    elif [[ $(estilo_actual) == islas ]]; then n=panel
    else n=islas; fi
    [[ -f $W/$n.css ]] || { echo "No existe el estilo: $n" >&2; exit 1; }
    echo "$n" > "$GEN/barra"
    iniciar
    ;;
esac
