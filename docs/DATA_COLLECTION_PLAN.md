# Data Collection Plan — Lenguas Senegalesas

> Plan faseado de recolección de datos para el sistema global-speak
> Julio 2026 — Basado en investigación de fuentes (Sankofa Research)

---

## Resumen de Cobertura por Lengua

| Lengua | Código | Estado | Prioridad | Población (aprox) |
|--------|--------|--------|-----------|-------------------|
| **Wolof** | wo | ✅ Abundante | P0 | ~12M hablantes |
| **Bambara** | bm/bam | ✅ Bueno | P1 | ~15M hablantes |
| **Fula/Pulaar** | ff/ful | ⚠️ Moderado | P2 | ~40M (varios países) |
| **Serer** | srr | ❌ Crítico | P3 | ~1.5M |
| **Jola/Diola** | dyo | ❌ Crítico | P3 | ~500K |
| **Soninké** | snk | ❌ Crítico | P3 | ~2M |

---

## FASE 1: Bajo Esfuerzo — Fuentes ya Curadas (ahora)

Fuentes que ya existen en HuggingFace o como dumps. Solo descargar y procesar.

### 1.1 NLLB-Seed (Meta)

Pares paralelos EN→WO/BM/FF del dataset NLLB-Seed.

```python
from datasets import load_dataset

pares = [
    ("wol_Latn-eng_Latn", "wo-en"),
    ("bam_Latn-eng_Latn", "bm-en"),
    ("ful_Latn-eng_Latn", "ff-en"),
]
for pair, name in pares:
    ds = load_dataset("allenai/nllb", pair, split="train", trust_remote_code=True)
    ds.to_parquet(f"/mnt/HC_Volume_106255499/data/nllb_{name}.parquet")
```

**Estimado:** ~500K-2M pares por lengua
**Espacio:** ~2-5GB por lengua
**Destino:** `/mnt/HC_Volume_106255499/data/nllb/`

### 1.2 FLORES-200 (Evaluación)

Dataset de evaluación estándar NMT para 200 lenguas.

| Lengua | Código FLORES | ¿Disponible? |
|--------|--------------|-------------|
| Wolof | `wol_Latn` | ✅ Sí |
| Bambara | `bam_Latn` | ✅ Sí |
| Fula | `ful_Latn` | ❌ No |

```python
load_dataset("Muennighoff/flores200", "wol_Latn")
load_dataset("Muennighoff/flores200", "bam_Latn")
```

### 1.3 FrancophonIA Datasets (1,095 datasets)

**Organización HF con datasets para lenguas de África Occidental.**

Prioritarios:

| Dataset | Lenguas | Tipo | Prioridad |
|---------|---------|------|-----------|
| `FrancophonIA/Dictionnaire_francais-wolof_et_francais-bambara` | WO, BM | Diccionario | Alta |
| `FrancophonIA/Guide_de_la_conversation_en_quatre_langues_francais-wolof-diola-serer` | WO, DYO, SRR | Guía conversación | **Alta** (útil para SRR/DYO) |
| `FrancophonIA/Wolof_Vocabulary_Body_Organs` | WO | Vocabulario médico | Alta |
| `FrancophonIA/Wolof_Vocabulary_Anatomy_Trunk_Limbs` | WO | Vocabulario médico | Alta |
| `FrancophonIA/Wolof_Vocabulary_Reproduction` | WO | Vocabulario médico | Media |
| `FrancophonIA/bambara-french` | BM | FR-BM paralelo (77.3K) | Alta |
| `FrancophonIA/lexique-senegalais-wolof-diola` | WO, DYO | Léxico | Media |
| `FrancophonIA/Lexicologie_du_soninke` | SNK | Léxico | Media |
| `FrancophonIA/Lexique_Soninke-Francais-Anglais` | SNK, FR, EN | Léxico trilingüe | Media |

**Método:** `load_dataset("FrancophonIA/<dataset>")` o descarga directa.

### 1.4 GalsenAI Datasets

Comunidad senegalesa de IA con datasets wolof.

| Dataset | Tipo | Tamaño |
|---------|------|--------|
| `galsenai/centralized_wolof_french_translation_data` | FR-WO traducción | 98.3K rows |
| `galsenai/wolof_corpus` | Corpus texto wolof | 52.7K rows |
| `galsenai/french-wolof-translation` | FR-WO traducción | 17.8K downloads |
| `galsenai/wolof-audio-data` | Audio wolof | 35.1K downloads |
| `galsenai/wolof_tts` | TTS wolof | 40K downloads |
| `galsenai/anta_women_tts` | TTS voz femenina | 19.9K downloads |
| `galsenai/WaxalNLP` | NLP benchmark | 1.04K rows |

