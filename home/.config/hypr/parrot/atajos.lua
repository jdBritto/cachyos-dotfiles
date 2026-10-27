-- Atajos de teclado. Super + K los muestra todos con su descripcion.
-- Son los mismos que en Niri siempre que se pudo.
local P = require("parrot.base")
local pr = P.programas
local S = P.script
local dsp = hl.dsp

local function b(teclas, accion, desc, opts)
    opts = opts or {}
    opts.description = desc
    hl.bind(teclas, accion, opts)
end
local function cmd(c) return dsp.exec_cmd(c) end

-------------------------------------------------- Aplicaciones
b("SUPER + RETURN",         cmd(pr.terminal),  "Terminal")
b("SUPER + SHIFT + RETURN", cmd(pr.navegador), "Navegador")
b("SUPER + SHIFT + B",      cmd(pr.navegador), "Navegador")
b("SUPER + SHIFT + F",      cmd(pr.archivos),  "Archivos")
b("SUPER + E",              cmd(pr.archivos),  "Archivos")
b("SUPER + SPACE",          cmd(S("lanzador.sh")), "Buscar aplicaciones")
-- Terminal desplegable: la tecla a la izquierda del 1 (| en latam, ` en EE.UU., º en Espana)
b("SUPER + bar",            dsp.workspace.toggle_special("terminal"), "Terminal desplegable (tecla a la izquierda del 1)")
hl.bind("SUPER + grave",     dsp.workspace.toggle_special("terminal"))
hl.bind("SUPER + masculine", dsp.workspace.toggle_special("terminal"))
b("CTRL + SHIFT + ESCAPE",  cmd(pr.tareas), "Administrador de tareas")
b("SUPER + CTRL + X",       cmd("voxtype record toggle"), "Dictado por voz")

-------------------------------------------------- Menus Parrot
b("SUPER + A",       cmd(S("centro.sh")), "Centro Parrot (ajustes rapidos)")
b("SUPER + I",       cmd(S("centro.sh")), "Centro Parrot (ajustes rapidos)")
b("SUPER + K",       cmd(S("atajos.sh")), "Ver atajos")
b("ALT + F1",        cmd(S("atajos.sh")), "Ver atajos")
b("SUPER + ESCAPE",  cmd(S("energia.sh")), "Apagar / reiniciar / bloquear")
b("XF86PowerOff",    cmd(S("energia.sh")), "Apagar / reiniciar / bloquear", { locked = true })
b("SUPER + CTRL + SHIFT + SPACE", cmd(S("tema.sh menu")),  "Cambiar tema")
b("SUPER + ALT + T",              cmd(S("tema.sh menu")),  "Cambiar tema")
b("SUPER + CTRL + SPACE",         cmd(S("fondo.sh menu")), "Cambiar fondo")
b("SUPER + ALT + W",              cmd(S("fondo.sh menu")), "Cambiar fondo")
b("SUPER + V",        cmd(S("portapapeles.sh")), "Portapapeles")
b("SUPER + CTRL + V", cmd(S("portapapeles.sh")), "Portapapeles")
b("SUPER + TAB",      cmd(S("ventanas.sh")),     "Lista de ventanas abiertas")
b("SUPER + ALT + P",  cmd(S("modo.sh ciclar")),  "Modo: equilibrado / rendimiento / ahorro")
b("SUPER + ALT + N",  cmd(S("luz.sh alternar")), "Luz nocturna")
b("SUPER + B",        cmd(S("barra.sh ocultar")), "Mostrar / ocultar la barra")
b("SUPER + ALT + B",  cmd(S("barra.sh estilo")),  "Cambiar estilo de la barra")
b("SUPER + CTRL + L", cmd("loginctl lock-session"), "Bloquear pantalla")
b("SUPER + ALT + L",  cmd("loginctl lock-session"), "Bloquear pantalla")

-------------------------------------------------- Notificaciones
b("SUPER + N",             cmd("dunstctl history-pop"),  "Ver la ultima notificacion")
b("SUPER + SHIFT + COMMA", cmd("dunstctl close-all"),    "Cerrar notificaciones")
b("SUPER + SHIFT + N",     cmd(S("notificaciones.sh no-molestar")), "No molestar")

-------------------------------------------------- Capturas
b("PRINT",              cmd(S("captura.sh area")),     "Captura de una zona (se copia)")
b("SHIFT + PRINT",      cmd(S("captura.sh pantalla")), "Captura de la pantalla")
b("ALT + PRINT",        cmd(S("captura.sh ventana")),  "Captura de la ventana")
b("SUPER + SHIFT + S",  cmd(S("captura.sh editar")),   "Captura de una zona y editarla")
b("SUPER + SHIFT + C",  cmd("hyprpicker -a -f hex"),   "Copiar un color de la pantalla")

-------------------------------------------------- Ventanas
b("SUPER + W",         dsp.window.close(), "Cerrar ventana")
b("SUPER + Q",         dsp.window.close(), "Cerrar ventana")
b("SUPER + F",         dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }), "Pantalla completa")
b("SUPER + ALT + F",   dsp.window.fullscreen({ mode = "maximized",  action = "toggle" }), "Maximizar")
b("SUPER + T",         dsp.window.float({ action = "toggle" }), "Flotante / mosaico")
b("SUPER + C",         dsp.window.center(), "Centrar ventana flotante")
b("SUPER + SHIFT + P", dsp.window.pin({ action = "toggle" }), "Fijar ventana en todos los escritorios")
b("SUPER + G",         dsp.group.toggle(), "Agrupar en pestanas")
b("SUPER + ALT + RIGHT", dsp.group.next(), "Siguiente pestana del grupo")
b("SUPER + ALT + LEFT",  dsp.group.prev(), "Pestana anterior del grupo")
b("SUPER + J",         dsp.layout("togglesplit"), "Girar division (mosaico)")
b("SUPER + M",         dsp.window.move({ workspace = "special:minimizadas", follow = false }), "Minimizar")
b("SUPER + SHIFT + M", dsp.workspace.toggle_special("minimizadas"), "Ver minimizadas")

b("ALT + TAB", function()
    hl.dispatch(dsp.window.cycle_next())
    hl.dispatch(dsp.window.alter_zorder({ mode = "top" }))
end, "Siguiente ventana")
b("ALT + SHIFT + TAB", function()
    hl.dispatch(dsp.window.cycle_next({ next = false }))
    hl.dispatch(dsp.window.alter_zorder({ mode = "top" }))
end, "Ventana anterior")

b("SUPER + D", cmd(S("distribucion.sh")), "Cambiar distribucion: mosaico / columnas / principal")

-- Mover el foco, mover la ventana y cambiar su tamano con las flechas
local dirs = { LEFT = "left", RIGHT = "right", UP = "up", DOWN = "down" }
local delta = { LEFT = { -40, 0 }, RIGHT = { 40, 0 }, UP = { 0, -40 }, DOWN = { 0, 40 } }
for tecla, d in pairs(dirs) do
    b("SUPER + " .. tecla,         dsp.focus({ direction = d }), "Foco a la " .. d)
    b("SUPER + SHIFT + " .. tecla, dsp.window.move({ direction = d }), "Mover ventana")
    b("SUPER + CTRL + " .. tecla,
      dsp.window.resize({ x = delta[tecla][1], y = delta[tecla][2], relative = true }),
      "Cambiar tamano", { repeating = true })
end

-- Raton: Super + arrastrar mueve, Super + clic derecho cambia el tamano
hl.bind("SUPER + mouse:272", dsp.window.drag(),   { mouse = true, description = "Mover ventana con el raton" })
hl.bind("SUPER + mouse:273", dsp.window.resize(), { mouse = true, description = "Cambiar tamano con el raton" })

-------------------------------------------------- Escritorios
for i = 1, 10 do
    local k = i % 10
    b("SUPER + " .. k,         dsp.focus({ workspace = i }), "Ir al escritorio " .. i)
    b("SUPER + SHIFT + " .. k, dsp.window.move({ workspace = i }), "Llevar ventana al escritorio " .. i)
    b("SUPER + CTRL + " .. k,  dsp.window.move({ workspace = i, follow = false }), "Enviar ventana al escritorio " .. i)
end
b("SUPER + PAGE_DOWN",  dsp.focus({ workspace = "e+1" }), "Escritorio siguiente")
b("SUPER + PAGE_UP",    dsp.focus({ workspace = "e-1" }), "Escritorio anterior")
b("SUPER + mouse_down", dsp.focus({ workspace = "e+1" }), "Escritorio siguiente")
b("SUPER + mouse_up",   dsp.focus({ workspace = "e-1" }), "Escritorio anterior")
b("SUPER + O",          dsp.focus({ workspace = "empty" }), "Escritorio vacio nuevo")

-------------------------------------------------- Teclas multimedia
local osd = S("osd.sh")
b("XF86AudioRaiseVolume",  cmd(osd .. " subir"),    "Subir volumen",  { locked = true, repeating = true })
b("XF86AudioLowerVolume",  cmd(osd .. " bajar"),    "Bajar volumen",  { locked = true, repeating = true })
b("XF86AudioMute",         cmd(osd .. " silencio"), "Silenciar",      { locked = true })
b("XF86AudioMicMute",      cmd(osd .. " microfono"), "Silenciar microfono", { locked = true })
b("XF86MonBrightnessUp",   cmd(osd .. " brillo+"),  "Subir brillo",   { locked = true, repeating = true })
b("XF86MonBrightnessDown", cmd(osd .. " brillo-"),  "Bajar brillo",   { locked = true, repeating = true })
b("XF86AudioNext",  cmd("playerctl next"),       "Siguiente cancion", { locked = true })
b("XF86AudioPrev",  cmd("playerctl previous"),   "Cancion anterior",  { locked = true })
b("XF86AudioPlay",  cmd("playerctl play-pause"), "Reproducir / pausa", { locked = true })
b("XF86AudioPause", cmd("playerctl play-pause"), "Reproducir / pausa", { locked = true })

-------------------------------------------------- Sesion
b("SUPER + ALT + R", function()
    hl.exec_cmd("hyprctl reload && " .. S("barra.sh reiniciar"))
end, "Recargar Hyprland y la barra")
b("SUPER + SHIFT + E", cmd(S("energia.sh")), "Salir / apagar")
