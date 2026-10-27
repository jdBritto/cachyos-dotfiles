-- Reglas de ventanas (se suman a las de hyprland/rules.lua).
local function flotante(nombre, match, ancho, alto)
    hl.window_rule({
        name = nombre, match = match,
        float = true, center = true,
        size = ancho and (ancho .. " " .. alto) or nil,
    })
end

-- Ventanas de ajustes y dialogos: flotantes y centradas
flotante("c-sonido",    { class = "^(org\\.pulseaudio\\.pavucontrol|pavucontrol|pavucontrol-qt)$" }, 820, 560)
flotante("c-pantallas", { class = "^(nwg-displays)$" }, 1000, 640)
flotante("c-apariencia",{ class = "^(nwg-look|qt6ct|kvantummanager)$" }, 900, 640)
flotante("c-calc",      { class = "^(org\\.gnome\\.Calculator|org\\.kde\\.kcalc)$" })
flotante("c-dialogos",  { title = "^(Abrir.*|Guardar.*|Seleccionar.*|Elegir.*)$" }, 960, 620)
flotante("c-vpn",       { title = "^(VPN del trabajo)$" }, 900, 520)

-- Video flotante (Picture-in-Picture) siempre visible en la esquina
hl.window_rule({
    name = "c-pip",
    match = { title = "^(Picture-in-Picture|Imagen en imagen)$" },
    float = true, pin = true, size = "480 270",
    move = "monitor_w-500 monitor_h-300",
    keep_aspect_ratio = true,
})

-- No apagar la pantalla mientras algo esta en pantalla completa (videos, juegos)
hl.window_rule({ name = "c-video-despierto", match = { class = ".*" }, idle_inhibit = "fullscreen" })

-- Terminal desplegable (Super + tecla a la izquierda del 1): se abre sola la primera vez
hl.workspace_rule({
    workspace = "special:terminal",
    on_created_empty = "kitty",
    gaps_out = 40,
})
