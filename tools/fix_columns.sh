#!/bin/bash
# ============================================================
# fix_columns.sh — Asigna columnas correctas a los issues del
# piloto wolof: los nuevos (#24-#33) → Ready, done → Done, etc.
# ============================================================
set -e
REPO="qidia-io/global-speak"
FIELD_ESTADO="PVTSSF_lAHOENGz784Bh_XWzhg5D6Q"
COL_READY="a67b4bb6"; COL_DONE="6bec6106"; COL_BACKLOG="d1bafce3"
L_READY=12013861768; L_DONE=12013861844

# Añadir label status:ready a los nuevos del piloto y ponerlos en Ready
for num in 24 25 26 27 28 29 30 31 32 33; do
  gh api -X POST "repos/$REPO/issues/$num/labels" -f labels[]="status:ready" >/dev/null 2>&1 || true
  # buscar item id en el board
  ITEM_ID=$(gh project item-list 1 --owner qidia-io --limit 50 --format json 2>/dev/null | python3 -c "
import json,sys
d=json.load(sys.stdin)
for i in d.get('items',[]):
    if i.get('content',{}).get('number')==$num:
        print(i.get('id')); break
" 2>/dev/null)
  if [ -n "$ITEM_ID" ]; then
    gh api graphql -f query="mutation {
      updateProjectV2ItemFieldValue(input: {
        projectId: \"PVT_kwHOENGz784Bh_XW\"
        itemId: \"$ITEM_ID\"
        fieldId: \"$FIELD_ESTADO\"
        value: { singleSelectOptionId: \"$COL_READY\" }
      }) { projectV2Item { id } }
    }" >/dev/null 2>&1 && echo "  #$num → Ready (label status:ready añadido)" || echo "  ! #$num falló"
  fi
done

# Verificación final: mostrar el board con columnas
echo ""
echo "=== VERIFICACIÓN FINAL ==="
gh project item-list 1 --owner qidia-io --limit 50 --format json 2>/dev/null | python3 -c "
import json,sys
d=json.load(sys.stdin)
cols={}
for i in d.get('items',[]):
    # extraer estado de los fieldValues
    estado='?'
    for fv in i.get('fieldValues',{}).get('nodes',[]):
        if fv.get('field',{}).get('name')=='Estado' or (fv.get('name') and fv.get('name') in ('Backlog','Ready','In Progress','Done')):
            estado=fv.get('name',fv.get('name'))
            break
    cols.setdefault(estado,[]).append(i.get('content',{}).get('number'))
for c in ['Backlog','Ready','In Progress','Done','?']:
    if c in cols:
        print(f'{c}: {len(cols[c])} items → {sorted(cols[c])}')
" 2>&1
