-- Teclado y opciones que los ajustes de end4-pC no tienen.
--
-- Distribucion del teclado, repeticion, touchpad (desplazamiento natural, clic con
-- dedos, velocidad), distribucion de ventanas y tiempos de inactividad se cambian en
-- los ajustes de end4-pC (Super + Escape > Hyprland). Sus valores iniciales para este
-- equipo los pone scripts/ajustes-end4.py la primera vez.
local B = require("custom.base")

-- Variante, modelo y opciones del teclado de CachyOS ("localectl set-x11-keymap")
local teclado = { variant = "", model = "pc105", options = "" }
local f = io.open("/etc/X11/xorg.conf.d/00-keyboard.conf")
if f then
    for linea in f:lines() do
        local k, v = linea:match('Option%s+"Xkb(%a+)"%s+"([^"]*)"')
        if k and k ~= "Layout" then teclado[k:lower()] = v end
    end
    f:close()
end

hl.config({
    input = {
        kb_variant = teclado.variant,
        kb_model   = teclado.model,
        kb_options = teclado.options,
        touchpad = { tap_to_click = true },
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
    -- Ajustes de cada distribucion (los ajustes de end4-pC pueden cambiarlos)
    dwindle   = { preserve_split = true, smart_resizing = true },
    master    = { new_status = "master", mfact = 0.55 },
    scrolling = { fullscreen_on_one_column = true, column_width = 0.6 },
})

require("custom.pantallas")
