# Global Speak — Arquitectura del Sistema

> **Sistema multilingüe SST→NMT→TTS para migrantes senegaleses**
> *Versión: 2.0 — Multi-agente Hermes | Julio 2026*
> *Blueprint que guía a Echo, Janus, Mbok y Sankofa*

---

## Tabla de Contenidos

1. [Visión General y Filosofía](#1-visión-general-y-filosofía)
2. [Arquitectura Multiagente](#2-arquitectura-multiagente)
3. [Diagrama General del Sistema](#3-diagrama-general-del-sistema)
4. [Pipeline SST→NMT→TTS (Voz)](#4-pipeline-sstnmt-tts-voz)
5. [Model Router — Enrutamiento Config-Driven](#5-model-router--enrutamiento-config-driven)
6. [Pipeline de Datos (Data Curation & ETL)](#6-pipeline-de-datos-data-curation--etl)
7. [Quality Gates — Definición Formal](#7-quality-gates--definición-formal)
8. [Glosario y Diccionario (Glossary Integration)](#8-glosario-y-diccionario-glossary-integration)
9. [App React + Capacitor](#9-app-react--capacitor)
10. [Infraestructura y Deployment](#10-infraestructura-y-deployment)
11. [Estrategia para Nuevas Lenguas](#11-estrategia-para-nuevas-lenguas)
12. [Evaluación y Métricas](#12-evaluación-y-métricas)
13. [Diagramas de Flujo de Datos](#13-diagramas-de-flujo-de-datos)
14. [Decisiones Tecnológicas](#14-decisiones-tecnológicas)
15. [Referencias](#15-referencias)

---

## 1. Visión General y Filosofía

### Propósito

Global Speak permite a migrantes senegaleses comunicarse en tiempo real mediante traducción de voz y texto entre lenguas senegalesas (Wolof, Fula, Bambara, Serer, Jola, Soninké) y lenguas europeas (Español, Francés, Inglés).

### Filosofía Arquitectónica

> **Cada idioma nuevo es un "plugin" que sigue el mismo pipeline — recolectar, curar, entrenar, validar, desplegar.**

| Principio | Implicación |
|-----------|-------------|
| **Config-driven routing** | Nueva lengua = 1-2 líneas en un mapa, sin tocar lógica de producción |
| **Quality gates first** | Ningún dato entra al pipeline sin pasar filtros automáticos |
| **Real data transformation** | No solo detectar problemas — transformar y limpiar datos activamente |
| **Multi-agent orchestration** | Cada fase tiene un agente especializado, orquestado por Nemrod |
| **Inference via API** | Modelos servidos por HF Inference API, no servidores propios |
| **Offline-first app** | La app funciona con mock/fallback cuando no hay conexión |

### Stack Tecnológico Resumido

```
Frontend:   React 18 + TypeScript + Vite + Capacitor + shadcn/ui + Tailwind
Inferencia: HuggingFace Inference API (Whisper + NLLB-200/ByT5 + MMS-TTS)
Orquestación: Hermes Agent + 4 perfiles especializados
Código:     GitHub (qidia-io/global-speak)
Modelos:   HuggingFace Hub (sainzpaa/*)
```

---

## 2. Arquitectura Multiagente

### Mapa del Equipo

```
     👑 NEMROD (default) — Arquitecto, diseña, documenta y coordina
     ─────────────────────────────────────────────────────────────
     │                 │                 │                 │
  🎤 Echo           🔄 Janus          🏗️ Mbok           📊 Sankofa
  translator        linguist          coder             curator
  Voz+Audio         Fine-tuning       App React         Data Curation
  SST/NMT/TTS       Notebooks         Capacitor/API     Quality Gates
```

### Matriz de Responsabilidades

| Agente | Perfil Hermes | Área | Lo que NO hace |
|--------|---------------|------|----------------|
| **Nemrod** 🧠 | `default` | Arquitectura, documentación, orquestación | No codea, no hace fine-tuning, no toca la app |
| **Echo** 🎤 | `translator` | SST→NMT→TTS pipeline, calidad de audio, latencia | No toca notebooks, no modifica la app |
| **Janus** 🔄 | `linguist` | Fine-tuning, notebooks, evaluación de modelos | No toca datos crudos, no despliega apps |
| **Mbok** 🏗️ | `coder` | App React + Capacitor, API client, compilación | No entrena modelos, no cura datos |
| **Sankofa** 📊 | `curator` | Data curation, quality gates, ETL, glossaries | No despliega apps, no modifica notebooks |

### Ciclo de Orquestación de Nemrod

```
1. RECIBIR solicitud del usuario
     │
     ▼
2. DIAGNOSTICAR estado actual → leer STATUS.md, ROADMAP.md, archivos afectados
     │
     ▼
3. DESCOMPONER en tareas → determinar dependencias, paralelizables vs secuenciales
     │
     ▼
4. DELEGAR a agentes → delegate_task con goal + context precisos
     ├── Tareas independientes → delegate_task(tasks=[...]) en paralelo
     └── Tareas secuenciales → delegate_task una por una
     │
     ▼
5. VERIFICAR resultados → stat archivos, validar contenido, compilar/test
     │
     ▼
6. ACTUALIZAR STATUS.md → reflejar avances, problemas, decisiones
```

---

## 3. Diagrama General del Sistema

### Vista Macro: Tres Entornos

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                         ENTORNO DE DESARROLLO (VPS)                          │
│                    46.224.226.201 — CPU-only, 75GB SSD                       │
│                                                                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────────────────────┐│
│  │ Sankofa  │→ │ Quality  │→ │ Datasets │→ │ Janus                        ││
│  │ Ingesta  │  │ Gates    │  │ Curados  │  │ Notebooks + Evaluación       ││
│  │ Datos    │  │ (4 gates)│  │ 80/10/10 │  │ (sin GPU — CPU para eval)    ││
│  └──────────┘  └──────────┘  └──────────┘  └──────────────┬───────────────┘│
│                                                            │                │
│  ┌─────────────────────────────────────────────────────────┐│               │
│  │  Código fuente: GitHub qidia-io/global-speak            ││               │
│  │  ├── app/          → Frontend React + Capacitor         ││               │
│  │  ├── pipeline/     → Pipeline Python standalone         ││               │
│  │  ├── notebooks/    → Notebooks de entrenamiento         ││               │
│  │  ├── data/         → Datasets crudos + procesados       ││               │
│  │  ├── scripts/      → ETL, parseo, limpieza              ││               │
│  │  ├── db/           → Esquemas SQL                       ││               │
│  │  └── docs/         → Documentación técnica              ││               │
│  └─────────────────────────────────────────────────────────┘│               │
└──────────────────────────────┬───────────────────────────────────────────────┘
                               │
                               │
                               ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                    ENTORNO DE ENTRENAMIENTO (GPU Cloud)                      │
│                 RunPod / Colab / Vast.ai — Temporal                          │
│                                                                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌────────────────────────────┐  │
│  │ Dataset  │→ │ Train    │→ │ Eval     │→ │ Export → HF Hub           │  │
│  │ Loader   │  │ Loop     │  │ BLEU/    │  │ sainzpaa/*                │  │
│  │          │  │ LoRA/FT  │  │ chrF/    │  │                           │  │
│  │          │  │          │  │ COMET    │  │                           │  │
│  └──────────┘  └──────────┘  └──────────┘  └───────────────────────────┘  │
│                                                                              │
│  Tracking: Weights & Biases (opcional)                                       │
└──────────────────────────────┬───────────────────────────────────────────────┘
                               │
                               ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                         PRODUCCIÓN (HF Inference API)                        │
│                                                                              │
│  ┌──────────┐    ┌────────────────────┐    ┌──────────┐                     │
│  │ Whisper  │───→│ Model Router       │───→│ MMS-TTS  │                     │
│  │ Large V3 │    │ ByT5 ↔ NLLB-200    │    │ (español)│                     │
│  │ (SST)    │    │ + Glossary Lookup  │    │ (TTS)    │                     │
│  └──────────┘    └────────────────────┘    └──────────┘                     │
│                        │                                                    │
│                        ▼                                                    │
│              ┌──────────────────────┐                                       │
│              │  App React +         │                                       │
│              │  Capacitor           │                                       │
│              │  (Android / Web)     │                                       │
│              └──────────────────────┘                                       │
└──────────────────────────────────────────────────────────────────────────────┘
```

### Vista del Pipeline Completo

```
🎤 AUDIO ENTRADA
    │
    ▼
┌──────────────────────────────────────────────┐
│                  ECHO 🎤                      │
│  ┌────────────────────────────────────────┐  │
│  │ 1. SST — Whisper Large V3              │  │
│  │    Audio → Texto (Wolof/Español/...)  │  │
│  │    Latencia: ~2-5s (CPU: ~60s/3s)     │  │
│  └──────────────────┬─────────────────────┘  │
└─────────────────────┼────────────────────────┘
                      │ Texto transcrito
                      ▼
┌──────────────────────────────────────────────┐
│            MODEL ROUTER (config-driven)       │
│                                              │
│  ┌──────────────────┐  ┌─────────────────┐  │
│  │ ByT5 (fine-tuned)│  │ NLLB-200 600M   │  │
│  │ es↔wo            │  │ resto de pares  │  │
│  └────────┬─────────┘  └────────┬────────┘  │
│           │                     │            │
│           ▼                     ▼            │
│  ┌────────────────────────────────────────┐  │
│  │ Glossary Lookup (enhance prompt)      │  │
│  │ Fuzzy match > 0.85 contra glossary DB │  │
│  └──────────────────┬─────────────────────┘  │
└─────────────────────┼────────────────────────┘
                      │ Texto traducido
                      ▼
┌──────────────────────────────────────────────┐
│                  ECHO 🎤                      │
│  ┌────────────────────────────────────────┐  │
│  │ 3. TTS — MMS-TTS                      │  │
│  │    Texto → Audio (español / wolof)    │  │
│  │    Latencia: ~2-4s (CPU: ~6s/3s)     │  │
│  └──────────────────┬─────────────────────┘  │
└─────────────────────┼────────────────────────┘
                      │ Audio sintetizado
                      ▼
🔊 AUDIO TRADUCIDO (reproducido en app)
```

---

## 4. Pipeline SST→NMT→TTS (Voz)

### 4.1 Speech-to-Text — Whisper Large V3

| Propiedad | Valor |
|-----------|-------|
| Modelo | `openai/whisper-large-v3` |
| Fine-tuned | `sainzpaa/whisper-small-wolof-v1` (Wolof) |
| Entrada | WAV/PCM 16kHz, mono, 16-bit |
| Salida | Texto plano (detección automática de idioma) |
| Latencia (HF API) | ~2-5s |
| Latencia (CPU local) | ~60s por 3s de audio |

**Endpoint:**
```
POST https://api-inference.huggingface.co/models/openai/whisper-large-v3
Authorization: Bearer {HF_TOKEN}
Body: audio_bytes (raw)
→ {"text": "Nanga def?"}
```

### 4.2 Text-to-Speech — MMS-TTS

| Propiedad | Valor |
|-----------|-------|
| Modelo | `facebook/mms-tts-spa` |
| Entrada | Texto + código de lengua |
| Salida | Audio WAV |
| Latencia (HF API) | ~2-4s |
| Latencia (CPU local) | ~6s por 3s de audio |
| Lenguas | 1100+ |

**Endpoint:**
```
POST https://api-inference.huggingface.co/models/facebook/mms-tts
Body: {"inputs": "texto", "parameters": {"language": "spa"}}
```

### 4.3 Modo Texto (sin audio)

```
⌨️ Usuario escribe texto
    │
    ▼
Model Router → ByT5/NLLB-200 → texto traducido
    │
    ▼
(Opcional) MMS-TTS → audio
```

### 4.4 Pipeline Python Standalone

`/root/proyecto/full-review/pipeline/pipeline.py`

- CLI con `argparse` compatible con la app React
- Model Router idéntico a `modelRouter.ts`
- HF Inference API vía `requests` (sin transformers/torch)
- `--mock` flag para testing offline
- Modo automático: detecta si input es archivo de audio o texto
- 1 retry con backoff 2s en errores 5xx
- Logging con timestamps

```bash
# Modo texto
python3 pipeline.py "Nanga def?" --src wo --tgt es

# Modo audio
python3 pipeline.py input.wav --src es --tgt wo --output translated.wav

# Modo mock (sin HF_TOKEN)
python3 pipeline.py "Nanga def?" --src wo --tgt es --mock
```

---

## 5. Model Router — Enrutamiento Config-Driven

### 5.1 Arquitectura

El Model Router es el corazón de la escalabilidad del sistema. En lugar de `if/else` por cada par de lenguas (anti-patrón), usa un mapa de rutas configurable:

```typescript
// src/config/modelRouter.ts
const MODEL_ROUTES: Record<string, RouteConfig> = {
  'es-wo': { model: 'sainzpaa/byt5-nmt-wolof-v1', type: 'byt5' },
  'wo-es': { model: 'sainzpaa/byt5-nmt-wolof-v1', type: 'byt5' },
  'es-bm': { model: 'sainzpaa/byt5-nmt-bambara-v1', type: 'byt5' },  // futuro
  'bm-es': { model: 'sainzpaa/byt5-nmt-bambara-v1', type: 'byt5' },  // futuro
  '*':     { model: 'facebook/nllb-200-distilled-600M', type: 'nllb' },
};

function getRoute(source: string, target: string): RouteConfig {
  const key = `${source}-${target}`;
  return MODEL_ROUTES[key] || MODEL_ROUTES['*'];
}
```

**Propiedades:**
- Nueva lengua = 1-2 líneas en el mapa, sin tocar `translateText()`
- `*` comodín atrapa todo lo no mapeado
- `translateText()` pregunta `getRoute(src, tgt)` — no sabe qué modelo usa

### 5.2 Cobertura de NLLB-200 para Lenguas Senegalesas

| Lengua | Código ISO | Código NLLB | ¿En NLLB-200? | Prioridad fine-tune |
|--------|-----------|-------------|---------------|-------------------|
| Wolof | wo | `wol_Latn` | ✅ Sí | ByT5 fine-tuned ya existe |
| Bambara | bm | `bam_Latn` | ✅ Sí | Alta |
| Fula | ff | `ful_Latn` | ✅ Sí | Alta |
| Serer | srr | ❌ No existe | ❌ No | Obligatorio |
| Jola (Fogny) | dyo | ❌ No existe | ❌ No | Obligatorio |
| Soninké | snk | ❌ No existe | ❌ No | Obligatorio |

### 5.3 Modelos en Producción

| Modelo | HF Hub | Propósito | Estado |
|--------|--------|-----------|--------|
| Whisper Wolof | `sainzpaa/whisper-small-wolof-v1` | SST Wolof (fine-tuned) | ✅ Activo |
| ByT5 Wolof v1 | `sainzpaa/byt5-nmt-wolof-v1` | NMT es↔wo | ✅ Activo |
| ByT5 Wolof v2 | `sainzpaa/SPANISH-WOLOF-BYT5` | NMT es↔wo (checkpoint alt.) | ✅ Activo |
| NLLB-200 600M | `facebook/nllb-200-distilled-600M` | NMT fallback 200 lenguas | ✅ Disponible |
| Whisper Large V3 | `openai/whisper-large-v3` | SST multilingüe | ✅ Disponible |
| MMS-TTS | `facebook/mms-tts-spa` | TTS español | ✅ Disponible |

### 5.4 Pitfall Conocido: ByT5 Wolof v1 Corrupto

El modelo `byt5-nmt-wolof-v1` fue entrenado como **denoising** en lugar de **seq2seq**. `state.json` reporta `step=0` con `epoch=7`. No funciona para traducción directa. Usar `SPANISH-WOLOF-BYT5` como alternativa.

---

## 6. Pipeline de Datos (Data Curation & ETL)

### 6.1 Flujo de Sankofa

```
DATOS CRUDOS (ZIP/OPUS Moses/NLLB format/CSV)
    │
    ▼
┌──────────────────────────────────────────────────────┐
│                 SANKOFA 📊 DATA CURATOR               │
│                                                      │
│  Paso 1: DETECCIÓN DE DUPLICADOS                    │
│    ├── Comparar nombre de corpus con data/raw/      │
│    ├── Comparar SHA-256 o file sizes + counts       │
│    ├── Verificar en data/processed/{pair}/          │
│    └── Si duplicado → informar, no reprocesar       │
│                                                      │
│  Paso 2: EXTRACCIÓN                                 │
│    ├── OPUS Moses → leer .{src} y .{tgt} como pares │
│    └── NLLB format → leer nllb.{pair}.{lang}        │
│                                                      │
│  Paso 3: LIMPIEZA REAL (produce datos, no reportes) │
│    ├── strip puntuación redundante                  │
│    ├── ftfy (corrige U+FFFD, guess encoding)        │
│    ├── NFKC normalize (unicodedata)                 │
│    ├── remove non-printables                        │
│    ├── dedup exacta (string match)                  │
│    ├── dedup fuzzy (rapidfuzz > 0.95)               │
│    └── shuffle aleatorio                            │
│                                                      │
│  Paso 4: QUALITY GATES (4 gates)                    │
│    ├── Ingestion Gate (archivos válidos)            │
│    ├── Language Gate (idioma correcto)              │
│    ├── Quality Gate (score compuesto)               │
│    └── Pivot Gate (si es pivoteo)                   │
│                                                      │
│  Paso 5: SPLIT 80/10/10                             │
│    ├── data/processed/{pair}/{source}/train.csv     │
│    ├── data/processed/{pair}/{source}/val.csv       │
│    └── data/processed/{pair}/{source}/test.csv      │
│                                                      │
│  Paso 6: REPORTE                                    │
│    └── reporte_limpieza.md con BEFORE/AFTER         │
│                                                      │
└──────────────────────────────────────────────────────┘
```

### 6.2 Resultados Reales de Limpieza (Julio 2026)

| Par | Fuentes | Inicial | Final | Retención | Chars reparados |
|-----|---------|---------|-------|-----------|-----------------|
| es-wo | 3 (MultiCC, bible, XLEnt) | 39.214 | 37.094 | 94.6% | 173.765 |
| en-wo | 2 (CCAligned, NLLB) | 1.548.862 | 1.470.010 | 94.9% | ~5M |
| fr-wo | 1 (NLLB) | 376.455 | 366.837 | 97.4% | ~2M |
| **TOTAL** | **6 fuentes** | **1.964.531** | **1.873.941** | **95.4%** | **7.118.699** |

### 6.3 Rechazos por Quality Gates

| Razón | es-wo | en-wo | fr-wo | Total |
|-------|-------|-------|-------|-------|
| empty | 46 | 4 | 0 | 50 |
| too_long | 4 | 19 | 0 | 23 |
| unbalanced_ratio | 114 | 788 | 112 | 1.014 |
| wrong_lang | 7 | 81 | 0 | 88 |
| **Total** | **171** | **892** | **112** | **1.175** |

Retención global: **95.4%** sobre 1.96M pares.

### 6.4 Pipeline de Limpieza de Audio

Para audios crudos (grabaciones de campo, entrenamiento SST/TTS):

```
1. Filtrado de ruido    → ffmpeg anlmdn o sox
2. Normalización volumen → ffmpeg loudnorm, target RMS -23dB
3. Recorte de silencios → ffmpeg silenceremove (1% threshold)
4. Segmentación         → frames de 25ms con hop 10ms
5. Conversión a WAV     → 16kHz, mono, PCM 16-bit
6. MFCC extraction      → 13 coeficientes (librosa)
7. PCA reduction        → mantener 95% varianza
8. Salida por audio     → audio_clean.wav + audio_features.npy
```

---

## 7. Quality Gates — Definición Formal

Cada quality gate es un script ejecutable que retorna **PASS / WARN / FAIL**:

### Gate 1: Ingestion Gate

```python
def ingestion_gate(dataset_path: str) -> GateResult:
    """
    - Archivos existen y no están vacíos
    - Mismo número de líneas en src y tgt
    - Codificación UTF-8 válida
    """
```

### Gate 2: Language Gate

```python
def language_gate(pairs: list, expected_langs: tuple) -> GateResult:
    """
    - FAIL si >10% de líneas no coinciden con idioma esperado
    - Usa fastText o langdetect (o heurística wolof si no disponible)
    """
```

### Gate 3: Quality Gate

```python
def quality_gate(pairs: list) -> GateResult:
    """
    - Puntuación compuesta (longitud, ratio, caracteres extraños)
    - Score 0-100
    - FAIL si quality_score < 50
    """
```

### Gate 4: Pivot Gate

```python
def pivot_gate(synthetic_pairs: list, confidence_scores: list) -> GateResult:
    """
    - FAIL si confidence < 0.8 promedio
    - FAIL si lang_detect no coincide en >90%
    - WARN si >10% de pares no tienen sentido semántico
    """
```

### Arquivos de Quality Gates

| Archivo | Propósito |
|---------|-----------|
| `/pipeline/data/quality.py` | Implementación de los 4 gates |
| `/pipeline/data/cleaning.py` | Limpieza real (ftfy, NFKC, dedup) |
| `/pipeline/data/ingestion.py` | Carga desde OPUS Moses, HF |
| `/pipeline/data/dedup.py` | Dedup exacta + fuzzy |
| `/pipeline/data/pivoting.py` | Pivoteo multilingüe con NLLB |

---

## 8. Glosario y Diccionario (Glossary Integration)

### 8.1 Arquitectura

```
┌─────────────────────────────────────────────────┐
│                  GLOSSARY LOOKUP                 │
│                                                  │
│  Texto de entrada: "Mangi dem sil sa biro."     │
│                        │                        │
│                        ▼                        │
│  ┌─────────────────────────────────────────┐   │
│  │ 1. Tokenización básica (split por       │   │
│  │    espacios + puntuación)               │   │
│  └──────────────────┬──────────────────────┘   │
│                     ▼                          │
│  ┌─────────────────────────────────────────┐   │
│  │ 2. Para cada token:                     │   │
│  │    ├── exact_lookup(token) → 1.0 match │   │
│  │    └── fuzzy_lookup(token, >0.80)       │   │
│  │        → 0.80-0.99 match (OCR rescue)  │   │
│  └──────────────────┬──────────────────────┘   │
│                     ▼                          │
│  ┌─────────────────────────────────────────┐   │
│  │ 3. enhance_prompt(texto):               │   │
│  │    Genera contexto para NMT:            │   │
│  │    "Glossary: dem → go, sil → place"   │   │
│  └─────────────────────────────────────────┘   │
│                     │                          │
│                     ▼                          │
│  Prompt enriquecido → ByT5 / NLLB-200          │
└─────────────────────────────────────────────────┘
```

### 8.2 Fuentes de Datos del Glosario

| Fuente | Entradas | Método | Calidad |
|--------|----------|--------|---------|
| Peace Corps Wolof-English Dictionary | 5.021 | OCR + parse | Alta (verificado humano) |
| Diccionario estructurado | 779 | Manual + parse | Alta |

### 8.3 Esquema de Base de Datos

```sql
-- Glossary DB: data/glossary/glossary.db

CREATE TABLE glossary (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    word TEXT NOT NULL,
    part_of_speech TEXT,
    definition TEXT NOT NULL,
    language TEXT DEFAULT 'wo',
    source TEXT DEFAULT 'peace_corps',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE bilingual_pairs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    source_word TEXT NOT NULL,
    source_lang TEXT DEFAULT 'wo',
    target_word TEXT,
    target_lang TEXT DEFAULT 'en',
    definition TEXT,
    source TEXT DEFAULT 'peace_corps',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 8.4 Pipeline de Ingesta (OCR → DB)

Para diccionarios antiguos con encoding corrupto (PDFs pre-2010):

```
PDF con encoding roto (Acrobat Distiller 2.x)
    │
    ▼
1. mutool draw -F png -r 200 → páginas como PNG
    │
    ▼
2. Tesseract OCR → texto raw (~5-10% error OCR aceptable)
    │
    ▼
3. parse_glossary.py → regex: palabra (tipo) definición.
    │
    ▼
4. Dedup (palabra más larga/más completa)
    │
    ▼
5. SQLite insert → glossary.db
    │
    ▼
6. glossary_lookup.py → fuzzy match + prompt enhancement
```

---

## 9. App React + Capacitor

### 9.1 Estructura de la App

```
app/
├── src/
│   ├── components/        # UI components (shadcn/ui)
│   ├── screens/           # 4 pantallas principales
│   │   ├── HomeScreen.tsx
│   │   ├── VoiceScreen.tsx
│   │   ├── TextScreen.tsx
│   │   └── SettingsScreen.tsx
│   ├── services/
│   │   ├── inferenceClient.ts   # API calls + Model Router
│   │   ├── audio.ts             # Grabación/reproducción
│   │   └── storage.ts           # localStorage (historial)
│   ├── config/
│   │   ├── modelRouter.ts       # Config-driven routing
│   │   └── languages.ts         # Lenguas soportadas
│   ├── hooks/                   # Custom React hooks
│   └── lib/                     # Utilities
├── package.json
└── capacitor.config.ts
```

### 9.2 Flujo de la App

```
Pantalla Home
    │
    ├──→ VoiceScreen: 🎤 Grabar → SST → NMT → TTS → 🔊 Reproducir
    │
    ├──→ TextScreen:  ⌨️ Escribir → NMT → Mostrar traducción (opcional TTS)
    │
    └──→ SettingsScreen: ⚙️ Seleccionar lenguas, ver historial
```

### 9.3 inferenceClient.ts (Servicio Central)

```
inferenceClient.translateText(source, target, text)
    │
    ├── getRoute(source, target) → {model, type}
    │
    ├── if (mock mode) → return placeholder
    │
    ├── if (type === 'byt5')
    │     POST /models/sainzpaa/byt5-nmt-wolof-v1
    │
    ├── if (type === 'nllb')
    │     POST /models/facebook/nllb-200-distilled-600M
    │     Body: { inputs: text, parameters: { src_lang, tgt_lang } }
    │
    └── retry 1x con backoff 2s si error 5xx/timeout
```

### 9.4 Arquitectura de Audio

```typescript
// Servicio de audio (audio.ts)
interface AudioService {
  startRecording(): Promise<void>;     // MediaRecorder API
  stopRecording(): Promise<Blob>;      // WAV/MP3 blob
  playAudio(url: string): Promise<void>; // Web Audio API
  visualize(analyserNode): void;       // Visualización en tiempo real
}
```

---

## 10. Infraestructura y Deployment

### 10.1 Entornos

| Entorno | Servidor | CPU/GPU | Propósito |
|---------|----------|---------|-----------|
| Desarrollo | 46.224.226.201 (VPS) | CPU-only, 4 vCPU, 75GB SSD | Data curation, quality gates, pipeline testing, notebooks |
| Entrenamiento | RunPod / Colab / Vast.ai | GPU (24-80GB VRAM) | Fine-tuning por época |
| Producción | HF Inference API | Serverless | Inferencia ligera sin servidor propio |

### 10.2 Hardware Decision Matrix

| Opción | Coste | VRAM | Ideal para |
|--------|-------|------|------------|
| Google Colab (free T4) | 0€ | 15GB | Evaluación, pruebas, fine-tune pequeño |
| Colab Pro+ (A100) | ~50€/mes | 40GB | Fine-tuning ByT5-large |
| RunPod RTX 4090 | ~0.50€/hora | 24GB | Fine-tuning iterativo (spot) |
| Vast.ai spot | ~0.30€/hora | 24-48GB | Batch fine-tuning económico |
| HF AutoTrain | Pago/ejecución | Automatizado | Sin gestión de infra |

**Recomendación:** RunPod spot para fine-tuning iterativo, HF Inference API para inferencia.

### 10.3 Pipeline CI/CD (planeado)

```
GitHub Push
    │
    ▼
GitHub Actions
    ├── Lint (tsc --noEmit, eslint)
    ├── Test (vitest)
    ├── Build (vite build)
    └── (Opcional) Deploy APK
```

### 10.4 Códigos NLLB para Lenguas del Proyecto

| Lengua | Código NLLB | En modelo |
|--------|-------------|-----------|
| Español | `spa_Latn` | Sí |
| Wolof | `wol_Latn` | Sí |
| Bambara | `bam_Latn` | Sí |
| Fula | `ful_Latn` | Sí |
| Francés | `fra_Latn` | Sí |
| Inglés | `eng_Latn` | Sí |
| Serer | ❌ No en NLLB | Fine-tune requerido |
| Jola (Fogny) | ❌ No en NLLB | Fine-tune requerido |
| Soninké | ❌ No en NLLB | Fine-tune requerido |

---

## 11. Estrategia para Nuevas Lenguas

### 11.1 Flujo Completo

```
Fase 1: DATA CURATION          → Sankofa 📊
  ├── Buscar fuentes (OPUS, Tatoeba, Bible, NLLB-mined)
  ├── Extraer, limpiar, quality gates
  └── Split 80/10/10 → processed/

Fase 2: VERIFICACIÓN           → Nemrod 🧠
  ├── Revisar reporte de calidad
  └── Aprobar o re-delegar

Fase 3: EVALUACIÓN BASELINE    → Sankofa + Echo
  ├── BLEU + chrF con NLLB-200 como baseline
  └── Determinar si fine-tune mejora

Fase 4: FINE-TUNING            → Janus 🔄 (GPU necesaria)
  ├── Fine-tune ByT5 con datos limpios
  ├── Evaluar contra test set
  ├── Early stopping si no mejora
  └── Subir mejor checkpoint a HF Hub

Fase 5: DESPLIEGUE             → Mbok 🏗️
  ├── 1-2 líneas en modelRouter.ts
  ├── 1 línea en languages.ts
  ├── Probar pipeline end-to-end (Echo verifica)
  └── Compilar APK si app móvil
```

### 11.2 Criterios de Aceptación para Nueva Lengua

1. **Data**: Mínimo 10.000 pares paralelos limpios
2. **Quality Gates**: Todos PASS con retention > 80%
3. **Métrica**: BLEU > 15 o mejor que NLLB baseline en > 5 puntos
4. **Pipeline**: Traducción real demostrada con `pipeline.py`
5. **App**: Seleccionable desde la interfaz de lenguas

---

## 12. Evaluación y Métricas

### 12.1 Métricas por Componente

| Componente | Métrica | Herramienta | ¿GPU? |
|-----------|---------|-------------|-------|
| NMT (ByT5/NLLB) | BLEU | `sacrebleu` | ❌ No |
| NMT (ByT5/NLLB) | chrF++ | `sacrebleu --metric chrF` | ❌ No |
| NMT (ByT5/NLLB) | COMET | `unbabel-comet` | ✅ Opcional |
| SST (Whisper) | WER | `jiwer` | ❌ No |
| TTS (MMS-TTS) | MOS | Evaluación humana | ❌ No |

### 12.2 Pipeline de Evaluación

```
1. Sankofa: quality gates + dedup + split → test_set_limpio.json
2. Nemrod: verificar test set (BEFORE/AFTER samples)
3. Sankofa+Echo: sacrebleu --metric bleu test_set.jsonl
   Sankofa+Echo: sacrebleu --metric chrF test_set.jsonl
4. (Opcional, GPU) Sankofa+Echo: comet-score --model wmt22-comet-da
5. Janus: comparar con baseline, decidir fine-tuning
```

### 12.3 Script de Evaluación

`/root/proyecto/full-review/scripts/evaluate_nmt.py`
- Acepta `--test-set`, `--model`, `--pair`, `--sample`, `--output-dir`, `--seed`
- Muestreo estratificado por fuente
- Cliente HF Inference API con 3 retries + exponential backoff
- BLEU (tokenize=flores200) y chrF (word_order=2) via sacrebleu
- Desglose por fuente, mejores/peores ejemplos, predicciones raw JSONL

---

## 13. Diagramas de Flujo de Datos

### 13.1 Flujo: Traducción de Voz (Modo Voz)

```
┌──────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────┐
│ User │────→│ App      │────→│ Whisper  │────→│ Model    │────→│ User │
│ habla│     │ graba    │     │ SST      │     │ Router   │     │ oye  │
│      │     │ WAV      │     │→texto   │     │→texto   │     │      │
└──────┘     └──────────┘     └──────────┘     └────┬─────┘     └──────┘
                                                     │           ▲
                                                     ▼           │
                                              ┌──────────┐     ┌──────┐
                                              │ MMS-TTS  │────→│ App  │
                                              │ texto→   │     │ repro│
                                              │ audio    │     │duce  │
                                              └──────────┘     └──────┘
```

### 13.2 Flujo: Curación de Datos (Sankofa)

```
┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│  ZIP /   │───→│ Extract  │───→│ Clean    │───→│ Quality  │
│  OPUS    │    │ + Detect │    │ ftfy +   │    │ Gates    │
│  Moses   │    │ Dupes    │    │ NFKC +   │    │ 1-4      │
│  NLLB    │    │          │    │ Dedup    │    │          │
└──────────┘    └──────────┘    └──────────┘    └────┬─────┘
                                                     │
                                                     ▼
                                              ┌──────────┐    ┌──────────┐
                                              │ Split    │───→│ train/   │
                                              │ 80/10/10 │    │ val/test │
                                              └──────────┘    │ .csv     │
                                                              └──────────┘
```

### 13.3 Flujo: Fine-tuning (Janus → GPU Cloud)

```
┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│ Processed│───→│ Load on  │───→│ Train    │───→│ Eval     │
│ Dataset  │    │ GPU      │    │ ByT5     │    │ BLEU/    │
│          │    │          │    │ LoRA/FT  │    │ chrF     │
└──────────┘    └──────────┘    └──────────┘    └────┬─────┘
                                                     │
                                                     ▼
                                              ┌──────────┐    ┌──────────┐
                                              │ Push to  │───→│ Update   │
                                              │ HF Hub   │    │ model    │
                                              │          │    │ Router   │
                                              └──────────┘    └──────────┘
```

---

## 14. Decisiones Tecnológicas

### 14.1 ¿Por qué HF Inference API en lugar de servidor propio?

| Factor | HF Inference API | Servidor propio (FastAPI) |
|--------|-----------------|--------------------------|
| Coste fijo | 0€ (modelos públicos) | ~10-50€/mes VPS |
| Mantenimiento | Cero | Gestionar dependencias, updates |
| Escalabilidad | Serverless, automática | Vertical limitada |
| Latencia | 2-12s | Similar + overhead gestión |
| Modelos disponibles | 200k+ | Los que instales |
| Control de datos | Menos (datos pasan por HF) | Total |

**Decisión:** HF Inference API para prototipo y uso ligero. Backend propio planeado para Milestone 4 si es necesario.

### 14.2 ¿Por qué ByT5 (byte-level) en lugar de tokenizador subword?

- **Lenguas sin tokenizador**: Wolof, Serer, Jola no tienen SentencePiece/BPE entrenado. ByT5 opera sobre bytes UTF-8, eliminando la necesidad de tokenizador.
- **Robustez ortográfica**: Tolera variaciones dialectales y ruido OCR mejor que modelos subword.
- **Contrapartida**: Secuencias ~4x más largas (cada char = 1-4 bytes), mayor coste computacional.

### 14.3 ¿Por qué NLLB-200 como fallback?

- **200 lenguas** cubiertas, incluyendo las principales lenguas senegalesas (wo, bm, ff)
- **Calidad probada**: Entrenado con datos curados por Meta
- **Tamaño manejable**: Distilled 600M funciona en CPU
- **Limitación**: Calidad pobre para frases cortas cotidianas (ej: "Nanga def?" → "¿Quién lo hizo?" en wolof→español)

### 14.4 ¿Por qué shadcn/ui + Radix?

- **Accesibilidad nativa**: Radix UI proporciona componentes accesibles por defecto
- **Personalización**: shadcn/ui son copiables al proyecto, modificables
- **Tamaño**: Sin dependencia runtime pesada (no es una "library" instalada)
- **Tailwind**: Estilos consistentes sin CSS modules

### 14.5 ¿Por qué Capacitor en lugar de React Native?

| Factor | Capacitor | React Native |
|--------|-----------|-------------|
| Código compartido | Web + móvil mismo codebase | Necesita capa de bridging |
| Curva de aprendizaje | React web skills transferibles | Aprendizaje RN específico |
| Compilación | Vite build + wrap | Metro bundler + native build |
| Ecosistema | Plugins JS + nativos | Comunidad RN enorme |

---

## 15. Referencias

### Documentación del Sistema

| Documento | Ruta | Contenido |
|-----------|------|-----------|
| **Este documento** | `docs/ARCHITECTURE_SYSTEM.md` | Arquitectura completa del sistema |
| Arquitectura app | `docs/architecture.md` | Vista app + API |
| Pipeline detalles | `docs/pipeline.md` | Pipeline SST→NMT→TTS detallado |
| Modelos | `docs/models.md` | Catálogo de modelos y parámetros |
| Setup | `docs/setup.md` | Instrucciones de instalación |
| Lenguas | `docs/languages.md` | Códigos y configuración de lenguas |
| App | `docs/app.md` | Documentación de la app |

### Perfiles de Agentes (Hermes)

| Agente | Perfil | SOUL.md | Skill |
|--------|--------|---------|-------|
| Nemrod 🧠 | `default` | `~/.hermes/SOUL.md` | `nemrod-orchestration` |
| Echo 🎤 | `translator` | `~/.hermes/profiles/translator/SOUL.md` | `echo-voice-pipeline` |
| Janus 🔄 | `linguist` | `~/.hermes/profiles/linguist/SOUL.md` | `janus-finetuning` |
| Mbok 🏗️ | `coder` | `~/.hermes/profiles/coder/SOUL.md` | `mbok-app-builder` |
| Sankofa 📊 | `curator` | `~/.hermes/profiles/curator/SOUL.md` | `sankofa-data-curator` |

### Estado del Proyecto (vivos)

| Archivo | Propósito |
|---------|-----------|
| `repo/STATUS.md` | Estado general del proyecto |
| `full-review/STATUS.md` | Estado detallado por componente |
| `full-review/ROADMAP.md` | Hitos, milestones, dependencias |

### Recursos Externos

| Recurso | URL |
|---------|-----|
| GitHub Repo | `git@github.com:qidia-io/global-speak.git` |
| ByT5 Wolof | https://huggingface.co/sainzpaa/SPANISH-WOLOF-BYT5 |
| Whisper Wolof | https://huggingface.co/sainzpaa/whisper-small-wolof-v1 |
| ByT5 NMT Wolof | https://huggingface.co/sainzpaa/byt5-nmt-wolof-v1 |
| NLLB-200 600M | https://huggingface.co/facebook/nllb-200-distilled-600M |
| Whisper Large V3 | https://huggingface.co/openai/whisper-large-v3 |
| MMS-TTS | https://huggingface.co/facebook/mms-tts |
| HF Inference API | https://api-inference.huggingface.co/ |

---

> **Documento creado:** 2026-07-08  
> **Autor:** Nemrod — System Architect (Hermes Agent)  
> **Versión:** 2.0 — Migración a multi-agente, Model Router, Quality Gates reales, Glossary Integration  
> **Próxima revisión:** Al completar Milestone 2 (Evaluación) o al añadir una nueva lengua
