#!/bin/bash
# Instala la interfaz end4-pC y lo que necesita de illogical-impulse.
# Lo llama install.sh; tambien sirve solo, para actualizar la interfaz.
#
# Uso:  extras/shell.sh                 instala (paquetes incluidos)
#       extras/shell.sh --sin-paquetes  no instala paquetes (install.sh ya lo hizo)
#       extras/shell.sh --simular       muestra lo que haria, sin cambiar nada
#
# - Paquetes: paquetes/shell.txt (oficiales) y paquetes/aur.txt (paru).
# - illogical-impulse (ii) y end4-pC se clonan en commits fijados (abajo).
#   Para subir de version: cambia el commit, prueba y sube el cambio.
# - De ii solo se copia lo que hace falta: hypr/hyprland, hyprlock, matugen, Kvantum,
#   kde-material-you-colors, fuzzel, kitty y wlogout.
#   NUNCA se usa su ./setup install: borraria tu ~/.config/hypr.
# - Fuente Google Sans Flex, entorno de Python (uv), grupos video,i2c,input,
#   modulo i2c-dev y servicio ydotool.
#
# Es seguro ejecutarlo mas de una vez. Lo que se sobrescribe se guarda antes en
# ~/.config-respaldo-<fecha>.

set -euo pipefail

II_URL=https://github.com/end-4/dots-hyprland.git
II_COMMIT=2f2a376f
PC_URL=https://github.com/pctrade/end4-pC.git
PC_COMMIT=74813a8
FUENTE_URL=https://github.com/end-4/google-sans-flex.git

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FUENTES="$HOME/.local/share/hypr-cachyos/fuentes"
VENV="$HOME/.local/state/quickshell/.venv"
RESPALDO="${RESPALDO:-$HOME/.config-respaldo-$(date +%Y%m%d-%H%M%S)}"

verde() { printf '\n\033[1;32m==> %s\033[0m\n' "$*"; }
aviso() { printf '\033[1;33m[aviso] %s\033[0m\n' "$*"; }
error() { printf '\033[1;31m[error] %s\033[0m\n' "$*" >&2; exit 1; }

SIMULAR=false PAQUETES=true
for arg in "$@"; do
  case $arg in
    --simular) SIMULAR=true ;;
    --sin-paquetes) PAQUETES=false ;;
    -h|--help) sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) error "Opcion desconocida: $arg" ;;
  esac
done
[[ $EUID -ne 0 ]] || error "No lo ejecutes con sudo; ejecutalo como tu usuario normal."

hacer() { if $SIMULAR; then printf '\033[2m  [simular] %s\033[0m\n' "$*"; else "$@"; fi; }
leer_lista() { grep -vE '^\s*(#|$)' "$REPO/paquetes/$1.txt"; }

# Clona URL en DESTINO y deja el commit fijado (si ya existe, solo cambia de commit)
fijar() {
  local url=$1 destino=$2 commit=$3
  if [[ ! -d $destino/.git ]]; then
    hacer git clone --filter=blob:none --quiet "$url" "$destino"
  else
    hacer git -C "$destino" fetch --quiet origin
  fi
  hacer git -C "$destino" -c advice.detachedHead=false checkout --quiet "$commit"
  $SIMULAR || echo "  $(basename "$destino"): $(git -C "$destino" log -1 --format='%h %cs %s')"
}

