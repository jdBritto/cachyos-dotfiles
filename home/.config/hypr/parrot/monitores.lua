-- Pantallas. Por defecto: resolucion preferida, escala 1.
-- Para cambiarlas usa el Centro Parrot > Pantallas (nwg-displays): guarda en
-- ~/.config/hypr/monitors.conf y aqui se lee ese archivo.
local P = require("parrot.base")

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

-- Formato de nwg-displays (el de Hyprland 0.54):
--   monitor=eDP-1,1920x1080@60.0,0x0,1.0[,clave,valor...]
--   monitor=eDP-1,transform,1
--   monitor=HDMI-A-1,disable
local f = io.open(P.dir .. "/monitors.conf")
if f then
    local pantallas, orden = {}, {}
    local function extras(m, c, i)
        while c[i] and c[i + 1] do
            local k, v = c[i], c[i + 1]
            if k == "transform" or k == "bitdepth" or k == "vrr" then
                m[k] = tonumber(v)
            elseif k == "mirror" then
                m.mirror = v
            end
            i = i + 2
        end
    end
    for linea in f:lines() do
        local def = linea:match("^%s*monitor%s*=%s*(.-)%s*$")
        if def then
            local c = {}
            for campo in (def .. ","):gmatch("%s*([^,]-)%s*,") do c[#c + 1] = campo end
            local nombre = c[1]
            if nombre and nombre ~= "" then
                if not pantallas[nombre] then
                    pantallas[nombre] = { output = nombre }
                    orden[#orden + 1] = nombre
                end
                local m = pantallas[nombre]
                if c[2] == "disable" or c[2] == "disabled" then
                    m.disabled = true
                elseif c[2] == "transform" or c[2] == "vrr" or c[2] == "bitdepth" or c[2] == "mirror" then
                    extras(m, c, 2)
                elseif c[2] and c[2] ~= "" then
                    m.mode, m.position = c[2], c[3] or "auto"
                    m.scale = tonumber(c[4]) or 1
                    extras(m, c, 5)
                end
            end
        end
    end
    f:close()
    for _, nombre in ipairs(orden) do
        local m = pantallas[nombre]
        if m.disabled or m.mode then hl.monitor(m) end
    end
end
