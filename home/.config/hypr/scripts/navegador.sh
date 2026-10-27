#!/bin/bash
# Abre el navegador predeterminado (sirve en Parrot/Debian y en CachyOS/Arch).
if command -v x-www-browser >/dev/null; then exec x-www-browser "$@"; fi
app=$(xdg-settings get default-web-browser 2>/dev/null)
if [[ -n $app ]] && (($# == 0)); then exec gtk-launch "${app%.desktop}"; fi
for b in firefox chromium brave google-chrome-stable; do
  command -v "$b" >/dev/null && exec "$b" "$@"
done
exec xdg-open "${1:-https://}"
