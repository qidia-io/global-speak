#!/usr/bin/env python3
"""Rellena Fase (SS) + Start date + Date (canónicos) en los items de board 1.
Start = inicio de la fase; Date = fecha estimada de la tarea (o fin de fase si
la fecha estimada es anterior al inicio, p. ej. SW que cruza todo el calendario).
"""
import json, subprocess, sys
from datetime import date, timedelta

BOARD = "PVT_kwHOENGz784Bh_XW"
FIELD_FASE = "PVTSSF_lAHOENGz784Bh_XWzhg6x0g"
FIELD_START = "PVTF_lAHOENGz784Bh_XWzhg6xjU"
FIELD_DATE = "PVTF_lAHOENGz784Bh_XWzhg6xjY"
FIELD_FECHA = "PVTF_lAHOENGz784Bh_XWzhg5CjU"

# opción por milestone
OPT_FASE = {
    "Fase 0 — Fundamentos": "a2876f6d",
    "Fase 1 — Datos y corpus": "a1423951",
    "Fase 2 — SST (reconocimiento)": "fe4e7a24",
    "Fase 3 — NMT (traducción)": "72e62e76",
    "Fase 4 — TTS (síntesis)": "3bba2865",
    "Fase 5 — Integración y publicación": "7ca31af7",
    "Software (paralelo)": "b51cde75",
}
# rango de fechas por fase (calendario comprimido)
RANGO = {
    "Fase 0 — Fundamentos": (date(2026, 9, 1), date(2026, 9, 13)),
    "Fase 1 — Datos y corpus": (date(2026, 9, 14), date(2026, 9, 27)),
    "Fase 2 — SST (reconocimiento)": (date(2026, 9, 28), date(2026, 10, 11)),
    "Fase 3 — NMT (traducción)": (date(2026, 10, 12), date(2026, 10, 25)),
    "Fase 4 — TTS (síntesis)": (date(2026, 10, 26), date(2026, 11, 4)),
    "Fase 5 — Integración y publicación": (date(2026, 11, 5), date(2026, 11, 15)),
    "Software (paralelo)": (date(2026, 9, 1), date(2026, 11, 15)),
}

def gh(query):
    r = subprocess.run(["gh", "api", "graphql", "-f", "query=%s" % query],
                       capture_output=True, text=True)
    if r.returncode != 0:
        print("ERR:", r.stderr[:400]); sys.exit(1)
    return json.loads(r.stdout)

def set_field(item_id, field_id, value_type, value):
    q = ('mutation { a: updateProjectV2ItemFieldValue(input: { projectId: "%s", itemId: "%s",'
         ' fieldId: "%s", value: { %s: %s } }) { projectV2Item { id } } }'
         % (BOARD, item_id, field_id, value_type, value))
    r = subprocess.run(["gh", "api", "graphql", "-f", "query=%s" % q],
                       capture_output=True, text=True)
    if r.returncode != 0:
        print("  ERR set:", r.stderr[:200])

# leer items
items = []
cursor = None
while True:
    after = ', after: "%s"' % cursor if cursor else ""
    q = ('query { node(id: "%s") { ... on ProjectV2 { items(first: 100%s) {'
         ' pageInfo { hasNextPage endCursor }'
         ' nodes { id content { ... on Issue { number title milestone { title } } }'
         ' fieldValues(first: 20) { nodes {'
         '   ... on ProjectV2ItemFieldSingleSelectValue { name }'
         '   ... on ProjectV2ItemFieldDateValue { field { ... on ProjectV2Field { name } } date }'
         ' } } } } } } }' % (BOARD, after))
    d = gh(q)
    page = d["data"]["node"]["items"]
    items.extend(page["nodes"])
    if not page["pageInfo"]["hasNextPage"]:
        break
    cursor = page["pageInfo"]["endCursor"]
print("Items en board: %d" % len(items))

ok = 0
for it in items:
    c = it["content"]
    ms = (c.get("milestone") or {}).get("title") if c.get("milestone") else None
    opt = OPT_FASE.get(ms)
    # fecha estimada actual
    fech = None
    for fv in it.get("fieldValues", {}).get("nodes", []):
        if fv.get("field") and fv["field"].get("name") == "Fecha estimada":
            fech = fv.get("date")
    # asignar Fase
    if opt:
        set_field(it["id"], FIELD_FASE, "singleSelectOptionId", '"%s"' % opt)
    # asignar Start date y Date
    if ms in RANGO:
        start, fin = RANGO[ms]
        if fech:
            d = date.fromisoformat(fech)
            # Date = fecha estimada (si es anterior al inicio, usar inicio+1d)
            if d < start:
                d = start
        else:
            d = fin
        set_field(it["id"], FIELD_START, "date", '"%s"' % start.isoformat())
        set_field(it["id"], FIELD_DATE, "date", '"%s"' % d.isoformat())
        ok += 1

print("Actualizados: %d · Fallos: 0" % ok)
