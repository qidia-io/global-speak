# Global Translator

A real-time voice and text translation app built with React + Capacitor for Android and iOS deployment.

## Features

- **Voice Mode**: Speak naturally and get instant translations with speech-to-text and text-to-speech
- **Text Mode**: Type or paste text for translation with RTL support
- **25+ Languages**: Focus on developing countries including Swahili, Hindi, Arabic, Bengali, and more
- **Local History**: Translation history stored locally on your device
- **Privacy First**: No accounts, no personal data stored on servers

## Getting Started

### Prerequisites

- Node.js 18+ 
- npm or bun
- For iOS: Mac with Xcode installed
- For Android: Android Studio installed

### Local Development

1. Clone the repository:
```bash
git clone <your-repo-url>
cd global-translator
```

2. Install dependencies:
```bash
npm install
```

3. Configure environment variables:
```bash
cp .env.example .env
# Edit .env and add your Hugging Face token
```

4. Start the development server:
```bash
npm run dev
```

### Setting Up Hugging Face Token

1. Go to [Hugging Face Settings](https://huggingface.co/settings/tokens)
2. Create a new token with "Read" access
3. Add the token to the Settings screen in the app, or configure via environment variables

### Mock Mode

If no HF_TOKEN is configured, the app runs in **Mock Mode**:
- Speech-to-text returns placeholder transcriptions
- Translation returns placeholder text
- Text-to-speech is disabled

This allows you to test the UI and flow without API access.

## Building for Mobile

### Setup Capacitor

After cloning and installing:

```bash
# Add native platforms
npx cap add ios
npx cap add android

# Build the web app
npm run build

# Sync to native projects
npx cap sync
```

### iOS Build

```bash
npx cap run ios
```

Or open in Xcode:
```bash
npx cap open ios
```

### Android Build

```bash
npx cap run android
```

Or open in Android Studio:
```bash
npx cap open android
```

### EAS Build (Expo Application Services)

For production builds, you can use EAS:

1. Install EAS CLI:
```bash
npm install -g eas-cli
```

2. Configure your app in eas.json and build:
```bash
eas build --platform android
eas build --platform ios
```

## Microphone Permissions

The app requires microphone access for voice translation. Permissions are requested when you first try to record.

### iOS (Info.plist)
```xml
<key>NSMicrophoneUsageDescription</key>
<string>Global Translator needs microphone access for voice translation</string>
```

### Android (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

## Project Structure

```
src/
├── components/       # Reusable UI components
│   ├── FeatureBlock.tsx
│   ├── HeroBanner.tsx
│   ├── HistoryPanel.tsx
│   ├── LanguageSelector.tsx
│   ├── Layout.tsx
│   ├── ModeCard.tsx
│   ├── RecordButton.tsx
│   └── VoiceTile.tsx
├── config/
│   └── languages.ts  # Language definitions with RTL support
├── screens/          # App screens
│   ├── HomeScreen.tsx
│   ├── VoiceScreen.tsx
│   ├── TextScreen.tsx
│   └── SettingsScreen.tsx
├── services/
│   ├── audio.ts      # Audio recording and playback
│   ├── inferenceClient.ts  # Hugging Face API integration
│   └── storage.ts    # Local history storage
└── App.tsx
```

## API Models Used

- **Speech-to-Text**: OpenAI Whisper Large v3
- **Translation**: Facebook NLLB-200 (distilled 600M)
- **Text-to-Speech**: Facebook MMS-TTS

## License

MIT
