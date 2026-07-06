# Estrategia de Fine-Tuning para Lenguas Low-Resource

## Visión General

Pipeline completo para entrenar modelos SST + NMT + TTS en lenguas con pocos
recursos digitales. Cada notebook es un proceso reproducible que genera modelos
subibles a HuggingFace Hub.

## Arquitectura

```
                 ┌─────────────────────────────┐
                 │     Datos (Common Voice +    │
                 │     audios propios + textos) │
                 └──────────┬──────────────────┘
                            │
          ┌─────────────────┼─────────────────┐
          ▼                 ▼                  ▼
   ┌──────────┐     ┌────────────┐     ┌──────────┐
   │ SST       │     │ NMT        │     │ TTS      │
   │ Whisper   │     │ ByT5/T5    │     │ MMS/XTTS │
   └────┬─────┘     └─────┬──────┘     └────┬─────┘
        │                 │                  │
        ▼                 ▼                  ▼
   ┌──────────┐     ┌────────────┐     ┌──────────┐
   │ whisper- │     │ byt5-nmt-  │     │ mms-tts- │
   │ {lang}   │     │ {lang}     │     │ {lang}   │
   └──────────┘     └────────────┘     └──────────┘
        │                 │                  │
        └─────────────────┼──────────────────┘
                          ▼
               ┌──────────────────┐
               │  App React       │
               │  (online/offline)│
               └──────────────────┘
```

## Modelos en HuggingFace

| Modelo | Estado | Notebook |
|--------|--------|----------|
| `sainzpaa/whisper-small-wolof-v1` | ✅ Subido | `sst_finetune_whisper.ipynb` |
| `sainzpaa/byt5-nmt-wolof-v1` | ✅ Subido | `NMT_NLLB200_+_ByT5.ipynb` |
| `sainzpaa/SPANISH-WOLOF-BYT5` | ✅ Subido | (otro checkpoint) |
| `sainzpaa/whisper-small-fula-v1` | ❌ Pendiente | `sst_finetune_whisper.ipynb` |
| `sainzpaa/whisper-small-bambara-v1` | ❌ Pendiente | `sst_finetune_whisper.ipynb` |

## SST: Fine-tuning Whisper

**Notebook:** `notebooks/sst_finetune_whisper.ipynb`

### Datos necesarios

| Lengua | Common Voice | Datos propios | Progreso |
|--------|-------------|---------------|----------|
| Wolof (wo) | ✅ ~15h | ❌ No subido | ✅ Modelo listo |
| Fula (ff) | ✅ ~5h | ❌ No subido | 🔄 Pendiente |
| Bambara (bm) | ❌ (no existe) | ❌ No subido | 🔄 Pendiente |
| Serer (srr) | ❌ (no existe) | ❌ No subido | ⏳ Sin datos |

### Pipeline

1. Carga de Common Voice + datos propios
2. Remuestreo a 16kHz, filtrado de duración
3. Extracción de mel-spectrogramas
4. Fine-tuning con Seq2SeqTrainer
5. Evaluación con WER + CER
6. Subida a HuggingFace Hub
7. (Opcional) Exportación ONNX para móvil

### Métricas objetivo

- WER < 30% para usable
- WER < 15% para buena calidad
- WER < 5% para producción

## NMT: Fine-tuning ByT5

**Notebook:** `notebooks/NMT_NLLB200_+_ByT5.ipynb` (necesita limpieza)

### Datos necesarios

- Mínimo: ~10K pares de traducción
- Ideal: ~100K+ pares
- Wolof ya tiene ~33K pares en dataset HF

### Pipeline

1. Carga de datasets HF (wolof-es, wolof-fr)
2. Tokenización con ByT5 (byte-level, no necesita vocab)
3. Fine-tuning con Seq2SeqTrainer
4. Evaluación con BLEU + chrF
5. Subida a HF Hub

## TTS: Síntesis de Voz

**Notebook:** `notebooks/tts_finetune.ipynb`

### Estrategia por lengua

| Lengua | MMS-TTS | Fine-tuning necesario | Datos |
|--------|---------|---------------------|-------|
| Wolof | ✅ Soporte nativo | No (API directa) | 0 |
| Fula | ✅ Soporte nativo | No (API directa) | 0 |
| Bambara | ✅ Soporte nativo | No (API directa) | 0 |
| Serer | ❌ No soportado | Sí (XTTS-v2/F5) | ~30 min audio |
| Jola | ❌ No soportado | Sí (XTTS-v2/F5) | ~30 min audio |
| Soninké | ❌ No soportado | Sí (XTTS-v2/F5) | ~30 min audio |

## Prioridades

1. **SST Whisper Wolof** ✅ Completado (refinar notebook)
2. **SST Whisper Fula** 🔄 Pendiente (datos en Common Voice)
3. **SST Whisper Bambara** 🔄 Pendiente (necesita datos propios)
4. **NMT ByT5 Wolof** ✅ Completado (limpiar notebook)
5. **TTS Wolof** 🔄 Usar MMS-TTS nativo
6. **TTS Serer/Jola/Soninké** 🔄 Pendiente (necesita audios)
7. **Offline móvil** 🔄 Exportar modelos a ONNX/TFLite

## Skills de Hermes

- `multilingual-translation-systems` — análisis de datasets y modelos NMT
- Knowledge de HF Hub para subir modelos
