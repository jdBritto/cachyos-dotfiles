#!/bin/bash
# Instala Hyprland con la interfaz end4-pC en CachyOS.
# Al empezar muestra un menu de extras (flechas y Espacio).
#
# Uso:  ./install.sh            (pregunta)
#       ./install.sh --si       (sin preguntas: lo recomendado)
#       ./install.sh --simular  (muestra lo que haria, sin instalar ni copiar nada)
#       ./install.sh --con=bateria --sin=apps
#                               (marca o desmarca extras sin el menu: apps, herramientas,
#                                respaldo, bateria)
#
# Es seguro ejecutarlo mas de una vez. Antes de sobrescribir guarda una copia
# de tus archivos en ~/.config-respaldo-<fecha>.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESPALDO="$HOME/.config-respaldo-$(date +%Y%m%d-%H%M%S)"
export RESPALDO   # extras/shell.sh guarda en la misma carpeta

verde() { printf '\n\033[1;32m==> %s\033[0m\n' "$*"; }
AVISOS=()
aviso() { printf '\033[1;33m[aviso] %s\033[0m\n' "$*"; AVISOS+=("$*"); }
error() { printf '\033[1;31m[error] %s\033[0m\n' "$*" >&2; exit 1; }

# ---------------------------------------------------------------- opciones
PREGUNTAR=true
SIMULAR=false
CON="" SIN=""
for arg in "$@"; do
  case "$arg" in
    --si)       PREGUNTAR=false ;;
    --simular)  SIMULAR=true ;;
    --con=*)    CON+=",${arg#--con=}" ;;
    --sin=*)    SIN+=",${arg#--sin=}" ;;
    -h|--help)  sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *)          error "Opcion desconocida: $arg (mira: ./install.sh --help)" ;;
  esac
done
[[ -t 0 ]] || PREGUNTAR=false

# En modo simular, las ordenes que cambian el sistema solo se muestran.
hacer() {
  if $SIMULAR; then printf '\033[2m  [simular] %s\033[0m\n' "$*"; else "$@"; fi
}
pac() { hacer sudo pacman --noconfirm "$@"; }

# ---------------------------------------------------------------- comprobaciones
[[ $EUID -ne 0 ]] || error "No lo ejecutes con sudo; ejecutalo como tu usuario normal."
. /etc/os-release
if ! $SIMULAR; then
  [[ $ID == cachyos || $ID == arch || ${ID_LIKE:-} == *arch* ]] ||
    error "Este instalador es para CachyOS (este sistema: ${PRETTY_NAME:-desconocido})."
  command -v pacman >/dev/null || error "No encuentro pacman."
fi

BATERIA=$(ls -d /sys/class/power_supply/BAT*/ 2>/dev/null | head -n1)
UMBRAL=false
if [[ -n $BATERIA && -e ${BATERIA}charge_control_end_threshold ]]; then UMBRAL=true; fi

echo "Sistema: ${PRETTY_NAME:-desconocido}"
echo "Equipo: $(cat /sys/class/dmi/id/sys_vendor 2>/dev/null) $(cat /sys/class/dmi/id/product_version 2>/dev/null)"

# ---------------------------------------------------------------- logo
logo() {
  local colores=(43 44 45 51 50 49) i=0 linea
  while IFS= read -r linea; do
    printf '\033[1;38;5;%sm%s\033[0m\n' "${colores[i % ${#colores[@]}]}" "$linea"
    i=$((i + 1))
  done <<'LOGO'

   ██████╗ █████╗  ██████╗██╗  ██╗██╗   ██╗ ██████╗ ███████╗
  ██╔════╝██╔══██╗██╔════╝██║  ██║╚██╗ ██╔╝██╔═══██╗██╔════╝
  ██║     ███████║██║     ███████║ ╚████╔╝ ██║   ██║███████╗
  ██║     ██╔══██║██║     ██╔══██║  ╚██╔╝  ██║   ██║╚════██║
  ╚██████╗██║  ██║╚██████╗██║  ██║   ██║   ╚██████╔╝███████║
   ╚═════╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚══════╝
LOGO
  printf '\033[2m  Hyprland + end4-pC para %s\033[0m\n\n' "${PRETTY_NAME:-CachyOS}"
}

