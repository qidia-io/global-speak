# Organización de Datos — Global Speak

## Estructura de directorios

```
data/
├── raw/                          ← DATOS CRUDOS (tíralos aquí tal cual)
│   ├── wo-es/                    ← Wolof ↔ Español
│   │   ├── audio/                ← Audios .wav / .mp3 (voz en wolof y español)
│   │   └── text/                 ← Pares de traducción (.csv, .tsv, .txt, .json)
│   ├── es-sw/                    ← Español ↔ Suajili (proyecto anterior)
│   │   ├── audio/
│   │   └── text/
│   ├── it-sw/                    ← Italiano ↔ Suajili (proyecto anterior)
│   │   ├── audio/
│   │   └── text/
│   └── fr-wo/                    ← Francés ↔ Wolof (futuro)
│       ├── audio/
│       └── text/
│
├── processed/                    ← DATOS PROCESADOS (limpios, normalizados)
│   ├── train/                    ← Train set (80%)
│   ├── val/                      ← Validation set (10%)
│   └── test/                     ← Test set (10%)
│
├── database/                     ← Scripts SQL + dumps para poblar la BD
│
└── scripts/                      ← Scripts de ETL (Python)
```

## Flujo de trabajo

```
  TU PC                              SERVIDOR (éste)
 ────────                          ─────────────────
  Tus audios/CSVs                  data/raw/wo-es/text/   (subes aquí)
       │                                  │
       │   scp / rsync / subida manual     │
       └───────────────────────────────────┘
                                          │
                                          ▼
                                   scripts/etl_raw_to_db.py
                                          │
                                          ▼
                                   data/processed/train/   (limpio, split)
                                          │
                                          ▼
                                   data/database/populate.sql
                                          │
                                          ▼
                                   PostgreSQL en triniti
```

## Convenciones para los datos

### Archivos de texto (pares de traducción)

Formato recomendado: **CSV** con cabecera:

```csv
source_lang,target_lang,source_text,target_text,source_audio,target_audio,quality
wo,es,Nanga def?,¿Cómo estás?,audio_001_wo.wav,audio_001_es.wav,5
es,wo,Buenos días,Njékk na nga suba,audio_002_es.wav,audio_002_wo.wav,4
```

Campos:
- `source_lang` — código ISO del idioma fuente (wo, es, fr, it, sw)
- `target_lang` — código ISO del idioma destino
- `source_text` — texto en idioma fuente
- `target_text` — texto traducido
- `source_audio` — nombre del archivo de audio (opcional)
- `target_audio` — nombre del archivo de audio traducido (opcional)
- `quality` — puntuación 1-5 (opcional, para filtrar calidad)

### Archivos NLLB (formato legacy)

Si tienes pares en el formato antiguo del proyecto (`.es`, `.sw`, `.scores`):

```
nllb.es-wo.es    → frases en español
nllb.es-wo.wo    → frases en wolof
nllb.es-wo.scores → puntuaciones de calidad
```

Los scripts de ETL aceptan este formato directamente.

### Archivos de audio

- Formato: WAV (preferido) o MP3
- Frecuencia: 16kHz preferido
- Mono
- Nombrar con patrón: `{idioma}_{id}.wav` (ej: `wo_001.wav`, `es_042.wav`)

## Base de datos objetivo (PostgreSQL en triniti)

El schema vive en `db/schema.sql`. Las tablas relevantes para datos:

| Tabla | Contenido |
|-------|-----------|
| `datasets` | Metadatos del dataset (nombre, pares, fuente) |
| `languages` | Catálogo de lenguas con códigos ISO y NLLB |
| `pipeline_logs` | Logs de traducciones reales (texto fuente → traducido) |

## Scripts disponibles

| Script | Función |
|--------|---------|
| `data/scripts/etl_raw_to_db.py` | Lee raw/ → limpia → split → genera SQL |
| `data/database/populate.sql` | SQL generado listo para PostgreSQL |
