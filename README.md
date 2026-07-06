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

📊 **[Ver STATUS.md →](STATUS.md)** — trazabilidad completa de lo completado, en progreso y pendiente.

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

---

## Licencia

MIT