# ---------------------------------------------------------------- que instalar
# Hyprland y la interfaz end4-pC siempre se instalan; aqui se eligen los extras.
declare -a IDS=()
declare -A NOMBRE DESC MARCA
agregar() { IDS+=("$1"); NOMBRE[$1]=$2; DESC[$1]=$3; MARCA[$1]=$4; }

agregar apps "Firefox y firmware" "Firefox y fwupd, para actualizar la BIOS y el firmware de Lenovo desde Linux (fwupdmgr update)." si
agregar herramientas "Herramientas de desarrollo" "mise con claude, codex, gh, node y opencode (~/.config/mise/config.toml)." si
RESPALDO_PERSONAL=$(ls -1 "$HOME"/respaldo-cachyos-*.tar.gz{.gpg,} "$REPO"/../respaldo-cachyos-*.tar.gz{.gpg,} 2>/dev/null | sort | tail -n1 || true)
# Si ya se restauro antes (rclone y vpn-trabajo existen), viene desmarcado
YA_RESTAURADO=si
[[ -f $HOME/.config/rclone/rclone.conf && -x $HOME/.local/bin/vpn-trabajo ]] && YA_RESTAURADO=no
[[ -n $RESPALDO_PERSONAL ]] && agregar respaldo "Restaurar Google Drive y VPN" "Usa tu respaldo ($(basename "$RESPALDO_PERSONAL")): monta Google Drive en ~/Drive con rclone y crea vpn-trabajo (openfortivpn con SAML)." $YA_RESTAURADO
$UMBRAL && agregar bateria "Cuidar la bateria (hasta 80%)" "La bateria deja de cargar al 80%: dura mas anos si el portatil pasa enchufado. Para cargar al 100% una vez: bateria-completa" no

quiere() { [[ ${MARCA[$1]:-no} == si ]]; }

# --con / --sin cambian lo que viene marcado (antes del menu)
IFS=, read -ra lista <<<"${CON#,}"
for id in "${lista[@]}"; do [[ -n ${NOMBRE[$id]:-} ]] && MARCA[$id]=si || aviso "Extra no disponible: $id"; done
IFS=, read -ra lista <<<"${SIN#,}"
for id in "${lista[@]}"; do [[ -n ${NOMBRE[$id]:-} ]] && MARCA[$id]=no || aviso "Extra no disponible: $id"; done
cambiar() { if quiere "$1"; then MARCA[$1]=no; else MARCA[$1]=si; fi; }

leer_tecla() {  # deja en TECLA la tecla pulsada; las flechas llegan como Esc + [A / [B
  local resto
  IFS= read -rsn1 TECLA || exit 1
  if [[ $TECLA == $'\e' ]]; then
    IFS= read -rsn2 -t 0.1 resto || true
    TECLA+=$resto
  fi
}

# Menu con flechas: se mueve con arriba/abajo (o j/k), Espacio marca o desmarca.
menu() {
  local actual=0 total=${#IDS[@]} i id marca
  printf '\033[?25l'
  trap 'printf "\033[?25h"' EXIT
  while true; do
    printf '\033[H\033[2J'
    logo
    printf '  \033[1mSE INSTALA\033[0m\n    \033[1;32m[x]\033[0m Hyprland con la interfaz end4-pC (barra, menus, colores del fondo, modo de energia)\n'
    printf '\n  \033[1mEXTRAS\033[0m\n'
    for i in "${!IDS[@]}"; do
      id=${IDS[i]}
      if quiere "$id"; then marca='\033[1;32m[x]\033[0m'; else marca='\033[2m[ ]\033[0m'; fi
      if ((i == actual)); then
        printf '  \033[1;36m❯\033[0m %b \033[1;36m%s\033[0m\n' "$marca" "${NOMBRE[$id]}"
      else
        printf '    %b %s\n' "$marca" "${NOMBRE[$id]}"
      fi
    done
    printf '\n  \033[3m%s\033[0m\n' "${DESC[${IDS[actual]}]}"
    printf '\n  \033[2m↑↓ moverse   Espacio marcar   a todo   n nada   Enter continuar   q salir\033[0m\n'
    leer_tecla
    case $TECLA in
      $'\e[A' | k) actual=$(((actual - 1 + total) % total)) ;;
      $'\e[B' | j) actual=$(((actual + 1) % total)) ;;
      ' ') cambiar "${IDS[actual]}" ;;
      [1-9]) if ((TECLA <= total)); then actual=$((TECLA - 1)); cambiar "${IDS[actual]}"; fi ;;
      a | A) for id in "${IDS[@]}"; do MARCA[$id]=si; done ;;
      n | N) for id in "${IDS[@]}"; do MARCA[$id]=no; done ;;
      '') break ;;
      q | Q) printf '\033[?25h\033[H\033[2J'; echo "Cancelado. No se cambio nada."; exit 0 ;;
    esac
  done
  printf '\033[?25h\033[H\033[2J'
  logo
}

