-- Variables que lee hyprland/keybinds.lua (cambian las de hyprland/variables.lua).

-- La interfaz: ~/.config/quickshell/end4-pC
hl.env("qsConfig", "end4-pC")

local primero = "~/.config/hypr/hyprland/scripts/launch_first_available.sh "
terminal    = primero .. "'kitty -1' 'ghostty' 'foot' 'alacritty' 'konsole'"
fileManager = primero .. "'dolphin' 'nautilus' 'thunar'"
browser     = primero .. "'firefox' 'google-chrome-stable' 'chromium' 'brave'"
