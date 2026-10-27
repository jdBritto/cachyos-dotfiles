#!/bin/bash
# Modo de energia: cambia los efectos de Hyprland y el perfil de energia.
#
#   equilibrado  efectos como en los ajustes de end4-pC, perfil "balanced"
#   rendimiento  sin desenfoque ni sombras, perfil "performance" (juegos, trabajo pesado)
#   ahorro       sin efectos ni animaciones, perfil "power-saver" (bateria)
#
#   modo.sh ciclar | poner MODO | aplicar | estado | vigilar
#
# "vigilar" se queda escuchando a power-profiles-daemon: si cambias el perfil con el
# boton de end4-pC (barra o panel derecho), los efectos de Hyprland cambian tambien.

source "$(dirname "$0")/comun.sh"

actual() { cat "$ESTADO/modo" 2>/dev/null || echo equilibrado; }

perfil() { # modo -> perfil de power-profiles-daemon
  case $1 in
    rendimiento) echo performance ;;
    ahorro) echo power-saver ;;
    *) echo balanced ;;
  esac
}

modo_de() { # perfil -> modo
  case $1 in
    performance) echo rendimiento ;;
    power-saver) echo ahorro ;;
    *) echo equilibrado ;;
  esac
}

guardar() { # guardar MODO: lo apunta y recarga Hyprland (custom/modo.lua lo lee)
  echo "$1" > "$ESTADO/modo"
  hyprctl reload >/dev/null
}

poner() {
  case $1 in equilibrado|rendimiento|ahorro) ;; *) echo "Modo desconocido: $1" >&2; return 1 ;; esac
  guardar "$1"
  command -v powerprofilesctl >/dev/null && powerprofilesctl set "$(perfil "$1")" 2>/dev/null
  return 0
}

vigilar() {
  command -v gdbus >/dev/null || exit 0
  # Solo uno a la vez
  exec 9>"$ESTADO/vigilar.lock"
  flock -n 9 || exit 0
  while true; do
    gdbus monitor --system --dest org.freedesktop.UPower.PowerProfiles \
        --object-path /org/freedesktop/UPower/PowerProfiles 2>/dev/null |
      while read -r linea; do
        [[ $linea =~ \'ActiveProfile\':\ \<\'([a-z-]+)\'\> ]] || continue
        m=$(modo_de "${BASH_REMATCH[1]}")
        [[ $m == "$(actual)" ]] || guardar "$m"
      done
    sleep 5   # power-profiles-daemon se reinicio o no esta: reintentar
  done
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
  vigilar) vigilar ;;
  estado) actual ;;
  *) sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; exit 2 ;;
esac
