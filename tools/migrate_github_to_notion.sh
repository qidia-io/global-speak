#!/bin/bash
# Migración GitHub Issues -> Notion BD Tareas global-speak
# Uso: NOTION_DB=6b20b17c-872a-474a-82b0-1f82815308e9 bash tools/migrate_github_to_notion.sh
set -u
TOKEN="$NOTION_API_KEY"
DB="6b20b17c-872a-474a-82b0-1f82815308e9"

# issue_num|titulo|area|estado|agente
declare -a ROWS=(
  "2|Reescribir notebooks ML: SST (HuBERT) + NMT (ByT5) + TTS (MMS)|ML|✅ Done|janus"
  "3|Pipeline offline móvil: exportar modelos a ONNX/TFLite|ML|▶ Ready|janus"
  "4|Ingerir dataset soynade-research/Wolof-ASR-Data + datos propios|DATOS|▶ Ready|sankofa"
  "5|[INFRA] CI/CD GitHub Actions (build, lint, type-check)|INFRA|▶ Ready|mbok"
  "6|[APP] Despliegue móvil: APK Capacitor → Play/App Store|APP|▶ Ready|mbok"
  "7|[INFRA] Backend API FastAPI (desacoplar inferencia)|INFRA|▶ Ready|mbok"
  "8|[ML] Pipeline offline móvil ONNX/TFLite|ML|▶ Ready|janus"
  "9|[DATOS] Descargar FLORES-200 para evaluación multilingüe|DATOS|▶ Ready|sankofa"
  "10|[APP] Integrar ByT5 en inferenceClient.ts (selector: ByT5 es↔wo, NLLB resto)|APP|✅ Done|mbok"
  "11|[APP] Pipeline Python standalone pipeline.py (SST→NMT→TTS)|APP|▶ Ready|mbok"
  "12|[APP] Cache de inferencia (SQLite/JSON)|APP|▶ Ready|mbok"
  "13|[APP] Tests unitarios: inferenceClient, storage, audio|APP|▶ Ready|mbok"
  "14|[ML] Evaluación formal ByT5 ES↔WO (BLEU, chrF, COMET)|ML|▶ Ready|janus"
  "15|[VOZ] Test E2E SST→NMT→TTS audio wolof real|VOZ|▶ Ready|echo"
  "16|[DATOS] Fase 1 BM/FF: NLLB-Seed, Maliba, FrancophonIA, Wikipedia|DATOS|▶ Ready|sankofa"
  "17|[PRODUCTO] Especificar sincronización multi-dispositivo|PRODUCTO|⛔ Blocked|griot"
  "18|[INFRA] Nodo local: formatear PC 16GB + Ubuntu + Ollama + Hermes local (IA libre 7-14B)|INFRA|✅ Done|mbok"
  "19|[ML] Limpiar notebooks NMT/SST/TTS (solo PyTorch, sin TF/Colab)|ML|✅ Done|janus"
  "20|[VOZ] Integrar galsenai/wolof_tts en pipeline TTS|VOZ|▶ Ready|echo"
  "21|[PRODUCTO] PRD: sistema walkie-talkie SST→NMT→TTS|PRODUCTO|⛔ Blocked|griot"
  "22|[PRODUCTO] Diseño UX/UI: flujo pulsar-hablar-soltar|PRODUCTO|⛔ Blocked|griot"
)

ok=0; fail=0
for row in "${ROWS[@]}"; do
  num="${row%%|*}"; rest="${row#*|}"
  title="${rest%%|*}"; rest="${rest#*|}"
  area="${rest%%|*}"; rest="${rest#*|}"
  estado="${rest%%|*}"; agent="${rest##*|}"
  url="https://github.com/qidia-io/global-speak/issues/$num"
  body=$(python3 - "$title" "$estado" "$area" "$agent" "$url" <<'PYEOF'
import json, sys
title, estado, area, agent, url = sys.argv[1:6]
payload = {
  "parent": {"database_id": "6b20b17c-872a-474a-82b0-1f82815308e9"},
  "properties": {
    "Name": {"title": [{"text": {"content": title}}]},
    "Estado": {"select": {"name": estado}},
    "Área": {"select": {"name": area}},
    "Agente": {"select": {"name": agent}},
    "GitHub Issue": {"url": url},
    "Fecha": {"date": {"start": "2026-08-27"}}
  }
}
print(json.dumps(payload))
PYEOF
)
  resp=$(curl -s -X POST "https://api.notion.com/v1/pages" \
    -H "Authorization: Bearer $TOKEN" -H "Notion-Version: 2025-09-03" -H "Content-Type: application/json" \
    -d "$body")
  id=$(echo "$resp" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('id','FAIL: '+d.get('message','?')))" 2>/dev/null)
  if [[ "$id" == FAIL:* ]]; then fail=$((fail+1)); echo "✗ #$num $id"; else ok=$((ok+1)); echo "✓ #$num → $id"; fi
done
echo "=== OK:$ok FAIL:$fail ==="
