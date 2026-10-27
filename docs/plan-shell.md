# Plan: Hyprland + end4-pC en CachyOS

Estudio del 2026-10-27. Versiones vistas:
- end-4/dots-hyprland (illogical-impulse) `2f2a376` (2026-10-11)
- pctrade/end4-pC `74813a8` (2026-10-26)

## Qué es cada cosa

| Pieza | Qué aporta | Archivos |
|---|---|---|
| **illogical-impulse (ii)** | Dotfile completo: config de Hyprland en Lua, la interfaz `quickshell/ii`, colores Material You (matugen), instalador `./setup` | `~/.config/hypr/{hyprland,custom}/`, `~/.config/quickshell/ii`, `~/.config/illogical-impulse/config.json` |
| **end4-pC** | Solo la interfaz (fork de `quickshell/ii`): ajustes con ventana, presets, widgets, letras, esquemas de color con nombre | `~/.config/quickshell/end4-pC` |
| **Este repo** | Instalador fácil para CachyOS, modos de energía, Centro, extras (batería, Drive/VPN, mise, firmware) | `~/.config/hypr/{custom,scripts}` |

## Lo que end4-pC necesita de illogical-impulse

1. **Dependencias**: 104 paquetes; 94 oficiales y 10 de AUR (fuentes y temas:
   `adw-gtk-theme-git breeze-plus darkly-bin otf-space-grotesk qt6-avif-image-plugin
   ttf-material-symbols-variable-git ttf-readex-pro ttf-rubik-vf ttf-twemoji wlogout`).
   ii los agrupa en metapaquetes `sdata/dist-arch/illogical-impulse-*/PKGBUILD`.
2. **Quickshell 0.3.2**: ii fija el commit `4f508be`, que es exactamente la
   versión `quickshell 0.3.2` del repositorio oficial `extra`. No hay que compilarla.
3. **Entorno Python** en `~/.local/state/quickshell/.venv` (uv, `sdata/uv/requirements.txt`)
   y la variable `ILLOGICAL_IMPULSE_VIRTUAL_ENV`.
4. **Disposición de la config de Hyprland de ii**. end4-pC lee y escribe:
   - `hypr/hyprland/keybinds.lua` y `hypr/custom/keybinds.lua` (lista de atajos)
   - `hypr/hyprland/shellOverrides/main.lua` y `animations.lua` (página de ajustes de Hyprland)
   - `hl.env("qsConfig", ...)` en `custom/variables.lua`
5. Config de apps: `~/.config/matugen`, `kde-material-you-colors`, `Kvantum`, `fontconfig`.
6. Setup del sistema: grupos `video,i2c,input`, `i2c-dev`, servicio de usuario `ydotool`.

## Peligro: el instalador de ii

`./setup install` sincroniza `~/.config/hypr` con `rsync --delete` (salvo `custom/`,
`hyprlock.conf`, `hypridle.conf`). **Borraría la capa de este repo.** Por eso:
- usar solo `./setup install-deps` y `./setup install-setups` (o replicarlos);
- copiar a mano solo `hypr/hyprland/`, `matugen`, `Kvantum`, `kde-material-you-colors`;
- nunca ejecutar `./setup install` ni `exp-update` sobre esta config.

## Decisión (2026-10-27)

El usuario pidió **quitar todo lo de Parrot** y centrarse en CachyOS. Ya no hay dos
escritorios: **end4-pC es el escritorio**. Se borró del repo el modo clásico
(waybar, fuzzel con temas, dunst, hyprpaper), los 7 temas, los fondos, el logo, el
nombre "Hyprland Parrot", el Centro Parrot y el extra BlackArch.

```
~/.config/hypr/
  hyprland.lua      del repo: hyprland/ -> custom/ -> shellOverrides -> custom/modo.lua -> personal.lua
  hyprland/         de ii, sin tocar (extras/shell.sh)
  hyprlock/, hyprlock.conf   de ii
  custom/           del repo: teclado, touchpad, pantallas, reglas, atajos extra, modo
  scripts/          del repo: centro, modo, distribucion, monitores
  personal.lua      del usuario, nunca se sobrescribe
```

## Atajos propios (sobre los de ii)

| Tecla | Qué hace |
|---|---|
| Super + I | Centro (en ii abría la app de ajustes; se quita con `hl.unbind`) |
| Super + Escape | ajustes de end4-pC (lo sugiere su README) |
| Super + Alt + P | modo equilibrado / rendimiento / ahorro |
| Super + Alt + D | distribución mosaico / columnas / principal |
| Super + Alt + G | agrupar en pestañas |
| Super + \| | terminal desplegable |
| Ctrl + Super + Shift + flechas | cambiar tamaño (Ctrl + Super + flechas es de ii) |

## Riesgos

- end4-pC cambia casi a diario: fijar commit y probar antes de subir.
- Más pesado que un escritorio con waybar: en batería conviene el modo ahorro.

## Pasos

1. ✅ `paquetes/shell.txt` + `paquetes/aur.txt` desde los PKGBUILD de ii (2026-10-27).
   - `wlogout` ya está en los repositorios oficiales: de 104 dependencias, 95 son oficiales.
   - Fuera: `microtex` (solo fórmulas en el chat de IA), cursor Bibata (se usa WhiteSur)
     y `polkit-kde-agent` (end4-pC trae su propio agente polkit; tampoco se usa `hyprpolkitagent`).
2. ✅ `extras/shell.sh`: clona ii y end4-pC fijados, copia lo necesario, fuente Google Sans
   Flex, venv con uv, grupos, i2c, ydotool.
3. ✅ `hyprland.lua` nuevo + `custom/*.lua`; `install.sh` sin Parrot y con la interfaz siempre.
4. ✅ Probado en el equipo (2026-10-27, Hyprland 0.56.2, quickshell 0.3.2). Arreglos:
   - Los overrides de end4-pC pisaban la capa `custom/`: teclado en `us` en vez de
     `latam`, sin desplazamiento natural. Ahora config.json de end4-pC es la única fuente
     (`scripts/ajustes-end4.py`, valores iniciales del portátil una sola vez).
   - `hyprland.lua` no cargaba `monitors.lua`: se perdían las pantallas guardadas
     en los ajustes de end4-pC. `custom/pantallas.lua` queda para el `monitors.conf` antiguo.
   - `hypridle.conf` con el formato que edita end4-pC (`$suspend_cmd`): antes, cambiar
     "suspender" en los ajustes añadía un bloque roto. Bloqueo con la pantalla de
     end4-pC (hyprlock si la interfaz no está), `inhibit_sleep`, `scripts/suspender.sh`.
   - El botón de perfil de energía de end4-pC y `Super + Alt + P` van sincronizados
     (`modo.sh vigilar`). `Super + Alt + D` guarda la distribución en end4-pC.
   - Faltaba `custom/scripts/__restore_video_wallpaper.sh` (lo arranca ii); `~/.face`
     desde AccountsService.
   - Pendiente de probar a mano: bloqueo (`Super + L`), suspender, monitor externo, VPN.
5. Ideas: página propia en los ajustes de end4-pC para el modo de energía; preset propio.
