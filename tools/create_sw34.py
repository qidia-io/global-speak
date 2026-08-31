#!/usr/bin/env python3
"""Crea issue SW.3.4 (adopción de design skills de Emil Kowalski) con todos los campos del board."""
import json, subprocess, sys

REPO = "qidia-io/global-speak"
BOARD = "PVT_kwHOENGz784Bh_XW"

FIELDS = {
    "accion": "PVTF_lAHOENGz784Bh_XWzhg6ZXc",
    "orden": "PVTF_lAHOENGz784Bh_XWzhg6ZXg",
    "agente": "PVTSSF_lAHOENGz784Bh_XWzhg6ZbE",
    "estado": "PVTSSF_lAHOENGz784Bh_XWzhg5D6Q",
    "start": "PVTF_lAHOENGz784Bh_XWzhg6xjU",
    "end": "PVTF_lAHOENGz784Bh_XWzhg6xjY",
    "fase": "PVTSSF_lAHOENGz784Bh_XWzhg6x0g",
    "fecha_est": "PVTF_lAHOENGz784Bh_XWzhg5CjU",
}
# opciones
OPT = {
    "agente_mbok": "1c8dbf64",
    "estado_ready": "a67b4bb6",
    "fase_sw": "b51cde75",
    "milestone_sw": "MI_kwDOTPmVes4BDAu1",
}

def gh(query, **kw):
    cmd = ["gh", "api", "graphql", "-f", "query=%s" % query]
    for k, v in kw.items():
        cmd += ["-F", "%s=%s" % (k, v)]
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode != 0:
        print("ERR:", r.stderr[:500]); sys.exit(1)
    return json.loads(r.stdout)

TITLE = "SW.3.4 · Adoptar estándares de diseño/animation de Emil Kowalski (emil-design)"
BODY = """## Objetivo
Adoptar la doctrina de diseño de [Emil Kowalski](https://github.com/emilkowalski/skills) (animations.dev, autor de vaul/sonner, co-creador de shadcn/ui) para elevar el acabado de la app por encima del "AI slop".

## Contexto
- Repo de skills estudiado: https://github.com/emilkowalski/skills (15 skills, licencia MIT)
- Doctrine sintetizada e instalada como skill `emil-design` en Hermes (con 18 referencias: emil-design-eng, apple-design, animate, animate-expo, review-animations, improve-animations, find-animation-opportunities, pick-ui-library, prototype, animation-vocabulary, ask-sonner + STANDARDS/AUDIT/PLAN-TEMPLATE/PICKER)
- La app (Vite + React + shadcn/ui + Tailwind + Capacitor) YA usa el stack recomendado: sonner, vaul, cmdk, framer-motion, cva, clsx, next-themes, input-otp, recharts ✅

## Auditoría inicial (componentes custom, sep-2026)
| Componente | Hallazgo |
|---|---|
| RecordButton | ✅ whileTap scale(0.95) correcto; shadow-button-primary |
| ModeCard | ⚠️ `transition-all duration-300` → especificar `transform` + `duration-200` |
| VoiceTile | ⚠️ `transition-all` → idem; verificar origin |
| LanguageSelector/HistoryPanel/HeroBanner/FeatureBlock | ✅ entradas fade+y con framer-motion; verificar `scale(0)` no usado |

## Alcance
1. **Tokens de movimiento** en tailwind: `--ease-out: cubic-bezier(0.23,1,0.32,1)`, `--ease-in-out: cubic-bezier(0.77,0,0.175,1)`, duraciones 100–300ms
2. **Eliminar anti-patrones**: `transition-all`, `ease-in`, `scale(0)`, duraciones >300ms, hovers sin gate `(hover:hover)` en touch
3. **Press feedback universal** en botones/items interactivos (scale 0.95–0.98, 100–160ms)
4. **Origin-aware** en popovers/dropdowns (transform-origin del trigger)
5. **Sonner**: configurar a medida (posición, duración, tema) — ya instalado
6. **Reduced motion**: `prefers-reduced-motion` → crossfades
7. Pasar componentes por la checklist de la skill `emil-design` antes de dar por bueno

## Criterio de aceptación
- Checklist de la skill `emil-design` verde en todos los componentes custom
- Sin `transition-all`, sin `ease-in`, sin `scale(0)` en el codebase de la app
- Press feedback en el 100% de elementos interactivos
- Reduced-motion respetado
- Referencias: docs/DESIGN_GUIDE.md (doctrina + tokens + anti-patrones)

## Agente
mbok (frontend/app). Nemrod revisa con la skill `emil-design` (checklist + formato Before/After/Why).
"""

