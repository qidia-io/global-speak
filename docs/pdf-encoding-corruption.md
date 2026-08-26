# PDF Encoding Corruption — Diagnosis & Rescue (global-speak)

## El problema

PDFs antiguos (1999–2010) suelen usar fuentes con encoding personalizado que
no incluyen mapeo ToUnicode. El texto se ve correcto al abrir el PDF, pero
los extractores de texto (pdftotext, pymupdf) producen `?` para todos los
caracteres extendidos (acentos, diacríticos wolof, IPA, etc.).

Afecta especialmente a diccionarios, gramáticas y lingüística de lenguas
africanas, muchos creados en esa era.

## Síntomas concretos (Peace Corps Wolof-English Dictionary)

| Lo que ves | Lo que se extrae | Causa |
|------------|------------------|-------|
| `ë`        | `?`              | Sin ToUnicode para U+00EB |
| `ŋ`        | `?`              | Sin ToUnicode para U+014B |
| `ñ`, `é`, `à` | `?`          | Sin ToUnicode para Latin-1 Supplement |
| Vocales (a, e, i, o, u) | OK | En rango ASCII básico, heredado |

Herramienta de origen: `Acrobat Distiller 2.1 for Power Macintosh`

## Diagnóstico rápido

```bash
mutool info documento.pdf 2>/dev/null | grep "Producer\\|Creator"
# "Acrobat Distiller 2.1" = alto riesgo

# Ver si sobrevive algo del diccionario
mutool draw -F text documento.pdf 2>/dev/null | head -30
# Si ves el prefacio/intro pero las entradas del diccionario son puros '?'
# → encoding roto. Ir directamente a OCR.
```

## Estrategias de rescate

### 1. OCR por imágenes — **verificado: funciona** ✓

Probado con Peace Corps Wolof-English Dictionary, 229 páginas, Acrobat Distiller 2.1.
Tesseract con idioma `eng` (sin modelo wolof disponible) extrae contenido legible.

```bash
# Instalar herramientas
apt-get install -y tesseract-ocr tesseract-ocr-eng poppler-utils mupdf-tools

# Extraer cada página como PNG a 200 DPI
# ⚠️ Usar -F png (NO -F image — flag inválido en mutool moderno)
mkdir -p /tmp/pdf_pages
mutool draw -F png -r 200 -o "/tmp/pdf_pages/page-%d.png" "documento.pdf" 1-229 2>/dev/null

# OCR de página individual
tesseract /tmp/pdf_pages/page-10.png /tmp/page10 -l eng 2>/dev/null
cat /tmp/page10.txt | head -30
```

**Resultado verificado** (Peace Corps Dictionary, página 10):
```
doxaan (v) to count, date
doxaan ak bu jigéén = date your sister

doxaankat (n) someone who counts
"Yow doxaankat nga" = You are a person who counts

doxandéem (n) walk
Doxandéem bi dafa tàmm... = The walk has started
```

**Notas de calidad:**
- El texto tiene algo de ruido (Tesseract a veces mezcla columnas)
- Acentos y caracteres wolof (é, ë, ŋ) no siempre perfectos
- Los pares {wolof_word → english_definition} son identificables
- Para uso como glossary de traducción: suficiente con post-procesado

**OCR masivo (229 páginas):**
```bash
mkdir -p /tmp/ocr_out
for f in /tmp/pdf_pages/page-*.png; do
  base=$(basename "$f" .png)
  tesseract "$f" "/tmp/ocr_out/$base" -l eng 2>/dev/null
done
```

### 2. marker-pdf (alternativa, no probada con este PDF)

```bash
pip install marker-pdf  # descarga ~2.5GB de modelos Surya OCR
marker_single documento.pdf --output_dir ./output
```

Mejor con layouts complejos (columnas), pero costoso en disco (~2.5GB de modelos).

### 3. Post-procesado del OCR (Sankofa)

Tras el OCR, limpiar el texto con el pipeline de Sankofa:
- ftfy para corregir encoding residual
- regex para separar columnas (wolof | inglés)
- Dedup de entradas duplicadas (rapidfuzz > 0.95)
- Extraer pares como {word, translation} para glossary.db

## Referencias

- Peace Corps Wolof-English Dictionary: 229 páginas, Acrobat Distiller 2.1
- Ubicación: `/root/data/raw/wo-es/Wolof Dictionary.pdf`
- Estado: **rescate vía OCR verificado ✅** — NO usar pdftotext/pymupdf directo
- Tesseract sin modelo wolof → usar `eng` + post-procesado Sankofa
