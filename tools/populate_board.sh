#!/bin/bash
# ============================================================
# populate_board.sh — Puebla el board Projects con los issues
# del PILOTO WOLOF y asigna columna según estado real.
# Columnas: Backlog d1bafce3 · Ready a67b4bb6 · In Progress d1d82990 · Done 6bec6106
# ============================================================
set -e
REPO="qidia-io/global-speak"
PROJECT_NUM=1
OWNER="qidia-io"
FIELD_ESTADO="PVTSSF_lAHOENGz784Bh_XWzhg5D6Q"

COL_BACKLOG="d1bafce3"; COL_READY="a67b4bb6"; COL_INPROG="d1d82990"; COL_DONE="6bec6106"

# Milestones
MS_FASE0=$(gh api "repos/$REPO/milestones" --jq '.[] | select(.title=="Fase 0 — Fundamentos") | .number')
MS_FASE1=$(gh api "repos/$REPO/milestones" --jq '.[] | select(.title=="Fase 1 — Piloto Wolof (es↔wo)") | .number')
MS_SOFT=$(gh api "repos/$REPO/milestones" --jq '.[] | select(.title=="Software (paralelo)") | .number')
echo "Milestones: F0=$MS_FASE0 F1=$MS_FASE1 SW=$MS_SOFT"

# Asignar milestone a issues antiguos (los que no tienen)
assign_ms() {
  local num="$1" ms_num="$2"
  gh api -X PATCH "repos/$REPO/issues/$num" -f milestone="$ms_num" --jq '.milestone.number' >/dev/null 2>&1 \
    && echo "  #$num → milestone $ms_num" || echo "  #$num (ya tenía)"
}

echo "=== 1. ASIGNAR MILESTONES ==="
# Fase 1 (piloto wolof — datos/modelos)
for n in 2 3 4 9 14 15 19 20; do assign_ms $n $MS_FASE1; done
# Software (app/infra/producto)
for n in 5 6 7 8 11 12 13 17 21 22; do assign_ms $n $MS_SOFT; done
# Fase 0 (fundamentos — nodo local ya hecho)
assign_ms 18 $MS_FASE0

echo ""
echo "=== 2. AÑADIR AL BOARD ==="
# Lista de issues del piloto: todos abiertos salvo #16 (bm/ff) y #23 (cerrado bm)
ISSUES=$(gh issue list --repo "$REPO" --state all --limit 50 --json number,state --jq '.[] | select(.state=="OPEN") | .number' 2>/dev/null | grep -vE '^(16|23)$')
for num in $ISSUES; do
  # añadir al board (con --url, sintaxis correcta)
  ITEM_ID=$(gh project item-add $PROJECT_NUM --owner "$OWNER" --url "https://github.com/$REPO/issues/$num" --format json 2>/dev/null | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('id',''))" 2>/dev/null || echo "")
  if [ -n "$ITEM_ID" ]; then
    # determinar columna por label
    LABELS=$(gh issue view "$num" --repo "$REPO" --json labels --jq '[.labels[].name] | join(",")' 2>/dev/null)
    COL=""
    case "$LABELS" in
      *status:done*) COL="$COL_DONE" ;;
      *status:blocked*) COL="$COL_BACKLOG" ;;
      *status:ready*) COL="$COL_READY" ;;
      *) COL="$COL_BACKLOG" ;;
    esac
    # asignar columna
    gh api graphql -f query="mutation {
      updateProjectV2ItemFieldValue(input: {
        projectId: \"PVT_kwHOENGz784Bh_XW\"
        itemId: \"$ITEM_ID\"
        fieldId: \"$FIELD_ESTADO\"
        value: { singleSelectOptionId: \"$COL\" }
      }) { projectV2Item { id } }
    }" --jq '.data.updateProjectV2ItemFieldValue.projectV2Item.id' >/dev/null 2>&1 && \
      echo "  + #$num → board ($LABELS)" || echo "  ! #$num campo falló"
  else
    echo "  ! #$num no añadido"
  fi
done

echo ""
echo "=== HECHO: board poblado ==="
