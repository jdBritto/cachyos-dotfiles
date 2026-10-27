# Plan: Parrot Shell (Hyprland Parrot + illogical-impulse + end4-pC)

Estudio del 2026-10-27. Versiones vistas:
- end-4/dots-hyprland (illogical-impulse) `2f2a376` (2026-10-11)
- pctrade/end4-pC `74813a8` (2026-10-26)

## Qué es cada cosa

| Pieza | Qué aporta | Archivos |
|---|---|---|
| **illogical-impulse (ii)** | Dotfile completo: config de Hyprland en Lua, la interfaz `quickshell/ii`, colores Material You (matugen), instalador `./setup` | `~/.config/hypr/{hyprland,custom}/`, `~/.config/quickshell/ii`, `~/.config/illogical-impulse/config.json` |
| **end4-pC** | Solo la interfaz (fork de `quickshell/ii`): ajustes con ventana, presets, widgets, letras, esquemas de color con nombre | `~/.config/quickshell/end4-pC` |
| **Hyprland Parrot** | Instalador fácil para CachyOS, 7 temas Parrot, modos de energía, Centro Parrot, extras (BlackArch, batería, Drive/VPN) | `~/.config/hypr/{parrot,scripts,temas}` |

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
`hyprlock.conf`, `hypridle.conf`). **Borraría Hyprland Parrot.** Por eso:
- usar solo `./setup install-deps` y `./setup install-setups` (o replicarlos);
- copiar a mano solo `hypr/hyprland/`, `matugen`, `Kvantum`, `kde-material-you-colors`;
- nunca ejecutar `./setup install` ni `exp-update` sobre esta config.

## Diseño propuesto

El instalador pregunta el escritorio:

- **Parrot clásico** (el actual): waybar + fuzzel + dunst. Ligero.
- **Shell end4-pC**: interfaz end4-pC con sus propios colores, más los extras de este repo.

```
~/.config/hypr/
  hyprland.lua          lee ~/.config/hypr/escritorio (clasico|shell) y carga uno u otro
  parrot/               comun: monitores, entrada, reglas, energia (los dos modos)
  hyprland/             de ii, sin tocar (solo modo shell; se actualiza desde ii)
  custom/               lo Parrot en modo shell: atajos, variables (qsConfig=end4-pC), inicio
  personal.lua          tuyo, nunca se sobrescribe
```

- ii y end4-pC **no se copian al repo**: el instalador los clona en commits fijados
  (estabilidad + licencias GPL-3 separadas). `actualizar-shell` sube de commit a propósito.
- **Colores: los de end4-pC**, sin temas Parrot (decisión del usuario, 2026-10-27: en
  CachyOS nativo no hacen falta). Material You desde el fondo o sus esquemas con nombre
  (catppuccin, nord, tokyonight...). Los `temas/*.tema` quedan solo para el modo clásico.
- Centro Parrot sigue para lo que end4-pC no tiene: modo de energía, distribución de
  ventanas, VPN, batería.
- Cambio de modo en caliente: `escritorio clasico|shell` (para waybar/dunst o qs y recarga).

## Choques de atajos (Parrot → ii)

| Tecla | Parrot | ii / end4-pC |
|---|---|---|
| Super + A | Centro Parrot | barra lateral izquierda (IA, traductor) |
| Super + K | ver atajos | teclado en pantalla |
| Super + Tab | lista de ventanas | vista general |
| Super + M | minimizar | controles de música |
| Super + G | agrupar | widgets superpuestos |
| Super + B | ocultar barra | barra lateral izquierda |
| Super + N | última notificación | barra lateral derecha |
| Super + Escape | apagar | ajustes de end4-pC (sugerido en su README) |
| Super (solo) | — | lanzador |

Propuesta: en modo shell manda ii en lo que es "interfaz" (lanzador, vista general,
barras laterales, notificaciones) y Parrot en ventanas y extras: Centro Parrot en
`Super + I`, minimizar en `Super + Shift + M`, atajos en `Super + /` (hoja de ii, que lee
`custom/keybinds.lua`), apagar en `Ctrl + Alt + Supr`.

## Riesgos

- end4-pC cambia casi a diario (PR #238): fijar commit y probar antes de subir.
- Solo se puede probar en CachyOS (Parrot no tiene Quickshell 0.3.2 ni Hyprland 0.56).
- Más pesado que el clásico: en batería conviene el modo ahorro o el clásico.

## Pasos

1. `paquetes/shell.txt` + `paquetes/shell-aur.txt` desde los PKGBUILD de ii.
2. `extras/shell.sh`: clonar ii y end4-pC fijados, venv con uv, grupos, ydotool,
   copiar `hypr/hyprland`, matugen, Kvantum, end4-pC.
3. `hyprland.lua` con selector + `custom/*.lua` Parrot.
4. (Descartado: convertir temas Parrot a esquemas JSON.)
5. `scripts/escritorio.sh` para cambiar de modo; entrada en el Centro Parrot.
6. Probar en CachyOS: instalar limpio, cambiar de modo, temas, suspender, monitor externo.
