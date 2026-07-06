# Arquitectura del Sistema

## Visión General

Global Speak conecta tres grandes componentes:

1. **App Móvil/Web** — Frontend React + Capacitor para Android/iOS
2. **Modelos de IA** — Inferencia vía HuggingFace Inference API
3. **Pipeline de Voz** — Secuencia SST → NMT → TTS

## Diagrama de Alto Nivel

```
┌─────────────────────┐
│     App Móvil       │
│  (React+Capacitor)  │
│                     │
│  ┌───────────────┐  │
│  │ VoiceScreen   │──┼───🎤 Grabación de audio
│  │ TextScreen    │──┼───⌨️ Texto escrito
│  │ SettingsScreen│  │
│  │ HistoryPanel  │  │
│  └───────────────┘  │
└─────────┬───────────┘
          │ HTTPS / REST
          ▼
┌──────────────────────────────────────────┐
│         HuggingFace Inference API        │
│                                          │
│  ┌──────────┐  ┌──────────┐  ┌────────┐ │
│  │ Whisper  │  │ NLLB-200 │  │ MMS-TTS│ │
│  │ Large V3 │  │ 600M     │  │        │ │
│  │ (SST)    │  │ (NMT)    │  │ (TTS)  │ │
│  └──────────┘  └──────────┘  └────────┘ │
│                                          │
│  ┌──────────────────────────────────┐    │
│  │ ByT5-large (custom fine-tuned)  │    │
│  │ Español ↔ Wolof                  │    │
│  └──────────────────────────────────┘    │
└──────────────────────────────────────────┘
```

## Flujo de Datos — Modo Voz

```
🎤 Usuario habla
    │
    ▼
Grabación WAV/MP3 (micrófono del dispositivo)
    │
    ▼
POST a Whisper Large V3 (speech-to-text)
    │
    ▼
Texto fuente (ej: "¿Cómo llegar a la oficina de extranjería?")
    │
    ▼
POST a NMT (ByT5 / NLLB-200) con idioma fuente + destino
    │
    ▼
Texto traducido (ej: "Nam na dem sil sa biro dëkkandoo?")
    │
    ▼
POST a MMS-TTS (text-to-speech)
    │
    ▼
🔊 Audio de vuelta (Wolof hablado)
```

## Flujo de Datos — Modo Texto

```
⌨️ Usuario escribe texto
    │
    ▼
POST a NMT (ByT5 / NLLB-200)
    │
    ▼
Texto traducido mostrado en pantalla
    │
    ▼
(Opcional) POST a MMS-TTS para escuchar
```

## Modelo de Datos

```typescript
interface TranslationEntry {
  id: string;
  sourceLanguage: string;
  targetLanguage: string;
  sourceText: string;
  translatedText: string;
  mode: 'voice' | 'text';
  timestamp: Date;
  audioUrl?: string;        // URL del audio fuente
  translatedAudioUrl?: string; // URL del audio traducido
}

interface Language {
  code: string;              // "wo", "es", "fr", "en"
  name: string;              // "Wolof", "Español"
  nativeName: string;        // "Wolof", "Español"
  rtl: boolean;              // true para árabe, etc.
  flag: string;              // Emoji bandera
}
```

## Stack Tecnológico

### Frontend (global-speak)
| Tecnología | Versión | Uso |
|---|---|---|
| React | 18.3+ | UI framework |
| TypeScript | 5.x | Tipado estático |
| Vite | 5.x | Build system |
| Capacitor | 8.x | Wrapper nativo Android/iOS |
| shadcn/ui | - | Componentes UI |
| Radix UI | - | Componentes accesibles |
| Tailwind CSS | - | Estilos |
| Framer Motion | 12.x | Animaciones |
| TanStack Query | 5.x | Estado y caché |

### Backend / Modelos
| Modelo | Tamaño | Proveedor |
|---|---|---|
| Whisper Large V3 | ~3GB | OpenAI / HF |
| NLLB-200 distilled 600M | ~2.4GB | Facebook |
| ByT5-large (custom) | ~1.2GB | Google / Fine-tuned |
| MMS-TTS | ~1GB | Facebook |

### Infraestructura Actual
| Recurso | Detalle |
|---|---|
| Servidor | Hermes Agent (Linux, 46.224.226.201) |
| Modelo actual | deepseek/deepseek-v4-flash |
| Almacenamiento | HuggingFace Hub |
| Código fuente | GitHub (qidia-io/global-speak) |
