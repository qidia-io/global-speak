#!/bin/bash
# ============================================================
# setup_piloto_wolof.sh — Backlog del PILOTO WOLOF completo
# Foco: sistema end-to-end es↔wo (solo wolof). Los demás
# idiomas replicarán esta plantilla en fases posteriores.
# ============================================================
set -e
REPO="qidia-io/global-speak"

echo "=== 0. LIMPIEZA: cerrar #23 (bm, fuera del piloto) ==="
gh issue close 23 --repo "$REPO" --comment "Fuera del alcance del piloto wolof. Se reabre en Fase 2 (Bambara)." 2>&1 | head -1

create_issue() {
  local title="$1" labels="$2" ms="$3" body="$4"
  local existing
  existing=$(gh issue list --repo "$REPO" --state all --limit 100 --json title --jq ".[] | select(.title==\"$title\") | .number" 2>/dev/null | head -1)
  if [ -z "$existing" ]; then
    local num
    num=$(gh issue create --repo "$REPO" --title "$title" --label "$labels" --milestone "$ms" --body "$body" 2>/dev/null | grep -oE '[0-9]+$' | head -1 || echo "")
    if [ -n "$num" ]; then echo "  + #$num $title"; else echo "  ! fallo: $title"; fi
  else
    echo "  = #$existing (ya existe)"
  fi
}

echo ""
echo "=== 1. PILOTO WOLOF — huecos que faltan (SST/NMT/TTS completos) ==="
# Evaluación formal de cada componente (el piloto necesita métricas reales)
create_issue "[ML] Evaluación formal SST wolof (WER sobre test set)" "[ML]" "Fase 1 — Piloto Wolof (es↔wo)" "Métricas reales del SST HuBERT-CTC: WER en test set separado, comparado con whisper. Objetivo: <30% WER."
create_issue "[VOZ] Evaluación TTS wolof (naturalidad, inteligibilidad)" "[VOZ]" "Fase 1 — Piloto Wolof (es↔wo)" "Evaluar galsenai/wolof_tts vs mms-tts: MOS subjetivo, inteligibilidad con hablantes nativos."
create_issue "[DATOS] Corpus TTS wolof (audio+texto) para fine-tune" "[DATOS]" "Fase 1 — Piloto Wolof (es↔wo)" "Recopilar audio wolof + transcripciones (Common Voice wo, datos propios) para entrenar TTS de calidad."
create_issue "[DATOS] Test set SST wolof (evaluación real, no train)" "[DATOS]" "Fase 1 — Piloto Wolof (es↔wo)" "Split train/test limpio del dataset Wolof-ASR. El test NO puede estar en el train."

echo ""
echo "=== 2. SISTEMA + APP — modo investigación/offline ==="
create_issue "[APP] Pantalla 'Investigación': cargar modelos locales offline" "[APP]" "Software (paralelo)" "Modo sin conexión: seleccionar modelos (SST/NMT/TTS) descargados localmente. Es la opción de investigación que permite usar todos los modelos sin API."
create_issue "[INFRA] Descarga y gestión de modelos locales (HF Hub → dispositivo)" "[INFRA]" "Software (paralelo)" "Gestor de descargas: HF Hub → almacenamiento local, versionado, espacio ocupado, borrado."
create_issue "[APP] Runner local ONNX/TFLite (inferencia sin red)" "[APP]" "Software (paralelo)" "Ejecutar modelos exportados ONNX/TFLite en el dispositivo sin conexión a internet."
create_issue "[APP] Selector de idioma ES↔WO funcional en la app" "[APP]" "Software (paralelo)" "Selector visible: Español ↔ Wolof, que enruta por el Model Router (ByT5)."
create_issue "[APP] Grabación de audio + reproducción TTS en la app" "[APP]" "Software (paralelo)" "Micro: grabar voz (pulsar-hablar), reproducir audio sintetizado. Corazón del walkie-talkie."
create_issue "[VOZ] Conversación completa E2E en wolof dentro de la app" "[VOZ]" "Software (paralelo)" "Flujo real: hablar wolof → SST → NMT → TTS → oír español, todo dentro de la app."

echo ""
echo "=== HECHO: piloto wolof completo ==="
