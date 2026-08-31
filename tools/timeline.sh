#!/bin/bash
# ============================================================
# timeline.sh — Asigna fechas inicio/fin a las fases
# Calendario realista desde 01-sep-2026
# ============================================================
set -e
FIELD_INI="PVTF_lAHOENGz784Bh_iWzhg5lOk"
FIELD_FIN="PVTF_lAHOENGz784Bh_iWzhg5lOo"
PROJECT="PVT_kwHOENGz784Bh_iW"

# issue → (inicio, fin)
declare -A INICIO=(
  [35]="2026-09-01"  # F0 Fundamentos
  [41]="2026-10-01"  # F1 Datos
  [42]="2026-11-16"  # F2 SST
  [43]="2027-01-04"  # F3 NMT
  [44]="2027-02-15"  # F4 TTS
  [45]="2027-04-01"  # F5 Integración
  [40]="2026-09-01"  # SW Software (paralelo, empieza ya)
)
declare -A FIN=(
  [35]="2026-09-30"  # F0
  [41]="2026-11-15"  # F1
  [42]="2027-01-03"  # F2
  [43]="2027-02-14"  # F3
  [44]="2027-03-31"  # F4
  [45]="2027-05-31"  # F5
  [40]="2027-05-31"  # SW (hasta el final)
)

for num in 35 40 41 42 43 44 45; do
  ITEM=$(gh project item-list 2 --owner qidia-io --limit 20 --format json 2>/dev/null | python3 -c "
import json,sys
d=json.load(sys.stdin)
for i in d.get('items',[]):
    if i.get('content',{}).get('number')==$num: print(i.get('id')); break
" 2>/dev/null)
  if [ -z "$ITEM" ]; then echo "  ! #$num no encontrado"; continue; fi
  # fecha inicio
  gh api graphql -f query="mutation {
    updateProjectV2ItemFieldValue(input: {
      projectId: \"$PROJECT\"
      itemId: \"$ITEM\"
      fieldId: \"$FIELD_INI\"
      value: { date: \"${INICIO[$num]}\" }
    }) { projectV2Item { id } }
  }" >/dev/null 2>&1 && echo "  #$num inicio ${INICIO[$num]} OK" || echo "  ! #$num inicio falló"
  # fecha fin
  gh api graphql -f query="mutation {
    updateProjectV2ItemFieldValue(input: {
      projectId: \"$PROJECT\"
      itemId: \"$ITEM\"
      fieldId: \"$FIELD_FIN\"
      value: { date: \"${FIN[$num]}\" }
    }) { projectV2Item { id } }
  }" >/dev/null 2>&1 && echo "  #$num fin ${FIN[$num]} OK" || echo "  ! #$num fin falló"
done
echo "=== TIMELINE ASIGNADO ==="
