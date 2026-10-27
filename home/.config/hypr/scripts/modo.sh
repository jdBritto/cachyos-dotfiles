#!/bin/bash
# Modo de rendimiento: cambia los efectos de Hyprland y el perfil de energia.
#
#   equilibrado  todos los efectos, perfil "balanced"
#   rendimiento  sin desenfoque ni sombras, perfil "performance" (juegos, trabajo pesado)
#   ahorro       sin efectos ni animaciones, perfil "power-saver" (bateria)
#
#   modo.sh ciclar | poner MODO | aplicar | estado (para la barra)

source "$(dirname "$0")/comun.sh"

actual() { cat "$GEN/modo" 2>/dev/null || echo equilibrado; }

perfil() { # equivalente en power-profiles-daemon
  case $1 in
    rendimiento) echo performance ;;
    ahorro) echo power-saver ;;
    *) echo balanced ;;
  esac
}

poner() {
  local m=$1
  case $m in equilibrado|rendimiento|ahorro) ;; *) echo "Modo desconocido: $m" >&2; return 1 ;; esac
  echo "$m" > "$GEN/modo"
  [[ -z ${PARROT_PRUEBA:-} ]] && command -v powerprofilesctl >/dev/null && powerprofilesctl set "$(perfil "$m")" 2>/dev/null
  hyprctl reload >/dev/null
  pkill -RTMIN+8 waybar 2>/dev/null
}

case "${1:-estado}" in
  ciclar)
    case $(actual) in
      equilibrado) n=rendimiento ;;
      rendimiento) n=ahorro ;;
      *) n=equilibrado ;;
    esac
    poner $n
    case $n in
      equilibrado) avisar "Modo equilibrado" "Todos los efectos activos" speedometer ;;
      rendimiento) avisar "Modo rendimiento" "Sin desenfoque ni sombras, CPU al maximo" speedometer ;;
      ahorro)      avisar "Modo ahorro" "Sin efectos ni animaciones, ahorra bateria" speedometer ;;
    esac
    ;;
  poner) poner "$2" ;;
  aplicar) command -v powerprofilesctl >/dev/null && powerprofilesctl set "$(perfil "$(actual)")" 2>/dev/null ;;
  estado)
    case $(actual) in
      equilibrado) printf '{"text":"󰾅","tooltip":"Modo equilibrado\\nClic: cambiar modo","class":"equilibrado"}\n' ;;
      rendimiento) printf '{"text":"󰓅","tooltip":"Modo rendimiento\\nClic: cambiar modo","class":"rendimiento"}\n' ;;
      ahorro)      printf '{"text":"󰾆","tooltip":"Modo ahorro de bateria\\nClic: cambiar modo","class":"ahorro"}\n' ;;
    esac
    ;;
esac
