#!/bin/bash
# Centro (Super + I): lo que la interfaz end4-pC no trae, en un solo menu.
# Wifi, bluetooth, sonido, notificaciones y fondo estan en las barras laterales
# de end4-pC (Super + A y Super + N); sus ajustes, en Super + Escape.
source "$(dirname "$0")/comun.sh"
S=$SCRIPTS

modo=$("$S/modo.sh" estado)
dist=$(cat "$ESTADO/distribucion" 2>/dev/null || echo dwindle)
case $dist in dwindle) dist=mosaico ;; scrolling) dist=columnas ;; master) dist=principal ;; esac

opciones=(
  "󰓅  Modo de energia          $modo|$S/modo.sh ciclar"
  "󰕰  Distribucion ventanas    $dist|$S/distribucion.sh"
  "󰍹  Pantallas|$S/monitores.sh"
  "󰉼  Apariencia de apps GTK|nwg-look"
  "  Ajustes de end4-pC|hyprctl dispatch 'hl.dsp.global(\"quickshell:settingsToggle\")'"
)

if [[ -x $HOME/.local/bin/vpn-trabajo ]]; then
  vpn="desconectada"; pgrep -x openfortivpn >/dev/null && vpn="conectada"
  opciones+=("󰒄  VPN del trabajo          $vpn|source $S/comun.sh; en_terminal 'VPN del trabajo' $HOME/.local/bin/vpn-trabajo")
fi

BAT=$(ls -d /sys/class/power_supply/BAT*/ 2>/dev/null | head -n1)
if [[ -n $BAT && -r ${BAT}charge_control_end_threshold ]]; then
  limite=$(cat "${BAT}charge_control_end_threshold")
  if command -v bateria-completa >/dev/null && ((limite < 100)); then
    opciones+=("󰂄  Bateria: cargar al 100% una vez (limite $limite%)|source $S/comun.sh; en_terminal 'Bateria' bateria-completa")
  fi
fi

i=$(printf '%s\n' "${opciones[@]%%|*}" | menu "Centro" --width 50 --lines ${#opciones[@]} --index) || exit 0
accion=${opciones[$i]#*|}
sleep 0.1
exec bash -c "$accion"
