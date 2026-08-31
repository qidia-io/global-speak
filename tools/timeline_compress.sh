#!/bin/bash
# ============================================================
# timeline_compress.sh — Calendario comprimido:
# objetivo: terminar a MEDIADOS DE NOVIEMBRE 2026
# F0 → F5 secuencial, SW cross todo el tiempo
# ============================================================
set -e
PROJECT="PVT_kwHOENGz784Bh_iW"

# 4 campos de fecha a actualizar
F_INI_ES="PVTF_lAHOENGz784Bh_iWzhg5lOk"   # Fecha inicio
F_FIN_ES="PVTF_lAHOENGz784Bh_iWzhg5lOo"   # Fecha fin
F_START="PVTF_lAHOENGz784Bh_iWzhg5oYE"    # Start date (canónico gantt)
F_DATE="PVTF_lAHOENGz784Bh_iWzhg5oYI"     # Date (canónico gantt)

# issue → inicio,fin  (secuencial: cada fase arranca al terminar la anterior)
declare -A INICIO=(
  [35]="2026-09-01"  # F0 · Fundamentos
  [41]="2026-09-14"  # F1 · Datos y corpus
  [42]="2026-09-28"  # F2 · SST
  [43]="2026-10-12"  # F3 · NMT
  [44]="2026-10-26"  # F4 · TTS
  [45]="2026-11-05"  # F5 · Integración
  [40]="2026-09-01"  # SW · Software (cross desde el inicio)
)
declare -A FIN=(
  [35]="2026-09-13"
  [41]="2026-09-27"
  [42]="2026-10-11"
  [43]="2026-10-25"
  [44]="2026-11-04"
  [45]="2026-11-15"  # ← FIN DEL PROYECTO (mediados noviembre)
  [40]="2026-11-15"  # SW cross hasta el final
)

for num in 35 40 41 42 43 44 45; do
  ITEM=$(gh project item-list 2 --owner qidia-io --limit 20 --format json 2>/dev/null | python3 -c "
import json,sys
d=json.load(sys.stdin)
for i in d.get('items',[]):
    if i.get('content',{}).get('number')==$num: print(i.get('id')); break
" 2>/dev/null)
  if [ -z "$ITEM" ]; then echo "  ! #$num no encontrado"; continue; fi
  for FIELD in "$F_INI_ES:${INICIO[$num]}" "$F_FIN_ES:${FIN[$num]}" "$F_START:${INICIO[$num]}" "$F_DATE:${FIN[$num]}"; do
    FID="${FIELD%%:*}"; VAL="${FIELD##*:}"
    gh api graphql -f query="mutation {
      updateProjectV2ItemFieldValue(input: {
        projectId: \"$PROJECT\"
        itemId: \"$ITEM\"
        fieldId: \"$FID\"
        value: { date: \"$VAL\" }
      }) { projectV2Item { id } }
    }" >/dev/null 2>&1 && echo "  #$num $VAL OK" || echo "  ! #$num $VAL falló"
  done
done
echo "=== CALENDARIO COMPRIMIDO APLICADO ==="
