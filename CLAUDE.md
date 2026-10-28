# Contexto para Claude Code

Responder siempre en **español**, con mensajes cortos y sencillos.

## Quién y qué
- Equipo de trabajo: Lenovo ThinkPad E14 Gen 4 (AMD) con **CachyOS nativo** (instalado 2026-10-27).
  En casa usa Omarchy.
- Este repo instala **Hyprland + la interfaz end4-pC** (fork de illogical-impulse) en CachyOS:
  `install.sh` (menú de extras, `--simular`, `--si`, `--con=`/`--sin=`), `extras/shell.sh`
  (interfaz), `paquetes/*.txt`, configuración en `home/`, `actualizar.sh` sube los cambios.
- **Nada de Parrot** (decisión del usuario, 2026-10-27): ni nombre, logo, fondos, temas, ni
  paquetes pensados para Parrot. Se mejora con lo aprendido de end4-pC, illogical-impulse y gh0stzk.

## Cómo está armado `~/.config/hypr`
- `hyprland.lua` (del repo): carga `hyprland/` (ii, sin tocar) → `custom/` (del repo) →
  `hyprland/shellOverrides/main.lua` (lo guarda la interfaz) → `custom/modo.lua` → `personal.lua`.
- `hyprland/`, `hyprlock/`, `hyprlock.conf` vienen de ii (los copia `extras/shell.sh`).
- `custom/`: teclado del sistema, touchpad, pantallas (nwg-displays → `monitors.conf`), reglas,
  atajos extra (Super + I Centro, Super + Escape ajustes end4-pC, Super + Alt + P/D), modo.
- Estado de los scripts en `~/.local/state/hypr-cachyos/` (modo, marca `ajustes-iniciales`).
- **Fuente de verdad de los ajustes = `~/.config/illogical-impulse/config.json`** (`hyprland.*`).
  Al abrir su página de Hyprland, end4-pC reescribe `shellOverrides/main.lua` desde ahí
  (pisa teclado, touchpad, layout de `custom/`). Para cambiarlos desde scripts:
  `scripts/ajustes-end4.py poner general.layout scrolling` (toca config.json + overrides).
  `ajustes-end4.py inicial` (al arrancar, una vez) pone los valores del portátil.
- end4-pC reescribe los bloques `listener` de `hypridle.conf` (los reconoce por
  `loginctl lock-session`, `dpms` y `$suspend_cmd`): mantener ese formato.
- `monitors.lua`/`workspaces.lua` los escriben end4-pC y nwg-displays 0.5; `hyprland.lua` los carga.
- `modo.sh vigilar` escucha power-profiles-daemon por D-Bus: el botón de energía de end4-pC
  cambia el modo de Hyprland.
- ii y end4-pC se clonan en commits fijados (`extras/shell.sh`) en `~/.local/share/hypr-cachyos/fuentes`.
- **Nunca** ejecutar `./setup install` de end-4: hace `rsync --delete` sobre `~/.config/hypr`.

## Trucos
- Validar: `Hyprland --verify-config -c ~/.config/hypr/hyprland.lua` (sí detecta errores de Lua).
  Para probar sin tocar `~/.config`: copiar ii `hypr/hyprland` + `home/.config/hypr` a una carpeta y
  verificar con `-c` esa carpeta.
- En Lua: `hyprctl dispatch 'hl.dsp...'`; `hyprctl keyword` ya no existe, usar `hyprctl eval`.
  `hl.unbind("SUPER + I")` existe (para cambiar atajos de ii sin editar sus archivos).
- Las teclas `code:NN` no funcionan en Lua: usar nombres (bar, grave, masculine).
- `binds.workspace_back_and_forth` debe quedar en false: en 0.56 hace que `Super + número` vuelva
  al escritorio anterior al instante. Probar atajos con `ydotool key -d 60 125:1 4:1 4:0 125:0` (wtype no dispara atajos).
- Teclado latam: Hyprland compara la tecla sin Shift; `/ = [ ] ; \` de ii no se pueden pulsar.
  `custom/keybinds.lua` las repite (F1 atajos, plus, braceleft/braceright, ntilde). end4-pC quitó
  los globales `cheatsheetToggle`, `toggleLightDark`, `panelFamilyCycle` (ver `hyprctl globalshortcuts`).
- sudo con ventana: `SUDO_ASKPASS` con `pinentry-qt` y un `sudo` que llama a `sudo -A`.
  GPG usa `pinentry-qt` (`~/.gnupg/gpg-agent.conf`).

## Respaldo personal (privado, fuera del repo)
- `respaldo-cachyos-2026-10-27.tar.gz.gpg` (cifrado GPG con contraseña del usuario):
  rclone (Google Drive en `~/Drive`, servicio de usuario `rclone-gdrive`) y datos de la VPN
  del trabajo (FortiClient, SAML). Se restaura con `restaurar-respaldo.sh` o el extra del
  instalador; crea `vpn-trabajo` (openfortivpn `--saml-login`). FortiClient VPN en AUR: `forticlient-vpn`.
  Ya restaurado en el equipo (2026-10-27).
- Copias en el disco externo Ventoy de 500 GB: `Backup/CachyOS-2026-10-27/`.
  El usuario quiere los respaldos en ese disco, carpeta `Backup`.
- No poner datos privados (tokens, servidor de la VPN) en este repo: es público.
