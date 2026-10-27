# Contexto para Claude Code (retomar en CachyOS)

Responder siempre en **español**, con mensajes cortos y sencillos.

## Quién y qué
- Equipo de trabajo: Lenovo ThinkPad E14 Gen 4 (AMD) con **CachyOS nativo** (instalado 2026-10-27).
  Antes usaba Parrot OS, donde se creó este repo. En casa usa Omarchy.
- Este repo instala Hyprland (config en **Lua**) en CachyOS: `install.sh` (menú de extras,
  `--simular`, `--si`), `paquetes/*.txt`, configuración en `home/`, `actualizar.sh` sube los cambios.
- Validar la config: `Hyprland --verify-config -c ~/.config/hypr/hyprland.lua`.
  En Lua: `hyprctl dispatch 'hl.dsp...'`; `hyprctl keyword` ya no existe, usar `hyprctl eval`.
  Las teclas `code:NN` no funcionan en Lua: usar nombres (bar, grave, masculine).

## Trabajo en curso: mezcla con illogical-impulse + end4-pC
Plan completo y estudio: **`docs/plan-parrot-shell.md`**. Resumen:
- El instalador ofrecerá dos escritorios: **clásico** (waybar/fuzzel/dunst, el actual) y
  **Shell end4-pC** (https://github.com/pctrade/end4-pC, fork de la interfaz de
  https://github.com/end-4/dots-hyprland).
- end4-pC necesita de illogical-impulse: dependencias (94 oficiales + 10 AUR), venv de Python
  (`~/.local/state/quickshell/.venv`), la disposición `~/.config/hypr/{hyprland,custom}/` y
  `~/.config/illogical-impulse/config.json`. Quickshell 0.3.2 del repo oficial sirve.
- **Nunca** ejecutar `./setup install` de end-4: hace `rsync --delete` sobre `~/.config/hypr`.
- ii y end4-pC no se copian al repo: se clonan en commits fijados.
- Decisión del usuario: **no usar los temas de Parrot** en CachyOS; colores de end4-pC.
- Pendiente de decidir: quitar también el nombre "Hyprland Parrot", logo y fondos de Parrot.
- Mantener: instalador fácil, extras (Drive/VPN, batería 80 %, BlackArch, mise, firmware),
  modo de energía, Centro (Super + I en modo shell).
- Primer paso en CachyOS: comprobar qué hay instalado (`pacman -Q hyprland quickshell`,
  `hyprctl version`, ¿corrió ya install.sh?) y empezar por el paso 1 del plan.

## Respaldo personal (privado, fuera del repo)
- `respaldo-cachyos-2026-10-27.tar.gz.gpg` (cifrado GPG con contraseña del usuario):
  rclone (Google Drive en `~/Drive`, servicio de usuario `rclone-gdrive`) y datos de la VPN
  del trabajo (FortiClient, SAML). Se restaura con `restaurar-respaldo.sh` o el extra del
  instalador; crea `vpn-trabajo` (openfortivpn `--saml-login`). FortiClient VPN en AUR: `forticlient-vpn`.
- Copias en el disco externo Ventoy de 500 GB: `Backup/CachyOS-2026-10-27/`.
  El usuario quiere los respaldos en ese disco, carpeta `Backup`.
- No poner datos privados (tokens, servidor de la VPN) en este repo: es público.
