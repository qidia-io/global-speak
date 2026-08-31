# 🎯 PROJECT CONTROL — Global Speak
> **Documento maestro de control global** — todo el proyecto, no solo el SST
> Última actualización: 31 agosto 2026 · Autor: Nemrod (System Architect)

---

## 1. 🧭 Misión y Contexto

**global-speak** es un sistema multilingüe **SST → NMT → TTS** (voz → traducción → voz) para **migrantes senegaleses** y hablantes de lenguas con pocos recursos (*low-resource languages*).

| Aspecto | Detalle |
|---|---|
| **Visión** | Traducción de voz en tiempo real para lenguas sin recursos comerciales |
| **Piloto** | Español ↔ Wolof (es↔wo) |
| **Expansión** | Bambara (bm) → Fula (ff) → Serer (srr) → Jola (dyo) → Soninké (snk) |
| **Diseño de producto** | Sistema **walkie-talkie**: pulsar-hablar-soltar, traducción instantánea |
| **Repositorio** | `qidia-io/global-speak` — **público** |

> ⚠️ **El proyecto NO es solo el SST.** El pipeline de voz es el corazón técnico, pero el proyecto completo abarca: infraestructura, nodo local, agentes IA, seguimiento externo, despliegue móvil y documentación. Este documento da el **control global de todo ello**.

---

## 2. 🏗️ Las 3 Dimensiones del Proyecto

| Dimensión | Qué es | Dónde vive | Estado |
|---|---|---|---|
| **A. Producto técnico** | Pipeline SST→NMT→TTS + app móvil | Repo (`app/`, `notebooks/`), HF Hub | 🔄 Fases A+B cerradas, C/D/E en backlog |
| **B. Infraestructura** | Triniti (24/7) + nodo local (PC usuario) + red Tailscale | Servidores, DeepSeek API | ✅ Operativa |
| **C. Organización** | Equipo multiagente + seguimiento externo (GitHub/Notion/Bruce) | Kanban Hermes, GitHub, Notion | 🔄 En consolidación |

**Principio rector:** *El seguimiento debe verse desde un sistema externo — no depender de un solo agente.*

---

## 3. 📅 Cronología de Actividades (de principio a fin)

