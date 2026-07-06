# App Global Speak

Aplicación híbrida **React + Capacitor** para Android, iOS y web.

## Stack

| Tecnología | Propósito |
|---|---|
| React 18 + TypeScript | UI framework |
| Vite | Dev server y build |
| Capacitor 8 | Wrapper nativo (Android/iOS) |
| shadcn/ui + Radix UI | Sistema de componentes |
| Tailwind CSS | Estilos utilitarios |
| Framer Motion | Animaciones |
| TanStack Query | Caché y estado asíncrono |
| React Router | Navegación |

## Estructura del Código Fuente

```
global-speak/
├── src/
│   ├── components/        # Componentes reutilizables
│   │   ├── FeatureBlock.tsx
│   │   ├── HeroBanner.tsx
│   │   ├── HistoryPanel.tsx
│   │   ├── LanguageSelector.tsx
│   │   ├── Layout.tsx
│   │   ├── ModeCard.tsx
│   │   ├── NavLink.tsx
│   │   ├── RecordButton.tsx
│   │   └── VoiceTile.tsx
│   │   └── ui/            # shadcn/ui components
│   ├── config/
│   │   └── languages.ts   # Definición de lenguas con RTL
│   ├── screens/
│   │   ├── HomeScreen.tsx
│   │   ├── VoiceScreen.tsx
│   │   ├── TextScreen.tsx
│   │   └── SettingsScreen.tsx
│   ├── services/
│   │   ├── audio.ts       # Grabación y reproducción
│   │   ├── inferenceClient.ts  # API HuggingFace
│   │   └── storage.ts     # Historial local (IndexedDB/LocalStorage)
│   ├── App.tsx
│   └── App.css
├── public/
├── capacitor.config.ts
├── package.json
├── vite.config.ts
└── index.html
```

## Pantallas

### HomeScreen
Pantalla principal con dos modos y hero banner.

### VoiceScreen
- Grabación de voz con botón pulsar-para-hablar
- Visualización de onda de sonido
- Transcripción en tiempo real
- Traducción y reproducción TTS

### TextScreen
- Área de texto con soporte RTL
- Selector de idioma origen/destino
- Botón de traducción
- Opción de escuchar traducción

### SettingsScreen
- Configuración de token HuggingFace
- Selección de idioma por defecto
- Gestión de caché

## Servicios

### inferenceClient.ts
Comunicación con HuggingFace Inference API:
- `transcribeAudio(audioBlob)` → Whisper SST
- `translateText(text, source, target)` → NLLB-200 o ByT5
- `synthesizeSpeech(text, language)` → MMS-TTS

### audio.ts
Manejo de audio en el dispositivo:
- Grabación vía MediaRecorder API / Capacitor plugin
- Reproducción con Web Audio API
- Conversión de formatos

### storage.ts
Persistencia local:
- Historial de traducciones (IndexedDB)
- Preferencias de usuario (LocalStorage)
- Caché de respuestas

## Compilación

```bash
# Desarrollo web
npm run dev

# Build web
npm run build

# Build Android
npx cap add android
npm run build
npx cap sync
npx cap run android

# Build iOS (solo en Mac)
npx cap add ios
npm run build
npx cap sync
npx cap run ios
```

## Configuración

Crear `.env` a partir de `.env.example` con el token de HuggingFace:

```
HF_TOKEN=hf_xxxxxxxxxxxxxxxxxxxxx
```

Sin token, la app corre en **Mock Mode** con datos de placeholder.
