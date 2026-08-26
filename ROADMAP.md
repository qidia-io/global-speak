# 🗺️ ROADMAP — Global Speak

> Hitos del proyecto ordenados por prioridad y dependencias.

---

## 🏁 Milestone 1: Codebase Limpio y Funcional
*Target: 1-2 sesiones*

| Issue | Tarea | Depende de |
|-------|-------|-----------|
| #1 | Limpiar notebooks NMT (eliminar celdas TF/muertas) | — |
| #2 | Reescribir SST notebook con Whisper + PyTorch | — |
| #3 | Simplificar TTS notebook a HF MMS-TTS API | — |
| #4 | Integrar ByT5 selector en `inferenceClient.ts` | — |
| #5 | Crear `pipeline.py` (SST→NMT→TTS standalone) | #1, #2, #3, #4 |

**🧪 Verificación:** Traducción real funcionando desde terminal con `pipeline.py`

---

## 🏁 Milestone 2: Evaluación y Calidad
*Target: 1 sesión*

| Issue | Tarea | Depende de |
|-------|-------|-----------|
| #6 | Evaluar ByT5: BLEU, chrF, COMET | #1 |
| #7 | Evaluar Whisper: WER en wolof | #2 |
| #8 | Evaluar MMS-TTS: MOS subjetivo | #3 |
| #9 | Cache de inferencia local (SQLite) | #5 |

---

## 🏁 Milestone 3: Robustez y Tests
*Target: 1-2 sesiones*

| Issue | Tarea | Depende de |
|-------|-------|-----------|
| #10 | Tests unitarios para servicios (inference, audio, storage) | #4 |
| #11 | Tests de integración del pipeline | #5 |
| #12 | CI/CD con GitHub Actions (build + lint + test) | #10, #11 |

---

## 🏁 Milestone 4: Producción
*Target: 2-3 sesiones*

| Issue | Tarea | Depende de |
|-------|-------|-----------|
| #13 | Backend API Server (FastAPI) | #5 |
| #14 | Despliegue Mobile (APK compilado con Capacitor) | — |
| #15 | Soporte multi-lengua completo (fr↔wo, es↔sw, etc.) | #4 |
| #16 | Documentación de API backend | #13 |

---

## Progreso

```
Milestone 1: ████░░░░░░ 40%
Milestone 2: ░░░░░░░░░░  0%
Milestone 3: ░░░░░░░░░░  0%
Milestone 4: ░░░░░░░░░░  0%
```

*Actualizado: 2026-07-06*
