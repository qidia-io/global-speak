# global-speak — AGENTS.md

> *"El rey que construyó la torre que dividió las lenguas, ahora construye el sistema que las reconecta"*

---

## Project Identity

**global-speak** es un sistema multilingüe Speech-to-Text → Neural Machine Translation → Text-to-Speech diseñado para migrantes senegaleses y hablantes de lenguas con pocos recursos (*low-resource languages*). El piloto cubre **Español ↔ Wolof**, con plan de expansión a Fula (ff), Bambara (bm), Serer (srr), Jola (dyo) y Soninké (snk).

| Aspecto | Detalle |
|---------|--------|
| **Visión** | Traducción de voz en tiempo real para lenguas sin recursos comerciales |
| **App** | React 18 + TypeScript + Capacitor (Android/iOS/Web) |
| **Inferencia** | HuggingFace Inference API (Whisper → NLLB/ByT5 → MMS-TTS) |
| **Datos** | OPUS, CCAligned, NLLB-mined, Bible corpus, Peace Corps Dictionary |
| **Entrenamiento** | GPU cloud (Colab/RunPod spot), fine-tuning ByT5/Whisper/MMS-TTS |
| **Servidor** | VPS CPU-only (46.224.226.201, 75GB SSD) — sin GPU en producción |

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│  USER: App (React + Capacitor)                                  │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐                   │
│  │ Voice    │    │ Text     │    │ History  │                   │
│  │ Screen   │    │ Screen   │    │ Panel    │                   │
│  └────┬─────┘    └────┬─────┘    └──────────┘                   │
│       │               │                                         │
│       ▼               ▼                                         │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │             inferenceClient.ts (Model Router)             │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌──────────────┐     │   │
│  │  │ SST: Whisper │→ │ NMT: ByT5   │→ │ TTS: MMS-TTS │     │   │
│  │  │ Large V3     │  │ / NLLB-200  │  │ (español)    │     │   │
│  │  └─────────────┘  └─────────────┘  └──────────────┘     │   │
│  └──────────────────────────────────────────────────────────┘   │
│                          │                                       │
│                          ▼                                       │
│              HuggingFace Inference API (Cloud)                    │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  BACKEND: Pipeline de Datos y Entrenamiento                     │
│                                                                 │
│  Data Ingestion → Quality Gates → ETL → Train/Test/Val Splits   │
│                                     ↓                            │
│                    Fine-tuning (GPU Cloud) → HF Hub Checkpoint    │
│                                     ↓                            │
│                    Evaluation (BLEU, chrF, COMET)                │
└─────────────────────────────────────────────────────────────────┘
```

### Inference Pipeline (End-to-End)

```
Audio in (WAV 16kHz mono)  →  Whisper SST   →  Text (source language)
Text (source)              →  ByT5 / NLLB    →  Text (target language)
Text (target)              →  MMS-TTS        →  Audio out
```

### Model Router Strategy (config-driven routing)

```typescript
const MODEL_ROUTES: Record<string, RouteConfig> = {
  'es-wo': { model: 'sainzpaa/byt5-nmt-wolof-v1', type: 'byt5' },
  'wo-es': { model: 'sainzpaa/byt5-nmt-wolof-v1', type: 'byt5' },
  '*':     { model: 'facebook/nllb-200-distilled-600M', type: 'nllb' },
};
```

Nueva lengua = 1-2 líneas en este mapa, sin tocar `translateText()`. El comodín `*` atrapa todo lo no mapeado.

---

## Agent Team

El sistema es construido y mantenido por cuatro agentes especializados, coordinados por Nemrod. Cada agente mapea a un perfil de Hermes Agent.

| Agente | Perfil Hermes | Rol | Directorio del Perfil |
|--------|---------------|-----|----------------------|
| 👑 **Nemrod** | `default` | Arquitecto — diseña, documenta, coordina | `/root/.hermes/` (SOUL.md raíz) |
| 🎤 **Echo** | `translator` | Voz — SST, TTS, pipeline de audio | `/root/.hermes/profiles/translator/` |
| 🔄 **Janus** | `linguist` | Fine-tuning, notebooks, evaluación | `/root/.hermes/profiles/linguist/` |
| 🏗️ **Mbok** | `coder` | App React + Capacitor, API client | `/root/.hermes/profiles/coder/` |
| 📊 **Sankofa** | `curator` | Data curation, quality gates, ETL | `/root/.hermes/profiles/curator/` |

### 👑 Nemrod — System Architect (Orchestrator)

| Campo | Detalle |
|-------|---------|
| **Perfil** | `default` (orquestador) |
| **SOUL** | `/root/.hermes/SOUL.md` |
| **Rol** | Diseño del sistema, coordinación de agentes, documentación técnica, decisiones de arquitectura |
| **Delegación** | Usa `delegate_task` para despachar trabajo a echo/janus/mbok/sankofa |
| **Lo que NO hace** | No codea, no hace fine-tuning, no toca la app, no cura datos |

**Reglas para Nemrod:**
1. Diagnostica antes de delegar — verifica que el perfil del agente existe y tiene el SOUL correcto
2. Tareas independientes → `delegate_task(tasks=[...])` en paralelo (máx. 3 concurrentes)
3. Tareas secuenciales → nunca paralelizar si output de A es input de B
4. Verifica después de delegar — los resúmenes de subagentes son auto-reportes, siempre lee el archivo
5. Actualiza STATUS.md después de cambios significativos

### 🎤 Echo — Voice & Audio Specialist

| Campo | Detalle |
|-------|---------|
| **Perfil Hermes** | `translator` |
| **SOUL** | `/root/.hermes/profiles/translator/SOUL.md` |
| **Skill** | `echo-voice-pipeline` |
| **Dominio** | SST (Whisper Large V3), NMT (NLLB-200 / ByT5), TTS (MMS-TTS), calidad de audio |
| **Responsabilidades** | Validación del pipeline SST→NMT→TTS, evaluación de latencia/WER/MOS, testing con audio real (Wolof, Fula, Bambara), documentación de formatos de audio |
| **Lo que NO hace** | No toca notebooks, no modifica la app |
| **Documentación** | `agents/echo.md` |

**Reglas para Echo:**
1. Siempre valida el idioma en cada paso — Wolof audio → Whisper(wolof) → NLLB(wol_Latn→spa_Latn) → MMS-TTS(spanish)
2. **Pitfall conocido NLLB:** Frases cortas en Wolof (saludos, 1-3 palabras) se traducen incorrectamente. "Nanga def?" → "¿Quién lo hizo?" en lugar de "¿Cómo estás?". Frases de 5+ palabras funcionan mejor.
3. Mide y documenta latencias — CPU tiene latencia significativa (~60s por 3s audio para Whisper-Small)
4. Prueba con audio real, no solo mock mode

### 🔄 Janus — Fine-tuning & Notebook Specialist

| Campo | Detalle |
|-------|---------|
| **Perfil Hermes** | `linguist` |
| **SOUL** | `/root/.hermes/profiles/linguist/SOUL.md` |
| **Skill** | `janus-finetuning` |
| **Dominio** | PyTorch, Transformers, fine-tuning (Whisper/ByT5/MMS-TTS/XTTS-v2), notebooks |
| **Responsabilidades** | Limpieza de notebooks (TF→PyTorch, eliminar paths de Colab), fine-tuning para lenguas low-resource, evaluación (BLEU/chrF/COMET/WER), gestión de HF Hub |
| **Lo que NO hace** | No toca datos crudos, no despliega apps |
| **Documentación** | `agents/janus.md` |

**Reglas para Janus:**
1. **100% PyTorch** — eliminar cualquier código TensorFlow/Keras de los notebooks
2. **Sin artefactos de Colab** — eliminar `drive.mount()`, `/content/`, `google.colab`, formularios de notebook
3. **Documenta cada celda** — encabezados markdown explicando qué hace cada celda
4. **Tamaño objetivo** — notebooks limpios de ~50 KB; eliminar código muerto, outputs excesivos, celdas redundantes
5. **¿GPU necesaria? Pregunta primero** — fine-tuning ByT5-large en CPU toma días por época

### 🏗️ Mbok — App Builder

| Campo | Detalle |
|-------|---------|
| **Perfil Hermes** | `coder` |
| **SOUL** | `/root/.hermes/profiles/coder/SOUL.md` |
| **Skill** | `mbok-app-builder` |
| **Dominio** | React 18, TypeScript, Capacitor 8, Vite, Tailwind CSS 3, shadcn/ui, Radix, Framer Motion, TanStack Query |
| **Responsabilidades** | Pantallas (Home, Voice, Text, Settings, History), integración con HF Inference API, permisos de micrófono, modo offline, compilación APK |
| **Lo que NO hace** | No entrena modelos, no cura datos |
| **Documentación** | `agents/mbok.md` |

**Reglas para Mbok:**
1. **Mock mode es sagrado** — la app debe funcionar sin HF_TOKEN. Cada feature debe tener fallback mock
2. **Patrón Model Router** — nunca hardcodear if/else por par de lenguas. Usar el mapa `MODEL_ROUTES` config-driven
3. **Compila antes de declarar done** — después de cualquier cambio, ejecutar `npm run build` y `npx tsc --noEmit`
4. **Mobile-first** — la app apunta a Android principalmente. Considerar touch targets, rendimiento y offline

### 📊 Sankofa — Data Curator

| Campo | Detalle |
|-------|---------|
| **Perfil Hermes** | `curator` |
| **SOUL** | `/root/.hermes/profiles/curator/SOUL.md` |
| **Skill** | `sankofa-data-curator` |
| **Dominio** | Quality gates (4 gates), ETL, datasets multilingües (OPUS, NLLB, CCAligned), SQL, limpieza de audio/texto, deduplicación, pivot |
| **Responsabilidades** | Curación de datos con quality gates, generación de reportes, mantenimiento de bases de datos, validación cruzada raw↔processed, preparación de datasets HF, integración de glosarios |
| **Lo que NO hace** | No despliega apps, no modifica notebooks |
| **Documentación** | `agents/sankofa.md` |

**Reglas para Sankofa:**
1. **Produce datos, no solo reportes** — los quality gates detectan problemas; el pipeline debe TRANSFORMAR datos activamente. Salida: archivos limpios, no solo logs pass/fail
2. **Before/after es obligatorio** — cada operación de limpieza debe mostrar 10-50 ejemplos de lo que cambió
3. **Verifica duplicados antes de procesar** — comparar contra `data/raw/` y `data/processed/` por nombre de corpus y tamaño de archivo
4. **Wolof no tiene modelo FastText** — la detección heurística es el fallback. Aceptar algunos falsos positivos
5. **Formato OPUS Moses:** Leer archivos `.es`/`.wo` como listas paralelas línea a línea. Ignorar archivos `.xml` de metadatos

---

## Tech Stack

### Frontend (App)
- **React 18** + **TypeScript 5.8**
- **Vite 5** (build system)
- **Tailwind CSS 3** + **shadcn/ui** + **Radix** (componentes)
- **Framer Motion** (animaciones)
- **TanStack Query** (estado + caché)
- **Capacitor 8** (Android/iOS)
- **React Router v6** (routing)
- **Vitest + Testing Library** (tests)
- **Ubicación:** `app/`

### Backend (Inferencia)
- **HuggingFace Inference API** (primaria — inferencia en la nube)
- **Transformers + PyTorch** (fallback local cuando DNS falla)
- **Whisper Large V3** → SST (Wolof: `sainzpaa/whisper-small-wolof-v1`)
- **NLLB-200 distilled 600M** → NMT fallback (200 lenguas)
- **ByT5 fine-tuned** → NMT dedicado (es↔wo)
- **MMS-TTS** → TTS (Español: `facebook/mms-tts-spa`)

### Datos y Entrenamiento
- **Python 3.10+** + PyTorch + Transformers + Datasets (HF)
- **sacrebleu** (BLEU/chrF — CPU-only, no necesita GPU)
- **Weights & Biases** (experiment tracking, opcional)
- **Tesseract** (OCR para diccionarios PDF)
- **OPUS, Tatoeba, NLLB-mined, CCAligned, Bible corpus** (fuentes de datos)
- **PostgreSQL 18** (datos estructurados, schema en `db/schema.sql`)

### Infraestructura
- **VPS**: CPU-only, 75GB SSD, 8GB RAM
- **Entrenamiento GPU**: Google Colab (T4 gratis) / RunPod (RTX 4090 spot ~$0.50/hr) / Vast.ai (~$0.30/hr)
- **HF Inference API**: inferencia en producción

---

## Project Structure

```
global-speak/
├── app/                    # App React + Capacitor (código fuente)
│   ├── src/
│   │   ├── components/     # Componentes reutilizables (RecordButton, VoiceTile, etc.)
│   │   ├── config/         # Config (languages.ts, modelRouter.ts)
│   │   ├── screens/        # Pantallas (Home, Voice, Text, Settings)
│   │   ├── services/       # Servicios (audio.ts, inferenceClient.ts, storage.ts)
│   │   ├── hooks/          # Custom hooks
│   │   ├── lib/            # Utilidades
│   │   ├── pages/          # Páginas adicionales
│   │   └── test/           # Tests
│   ├── package.json
│   ├── capacitor.config.ts
│   ├── vite.config.ts
│   └── tailwind.config.ts
├── agents/                 # Documentación por agente (echo.md, janus.md, mbok.md, sankofa.md, nemrod.md)
├── docs/                   # Documentación del sistema
│   ├── ARCHITECTURE_SYSTEM.md  # Arquitectura completa (937 líneas, 15 secciones)
│   ├── models.md           # Registro de modelos
│   ├── app.md              # Documentación de la app
│   ├── pipeline.md         # Pipeline SST→NMT→TTS
│   ├── languages.md        # Matriz de lenguas soportadas
│   ├── api.md              # Referencia de API
│   └── setup.md            # Guía de instalación
├── notebooks/              # Notebooks de entrenamiento (SST, NMT, TTS)
│   └── _archive/           # Notebooks legacy respaldados
├── db/                     # Esquemas de base de datos
│   └── schema.sql          # PostgreSQL schema (models, languages, translations, glossary)
├── AGENTS.md               # ← ESTE ARCHIVO — contexto del proyecto para agentes IA
├── README.md               # Visión general del proyecto
├── STATUS.md               # Estado actual del proyecto
├── LICENSE                 # MIT
└── .gitignore
```

---

## Workflow Rules

### Para Todos los Agentes

1. **Conoce tu identidad.** Lee tu SOUL.md y perfil antes de actuar. Tu identidad define tu dominio.
2. **Mock mode awareness.** La app tiene modo mock (sin HF_TOKEN = respuestas placeholder). Nunca romper mock mode; probar siempre con y sin él.
3. **Prioridad low-resource.** Cada decisión debe considerar primero Wolof, Fula, Bambara, Serer, Jola, Soninké.
4. **Prueba en CPU.** El servidor de producción no tiene GPU. El código debe correr en CPU a menos que se indique explícitamente.
5. **Sin rutas hardcodeadas.** Sin rutas de Colab, Windows, `/content/` o `/mnt/` sin configurabilidad.
6. **Documenta las decisiones.** Cada cambio significativo debe documentarse (comentarios, docstrings, o archivos markdown).
7. **Async infrastructure.** El directorio `full-review/` (otra copia del código) tiene documentación precedente. Mantener `repo/` como fuente de verdad autoritativa.

### Reglas por Agente (ver sección Agent Team arriba)

Cada agente tiene reglas específicas listadas en su descripción. Leerlas antes de actuar.

---

## Models Status (July 2026)

| Componente | Modelo | Estado | Notas |
|-----------|--------|--------|-------|
| SST (Wolof audio→texto) | `sainzpaa/whisper-small-wolof-v1` | ✅ Funciona | Transcripciones reales correctas, ~60s/3s-audio en CPU |
| NMT (Wolof→Español) | `facebook/nllb-200-distilled-600M` | ⚠️ Calidad pobre | 3/6 frases correctas; saludos cortos fallan |
| NMT (Wolof→Español) | `sainzpaa/byt5-nmt-wolof-v1` | ❌ Corrupto | Entrenado como denoising, no seq2seq; `step=0` con `epoch=7` |
| NMT (Wolof→Español) | `sainzpaa/SPANISH-WOLOF-BYT5` | ✅ Alternativa funcional | Checkpoint alternativo funcional |
| NMT (Inglés→Español) | `facebook/nllb-200-distilled-600M` | ✅ Excelente | Para traducción de diccionario |
| TTS (Español) | `facebook/mms-tts-spa` | ✅ Buena calidad | ~6s por 3s de audio |

### Lenguas Soportadas

| Lengua | Código | Código NLLB-200 | ¿En App? | ¿Modelo Fine-tuned? |
|--------|--------|-----------------|----------|-------------------|
| Wolof | wo | `wol_Latn` | ✅ Sí | ❌ (ByT5 v1 corrupto, usar SPANISH-WOLOF-BYT5) |
| Bambara | bm | `bam_Latn` | ❌ No | ❌ No (alta prioridad) |
| Fula | ff | `ful_Latn` | ❌ No | ❌ No (alta prioridad) |
| Serer | srr | ❌ No en NLLB | ❌ No | ❌ Obligatorio |
| Jola (Fogny) | dyo | ❌ No en NLLB | ❌ No | ❌ Obligatorio |
| Soninké | snk | ❌ No en NLLB | ❌ No | ❌ Obligatorio |
| Español | es | `spa_Latn` | ✅ Sí | ❌ (usar NLLB) |
| Francés | fr | `fra_Latn` | ✅ Sí | ❌ (usar NLLB) |
| Inglés | en | `eng_Latn` | ✅ Sí | ❌ (usar NLLB) |

---

## Hardware Constraints

| Recurso | Detalle |
|---------|---------|
| **Servidor producción** | CPU-only, 75GB SSD, 8GB RAM |
| **Opción GPU** | Colab (T4 15GB gratis) / RunPod (RTX 4090 ~$0.50/hr) / Vast.ai (~$0.30/hr) |
| **Disco extra** | `/mnt/HC_Volume_*` puede estar disponible para descargas grandes de modelos |
| **DNS HF API** | `api-inference.huggingface.co` puede NO resolver en algunos servidores. Fallback: transformers local |
| **Fase 1-2 (limpieza, glossary)** | ✅ CPU suficiente |
| **Fase 3 (BLEU/chrF)** | ✅ CPU suficiente (sacrebleu no requiere GPU) |
| **Fase 3 (COMET)** | ⚠️ GPU recomendada |
| **Fase 4 (Fine-tuning)** | ❌ GPU necesaria (RunPod/Colab) |

---

## Key Files Reference

| Archivo | Ruta (relativa a repo root) | Propósito |
|---------|---------------------------|-----------|
| App source | `app/src/` | Punto de entrada de la app React |
| Inference client | `app/src/services/inferenceClient.ts` | Llamadas HF API, routing de modelos |
| Audio service | `app/src/services/audio.ts` | Grabación, reproducción, permisos de micrófono |
| Language config | `app/src/config/languages.ts` | Lenguas con soporte RTL |
| Model Router | `app/src/config/modelRouter.ts` | Mapa config-driven de rutas de modelos |
| Architecture doc | `docs/ARCHITECTURE_SYSTEM.md` | Arquitectura completa del sistema (937 líneas) |
| Project status | `STATUS.md` | Estado actual del proyecto |
| Agent docs | `agents/` | Documentación por agente (echo, janus, mbok, sankofa, nemrod) |
| DB schema | `db/schema.sql` | Esquema PostgreSQL (models, languages, translations, glossary) |
| Notebooks | `notebooks/` | Notebooks de entrenamiento (SST, NMT, TTS) |

---

## Delegation Protocol

Las tareas son despachadas por Nemrod usando `delegate_task`:

```python
# Tarea única
delegate_task(
    goal="Qué lograr (concreto, medible)",
    context="Background: rutas de archivos, constraints, referencias a skills"
)

