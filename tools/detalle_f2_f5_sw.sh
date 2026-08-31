#!/bin/bash
# ============================================================
# detalle_f2_f5_sw.sh — Materializa F2 (SST), F3 (NMT), F4 (TTS),
# F5 (Integración) y SW (Software completo, paralelo) en el board
# de Detalle (projects/1) con subtareas granulares + checkpoints.
# Formato: secuencia numerada (F2.1, F3.2...), agente, dependencias
# ============================================================
set -e
REPO="qidia-io/global-speak"
BOARD=1
FIELD_ESTADO="PVTSSF_lAHOENGz784Bh_XWzhg5D6Q"

mk_issue() {  # $1=title $2=body $3=milestone $4=labels_csv $5=estado
  local title="$1" body="$2" ms="$3" labels="$4" estado="$5"
  local out labels_args=()
  IFS=',' read -ra LBL <<< "$labels"
  for l in "${LBL[@]}"; do labels_args+=(-f "labels[]=$l"); done
  out=$(gh api -X POST "repos/$REPO/issues" -f "title=$title" -f "body=$body" -f "milestone=$ms" "${labels_args[@]}" --jq '.number' 2>&1)
  local num=$(echo "$out" | grep -oE '[0-9]+$' | head -1)
  if [ -z "$num" ]; then echo "  ❌ $title → $out"; return; fi
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

echo "=== F2 · SST — scripts, entrenamiento y offline (milestone 3) ==="
mk_issue "F2.1 · Benchmark modelos base SST: Whisper vs HuBERT vs Wav2Vec2 en wolof" "**Agente:** janus
**Depende de:** CP-GATE F1→F2
Evaluar los 3 candidatos sobre un subconjunto del test set wolof. Registrar WER de cada base sin fine-tune." 3 "agente:janus,f2-sst,prio:alta,status:backlog" "d1bafce3"
mk_issue "F2.2 · Medir WER de cada base sin fine-tune" "**Agente:** janus
**Depende de:** F2.1
WER de Whisper, HuBERT y Wav2Vec2 sobre test set wolof sin fine-tune. Tabla comparativa." 3 "agente:janus,f2-sst,prio:alta,status:backlog" "d1bafce3"
mk_issue "F2.3 · Decidir modelo base ganador SST → DECISION LOG" "**Agente:** janus + nemrod
**Depende de:** F2.2
Selección final del modelo base SST con justificación (WER, tamaño, licencia, exportabilidad). Registrar en DECISION LOG." 3 "agente:janus,f2-sst,prio:alta,status:backlog" "d1bafce3"
mk_issue "F2.4 · Script de fine-tune del modelo base SST elegido" "**Agente:** janus
**Depende de:** F2.3
Script de entrenamiento reutilizable (config, wandb/logger, checkpointing). Base: SST_lo_conseguí.ipynb / sst_finetune_whisper.ipynb." 3 "agente:janus,f2-sst,prio:alta,status:backlog" "d1bafce3"
mk_issue "F2.5 · Configuración de hiperparámetros SST" "**Agente:** janus
**Depende de:** F2.4
LR, batch, épocas, warmup, freeze layers, aumentación de audio. Justificar valores." 3 "agente:janus,f2-sst,prio:media,status:backlog" "d1bafce3"
mk_issue "F2.6 · DataLoader y preprocesado de audio (16 kHz, aumentación)" "**Agente:** janus
**Depende de:** F2.4
Pipeline de audio: resample 16 kHz, normalización, spec-augment, collate. Compatible con Wolof-ASR-Data." 3 "agente:janus,f2-sst,prio:media,status:backlog" "d1bafce3"
mk_issue "F2.7 · Contratar/configurar RunPod (GPU) para entrenamiento SST" "**Agente:** nemrod
**Depende de:** F2.3
Instancia GPU, imagen con dependencias, presupuesto y límites. Registrar en presupuesto (F0.11)." 3 "agente:nemrod,f2-sst,prio:alta,status:backlog" "d1bafce3"
mk_issue "F2.8 · Entrenar modelo SST wolof (RunPod)" "**Agente:** janus
**Depende de:** F2.5, F2.6, F2.7
Fine-tune completo del modelo base sobre corpus wolof (train 90%)." 3 "agente:janus,f2-sst,prio:alta,status:backlog" "d1bafce3"
mk_issue "F2.9 · Registrar checkpoints y métricas de entrenamiento SST" "**Agente:** janus
**Depende de:** F2.8
Curvas de pérdida/WER por época, mejor checkpoint, reproducibilidad (seed, config guardada)." 3 "agente:janus,f2-sst,prio:media,status:backlog" "d1bafce3"
mk_issue "F2.10 · Investigar exportación ONNX/TFLite del SST" "**Agente:** janus + mbok
**Depende de:** F2.8
Viabilidad de exportar el modelo SST a ONNX/TFLite (ops soportadas, conversión, wrappers)." 3 "agente:janus,f2-sst,prio:alta,status:backlog" "d1bafce3"
mk_issue "F2.11 · Documentar opciones de cuantización SST (INT8/FP16)" "**Agente:** janus + mbok
**Depende de:** F2.10
Impacto en tamaño/latencia/precisión de INT8 vs FP16. Decisión documentada." 3 "agente:janus,f2-sst,prio:media,status:backlog" "d1bafce3"
mk_issue "F2.12 · Medir tamaño y latencia del SST en móvil" "**Agente:** mbok
**Depende de:** F2.11
Benchmark del modelo cuantizado en dispositivo: tamaño, latencia por frase, memoria. Objetivo: latencia < 2 s." 3 "agente:mbok,f2-sst,prio:media,status:backlog" "d1bafce3"
mk_issue "F2.13 · Evaluación WER del SST fine-tuneado sobre test set" "**Agente:** echo
**Depende de:** F2.8
WER del modelo final sobre test set limpio (F1.5). Reutilizar script de métricas #24." 3 "agente:echo,f2-sst,prio:alta,status:backlog" "d1bafce3"
mk_issue "F2.14 · Verificar objetivo: WER < 30%" "**Agente:** echo + nemrod
**Depende de:** F2.13
Comparar contra objetivo medible (F0.10). Si no se cumple: iterar o plan B." 3 "agente:echo,f2-sst,prio:alta,status:backlog" "d1bafce3"
mk_issue "F2.15 · Documentar resultados SST (métricas, decisión, exportación)" "**Agente:** echo
**Depende de:** F2.14
Informe de la fase: modelo, métricas, exportación, lecciones. Actualizar STATUS/ROADMAP." 3 "agente:echo,f2-sst,prio:media,status:backlog" "d1bafce3"
mk_issue "CP-F2 · Checkpoint salida F2: SST wolof WER < 30% exportable" "**Agente:** nemrod
**Depende de:** F2.15
Criterios: (1) WER < 30% sobre test set limpio; (2) modelo exportado ONNX/TFLite con tamaño medido; (3) documentación completa. Bloquea F3 si no se cumple." 3 "agente:nemrod,checkpoint,f2-sst,prio:alta,status:backlog" "d1bafce3"

echo "=== F3 · NMT — scripts, entrenamiento y offline (milestone 4) ==="
mk_issue "F3.1 · Benchmark modelos base NMT: ByT5 vs NLLB vs M2M100 en wolof" "**Agente:** janus
**Depende de:** CP-F2
Evaluar los 3 candidatos ES↔WO sobre test set. ByT5 ya integrado en Fase B (#10) — validar si sigue siendo la mejor opción." 4 "agente:janus,f3-nmt,prio:alta,status:backlog" "d1bafce3"
mk_issue "F3.2 · Medir BLEU/chrF de cada base sin fine-tune" "**Agente:** janus
**Depende de:** F3.1
BLEU y chrF de cada base ES↔WO sin fine-tune. Tabla comparativa (saco sacábamos en NMT_lo_conseguí.ipynb)." 4 "agente:janus,f3-nmt,prio:alta,status:backlog" "d1bafce3"
mk_issue "F3.3 · Decidir modelo base ganador NMT → DECISION LOG" "**Agente:** janus + nemrod
**Depende de:** F3.2
Selección final (BLEU, tamaño, licencia, exportabilidad). Registrar en DECISION LOG." 4 "agente:janus,f3-nmt,prio:alta,status:backlog" "d1bafce3"
mk_issue "F3.4 · Script fine-tune del modelo base NMT elegido (es↔wo)" "**Agente:** janus
**Depende de:** F3.3
Script reutilizable de fine-tune NMT ES↔WO. Base: NMT_NLLB200_+_ByT5.ipynb." 4 "agente:janus,f3-nmt,prio:alta,status:backlog" "d1bafce3"
mk_issue "F3.5 · Tokenización y preparación de batches NMT" "**Agente:** janus
**Depende de:** F3.4
Tokenizador del modelo base, padding, batches, atención máscaras. Manejo de pares largos." 4 "agente:janus,f3-nmt,prio:media,status:backlog" "d1bafce3"
mk_issue "F3.6 · Configuración de hiperparámetros NMT" "**Agente:** janus
**Depende de:** F3.4
LR, batch, épocas, warmup, beam search en inferencia. Justificar." 4 "agente:janus,f3-nmt,prio:media,status:backlog" "d1bafce3"
mk_issue "F3.7 · Entrenar modelo NMT ES↔WO (RunPod)" "**Agente:** janus
**Depende de:** F3.5, F3.6
Fine-tune completo sobre pares es↔wo (train 90%)." 4 "agente:janus,f3-nmt,prio:alta,status:backlog" "d1bafce3"
mk_issue "F3.8 · Registrar checkpoints y métricas de entrenamiento NMT" "**Agente:** janus
**Depende de:** F3.7
Curvas de pérdida/BLEU por época, mejor checkpoint, reproducibilidad." 4 "agente:janus,f3-nmt,prio:media,status:backlog" "d1bafce3"
mk_issue "F3.9 · Exportación ONNX/TFLite del NMT" "**Agente:** janus + mbok
**Depende de:** F3.7
Convertir el modelo NMT a ONNX/TFLite (encoder+decoder, ops)." 4 "agente:janus,f3-nmt,prio:alta,status:backlog" "d1bafce3"
mk_issue "F3.10 · Documentar cuantización y tamaño final del NMT" "**Agente:** janus + mbok
**Depende de:** F3.9
INT8/FP16, tamaño final, impacto en BLEU. Decisión documentada." 4 "agente:janus,f3-nmt,prio:media,status:backlog" "d1bafce3"
mk_issue "F3.11 · Medir latencia del NMT en móvil" "**Agente:** mbok
**Depende de:** F3.10
Latencia por frase en dispositivo. Objetivo: latencia < 2 s." 4 "agente:mbok,f3-nmt,prio:media,status:backlog" "d1bafce3"
mk_issue "F3.12 · Evaluación BLEU, chrF y COMET del NMT final" "**Agente:** janus
**Depende de:** F3.7
Métricas sobre test set limpio (F1.5). COMET si hay recursos." 4 "agente:janus,f3-nmt,prio:alta,status:backlog" "d1bafce3"
mk_issue "F3.13 · Verificar objetivo: BLEU > 20" "**Agente:** janus + nemrod
**Depende de:** F3.12
Comparar contra objetivo medible (F0.10). Si no se cumple: iterar o plan B." 4 "agente:janus,f3-nmt,prio:alta,status:backlog" "d1bafce3"
mk_issue "F3.14 · Documentar resultados NMT (métricas, decisión, exportación)" "**Agente:** janus
**Depende de:** F3.13
Informe de la fase. Actualizar STATUS/ROADMAP." 4 "agente:janus,f3-nmt,prio:media,status:backlog" "d1bafce3"
mk_issue "CP-F3 · Checkpoint salida F3: NMT ES↔WO BLEU > 20 exportable" "**Agente:** nemrod
**Depende de:** F3.14
Criterios: (1) BLEU > 20 sobre test set; (2) modelo exportado ONNX/TFLite con tamaño medido; (3) documentación completa. Bloquea F4 si no se cumple." 4 "agente:nemrod,checkpoint,f3-nmt,prio:alta,status:backlog" "d1bafce3"

echo "=== F4 · TTS — scripts, entrenamiento y offline (milestone 5) ==="
mk_issue "F4.1 · Benchmark modelos base TTS: MMS-TTS vs XTTS-v2 vs galsenai en wolof" "**Agente:** janus + echo
**Depende de:** CP-F3
Evaluar candidatos en wolof. galsenai ya integrado en pipeline (#20) — validar." 5 "agente:janus,f4-tts,prio:alta,status:backlog" "d1bafce3"
mk_issue "F4.2 · Medir naturalidad e inteligibilidad de cada base TTS" "**Agente:** echo
**Depende de:** F4.1
Escucha ciega + métricas (MOS subjetivo, WER de la síntesis)." 5 "agente:echo,f4-tts,prio:alta,status:backlog" "d1bafce3"
mk_issue "F4.3 · Decidir modelo base ganador TTS → DECISION LOG" "**Agente:** janus + nemrod
**Depende de:** F4.2
Selección final (naturalidad, idioma wolof, exportabilidad, licencia). Registrar en DECISION LOG." 5 "agente:janus,f4-tts,prio:alta,status:backlog" "d1bafce3"
mk_issue "F4.4 · Script fine-tune del modelo base TTS elegido" "**Agente:** janus
**Depende de:** F4.3
Script reutilizable de fine-tune TTS. Base: TTS.ipynb / tts_finetune.ipynb." 5 "agente:janus,f4-tts,prio:alta,status:backlog" "d1bafce3"
mk_issue "F4.5 · Preprocesado de audio + texto para TTS" "**Agente:** janus
**Depende de:** F4.4
Normalización de texto wolof, transcripciones limpias, audio 22-24 kHz, filtrado de clips ruidosos." 5 "agente:janus,f4-tts,prio:media,status:backlog" "d1bafce3"
mk_issue "F4.6 · Entrenar TTS wolof (RunPod)" "**Agente:** janus
**Depende de:** F4.4, F4.5
Fine-tune sobre corpus TTS (F1.6)." 5 "agente:janus,f4-tts,prio:alta,status:backlog" "d1bafce3"
mk_issue "F4.7 · Registrar checkpoints del TTS" "**Agente:** janus
**Depende de:** F4.6
Checkpoints por época, mejor modelo por validación, muestras auditivas guardadas." 5 "agente:janus,f4-tts,prio:media,status:backlog" "d1bafce3"
mk_issue "F4.8 · Exportación ONNX/TFLite del TTS" "**Agente:** janus + mbok
**Depende de:** F4.6
Convertir vocoder + sintetizador a ONNX/TFLite." 5 "agente:janus,f4-tts,prio:alta,status:backlog" "d1bafce3"
mk_issue "F4.9 · Documentar tamaño y latencia del TTS" "**Agente:** janus + mbok
**Depende de:** F4.8
Tamaño del modelo, latencia de síntesis por frase, cuantización." 5 "agente:janus,f4-tts,prio:media,status:backlog" "d1bafce3"
mk_issue "F4.10 · Medir latencia del TTS en móvil" "**Agente:** mbok
**Depende de:** F4.9
Latencia de síntesis en dispositivo. Objetivo: < 2 s por frase." 5 "agente:mbok,f4-tts,prio:media,status:backlog" "d1bafce3"
mk_issue "F4.11 · Evaluación naturalidad + inteligibilidad (hablantes nativos)" "**Agente:** echo + griot
**Depende de:** F4.6
Test con hablantes wolof: inteligibilidad y naturalidad. Reutilizar métricas #25." 5 "agente:echo,f4-tts,prio:alta,status:backlog" "d1bafce3"
mk_issue "F4.12 · Verificar objetivo: inteligibilidad aceptable" "**Agente:** echo + nemrod
**Depende de:** F4.11
Contrastar con objetivo medible (F0.10). Iterar si no se cumple." 5 "agente:echo,f4-tts,prio:alta,status:backlog" "d1bafce3"
mk_issue "F4.13 · Documentar resultados TTS (métricas, decisión, exportación)" "**Agente:** echo
**Depende de:** F4.12
Informe de la fase. Actualizar STATUS/ROADMAP." 5 "agente:echo,f4-tts,prio:media,status:backlog" "d1bafce3"
mk_issue "CP-F4 · Checkpoint salida F4: TTS wolof de calidad aceptable exportable" "**Agente:** nemrod
**Depende de:** F4.13
Criterios: (1) inteligibilidad aceptable por hablantes nativos; (2) modelo exportado ONNX/TFLite con tamaño medido; (3) documentación completa. Bloquea F5 si no se cumple." 5 "agente:nemrod,checkpoint,f4-tts,prio:alta,status:backlog" "d1bafce3"

echo "=== F5 · Integración — app, publicación y testeos (milestone 7) ==="
mk_issue "F5.1 · Pipeline completo SST→NMT→TTS en producción" "**Agente:** echo + mbok
**Depende de:** CP-F2, CP-F3, CP-F4
Ensamblar los 3 módulos entrenados en el pipeline real de la app (backend o standalone)." 7 "agente:echo,f5-integracion,prio:alta,status:backlog" "d1bafce3"
mk_issue "F5.2 · Conversación E2E real en wolof (grabación→traducción→voz)" "**Agente:** echo
**Depende de:** F5.1
Prueba de conversación completa en wolof: hablas → SST → NMT → TTS → respuesta. Es el #33 (piloto) llevado a producción." 7 "agente:echo,f5-integracion,prio:alta,status:backlog" "d1bafce3"
mk_issue "F5.3 · Pruebas de integración completas (3 módulos + app)" "**Agente:** mbok + echo
**Depende de:** F5.2
Suite de integración: cada módulo por separado y el flujo completo. Errores y fallbacks." 7 "agente:mbok,f5-integracion,prio:alta,status:backlog" "d1bafce3"
mk_issue "F5.4 · Selector de idioma funcional en producción" "**Agente:** mbok
**Depende de:** SW (selector #31)
Selector ES↔WO funcional con los modelos finales, no el mock." 7 "agente:mbok,f5-integracion,prio:alta,status:backlog" "d1bafce3"
mk_issue "F5.5 · Modo offline con todos los modelos locales" "**Agente:** mbok
**Depende de:** F2.12, F3.11, F4.10 (exportaciones)
La app funciona sin red: SST+NMT+TTS cargados del dispositivo." 7 "agente:mbok,f5-integracion,prio:alta,status:backlog" "d1bafce3"
mk_issue "F5.6 · Tests de usuario final (beta interna)" "**Agente:** mbok
**Depende de:** F5.5
Beta interna con el equipo: bugs de uso real, rendimiento, batería." 7 "agente:mbok,f5-integracion,prio:media,status:backlog" "d1bafce3"
mk_issue "F5.7 · Reclutar testers hablantes de wolof" "**Agente:** griot
**Depende de:** — (puede empezar en paralelo)
Comunidad de testers senegaleses/migrantes para pruebas reales." 7 "agente:griot,f5-integracion,prio:media,status:backlog" "d1bafce3"
mk_issue "F5.8 · Sesiones de prueba reales guiadas" "**Agente:** griot + echo
**Depende de:** F5.7
Sesiones guiadas: conversaciones reales, casos de uso cotidianos (médico, admin, trabajo)." 7 "agente:griot,f5-integracion,prio:alta,status:backlog" "d1bafce3"
mk_issue "F5.9 · Recoger feedback: usabilidad, calidad de traducción, voz" "**Agente:** griot
**Depende de:** F5.8
Encuestas/entrevistas a testers. Priorizar mejoras." 7 "agente:griot,f5-integracion,prio:media,status:backlog" "d1bafce3"
mk_issue "F5.10 · Verificar consentimiento en la app" "**Agente:** griot
**Depende de:** F0.8 (política)
El flujo de consentimiento de grabaciones está implementado y visible." 7 "agente:griot,f5-integracion,prio:alta,status:backlog" "d1bafce3"
mk_issue "F5.11 · Comprobar que las grabaciones no salen del dispositivo sin permiso" "**Agente:** mbok + nemrod
**Depende de:** F5.10
Auditoría técnica: tráfico de red, almacenamiento local, permisos. Sin envío salvo consentimiento." 7 "agente:mbok,f5-integracion,prio:alta,status:backlog" "d1bafce3"
mk_issue "F5.12 · Auditoría de datos: qué se guarda, dónde, durante cuánto" "**Agente:** nemrod
**Depende de:** F5.11
Inventario de datos (grabaciones, logs, uso), retención, derecho al borrado. Documentar." 7 "agente:nemrod,f5-integracion,prio:media,status:backlog" "d1bafce3"
mk_issue "F5.13 · APK Capacitor → Play Store" "**Agente:** mbok
**Depende de:** F5.6
Build de producción, firma, listing, revisión de Play Store." 7 "agente:mbok,f5-integracion,prio:alta,status:backlog" "d1bafce3"
mk_issue "F5.14 · Documentación de usuario (guía en es + wo)" "**Agente:** griot
**Depende de:** F5.13
Guía de uso, FAQ, contacto. En español y wolof." 7 "agente:griot,f5-integracion,prio:media,status:backlog" "d1bafce3"
mk_issue "F5.15 · Test E2E final con hablantes reales" "**Agente:** griot + equipo
**Depende de:** F5.8, F5.13
Test completo con testers en dispositivo final: instalación → conversación → resultado." 7 "agente:griot,f5-integracion,prio:alta,status:backlog" "d1bafce3"
mk_issue "F5.16 · Verificación de objetivos medibles finales" "**Agente:** nemrod
**Depende de:** F5.15
WER < 30%, BLEU > 20, latencia < 2 s, APK < 300 MB. Informe de cumplimiento." 7 "agente:nemrod,f5-integracion,prio:alta,status:backlog" "d1bafce3"
mk_issue "F5.17 · Corrección de incidencias post-test" "**Agente:** mbok + echo
**Depende de:** F5.15
Arreglar bugs detectados en los testeos finales." 7 "agente:mbok,f5-integracion,prio:media,status:backlog" "d1bafce3"
mk_issue "CP-F5 · Checkpoint salida F5: app publicada con objetivos cumplidos" "**Agente:** nemrod
**Depende de:** F5.16
Criterios: (1) app en Play Store; (2) objetivos medibles verificados (WER<30, BLEU>20, latencia<2s, APK<300MB); (3) privacidad auditada; (4) documentación completa. CIERRE DEL PROYECTO." 7 "agente:nemrod,checkpoint,f5-integracion,prio:alta,status:backlog" "d1bafce3"

echo "=== SW · SOFTWARE — app completa, backend y offline (milestone 6, paralelo) ==="
mk_issue "SW.1.1 · Scaffold app React + Capacitor (base, navegación, temas)" "**Agente:** mbok
**Depende de:** —
Estructura base de la app: proyecto React+Capacitor, navegación entre pantallas, tema, i18n es/wo." 6 "agente:mbok,sw-software,prio:alta,status:ready" "a67b4bb6"
mk_issue "SW.1.2 · Integración del runner SST en la app (grabar → transcribir local)" "**Agente:** mbok + echo
**Depende de:** SW.1.1
Conectar micrófono → runner SST (ONNX/TFLite) → texto local. Estados de grabación y resultados." 6 "agente:mbok,sw-software,prio:alta,status:ready" "a67b4bb6"
mk_issue "SW.1.3 · Integración del runner NMT en la app (traducir local)" "**Agente:** mbok
**Depende de:** SW.1.1
Conectar texto → runner NMT (ONNX/TFLite) → traducción local. ByT5/NLLB via model router (#10)." 6 "agente:mbok,sw-software,prio:alta,status:ready" "a67b4bb6"
mk_issue "SW.1.4 · Integración del runner TTS en la app (texto → voz local)" "**Agente:** mbok + echo
**Depende de:** SW.1.1
Conectar texto → runner TTS (ONNX/TFLite) → audio local. Reproducción y velocidad." 6 "agente:mbok,sw-software,prio:alta,status:ready" "a67b4bb6"
mk_issue "SW.1.5 · Pantalla de conversación: grabación, transcripción, traducción y audio" "**Agente:** mbok
**Depende de:** SW.1.2, SW.1.3, SW.1.4
UI del flujo E2E: botón grabar, transcripción visible, traducción, reproducción. Equivale al E2E #33 en producción." 6 "agente:mbok,sw-software,prio:alta,status:ready" "a67b4bb6"
mk_issue "SW.1.6 · Manejo de errores y estados (sin red, modelo no descargado, micrófono denegado)" "**Agente:** mbok
**Depende de:** SW.1.5
Estados de carga, errores legibles, reintentos, permisos de micrófono denegados." 6 "agente:mbok,sw-software,prio:media,status:ready" "a67b4bb6"
mk_issue "SW.1.7 · Historial de conversaciones (persistencia local)" "**Agente:** mbok
**Depende de:** SW.1.5
Guardar conversaciones en el dispositivo, listarlas, borrarlas. Privacidad por defecto." 6 "agente:mbok,sw-software,prio:media,status:ready" "a67b4bb6"
mk_issue "SW.1.8 · Gestor de descarga/actualización de modelos desde la app" "**Agente:** mbok + sankofa
**Depende de:** SW.1.1
Descargar modelos al dispositivo (progreso, reanudar, verificación de integridad, espacio)." 6 "agente:mbok,sw-software,prio:alta,status:ready" "a67b4bb6"
mk_issue "SW.1.9 · Configuración de la app (idioma, velocidad TTS, borrar datos)" "**Agente:** mbok
**Depende de:** SW.1.5
Pantalla de ajustes: idioma origen/destino, velocidad de voz, borrado de datos e historial." 6 "agente:mbok,sw-software,prio:media,status:ready" "a67b4bb6"
mk_issue "SW.2.1 · Backend FastAPI desacoplado (API de inferencia)" "**Agente:** mbok
**Depende de:** —
Backend para casos con conexión: endpoint de inferencia, gestión de peticiones. Desacoplado de la app." 6 "agente:mbok,sw-software,prio:media,status:ready" "a67b4bb6"
mk_issue "SW.2.2 · CI/CD GitHub Actions (build, test, APK)" "**Agente:** mbok
**Depende de:** SW.1.1
Pipeline de integración continua: lint, tests, build APK en cada push." 6 "agente:mbok,sw-software,prio:media,status:ready" "a67b4bb6"
mk_issue "SW.2.3 · Tests unitarios de la app y del backend" "**Agente:** mbok
**Depende de:** SW.1.1
Cobertura de los módulos críticos: router de modelos, runner, UI básica." 6 "agente:mbok,sw-software,prio:media,status:ready" "a67b4bb6"
mk_issue "SW.3.1 · PRD walkie-talkie (modo push-to-talk)" "**Agente:** griot
**Depende de:** —
PRD del modo conversación por pulsación (walkie-talkie): flujo, UX, prioridades." 6 "agente:griot,sw-software,prio:media,status:ready" "a67b4bb6"
mk_issue "SW.3.2 · Diseño UX/UI de la app" "**Agente:** griot
**Depende de:** SW.1.1
Diseño de pantallas, flujo conversacional, iconografía accesible." 6 "agente:griot,sw-software,prio:media,status:ready" "a67b4bb6"
mk_issue "SW.3.3 · Sincronización multi-dispositivo (opcional, post-piloto)" "**Agente:** griot + mbok
**Depende de:** —
Sinced del historial entre dispositivos. Postergable tras el piloto." 6 "agente:griot,sw-software,prio:baja,status:backlog" "d1bafce3"
mk_issue "SW.4.1 · Pipeline.py standalone (CLI de inferencia)" "**Agente:** echo
**Depende de:** —
Pipeline de inferencia por CLI: entrada audio → salida audio (SST→NMT→TTS). Para pruebas y backend." 6 "agente:echo,sw-software,prio:media,status:ready" "a67b4bb6"
mk_issue "SW.4.2 · Integrar galsenai/wolof_tts en el pipeline TTS" "**Agente:** echo
**Depende de:** —
Conectar la voz wolof de galsenai (ya existente) al pipeline de síntesis." 6 "agente:echo,sw-software,prio:media,status:ready" "a67b4bb6"
mk_issue "SW.5.1 · Investigación offline: exportar modelos a ONNX/TFLite" "**Agente:** janus + mbok
**Depende de:** —
Exportar SST/NMT/TTS a ONNX/TFLite (en paralelo con el entrenamiento, usando WIP)." 6 "agente:janus,sw-software,prio:alta,status:ready" "a67b4bb6"
mk_issue "SW.5.2 · Integración offline de todos los modelos en la app" "**Agente:** mbok
**Depende de:** SW.1.8
Los 3 modelos finales cargados del dispositivo y funcionando sin red." 6 "agente:mbok,sw-software,prio:alta,status:ready" "a67b4bb6"
mk_issue "CP-SW · Checkpoint SW: app funcional con 3 modelos integrados" "**Agente:** nemrod
**Depende de:** SW.5.2
Criterios: (1) app instalable; (2) los 3 runners funcionan en dispositivo (aunque con modelos provisionales); (3) manejo de errores OK; (4) CI/CD en marcha. Se consolida con F5." 6 "agente:nemrod,checkpoint,sw-software,prio:alta,status:ready" "a67b4bb6"

echo ""
echo "=== LISTO — nuevas tareas creadas ==="
