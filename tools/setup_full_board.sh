#!/bin/bash
# ============================================================
# setup_full_board.sh — Roadmap completo del proyecto global-speak
# Crea: columnas del board + milestones + backlog completo por
# idioma×pipeline×etapa, y puebla el board Projects.
# ============================================================
set -e
REPO="qidia-io/global-speak"
BOARD_ID="PVT_kwHOENGz784Bh_XW"
PROJECT_NUM=1
OWNER="qidia-io"
REPO_ID=1291425146

# Labels
L_APP=12013853890; L_DATOS=12013854125; L_INFRA=12013854204
L_ML=12013853969; L_PRODUCTO=12013854248; L_VOZ=12013854037
L_READY=12013861768; L_DONE=12013861844; L_BLOCKED=12013861925
L_ALTA=12013855847; L_MEDIA=12013855918; L_BAJA=12013855991

echo "=== 1. COLUMNAS DEL BOARD (campo custom Estado con 4 columnas) ==="
# El Status por defecto no puede borrarse (solo custom). El campo custom
# "Estado" (PVTSSF_lAHOENGz784Bh_XWzhg5D6Q) ya existe con Backlog/Ready/In Progress/Done.
echo "Campo Estado: PVTSSF_lAHOENGz784Bh_XWzhg5D6Q (Backlog/Ready/In Progress/Done)"

echo ""
echo "=== 2. MILESTONES ==="
create_milestone() {
  local title="$1"
  local existing
  existing=$(gh api "repos/$REPO/milestones" --jq ".[] | select(.title==\"$title\") | .number" 2>/dev/null || true)
  if [ -z "$existing" ]; then
    local num
    num=$(gh api -X POST "repos/$REPO/milestones" -f title="$title" --jq '.number')
    echo "  + $title (#$num)"
  else
    echo "  = $title ya existe (#$existing)"
  fi
}
create_milestone "Fase 0 — Fundamentos"
create_milestone "Fase 1 — Piloto Wolof (es↔wo)"
create_milestone "Fase 2 — Bambara (bm)"
create_milestone "Fase 3 — Fula (ff)"
create_milestone "Fase 4 — Otras lenguas (srr, dyo, snk)"
create_milestone "Software (paralelo)"

echo ""
echo "=== 3. BACKLOG COMPLETO (issues nuevos) ==="
# Los issues ya existentes (#5-#22) se reutilizan; creamos los de la matriz por idioma.

create_issue() {
  local title="$1" labels="$2" ms="$3"
  local existing
  existing=$(gh issue list --repo "$REPO" --state all --limit 100 --json title --jq ".[] | select(.title==\"$title\") | .number" 2>/dev/null | head -1)
  if [ -z "$existing" ]; then
    local num
    num=$(gh issue create --repo "$REPO" --title "$title" --label "$labels" --milestone "$ms" --body "Generada por setup_full_board.sh — backlog completo del proyecto." 2>/dev/null | grep -oE '[0-9]+$' | head -1 || echo "")
    if [ -n "$num" ]; then echo "  + #$num $title"; else echo "  ! fallo: $title"; fi
  else
    echo "  = #$existing (ya existe)"
  fi
}

# --- FASE 2: BAMBARA (bm) — NMT ---
create_issue "[DATOS] bm: Recolección corpus NMT es↔bm (NLLB-Seed, Maliba, FrancophonIA)" "[DATOS]" "Fase 2 — Bambara (bm)"
create_issue "[DATOS] bm: Limpieza y dedup de pares es↔bm" "[DATOS]" "Fase 2 — Bambara (bm)"
create_issue "[DATOS] bm: Estandarización y tokenización del corpus" "[DATOS]" "Fase 2 — Bambara (bm)"
create_issue "[ML] bm: Fine-tune ByT5 es↔bm" "[ML]" "Fase 2 — Bambara (bm)"
create_issue "[ML] bm: Evaluación formal (BLEU, chrF, COMET)" "[ML]" "Fase 2 — Bambara (bm)"
create_issue "[ML] bm: Registrar modelo en HF Hub" "[ML]" "Fase 2 — Bambara (bm)"
# --- FASE 2: BAMBARA — SST ---
create_issue "[DATOS] bm: Recolección de audio para SST" "[DATOS]" "Fase 2 — Bambara (bm)"
create_issue "[VOZ] bm: Fine-tune modelo SST (HuBERT/Wav2Vec2)" "[VOZ]" "Fase 2 — Bambara (bm)"
create_issue "[VOZ] bm: Evaluación WER" "[VOZ]" "Fase 2 — Bambara (bm)"
# --- FASE 2: BAMBARA — TTS ---
create_issue "[DATOS] bm: Recolección audio+texto para TTS" "[DATOS]" "Fase 2 — Bambara (bm)"
create_issue "[VOZ] bm: Entrenar/fine-tune TTS" "[VOZ]" "Fase 2 — Bambara (bm)"
create_issue "[VOZ] bm: Integración en pipeline SST→NMT→TTS" "[VOZ]" "Fase 2 — Bambara (bm)"
create_issue "[APP] bm: Añadir bambara a la app (selector, rutas)" "[APP]" "Fase 2 — Bambara (bm)"

