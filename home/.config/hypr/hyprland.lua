-- Hyprland en CachyOS con la interfaz end4-pC
--
-- Orden de carga:
--   hyprland/   base de illogical-impulse (no se edita: se actualiza con extras/shell.sh)
--   custom/     lo de este repositorio: teclado, reglas, atajos extra, modo de energia
--   personal.lua  tus cambios: nunca se sobrescribe y manda sobre todo lo anterior
--
-- Atajos: Super + / muestra la hoja de atajos. Super + I abre el Centro.

-- Interno de illogical-impulse
require("hyprland.lib")
require("hyprland.services")

-- Variables de entorno
require("hyprland.env")
require("custom.env")

-- Base de illogical-impulse
require("hyprland.execs")
require("hyprland.general")
require("hyprland.rules")
require("hyprland.colors")
require("hyprland.keybinds")

-- Capa de este repositorio
require("custom.execs")
require("custom.general")
require("custom.rules")
require("custom.keybinds")

-- Ajustes que guarda la interfaz (pagina de Hyprland en los ajustes de end4-pC)
require("hyprland.shellOverrides.main")

-- Modo de energia y distribucion de ventanas (despues de todo, para que manden)
require("custom.modo")

if is_file_exists(HOME .. "/.config/hypr/personal.lua") then
    require("personal")
end
