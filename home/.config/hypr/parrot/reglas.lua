-- Reglas de ventanas, capas y escritorios.
local P = require("parrot.base")

local function flotante(nombre, match, ancho, alto)
    hl.window_rule({
        name = nombre, match = match,
        float = true, center = true,
        size = ancho and (ancho .. " " .. alto) or nil,
    })
end

-- Ventanas de ajustes y dialogos: flotantes y centradas
flotante("sonido",     { class = "^(org\\.pulseaudio\\.pavucontrol|pavucontrol)$" }, 820, 560)
flotante("bluetooth",  { class = "^(blueman-manager|\\.blueman-manager-wrapped)$" }, 760, 520)
flotante("redes",      { class = "^(nm-connection-editor)$" }, 760, 520)
flotante("apariencia", { class = "^(nwg-look|qt6ct|kvantummanager)$" }, 900, 640)
flotante("pantallas",  { class = "^(nwg-displays)$" }, 1000, 640)
flotante("calc",       { class = "^(org\\.gnome\\.Calculator|org\\.kde\\.kcalc)$" })
flotante("swappy",     { class = "^(swappy)$" })
flotante("polkit",     { class = "^(hyprpolkitagent|org\\.kde\\.polkit-kde-authentication-agent-1)$" })
flotante("portal",     { class = "^(xdg-desktop-portal-gtk|org\\.freedesktop\\.impl\\.portal\\.desktop\\.kde)$" }, 960, 620)
flotante("dialogos",   { title = "^(Abrir.*|Guardar.*|Open.*|Save.*|Seleccionar.*|Choose.*|Elegir.*)$" }, 960, 620)
flotante("tareas",     { title = "^(Tareas)$" }, 1100, 680)

-- Video flotante (Picture-in-Picture) siempre visible en la esquina
hl.window_rule({
    name = "pip",
    match = { title = "^(Picture-in-Picture|Imagen en imagen)$" },
    float = true, pin = true, size = "480 270",
    move = "monitor_w-500 monitor_h-300",
    keep_aspect_ratio = true,
})

-- Las apps no se maximizan solas (lo decides tu con Super + Alt + F)
hl.window_rule({ name = "sin-maximizar", match = { class = ".*" }, suppress_event = "maximize" })
-- No apagar la pantalla mientras algo esta en pantalla completa (videos, juegos)
hl.window_rule({ name = "video-despierto", match = { class = ".*" }, idle_inhibit = "fullscreen" })

-- Arreglo para arrastres de XWayland
hl.window_rule({
    name  = "xwayland-arrastres",
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
})

-- Desenfoque detras de la barra, el lanzador, las notificaciones y el menu de apagado
for _, ns in ipairs({ "waybar", "launcher", "notifications", "logout_dialog" }) do
    hl.layer_rule({
        name = "blur-" .. ns,
        match = { namespace = "^" .. ns .. "$" },
        blur = true,
        ignore_alpha = 0.3,
    })
end
hl.layer_rule({ name = "anim-launcher", match = { namespace = "^launcher$" }, animation = "popin 90%" })
hl.layer_rule({ name = "anim-logout",   match = { namespace = "^logout_dialog$" }, animation = "fade" })

-- Terminal desplegable (Super + `): se abre sola la primera vez
hl.workspace_rule({
    workspace = "special:terminal",
    on_created_empty = P.programas.terminal,
    gaps_out = 40,
})
