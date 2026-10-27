#!/bin/bash
# Restaura tu respaldo personal en CachyOS: Google Drive (rclone) y la VPN.
#
# Uso:  ./restaurar-respaldo.sh [ARCHIVO.tar.gz] [--si] [--forticlient]
#   ARCHIVO        el respaldo (por defecto el mas nuevo ~/respaldo-cachyos-*.tar.gz[.gpg])
#                  Si esta cifrado (.gpg) pide la contrasena.
#   --si           sin preguntas
#   --forticlient  instala tambien FortiClient VPN (AUR) ademas de openfortivpn
#
# El respaldo NO esta en este repositorio: tiene tu sesion de Google Drive.

set -euo pipefail

verde() { printf '\n\033[1;32m==> %s\033[0m\n' "$*"; }
aviso() { printf '\033[1;33m[aviso] %s\033[0m\n' "$*"; }
error() { printf '\033[1;31m[error] %s\033[0m\n' "$*" >&2; exit 1; }

ARCHIVO="" PREGUNTAR=true FORTI=preguntar
for arg in "$@"; do
  case $arg in
    --si) PREGUNTAR=false ;;
    --forticlient) FORTI=si ;;
    -h|--help) sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*) error "Opcion desconocida: $arg" ;;
    *) ARCHIVO=$arg ;;
  esac
done
[[ -t 0 ]] || PREGUNTAR=false
[[ $EUID -ne 0 ]] || error "No lo ejecutes con sudo; ejecutalo como tu usuario normal."

if [[ -z $ARCHIVO ]]; then
  ARCHIVO=$(ls -1 "$HOME"/respaldo-cachyos-*.tar.gz{.gpg,} 2>/dev/null | sort | tail -n1 || true)
fi
[[ -f $ARCHIVO ]] || error "No encuentro el respaldo. Copia respaldo-cachyos-*.tar.gz a tu carpeta personal o pasa la ruta."
echo "Respaldo: $ARCHIVO"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
umask 077
if [[ $ARCHIVO == *.gpg ]]; then
  command -v gpg >/dev/null || sudo pacman -S --needed --noconfirm gnupg
  echo "El respaldo esta cifrado: escribe su contrasena."
  gpg --quiet --decrypt "$ARCHIVO" | tar xz -C "$TMP" || error "No se pudo descifrar (contrasena incorrecta?)."
else
  tar xzf "$ARCHIVO" -C "$TMP"
fi
R="$TMP/respaldo-cachyos"
[[ -d $R ]] || error "El archivo no parece un respaldo valido."
umask 022

# ---------------------------------------------------------------- Google Drive
if [[ -f $R/rclone/rclone.conf ]]; then
  verde "Google Drive (rclone)"
  sudo pacman -S --needed --noconfirm rclone fuse3
  mkdir -p "$HOME/.config/rclone" "$HOME/.config/systemd/user" "$HOME/Drive"
  if [[ -f $HOME/.config/rclone/rclone.conf ]] && ! cmp -s "$R/rclone/rclone.conf" "$HOME/.config/rclone/rclone.conf"; then
    cp -a "$HOME/.config/rclone/rclone.conf" "$HOME/.config/rclone/rclone.conf.antes-$(date +%Y%m%d-%H%M%S)"
  fi
  install -m 600 "$R/rclone/rclone.conf" "$HOME/.config/rclone/rclone.conf"
  install -m 644 "$R/rclone/rclone-gdrive.service" "$HOME/.config/systemd/user/rclone-gdrive.service"
  systemctl --user daemon-reload
  if systemctl --user enable --now rclone-gdrive.service; then
    sleep 3
    if mountpoint -q "$HOME/Drive"; then echo "Google Drive montado en ~/Drive"
    else aviso "El servicio arranco pero ~/Drive aun no esta montado. Mira: journalctl --user -u rclone-gdrive"; fi
  else
    aviso "No se pudo arrancar rclone-gdrive. Mira: journalctl --user -u rclone-gdrive"
  fi
fi

# ---------------------------------------------------------------- VPN
if [[ -f $R/vpn/vpn.conf ]]; then
  verde "VPN del trabajo"
  # shellcheck disable=SC1091
  source "$R/vpn/vpn.conf"
  sudo pacman -S --needed --noconfirm openfortivpn xdg-utils
  mkdir -p "$HOME/.local/bin"
  cat >"$HOME/.local/bin/vpn-trabajo" <<EOF
#!/bin/bash
# $NOMBRE: conecta o desconecta con openfortivpn (inicio de sesion SAML en el navegador).
SERVIDOR="$SERVIDOR"
PUERTO="$PUERTO"
PUERTO_SAML="${PUERTO_SAML:-8020}"
CERT="${CERT_SHA256:-}"

if pgrep -x openfortivpn >/dev/null; then
  read -rp "La VPN esta conectada. Desconectar? [S/n] " r
  [[ \$r =~ ^[nN]\$ ]] || { sudo pkill -INT -x openfortivpn && echo "VPN desconectada."; }
  exit 0
fi
echo "Conectando a $NOMBRE..."
sudo -v || exit 1
echo "Se abre el navegador: inicia sesion y vuelve aqui. (Ctrl + C desconecta)"
( sleep 2; xdg-open "https://\$SERVIDOR:\$PUERTO/remote/saml/start?redirect=1" >/dev/null 2>&1 ) &
exec sudo openfortivpn "\$SERVIDOR:\$PUERTO" --saml-login="\$PUERTO_SAML" \${CERT:+--trusted-cert="\$CERT"}
EOF
  chmod +x "$HOME/.local/bin/vpn-trabajo"
  echo "Listo: ejecuta  vpn-trabajo  (o Super + A > VPN del trabajo)."

  if [[ $FORTI == preguntar ]]; then
    FORTI=no
    if $PREGUNTAR; then
      read -rp "Instalar tambien FortiClient VPN (AUR, con ventana)? [s/N] " r
      [[ $r =~ ^[sS]$ ]] && FORTI=si
    fi
  fi
  if [[ $FORTI == si ]]; then
    if command -v paru >/dev/null && paru -S --needed --noconfirm forticlient-vpn; then
      mkdir -p "$HOME/.config/FortiClient"
      cp -n "$R"/vpn/forticlient-usuario/* "$HOME/.config/FortiClient/" 2>/dev/null || true
      echo "FortiClient instalado. Crea el perfil una vez: Nombre \"$NOMBRE\", gateway $SERVIDOR, puerto $PUERTO, SAML con navegador externo."
    else
      aviso "No se pudo instalar forticlient-vpn desde AUR; usa vpn-trabajo."
    fi
  fi
fi

verde "Respaldo restaurado"