# Tareas independientes en paralelo (máx. 3)
delegate_task(
    tasks=[
        {"goal": "...", "context": "..."},
        {"goal": "...", "context": "..."},
    ]
)
```

### Mapa de Delegación

| Tarea | Agente | Perfil destino | Método |
|-------|--------|---------------|--------|
| Probar pipeline SST→NMT→TTS con audio real | Echo | `translator` | `delegate_task` |
| Evaluar WER/MOS de modelo TTS | Echo | `translator` | `delegate_task` |
| Reescribir notebook heredado | Janus | `linguist` | `delegate_task` |
| Fine-tune Whisper/ByT5/TTS para nueva lengua | Janus | `linguist` | `delegate_task` |
| Evaluar modelo (BLEU, chrF, COMET) | Janus | `linguist` | `delegate_task` |
| Cambiar UI de la app o añadir pantalla | Mbok | `coder` | `delegate_task` |
| Integrar nuevo modelo en inferenceClient.ts | Mbok | `coder` | `delegate_task` |
| Compilar APK | Mbok | `coder` | `delegate_task` |
| Ejecutar quality gates sobre dataset | Sankofa | `curator` | `delegate_task` |
| Generar reporte de calidad de datos | Sankofa | `curator` | `delegate_task` |
| Ingesta de diccionario a glossary DB | Sankofa | `curator` | `delegate_task` |

### Pipeline de Nueva Lengua (Secuencial)

```
Sankofa 📊 → Curación de datos + quality gates
Janus 🔄   → Fine-tune ByT5 + evaluar + subir a HF Hub
Mbok 🏗️   → 2 líneas en modelRouter.ts + 1 línea en languages.ts
Echo 🎤    → Probar pipeline end-to-end con audio real
```

Cada paso depende del anterior. Nunca paralelizar.

---

## Data Pipeline Results (Julio 2026)

Resultados reales de la limpieza de datos ejecutada por Sankofa:

| Par | Fuentes | Inicial | Final | Retención | Chars reparados |
|-----|---------|---------|-------|-----------|-----------------|
| es-wo | 3 (MultiCC, bible, XLEnt) | 39.214 | 37.094 | 94.6% | 173.765 |
| en-wo | 2 (CCAligned, NLLB) | 1.548.862 | 1.470.010 | 94.9% | ~5M |
| fr-wo | 1 (NLLB) | 376.455 | 366.837 | 97.4% | ~2M |
| **TOTAL** | **6 fuentes** | **1.964.531** | **1.873.941** | **95.4%** | **7.118.699** |

Glossary DB: **5.021 entradas** wolof→inglés extraídas del Peace Corps Wolof-English Dictionary vía OCR.

---

## Environment

```bash
# App
cd app/
npm install
cp .env.example .env    # Editar con HF_TOKEN
npm run dev             # Servidor de desarrollo
npm run build           # Build de producción
npx tsc --noEmit        # Type check

# Evaluación de modelos
pip install sacrebleu   # BLEU/chrF (CPU-only, sin GPU)
```

---

*Este archivo es la fuente de verdad para el contexto de los agentes IA en el proyecto global-speak. Mantener actualizado cuando cambien perfiles, arquitectura o reglas.*
