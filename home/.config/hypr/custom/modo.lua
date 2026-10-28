-- Modo de energia (Super + Alt + P, o el boton de perfil de energia de end4-pC).
--   equilibrado -> como lo dejaste en los ajustes de end4-pC
--   rendimiento -> sin desenfoque ni sombras
--   ahorro      -> sin efectos ni animaciones, menos cuadros en ventanas sin foco
-- hyprland/shellOverrides (los ajustes de end4-pC) se carga al final y vuelve a poner los
-- efectos, asi que esto se aplica despues: al arrancar y tras cada recarga.
local B = require("custom.base")

local function aplicar()
    local modo = B.leer(B.estado .. "/modo") or "equilibrado"
    if modo ~= "equilibrado" then
        hl.config({ decoration = { blur = { enabled = false }, shadow = { enabled = false }, dim_inactive = false } })
    end
    if modo == "ahorro" then
        hl.config({ animations = { enabled = false }, misc = { render_unfocused_fps = 5 } })
    end
end

hl.on("hyprland.start", aplicar)
hl.on("config.reloaded", aplicar)
