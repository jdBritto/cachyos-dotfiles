#!/bin/bash
# Temas de Hyprland Parrot. Un tema (temas/<id>.tema) define los colores y el
# fondo; este script los lleva a Hyprland, la barra, el lanzador, las
# notificaciones, la terminal, el bloqueo y el menu de apagado, al instante.
#
#   tema.sh menu          elegir con un menu
#   tema.sh aplicar ID    aplicar un tema (parrot, lorikeet, claro...)
#   tema.sh siguiente     pasar al siguiente tema
#   tema.sh inicio        al iniciar la sesion
#   tema.sh lista         ver los temas
#   tema.sh generar [ID]  solo crear los archivos de colores

source "$(dirname "$0")/comun.sh"

generar() { # generar ID: crea los archivos de colores en generado/
  local id=$1
  cargar_tema "$id" || { echo "No existe el tema: $id" >&2; return 1; }
  local fondo_elegido
  fondo_elegido=$(cat "$GEN/fondo-$id" 2>/dev/null)
  if [[ -f $fondo_elegido ]]; then fondo=$fondo_elegido; else fondo=$(ruta_fondo "$fondo"); fi
  local iconos; iconos=$(tema_iconos)

  # Sustituye {{clave}} por su valor en cada plantilla
  local sedargs=(-e "s|{{id}}|$id|g" -e "s|{{gen}}|$GEN|g" -e "s|{{dir}}|$HYPR|g" -e "s|{{fondo}}|$fondo|g" -e "s|{{iconos}}|$iconos|g")
  local k
  for k in bg bg_alt superficie borde fg fg_dim acento acento2 urgente aviso c{0..15}; do
    sedargs+=(-e "s|{{$k}}|${!k}|g")
  done
  local p
  for p in "$HYPR"/plantillas/*; do
    sed "${sedargs[@]}" "$p" > "$GEN/$(basename "$p").tmp" && mv "$GEN/$(basename "$p").tmp" "$GEN/$(basename "$p")"
  done

  # Iconos del menu de apagado con el color del tema
  mkdir -p "$GEN/wlogout"
  local n
  for n in lock logout suspend reboot shutdown; do
    sed "s|<svg |<svg fill=\"#$fg\" |" "/usr/share/wlogout/assets/$n.svg" > "$GEN/wlogout/$n.svg"
    sed "s|<svg |<svg fill=\"#$acento\" |" "/usr/share/wlogout/assets/$n.svg" > "$GEN/wlogout/$n-acento.svg"
  done

  # Logo de Parrot para la barra, con el color de acento
  sed "s/#232629/#$acento/" "$HYPR/iconos/parrot.svg" > "$GEN/parrot-logo.svg"

  echo "$id" > "$GEN/tema"
  echo "$fondo" > "$GEN/fondo-actual"
}

aplicar_apps() { # recarga lo que ya esta abierto
  "$SCRIPTS/fondo.sh" poner "$(cat "$GEN/fondo-actual")" --sin-guardar
  esquema_gtk "$modo"
  hyprctl reload >/dev/null
  "$SCRIPTS/barra.sh" reiniciar
  pkill -x dunst; (dunst -conf "$GEN/dunstrc" &>/dev/null &)
  pkill -USR2 -x ghostty 2>/dev/null # las terminales abiertas recargan colores
}

case "${1:-menu}" in
  aplicar)
    [[ -n ${2:-} ]] || { echo "Uso: tema.sh aplicar ID" >&2; exit 1; }
    generar "$2" || exit 1
    aplicar_apps
    sleep 0.3
    avisar "Tema: $nombre" "$descripcion" preferences-desktop-theme
    ;;
  inicio)
    # Si falta algo (primera vez), se genera; luego fondo, barra y notificaciones
    id=$(tema_actual)
    [[ -f $GEN/fuzzel.ini && -f $GEN/ghostty.conf ]] || generar "$id"
    cargar_tema "$id"
    esquema_gtk "$modo"
    "$SCRIPTS/fondo.sh" poner "$(cat "$GEN/fondo-actual")" --sin-guardar
    "$SCRIPTS/barra.sh" reiniciar
    pkill -x dunst; (dunst -conf "$GEN/dunstrc" &>/dev/null &)
    ;;
  generar) generar "${2:-$(tema_actual)}" ;;
  siguiente)
    mapfile -t ids < <(ls "$TEMAS" | sed 's/\.tema$//')
    actual=$(tema_actual)
    for i in "${!ids[@]}"; do [[ ${ids[i]} == "$actual" ]] && break; done
    exec "$0" aplicar "${ids[$(( (i + 1) % ${#ids[@]} ))]}"
    ;;
  lista)
    for f in "$TEMAS"/*.tema; do
      ( source "$f"; printf '%-12s %s\n' "$(basename "$f" .tema)" "$descripcion" )
    done
    ;;
  menu)
    actual=$(tema_actual)
    # Cada linea: miniatura del fondo + nombre + descripcion
    mkdir -p "$GEN/miniaturas"
    filas() {
      local f id mini marca
      for f in "$TEMAS"/*.tema; do
        id=$(basename "$f" .tema)
        eval "$(grep -E '^(nombre|descripcion|fondo)=' "$f")"
        mini="$GEN/miniaturas/tema-$id-v2.png"
        miniatura "$(ruta_fondo "$fondo")" "$mini"
        marca=""; [[ $id == "$actual" ]] && marca="  (actual)"
        printf '%s — %s%s\0icon\x1f%s\n' "$nombre" "$descripcion" "$marca" "$mini"
      done
    }
    elegido=$(filas | menu "Tema" --width 52 --line-height 54 --lines 7 --index) || exit 0
    ids=( $(ls "$TEMAS" | sed 's/\.tema$//') )
    exec "$0" aplicar "${ids[$elegido]}"
    ;;
  *) sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//' ;;
esac
