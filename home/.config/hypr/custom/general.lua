-- Teclado del sistema, touchpad y pantallas guardadas con nwg-displays.
local B = require("custom.base")

-- La distribucion del teclado se toma de CachyOS (la que guarda "localectl set-x11-keymap")
local teclado = { layout = "us", variant = "", model = "pc105", options = "" }
local f = io.open("/etc/X11/xorg.conf.d/00-keyboard.conf")
if f then
    for linea in f:lines() do
        local k, v = linea:match('Option%s+"Xkb(%a+)"%s+"([^"]*)"')
        if k then teclado[k:lower()] = v end
    end
    f:close()
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
        touchpad = {
            natural_scroll       = true,
            tap_to_click         = true,
            disable_while_typing = true,
            clickfinger_behavior = true,
            scroll_factor        = 0.8,
        },
    },
    binds = {
        -- Pulsar otra vez el numero del escritorio actual vuelve al anterior
        workspace_back_and_forth = true,
        allow_workspace_cycles   = true,
    },
    misc = {
        -- Si el bloqueo se cierra por error, se puede volver a bloquear
        allow_session_lock_restore = true,
        -- La terminal se "traga" la ventana que abre (p. ej. mpv o imv)
        enable_swallow = true,
        swallow_regex  = "^(kitty|com\\.mitchellh\\.ghostty)$",
    },
    ecosystem = { no_update_news = true, no_donation_nag = true },
})

require("custom.pantallas")
