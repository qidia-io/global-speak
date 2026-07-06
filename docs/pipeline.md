# Pipeline SST → NMT → TTS

El flujo completo de procesamiento de voz para traducción.

## Pipeline Completo

```
🎤 Grabación (WAV/MP3)
         │
         ▼
┌──────────────────────────┐
│   1. Speech-to-Text     │
│   Whisper Large V3      │
│   Salida: texto fuente  │
└──────────────────────────┘
         │
         ▼
┌──────────────────────────┐
│   2. Normalización      │
│   Limpieza + detección  │
│   de idioma             │
└──────────────────────────┘
         │
         ▼
┌──────────────────────────┐
│   3. Traducción (NMT)   │
│   ByT5 (Español↔Wolof)  │
│   o NLLB-200 (resto)    │
│   Salida: texto trad.   │
└──────────────────────────┘
         │
         ▼
┌──────────────────────────┐
│   4. Text-to-Speech     │
│   MMS-TTS               │
│   Salida: audio WAV     │
└──────────────────────────┘
         │
         ▼
🔊 Audio traducido
```

## Componentes del Pipeline

### 1. Speech-to-Text (Whisper Large V3)

```python
import requests

API_URL = "https://api-inference.huggingface.co/models/openai/whisper-large-v3"
headers = {"Authorization": f"Bearer {HF_TOKEN}"}

def transcribe(audio_bytes: bytes) -> str:
    response = requests.post(API_URL, headers=headers, data=audio_bytes)
    return response.json()["text"]
```

- **Entrada**: Audio WAV/PCM (16kHz, mono)
- **Salida**: Texto plano en el idioma detectado
- **Lenguas**: 99+, incluye Wolof, Fula, Bambara
- **Latencia**: ~2-5s (depende del tamaño del audio)

### 2. Normalización

Pasos intermedios antes de la traducción:

1. **Trim**: Recortar silencios al inicio/final
2. **Detección de idioma**: Confirmar idioma fuente (Whisper ya lo detecta)
3. **Limpieza**: Eliminar caracteres no imprimibles, normalizar espacios
4. **Segmentación**: Dividir textos largos en oraciones

### 3. Traducción (NMT)

**Ruta preferente — ByT5 (Español ↔ Wolof):**

```python
from transformers import AutoTokenizer, AutoModelForSeq2SeqLM

model_name = "sainzpaa/SPANISH-WOLOF-BYT5"
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForSeq2SeqLM.from_pretrained(model_name)

def translate(text: str, source: str, target: str) -> str:
    prefix = f"translate {source} to {target}: "
    inputs = tokenizer(prefix + text, return_tensors="pt", max_length=512, truncation=True)
    outputs = model.generate(**inputs, max_length=512, num_beams=4)
    return tokenizer.decode(outputs[0], skip_special_tokens=True)
```

**Ruta fallback — NLLB-200:**

```python
API_URL = "https://api-inference.huggingface.co/models/facebook/nllb-200-distilled-600M"

def translate_nllb(text: str, source: str, target: str) -> str:
    payload = {
        "inputs": text,
        "parameters": {
            "src_lang": source,  # ej: "spa_Latn"
            "tgt_lang": target,   # ej: "wol_Latn"
        }
    }
    response = requests.post(API_URL, headers=headers, json=payload)
    return response.json()[0]["translation_text"]
```

**Selector de modelo:**

| Par Origen→Destino | Modelo | Notas |
|---|---|---|
| Español ↔ Wolof | ByT5-large (custom) | Fine-tuned, mejor calidad |
| Cualquier otro | NLLB-200 distilled 600M | 200 lenguas |

### 4. Text-to-Speech (MMS-TTS)

```python
API_URL = "https://api-inference.huggingface.co/models/facebook/mms-tts"

def synthesize(text: str, language: str) -> bytes:
    payload = {
        "inputs": text,
        "parameters": {"language": language}
    }
    response = requests.post(API_URL, headers=headers, json=payload)
    return response.content  # audio WAV
```

- **Entrada**: Texto traducido + código de lengua
- **Salida**: Audio WAV
- **Lenguas**: 1100+ idiomas
- **Latencia**: ~2-4s

## Endpoints de Inferencia

| Modelo | Endpoint HF API |
|---|---|
| Whisper Large V3 | `openai/whisper-large-v3` |
| NLLB-200 600M | `facebook/nllb-200-distilled-600M` |
| ByT5 Wolof | `sainzpaa/SPANISH-WOLOF-BYT5` (dedicated endpoint) |
| MMS-TTS | `facebook/mms-tts` |

## Latencia Estimada

| Paso | Tiempo |
|---|---|
| Whisper SST | 2-5s |
| ByT5 NMT | 1-3s |
| MMS-TTS | 2-4s |
| **Total** | **5-12s** |
