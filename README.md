# cachyos-dotfiles

**Hyprland Parrot** para **CachyOS**: Hyprland con el estilo de Parrot, temas que se cambian al instante, menús fáciles y
un modo rendimiento. Pensado para un Lenovo ThinkPad (AMD), pero funciona en
cualquier equipo.

Las ideas vienen de los [dotfiles de gh0stzk](https://github.com/gh0stzk/dotfiles):
paletas hechas a mano, menús para todo y efectos que se pueden apagar.

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

3. Reinicia y entra en la sesión **Hyprland**.

El instalador muestra un menú de extras (flechas, Espacio para marcar, Enter
para seguir). Sin preguntas: `install.sh --si`. Para ver lo que haría sin
tocar nada: `install.sh --simular`.

### Qué hace el instalador

- Actualiza el sistema e instala Hyprland y todo lo necesario desde los
  repositorios oficiales (lista en `paquetes/`). `wlogout` (menú de apagado)
  viene de AUR con `paru`; si falla, se usa un menú sencillo.
- Aparta el `hyprland.conf` que trae CachyOS y copia la configuración nueva
  (en Lua, el formato actual de Hyprland). Antes de sobrescribir guarda una
  copia en `~/.config-respaldo-<fecha>`. Es seguro ejecutarlo más de una vez.
- Instala los fondos de Parrot (GPL) en `~/.local/share/backgrounds/parrot`,
  el cursor WhiteSur y pone las apps GTK en oscuro con iconos Papirus.
- Activa la red, el bluetooth y los perfiles de energía, y deja Hyprland
  propuesto en la pantalla de inicio.

### Extras

| Extra | Qué hace |
|---|---|
| Firefox y firmware | Firefox y `fwupd`: actualiza la BIOS de Lenovo con `fwupdmgr refresh && fwupdmgr update` |
| Herramientas de desarrollo | `mise` con claude, codex, gh, node y opencode |
| Repositorio BlackArch | Herramientas de seguridad como en Parrot (`sudo pacman -S blackarch-<categoría>`). Viene desmarcado |
| Cuidar la batería | Deja de cargar al 80 % (solo aparece si el portátil lo permite, como los ThinkPad). `bateria-completa` carga al 100 % una vez |

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
  sesión SAML en el navegador (también en `Super + A` → VPN del trabajo).
  Con `--forticlient` instala además FortiClient VPN desde AUR.

El respaldo **no** va en este repositorio: tiene tu sesión de Google Drive.

## Usar

| Atajo | Qué hace |
|---|---|
| `Super + K` | Ver todos los atajos |
| `Super + A` | Centro Parrot: tema, fondo, modo, wifi, bluetooth, sonido, pantallas… |
| `Super + Espacio` | Buscar aplicaciones |
| `Super + Enter` | Terminal |
| `Super + Tab` / `Alt + Tab` | Lista de ventanas / siguiente ventana |
| `Super + W` | Cerrar ventana |
| `Super + T` / `Super + F` | Flotante / pantalla completa |
| `Super + D` | Ordenar ventanas: mosaico, columnas (como Niri) o principal |
| `Super + M` / `Super + Shift + M` | Minimizar / ver minimizadas |
| `Super + G` | Agrupar en pestañas |
| `Super + \|` | Terminal desplegable (tecla a la izquierda del 1) |
| `Super + Alt + T` | Cambiar tema |
| `Super + Ctrl + Espacio` | Cambiar fondo |
| `Super + Alt + P` | Modo: equilibrado / rendimiento / ahorro |
| `Super + V` | Portapapeles |
| `Impr Pant` / `Super + Shift + S` | Captura de una zona / y editarla |
| `Super + Ctrl + L` | Bloquear |
| `Super + Escape` | Apagar / reiniciar |

Con el ratón: `Super` + arrastrar mueve, `Super` + clic derecho cambia el
tamaño, y también desde el borde. Touchpad: 3 dedos a los lados cambia de
escritorio.

- **7 temas**: Parrot, Lorikeet, Vaporwave, HackTheBox, Nefelibata, Mystic y
  Claro. Cada uno cambia bordes, barra, menús, notificaciones, terminal,
  bloqueo y fondo, y recuerda el fondo que le elijas.
- **Modos**: *equilibrado* (todos los efectos), *rendimiento* (sin
  desenfoque ni sombras, CPU al máximo) y *ahorro* (sin efectos, para la
  batería).

## Personalizar

Todo está en `~/.config/hypr/`:

| Carpeta / archivo | Qué es |
|---|---|
| `personal.lua` | **Tus cambios.** Se carga al final y el instalador nunca lo sobrescribe |
| `parrot/` | Las partes de la configuración (aspecto, atajos, reglas, inicio…) |
| `temas/` | Los colores: copia uno, cámbiale los colores y aparece en el menú |
| `scripts/` | Los menús y utilidades |
| `waybar/` | La barra (estilos "islas" y "panel") |

Comprueba la configuración sin reiniciar: `Hyprland --verify-config`.
Pruébala en una ventana desde otro escritorio:
`PARROT_PRUEBA=1 Hyprland -c ~/.config/hypr/hyprland.lua`.

## Guardar tus cambios

`./actualizar.sh "mensaje"` copia tu configuración actual al repositorio y la
sube a GitHub.
