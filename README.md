# Global Speak 🌍

> Sistema de traducción multilingüe **SST → NMT → TTS**
> para lenguas con pocos recursos (*low-resource languages*)

| | |
|---|---|
| **Piloto** | Español ↔ Wolof (migrantes senegaleses) |
| **App** | React + TypeScript + Capacitor (Android/iOS) |
| **Modelos** | ByT5-large (fine-tuned), NLLB-200 distilled 600M |
| **SST** | Whisper Large V3 |
| **TTS** | MMS-TTS |

## Pipeline

```
🎤 Audio (voz) ──→ Whisper ──→ texto fuente ──→ NMT (ByT5/NLLB200) ──→ texto traducido ──→ MMS-TTS ──→ 🔊 Audio (voz)
```

## Repositorio

```
global-speak/
├── docs/               # Documentación del sistema
│   ├── architecture.md  # Arquitectura general
│   ├── models.md        # Modelos de traducción
│   ├── app.md           # App móvil/web
│   ├── pipeline.md      # Pipeline SST→NMT→TTS
│   ├── languages.md     # Lenguas soportadas
│   ├── api.md           # Referencia de API
│   └── setup.md         # Guía de instalación
├── agents/             # Perfiles de agentes del sistema multiagente
│   └── echo.md          # Agente especialista en voz
├── notebooks/          # Notebooks de entrenamiento
├── build/              # Apps compiladas (v1 Flutter, v2 React)
├── models/             # Modelos subidos a HuggingFace
└── README.md
```

## Equipo Multiagente

| Agente | Rol | Especialidad |
|---|---|---|
| **Tú** (orquestador) | Punto central con el usuario | Coordinación general |
| **Echo** | Especialista en voz | SST (Whisper), TTS (MMS-TTS), pipeline de audio |
| *(más pronto)* | | |

## Modelos en HuggingFace

| Modelo | Descripción | Enlace |
|---|---|---|
| `sainzpaa/SPANISH-WOLOF-BYT5` | ByT5-large fine-tuned Español↔Wolof | [HF Hub](https://huggingface.co/sainzpaa/SPANISH-WOLOF-BYT5) |

## Licencia

MIT
