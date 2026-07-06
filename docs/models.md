# Modelos de Traducción

## ByT5-large (Español ↔ Wolof)

Modelo fine-tuned desde `google/byt5-large` para traducción bidireccional Español-Wolof.

### Arquitectura

| Parámetro | Valor |
|---|---|
| Arquitectura | T5ForConditionalGeneration |
| Tokenizador | ByT5Tokenizer (byte-level, sin vocab fijo) |
| Capas encoder | 12 (T5Stack) |
| Capas decoder | 4 (T5Stack) |
| Dimensión | 1472 |
| FF hidden | 3584 |
| Cabezas atención | 16 |
| Parámetros totales | ~1.2B |
| Peso del modelo | ~1.2 GB |
| Optimizador | ~2.4 GB (no subido a HF) |

### Entrenamiento

| Parámetro | Valor |
|---|---|
| Dataset | Corpus paralelo Español-Wolof (propio) |
| Épocas | 4 |
| Checkpoint final | `/workspace/output/checkpoints/epoch_4_final` |
| Librería | transformers 4.44.2 |
| Precisión | float32 |
| Device | CPU (entrenamiento local) |

### Subida a HuggingFace

- **Repo**: `sainzpaa/SPANISH-WOLOF-BYT5`
- **CometSSLFile?**: No detectado automáticamente
- **Estado**: Subido y verificado ✅

## NLLB-200 distilled 600M

Modelo base para traducción entre 200 lenguas, usado como respaldo/alternativa.

| Parámetro | Valor |
|---|---|
| Modelo | `facebook/nllb-200-distilled-600M` |
| Lenguas | 200 |
| Tamaño | ~2.4 GB |
| Tokenizador | NllbTokenizer (SentencePiece, 256k vocab) |
| Uso en el proyecto | Fallback para pares no cubiertos por ByT5 |

### Selector de Modelo

La app selecciona el modelo según el par de lenguas:

```
Español ↔ Wolof   → ByT5-large (fine-tuned, mejor calidad)
Otros pares       → NLLB-200 distilled 600M
```

## Whisper Large V3 (Speech-to-Text)

| Parámetro | Valor |
|---|---|
| Modelo | `openai/whisper-large-v3` |
| Uso | Transcripción de voz a texto |
| Lenguas | Multilingüe (99+ idiomas) |
| Tamaño | ~3 GB |

## MMS-TTS (Text-to-Speech)

| Parámetro | Valor |
|---|---|
| Modelo | `facebook/mms-tts` |
| Lenguas | 1100+ idiomas |
| Uso | Síntesis de voz desde texto traducido |

## Evaluación

*(Pendiente: ejecutar evaluaciones BLEU, chrF, COMET sobre el modelo ByT5)*

### Méticas planeadas

- **BLEU**: Precisión de n-gramas entre traducción y referencia
- **chrF**: Precisión a nivel de caracteres (mejor para lenguas aglutinantes)
- **COMET**: Evaluación neuronal basada en embeddings
- **WER**: Word Error Rate (para SST con Whisper)
- **MOS**: Mean Opinion Score (para TTS)
