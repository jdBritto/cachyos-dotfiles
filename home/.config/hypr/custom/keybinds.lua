-- Atajos extra (se suman a los de hyprland/keybinds.lua; Super + F1 los muestra todos).
local B = require("custom.base")
local S = B.script
local dsp = hl.dsp

local function b(teclas, accion, desc, opts)
    opts = opts or {}
    opts.description = desc
    hl.bind(teclas, accion, opts)
end
local function cmd(c) return dsp.exec_cmd(c) end

-- Super + I: el Centro (en ii abria la app de ajustes; ahora va en Super + Escape)
hl.unbind("SUPER + I")
b("SUPER + I",      cmd(S("centro.sh")), "Centro: modo de energia, ventanas, VPN, pantallas")
b("SUPER + ESCAPE", dsp.global("quickshell:settingsToggle"), "Ajustes de end4-pC")

b("SUPER + ALT + P", cmd(S("modo.sh ciclar")),     "Modo: equilibrado / rendimiento / ahorro")
b("SUPER + ALT + D", cmd(S("distribucion.sh")),    "Distribucion: mosaico / columnas / principal")

-- Terminal desplegable: la tecla a la izquierda del 1 (| en latam, ` en EE.UU., º en Espana)
b("SUPER + bar",            dsp.workspace.toggle_special("terminal"), "Terminal desplegable")
hl.bind("SUPER + grave",     dsp.workspace.toggle_special("terminal"))
hl.bind("SUPER + masculine", dsp.workspace.toggle_special("terminal"))

-- Ventanas agrupadas en pestanas
b("SUPER + ALT + G",     dsp.group.toggle(), "Agrupar en pestanas")
b("SUPER + ALT + RIGHT", dsp.group.next(),   "Siguiente pestana del grupo")
b("SUPER + ALT + LEFT",  dsp.group.prev(),   "Pestana anterior del grupo")

-- Cambiar el tamano con el teclado (Ctrl + Super + flechas ya cambia de escritorio en ii).
-- ii usa Ctrl + Super + Shift + izq/der para mover la ventana de escritorio (oculto, ya esta
-- en Super + Shift + RePag/AvPag): se quita para que no hagan las dos cosas a la vez.
hl.unbind("CTRL + SUPER + SHIFT + Left")
hl.unbind("CTRL + SUPER + SHIFT + Right")
local delta = { LEFT = { -40, 0 }, RIGHT = { 40, 0 }, UP = { 0, -40 }, DOWN = { 0, 40 } }
for tecla, d in pairs(delta) do
    hl.bind("SUPER + CTRL + SHIFT + " .. tecla, dsp.window.resize({ x = d[1], y = d[2], relative = true }),
        { repeating = true, description = "Cambiar tamano de la ventana" })
end

-- Teclado latinoamericano: ii usa teclas de EE.UU. que aqui necesitan Shift o AltGr
-- (/ = [ ] ; \), y Hyprland compara la tecla sin Shift, asi que esos atajos no se pueden pulsar.
-- Se repiten con teclas que si existen solas en latam.
--   Hoja de atajos: end4-pC quito la de ii (Super + /); la sustituye scripts/atajos.sh
hl.unbind("SUPER + Slash")
b("SUPER + F1",         cmd(S("atajos.sh")), "Ver todos los atajos")
b("SUPER + SHIFT + F1", cmd("xdg-open ~/.config/hypr/custom/keybinds.lua"), "Editar atajos propios")
--   Zoom: Super + - ya funciona; Super + = pasa a Super + +
local function zoom(v)
    local z = hl.get_config("cursor:zoom_factor") + v
    hl.config({ cursor = { zoom_factor = math.max(1.0, math.min(3.0, z)) } })
end
b("SUPER + plus", function() zoom(0.3) end, "Pantalla: acercar (zoom)", { repeating = true })
--   Super + [ ] (foco izq/der) y Ctrl + Super + [ ] (escritorio anterior/siguiente):
--   en latam [ ] estan sobre las teclas { }
hl.bind("SUPER + braceleft",         dsp.focus({ direction = "l" }))
hl.bind("SUPER + braceright",        dsp.focus({ direction = "r" }))
hl.bind("CTRL + SUPER + braceleft",  dsp.focus({ workspace = "-1" }))
hl.bind("CTRL + SUPER + braceright", dsp.focus({ workspace = "+1" }))
--   Proporcion de la division: Super + ; pasa a Super + ñ (Super + ' sigue igual)
hl.bind("SUPER + ntilde", dsp.layout("splitratio -0.1"), { repeating = true })

-- Atajos de ii que end4-pC ya no tiene
--   Ctrl + Super + Shift + D: claro/oscuro (end4-pC quito ese atajo global)
hl.unbind("CTRL + SUPER + SHIFT + D")
b("CTRL + SUPER + SHIFT + D", cmd(S("claro-oscuro.sh")), "Tema claro / oscuro")
--   Ctrl + Super + P: ciclo de familia de paneles (no existe en end4-pC)
hl.unbind("CTRL + SUPER + P")
