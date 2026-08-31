#!/bin/bash
# ============================================================
# timeline_canonical.sh — Asigna fechas a campos canónicos
# "Start date" y "Date" que el ROADMAP_LAYOUT reconoce
# ============================================================
set -e
FIELD_START="PVTF_lAHOENGz784Bh_iWzhg5oYE"  # Start date
FIELD_DATE="PVTF_lAHOENGz784Bh_iWzhg5oYI"   # Date (fin)
PROJECT="PVT_kwHOENGz784Bh_iW"

declare -A INICIO=(
  [35]="2026-09-01"  # F0
  [41]="2026-10-01"  # F1
  [42]="2026-11-16"  # F2
  [43]="2027-01-04"  # F3
  [44]="2027-02-15"  # F4
  [45]="2027-04-01"  # F5
  [40]="2026-09-01"  # SW
)
declare -A FIN=(
  [35]="2026-09-30"
  [41]="2026-11-15"
  [42]="2027-01-03"
  [43]="2027-02-14"
  [44]="2027-03-31"
  [45]="2027-05-31"
  [40]="2027-05-31"  # SW cross
)

for num in 35 40 41 42 43 44 45; do
  ITEM=$(gh project item-list 2 --owner qidia-io --limit 20 --format json 2>/dev/null | python3 -c "
import json,sys
d=json.load(sys.stdin)
for i in d.get('items',[]):
    if i.get('content',{}).get('number')==$num: print(i.get('id')); break
" 2>/dev/null)
  if [ -z "$ITEM" ]; then echo "  ! #$num no encontrado"; continue; fi
  gh api graphql -f query="mutation {
    updateProjectV2ItemFieldValue(input: {
      projectId: \"$PROJECT\"
      itemId: \"$ITEM\"
      fieldId: \"$FIELD_START\"
      value: { date: \"${INICIO[$num]}\" }
    }) { projectV2Item { id } }
  }" >/dev/null 2>&1 && echo "  #$num Start date ${INICIO[$num]} OK" || echo "  ! #$num Start falló"
  gh api graphql -f query="mutation {
    updateProjectV2ItemFieldValue(input: {
      projectId: \"$PROJECT\"
      itemId: \"$ITEM\"
      fieldId: \"$FIELD_DATE\"
      value: { date: \"${FIN[$num]}\" }
    }) { projectV2Item { id } }
  }" >/dev/null 2>&1 && echo "  #$num Date ${FIN[$num]} OK" || echo "  ! #$num Date falló"
done
echo "=== OK ==="
