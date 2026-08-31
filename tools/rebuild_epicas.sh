#!/bin/bash
# ============================================================
# rebuild_epicas.sh — Reconstruye las épicas por COMPONENTE
# (no por lengua). F0 y SW se mantienen; el resto se rehace.
# ============================================================
set -e
REPO="qidia-io/global-speak"

# milestones nuevos
MS0=$(gh api "repos/$REPO/milestones" --jq '.[] | select(.title=="Fase 0 — Fundamentos") | .number')
MS1=$(gh api "repos/$REPO/milestones" --jq '.[] | select(.title=="Fase 1 — Datos y corpus") | .number')
MS2=$(gh api "repos/$REPO/milestones" --jq '.[] | select(.title=="Fase 2 — SST (reconocimiento)") | .number')
MS3=$(gh api "repos/$REPO/milestones" --jq '.[] | select(.title=="Fase 3 — NMT (traducción)") | .number')
MS4=$(gh api "repos/$REPO/milestones" --jq '.[] | select(.title=="Fase 4 — TTS (síntesis)") | .number')
MS5=$(gh api "repos/$REPO/milestones" --jq '.[] | select(.title=="Fase 5 — Integración y publicación") | .number')
MSSW=$(gh api "repos/$REPO/milestones" --jq '.[] | select(.title=="Software (paralelo)") | .number')
echo "Milestones: F0=$MS0 F1=$MS1 F2=$MS2 F3=$MS3 F4=$MS4 F5=$MS5 SW=$MSSW"

# Cerrar épicas antiguas que estaban por lengua
for n in 36 37 38 39; do
  gh issue close "$n" --repo "$REPO" --comment "Reestructurada: las fases son por componente del sistema, no por lengua. Ver nuevas épicas." 2>&1 | head -1
done

create_epica() {
  local title="$1" ms="$2" body_file="$3"
  local existing
  existing=$(gh issue list --repo "$REPO" --state all --limit 100 --json title --jq ".[] | select(.title==\"$title\") | .number" 2>/dev/null | head -1)
  if [ -z "$existing" ]; then
    local num
    num=$(gh api -X POST "repos/$REPO/issues" \
      -f title="$title" -f milestone="$ms" \
      -F "body=@$body_file" -f labels[]="enhancement" --jq '.number' 2>/dev/null || echo "")
    if [ -n "$num" ]; then echo "  + #$num $title"; else echo "  ! fallo: $title"; fi
  else
    echo "  = #$existing (ya existe)"
  fi
}

mkdir -p /tmp/epicas

cat > /tmp/epicas/f1.md <<'EOF'
## Objetivo
Recopilar y organizar TODOS los datos que alimentan el sistema: pares de traducción, audios, transcripciones. La lengua piloto es el wolof; el resto se añade después dentro de esta misma fase.

## Subfases
### 1.1 Pares de traducción ES↔WO
- [ ] Recolección de pares: FLORES-200, NLLB-Seed, corpus propios (sankofa)
- [ ] Limpieza y filtrado de pares (duplicados, ruido, alineación)
- [ ] Estandarizado: formato, codificación, normalización de texto

### 1.2 Audio ASR (SST)
- [ ] Ingerir Wolof-ASR-Data (86.5k audios) + datos propios (sankofa)
- [ ] Test set limpio, separado del train (sankofa)
- [ ] Organización del dataset (train/dev/test)

### 1.3 Audio TTS
- [ ] Corpus TTS wolof: audio + transcripciones (sankofa)
- [ ] Limpieza y segmentación de audios

### 1.4 Organización general
- [ ] Estructura de datos definitiva (directorios, formatos, metadatos)
- [ ] Documentación del corpus (procedencia, licencias, estadísticas)

## Agentes
sankofa (protagonista) · janus (consulta técnica) · nemrod (decisiones de estructura)

## Dependencias
F0 cerrada (estructura de datos definida)

## Criterio de salida
Corpus wolof completo, limpio y documentado. Métricas de volumen por split.
EOF

cat > /tmp/epicas/f2.md <<'EOF'
## Objetivo
Construir el módulo SST (Speech-to-Text): scripts de entrenamiento, entrenamiento del modelo y evaluación. En wolof primero.

## Subfases
### 2.1 Scripts de entrenamiento
- [ ] Script de fine-tune HuBERT/Wav2Vec2-CTC (janus)
- [ ] Configuración de hiperparámetros (janus)
- [ ] DataLoader y preprocesado de audio (janus)

### 2.2 Entrenamiento (RunPod u otro)
- [ ] Contratar/configurar RunPod (nemrod)
- [ ] Entrenar modelo SST wolof (janus)
- [ ] Registrar checkpoints y métricas (janus)

### 2.3 Investigación offline
- [ ] Investigar exportación a ONNX/TFLite del SST (janus + mbok)
- [ ] Documentar opciones de cuantización (INT8/FP16)

### 2.4 Evaluación
- [ ] Evaluación WER sobre test set (echo)
- [ ] Documentar resultados (echo)

