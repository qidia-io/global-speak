#!/bin/bash
# ============================================================
# detalle_f0_f1.sh — Materializa F0 y F1 en el board de
# Detalle (projects/1) con subtareas granulares + checkpoints
# Formato: secuencia numerada, agente, dependencias
# ============================================================
set -e
REPO="qidia-io/global-speak"
BOARD=1
# Field Estado (board 1): Backlog=d1bafce3 Ready=a67b4bb6 InProgress=d1d82990 Done=6bec6106
FIELD_ESTADO="PVTSSF_lAHOENGz784Bh_XWzhg5D6Q"

mk_issue() {  # $1=title $2=body $3=milestone $4=labels_csv $5=estado
  local title="$1" body="$2" ms="$3" labels="$4" estado="$5"
  local out labels_args=()
  IFS=',' read -ra LBL <<< "$labels"
  for l in "${LBL[@]}"; do labels_args+=(-f "labels[]=$l"); done
  out=$(gh api -X POST "repos/$REPO/issues" -f "title=$title" -f "body=$body" -f "milestone=$ms" "${labels_args[@]}" --jq '.number' 2>&1)
  local num=$(echo "$out" | grep -oE '[0-9]+$' | head -1)
  if [ -z "$num" ]; then echo "  ❌ $title → $out"; return; fi
  # añadir al board
  local item
  item=$(gh project item-add $BOARD --owner qidia-io --url "https://github.com/$REPO/issues/$num" --format json 2>/dev/null | python3 -c "import json,sys; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
  if [ -n "$item" ]; then
    gh api graphql -f query="mutation {
      updateProjectV2ItemFieldValue(input: {
        projectId: \"PVT_kwHOENGz784Bh_XW\"
        itemId: \"$item\"
        fieldId: \"$FIELD_ESTADO\"
        value: { singleSelectOptionId: \"$estado\" }
      }) { projectV2Item { id } }
    }" >/dev/null 2>&1
  fi
  echo "  ✅ #$num $title"
}

echo "=== F0 · FUNDAMENTOS (milestone 1) ==="
mk_issue "F0.1 · Arquitectura end-to-end SST→NMT→TTS (flujo de datos)" "**Agente:** nemrod
**Depende de:** —
Definir arquitectura del sistema completa: flujo de datos audio→texto→traducción→audio, módulos, interfaces entre componentes. Documentar en ARCHITECTURE_SYSTEM.md." 1 "agente:griot,f0-fase,prio:alta,status:ready" "a67b4bb6"
mk_issue "F0.2 · Decidir stack tecnológico por módulo" "**Agente:** nemrod
**Depende de:** F0.1
Stack por módulo: SST (Whisper/HuBERT), NMT (ByT5/NLLB), TTS (galsenai/MMS), app (React+Capacitor), backend. Decidir y documentar." 1 "agente:griot,f0-fase,prio:alta,status:ready" "a67b4bb6"
mk_issue "F0.3 · Esquema de datos: pares de traducción" "**Agente:** nemrod + sankofa
**Depende de:** F0.1
Formato, campos y metadatos de los pares de traducción: src, tgt, fuente, licencia, dominio. Estructura de carpetas en data/." 1 "agente:sankofa,f0-fase,prio:alta,status:ready" "a67b4bb6"
mk_issue "F0.4 · Esquema de datos: audio/transcripciones" "**Agente:** nemrod + sankofa
**Depende de:** F0.1
Manifests de audio (wav, duración, transcripción, hablante, split), estructura para Wolof-ASR-Data y corpus TTS." 1 "agente:sankofa,f0-fase,prio:alta,status:ready" "a67b4bb6"
mk_issue "F0.5 · Definir pipeline de trabajo: datos → entrenamiento → integración" "**Agente:** nemrod
**Depende de:** F0.2
Flujo operativo del proyecto: cómo fluye el trabajo entre agentes, quality gates, momentos de integración." 1 "agente:griot,f0-fase,prio:media,status:ready" "a67b4bb6"
mk_issue "F0.6 · Crear/especializar agentes + plantilla de delegación" "**Agente:** nemrod
**Depende de:** —
Perfiles echo, janus, mbok, sankofa, griot: roles, SOUL.md, plantilla de delegación (nemrod-orchestration)." 1 "agente:griot,f0-fase,prio:alta,status:ready" "a67b4bb6"
mk_issue "F0.7 · Documentación: PROJECT_CONTROL, STATUS, ROADMAP, Notion HQ" "**Agente:** nemrod + griot
**Depende de:** F0.1-F0.6
Mantener al día la documentación del proyecto en repo + Notion (HQ documental)." 1 "agente:griot,f0-fase,prio:media,status:ready" "a67b4bb6"
mk_issue "F0.8 · Política de privacidad y consentimiento (grabaciones)" "**Agente:** nemrod + griot
**Depende de:** F0.3
Política de consentimiento para grabaciones de voz, GDPR, qué se guarda y dónde. CRÍTICO para migrantes." 1 "agente:griot,f0-fase,prio:alta,status:ready" "a67b4bb6"
mk_issue "F0.9 · Anonimización de corpus + política de retención" "**Agente:** sankofa
**Depende de:** F0.8
Revisar corpus por datos personales, anonimizar, definir retención de datos y accesos." 1 "agente:sankofa,f0-fase,prio:alta,status:ready" "a67b4bb6"
mk_issue "F0.10 · Objetivos medibles (WER, BLEU, latencia, tamaño)" "**Agente:** nemrod + janus + echo + mbok
**Depende de:** F0.7
Targets: WER<30%, BLEU>20, latencia<2s, APK<300MB, modelos<500MB. Criterio de éxito del piloto." 1 "agente:janus,f0-fase,prio:alta,status:ready" "a67b4bb6"
mk_issue "F0.11 · Presupuesto RunPod/GPU + almacenamiento HF" "**Agente:** nemrod + janus
**Depende de:** F0.10
Estimar y aprobar coste de entrenamiento (RunPod), almacenamiento de datasets/modelos en HF Hub." 1 "agente:janus,f0-fase,prio:alta,status:ready" "a67b4bb6"
mk_issue "F0.12 · Registro de riesgos + plan B por fase" "**Agente:** nemrod
**Depende de:** F0.11
Riesgos: falta de corpus TTS, WER alto, costes, dependencias. Plan de contingencia por fase." 1 "agente:griot,f0-fase,prio:media,status:ready" "a67b4bb6"
mk_issue "F0.13 · Benchmark SST: Whisper vs HuBERT (WER base)" "**Agente:** janus
**Depende de:** F0.10
Evaluar modelos base ASR en wolof sin fine-tune, medir WER, elegir candidato." 1 "agente:janus,f0-fase,prio:alta,status:ready" "a67b4bb6"
mk_issue "F0.14 · Benchmark NMT: ByT5 vs NLLB vs M2M100 (BLEU base)" "**Agente:** janus
**Depende de:** F0.10
Evaluar modelos base de traducción en wolof, medir BLEU/chrF, elegir candidato." 1 "agente:janus,f0-fase,prio:alta,status:ready" "a67b4bb6"
mk_issue "F0.15 · Benchmark TTS: MMS vs XTTS vs galsenai" "**Agente:** janus + echo
**Depende de:** F0.10
Evaluar modelos base TTS wolof: naturalidad, inteligibilidad. Elegir candidato." 1 "agente:echo,f0-fase,prio:alta,status:ready" "a67b4bb6"
mk_issue "F0.16 · DECISION LOG: modelos base elegidos por módulo" "**Agente:** nemrod
**Depende de:** F0.13-F0.15
Registrar en Notion DECISION LOG los modelos base finales de SST, NMT y TTS con justificación." 1 "agente:griot,f0-fase,prio:alta,status:ready" "a67b4bb6"

echo ""
echo "=== ✅ CHECKPOINT F0 (control de salida) ==="
mk_issue "CP-F0 · Checkpoint de salida de Fundamentos" "**Agente:** nemrod + usuario
**Depende de:** F0.1-F0.16
**Punto de control:** validar que F0 está completa antes de abrir F1.
- [ ] Arquitectura y stack documentados
- [ ] Esquemas de datos definidos
- [ ] Privacidad/consentimiento resueltos
- [ ] Objetivos medibles aprobados
- [ ] Presupuesto aprobado
- [ ] Riesgos registrados
- [ ] Modelos base elegidos (DECISION LOG)
→ Si no cumple criterios, NO se abre F1." 1 "checkpoint,f0-fase,prio:alta,status:ready" "a67b4bb6"

echo ""
echo "=== F1 · DATOS Y CORPUS (milestone 2) ==="
mk_issue "F1.1 · Ingerir fuentes ES↔WO existentes (multiCC, Bible, XLENT)" "**Agente:** sankofa
**Depende de:** F0.3
Incorporar las 5 fuentes ya descargadas de data/raw/es-wo al pipeline estructurado." 2 "agente:sankofa,f1-datos,prio:alta,status:ready" "d1bafce3"
mk_issue "F1.2 · Descargar fuentes nuevas: FLORES-200, NLLB-Seed" "**Agente:** sankofa
**Depende de:** F1.1
Descargar y añadir pares ES↔WO de FLORES-200 y NLLB-Seed al corpus." 2 "agente:sankofa,f1-datos,prio:media,status:ready" "d1bafce3"
mk_issue "F1.3.1 · Limpieza: ordenación y estructuración" "**Agente:** sankofa
**Depende de:** F1.1, F1.2
Unificar formato: 1 par por línea, campos src|tgt|fuente, estructura de carpetas uniforme." 2 "agente:sankofa,f1-datos,prio:alta,status:ready" "d1bafce3"
mk_issue "F1.3.2 · Limpieza: etiquetado de lenguaje" "**Agente:** sankofa
**Depende de:** F1.3.1
Anotar cada par con lang_src/lang_tgt (es, wo, fr) y validar consistencia." 2 "agente:sankofa,f1-datos,prio:alta,status:ready" "d1bafce3"
mk_issue "F1.3.3 · Limpieza: eliminación de símbolos" "**Agente:** sankofa
**Depende de:** F1.3.2
Quitar emojis, URLs, HTML, menciones, caracteres de control vía regex." 2 "agente:sankofa,f1-datos,prio:alta,status:ready" "d1bafce3"
mk_issue "F1.3.4 · Limpieza: unificación de diacríticos wolof (gàñ/gañ)" "**Agente:** sankofa + janus
**Depende de:** F1.3.3
Unificar diacríticos del wolof según convención ortográfica definida en F0 + NFKC." 2 "agente:sankofa,f1-datos,prio:alta,status:ready" "d1bafce3"
mk_issue "F1.3.5 · Limpieza: estandarización ortográfica" "**Agente:** janus
**Depende de:** F1.3.4
Aplicar mapa de variantes ortográficas wolof al corpus completo." 2 "agente:janus,f1-datos,prio:alta,status:ready" "d1bafce3"
mk_issue "F1.3.6 · Limpieza: normalización Unicode (NFKC)" "**Agente:** sankofa
**Depende de:** F1.3.5
NFKC: formas canónicas, espacios unificados, puntuación tipográfica → ASCII." 2 "agente:sankofa,f1-datos,prio:alta,status:ready" "d1bafce3"
mk_issue "F1.3.7 · Limpieza: eliminación de duplicados (exacto + fuzzy)" "**Agente:** sankofa
**Depende de:** F1.3.6
Dedup exacto + fuzzy (similitud > 0.95) conservando la mejor fuente." 2 "agente:sankofa,f1-datos,prio:alta,status:ready" "d1bafce3"
mk_issue "F1.3.8 · Limpieza: filtrado de ruido" "**Agente:** sankofa
**Depende de:** F1.3.7
Eliminar pares desalineados, frases <3 o >100 tokens, ratio de longitud anómalo." 2 "agente:sankofa,f1-datos,prio:alta,status:ready" "d1bafce3"
mk_issue "F1.3.9 · Limpieza: detección de idioma (langid)" "**Agente:** sankofa
**Depende de:** F1.3.8
Verificar que cada lado corresponde a su etiqueta de idioma." 2 "agente:sankofa,f1-datos,prio:alta,status:ready" "d1bafce3"
mk_issue "F1.3.10 · Limpieza: tokenización + vocabulario" "**Agente:** janus
**Depende de:** F1.3.9
Tokenizar ambos lados, registrar vocabulario y estadísticas (ByT5 usa bytes, validar)." 2 "agente:janus,f1-datos,prio:media,status:ready" "d1bafce3"
mk_issue "F1.3.11 · Limpieza: balanceo del corpus" "**Agente:** sankofa
**Depende de:** F1.3.10
Distribución controlada por dominio/fuente." 2 "agente:sankofa,f1-datos,prio:media,status:ready" "d1bafce3"
mk_issue "F1.3.12 · Limpieza: splits train/val/test" "**Agente:** sankofa
**Depende de:** F1.3.11
División estratificada 90/5/5 sin solapamiento de frases." 2 "agente:sankofa,f1-datos,prio:alta,status:ready" "d1bafce3"
mk_issue "F1.3.13 · Limpieza: validación final + métricas" "**Agente:** sankofa + nemrod
**Depende de:** F1.3.12
Reporte: nº pares por split, cobertura, ejemplos revisados a mano." 2 "agente:sankofa,f1-datos,prio:alta,status:ready" "d1bafce3"

echo ""
echo "=== ✅ CHECKPOINT F1.3 (calidad de limpieza) ==="
mk_issue "CP-F1.3 · Checkpoint de calidad — limpieza y normalización" "**Agente:** sankofa + nemrod
**Depende de:** F1.3.1-F1.3.13
**Punto de control:** validar la limpieza antes de seguir con ASR/TTS.
- [ ] Muestra aleatoria revisada a mano (50 pares)
- [ ] Duplicados eliminados (%, residual <1%)
- [ ] Detección de idioma 100% consistente
- [ ] Splits sin solapamiento
- [ ] Métricas de calidad documentadas
→ Si falla, NO se avanza a F1.4." 2 "checkpoint,f1-datos,prio:alta,status:ready" "d1bafce3"

echo ""
echo "=== F1 · CONTINUACIÓN ==="
mk_issue "F1.4 · Ingerir Wolof-ASR-Data (audio + transcripciones)" "**Agente:** sankofa + echo
**Depende de:** F0.4, CP-F1.3
Ingerir los 945MB/10.6GB de Wolof-ASR-Data: audio + transcripciones, verificar alineación." 2 "agente:sankofa,f1-datos,prio:alta,status:ready" "d1bafce3"
mk_issue "F1.5 · Preparar test set SST limpio y separado" "**Agente:** sankofa
**Depende de:** F1.4
Test set de ASR limpio, separado del train, con transcripciones verificadas." 2 "agente:sankofa,f1-datos,prio:alta,status:ready" "d1bafce3"
mk_issue "F1.6 · Corpus TTS: audio + transcripciones + segmentación" "**Agente:** sankofa + echo
**Depende de:** F0.4, CP-F1.3
Corpus para TTS wolof: audio, transcripciones alineadas, segmentación por frase." 2 "agente:echo,f1-datos,prio:alta,status:ready" "d1bafce3"
mk_issue "F1.7 · Anonimización + verificación de consentimiento" "**Agente:** sankofa + griot
**Depende de:** F1.4-F1.6
Revisar audios/transcripciones por datos personales, verificar consentimiento y licencias." 2 "agente:sankofa,f1-datos,prio:alta,status:ready" "d1bafce3"
mk_issue "F1.8 · Documentación del corpus (procedencia, licencias, stats)" "**Agente:** sankofa
**Depende de:** F1.3-F1.7
Documentar cada dataset: procedencia, licencias, estadísticas de volumen, splits." 2 "agente:sankofa,f1-datos,prio:media,status:ready" "d1bafce3"

echo ""
echo "=== ✅ CHECKPOINTS FINALES F1 + GATE TRANSICIÓN ==="
mk_issue "CP-F1 · Checkpoint de salida de Datos y corpus" "**Agente:** sankofa + nemrod
**Depende de:** F1.1-F1.8
**Punto de control:** corpus wolof completo.
- [ ] Pares ES↔WO limpios, normalizados, balanceados, con splits
- [ ] ASR data ingerido + test set limpio
- [ ] Corpus TTS segmentado
- [ ] Anonimizado + consentimiento verificado
- [ ] Documentado (procedencia, licencias, stats)
→ Si no cumple, NO se abre F2." 2 "checkpoint,f1-datos,prio:alta,status:ready" "d1bafce3"
mk_issue "CP-GATE · Gate de transición F1→F2 (abrir SST)" "**Agente:** nemrod + usuario
**Depende de:** CP-F1
**Punto de control de flujo:** revisión formal con el usuario antes de invertir en entrenamiento.
- [ ] Corpus validado por el usuario
- [ ] Presupuesto RunPod confirmado
- [ ] Modelo base SST elegido en F0 confirmado
→ Con este gate aprobado, se abre la fase F2 (SST)." 2 "checkpoint,f1-datos,prio:alta,status:ready" "d1bafce3"

echo ""
echo "=== TOTAL CREADO ==="
gh api "repos/$REPO/issues?state=all&per_page=100" --jq 'length' 2>/dev/null | xargs echo "Issues totales en repo:"
