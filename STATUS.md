# 📊 STATUS — Global Speak Project

> Sistema multilingüe SST→NMT→TTS para migrantes senegaleses
> **Última actualización:** 26 agosto 2026
> **Servidor:** Triniti (46.224.226.201)

---

## ✅ Completado

| Componente | Estado | Detalle |
|---|---|---|
| **App React + Capacitor** | ✅ | Código completo en `app/` — 4 screens, servicios, componentes shadcn/ui |
| **Inference Client** | ✅ | Mock mode + HF API real. SST (Whisper), NMT (NLLB-200 + ByT5), TTS (MMS-TTS) |
| **Servicio de audio** | ✅ | Grabación, reproducción, visualización con Web Audio API |
| **Historial local** | ✅ | `storage.ts` — historial persistente con localStorage |
| **DB schema + ETL** | ✅ | `db/schema.sql`, scripts en `data/scripts/` (etl_raw_to_db.py, generate_sql.py) |
| **SST Wolof (HuBERT-CTC)** | ✅ | `Wolof-HuBERT-CTC` integrado — 2.9s CPU, WER 35.65% (reemplaza Whisper legacy) |
| **NMT ES↔WO (ByT5)** | ✅ | `sainzpaa/SPANISH-WOLOF-BYT5` y `byt5-nmt-wolof-v1` en HF, en producción |
| **Glossary WO→EN** | ✅ | 5,021 entradas Peace Corps, fuzzy match integrado |
| **TTS Español** | ✅ | `facebook/mms-tts-spa` en producción |
| **Audios raw (3GB)** | ✅ | 33,896 WAVs de Common Voice y otras fuentes en servidor |
| **Docs arquitectura** | ✅ | `docs/ARCHITECTURE_SYSTEM.md`, `SPEECH_LLM_ARCHITECTURE.md`, `DATA_COLLECTION_PLAN.md` |
| **Notebooks fine-tuning** | ✅ | `sst_finetune_whisper.ipynb`, `tts_finetune.ipynb`, `finetuning-strategy.md` |
| **Equipo multiagente** | ✅ | Nemrod + Echo + Janus + Mbok + Sankofa (AGENTS.md, agents/*.md) |

## 🔄 En Progreso

| Componente | Estado | Detalle |
|---|---|---|
| **Refinar notebooks ML** | ⚡ | NMT/SST/TTS — limpiar TF/PyTorch mezclado, paths Colab, código duplicado |
| **Pipeline Python standalone** | ❌ | `pipeline.py` SST→NMT→TTS sin app React (para API backend) |
| **ByT5 en inferenceClient** | ⚡ | Falta selector de modelo (ByT5 es↔wo, NLLB resto) |

## 📋 Backlog de Issues (Priorizado)

### 🔴 Alta Prioridad

| # | Tarea | Notas |
|---|---|---|
| 1 | **Limpiar notebooks NMT/SST/TTS** | Mantener solo versiones PyTorch; eliminar TF, Colab paths, duplicados (`NMT_lo_conseguí (2).ipynb`, `SST_lo_conseguí (1).ipynb`, `TTS.ipynb`) |
| 2 | **Integrar ByT5 en inferenceClient.ts** | Selector de modelo: ByT5 para es↔wo, NLLB-200 para el resto |
| 3 | **Pipeline Python standalone** | `pipeline.py` para testing en servidor y futura API backend |
| 4 | **Integrar `galsenai/wolof_tts`** | TTS wolof pendiente — identificar y cablear en Model Router |

### 🟡 Media Prioridad

| # | Tarea | Notas |
|---|---|---|
| 5 | **Evaluación formal ByT5** | BLEU, chrF, COMET sobre `sainzpaa/SPANISH-WOLOF-BYT5` con test set limpio |
| 6 | **Fase 1 datos BM/FF** | Descargar NLLB-Seed, Maliba (892K), FrancophonIA, Wikipedia dumps, dialectos Fula |
| 7 | **FLORES-200** | Descargar para evaluación multilingüe |
| 8 | **Cache de inferencia** | SQLite/JSON para traducciones repetidas — reducir latencia y coste API |
| 9 | **Tests unitarios** | `app/src/test/` vacío — tests para inferenceClient, storage, audio |

### 🟢 Baja Prioridad

| # | Tarea | Notas |
|---|---|---|
| 10 | **CI/CD GitHub Actions** | Build automático, linting, type-check; opcional deploy Pages |
| 11 | **Despliegue móvil** | APK Capacitor → Play Store / App Store |
| 12 | **Backend API server** | FastAPI para traducción, desacoplar inferencia del frontend |
| 13 | **Pipeline offline móvil** | ONNX/TFLite para sin-conexión |

## Estado por Componente

### SST (Speech-to-Text)

| Lengua | Modelo | WER | Latencia | Estado |
|---|---|---|---|---|
| **WO** | `Wolof-HuBERT-CTC` (Soynade) | 35.65% | 2.9s CPU | ✅ Integrado |
| WO (legacy) | `whisper-small-wolof-v1` (propio) | — | ~60s | 🔄 Legacy |
| BM | — | — | — | ⏳ Fase 1 recolección |
| FF | — | — | — | ⏳ Fase 1 recolección |
| SRR/DYO/SNK | — | — | — | ❌ Sin datos |

### NMT (Machine Translation)

| Par | Modelo | Métrica | Estado |
|---|---|---|---|
| ES↔WO | ByT5-small (propio) | Pendiente BLEU/chrF | ✅ En producción |
| EN↔WO | NLLB-200-distilled-600M | — | ✅ Fallback |
| FR↔WO | NLLB-200-distilled-600M | — | ✅ Fallback |
| ES/EN/FR↔BM | NLLB-200 (`bam_Latn`) | — | ⏳ Datos en recolección |
| ES/EN/FR↔FF | NLLB-200 (`ful_Latn`) | — | ⏳ Datos en recolección |
| SRR/DYO/SNK | — | — | ❌ Sin cobertura NLLB |

### TTS (Text-to-Speech)

| Lengua | Modelo | Estado |
|---|---|---|
| ES | `facebook/mms-tts-spa` | ✅ En producción |
| WO | `galsenai/wolof_tts` (identificado) | ⏳ Pendiente integración |
| BM | — | ⏳ Pendiente |
| FF | — | ⏳ Pendiente |

## Infraestructura

| Recurso | Detalle |
|---|---|
| Servidor | Triniti, CPU-only (46.224.226.201) |
| Disco raíz | 75GB (9GB libres) |
| **Volumen datos** | **/mnt/HC_Volume_106255499 — 50GB (32GB libres)** |
| HF cache | Redirigido al volumen |
| GPU | ❌ No — fine-tuning via RunPod/Colab |
| Servicios activos | PostgreSQL :5432, Ollama :11434, Dashboard Hermes :9119 |

## Pipeline de Trabajo por Lengua

```
1. Recolectar datos (Sankofa) → 2. Limpiar + ETL (Sankofa)
→ 3. Fine-tune (Janus, GPU opcional)
→ 4. Integrar en Model Router (Mbok)
→ 5. Probar E2E (Echo)
```

### WO (Wolof) — ✅ Pipeline completo
- SST: HuBERT-CTC integrado · NMT: ByT5 en producción · TTS: pendiente galsenai/wolof_tts

### BM (Bambara) — 🔄 Fase 1 activa
- Datos: 892K Maliba, 186K MT, 77K FR-BM → descargar NLLB-Seed + FrancophonIA + Maliba

### FF (Fula) — 🔄 Fase 1 activa
- Datos: 88K dialectos Kppwdfgu1, 81K NancyT, 20K Wikipedia → descargar + dump

### SRR/DYO/SNK — ⏳ Fase 3
- Estrategia: backtranslation + colaboración UCAD + grabaciones campo

## 📁 Estructura del Repositorio

```
global-speak/
├── app/                    # Frontend React + Capacitor (TypeScript)
├── notebooks/              # Jupyter notebooks (NMT, SST, TTS)
├── docs/                   # Documentación completa
├── data/                   # Datos crudos + procesados + scripts ETL
├── db/                     # SQL schema
├── agents/                 # Perfiles de agentes Hermes
├── AGENTS.md               # Identidad y reglas del equipo
├── STATUS.md               ← ESTE ARCHIVO (tracking vivo)
├── ROADMAP.md              # Milestones con dependencias
└── README.md
```

## 🔗 Recursos

| Recurso | URL |
|---|---|
| GitHub Repo | `git@github.com:qidia-io/global-speak.git` |
| ByT5 Wolof | https://huggingface.co/sainzpaa/SPANISH-WOLOF-BYT5 |
| Whisper Wolof | https://huggingface.co/sainzpaa/whisper-small-wolof-v1 |
| ByT5 NMT Wolof | https://huggingface.co/sainzpaa/byt5-nmt-wolof-v1 |
| HF Inference API | https://api-inference.huggingface.co/ |
| Kanban | `hermes kanban` — board `global-speak` |

---

*Este archivo se actualiza con cada sesión de trabajo.*