### 1.5 bilalfaye/english-wolof-french-dataset

**83.5K rows** EN-WO-FR paralelo con audio. Dataset multilingüe de alta prioridad.

### 1.6 Kppwdfgu1 — Dialectos Fula

8 dialectos de Fula/Pulaar:

| Dataset | Dialecto | Filas |
|---------|----------|-------|
| `Kppwdfgu1/Fula-maacina` | Maacina | 9.78K |
| `Kppwdfgu1/Fula-borgu` | Borgu | 10.1K |
| `Kppwdfgu1/Fula-liptako` | Liptako | 9.71K |
| `Kppwdfgu1/Fula-bororro` | Bororro | 9.65K |
| `Kppwdfgu1/Fula-pular` | Pular | 9.76K |
| `Kppwdfgu1/Fula-caka` | Caka | 8.92K |
| `Kppwdfgu1/Fula-adamawa` | Adamawa | 10.1K |
| `Kppwdfgu1/fulaa_pulaar` | Pulaar general | 20K |

**Total: ~88K filas** entre todos los dialectos.

### 1.7 NancyT/FulaData

| Dataset | Tipo | Tamaño |
|---------|------|--------|
| `NancyT/FulaData` | ASR Fula | 81.5K rows |
| `NancyT/FulaDatas` | ASR Fula | 73.5K rows |
| `NancyT/Fula-pulaar` | ASR Pulaar | 5.55K rows |

### 1.8 Wikipedia Dumps

| Lengua | Artículos | URL del dump | Tamaño aprox |
|--------|-----------|-------------|-------------|
| **Fula** (ff) | **20,482** | `https://dumps.wikimedia.org/ffwiki/latest/ffwiki-latest-pages-articles.xml.bz2` | ~50MB |
| **Wolof** (wo) | 1,743 | `https://dumps.wikimedia.org/wowiki/latest/wowiki-latest-pages-articles.xml.bz2` | ~5MB |
| **Bambara** (bm) | 1,007 | `https://dumps.wikimedia.org/bmwiki/latest/bmwiki-latest-pages-articles.xml.bz2` | ~3MB |

**Método:** `wget <URL>` + `wikiextractor` para texto plano.
**Herramienta:** `pip install wikiextractor`

### 1.9 Common Voice Adamawa Fulfulde

Common Voice v26 contiene **250.63 MB** de ASR en Adamawa Fulfulde (fub).

**Método:** Descargar de https://commonvoice.mozilla.org/ → seleccionar fub → dataset MP3.

---

## FASE 2: Medio Esfuerzo — Scraping y APIs (esta semana)

Fuentes que requieren scraping programático o uso de APIs.

### 2.1 Web Scraping Senegal

Sitios con potencial contenido bilingüe (FR-WO, FR-BM):

| Sitio | URL | Contenido | Herramienta |
|-------|-----|-----------|-------------|
| Sante.gouv.sn | https://sante.gouv.sn/ | Salud pública | `trafilatura` |
| Seneweb.com | https://www.seneweb.com/ | Noticias | `newspaper3k` |
| Rewmi.com | https://www.rewmi.com/ | Noticias | `newspaper3k` |
| APS.sn | https://aps.sn/ | Agencia prensa Senegal | `trafilatura` |
| Sec.gouv.sn | https://www.sec.gouv.sn/ | Gobierno | `trafilatura` |

**Pipeline de scraping:**
```python
import trafilatura, newspaper3k
from lingua import LanguageDetector

# Por cada URL:
downloaded = trafilatura.fetch_url(url)
text = trafilatura.extract(downloaded)
# Detectar lengua con openlID/fastText
# Si detecta FR + WO → alinear oraciones con LASER
```

**Herramientas a instalar:**
```bash
pip install trafilatura newspaper3k youtube-transcript-api lingua-language-detector
```

### 2.2 YouTube Subtitles

Canales de YouTube con contenido en lenguas senegalesas:
- Buscar: "wolof education", "bambara lesson", "pulaar news"
- Extraer transcripciones automáticas con `youtube-transcript-api`
- Si tienen subtítulos FR + WO → pares paralelos

```python
from youtube_transcript_api import YouTubeTranscriptApi
# Obtener transcripción de un video
transcript = YouTubeTranscriptApi.get_transcript("video_id", languages=['wo', 'fr'])
```

### 2.3 OPUS API

