#!/bin/bash
# Instalacion limpia: illogical-impulse con su ./setup oficial y luego end4-pC segun su README.
# Lo propio de este repo (custom/, scripts/, personal.lua) se aparta en ~/.config/hypr-anterior-<fecha>
# para revisarlo y volver a traerlo por partes.
#
# Uso: extras/instalar-limpio.sh   (en una terminal: el setup pide contrasena y hace preguntas)

set -uo pipefail
FUENTES="$HOME/.local/share/hypr-cachyos/fuentes"
II="$FUENTES/ii"
HYPR="$HOME/.config/hypr"
APARTE="$HOME/.config/hypr-anterior-$(date +%Y%m%d-%H%M)"

verde() { printf '\n\033[1;32m==> %s\033[0m\n' "$*"; }
aviso() { printf '\033[1;33m[aviso] %s\033[0m\n' "$*"; }

[[ -x $II/setup ]] || { echo "No esta $II (ejecuta antes extras/shell.sh)"; exit 1; }
git -C "$II" fetch -q origin && git -C "$II" -c advice.detachedHead=false checkout -q origin/HEAD
echo "illogical-impulse: $(git -C "$II" log -1 --format='%h %cs %s')"

verde "1. Apartando la capa propia en $APARTE"
mkdir -p "$APARTE"
# Primero el hyprland.lua de ii (carga custom/ solo si existe), asi Hyprland no falla al recargar
cp "$HYPR/hyprland.lua" "$APARTE/" && cp "$II/dots/.config/hypr/hyprland.lua" "$HYPR/hyprland.lua"
for p in custom scripts personal.lua monitors.conf workspaces.conf monitors.lua workspaces.lua; do
  [[ -e $HYPR/$p ]] && mv "$HYPR/$p" "$APARTE/"
done
ls "$APARTE"

verde "2. Quitando el quickshell de CachyOS (ii compila el suyo y chocan)"
sudo pacman -Rdd --noconfirm quickshell || true

verde "3. Setup oficial de illogical-impulse (responde a sus preguntas)"
( cd "$II" && ./setup install )
if ! command -v qs >/dev/null; then
  aviso "No se instalo el quickshell de ii: vuelvo a poner el de CachyOS"
  sudo pacman -S --noconfirm quickshell
fi

verde "4. end4-pC (como dice su README)"
rm -rf "$HOME/.config/quickshell/end4-pC"
git clone -q https://github.com/pctrade/end4-pC.git "$HOME/.config/quickshell/end4-pC"
echo "end4-pC: $(git -C "$HOME/.config/quickshell/end4-pC" log -1 --format='%h %cs %s')"
mkdir -p "$HYPR/custom"
cat >> "$HYPR/custom/variables.lua" <<'EOF'

-- end4-pC como interfaz (README de end4-pC)
hl.env("qsConfig", "end4-pC")
EOF
cat >> "$HYPR/custom/keybinds.lua" <<'EOF'

-- Ajustes de end4-pC (README de end4-pC)
hl.bind("SUPER + escape", hl.dsp.global("quickshell:settingsToggle"), {description = "Toggle settings"})
EOF
cat >> "$HYPR/custom/general.lua" <<'EOF'

-- Teclado latinoamericano
hl.config({ input = { kb_layout = "latam" } })
EOF

verde "5. Recargando"
hyprctl reload
killall qs quickshell 2>/dev/null; sleep 1
setsid -f qs -c end4-pC >/dev/null 2>&1
hyprctl configerrors

verde "Listo"
echo "Tu capa anterior quedo en: $APARTE"
echo "La copia de ii de lo que piso esta en: ~/ii-original-dots-backup"
