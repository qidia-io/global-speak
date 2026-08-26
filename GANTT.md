# 🗓️ GANTT — Global Speak Project

> Generado desde el kanban de Hermes (`hermes kanban` → board `global-speak`)
> **Actualizado:** 26 agosto 2026
> Fases por prioridad + dependencias lógicas (limpieza → evaluación → integración)

```mermaid
gantt
    title global-speak — Roadmap SST→NMT→TTS
    dateFormat  YYYY-MM-DD
    axisFormat  %d %b

    section 🧹 Fase A — Limpieza (Janus)
    Limpiar notebooks NMT/SST/TTS        :a1, 2026-08-26, 5d
    Evaluación formal ByT5 (BLEU/chrF)   :a2, after a1, 3d

    section 📱 Fase B — App (Mbok)
    Integrar ByT5 en inferenceClient     :b1, 2026-08-26, 2d
    Pipeline Python standalone (pipeline.py) :b2, after b1, 3d
    Cache de inferencia (SQLite/JSON)    :b3, after b2, 2d
    Tests unitarios (inferenceClient/storage/audio) :b4, after b3, 3d
    CI/CD GitHub Actions                 :b5, after b4, 2d
    Compilar primer APK (Capacitor)      :b6, after b5, 3d
    Despliegue móvil (Play/App Store)    :b7, after b6, 5d

    section 🎤 Fase C — Voz (Echo)
    Integrar galsenai/wolof_tts (TTS WO) :c1, 2026-08-27, 3d
    Test E2E SST→NMT→TTS audio wolof real :c2, after c1, 2d

    section 📊 Fase D — Datos (Sankofa)
    Fase 1 datos BM/FF (NLLB-Seed, Maliba, Wikipedia) :d1, 2026-08-28, 7d
    Descargar FLORES-200                  :d2, after d1, 2d
    Ingerir Wolof-ASR-Data + datos propios :d3, after d1, 4d

    section 🏗️ Fase E — Backend/Infra (Mbok)
    Backend API FastAPI                  :e1, after b7, 4d
    Pipeline offline móvil (ONNX/TFLite) :e2, after e1, 5d
```

## Leyenda

| Fase | Prioridad | Agente | Depende de |
|---|---|---|---|
| A. Limpieza + evaluación | 🔴 Alta | Janus | — (desbloquea todo) |
| B. App + pipeline | 🔴 Alta | Mbok | — (paralela a A) |
| C. Voz wolof completa | 🔴 Alta | Echo | A (notebooks limpios) |
| D. Datos BM/FF | 🟡 Media | Sankofa | — (paralela) |
| E. Backend + offline | 🟢 Baja | Mbok | B (app estable) |

## Cómo regenerar

```bash
hermes kanban list --board global-speak   # estado vivo
# Actualizar este archivo cuando cambien fases/fechas
```

*Fuente de verdad diaria: kanban. Este Gantt es la vista temporal agregada.*
