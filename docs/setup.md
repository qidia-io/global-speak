# Setup y Despliegue

## Entorno Local

### Prerrequisitos

```bash
# Node.js 18+
node --version

# npm o bun
npm --version

# Para iOS: macOS con Xcode
# Para Android: Android Studio
```

### Instalación de la App

```bash
git clone git@github.com:qidia-io/global-speak.git
cd global-speak

# Instalar dependencias
npm install

# Configurar token HuggingFace
cp .env.example .env
# Editar .env con HF_TOKEN=hf_xxxxxxxxxxxxx

# Desarrollo web
npm run dev
```

### Compilación Móvil

```bash
# Build web
npm run build

# Android
npx cap add android
npx cap sync
npx cap run android

# iOS (solo macOS)
npx cap add ios
npx cap sync
npx cap run ios
```

## Despliegue en Servidor (Hermes Agent)

### Servidor Actual

| Recurso | Valor |
|---|---|
| IP | `46.224.226.201` |
| Puerto SSH | `22` |
| Usuario | `root` |
| Sistema | Linux (7.0.0-15-generic) |
| Directorio proyecto | `/root/proyecto/` |

### Conectarse

```bash
ssh root@46.224.226.201
```

### Subir Archivos (SCP)

```bash
# Desde Windows PowerShell
scp archivo.zip root@46.224.226.201:/root/proyecto/

# Desde Linux/Mac
scp archivo.zip root@46.224.226.201:/root/proyecto/
```

### Perfiles de Agentes (Hermes)

```bash
# Listar perfiles
hermes profile list

# Cambiar a un perfil específico
polyglot chat    # Experto en modelos NMT
forge chat       # Desarrollador de la app
echo chat        # Especialista en voz

# Iniciar gateway para Telegram (cuando toque)
echo gateway start
```

## HuggingFace

### Modelos

| Modelo | Repo |
|---|---|
| ByT5 Español-Wolof | `sainzpaa/SPANISH-WOLOF-BYT5` |

### Subir un Modelo

```bash
pip install huggingface_hub
huggingface-cli login
huggingface-cli upload sainzpaa/MI-MODELO /ruta/al/modelo
```

### Inference API

Los modelos se llaman vía REST:

```bash
curl https://api-inference.huggingface.co/models/sainzpaa/SPANISH-WOLOF-BYT5 \
  -H "Authorization: Bearer $HF_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"inputs": "translate Spanish to Wolof: Hola, ¿cómo estás?"}'
```

## Variables de Entorno

| Variable | Propósito | Obligatoria |
|---|---|---|
| `HF_TOKEN` | Token HuggingFace Inference API | Sí |
| `GITHUB_TOKEN` | Token GitHub (API) | Opcional |
