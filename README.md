# 🌍 Global Speak

> Sistema de traducción multilingüe **SST → NMT → TTS**
> para lenguas con pocos recursos (*low-resource languages*)

| | |
|---|---|
| **Piloto** | Español ↔ Wolof (migrantes senegaleses) |
| **App** | React 18 + TypeScript + Capacitor (Android/iOS/Web) |
| **Modelos** | ByT5-large fine-tuned, NLLB-200 distilled 600M |
| **SST** | Whisper Large V3 |
| **TTS** | MMS-TTS (1100+ idiomas) |

---

## Pipeline

```
🎤 Audio (voz) ──→ Whisper ──→ texto fuente ──→ NMT (ByT5 / NLLB-200) ──→ texto traducido ──→ MMS-TTS ──→ 🔊 Audio sintetizado
```

---

## Estado del Proyecto

| Documento | Qué contiene |
|---|---|
| 🎯 **[PROJECT_CONTROL.md](PROJECT_CONTROL.md)** | **Documento maestro** — visión 360°, cronología, fases, equipo, decisiones, infraestructura, pendientes |
| 📊 **[STATUS.md](STATUS.md)** | Estado actual verificado — completado, en progreso, backlog |
| 🗺️ **[ROADMAP.md](ROADMAP.md)** | Milestones técnicos con dependencias |
| 🗓️ **[GANTT.md](GANTT.md)** | Diagrama temporal por fases (Mermaid) |

**Seguimiento externo:** [GitHub Issues](https://github.com/qidia-io/global-speak/issues) (tablero operativo, 21 tareas etiquetadas) · [Notion](https://app.notion.com/p/Nemrod-global-speak-3cda97bd797c80ccb06ce6b3ade351e6) (cuartel general: BD Tareas + ROADMAP + DECISION LOG) · Bruce (`@tio_bruce_bot`)

---

## Quick Start

```bash
# Clonar
git clone git@github.com:qidia-io/global-speak.git
cd global-speak

# App frontend
cd app
npm install
cp .env.example .env   # Poner HF_TOKEN=
npm run dev            # http://localhost:5173

# Compilar para Android
npx cap add android
npx cap sync
npx cap run android
```

---

## Estructura

```
global-speak/
├── app/                 # Frontend React + Capacitor
│   ├── src/
│   │   ├── screens/     # Home, Voice, Text, Settings
│   │   ├── services/    # inferenceClient, audio, storage
│   │   ├── components/  # UI (Layout, RecordButton, LanguageSelector...)
│   │   └── config/      # languages.ts
│   └── ...
├── notebooks/           # Jupyter notebooks (NMT, SST, TTS)
├── docs/                # Documentación completa
├── data/                # Datos + scripts ETL
├── db/                  # SQL schema
└── agents/              # Perfiles de agentes Hermes
```

---

## Modelos

| Modelo | Uso | Tamaño |
|---|---|---|
| `sainzpaa/SPANISH-WOLOF-BYT5` | NMT Español ↔ Wolof (custom fine-tune) | ~1.2 GB |
| `facebook/nllb-200-distilled-600M` | NMT 200 lenguas (fallback) | ~2.4 GB |
| `openai/whisper-large-v3` | Speech-to-Text | ~3 GB |
| `facebook/mms-tts` | Text-to-Speech (1100+ idiomas) | ~1 GB |

## Equipo de Agentes

| Agente | Rol | Especialidad |
|---|---|---|
| **Nemrod** 🧠 | Arquitecto del sistema | Diseño, coordinación, documentación, delegación |
| **Echo** 🎤 | Especialista en voz | SST (Whisper), TTS (MMS-TTS), pipeline SST→NMT→TTS |
| **Janus** 🔄 | Fine-tuning & notebooks | ByT5, NLLB-200, Whisper, limpieza de notebooks |
| **Mbok** 🏗️ | App builder | React + Capacitor, frontend, API, pipeline.py |
| **Sankofa** 📊 | Data curator | Quality gates, ETL, dedup, glossary, limpieza real |

---

## Licencia

MIT