# Guarda una copia de RUTA (dentro de $HOME) en $RESPALDO si existe
respaldar() {
  local rel=${1#"$HOME"/}
  [[ -e $1 ]] || return 0
  mkdir -p "$(dirname "$RESPALDO/$rel")"
  cp -a "$1" "$RESPALDO/$rel"
}

# Copia la carpeta ORIGEN en DESTINO (que queda igual que ORIGEN)
copiar_dir() {
  local origen=$1 destino=$2
  if $SIMULAR; then printf '\033[2m  [simular] copiar %s\033[0m\n' "${destino#"$HOME"/}"; return; fi
  if [[ -d $destino ]] && ! diff -rq --exclude=.git "$origen" "$destino" >/dev/null 2>&1; then respaldar "$destino"; fi
  mkdir -p "$destino"
  rsync -a --delete --exclude=.git "$origen"/ "$destino"/
}

# Copia un archivo
copiar_archivo() {
  local origen=$1 destino=$2
  if $SIMULAR; then printf '\033[2m  [simular] copiar %s\033[0m\n' "${destino#"$HOME"/}"; return; fi
  if [[ -f $destino ]] && ! cmp -s "$origen" "$destino"; then respaldar "$destino"; fi
  mkdir -p "$(dirname "$destino")"
  cp -a "$origen" "$destino"
}

$SIMULAR || sudo -v || error "Hace falta tu contrasena de administrador."

# ---------------------------------------------------------------- paquetes
if $PAQUETES; then
  verde "Paquetes de la interfaz"
  mapfile -t PAQ < <(leer_lista shell)
  hacer sudo pacman -S --needed --noconfirm "${PAQ[@]}" || error "No se pudieron instalar los paquetes."
  if command -v paru >/dev/null || $SIMULAR; then
    mapfile -t AUR < <(leer_lista aur)
    hacer paru -S --needed --noconfirm "${AUR[@]}" || aviso "Faltan fuentes o temas de AUR; reintenta: paru -S \$(grep -v '^#' $REPO/paquetes/aur.txt)"
  else
    aviso "No esta paru: no se instalaron las fuentes y temas de AUR (ejecuta antes install.sh)."
  fi
fi

# ---------------------------------------------------------------- fuentes fijadas
verde "Descargando illogical-impulse y end4-pC (commits fijados)"
hacer mkdir -p "$FUENTES"
fijar "$II_URL" "$FUENTES/ii" "$II_COMMIT"
fijar "$PC_URL" "$FUENTES/end4-pC" "$PC_COMMIT"

# ---------------------------------------------------------------- archivos
verde "Copiando la interfaz y la configuracion de ii"
II=$FUENTES/ii/dots/.config
copiar_dir "$FUENTES/end4-pC" "$HOME/.config/quickshell/end4-pC"
# De ~/.config/hypr solo estas partes de ii: lo propio (custom/, scripts/, personal.lua) no se toca
copiar_dir "$II/hypr/hyprland" "$HOME/.config/hypr/hyprland"
copiar_dir "$II/hypr/hyprlock" "$HOME/.config/hypr/hyprlock"
copiar_archivo "$II/hypr/hyprlock.conf" "$HOME/.config/hypr/hyprlock.conf"
copiar_archivo "$II/hypr/hyprland.lua" "$HOME/.config/hypr/hyprland.lua"
for app in matugen Kvantum kde-material-you-colors fuzzel kitty wlogout; do
  copiar_dir "$II/$app" "$HOME/.config/$app"
done
$SIMULAR || {
# kitty: ii reemplaza ~/.config/kitty; lo propio (zsh, paneles) se engancha al final
grep -qs kitty-propio "$HOME/.config/kitty/kitty.conf" ||
  printf '\n# Lo propio (fuera de esta carpeta, que ii reemplaza al actualizar)\ninclude ~/.config/kitty-propio/propio.conf\n' >> "$HOME/.config/kitty/kitty.conf"
}
# ii arranca este script al iniciar; lo rellena end4-pC si pones un video de fondo
VIDEO=$HOME/.config/hypr/custom/scripts/__restore_video_wallpaper.sh
[[ -f $VIDEO ]] || copiar_archivo "$FUENTES/ii/dots/.config/hypr/custom/scripts/${VIDEO##*/}" "$VIDEO"
# Foto de usuario de la interfaz: la de la cuenta (AccountsService), si hay
if [[ ! -e $HOME/.face && -r /var/lib/AccountsService/icons/$USER ]]; then
  hacer cp "/var/lib/AccountsService/icons/$USER" "$HOME/.face"
fi
# Si ya habia ajustes de end4-pC, sus tiempos de inactividad vuelven a hypridle.conf
hacer "$HOME/.config/hypr/scripts/ajustes-end4.py" reaplicar || true
[[ -d $RESPALDO ]] && echo "Copia de lo anterior: $RESPALDO"

verde "Fuente Google Sans Flex"
if fc-list 2>/dev/null | grep -qi "Google Sans Flex"; then
  echo "Ya esta instalada."
else
  fijar "$FUENTE_URL" "$FUENTES/google-sans-flex" origin/main
  copiar_dir "$FUENTES/google-sans-flex" "$HOME/.local/share/fonts/google-sans-flex"
  hacer fc-cache -f
fi
hacer gsettings set org.gnome.desktop.interface font-name 'Google Sans Flex Medium 11 @opsz=11,wght=500'
hacer gsettings set org.gnome.desktop.interface color-scheme prefer-dark

# ---------------------------------------------------------------- python
verde "Entorno de Python ($VENV)"
hacer mkdir -p "$VENV"
hacer env UV_NO_MODIFY_PATH=1 uv venv --allow-existing --prompt .venv -p 3.12 "$VENV"
hacer env VIRTUAL_ENV="$VENV" uv pip install --quiet -r "$FUENTES/ii/sdata/uv/requirements.txt" ||
  aviso "No se pudo instalar todo el entorno de Python."

# ---------------------------------------------------------------- sistema
verde "Grupos, i2c y ydotool"
getent group i2c >/dev/null || hacer sudo groupadd i2c
hacer sudo usermod -aG video,i2c,input "$USER"
hacer sudo sh -c "echo i2c-dev > /etc/modules-load.d/i2c-dev.conf"
hacer sudo modprobe i2c-dev || true
# ydotool (teclado en pantalla, pegar desde el portapapeles) necesita /dev/uinput: en
# CachyOS solo lo abre root, asi que se le da al grupo input
hacer sudo sh -c 'echo "KERNEL==\"uinput\", GROUP=\"input\", MODE=\"0660\", OPTIONS+=\"static_node=uinput\"" > /etc/udev/rules.d/99-uinput.rules'
hacer sudo udevadm control --reload-rules
hacer sudo sh -c "chgrp input /dev/uinput && chmod 660 /dev/uinput"   # ya, sin reiniciar
hacer systemctl --user enable ydotool.service
if id -nG | grep -qw input; then
  hacer systemctl --user restart ydotool.service || aviso "No se pudo arrancar ydotool."
else
  echo "ydotool arrancara al volver a iniciar sesion (grupo input nuevo)."
fi

verde "Interfaz end4-pC lista"
echo "Los grupos nuevos (video, i2c, input) valen desde el proximo inicio de sesion."
