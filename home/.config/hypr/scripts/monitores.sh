#!/bin/bash
# Configurar pantallas con nwg-displays y aplicar al cerrarlo.
source "$(dirname "$0")/comun.sh"
nwg-displays -m "$HYPR/monitors.conf"
hyprctl reload >/dev/null
