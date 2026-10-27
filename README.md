# cachyos-dotfiles

**Hyprland + end4-pC** para **CachyOS**: la interfaz
[end4-pC](https://github.com/pctrade/end4-pC) (fork de
[illogical-impulse](https://github.com/end-4/dots-hyprland)), con colores que
salen del fondo de pantalla, un instalador fácil, modo de energía y extras para
el portátil. Pensado para un Lenovo ThinkPad (AMD), pero funciona en cualquier equipo.

## Instalar

1. Instala CachyOS desde su ISO. En el instalador elige el escritorio
   **Hyprland** (así ya quedan la pantalla de inicio, la red y los drivers).
   Sistema de archivos: deja **btrfs** con instantáneas; si una actualización
   falla, vuelves atrás desde el menú de arranque.
2. Entra con tu usuario, abre una terminal y ejecuta:

```bash
sudo pacman -S --needed git
git clone https://github.com/jdBritto/cachyos-dotfiles.git ~/cachyos-dotfiles
~/cachyos-dotfiles/install.sh
```

3. Reinicia y entra en la sesión **Hyprland** (no la de UWSM).

El instalador muestra un menú de extras (flechas, Espacio para marcar, Enter
para seguir). Sin preguntas: `install.sh --si`. Para ver lo que haría sin
tocar nada: `install.sh --simular`. Elegir extras sin menú:
`install.sh --con=bateria --sin=apps`.

### Qué hace el instalador

- Actualiza el sistema e instala Hyprland y lo que necesita la interfaz desde
  los repositorios oficiales (`paquetes/hyprland.txt` y `paquetes/shell.txt`), y
  las fuentes y temas de AUR con `paru` (`paquetes/aur.txt`).
- Descarga illogical-impulse y end4-pC en **commits fijados** (`extras/shell.sh`)
  y copia solo lo necesario. No usa el instalador de illogical-impulse, que
  borraría tu `~/.config/hypr`.
- Copia la configuración (en Lua). Antes de sobrescribir guarda una copia en
  `~/.config-respaldo-<fecha>`. Es seguro ejecutarlo más de una vez.
- Prepara el entorno de Python de la interfaz, los grupos `video,i2c,input`,
  `ydotool`, la fuente Google Sans Flex y el cursor WhiteSur.
- Activa la red, el bluetooth y los perfiles de energía.

### Extras

| Extra | Qué hace |
|---|---|
| Firefox y firmware | Firefox y `fwupd`: actualiza la BIOS de Lenovo con `fwupdmgr refresh && fwupdmgr update` |
| Herramientas de desarrollo | `mise` con claude, codex, gh, node y opencode |
| Cuidar la batería | Deja de cargar al 80 % (solo aparece si el portátil lo permite, como los ThinkPad). `bateria-completa` carga al 100 % una vez |
| Restaurar Google Drive y VPN | Aparece si encuentra tu respaldo (abajo) |

### Respaldo personal (Google Drive y VPN)

Si dejas tu `respaldo-cachyos-*.tar.gz.gpg` en la carpeta personal (`~`) o junto
a esta carpeta antes de ejecutar `install.sh`, aparece el extra
**Restaurar Google Drive y VPN**. También se puede hacer aparte:

```bash
~/cachyos-dotfiles/restaurar-respaldo.sh ~/respaldo-cachyos-2026-10-27.tar.gz.gpg
```

El respaldo va cifrado con GPG: al restaurar se pide su contraseña.

- Monta Google Drive en `~/Drive` con rclone (servicio de usuario `rclone-gdrive`).
- Crea `vpn-trabajo`: conecta la VPN de Fortinet con `openfortivpn` e inicio de
  sesión SAML en el navegador (también en `Super + I` → VPN del trabajo).
  Con `--forticlient` instala además FortiClient VPN desde AUR.

El respaldo **no** va en este repositorio: tiene tu sesión de Google Drive.

## Usar

Los atajos son los de illogical-impulse; `Super + /` los muestra todos.

| Atajo | Qué hace |
|---|---|
| `Super` (solo) | Buscar aplicaciones |
| `Super + /` | Ver todos los atajos |
| `Super + I` | **Centro**: modo de energía, distribución de ventanas, VPN, pantallas, batería |
| `Super + Escape` | Ajustes de end4-pC (barra, colores, widgets, presets) |
| `Super + A` / `Super + N` | Barra lateral izquierda (IA, traductor) / derecha (wifi, bluetooth, sonido, notificaciones) |
| `Super + Tab` | Vista de escritorios y ventanas |
| `Super + Enter` | Terminal (kitty) |
| `Super + \|` | Terminal desplegable (tecla a la izquierda del 1) |
| `Super + Q` | Cerrar ventana |
| `Super + F` / `Super + D` | Pantalla completa / maximizar |
| `Super + Alt + Espacio` | Flotante / mosaico |
| `Super + Alt + P` | Modo: equilibrado / rendimiento / ahorro |
| `Super + Alt + D` | Distribución: mosaico / columnas (como Niri) / principal |
| `Super + Alt + G` | Agrupar en pestañas |
| `Ctrl + Super + T` | Elegir fondo (los colores salen de él) |
| `Super + V` | Portapapeles |
| `Super + Shift + S` | Captura de una zona |
| `Super + L` | Bloquear |
| `Ctrl + Alt + Supr` | Apagar / reiniciar |

- **Modos**: *equilibrado* (los efectos que elijas en los ajustes), *rendimiento*
  (sin desenfoque ni sombras, CPU al máximo) y *ahorro* (sin efectos, para la batería).
  El botón de perfil de energía de end4-pC (barra y panel derecho) cambia el modo también.
- **Un solo sitio para los ajustes**: teclado, touchpad, distribución de ventanas,
  pantallas y tiempos de inactividad se cambian en los ajustes de end4-pC
  (`Super + Escape` > Hyprland). La primera vez se ponen los de este equipo: teclado
  de CachyOS, desplazamiento natural, bloquear a los 5 min, apagar la pantalla a los 6
  y suspender a los 30 (solo con batería).

## Personalizar

Todo está en `~/.config/hypr/`:

| Carpeta / archivo | Qué es |
|---|---|
| `personal.lua` | **Tus cambios.** Se carga al final y el instalador nunca lo sobrescribe |
| `custom/` | Lo de este repositorio: teclado, touchpad, reglas, atajos extra, modo de energía |
| `hyprland/` | Base de illogical-impulse. No la edites: se reemplaza al actualizar |
| `scripts/` | Centro, modo de energía, distribución, pantallas, `ajustes-end4.py` |
| `monitors.lua` | Pantallas (lo guardan los ajustes de end4-pC y nwg-displays) |
| `hyprland/shellOverrides/` | Lo que cambias en los ajustes de end4-pC (no lo edites a mano) |

Comprueba la configuración sin reiniciar:
`Hyprland --verify-config -c ~/.config/hypr/hyprland.lua`.

### Actualizar la interfaz

Los commits de illogical-impulse y end4-pC están fijados al principio de
`extras/shell.sh`. Para subir de versión, cambia el commit, ejecuta
`extras/shell.sh` y prueba antes de subir el cambio.

## Guardar tus cambios

`./actualizar.sh "mensaje"` copia tu configuración actual al repositorio y la
sube a GitHub.

## Créditos

- [illogical-impulse](https://github.com/end-4/dots-hyprland) (GPL-3.0) y
  [end4-pC](https://github.com/pctrade/end4-pC) (GPL-3.0): se descargan al instalar, no se copian aquí.
- Ideas de los [dotfiles de gh0stzk](https://github.com/gh0stzk/dotfiles): menús para todo y efectos que se pueden apagar.
