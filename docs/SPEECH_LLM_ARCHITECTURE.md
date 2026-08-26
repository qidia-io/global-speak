# Global Speak — Arquitectura Multilingüe

> Sistema SST→NMT→TTS para migrantes senegaleses
> Documento de arquitectura — Julio 2026
> Inspirado en: *"Speech Language Models for Under-Represented Languages: Insights from Wolof"* (Sy et al., 2025)

---

## Filosofía del Sistema

Construimos **nuestro propio pipeline** SST→NMT→TTS, modular y extensible a múltiples lenguas. Nos apoyamos en modelos existentes (Soynade, NLLB, Whisper) como **componentes intercambiables**, no como arquitectura monolítica. Cada pieza puede ser reemplazada o fine-tuneada independientemente.

### Principios

1. **Propio, no prestado** — El pipeline es nuestro. Los modelos se eligen por calidad y se reemplazan cuando tenemos algo mejor.
2. **Multilingüe por diseño** — ES/EN/FR como lenguas fuente → WO/BM/FF/SRR/DYO/SNK como destino, con rutas indirectas cuando no hay par directo.
3. **Calidad > cantidad** — Un modelo pequeño con datos limpios supera a uno grande con datos ruidosos (Insight #2 del paper).
4. **Continued pretraining** — mejor que entrenar desde cero o depender solo de multilingual (Insight #1 del paper).
5. **Faseado** — primero lenguas con recursos (WO, BM, FF), luego las críticas (SRR, DYO, SNK).

---

## Arquitectura Actual (v2)

```
Audio Wolof (16kHz)
       │
       ▼
┌──────────────────────────────┐
│  SST: Wolof-HuBERT-CTC       │  ← Reemplaza Whisper-small-wolof-v1
│  94.4M params, 2.9s CPU      │     (era ~60s, ahora 20x más rápido)
│  WER: 35.65%                 │
└──────────┬───────────────────┘
           │ texto wolof
           ▼
┌──────────────────────────────┐
│  NMT: Model Router           │
│  ┌──────────────────────┐   │
│  │ ES→WO: ByT5 v1       │   │
│  │ WO→ES: ByT5 v1       │   │
│  │ EN→WO: NLLB-600M     │   │
│  │ WO→EN: NLLB-600M     │   │
│  │ *→* :  NLLB-600M     │   │  ← Comodín para pares sin modelo
│  └──────────────────────┘   │
│  + Glossary Lookup          │  ← 5,021 entradas Peace Corps
│    (fuzzy match → prompt)   │
└──────────┬───────────────────┘
           │ texto traducido (ES/EN)
           ▼
┌──────────────────────────────┐
│  TTS: MMS-TTS o similar      │
│  Síntesis de voz             │
└──────────────────────────────┘
```

### Componentes

| Capa | Componente | Lenguas | Estado |
|------|-----------|---------|--------|
| **SST** | `Wolof-HuBERT-CTC` (Soynade) | WO | ✅ Producido (2.9s CPU) |
| **SST** | `whisper-small-wolof-v1` (propio) | WO | 🔄 Legacy, reemplazado |
| **SST** | Por determinar | BM, FF | ⏳ Pendiente |
| **NMT** | `ByT5-small` (fine-tuned propio) | ES↔WO | ✅ En producción |
| **NMT** | `NLLB-200-distilled-600M` | WO, BM, FF ↔ ES, EN, FR | ✅ Fallback universal |
| **NMT** | Glossary Lookup | WO→EN (5,021 entradas) | ✅ Integrado |
| **TTS** | `MMS-TTS` | ES | ✅ En producción |
| **TTS** | Por determinar | WO, BM, FF | ⏳ Pendiente |

---

## Arquitectura Objetivo (v3 — Multilingüe)

```
                    ┌─── ES ───┐
                    │   EN     │─── Fuentes
                    │   FR     │
                    └────┬─────┘
                         │
                         ▼
┌───────────────────────────────────┐
│       LANGUAGE ROUTER             │
│  Detecta lengua fuente (ES/EN/FR) │
│  + detecta lengua destino         │
│  + elige ruta de traducción       │
└──────────┬────────────────────────┘
           │
     ┌─────┴──────┬──────────┬──────────┐
     ▼            ▼          ▼          ▼
┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐
│ SST     │ │ SST     │ │ SST     │ │ SST     │
│ WO      │ │ BM      │ │ FF      │ │ SRR/    │
│ HuBERT  │ │ Whisper │ │ Whisper │ │ DYO/SNK │
│ CTC     │ │ fine-   │ │ fine-   │ │ (campo) │
│         │ │ tuned   │ │ tuned   │ │         │
└────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘
     │           │           │           │
     ▼           ▼           ▼           ▼
┌───────────────────────────────────────────┐
│            NMT MODEL ROUTER                │
│                                            │
│  ES→WO  │ EN→WO  │ FR→WO  │ *→WO         │
│  ES→BM  │ EN→BM  │ FR→BM  │ *→BM         │
│  ES→FF  │ EN→FF  │ FR→FF  │ *→FF         │
│  ES→SRR │ EN→SRR │ FR→SRR │ *→SRR        │
│                                            │
│  Reglas de ruteo:                          │
│  1. Si existe modelo directo → usarlo      │
│  2. Si no, FR como puente                 │
│  3. Si no hay FR, EN como puente          │
│  4. Último recurso: NLLB directo          │
│                                            │
│  + Glossary Lookup (multilingüe)           │
└──────────────────┬────────────────────────┘
                   │
                   ▼
┌───────────────────────────────────────────┐
│              TTS ROUTER                    │
│                                            │
│  ES→WO: MMS-TTS (wo) o por determinar      │
│  ES→BM: MMS-TTS (bm) o por determinar      │
│  ES→FF: MMS-TTS (ff) o por determinar      │
│  ES→SRR/DYO/SNK: síntesis genérica        │
└───────────────────────────────────────────┘
```

### Rutas de Traducción (Model Router Lógico)

```
Para cada par (src_lang, tgt_lang):

1. ¿Existe modelo ByT5 fine-tuned propio?
   └── SÍ → usar ByT5 (mejor calidad)
   └── NO → 
2. ¿Existe par directo en NLLB-200?
   └── SÍ → NLLB directo (calidad aceptable)
   └── NO →
3. ¿Podemos rutear vía FR?
   └── SÍ → NLLB src→FR + NLLB FR→tgt
   └── NO →
4. ¿Podemos rutear vía EN?
   └── SÍ → NLLB src→EN + NLLB EN→tgt
   └── NO →
5. Último recurso: backtranslation con modelo generativo
```

**Cobertura de NLLB-200 para lenguas objetivo:**

| Lengua | Código NLLB | ¿Directo? | Puente recomendado |
|--------|-------------|-----------|-------------------|
| Wolof | `wol_Latn` | ✅ Sí | FR o EN |
| Bambara | `bam_Latn` | ✅ Sí | FR o EN |
| Fula | `ful_Latn` | ✅ Sí | FR o EN |
| Serer | ❌ No | — | FR → NLLB no puede, necesita grabaciones |
| Jola | ❌ No | — | FR → NLLB no puede, necesita grabaciones |
| Soninké | ❌ No | — | FR → NLLB no puede, necesita grabaciones |

---

## Estrategia por Lengua

### Wolof (WO) — Prioridad 0
- **SST**: ✅ `Wolof-HuBERT-CTC` (Soynade) — 94.4M, WER 35.65%, 2.9s CPU
- **NMT**: ✅ ByT5 propio ES↔WO + NLLB EN↔WO + Glossary 5K entries
- **TTS**: ⏳ Buscar/Poblar modelo TTS wolof (galsenai/wolof_tts existe en HF)
- **Datos**: ~1.9M pares paralelos, 33k audios ASR, 5K glossary entries
- **Mejora**: Fine-tune ByT5 con datos limpios (Fase 4 del ciclo)

### Bambara (BM) — Prioridad 1
- **SST**: ⏳ Whisper fine-tuned o HuBERT continued pretraining
- **NMT**: ⏳ NLLB `bam_Latn` directo o ByT5 fine-tuned
- **TTS**: ⏳ Por determinar
- **Datos identificados**: 892k corpus Maliba, 186k MT dataset, 77k FR-BM (FrancophonIA)
- **Entrada**: Fase 1 de recolección → luego fine-tuning

### Fula/Pulaar (FF) — Prioridad 2
- **SST**: ⏳ Whisper fine-tuned (Common Voice Adamawa Fulfulde ayuda)
- **NMT**: ⏳ NLLB `ful_Latn` directo o ByT5 fine-tuned
- **TTS**: ⏳ Por determinar
- **Datos identificados**: 8 dialectos Kppwdfgu1, 81k NancyT/FulaData, 20k Wikipedia
- **Entrada**: Fase 1 de recolección → fine-tuning

### Serer/Jola/Soninké (SRR/DYO/SNK) — Prioridad 3
- **SST**: ❌ Sin recursos digitales → grabaciones de campo necesarias
- **NMT**: ❌ Sin cobertura NLLB → backtranslation + revisión humana
- **TTS**: ❌ Sin datos
- **Datos identificados**: ~80 rows SRR, ~18 rows DYO, ~12 rows SNK en HF
- **Estrategia**: Léxicos impresos + colaboración UCAD + grabaciones comunitarias

---

## Pipeline de Recolección de Datos

Ver `/root/proyecto/repo/docs/DATA_COLLECTION_PLAN.md` para el plan detallado.

### Flujo de Ingesta

```
Fuente externa (HF, OPUS, web, Wikipedia)
       │
       ▼
┌──────────────────────────────┐
│  Sankofa (Data Curator)      │
│  ┌────────────────────────┐  │
│  │ 1. Quality Gates       │  │
│  │ 2. Limpieza (ftfy,     │  │
│  │    NFKC, dedup)        │  │
│  │ 3. ETL → train/val/test│  │
│  │ 4. Glossary DB         │  │
│  └────────────────────────┘  │
└──────────┬───────────────────┘
           │ datos limpios
           ▼
┌──────────────────────────────┐
│  Janus (Fine-tuning)         │
│  ┌────────────────────────┐  │
│  │ 1. Continued pretrain  │  │  ← Clave: Insight #1 del paper
│  │    HuBERT-Base         │  │
│  │ 2. Fine-tune ByT5      │  │
│  │ 3. Evaluar (BLEU/chrF) │  │
│  │ 4. Subir a HF          │  │
│  └────────────────────────┘  │
└──────────┬───────────────────┘
           │ modelo nuevo
           ▼
┌──────────────────────────────┐
│  Mbok (App + Pipeline)       │
│  ┌────────────────────────┐  │
│  │ 1. Model Router: +1    │  │  ← 2 líneas en modelRouter.ts
│  │    línea nueva lengua  │  │
│  │ 2. Probar E2E          │  │
│  │ 3. Compilar/Deploy     │  │
│  └────────────────────────┘  │
└──────────────────────────────┘
```

---

## Glosario de Archivos Clave

| Artefacto | Ruta | Propósito |
|-----------|------|-----------|
| Pipeline principal | `/root/proyecto/full-review/pipeline/pipeline.py` | SST→NMT→TTS standalone |
| Model Router | `src/config/modelRouter.ts` (app) / `pipeline.py` (CLI) | Ruteo config-driven |
| Glossary Lookup | `/root/proyecto/full-review/pipeline/glossary_lookup.py` | Fuzzy match + prompt |
| Glossary DB | `/root/proyecto/full-review/data/glossary/glossary.db` | 5,021 entradas WO→EN |
| Plan recolección | `docs/DATA_COLLECTION_PLAN.md` | Fases y fuentes |
| Esta arquitectura | `docs/SPEECH_LLM_ARCHITECTURE.md` | Documento actual |
| STATUS | `STATUS.md` | Estado del proyecto |
| Kanban | `hermes kanban boards switch global-speak` | Tablero activo |

---

## Decisiones Técnicas Clave

### 1. ¿Por qué continued pretraining y no entrenar desde cero?

El paper (Insight #1) demuestra que continuar el pretraining de HuBERT-base (960h LibriSpeech) con 860h de wolof específico supera a entrenar desde cero con 65,000h multilingüe. Razón: el modelo ya aprendió representaciones generales del habla; solo necesita adaptarse a la nueva lengua. Requiere 33 épocas vs cientos desde cero.

**Para nuestras lenguas:** Usar `Wolof-HuBERT-Base` como punto de partida para BM y FF, no empezar desde cero.

### 2. ¿Por qué pipeline secuencial y no Speech LLM end-to-end?

El Speech LLM del paper (HuBERT + Qwen2.5 3B) es prometedor pero:
- Requiere GPU (3B params no corre en CPU)
- El fine-tuning es más complejo
- No tenemos un LLM para cada lengua destino
- El pipeline modular permite intercambiar componentes independientemente

**Evolución natural:** Una vez que tengamos modelos sólidos para varias lenguas, podemos explorar la fusión Speech LLM como v2.

### 3. ¿Por qué FR como puente?

El paper usa EN como puente para knowledge transfer. Nosotros priorizamos FR porque:
- Senegal es francófono — la mayoría de recursos gubernamentales y médicos están en FR
- Los migrantes senegaleses a menudo tienen exposición al FR
- Hay más recursos FR↔WO/BM/FF que ES↔WO/BM/FF
- ES se usará como fuente para la app (migrantes en España/Argentina)

### 4. Calidad de datos > cantidad de datos

El paper (Insight #2) muestra que entrenar con 860h de wolof específico de alta calidad supera a 65,000h multilingüe. Nuestro pipeline de limpieza (ftfy, NFKC, dedup, quality gates) retiene ~95% de los datos con reparación de ~7M caracteres corruptos — validado en la sesión del 7 julio 2026.

---

## Referencias

- Sy et al., 2025 — *"Speech Language Models for Under-Represented Languages: Insights from Wolof"* — arXiv:2509.15362
- Hsu et al., 2021 — *"HuBERT: Self-Supervised Speech Representation Learning by Masked Prediction of Hidden Units"*
- NLLB Team, 2022 — *"No Language Left Behind: Scaling Human-Centered Machine Translation"*
- Gauthier et al., 2016 — *"Collecting Resources in Sub-Saharan African Languages for ASR: A Case Study of Wolof"*