if $PREGUNTAR; then menu; else logo; fi

resumen() { local id; for id in "${IDS[@]}"; do quiere "$id" && printf '%s, ' "${NOMBRE[$id]}"; done; return 0; }
LISTA=$(resumen)
echo "Se va a instalar: Hyprland + end4-pC${LISTA:+, ${LISTA%, }}"
if $PREGUNTAR; then
  read -rp "Continuar? [S/n] " r
  [[ $r =~ ^[nN]$ ]] && { echo "Cancelado. No se cambio nada."; exit 0; }
fi
$SIMULAR || sudo -v || error "Hace falta tu contrasena de administrador."

# ---------------------------------------------------------------- registro
LOG="$HOME/.cache/hypr-cachyos/install-$(date +%Y%m%d-%H%M%S).log"
if ! $SIMULAR; then
  mkdir -p "$(dirname "$LOG")"
  ln -sfn "$LOG" "$HOME/.cache/hypr-cachyos/ultimo.log"
  exec > >(tee -a "$LOG") 2>&1
  echo "Registro de la instalacion: $LOG"
fi
al_salir() {
  local codigo=$?
  printf '\033[?25h'
  ((codigo == 0)) || printf '\n\033[1;31mLa instalacion se detuvo (codigo %s).\033[0m\nRevisa: %s\n' "$codigo" "$LOG"
}
trap al_salir EXIT

leer_lista() { grep -vE '^\s*(#|$)' "$REPO/paquetes/$1.txt"; }

# ---------------------------------------------------------------- paquetes
verde "Actualizando el sistema e instalando paquetes"
mapfile -t PAQUETES < <(leer_lista hyprland)
mapfile -t -O "${#PAQUETES[@]}" PAQUETES < <(leer_lista shell)
quiere apps && mapfile -t -O "${#PAQUETES[@]}" PAQUETES < <(leer_lista apps)
quiere herramientas && mapfile -t -O "${#PAQUETES[@]}" PAQUETES < <(leer_lista herramientas)

# CachyOS puede traer tuned-ppd, que ya hace de power-profiles-daemon (chocan)
if pacman -Q tuned-ppd &>/dev/null; then
  mapfile -t PAQUETES < <(printf '%s\n' "${PAQUETES[@]}" | grep -vx power-profiles-daemon)
  echo "tuned-ppd ya esta instalado: se usa en lugar de power-profiles-daemon."
fi
# En Arch siempre se actualiza todo junto (-Syu) para no mezclar versiones
pac -Syu --needed "${PAQUETES[@]}" || error "No se pudieron instalar los paquetes."

# AUR: paru viene en los repositorios de CachyOS; en Arch se compila
verde "Paquetes de AUR (fuentes y temas de la interfaz)"
if ! command -v paru >/dev/null; then
  if $SIMULAR || pacman -Si paru &>/dev/null; then
    pac -S --needed paru || aviso "No se pudo instalar paru."
  else
    pac -S --needed base-devel git
    TMP=$(mktemp -d)
    hacer git clone --depth 1 https://aur.archlinux.org/paru-bin.git "$TMP/paru-bin" &&
      (cd "$TMP/paru-bin" && hacer makepkg -si --noconfirm) || aviso "No se pudo compilar paru."
    rm -rf "$TMP"
  fi
fi
if command -v paru >/dev/null || $SIMULAR; then
  mapfile -t AUR < <(leer_lista aur)
  hacer paru -S --needed --noconfirm "${AUR[@]}" ||
    aviso "Faltan fuentes o temas de AUR; reintenta: paru -S \$(grep -v '^#' $REPO/paquetes/aur.txt)"
fi

