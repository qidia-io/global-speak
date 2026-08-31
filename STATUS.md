# 📊 STATUS — Global Speak Project

> Sistema multilingüe SST→NMT→TTS para migrantes senegaleses
> **Última actualización:** 31 agosto 2026
> **Servidor:** Triniti (46.224.226.201) · **Nodo local:** HP EliteBook 840 G2 (Ubuntu 26.04)
> **Visión 360°:** ver [PROJECT_CONTROL.md](PROJECT_CONTROL.md) — documento maestro de control global

---

## ✅ Completado (verificado)

| Componente | Estado | Detalle |
|---|---|---|
| **App React + Capacitor** | ✅ | Código completo en `app/` — 4 screens, servicios, shadcn/ui |
| **Inference Client** | ✅ | Mock mode + HF API real. SST (Whisper), NMT (NLLB + ByT5), TTS (MMS) |
| **SST Wolof (HuBERT-CTC)** | ✅ | WER 35.65%, 2.9s CPU — integrado |
| **NMT ES↔WO (ByT5)** | ✅ | `sainzpaa/SPANISH-WOLOF-BYT5` en producción |
| **Glossary WO→EN** | ✅ | 5.021 entradas Peace Corps |
| **TTS Español** | ✅ | `facebook/mms-tts-spa` en producción |
| **Data pipeline** | ✅ | 1.873.941 pares limpios (es/en/fr-wo, 95.4% retención) |
| **Notebooks PyTorch limpios** | ✅ | Fase A cerrada — 4 notebooks validados (`c63daa4`) |
| **Nodo local** | ✅ | Hermes v0.20.5 + DeepSeek API en el PC del usuario (27-ago) |
| **Bruce (Telegram)** | ✅ | `@tio_bruce_bot` conectado y verificado con mensaje real |
| **Red Tailscale** | ✅ | Triniti + laptop + HP en cuenta única (`alejandro.sainz.pardo@`) |
| **Seguimiento externo** | ✅ | 21 GitHub Issues con labels + BD Notion (21 tareas) + ROADMAP Notion |

## 🔄 En Progreso

| Componente | Estado | Detalle |
|---|---|---|
| **Fase B (Mbok)** | ⚡ | `modelRouter.ts` + `inferenceClient.ts` listos pero **sin commitear** |
| **Documentación integral** | ⚡ | PROJECT_CONTROL.md creado (31-ago); DECISION LOG Notion pendiente de reintento |

## 📋 Backlog (de GitHub Issues #5–#22, con labels)

| Área | Tareas ready | Bloqueadas |
|---|---|---|
| [APP] | 6 | — |
| [ML] | 2 (+1 done) | — |
| [VOZ] | 2 | — |
| [DATOS] | 2 | — |
| [INFRA] | 2 | — |
| [PRODUCTO] | — | 3 (Griot) |

**Prioridades actuales:** commitear Fase B → evaluar ByT5 (BLEU/chrF) → pipeline.py → TTS wolof.

## 🗂️ Estado por Componente Técnico

| Componente | Lengua | Modelo | Métrica | Estado |
|---|---|---|---|---|
| SST | WO | Wolof-HuBERT-CTC | WER 35.65% | ✅ |
| NMT | ES↔WO | ByT5-small | Pendiente BLEU | ✅ Producción |
| NMT | EN/FR↔WO | NLLB-200-600M | — | ✅ Fallback |
| TTS | ES | mms-tts-spa | — | ✅ |
| TTS | WO | galsenai/wolof_tts | — | ⏳ Ready |
| SST/NMT/TTS | BM, FF | — | — | ⏳ Fase 1 datos |
| — | SRR/DYO/SNK | — | — | ❌ Fase 3 |

## 🖥️ Infraestructura

| Recurso | Detalle |
|---|---|
| Triniti | CPU-only, 7,6GB RAM, 46.224.226.201, Tailscale 100.109.240.106 |
| Nodo local | HP EliteBook 840 G2, Ubuntu 26.04, 14Gi RAM, Tailscale 100.124.169.79 |
| Volumen datos | `/mnt/HC_Volume_106255499` — 32GB libres |
| GPU | ❌ No — fine-tuning vía RunPod/Colab |
| Cerebro IA | DeepSeek API (`api.deepseek.com/v1`) — Triniti y nodo local |

## 🔗 Recursos

| Recurso | URL |
|---|---|
| Repo | `git@github.com:qidia-io/global-speak.git` (público) |
| Issues | https://github.com/qidia-io/global-speak/issues |
| Notion | https://app.notion.com/p/Nemrod-global-speak-3cda97bd797c80ccb06ce6b3ade351e6 |
| Bruce | `@tio_bruce_bot` en Telegram |
| Kanban | `hermes kanban` — board `global-speak` |
| ByT5 Wolof | https://huggingface.co/sainzpaa/SPANISH-WOLOF-BYT5 |

---

*Actualizado con cada sesión de trabajo. Estado verificado contra código, servicios y APIs reales.*