# --- FASE 3: FULA (ff) — NMT ---
create_issue "[DATOS] ff: Recolección corpus NMT es↔ff (NLLB-Seed, Wikipedia)" "[DATOS]" "Fase 3 — Fula (ff)"
create_issue "[DATOS] ff: Limpieza y dedup de pares es↔ff" "[DATOS]" "Fase 3 — Fula (ff)"
create_issue "[DATOS] ff: Estandarización y tokenización del corpus" "[DATOS]" "Fase 3 — Fula (ff)"
create_issue "[ML] ff: Fine-tune ByT5 es↔ff" "[ML]" "Fase 3 — Fula (ff)"
create_issue "[ML] ff: Evaluación formal (BLEU, chrF, COMET)" "[ML]" "Fase 3 — Fula (ff)"
create_issue "[ML] ff: Registrar modelo en HF Hub" "[ML]" "Fase 3 — Fula (ff)"
# --- FASE 3: FULA — SST ---
create_issue "[DATOS] ff: Recolección de audio para SST" "[DATOS]" "Fase 3 — Fula (ff)"
create_issue "[VOZ] ff: Fine-tune modelo SST (HuBERT/Wav2Vec2)" "[VOZ]" "Fase 3 — Fula (ff)"
create_issue "[VOZ] ff: Evaluación WER" "[VOZ]" "Fase 3 — Fula (ff)"
# --- FASE 3: FULA — TTS ---
create_issue "[DATOS] ff: Recolección audio+texto para TTS" "[DATOS]" "Fase 3 — Fula (ff)"
create_issue "[VOZ] ff: Entrenar/fine-tune TTS" "[VOZ]" "Fase 3 — Fula (ff)"
create_issue "[VOZ] ff: Integración en pipeline SST→NMT→TTS" "[VOZ]" "Fase 3 — Fula (ff)"
create_issue "[APP] ff: Añadir fula a la app (selector, rutas)" "[APP]" "Fase 3 — Fula (ff)"

# --- FASE 4: OTRAS LENGUAS (srr, dyo, snk) ---
for LANG in "srr:Serer" "dyo:Jola" "snk:Soninké"; do
  CODE="${LANG%%:*}"; NAME="${LANG##*:}"
  create_issue "[DATOS] $CODE: Recolección corpus NMT (NLLB-Seed)" "[DATOS]" "Fase 4 — Otras lenguas (srr, dyo, snk)"
  create_issue "[ML] $CODE: Fine-tune NMT + registro HF Hub" "[ML]" "Fase 4 — Otras lenguas (srr, dyo, snk)"
  create_issue "[VOZ] $CODE: SST + TTS básico" "[VOZ]" "Fase 4 — Otras lenguas (srr, dyo, snk)"
  create_issue "[DATOS] $CODE: Estandarización ortográfica ($NAME)" "[DATOS]" "Fase 4 — Otras lenguas (srr, dyo, snk)"
done

# --- SOFTWARE (paralelo) — huecos que faltan ---
create_issue "[APP] i18n de la interfaz (es, wo, bm, ff)" "[APP]" "Software (paralelo)"
create_issue "[APP] Persistencia local de conversaciones" "[APP]" "Software (paralelo)"
create_issue "[INFRA] Monitoreo de errores de inferencia" "[INFRA]" "Software (paralelo)"
create_issue "[DATOS] Pipeline ETL automatizado por idioma" "[DATOS]" "Software (paralelo)"

echo ""
echo "=== HECHO: milestones + backlog ==="
