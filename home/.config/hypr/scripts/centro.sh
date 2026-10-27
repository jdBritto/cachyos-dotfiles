#!/bin/bash
# Centro Parrot: todos los ajustes rapidos en un solo menu (Super + A).
source "$(dirname "$0")/comun.sh"
S=$SCRIPTS

cargar_tema "$(tema_actual)"
modo=$(cat "$GEN/modo" 2>/dev/null || echo equilibrado)
luz="apagada"; pgrep -x hyprsunset >/dev/null && luz="encendida"
nm="no";   [[ $(timeout 1 dunstctl is-paused 2>/dev/null) == true ]] && nm="si"
barra=$(cat "$GEN/barra" 2>/dev/null || echo islas)
dist=$(cat "$GEN/distribucion" 2>/dev/null || echo dwindle)
case $dist in dwindle) dist=mosaico ;; scrolling) dist=columnas ;; master) dist=principal ;; esac

opciones=(
  "󰏘  Tema                     $nombre|$S/tema.sh menu"
  "󰸉  Fondo de pantalla|$S/fondo.sh menu"
  "  Fondo al azar|$S/fondo.sh aleatorio"
  "󰓅  Modo de rendimiento      $modo|$S/modo.sh ciclar"
  "󰖔  Luz nocturna             $luz|$S/luz.sh alternar"
  "󰂛  No molestar              $nm|$S/notificaciones.sh no-molestar"
  "󰕰  Distribucion ventanas    $dist|$S/distribucion.sh"
  "󰖲  Estilo de la barra       $barra|$S/barra.sh estilo"
  "󰖩  Wifi|$S/wifi.sh"
  "󰂯  Bluetooth|blueman-manager"
  "󰕾  Sonido|pavucontrol"
  "󰍹  Pantallas|$S/monitores.sh"
  "󰉼  Apariencia de apps (GTK)|nwg-look"
  "󰄀  Captura de pantalla|$S/captura.sh menu"
  "󰅌  Portapapeles|$S/portapapeles.sh"
  "󰌌  Ver atajos|$S/atajos.sh"
  "󰑓  Recargar escritorio|hyprctl reload && $S/barra.sh reiniciar"
  "󰐥  Apagar / reiniciar|$S/energia.sh"
)

i=$(printf '%s\n' "${opciones[@]%%|*}" | menu "Centro Parrot" --width 46 --lines ${#opciones[@]} --index) || exit 0
accion=${opciones[$i]#*|}
sleep 0.1
exec bash -c "$accion"
