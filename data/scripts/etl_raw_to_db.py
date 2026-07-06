#!/usr/bin/env python3
"""
ETL: Raw data → Processed → PostgreSQL (triniti)

Uso:
    python3 data/scripts/etl_raw_to_db.py [--input data/raw] [--output data/processed] [--generate-sql]

Flujo:
    1. Escanea data/raw/ buscando CSVs y archivos NLLB (.src, .tgt, .scores)
    2. Normaliza textos (lowercase, trim, quita caracteres no imprimibles)
    3. Deduplica pares
    4. Hace split train/val/test (80/10/10)
    5. Genera CSV procesado y opcionalmente SQL para poblar la BD
"""

import os
import re
import csv
import sys
import json
import argparse
import random
from pathlib import Path
from collections import defaultdict
from datetime import datetime


# ── Config ────────────────────────────────────────────────
RAW_DIR = Path("data/raw")
PROCESSED_DIR = Path("data/processed")
DB_DIR = Path("data/database")

SEED = 42
TRAIN_SPLIT = 0.80
VAL_SPLIT = 0.10
TEST_SPLIT = 0.10

random.seed(SEED)


# ── Normalización ─────────────────────────────────────────
def normalize_text(text: str) -> str:
    """Limpieza básica de texto."""
    text = text.strip()
    text = re.sub(r'\s+', ' ', text)            # colapsa espacios múltiples
    text = re.sub(r'[^\w\s\.,;:!?¿¡\'\"-áéíóúàèìòùäëïöüâêîôûñç]', '', text)  # chars válidos
    return text


def read_csv_safe(path: Path) -> list[dict]:
    """Lee CSV con detección de encoding y dialecto."""
    try:
        with open(path, 'r', encoding='utf-8') as f:
            return list(csv.DictReader(f))
    except UnicodeDecodeError:
        with open(path, 'r', encoding='latin-1') as f:
            return list(csv.DictReader(f))


def read_nllb_format(pair_dir: Path) -> list[dict]:
    """
    Lee formato legacy NLLB: nllb.{src}-{tgt}.{src|tgt|scores}
    Ej: nllb.es-wo.es, nllb.es-wo.wo, nllb.es-wo.scores
    """
    pairs = pair_dir.name.split('-')
    if len(pairs) != 2:
        return []
    src_lang, tgt_lang = pairs

    # Buscar archivos .src .tgt .scores
    src_file = list(pair_dir.glob(f"nllb.{src_lang}-{tgt_lang}.{src_lang}"))
    tgt_file = list(pair_dir.glob(f"nllb.{src_lang}-{tgt_lang}.{tgt_lang}"))
    scores_file = list(pair_dir.glob(f"nllb.{src_lang}-{tgt_lang}.scores"))

    if not src_file or not tgt_file:
        return []

    with open(src_file[0], 'r', encoding='utf-8') as f:
        src_lines = [normalize_text(l) for l in f.readlines()]
    with open(tgt_file[0], 'r', encoding='utf-8') as f:
        tgt_lines = [normalize_text(l) for l in f.readlines()]

    scores = []
    if scores_file:
        with open(scores_file[0], 'r', encoding='utf-8') as f:
            scores = [float(l.strip()) for l in f.readlines()]

    records = []
    for i, (s, t) in enumerate(zip(src_lines, tgt_lines)):
        if not s or not t:
            continue
        rec = {
            'source_lang': src_lang,
            'target_lang': tgt_lang,
            'source_text': s,
            'target_text': t,
            'quality': scores[i] if i < len(scores) else '',
        }
        records.append(rec)

    return records


def load_all_raw(raw_dir: Path) -> list[dict]:
    """Carga todos los datasets desde raw/."""
    all_records = []

    for lang_dir in raw_dir.iterdir():
        if not lang_dir.is_dir():
            continue

        # CSV en text/
        text_dir = lang_dir / "text"
        if text_dir.exists():
            for f in sorted(text_dir.glob("*.csv")):
                records = read_csv_safe(f)
                all_records.extend(records)
                print(f"  📄 {f.name}: {len(records)} pares")

            # Formato NLLB (nllb.*)
            for f in text_dir.glob("nllb.*"):
                pass  # lo cogemos abajo por directorio

        # Formato NLLB legacy directamente
        nllb_records = read_nllb_format(lang_dir)
        if nllb_records:
            all_records.extend(nllb_records)
            print(f"  📄 {lang_dir.name} (NLLB): {len(nllb_records)} pares")

        # También buscar en text/
        if text_dir.exists():
            for subdir in text_dir.iterdir():
                if subdir.is_dir():
                    nllb_records = read_nllb_format(subdir)
                    if nllb_records:
                        all_records.extend(nllb_records)
                        print(f"  📄 {subdir.name} (NLLB): {len(nllb_records)} pares")

    return all_records


