#!/bin/bash
# Lista de atajos con descripcion (sustituye la hoja de atajos de ii, que end4-pC no trae).
# Lee los atajos cargados en Hyprland, asi siempre esta al dia.
source "$(dirname "$0")/comun.sh"
hyprctl binds -j | python3 -I -c '
import json, sys
mods = [(64, "Super"), (4, "Ctrl"), (8, "Alt"), (1, "Shift")]
nombres = {"Return": "Enter", "bar": "|", "minus": "-", "plus": "+", "braceleft": "{",
           "braceright": "}", "ntilde": "ñ", "apostrophe": "\x27", "Period": ".", "period": "."}
vistos = set()
for b in json.load(sys.stdin):
    d = b.get("description") or ""
    if not d or d in vistos:
        continue
    vistos.add(d)
    tecla = nombres.get(b["key"], b["key"].capitalize() if len(b["key"]) == 1 else b["key"])
    combo = " + ".join([n for m, n in mods if b["modmask"] & m] + [tecla])
    print(f"{combo:<28} {d}")
' | menu "Atajos" --width 80 --lines 20 >/dev/null
