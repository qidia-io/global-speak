# 📊 STATUS — Global Speak Project

> **Última actualización:** 2026-07-06
> **Sesión:** Hermes Agent (deepseek-v4-flash)
> **Servidor:** Linux, 46.224.226.201 — `/root/proyecto/`

---

## ✅ Completado

| Componente | Estado | Detalle |
|---|---|---|
| **Docs arquitectura** | ✅ | `docs/architecture.md`, `docs/models.md`, `docs/pipeline.md` |
| **Docs setup** | ✅ | `docs/setup.md`, `docs/languages.md`, `docs/app.md` |
| **App React + Capacitor** | ✅ | Código completo en `app/` — 4 screens, servicios, componentes shadcn/ui |
| **Inference Client** | ✅ | Mock mode + HF API real. Soporta SST (Whisper), NMT (NLLB-200), TTS (MMS-TTS) |
| **Servicio de audio** | ✅ | Grabación, reproducción, visualización con Web Audio API |
| **Historial local** | ✅ | `storage.ts` — historial persistente con localStorage |
| **DB schema** | ✅ | `db/schema.sql`, scripts ETL en `data/scripts/` |
| **Modelo ByT5 en HF** | ✅ | `sainzpaa/SPANISH-WOLOF-BYT5` subido y verificado |
| **Audios raw (3GB)** | ✅ | 33,896 WAVs de Common Voice y otras fuentes en servidor |
| **GitHub SSH** | ✅ | `git@github.com:qidia-io/global-speak.git` |

---

## 🔄 En Progreso

| Componente | Estado | Detalle |
|---|---|---|
| **Refinar NMT notebook** | ⚡ En revisión | `NMT_NLLB200_+_ByT5.ipynb` (PyTorch) está decente pero hay que limpiar la versión TF (`NMT_lo_conseguí.ipynb` — 120 celdas caóticas) |
| **Refinar SST notebook** | ❌ Pendiente | `SST_lo_conseguí (1).ipynb` — mezcla TF/PyTorch, Colab paths, código duplicado |
| **Refinar TTS notebook** | ❌ Pendiente | `TTS.ipynb` — Coqui TTS + TF, necesita simplificarse a HF API |
| **Pipeline Python standalone** | ❌ Pendiente | Script `pipeline.py` para SST→NMT→TTS sin depender de la app React |

---

## 📋 Trabajo Pendiente (Issues)

### 🔴 Alta Prioridad

#### 1. Refinar y limpiar notebooks
- **NMT**: Mantener solo `NMT_NLLB200_+_ByT5.ipynb` (PyTorch, 38 celdas). Mover/eliminar `NMT_lo_conseguí.ipynb` (120 celdas, TF + PyTorch mezclados, rutas Windows)
- **SST**: Reescribir desde cero con Whisper + PyTorch. Quitar todo el código TF y Colab-specific
- **TTS**: Simplificar — usar HF Inference API (MMS-TTS) en lugar de Coqui TTS

#### 2. ByT5 integration en inferenceClient.ts
- El `inferenceClient.ts` actual solo usa NLLB-200 para NMT
- Falta: selector de modelo (ByT5 para es↔wo, NLLB para el resto)
- Referencia: `docs/pipeline.md` tiene el pseudocódigo

#### 3. Pipeline Python standalone (`pipeline.py`)
- Script independiente que haga SST → NMT → TTS sin app React
- Útil para testing en servidor y para futura API backend

### 🟡 Media Prioridad

#### 4. Evaluación del modelo ByT5
- Pendiente: BLEU, chrF, COMET sobre `sainzpaa/SPANISH-WOLOF-BYT5`
- Script de evaluación en notebook o script Python

#### 5. Cache de inferencia
- Añadir caché local (SQLite o JSON) para traducciones repetidas
- Reducir latencia y consumo de API

#### 6. Soporte multi-lengua completo
- Actualmente configurado para es↔wo como piloto
- Expandir: fr↔wo, es↔sw, más lenguas

### 🟢 Baja Prioridad

#### 7. Tests unitarios
- `app/src/test/` existe pero vacío (`example.test.ts`)
- Tests para inferenceClient, storage, audio services

#### 8. CI/CD GitHub Actions
- Build automático de la app
- Linting, type-checking
- (Opcional) Deploy a GitHub Pages

#### 9. Despliegue móvil
- Compilar APK con Capacitor
- Publicar en Play Store / App Store

#### 10. Backend API server
- Servidor Python/FastAPI para traducción
- Desacoplar la lógica de inferencia de la app frontend

---

## 📁 Estructura del Repositorio

```
global-speak/
├── app/                    # Frontend React + Capacitor (TypeScript)
│   ├── src/
│   │   ├── components/     # UI components + shadcn/ui
│   │   ├── screens/        # Home, Voice, Text, Settings
│   │   ├── services/       # inferenceClient, audio, storage
│   │   ├── config/         # languages config
│   │   ├── hooks/          # Custom hooks
│   │   └── lib/            # Utilities
│   └── ...
├── docs/                   # Documentación del sistema
│   ├── architecture.md
│   ├── models.md
│   ├── pipeline.md
│   ├── app.md
│   ├── languages.md
│   ├── setup.md
│   └── data-organization.md
├── notebooks/              # Jupyter notebooks de entrenamiento
│   ├── NMT_NLLB200_+_ByT5.ipynb
│   ├── NMT_lo_conseguí.ipynb    ← REQUIERE LIMPIEZA
│   ├── NMT_lo_conseguí (2).ipynb ← DUPLICADO
│   ├── SST_lo_conseguí (1).ipynb ← REQUIERE LIMPIEZA
│   └── TTS.ipynb                ← REQUIERE LIMPIEZA
├── data/                   # Datos crudos + procesados + scripts ETL
│   ├── raw/
│   ├── processed/
│   ├── database/
│   └── scripts/
├── db/                     # Database schema
│   └── schema.sql
├── agents/                 # Perfiles de agentes Hermes
│   └── echo.md
├── STATUS.md               ← ESTE ARCHIVO (tracking vivo)
└── README.md
```

---

## 🔗 Recursos

| Recurso | URL |
|---|---|
| GitHub Repo | `git@github.com:qidia-io/global-speak.git` |
| ByT5 Wolof | https://huggingface.co/sainzpaa/SPANISH-WOLOF-BYT5 |
| HF Inference API | https://api-inference.huggingface.co/ |
| Modelos HF | Whisper Large V3, NLLB-200 distilled 600M, MMS-TTS |

---

*Este archivo se actualiza con cada sesión de trabajo para mantener trazabilidad.*