def deduplicate(records: list[dict]) -> list[dict]:
    """Elimina pares duplicados (mismo source_text + target_text)."""
    seen = set()
    unique = []
    for rec in records:
        key = (rec.get('source_lang', ''), rec.get('target_lang', ''),
               normalize_text(rec.get('source_text', '')),
               normalize_text(rec.get('target_text', '')))
        if key not in seen:
            seen.add(key)
            unique.append(rec)
    return unique


def split_dataset(records: list[dict]) -> tuple[list[dict], list[dict], list[dict]]:
    """Train/Val/Test split."""
    random.shuffle(records)
    n = len(records)
    train_end = int(n * TRAIN_SPLIT)
    val_end = train_end + int(n * VAL_SPLIT)

    train = records[:train_end]
    val = records[train_end:val_end]
    test = records[val_end:]
    return train, val, test


def save_csv(records: list[dict], path: Path):
    """Guarda registros como CSV."""
    if not records:
        return
    fieldnames = ['source_lang', 'target_lang', 'source_text', 'target_text', 'quality']
    with open(path, 'w', encoding='utf-8', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(records)
    print(f"  💾 {path.name}: {len(records)} registros")


def generate_sql(records: list[dict], path: Path):
    """Genera script SQL para poblar las tablas datasets y pipeline_logs."""
    lines = [
        "-- ============================================",
        f"-- Script de población generado: {datetime.now().isoformat()}",
        "-- ============================================",
        "",
        f"INSERT INTO datasets (name, source_lang, target_lang, source, sentence_count, notes)",
        f"VALUES ('Carga desde ETL', 'wo', 'es', 'Usuario', {len(records)}, 'Dataset subido desde PC local');",
        "",
        "-- Pipeline logs (pares de traducción de ejemplo)",
        "INSERT INTO pipeline_logs (pipeline_id, source_text, translated_text, success)",
    ]

    batch = []
    for i, rec in enumerate(records[:500]):  # limitar a 500 para no saturar
        src = rec.get('source_text', '').replace("'", "''")
        tgt = rec.get('target_text', '').replace("'", "''")
        batch.append(f"    (1, '{src}', '{tgt}', true)")

    if batch:
        lines.append("VALUES")
        lines.append(",\n".join(batch))
        lines.append(";")
        lines.append("")

    lines.append(f"-- Total: {len(records)} pares disponibles, {min(500, len(records))} insertados como muestra")

    with open(path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))
    print(f"  🛢️  {path.name}: SQL generado")


def main():
    parser = argparse.ArgumentParser(description="ETL para datos de Global Speak")
    parser.add_argument('--input', default=str(RAW_DIR), help='Directorio raw')
    parser.add_argument('--output', default=str(PROCESSED_DIR), help='Directorio processed')
    parser.add_argument('--generate-sql', action='store_true', help='Generar script SQL')
    args = parser.parse_args()

    raw_dir = Path(args.input)
    proc_dir = Path(args.output)

    print("=" * 60)
    print("  ETL — Global Speak Data Pipeline")
    print("=" * 60)
    print()

    # 1. Carga
    print("📥 Cargando datos raw...")
    records = load_all_raw(raw_dir)
    print(f"\n   Total bruto: {len(records)} pares")

    # 2. Deduplicación
    print("\n🧹 Deduplicando...")
    records = deduplicate(records)
    print(f"   Tras dedup: {len(records)} pares únicos")

    if not records:
        print("\n⚠️  No se encontraron datos. Sube archivos CSV o NLLB a data/raw/")
        return

    # 3. Split
    print("\n✂️  Dividiendo train/val/test...")
    train, val, test = split_dataset(records)

    proc_dir.mkdir(parents=True, exist_ok=True)
    save_csv(train, proc_dir / "train" / "train.csv")
    save_csv(val, proc_dir / "val" / "val.csv")
    save_csv(test, proc_dir / "test" / "test.csv")

    # 4. Resumen por par de lenguas
    print("\n📊 Resumen por par de lenguas:")
    lang_pairs = defaultdict(int)
    for rec in records:
        key = f"{rec.get('source_lang','?')}→{rec.get('target_lang','?')}"
        lang_pairs[key] += 1
    for pair, count in sorted(lang_pairs.items()):
        print(f"   {pair}: {count} pares")

    # 5. SQL
    if args.generate_sql:
        db_dir = DB_DIR
        db_dir.mkdir(parents=True, exist_ok=True)
        generate_sql(records, db_dir / "populate.sql")

    print(f"\n✅ Done. Procesados {len(records)} pares únicos.")
    print(f"   Train: {len(train)} | Val: {len(val)} | Test: {len(test)}")


if __name__ == '__main__':
    main()
