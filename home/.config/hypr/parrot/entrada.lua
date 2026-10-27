-- Teclado, raton, touchpad y gestos.
-- La distribucion del teclado se toma del sistema: /etc/default/keyboard en
-- Parrot/Debian, /etc/X11/xorg.conf.d/00-keyboard.conf en CachyOS/Arch
-- (lo que guarda "localectl set-x11-keymap").
local teclado = { layout = "us", variant = "", model = "pc105", options = "" }
local f = io.open("/etc/default/keyboard")
if f then
    for linea in f:lines() do
        local k, v = linea:match('^XKB(%u+)="?([^"]*)"?')
        if k then teclado[k:lower()] = v end
    end
    f:close()
else
    f = io.open("/etc/X11/xorg.conf.d/00-keyboard.conf")
    if f then
        for linea in f:lines() do
            local k, v = linea:match('Option%s+"Xkb(%a+)"%s+"([^"]*)"')
            if k then teclado[k:lower()] = v end
        end
        f:close()
    end
end

hl.config({
    input = {
        kb_layout  = teclado.layout,
        kb_variant = teclado.variant,
        kb_model   = teclado.model,
        kb_options = teclado.options,
        numlock_by_default = true,
        repeat_delay = 300,
        repeat_rate  = 35,
        follow_mouse = 1,
        sensitivity  = 0,
        touchpad = {
            natural_scroll       = true,
            tap_to_click         = true,
            disable_while_typing = true,
            clickfinger_behavior = true,
            scroll_factor        = 0.8,
        },
    },
    gestures = {
        workspace_swipe_create_new   = true,
        workspace_swipe_cancel_ratio = 0.3,
    },
    binds = {
        -- Pulsar otra vez el numero del escritorio actual vuelve al anterior
        workspace_back_and_forth = true,
        allow_workspace_cycles   = true,
    },
})

-- Tres dedos a los lados: cambiar de escritorio
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
-- Tres dedos arriba / abajo: pantalla completa
hl.gesture({ fingers = 3, direction = "up",   action = "fullscreen" })
hl.gesture({ fingers = 3, direction = "down", action = "fullscreen" })
-- Cuatro dedos arriba: ventanas minimizadas
hl.gesture({ fingers = 4, direction = "up", action = "special", workspace_name = "minimizadas" })
