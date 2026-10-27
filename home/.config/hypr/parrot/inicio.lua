-- Programas que arrancan con la sesion.
local P = require("parrot.base")
local S = P.script

-- PARROT_PRUEBA=1: Hyprland en una ventana para probar, sin tocar la sesion real
local prueba = os.getenv("PARROT_PRUEBA") ~= nil

hl.on("hyprland.start", function()
    hl.exec_cmd(S("tema.sh inicio"))
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("hyprctl setcursor WhiteSur-cursors 24")
    if prueba then return end

    -- Que las apps de systemd y D-Bus (portales, polkit) vean esta sesion
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY DISPLAY "
        .. "XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_DESKTOP HYPRLAND_INSTANCE_SIGNATURE "
        .. "QT_QPA_PLATFORM QT_QPA_PLATFORMTHEME XCURSOR_THEME XCURSOR_SIZE && "
        .. "systemctl --user start hyprpolkitagent.service")

    -- Bloqueo por inactividad y perfil de energia del modo guardado
    hl.exec_cmd("hypridle -c " .. P.dir .. "/hypridle.conf")
    hl.exec_cmd(S("modo.sh aplicar"))
end)