Corpus de traducción masivos (bible-uedin, GNOME, KDE4, Mozilla-l10n).

**Nota:** La API de OPUS (`https://opus.nlpl.eu/`) puede no responder. Alternativa:
- Usar los datasets ya curados en HF
- O descargar dumps estáticos de OPUS

### 2.4 Backtranslation para SRR/DYO/SNK

Para lenguas sin cobertura NLLB:
1. Tomar 10K oraciones EN de NLLB-Seed
2. Traducir EN→FR con NLLB-600M
3. Crear pseudo-pares FR→SRR usando el léxico existente (~80 rows)
4. Generar más datos con aumentación (sinónimos, paráfrasis)
5. Revisión humana de una muestra

---

## FASE 3: Alto Esfuerzo — Construcción de Datos (próximas semanas)

Fuentes que requieren trabajo manual o colaboración externa.

### 3.1 Glosario Médico

**Objetivo:** Terminología médica en WO/BM/FF para consultas de migrantes.

1. Extraer términos ICD-10/WHO ATC en ES/EN/FR
2. Traducir EN→WO con NLLB + revisar con FrancophonIA anatomy vocab existente
3. Crear glossary DB médica
4. Priorizar: síntomas, órganos, medicamentos, emergencias

**Fuentes:**
- FrancophonIA anatomy vocabulary (WO)
- WHO ATC/DDD Index (multilingüe)
- MSF Clinical Guidelines (FR/EN)
- IOM Migration Health Glossary

### 3.2 Grabaciones de Campo

Para SRR, DYO, SNK — lenguas sin recursos digitales.

**Colaboradores potenciales:**
- UCAD (Université Cheikh Anta Diop, Dakar) — Departamento de Lingüística
- CLAD (Centre de Linguistique Appliquée de Dakar)
- Asociaciones de migrantes en España

**Metodología:**
- 100-200 frases médicas/migración por lengua
- 3-5 hablantes nativos por lengua
- 16kHz, WAV, transcripción + traducción
- Protocolo de consentimiento informado

### 3.3 Web Alignment Masivo

Para FR→WO/BM:

1. Crawl .sn + sitios de África Occidental (trafilatura, scrapy)
2. Detectar lenguas con openlID (201 lenguas, soporta wo/bam/ful)
3. Alinear oraciones con LASER3 embeddings
4. Filtrar con BERT multilingual similarity (>0.8)
5. Quality gates + limpieza

---

## Criterios de Calidad

### Texto (NMT)
- ftfy: reparar encoding corrupto
- NFKC: normalización Unicode
- Dedup fuzzy: rapidfuzz > 0.95 por par
- Min chars: 3 por oración
- Max ratio src/tgt: 3:1
- No caracteres no imprimibles

### Audio (SST/TTS)
- 16kHz, mono, PCM 16-bit WAV
- Duración: 3-30 segundos
- DNSMOS > 3.2 (calidad perceptual)
- VAD: eliminar silencios
- SNR > 15dB después de limpieza

---

## Priorización

```
Prioridad  | Lengua | Acción inmediata
P0         | WO     | Integrar HuBERT-CTC + seguir mejorando ByT5
P1         | BM     | Fase 1: NLLB-Seed + FrancophonIA + Maliba corpus
P2         | FF     | Fase 1: Kppwdfgu1 + NancyT + Wikipedia dump
P3         | SRR    | Fase 3: Léxicos + backtranslation + campo
P3         | DYO    | Fase 3: Léxicos + backtranslation + campo  
P3         | SNK    | Fase 3: Léxicos + backtranslation + campo
```

**Criterio:** Primero las lenguas con más recursos y más hablantes. SRR/DYO/SNK requieren trabajo de campo que no podemos automatizar.

---

## Estructura de Archivos en el Volumen

```
/mnt/HC_Volume_106255499/
├── hf_home/              ← Cache de HuggingFace (modelos + datasets)
├── data/
│   ├── nllb/             ← NLLB-Seed pares (WO, BM, FF)
│   ├── francophonia/     ← Datasets FrancophonIA
│   ├── galsenai/         ← Datasets GalsenAI
│   ├── wikipedia/        ← Dumps y texto plano
│   ├── fula/             ← Dialectos Fula (Kppwdfgu1, NancyT)
│   ├── medical/          ← Glosario médico
│   └── evaluation/       ← FLORES-200, test sets
├── models/               ← Pesos de modelos fine-tuneados
├── venvs/                ← Entornos virtuales
└── scripts/              ← Scripts de scraping y ETL
```
