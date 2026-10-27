-- Modo de energia (Super + Alt + P) y distribucion de ventanas (Super + Alt + D).
-- Se carga al final para mandar sobre lo que guarde la interfaz:
--   equilibrado -> como lo dejaste en los ajustes de end4-pC
--   rendimiento -> sin desenfoque ni sombras
--   ahorro      -> sin efectos ni animaciones, menos cuadros en ventanas sin foco (bateria)
local B = require("custom.base")

hl.config({
    general = { layout = B.distribucion },
    dwindle   = { preserve_split = true, smart_resizing = true },
    master    = { new_status = "master", mfact = 0.55 },
    scrolling = { fullscreen_on_one_column = true, column_width = 0.6 },
})

if B.modo ~= "equilibrado" then
    hl.config({
        decoration = {
            blur   = { enabled = false },
            shadow = { enabled = false },
            dim_inactive = false,
        },
    })
end
if B.modo == "ahorro" then
    hl.config({
        animations = { enabled = false },
        misc = { render_unfocused_fps = 5 },
    })
end
