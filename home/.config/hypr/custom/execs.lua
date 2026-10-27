-- Programas al iniciar (se suman a los de hyprland/execs.lua).
local B = require("custom.base")

hl.on("hyprland.start", function()
    -- La ventana de contrasenas (polkit) la pone end4-pC: no hace falta otro agente
    -- Cursor (ii pone Bibata; aqui se usa WhiteSur)
    hl.exec_cmd("sleep 1 && hyprctl setcursor WhiteSur-cursors 24")
    -- Perfil de energia del modo guardado, y seguir el boton de perfil de end4-pC
    hl.exec_cmd(B.script("modo.sh aplicar"))
    hl.exec_cmd(B.script("modo.sh vigilar"))
    -- Primera sesion: teclado, touchpad e inactividad de este equipo en los ajustes de end4-pC
    hl.exec_cmd(B.script("ajustes-end4.py inicial"))
end)
