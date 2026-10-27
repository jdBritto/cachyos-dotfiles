-- Hyprland Parrot
-- Escritorio Hyprland con identidad Parrot: temas que se cambian al instante,
-- menus faciles y un modo rendimiento para equipos modestos.
--
-- Cada parte esta en ~/.config/hypr/parrot/. Tus cambios van en
-- ~/.config/hypr/personal.lua: ese archivo nunca se sobrescribe.
--
-- Atajos: Super + K muestra todos. Super + A abre el Centro Parrot.

require("parrot.monitores")
require("parrot.entorno")
require("parrot.apariencia")
require("parrot.entrada")
require("parrot.reglas")
require("parrot.atajos")
require("parrot.inicio")

local personal = os.getenv("HOME") .. "/.config/hypr/personal.lua"
local f = io.open(personal)
if f then
    f:close()
    require("personal")
end