## Agentes
janus (scripts y entrenamiento) · echo (evaluación de voz) · mbok (offline) · nemrod (infra RunPod)

## Dependencias
F1 cerrada (datos organizados)

## Criterio de salida
Modelo SST wolof con WER documentado, exportable a móvil.
EOF

cat > /tmp/epicas/f3.md <<'EOF'
## Objetivo
Construir el módulo NMT (Neural Machine Translation): scripts, entrenamiento y evaluación ES↔WO.

## Subfases
### 3.1 Scripts de entrenamiento
- [ ] Script fine-tune ByT5 (es↔wo) (janus)
- [ ] Tokenización y preparación de batches (janus)
- [ ] Configuración de hiperparámetros (janus)

### 3.2 Entrenamiento (RunPod u otro)
- [ ] Entrenar ByT5 ES↔WO (janus)
- [ ] Registrar checkpoints y métricas (janus)

### 3.3 Investigación offline
- [ ] Exportación ONNX/TFLite del NMT (janus + mbok)
- [ ] Documentar cuantización y tamaño final

### 3.4 Evaluación
- [ ] Evaluación BLEU, chrF, COMET (janus)
- [ ] Documentar resultados

## Agentes
janus (protagonista) · mbok (offline) · echo (integración voz)

## Dependencias
F1 cerrada (pares de traducción listos)

## Criterio de salida
Modelo NMT ES↔WO con métricas documentadas, exportable a móvil.
EOF

cat > /tmp/epicas/f4.md <<'EOF'
## Objetivo
Construir el módulo TTS (Text-to-Speech): scripts, entrenamiento y evaluación de voz sintetizada en wolof.

## Subfases
### 4.1 Scripts de entrenamiento
- [ ] Script fine-tune MMS-TTS / XTTS-v2 (janus)
- [ ] Preprocesado de audio + texto (janus)

### 4.2 Entrenamiento (RunPod u otro)
- [ ] Entrenar TTS wolof (janus)
- [ ] Registrar checkpoints (janus)

### 4.3 Investigación offline
- [ ] Exportación ONNX/TFLite del TTS (janus + mbok)
- [ ] Documentar tamaño y latencia

### 4.4 Evaluación
- [ ] Evaluación naturalidad + inteligibilidad (echo + hablantes nativos)
- [ ] Documentar resultados

## Agentes
janus (scripts/entrenamiento) · echo (evaluación audio) · mbok (offline)

## Dependencias
F1 cerrada (corpus TTS listo)

## Criterio de salida
Modelo TTS wolof de calidad aceptable, exportable a móvil.
EOF

cat > /tmp/epicas/f5.md <<'EOF'
## Objetivo
Integrar todos los módulos en el producto final: app con modelos offline, publicación y testeos.

## Subfases
### 5.1 Integración
- [ ] Pipeline completo SST→NMT→TTS en producción (echo + mbok)
- [ ] Conversación E2E real en wolof (echo)
- [ ] Pruebas de integración completas

### 5.2 App final
- [ ] Selector de idioma funcional (mbok)
- [ ] Modo offline con todos los modelos locales (mbok)
- [ ] Tests de usuario final

### 5.3 Publicación
- [ ] APK Capacitor → Play Store (mbok)
- [ ] Documentación de usuario (griot)

### 5.4 Testeos finales
- [ ] Test E2E con hablantes reales (griot + equipo)
- [ ] Corrección de incidencias

## Agentes
mbok (app) · echo (voz) · griot (producto) · nemrod (coordinación)

## Dependencias
F2, F3, F4 cerradas + SW maduro

## Criterio de salida
App publicada que traduce wolof↔español offline con todos los modelos locales.
EOF

echo "=== ÉPICAS POR COMPONENTE ==="
create_epica "F1 · Datos y corpus — recopilación, limpieza y organización" "$MS1" /tmp/epicas/f1.md
create_epica "F2 · SST — scripts, entrenamiento y offline" "$MS2" /tmp/epicas/f2.md
create_epica "F3 · NMT — scripts, entrenamiento y offline" "$MS3" /tmp/epicas/f3.md
create_epica "F4 · TTS — scripts, entrenamiento y offline" "$MS4" /tmp/epicas/f4.md
create_epica "F5 · Integración — app, publicación y testeos" "$MS5" /tmp/epicas/f5.md

echo ""
echo "=== AÑADIR AL BOARD DE FASES ==="
for num in $(gh issue list --repo "$REPO" --state open --limit 50 --json number --jq '.[].number' 2>/dev/null | sort -n); do
  TITLE=$(gh issue view "$num" --repo "$REPO" --json title --jq '.title' 2>/dev/null)
  # solo épicas (F0..F5, SW)
  if echo "$TITLE" | grep -qE '^(F[0-5]|SW) ·'; then
    gh project item-add 2 --owner qidia-io --url "https://github.com/$REPO/issues/$num" --format json 2>/dev/null | python3 -c "import json,sys; d=json.load(sys.stdin); print(f'  + #$num → board Fases')" 2>/dev/null || echo "  = #$num ya estaba"
  fi
done
echo "=== HECHO ==="
