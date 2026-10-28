-- Programas al iniciar (se suman a los de hyprland/execs.lua)
local B = require("custom.base")

hl.on("hyprland.start", function()
    -- Perfil de energia del modo guardado, y seguir el boton de perfil de end4-pC
    hl.exec_cmd(B.script("modo.sh aplicar"))
    hl.exec_cmd(B.script("modo.sh vigilar"))
end)
