-- Opciones propias (se cargan despues de hyprland/general.lua).
-- Teclado, repeticion, touchpad, distribucion e inactividad se cambian en los ajustes
-- de end4-pC (Super + Escape > Hyprland); lo que guardan ahi manda sobre esto.

hl.config({
    input = {
        kb_layout = "latam",              -- teclado latinoamericano
        touchpad = { tap_to_click = true },
    },
    binds = {
        -- En Hyprland 0.56 con true, Super + numero vuelve al escritorio anterior al instante
        workspace_back_and_forth = false,
        allow_workspace_cycles   = true,
    },
    misc = {
        -- La terminal se "traga" la ventana que abre (p. ej. mpv o imv)
        enable_swallow = true,
        swallow_regex  = "^(kitty|foot)$",
    },
    ecosystem = { no_update_news = true, no_donation_nag = true },
    dwindle   = { smart_resizing = true },
    master    = { new_status = "master", mfact = 0.55 },
    scrolling = { fullscreen_on_one_column = true, column_width = 0.6 },
})

-- Pantallas guardadas por nwg-displays en monitors.conf (Centro > Pantallas)
require("custom.pantallas")
-- Modos de energia (Super + Alt + P)
require("custom.modo")
