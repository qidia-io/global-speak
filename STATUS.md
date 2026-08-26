# Global Speak — STATUS.md

> Sistema multilingüe SST→NMT→TTS para migrantes senegaleses
> Actualizado: 8 julio 2026

## Filosofía del Sistema

**Pipeline propio SST→NMT→TTS, modular y extensible.** No reemplazamos nuestra arquitectura por modelos externos — los usamos como componentes intercambiables. Lenguas fuente: ES/EN/FR. Lenguas destino: WO/BM/FF/SRR/DYO/SNK. Prioridad: calidad.

## Equipo Multiagente

| Agente | Perfil | Rol | Estado |
|--------|--------|-----|--------|
| **Nemrod** 🧠 | `default` | Arquitecto, coordinación | ✅ Activo |
| **Echo** 🎤 | `translator` | Voz: SST→NMT→TTS | ✅ Activo |
| **Janus** 🔄 | `linguist` | Fine-tuning, notebooks | ✅ Activo |
| **Mbok** 🏗️ | `coder` | App React + Capacitor | ✅ Activo |
| **Sankofa** 📊 | `curator` | Data curation, quality gates | ✅ Activo |

## Documentación

| Documento | Ruta | Propósito |
|-----------|------|-----------|
| Arquitectura multilingüe | `docs/SPEECH_LLM_ARCHITECTURE.md` | Diseño del sistema, decisiones técnicas |
| Plan recolección de datos | `docs/DATA_COLLECTION_PLAN.md` | Fases y fuentes para 6 lenguas |
| Orquestación | SKILL: `nemrod-orchestration` | Delegación a agentes |

## Estado por Componente

### SST (Speech-to-Text)

| Lengua | Modelo | WER | Latencia (CPU) | Estado |
|--------|--------|-----|----------------|--------|
| **WO** | `Wolof-HuBERT-CTC` (Soynade) | 35.65% | **2.9s** ✅ | ✅ Integrado (reemplaza Whisper) |
| WO (legacy) | `whisper-small-wolof-v1` (propio) | — | ~60s | 🔄 Legacy |
| BM | — | — | — | ⏳ Fase 1 recolección |
| FF | — | — | — | ⏳ Fase 1 recolección |
| SRR/DYO/SNK | — | — | — | ❌ Sin datos |

### NMT (Machine Translation)

| Par | Modelo | Métrica | Estado |
|-----|--------|---------|--------|
| ES↔WO | ByT5-small (propio) | Pendiente BLEU/chrF | ✅ En producción |
| EN↔WO | NLLB-200-distilled-600M | — | ✅ Fallback |
| FR↔WO | NLLB-200-distilled-600M | — | ✅ Fallback |
| ES/EN/FR↔BM | NLLB-200 (`bam_Latn`) | — | ⏳ Datos en recolección |
| ES/EN/FR↔FF | NLLB-200 (`ful_Latn`) | — | ⏳ Datos en recolección |
| SRR/DYO/SNK | — | — | ❌ Sin cobertura NLLB |
| Glossary WO→EN | 5,021 entradas Peace Corps | Fuzzy match | ✅ Integrado |

### TTS (Text-to-Speech)

| Lengua | Modelo | Estado |
|--------|--------|--------|
| ES | `facebook/mms-tts-spa` | ✅ En producción |
| WO | `galsenai/wolof_tts` (identificado) | ⏳ Pendiente integración |
| BM | — | ⏳ Pendiente |
| FF | — | ⏳ Pendiente |

## Infraestructura

| Recurso | Detalle |
|---------|---------|
| Servidor principal | CPU-only (46.224.226.201) |
| Disco raíz | 75GB (9GB libres) |
| **Volumen datos** | **/mnt/HC_Volume_106255499 — 50GB (32GB libres)** |
| HF cache | Redirigido al volumen |
| GPU disponible | ❌ No — fine-tuning via RunPod/Colab |

## Pipeline de Trabajo por Lengua

```
1. Recolectar datos (Sankofa) → 2. Limpiar + ETL (Sankofa)
→ 3. Fine-tune (Janus, GPU opcional)
→ 4. Integrar en Model Router (Mbok)
→ 5. Probar E2E (Echo)
```

### WO (Wolof) — ✅ Pipeline completo
- SST: HuBERT-CTC integrado
- NMT: ByT5 funcionando, mejora continua vía datos limpios
- TTS: pendiente galsenai/wolof_tts

### BM (Bambara) — 🔄 Fase 1 activa
- Datos identificados: 892K Maliba, 186K MT, 77K FR-BM
- Acción: descargar NLLB-Seed + FrancophonIA + Maliba corpus

### FF (Fula) — 🔄 Fase 1 activa
- Datos identificados: 88K dialectos Kppwdfgu1, 81K NancyT, 20K Wikipedia
- Acción: descargar + Wikipedia dump

### SRR/DYO/SNK — ⏳ Fase 3
- Sin recursos digitales suficientes
- Estrategia: backtranslation + colaboración UCAD + grabaciones campo

## Tareas Completadas Recientemente

- [x] Auditoría de modelos Soynade (HuBERT-Base, HuBERT-CTC, ASR-Data)
- [x] Testeo de Wolof-HuBERT-CTC: 2.9s CPU, transcripción correcta de wolof
- [x] Research exhaustivo de fuentes de datos para 6 lenguas senegalesas
- [x] Catálogo de 50+ datasets identificados en HuggingFace
- [x] Documentación de arquitectura multilingüe (SPEECH_LLM_ARCHITECTURE.md)
- [x] Documentación de plan de recolección (DATA_COLLECTION_PLAN.md)
- [x] Redirección de HF cache a volumen externo (50GB)

## Próximas Tareas (FASE 1 — Inmediata)

- [ ] Descargar NLLB-Seed pares WO/BM/FF
- [ ] Descargar FrancophonIA datasets (médicos, guías multilingües)
- [ ] Descargar GalsenAI + bilalfaye datasets wolof
- [ ] Descargar Wikipedia dumps FF/WO/BM
- [ ] Descargar dialectos Fula (Kppwdfgu1 + NancyT)
- [ ] FLORES-200 para evaluación
- [ ] Integrar galsenai/wolof_tts en pipeline TTS
- [ ] Renovar STATUS.md con tracking por fase