# 1. idempotente: buscar issue existente por título
SEARCH = "SW.3.4 · Adoptar estándares"
r = gh('query($q: String!) { search(query: $q, type: ISSUE, first: 5) { nodes { ... on Issue { number id title } } } }', q='repo:qidia-io/global-speak "%s" in:title' % SEARCH)
found = [n for n in r["data"]["search"]["nodes"] if n and n.get("title", "").startswith("SW.3.4")]
if found:
    issue = found[0]
    num = issue["number"]
    print("Issue #%d ya existe (idempotente)" % num)
else:
    r = gh('mutation($t: String!, $b: String!) { c: createIssue(input: { repositoryId: "R_kgDOTPmVeg", title: $t, body: $b }) { issue { number id } } }', t=TITLE, b=BODY)
    issue = r["data"]["c"]["issue"]
    num = issue["number"]
    print("Issue #%d creado" % num)

# 2. añadir al board si no está
item_id = None
r = gh('query($p: ID!) { node(id: $p) { ... on ProjectV2 { items(first: 100) { nodes { id content { ... on Issue { number } } } } } } }', p=BOARD)
for it in r["data"]["node"]["items"]["nodes"]:
    if it["content"] and it["content"].get("number") == num:
        item_id = it["id"]
        print("Ya está en el board: %s" % item_id)
        break
if not item_id:
    r = gh('mutation($p: ID!, $c: ID!) { a: addProjectV2ItemById(input: { projectId: $p, contentId: $c }) { item { id } } }', p=BOARD, c=issue["id"])
    item_id = r["data"]["a"]["item"]["id"]
    print("Añadido al board: %s" % item_id)

# 3. milestone (Software) — vía REST (GraphQL no acepta milestone en ProjectV2FieldValue)
r = subprocess.run(["gh", "api", "-X", "PATCH", "repos/qidia-io/global-speak/issues/%d" % num, "-f", "milestone=6", "--jq", ".milestone.title"], capture_output=True, text=True)
print("Milestone Software:", r.stdout.strip() if r.returncode == 0 else "FAIL " + r.stderr[:200])

# 4. campos
def set_field(field, value, kind):
    if kind == "text":
        val = '{ text: %s }' % json.dumps(value)
    elif kind == "number":
        val = '{ number: %s }' % value
    elif kind == "ss":
        val = '{ singleSelectOptionId: "%s" }' % value
    elif kind == "date":
        val = '{ date: "%s" }' % value
    q = 'mutation($p: ID!, $i: ID!, $f: ID!) { u: updateProjectV2ItemFieldValue(input: { projectId: $p, itemId: $i, fieldId: $f, value: %s }) { projectV2Item { id } } }' % val
    r = gh(q, p=BOARD, i=item_id, f=field)
    return bool(r.get("data", {}).get("u"))

print("Acción SW.3.4:", "OK" if set_field(FIELDS["accion"], "SW.3.4", "text") else "FAIL")
print("Orden 637:", "OK" if set_field(FIELDS["orden"], 637, "number") else "FAIL")
print("Agente mbok:", "OK" if set_field(FIELDS["agente"], OPT["agente_mbok"], "ss") else "FAIL")
print("Estado Ready:", "OK" if set_field(FIELDS["estado"], OPT["estado_ready"], "ss") else "FAIL")
print("Fase SW:", "OK" if set_field(FIELDS["fase"], OPT["fase_sw"], "ss") else "FAIL")
print("Start 2026-09-01:", "OK" if set_field(FIELDS["start"], "2026-09-01", "date") else "FAIL")
print("End 2026-09-27:", "OK" if set_field(FIELDS["end"], "2026-09-27", "date") else "FAIL")
print("Fecha est 2026-09-20:", "OK" if set_field(FIELDS["fecha_est"], "2026-09-20", "date") else "FAIL")