# ---------------------------------------------------------------- archivos
copiar() { # copiar RUTA...: copia esas rutas de home/ a $HOME, respaldando lo que ya exista
  local ruta f rel destino
  for ruta in "$@"; do
    [[ -e $REPO/home/$ruta ]] || continue
    while IFS= read -r -d '' f; do
      rel=${f#"$REPO/home"/}
      destino="$HOME/$rel"
      if $SIMULAR; then printf '\033[2m  [simular] copiar %s\033[0m\n' "$rel"; continue; fi
      if [[ -e $destino ]] && ! cmp -s "$f" "$destino"; then
        mkdir -p "$(dirname "$RESPALDO/$rel")"
        cp -a "$destino" "$RESPALDO/$rel"
      fi
      mkdir -p "$(dirname "$destino")"
      cp -a "$f" "$destino"
    done < <(find "$REPO/home/$ruta" -type f -print0)
  done
}
apartar() { # apartar RUTA: mueve un archivo o carpeta de $HOME a la copia de respaldo
  [[ -e $HOME/$1 ]] || return 0
  if $SIMULAR; then printf '\033[2m  [simular] apartar %s\033[0m\n' "$1"; return; fi
  mkdir -p "$(dirname "$RESPALDO/$1")"
  mv "$HOME/$1" "$RESPALDO/$1"
}

verde "Copiando la configuracion"
# Lo que trae CachyOS (hyprland.conf o config/) y lo de versiones anteriores de este
# repositorio (Hyprland Parrot: temas, waybar, fondos...) se aparta a la copia de respaldo
apartar .config/hypr/hyprland.conf
apartar .config/hypr/config
for viejo in parrot temas plantillas waybar iconos generado; do apartar ".config/hypr/$viejo"; done
for s in atajos barra captura energia escritorios fondo lanzador luz navegador notificaciones \
         osd portapapeles tema temperatura terminal ventanas wifi; do
  apartar ".config/hypr/scripts/$s.sh"
done
apartar .local/share/backgrounds/parrot
apartar .config/systemd/user/hyprpolkitagent.service.d   # end4-pC trae su agente polkit
copiar .config/hypr/hyprland.lua .config/hypr/custom .config/hypr/scripts .config/hypr/hypridle.conf \
  .local/share/icons/WhiteSur-cursors
quiere herramientas && copiar .config/mise
if ! $SIMULAR; then
  # personal.lua es tuyo: solo se copia la primera vez
  [[ -f $HOME/.config/hypr/personal.lua ]] || cp "$REPO/home/.config/hypr/personal.lua" "$HOME/.config/hypr/"
  chmod +x "$HOME"/.config/hypr/scripts/*.sh
  xdg-user-dirs-update 2>/dev/null || true
fi

# ---------------------------------------------------------------- interfaz end4-pC
verde "Interfaz end4-pC"
args=(--sin-paquetes); $SIMULAR && args+=(--simular)
"$REPO/extras/shell.sh" "${args[@]}" || error "No se pudo instalar la interfaz end4-pC."
[[ -d $RESPALDO ]] && echo "Copia de tus archivos anteriores: $RESPALDO"

# ---------------------------------------------------------------- apariencia de las apps
verde "Apariencia de las apps (GTK)"
gs() { hacer gsettings set org.gnome.desktop.interface "$@" 2>/dev/null || true; }
gs gtk-theme adw-gtk3-dark        # end4-pC le pone los colores del fondo (matugen)
gs icon-theme Papirus-Dark
gs cursor-theme WhiteSur-cursors
gs cursor-size 24
gs monospace-font-name "JetBrainsMono Nerd Font 10"

# ---------------------------------------------------------------- herramientas (mise)
if quiere herramientas; then
  verde "Herramientas de desarrollo (mise)"
  hacer env MISE_MINIMUM_RELEASE_AGE=0 mise install --yes || aviso "mise no pudo instalar todo; reintenta luego con: mise install"
  if ! $SIMULAR; then
    for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
      [[ -f $rc ]] || continue
      sh=$(basename "$rc" rc); sh=${sh#.}
      grep -q 'mise activate' "$rc" || echo "eval \"\$(mise activate $sh)\"" >>"$rc"
    done
    # CachyOS usa fish por defecto
    FISH="$HOME/.config/fish/config.fish"
    if command -v fish >/dev/null; then
      mkdir -p "$(dirname "$FISH")"; touch "$FISH"
      grep -q 'mise activate' "$FISH" || echo 'mise activate fish | source' >>"$FISH"
    fi
  fi
fi

# ---------------------------------------------------------------- bateria
if quiere bateria; then
  verde "Cuidar la bateria: cargar hasta 80%"
  BAT=$(basename "$BATERIA")
  BAT=${BAT%/}
  hacer sudo tee /etc/systemd/system/bateria-80.service >/dev/null <<EOF
[Unit]
Description=La bateria deja de cargar al 80% (dura mas)
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/bin/sh -c 'echo 75 > /sys/class/power_supply/$BAT/charge_control_start_threshold 2>/dev/null; echo 80 > /sys/class/power_supply/$BAT/charge_control_end_threshold'

[Install]
WantedBy=multi-user.target
EOF
  hacer sudo tee /usr/local/bin/bateria-completa >/dev/null <<EOF
#!/bin/sh
# Carga la bateria al 100% esta vez (al reiniciar vuelve al 80%).
echo 100 | sudo tee /sys/class/power_supply/$BAT/charge_control_end_threshold >/dev/null && echo "Cargando hasta 100% hasta el proximo reinicio."
EOF
  hacer sudo chmod +x /usr/local/bin/bateria-completa
  hacer sudo systemctl daemon-reload
  hacer sudo systemctl enable --now bateria-80.service || aviso "No se pudo activar el limite de carga."
fi

# ---------------------------------------------------------------- respaldo personal
if quiere respaldo; then
  verde "Restaurando tu respaldo personal"
  args=("$RESPALDO_PERSONAL"); $PREGUNTAR || args+=(--si)
  hacer "$REPO/restaurar-respaldo.sh" "${args[@]}" || aviso "No se pudo restaurar todo el respaldo; reintenta con: $REPO/restaurar-respaldo.sh"
fi

# ---------------------------------------------------------------- servicios
verde "Activando servicios"
hacer sudo systemctl enable --now NetworkManager.service || true
hacer sudo systemctl enable --now bluetooth.service 2>/dev/null || true
pacman -Q power-profiles-daemon &>/dev/null && { hacer sudo systemctl enable --now power-profiles-daemon.service || true; }
hacer systemctl --user daemon-reload 2>/dev/null || true

# Pantalla de inicio: si no hay ninguna, SDDM; y que proponga Hyprland
if ! systemctl is-enabled display-manager.service &>/dev/null; then
  pac -S --needed sddm && hacer sudo systemctl enable sddm.service || aviso "No se pudo activar SDDM."
fi
if [[ $(readlink -f /etc/systemd/system/display-manager.service 2>/dev/null) == *sddm* ]]; then
  hacer sudo mkdir -p /var/lib/sddm
  if ! $SIMULAR; then
    printf '[Last]\nSession=/usr/share/wayland-sessions/hyprland.desktop\nUser=%s\n' "$USER" |
      sudo tee /var/lib/sddm/state.conf >/dev/null
    sudo chown sddm:sddm /var/lib/sddm/state.conf 2>/dev/null || true
  fi
  echo "La pantalla de inicio propondra Hyprland."
fi

# ---------------------------------------------------------------- listo
verde "Listo"
echo "Reinicia y entra en la sesion \"Hyprland\" (no la de UWSM) de la pantalla de inicio."
echo
echo "  Super (solo)     buscar aplicaciones"
echo "  Super + /        ver todos los atajos"
echo "  Super + I        Centro: modo de energia, ventanas, VPN, pantallas"
echo "  Super + Escape   ajustes de end4-pC (colores, barra, fondo...)"
echo "  Ctrl + Super + T elegir fondo (los colores salen de el)"
quiere apps && echo "  Firmware de Lenovo:  fwupdmgr refresh && fwupdmgr update"
quiere bateria && echo "  Bateria al 100% una vez:  bateria-completa"
quiere respaldo && echo "  VPN del trabajo:  vpn-trabajo      Google Drive:  ~/Drive"
echo
echo "Tus cambios van en ~/.config/hypr/personal.lua (nunca se sobrescribe)."
if ((${#AVISOS[@]})); then
  printf '\n\033[1;33mHubo %d aviso(s):\033[0m\n' "${#AVISOS[@]}"
  printf '  - %s\n' "${AVISOS[@]}"
fi
$SIMULAR || echo "Registro completo: $LOG"
