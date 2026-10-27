-- Atajos extra (se suman a los de hyprland/keybinds.lua; Super + / los muestra todos).
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

-- Cambiar el tamano con el teclado (Ctrl + Super + flechas ya cambia de escritorio en ii)
local delta = { LEFT = { -40, 0 }, RIGHT = { 40, 0 }, UP = { 0, -40 }, DOWN = { 0, 40 } }
for tecla, d in pairs(delta) do
    hl.bind("SUPER + CTRL + SHIFT + " .. tecla, dsp.window.resize({ x = d[1], y = d[2], relative = true }),
        { repeating = true, description = "Cambiar tamano de la ventana" })
end

-- Editar este archivo
b("CTRL + SUPER + ALT + SLASH", cmd("xdg-open ~/.config/hypr/custom/keybinds.lua"), "Editar atajos propios")
