#!/bin/bash
# Volumen y brillo con aviso en pantalla (barra de progreso).
#   osd.sh subir | bajar | silencio | microfono | brillo+ | brillo-
mostrar() { # mostrar ICONO TITULO VALOR
  notify-send -a osd -u low -i "$1" -h string:x-dunst-stack-tag:osd -h "int:value:$3" "$2" "$3%"
}
vol() { wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf "%d", $2*100}'; }
case $1 in
  subir)    wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+ ;;
  bajar)    wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- ;;
  silencio) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
  microfono)
    wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
    if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED; then
      notify-send -a osd -u low -i microphone-sensitivity-muted -h string:x-dunst-stack-tag:osd "Micrófono" "Silenciado"
    else
      notify-send -a osd -u low -i microphone-sensitivity-high -h string:x-dunst-stack-tag:osd "Micrófono" "Activo"
    fi
    exit 0 ;;
  brillo+)  brightnessctl -e4 -n2 set 5%+ >/dev/null ;;
  brillo-)  brightnessctl -e4 -n2 set 5%- >/dev/null ;;
esac
case $1 in
  brillo*) mostrar display-brightness "Brillo" "$(brightnessctl -m | cut -d, -f4 | tr -d %)" ;;
  *)
    if wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED; then
      notify-send -a osd -u low -i audio-volume-muted -h string:x-dunst-stack-tag:osd -h int:value:0 "Volumen" "Silenciado"
    else
      v=$(vol); i=audio-volume-high; ((v < 66)) && i=audio-volume-medium; ((v < 33)) && i=audio-volume-low
      mostrar "$i" "Volumen" "$v"
    fi ;;
esac
