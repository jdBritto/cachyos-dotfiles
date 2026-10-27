-- Aspecto: colores del tema, bordes, desenfoque, sombras y animaciones.
-- El modo (Super + Alt + P) quita efectos para ganar rendimiento:
--   equilibrado -> todos los efectos
--   rendimiento -> sin desenfoque ni sombras, animaciones rapidas
--   ahorro      -> sin efectos ni animaciones (bateria)
local P = require("parrot.base")
local t = P.tema
local efectos = P.modo == "equilibrado"
local animado = P.modo ~= "ahorro"

hl.config({
    general = {
        gaps_in  = 4,
        gaps_out = efectos and 10 or 6,
        border_size = 2,
        col = {
            active_border   = { colors = { P.color(t.acento), P.color(t.acento2) }, angle = 45 },
            inactive_border = P.color(t.borde, "cc"),
        },
        -- Cambiar el tamano arrastrando el borde o el hueco entre ventanas
        resize_on_border        = true,
        extend_border_grab_area = 12,
        hover_icon_on_border    = true,
        layout = P.distribucion,
        -- Las ventanas flotantes se "pegan" al borde de otras y de la pantalla
        snap = { enabled = true, window_gap = 12, monitor_gap = 12 },
    },

    decoration = {
        rounding       = 12,
        rounding_power = 2,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,
        dim_inactive = efectos,
        dim_strength = 0.06,
        dim_special  = 0.4,
        shadow = {
            enabled      = efectos,
            range        = 16,
            render_power = 3,
            color          = P.color("000000", t.modo == "claro" and "40" or "90"),
            color_inactive = P.color("000000", "30"),
        },
        blur = {
            enabled   = efectos,
            size      = 6,
            passes    = 2,
            vibrancy  = 0.17,
            noise     = 0.01,
            popups    = true,
            special   = false, -- desenfocar el fondo del cajon es caro
            new_optimizations = true,
        },
    },

    animations = { enabled = animado },

    group = {
        col = {
            border_active   = { colors = { P.color(t.acento), P.color(t.acento2) }, angle = 45 },
            border_inactive = P.color(t.borde, "cc"),
        },
        groupbar = {
            font_family = "JetBrainsMono Nerd Font",
            font_size   = 11,
            height      = 20,
            gradients   = true,
            rounding    = 8,
            col = {
                active   = P.color(t.acento, "dd"),
                inactive = P.color(t.superficie, "dd"),
            },
            text_color          = P.color(t.bg),
            text_color_inactive = P.color(t.fg),
        },
    },

    dwindle   = { preserve_split = true, smart_resizing = true },
    master    = { new_status = "master", mfact = 0.55 },
    scrolling = { fullscreen_on_one_column = true, column_width = 0.6 },

    misc = {
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        force_default_wallpaper  = 0,
        background_color         = P.color(t.bg),
        focus_on_activate        = true,
        -- Si el bloqueo se cierra por error, se puede volver a bloquear
        allow_session_lock_restore = true,
        mouse_move_enables_dpms  = true,
        key_press_enables_dpms   = true,
        -- La terminal se "traga" la ventana que abre (p. ej. mpv o imv)
        enable_swallow = true,
        swallow_regex  = "^(com\\.mitchellh\\.ghostty|kitty)$",
        -- Ventanas que no tienen el foco se dibujan a menos cuadros por segundo
        render_unfocused_fps = P.modo == "ahorro" and 5 or 15,
        animate_manual_resizes = false,
        font_family = "JetBrainsMono Nerd Font",
    },

    cursor = { hide_on_key_press = true },

    ecosystem = { no_update_news = true, no_donation_nag = true },
})

-- Animaciones (mas rapidas en modo rendimiento)
local v = P.modo == "rendimiento" and 1.6 or 1.0
hl.curve("parrot",   { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })
hl.curve("suave",    { type = "bezier", points = { {0.23, 1},   {0.32, 1}    } })
hl.curve("lineal",   { type = "bezier", points = { {0, 0},      {1, 1}       } })
hl.curve("casi",     { type = "bezier", points = { {0.5, 0.5},  {0.75, 1}    } })
hl.curve("resorte",  { type = "spring", mass = 1, stiffness = 80, dampening = 14 })

local function anim(leaf, speed, curva, estilo)
    local a = { leaf = leaf, enabled = true, speed = speed / v }
    if curva == "resorte" then a.spring = curva else a.bezier = curva end
    if estilo then a.style = estilo end
    hl.animation(a)
end
anim("windows",        4.5, "resorte")
anim("windowsIn",      4.0, "resorte", "popin 85%")
anim("windowsOut",     1.6, "lineal",  "popin 85%")
anim("border",         5.0, "suave")
anim("borderangle",    40,  "lineal")
anim("fade",           3.0, "casi")
anim("layersIn",       3.5, "suave", "slide")
anim("layersOut",      1.5, "lineal", "fade")
anim("fadeLayersIn",   1.8, "casi")
anim("fadeLayersOut",  1.4, "casi")
anim("workspaces",     3.5, "parrot", "slide")
anim("specialWorkspace", 3.5, "parrot", "slidevert")
