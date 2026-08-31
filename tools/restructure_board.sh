#!/bin/bash
# ============================================================
# restructure_board.sh — PASO 1: títulos limpios + agentes
# Quita los prefijos [AREA] de los títulos (pasan a labels
# reales) y asigna el agente responsable a cada issue.
# ============================================================
set -e
REPO="qidia-io/global-speak"

# Mapa: issue → agente (según responsabilidad del equipo)
declare -A AGENTE=(
  [2]="agente:janus"   # notebooks ML
  [3]="agente:janus"   # exportar ONNX
  [4]="agente:sankofa" # dataset ASR
  [5]="agente:mbok"    # CI/CD
  [6]="agente:mbok"    # APK
  [7]="agente:mbok"    # backend
  [8]="agente:janus"   # ONNX pipeline
  [9]="agente:sankofa" # FLORES
  [10]="agente:mbok"   # ByT5 inferenceClient
  [11]="agente:mbok"   # pipeline.py
  [12]="agente:mbok"   # cache
  [13]="agente:mbok"   # tests
  [14]="agente:janus"  # eval ByT5
  [15]="agente:echo"   # test E2E voz
  [17]="agente:griot"  # sync producto
  [18]="agente:griot"  # nodo local
  [19]="agente:janus"  # limpiar notebooks
  [20]="agente:echo"   # TTS galsenai
  [21]="agente:griot"  # PRD
  [22]="agente:griot"  # UX/UI
  [24]="agente:echo"   # eval SST
  [25]="agente:echo"   # eval TTS
  [26]="agente:sankofa" # corpus TTS
  [27]="agente:sankofa" # test set SST
  [28]="agente:mbok"   # pantalla investigación
  [29]="agente:sankofa" # gestión modelos
  [30]="agente:mbok"   # runner ONNX
  [31]="agente:mbok"   # selector idioma
  [32]="agente:mbok"   # grabación audio
  [33]="agente:echo"   # E2E conversación
)

echo "=== LIMPIAR TÍTULOS + ASIGNAR AGENTES ==="
for num in "${!AGENTE[@]}"; do
  agente="${AGENTE[$num]}"
  # título actual
  TITLE=$(gh issue view "$num" --repo "$REPO" --json title --jq '.title' 2>/dev/null)
  # quitar prefijo [AREA] al inicio
  CLEAN=$(echo "$TITLE" | sed -E 's/^\[[A-Z]+\] ?//')
  if [ "$CLEAN" != "$TITLE" ]; then
    gh api -X PATCH "repos/$REPO/issues/$num" -f title="$CLEAN" >/dev/null 2>&1 && echo "  #$num título: '$TITLE' → '$CLEAN'" || echo "  ! #$num título falló"
  fi
  # añadir label de agente (si no lo tiene)
  HAS=$(gh issue view "$num" --repo "$REPO" --json labels --jq "[.labels[].name] | index(\"$agente\")" 2>/dev/null)
  if [ "$HAS" = "null" ] || [ -z "$HAS" ]; then
    gh api -X POST "repos/$REPO/issues/$num/labels" -f labels[]="$agente" >/dev/null 2>&1 && echo "  #$num + $agente"
  fi
done
echo "=== HECHO ==="
