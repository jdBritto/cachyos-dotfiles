#!/bin/bash
# Conectarse a una red wifi desde un menu (NetworkManager).
source "$(dirname "$0")/comun.sh"
estado=$(nmcli -t -f WIFI radio)
op_radio="󰖪  Apagar wifi"; [[ $estado == enabled ]] || op_radio="󰖩  Encender wifi"
avisar "Wifi" "Buscando redes..." network-wireless
redes=$(nmcli -t -f IN-USE,SIGNAL,SECURITY,SSID device wifi list --rescan yes 2>/dev/null |
  awk -F: '$4 != "" && !visto[$4]++ {
    s = $2+0; i = (s>75) ? "󰤨" : (s>50) ? "󰤥" : (s>25) ? "󰤢" : "󰤟";
    c = ($3 == "" || $3 == "--") ? " " : "󰌾";
    printf "%s %s  %s%s\n", i, c, $4, ($1=="*") ? "  (conectado)" : "" }')
sel=$(printf '%s\n%s\n󰒓  Configuracion avanzada\n' "$redes" "$op_radio" | menu "Wifi" --width 46) || exit 0
case $sel in
  *"Apagar wifi")   nmcli radio wifi off ;;
  *"Encender wifi") nmcli radio wifi on ;;
  *"Configuracion avanzada") nm-connection-editor & ;;
  *)
    ssid=$(sed -E 's/^[^ ]+ [^ ]+  //; s/  \(conectado\)$//' <<< "$sel")
    if nmcli -t -f NAME connection show | grep -Fxq "$ssid"; then
      nmcli connection up id "$ssid" && avisar "Wifi" "Conectado a $ssid" network-wireless
    else
      clave=""
      if [[ $sel == *󰌾* ]]; then
        clave=$(menu "Clave de $ssid" --password --lines 0 < /dev/null) || exit 0
      fi
      if nmcli device wifi connect "$ssid" ${clave:+password "$clave"}; then
        avisar "Wifi" "Conectado a $ssid" network-wireless
      else
        avisar "Wifi" "No se pudo conectar a $ssid" network-wireless-disconnected
      fi
    fi ;;
esac
