#!/bin/bash
# Migración kanban -> GitHub Issues (global-speak)
set -u
cd /root/proyecto/repo

declare -a TITLES=(
  "[INFRA] CI/CD GitHub Actions (build, lint, type-check)"
  "[APP] Despliegue móvil: APK Capacitor → Play/App Store"
  "[INFRA] Backend API FastAPI (desacoplar inferencia)"
  "[ML] Pipeline offline móvil ONNX/TFLite"
  "[DATOS] Descargar FLORES-200 para evaluación multilingüe"
  "[APP] Integrar ByT5 en inferenceClient.ts (selector: ByT5 es↔wo, NLLB resto)"
  "[APP] Pipeline Python standalone pipeline.py (SST→NMT→TTS)"
  "[APP] Cache de inferencia (SQLite/JSON)"
  "[APP] Tests unitarios: inferenceClient, storage, audio"
  "[ML] Evaluación formal ByT5 ES↔WO (BLEU, chrF, COMET)"
  "[VOZ] Test E2E SST→NMT→TTS audio wolof real"
  "[DATOS] Fase 1 BM/FF: NLLB-Seed, Maliba, FrancophonIA, Wikipedia"
  "[PRODUCTO] Especificar sincronización multi-dispositivo"
  "[INFRA] Nodo local: formatear PC 16GB + Ubuntu + Ollama + Hermes local (IA libre 7-14B)"
  "[ML] Limpiar notebooks NMT/SST/TTS (solo PyTorch, sin TF/Colab)"
  "[VOZ] Integrar galsenai/wolof_tts en pipeline TTS"
  "[PRODUCTO] PRD: sistema walkie-talkie SST→NMT→TTS"
  "[PRODUCTO] Diseño UX/UI: flujo pulsar-hablar-soltar"
)

declare -a IDS=(
  "t_00d22847|mbok|ready" "t_7354a08e|mbok|ready" "t_96f6d2a0|mbok|ready"
  "t_a4604989|janus|ready" "t_aeeea91e|sankofa|ready" "t_4e5a7b32|mbok|done"
  "t_7d679f67|mbok|ready" "t_c08dbfc7|mbok|ready" "t_481f0b3a|mbok|ready"
  "t_55aae2ac|janus|ready" "t_0d536c80|echo|ready" "t_398c5eb9|sankofa|ready"
  "t_3be69447|griot|blocked" "t_00d7645f|mbok|ready" "t_8509e325|janus|done"
  "t_ec11a6dd|echo|ready" "t_94d75af4|griot|blocked" "t_5a5e84f5|griot|blocked"
)

i=0
for entry in "${IDS[@]}"; do
  tid="${entry%%|*}"; rest="${entry#*|}"
  agent="${rest%%|*}"; status="${rest##*|}"
  title="${TITLES[$i]}"
  area="${title%%]*}]"
  sflag="status:ready"
  [ "$status" = "done" ] && sflag="status:done"
  [ "$status" = "blocked" ] && sflag="status:blocked"
  body="**Origen:** kanban Hermes (\`$tid\`)\n**Agente:** $agent\n**Estado kanban:** $status\n\nTarea migrada desde el board interno \`global-speak\` al sistema externo de seguimiento."
  out=$(gh issue create --repo qidia-io/global-speak --title "$title" --body "$(printf '%b' "$body")" --label "$area" --label "$sflag" 2>&1 | tail -1)
  echo "$i | $out"
  i=$((i+1))
done
echo "=== DONE ==="
