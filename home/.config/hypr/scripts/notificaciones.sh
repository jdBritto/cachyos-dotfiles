#!/bin/bash
# Notificaciones (dunst): estado para la barra y modo "no molestar".
#   notificaciones.sh estado | no-molestar | historial
source "$(dirname "$0")/comun.sh"
case ${1:-estado} in
  no-molestar)
    dunstctl set-paused toggle
    [[ $(dunstctl is-paused) == false ]] && avisar "No molestar" "Desactivado" notifications
    pkill -RTMIN+10 waybar ;;
  historial)
    n=$(dunstctl count history)
    [[ $n -gt 0 ]] || { avisar "Notificaciones" "No hay notificaciones" notifications; exit 0; }
    for _ in $(seq "$n"); do dunstctl history-pop; done ;;
  estado)
    n=$(timeout 1 dunstctl count history 2>/dev/null || echo 0)
    if [[ $(timeout 1 dunstctl is-paused 2>/dev/null) == true ]]; then
      printf '{"text":"󰂛","tooltip":"No molestar activado\\nClic derecho: desactivar","class":"pausado"}\n'
    elif [[ $n -gt 0 ]]; then
      printf '{"text":"󰂚 %s","tooltip":"%s notificaciones\\nClic: verlas · Clic derecho: no molestar","class":"pendientes"}\n' "$n" "$n"
    else
      printf '{"text":"󰂜","tooltip":"Sin notificaciones\\nClic derecho: no molestar","class":"vacio"}\n'
    fi ;;
esac
