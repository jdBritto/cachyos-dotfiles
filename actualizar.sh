#!/bin/bash
# Copia tu configuracion actual al repositorio y la sube a GitHub.
# Uso:  ./actualizar.sh "mensaje opcional"

set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Actualiza cada archivo que ya esta en el repositorio con su version actual.
while IFS= read -r -d '' f; do
  rel=${f#"$REPO/home"/}
  if [[ -f $HOME/$rel ]]; then cp -a "$HOME/$rel" "$f"; fi
done < <(find "$REPO/home" -type f -print0)

cd "$REPO"
git add -A
if git diff --cached --quiet; then
  echo "No hay cambios que subir."
else
  git commit -m "${1:-Actualizar configuracion $(date +%F)}"
  git push
  echo "Configuracion subida a GitHub."
fi
