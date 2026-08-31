#!/bin/bash
# ============================================================
# create_epicas.sh — Crea las 6 ÉPICAS de fase (alto nivel)
# Usa API REST directamente (gh issue create con --milestone falla)
# ============================================================
set -e
REPO="qidia-io/global-speak"

create_epica() {
  local title="$1" ms="$2" body_file="$3"
  local existing
  existing=$(gh issue list --repo "$REPO" --state all --limit 100 --json title --jq ".[] | select(.title==\"$title\") | .number" 2>/dev/null | head -1)
  if [ -z "$existing" ]; then
    local num
    num=$(gh api -X POST "repos/$REPO/issues" \
      -f title="$title" \
      -f milestone="$ms" \
      -F "body=@$body_file" \
      -f labels[]="enhancement" --jq '.number' 2>/dev/null || echo "")
    if [ -n "$num" ]; then echo "  + #$num $title"; else echo "  ! fallo: $title"; fi
  else
    echo "  = #$existing (ya existe)"
  fi
}

mkdir -p /tmp/epicas
# Bodies separados por archivo (evita problemas de parsing)
cat > /tmp/epicas/f0.md <<'EOF'
## Objetivo
Preparar la base sobre la que se construye todo: código limpio, datos ingeridos, nodo local operativo.

## Entregables
- [ ] Nodo local (PC 16GB + Ubuntu + Ollama + Hermes) — #18
- [ ] Notebooks ML reescritos (SST HuBERT, NMT ByT5, TTS MMS) — #2, #19
- [ ] Dataset Wolof-ASR ingerido — #4

## Agentes
- griot: nodo local
- janus: notebooks
- sankofa: datos

## Criterio de salida
Nodo operativo, notebooks reproducibles, datos en bruto accesibles.
EOF

cat > /tmp/epicas/f1.md <<'EOF'
## Objetivo
PILOTO COMPLETO: pipeline SST→NMT→TTS funcionando de punta a punta en wolof, con métricas reales.

## Entregables por pipeline
### Datos (sankofa)
- [ ] FLORES-200 para evaluación — #9
- [ ] Test set SST limpio (no train) — #27
- [ ] Corpus TTS wolof — #26

### Modelos (janus + echo)
- [ ] Evaluación formal ByT5 (BLEU, chrF, COMET) — #14
- [ ] Evaluación SST wolof (WER < 30%) — #24
- [ ] Evaluación TTS wolof (naturalidad) — #25
- [ ] Integrar galsenai/wolof_tts — #20

### Integración (echo)
- [ ] Test E2E SST→NMT→TTS audio real — #15
- [ ] Conversación completa en wolof en la app — #33

## Agentes
sankofa → janus → echo (en ese orden)

## Criterio de salida
Hablante wolof graba → oye español. Métricas documentadas. WER < 30%.
EOF

cat > /tmp/epicas/f2.md <<'EOF'
## Objetivo
Aplicar la plantilla validada del piloto al bambara (bm).

## Entregables
- [ ] Recolección corpus NMT es↔bm (NLLB-Seed, Maliba)
- [ ] Limpieza + estandarizado de pares bm
- [ ] Fine-tune ByT5/NLLB es↔bm
- [ ] Evaluación formal bm (BLEU, chrF)
- [ ] SST bm (HuBERT, si hay datos)
- [ ] TTS bm (si hay corpus)
- [ ] Registro en HF Hub + integración en app

## Agentes
sankofa → janus → echo → mbok

## Criterio de salida
bm soportado en el mismo pipeline con métricas documentadas.

## Depende de
F1 cerrada (plantilla validada).
EOF

cat > /tmp/epicas/f3.md <<'EOF'
## Objetivo
Aplicar la plantilla validada del piloto al fula/peul (ff).

## Entregables
- [ ] Recolección corpus NMT es↔ff (NLLB-Seed, FrancophonIA)
- [ ] Limpieza + estandarizado de pares ff
- [ ] Fine-tune ByT5/NLLB es↔ff
- [ ] Evaluación formal ff (BLEU, chrF)
- [ ] SST ff (si hay datos)
- [ ] TTS ff (si hay corpus)
- [ ] Registro en HF Hub + integración en app

## Agentes
sankofa → janus → echo → mbok

## Depende de
F1 cerrada (plantilla validada).
EOF

cat > /tmp/epicas/f4.md <<'EOF'
## Objetivo
Evaluar y escalar a serer (srr), diola (dyo) y soninké (snk).

## Entregables
- [ ] Estudio de disponibilidad de datos por lengua
- [ ] Priorizar: cuál entra primero (volumen de hablantes × datos)
- [ ] Aplicar plantilla a la primera lengua seleccionada
- [ ] Documentar decisiones en DECISION LOG

## Agentes
sankofa (estudio) + nemrod (decisión) + griot (documentación)

## Criterio de salida
Lenguas priorizadas y primera lengua en marcha.
EOF

cat > /tmp/epicas/sw.md <<'EOF'
## Objetivo
El sistema software que usa los modelos: app móvil, backend, pipeline standalone y modo offline. Corre EN PARALELO al piloto.

## Entregables
### App (mbok)
- [ ] ByT5 en inferenceClient (model router) — #10
- [ ] Selector de idioma ES↔WO — #31
- [ ] Grabación + reproducción TTS — #32
- [ ] Pantalla Investigación (modelos locales) — #28
- [ ] Runner ONNX/TFLite offline — #30
- [ ] Cache de inferencia — #12
- [ ] Tests unitarios — #13
- [ ] APK + despliegue — #6

### Backend/Infra (mbok)
- [ ] Backend FastAPI desacoplado — #7
- [ ] CI/CD GitHub Actions — #5
- [ ] Gestión de descargas de modelos — #29

### Producto (griot)
- [ ] PRD walkie-talkie — #21
- [ ] Diseño UX/UI — #22
- [ ] Sincronización multi-dispositivo — #17

### Voz (echo)
- [ ] Pipeline.py standalone — #11

## Agentes
mbok (app/backend) + echo (voz) + griot (producto)

## Criterio de salida
App instalable que funciona offline con modelos locales.
EOF

echo "=== ÉPICAS DE FASE ==="
create_epica "F0 · Fundamentos — infraestructura base lista" 1 /tmp/epicas/f0.md
create_epica "F1 · Piloto Wolof — sistema end-to-end es↔wo" 2 /tmp/epicas/f1.md
create_epica "F2 · Bambara (bm) — replicar plantilla wolof" 3 /tmp/epicas/f2.md
create_epica "F3 · Fula (ff) — replicar plantilla wolof" 4 /tmp/epicas/f3.md
create_epica "F4 · Otras lenguas (srr, dyo, snk) — exploración" 5 /tmp/epicas/f4.md
create_epica "SW · Software — app, backend y sistema (paralelo a F1)" 6 /tmp/epicas/sw.md

# El #34 (prueba) → actualizar con el cuerpo real de F1
gh api -X PATCH "repos/$REPO/issues/34" -F body=@/tmp/epicas/f1.md >/dev/null 2>&1 && echo "  ~ #34 cuerpo F1 actualizado"
echo ""
echo "=== ÉPICAS LISTAS ==="
