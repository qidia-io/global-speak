#!/usr/bin/env python3
"""
Genera script SQL para poblar la base de datos con lenguas + datasets.

Uso:
    python3 data/scripts/generate_sql.py > data/database/populate_full.sql
    psql -h triniti -U postgres -d global_speak -f data/database/populate_full.sql
"""

from pathlib import Path

# ── Lenguas objetivo ──────────────────────────────────────
LANGUAGES = [
    # (code, iso_639_3, name_en, name_native, family, region, speakers_m, rtl, nllb200, priority)
    ('wo', 'wol', 'Wolof', 'Wolof',       'Níger-Congo', 'Senegal, Gambia', 10.0, False, True,  'high'),
    ('es', 'spa', 'Spanish', 'Español',    'Indo-European', 'Spain, Americas', 500.0, False, True, 'high'),
    ('fr', 'fra', 'French', 'Français',    'Indo-European', 'France, Africa', 320.0, False, True, 'high'),
    ('sw', 'swa', 'Swahili', 'Kiswahili',  'Níger-Congo', 'East Africa', 80.0, False, True,   'high'),
    ('it', 'ita', 'Italian', 'Italiano',   'Indo-European', 'Italy', 68.0, False, True,      'medium'),
    ('ff', 'ful', 'Fula', 'Fulfulde',      'Níger-Congo', 'West Africa', 40.0, False, True,   'medium'),
    ('bm', 'bam', 'Bambara', 'Bamanankan', 'Mandé',       'Mali, Ivory Coast', 15.0, False, True, 'medium'),
    ('en', 'eng', 'English', 'English',    'Indo-European', 'Global', 1500.0, False, True,  'medium'),
]

# ── Modelos ───────────────────────────────────────────────
MODELS = [
    ('sainzpaa/SPANISH-WOLOF-BYT5', 'ByT5-large', 'sainzpaa/SPANISH-WOLOF-BYT5',
     'Fine-tuned ByT5 para Español ↔ Wolof', 'es', 'wo', 'google/byt5-small', 580_000_000, 2300.0, 'production'),

    ('facebook/nllb-200-distilled-600M', 'NLLB-200 distilled', 'facebook/nllb-200-distilled-600M',
     'NLLB-200 distillado 600M — 200 lenguas', None, None, None, 600_000_000, 1200.0, 'production'),

    ('openai/whisper-large-v3', 'Whisper Large V3', 'openai/whisper-large-v3',
     'Speech-to-Text multilingüe', None, None, None, 1_550_000_000, 3100.0, 'production'),

    ('facebook/mms-tts', 'MMS-TTS', 'facebook/mms-tts',
     'Text-to-Speech 1100+ lenguas', None, None, None, 400_000_000, 1800.0, 'production'),
]


def generate() -> str:
    lines = [
        "============================================",
        "-- Global Speak — Población inicial de BD",
        "-- Generado: script automático",
        "============================================",
        "",
        "BEGIN;",
        "",
    ]

    # 1. Languages
    lines.append("-- 1. Lenguas")
    for code, iso3, name_en, name_native, family, region, speakers, rtl, nllb, priority in LANGUAGES:
        rtl_str = 'TRUE' if rtl else 'FALSE'
        nllb_str = 'TRUE' if nllb else 'FALSE'
        lines.append(
            f"INSERT INTO languages (code, iso_639_3, name_en, name_native, family, region, speakers_m, rtl, nllb200_support, priority) "
            f"VALUES ('{code}', '{iso3}', '{name_en}', '{name_native}', '{family}', '{region}', {speakers}, {rtl_str}, {nllb_str}, '{priority}') "
            f"ON CONFLICT (code) DO NOTHING;"
        )
    lines.append("")

    # 2. Models
    lines.append("-- 2. Modelos")
    for hf_repo, arch, name, desc, src, tgt, base, params, size, status in MODELS:
        src_null = f"'{src}'" if src else "NULL"
        tgt_null = f"'{tgt}'" if tgt else "NULL"
        base_null = f"'{base}'" if base else "NULL"
        lines.append(
            f"INSERT INTO models (name, architecture, hf_repo, description, source_lang, target_lang, base_model, parameters, size_mb, status) "
            f"VALUES ('{name}', '{arch}', '{hf_repo}', '{desc}', {src_null}, {tgt_null}, {base_null}, {params}, {size}, '{status}') "
            f"ON CONFLICT (name) DO NOTHING;"
        )
    lines.append("")

    # 3. Pipeline
    lines.append("-- 3. Pipeline por defecto (Wolof ↔ Español)")
    lines.append("""
INSERT INTO pipelines (name, sst_model, nmt_model, tts_model, source_lang, target_lang, status)
VALUES (
    'Wolof-Español',
    (SELECT id FROM models WHERE name = 'Whisper Large V3'),
    (SELECT id FROM models WHERE name = 'ByT5-large'),
    (SELECT id FROM models WHERE name = 'MMS-TTS'),
    'wo', 'es', 'development'
);
""")

    lines.append("COMMIT;")
    lines.append("")
    return '\n'.join(lines)


if __name__ == '__main__':
    print(generate())
