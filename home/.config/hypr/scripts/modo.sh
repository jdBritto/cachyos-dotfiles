#!/bin/bash
# Modo de energia: cambia los efectos de Hyprland y el perfil de energia.
#
#   equilibrado  efectos como en los ajustes de end4-pC, perfil "balanced"
#   rendimiento  sin desenfoque ni sombras, perfil "performance" (juegos, trabajo pesado)
#   ahorro       sin efectos ni animaciones, perfil "power-saver" (bateria)
#
#   modo.sh ciclar | poner MODO | aplicar | estado

source "$(dirname "$0")/comun.sh"

actual() { cat "$ESTADO/modo" 2>/dev/null || echo equilibrado; }

perfil() { # equivalente en power-profiles-daemon
  case $1 in
    rendimiento) echo performance ;;
    ahorro) echo power-saver ;;
    *) echo balanced ;;
  esac
}

poner() {
  case $1 in equilibrado|rendimiento|ahorro) ;; *) echo "Modo desconocido: $1" >&2; return 1 ;; esac
  echo "$1" > "$ESTADO/modo"
  command -v powerprofilesctl >/dev/null && powerprofilesctl set "$(perfil "$1")" 2>/dev/null
  hyprctl reload >/dev/null
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
      equilibrado) avisar "Modo equilibrado" "Todos los efectos activos" power-profile-balanced-symbolic ;;
      rendimiento) avisar "Modo rendimiento" "Sin desenfoque ni sombras, CPU al maximo" power-profile-performance-symbolic ;;
      ahorro)      avisar "Modo ahorro" "Sin efectos ni animaciones, ahorra bateria" power-profile-power-saver-symbolic ;;
    esac
    ;;
  poner) poner "$2" ;;
  aplicar) command -v powerprofilesctl >/dev/null && powerprofilesctl set "$(perfil "$(actual)")" 2>/dev/null ;;
  estado) actual ;;
esac