| Fecha | Actividad | Responsable | Estado |
|---|---|---|---|
| Jul 2026 | Fundación: estructura repo, BD PostgreSQL, agentes renombrados | Nemrod | ✅ |
| Jul 2026 | Data pipeline: es-wo/en-wo/fr-wo limpiados (1.873.941 pares, 95.4% retención) | Sankofa | ✅ |
| Jul 2026 | Glosario Peace Corps: 5.021 entradas vía OCR | Sankofa | ✅ |
| Jul 2026 | App React + Capacitor (4 pantallas, mock mode sagrado) | Mbok | ✅ |
| Jul 2026 | Modelos: ByT5 es↔wo, HuBERT-CTC SST, MMS-TTS español | Janus/Mbok | ✅ |
| 06-jul | GitHub Issues #2–#4 creados (backlog inicial) | Nemrod | ✅ |
| 26-ago | **Fase A**: 4 notebooks PyTorch limpios y validados (`c63daa4`) | Janus | ✅ |
| 26-ago | **Fase B**: ByT5 selector en `inferenceClient.ts` (sin commitear) | Mbok | 🔄 |
| 27-ago | Triniti unido a Tailscale (red unificada `alejandro.sainz.pardo@`) | Nemrod | ✅ |
| 27-ago | Saga HP: Boot Mode fix + Ubuntu 26.04 + Tailscale oficial | Usuario/Nemrod | ✅ |
| 27-ago | **Nodo local**: Hermes v0.20.5 + DeepSeek API en el PC | Nemrod | ✅ |
| 27-ago | **Bruce**: bot Telegram `tio_bruce_bot` conectado y verificado | Nemrod | ✅ |
| 27-ago | Migración kanban → GitHub Issues (18 tareas, #5–#22) | Nemrod | ✅ |
| 27-ago | Notion: integración API + BD Tareas (21 filas) + ROADMAP | Nemrod | ✅ |
| 31-ago | Documentación integral: PROJECT_CONTROL.md | Nemrod | 🔄 |

---

## 4. 🏁 Fases y Milestones (estado real verificado)

### Fase A — Codebase Limpio ✅
| Tarea | Estado |
|---|---|
| Limpiar notebooks NMT/SST/TTS (solo PyTorch) | ✅ Done (`c63daa4`) |
| Fix JSON en `sst_finetune_whisper.ipynb` | ✅ Done |

### Fase B — App y Pipeline 🔄
| Tarea | Estado |
|---|---|
| Integrar ByT5 en `inferenceClient.ts` (selector ByT5 es↔wo / NLLB resto) | 🔄 Sin commitear |
| Pipeline Python standalone `pipeline.py` | ▶ Ready |
| Cache de inferencia (SQLite/JSON) | ▶ Ready |
| Tests unitarios (inferenceClient, storage, audio) | ▶ Ready |

### Fase C — Voz Wolof Completa ▶
| Tarea | Estado |
|---|---|
| Integrar `galsenai/wolof_tts` (TTS wolof) | ▶ Ready |
| Test E2E SST→NMT→TTS con audio wolof real | ▶ Ready |

### Fase D — Datos BM/FF ▶
| Tarea | Estado |
|---|---|
| Fase 1 BM/FF: NLLB-Seed, Maliba, FrancophonIA, Wikipedia | ▶ Ready |
| Descargar FLORES-200 (evaluación multilingüe) | ▶ Ready |
| Ingerir Wolof-ASR-Data + datos propios | ▶ Ready |

### Fase E — Backend/Infra ▶
| Tarea | Estado |
|---|---|
| Backend API FastAPI (desacoplar inferencia) | ▶ Ready |
| Pipeline offline móvil (ONNX/TFLite) | ▶ Ready |
| CI/CD GitHub Actions | ▶ Ready |
| Despliegue móvil APK → Play/App Store | ▶ Ready |

**Gráfico Gantt completo:** `GANTT.md` (Mermaid, renderizable en GitHub).

---

## 5. 🤖 Equipo y Responsabilidades

| Agente | Perfil | Rol | Carga kanban |
|---|---|---|---|
| 👑 **Nemrod** | `default` | Arquitecto — diseña, documenta, coordina, aprueba | — |
| 🎤 **Echo** | `translator` | Voz — SST, TTS, calidad de audio, test E2E | 2 ready |
| 🔄 **Janus** | `linguist` | Fine-tuning, notebooks, evaluación (BLEU/chrF/COMET) | 1 done + 2 ready |
| 🏗️ **Mbok** | `coder` | App React + Capacitor, API client, pipeline | 2 done + 6 ready |
| 📊 **Sankofa** | `curator` | Data curation, quality gates, ETL, BD | 2 ready |
| 🎨 **Griot** | `griot` | Product Designer & UX/UI — PRD, flujo pulsar-hablar-soltar | 3 blocked |

**Pipeline de nueva lengua (secuencial):** Sankofa cura datos → Janus fine-tunea y evalúa → Mbok añade 2 líneas al Model Router → Echo prueba E2E.

---

## 6. 🗂️ Sistemas de Seguimiento (el «control»)

| Sistema | Rol | Estado | URL/Comando |
|---|---|---|---|
| **Kanban Hermes** | Fuente de verdad interna (SQLite, durável) | 12 ready · 3 blocked · 3 done | `hermes kanban` (board `global-speak`) |
| **GitHub Issues** | Tablero operativo público, conectado al código | 21 issues con labels `[ÁREA]` + `status:*` | [github.com/qidia-io/global-speak/issues](https://github.com/qidia-io/global-speak/issues) |
| **GitHub Projects** | Tablero visual drag-and-drop | ⏳ Pendiente token con scope `project` | — |
| **Notion** | Cuartel general: BD Tareas + ROADMAP + DECISION LOG | BD con 21 tareas + ROADMAP ✅ | [Nemrod-global-speak](https://app.notion.com/p/Nemrod-global-speak-3cda97bd797c80ccb06ce6b3ade351e6) |
| **Bruce (Telegram)** | Secretario personal — responde desde el portátil | ✅ Activo (`@tio_bruce_bot`) | Telegram ID 5520920388 |

**Flujo de sincronización:**
```
Kanban Hermes (fuente viva) → GitHub Issues (operativo) → Notion (cuartel general)
                                   ↑
                              Bruce (secretario, Telegram)
```

---

## 7. 📝 Decisiones Clave (Decision Log)

| Fecha | Decisión | Razón |
|---|---|---|
| 26-ago | **Walkie-talkie** como diseño del producto (pulsar-hablar-soltar) | Simplicidad para el usuario migrante |
| 27-ago | **DeepSeek API** como cerebro (no Ollama) | Sin GPU local; ~1 céntimo/conversación |
| 27-ago | **Triniti sigue de servidor principal**; el PC es nodo adicional | 24/7 para el proyecto; PC para uso personal |
| 27-ago | **Nodo local = Hermes + DeepSeek** en el HP EliteBook | Asistente personal con control de la máquina |
| 27-ago | **Bruce** = asistente personal (no temático de lenguas) | «No va a tratar sobre lenguas... controlar todos mis proyectos» |
| 27-ago | **Seguimiento externo**: GitHub (operativo) + Notion (cuartel) | «Desde un sistema externo, no solo en Hermes» |
| 27-ago | **Tailscale oficial** (no snap) en el HP | Bug de la snap: nodo offline pese a aparecer conectado |

---

## 8. 🖥️ Infraestructura Actual

### Triniti (servidor principal, 24/7)
| Recurso | Detalle |
|---|---|
| IP pública | 46.224.226.201 |
| IP Tailscale | 100.109.240.106 |
| RAM | 7,6 GB (2 GB usados) |
| Disco | 9 GB libres raíz + 32 GB en `/mnt/HC_Volume_106255499` |
| Servicios | PostgreSQL :5432 · Dashboard :9119 · Gateway Hermes |
| GPU | ❌ No — fine-tuning vía RunPod/Colab |

### Nodo local (HP EliteBook 840 G2)
| Recurso | Detalle |
|---|---|
| OS | Ubuntu 26.04 (kernel 7.0) |
| IP Tailscale | 100.124.169.79 (cambia en cada reconexión) |
| RAM | 14 Gi (11 Gi libres) · Disco: 206 GB libres |
| Hermes | v0.20.5 (`/home/qidia/.local/bin/hermes`) |
| Cerebro | DeepSeek API (`api.deepseek.com/v1`) |
| Canal | Telegram Bruce (`@tio_bruce_bot`) — gateway con linger |

### Red Tailscale (cuenta `alejandro.sainz.pardo@`)
| Nodo | IP |
|---|---|
| triniti | 100.109.240.106 |
| laptop-jf2jom99 (Windows) | 100.126.53.78 |
| qidia-hp-elitebook-840-g2 | 100.124.169.79 |

---

## 9. ⏳ Pendientes Globales

### 🔴 Bloqueado
| Tarea | Por qué |
|---|---|
| GitHub Projects visual | Token sin scope `project` |
| DECISION LOG en Notion | Error JSON puntual (se reintenta) |

### 🟡 Media
| Tarea | Notas |
|---|---|
| Commitear Fase B (`modelRouter.ts` + `inferenceClient.ts`) | Trabajo de Mbok, listo para push |
| Evaluación formal ByT5 (BLEU/chrF/COMET) | Janus, CPU suficiente |
| Fase 1 datos BM/FF | Sankofa (paralelo) |
| Schema.sql vs BD real | Dice `global_speak`, la BD es `globalspeak` |

### 🟢 Baja
| Tarea | Notas |
|---|---|
| Consolidar GitHub Issues del backlog | Unificar con kanban |
| `tools/setup_local_node.sh` | Obsoleto (todo se hizo por SSH) |
| Modelos HF con 401 (3) | Gated — solicitar acceso |

---

## 10. 🔄 Cómo se Mantiene Este Documento

1. **Fuente viva de tareas:** `hermes kanban` (board `global-speak`) — nunca marcar done sin verificación real
2. **Vista externa:** GitHub Issues (labels `[ÁREA]` + `status:*`) ↔ Notion (BD Tareas)
3. **Este documento** se actualiza cuando cambian fases, infraestructura o decisiones
4. **Nuevas decisiones** → se añaden al Decision Log (repo + Notion)

---

*Documento maestro. Complementa a STATUS.md (estado diario) y ROADMAP.md (milestones técnicos).*
