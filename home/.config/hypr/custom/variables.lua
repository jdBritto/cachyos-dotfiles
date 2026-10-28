-- Variables que lee hyprland/keybinds.lua (cambian las de hyprland/variables.lua)

-- end4-pC como interfaz (README de end4-pC)
hl.env("qsConfig", "end4-pC")

-- Apps: kitty primero (la terminal desplegable tambien es kitty)
local primero = "~/.config/hypr/hyprland/scripts/launch_first_available.sh "
terminal = primero .. "'kitty -1' 'foot' 'alacritty' 'konsole'"
