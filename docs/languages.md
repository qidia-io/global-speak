# Lenguas Soportadas

## Objetivo

El proyecto está diseñado para **lenguas con pocos recursos digitales** (*low-resource languages*), especialmente lenguas de África Occidental habladas por comunidades migrantes.

## Lengua Piloto: Wolof

| Propiedad | Valor |
|---|---|
| **Nombre nativo** | Wolof (Wolof) |
| **Código ISO** | `wo` / `wol` |
| **Hablantes** | ~10 millones (Senegal, Gambia, Mauritania) |
| **Escritura** | Latina (Wolofal árabe minoritario) |
| **Dirección** | LTR (left-to-right) |
| **Rol en proyecto** | Piloto — primer par entrenado con ByT5 |

## Próximas Lenguas (roadmap)

| Lengua | Código | Familia | Región | Prioridad |
|---|---|---|---|---|
| **Fula / Pular** | `ff` / `ful` | Níger-Congo | Senegal, Guinea, Mali, Nigeria | Alta |
| **Bambara / Bamanankan** | `bm` / `bam` | Mandé | Mali, Costa de Marfil | Alta |
| **Serer** | `srr` | Níger-Congo | Senegal, Gambia | Media |
| **Jola / Diola** | `dyo` | Níger-Congo | Senegal, Gambia, Guinea-Bissau | Media |
| **Soninké** | `snk` | Mandé | Senegal, Mali, Mauritania | Media |
| **Hausa** | `ha` / `hau` | Chádica | Nigeria, Níger, Ghana | Baja |
| **Suajili** | `sw` / `swa` | Bantú | Tanzania, Kenia, Uganda | Baja |
| **Árabe (Hassaniya)** | `mey` | Semítica | Mauritania, Sahara Occidental | Baja |

## Lenguas Fuente

| Lengua | Código | Notas |
|---|---|---|
| Español | `es` / `spa` | Lengua principal de la interfaz |
| Francés | `fr` / `fra` | Lengua administrativa en Senegal |
| Inglés | `en` / `eng` | Interfaz secundaria |

## Cobertura por Modelo

### ByT5 (fine-tuned)
- [x] Español ↔ Wolof (entrenado y subido)
- [ ] Español ↔ Fula (pendiente)
- [ ] Español ↔ Bambara (pendiente)
- [ ] Francés ↔ Wolof (pendiente)

### NLLB-200 (cobertura nativa)
- [x] Wolof (`wol_Latn`)
- [x] Fula (`ful_Latn`) — pero calidad no óptima
- [x] Bambara (`bam_Latn`)
- [x] Hausa (`hau_Latn`)
- [x] Suajili (`swh_Latn`)
- [x] Árabe (`arb_Arab`)
- [x] Serer (`srr`) — **no soportado** por NLLB-200
- [x] Jola (`dyo`) — **no soportado** por NLLB-200
- [x] Soninké (`snk`) — **no soportado** por NLLB-200

> **Nota**: Las lenguas sin soporte en NLLB-200 necesitan modelos fine-tuned propios (ByT5).

## Evaluación de Calidad (planeada)

| Par | BLEU | chrF | COMET | Estado |
|---|---|---|---|---|
| Español→Wolof | *(pendiente)* | *(pendiente)* | *(pendiente)* | Modelo listo |
| Wolof→Español | *(pendiente)* | *(pendiente)* | *(pendiente)* | Modelo listo |
| Español→Fula | - | - | - | Sin datos |
