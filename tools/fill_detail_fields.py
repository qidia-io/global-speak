#!/usr/bin/env python3
"""Rellena campos Acción / Orden / Agente principal en board 1 (Detalle)."""
import json, subprocess, re, sys

BOARD = "PVT_kwHOENGz784Bh_XW"
FIELD_ACCION = "PVTF_lAHOENGz784Bh_XWzhg6ZXc"
FIELD_ORDEN = "PVTF_lAHOENGz784Bh_XWzhg6ZXg"
FIELD_AGENTE = "PVTSSF_lAHOENGz784Bh_XWzhg6ZbE"
OPT_AGENTE = {"nemrod": "f891313b", "echo": "380cbff6", "janus": "e9784790",
              "mbok": "1c8dbf64", "sankofa": "de36e0d2", "griot": "bac6c550"}

def gh(query):
    r = subprocess.run(["gh", "api", "graphql", "-f", f"query={query}"],
                       capture_output=True, text=True)
    if r.returncode != 0:
        print("ERR:", r.stderr[:500]); sys.exit(1)
    return json.loads(r.stdout)

def set_field(item_id, field_id, value_type, value):
    q = f'mutation {{ a: updateProjectV2ItemFieldValue(input: {{ projectId: "{BOARD}", itemId: "{item_id}", fieldId: "{field_id}", value: {{ {value_type}: {value} }} }}) {{ projectV2Item {{ id }} }} }}'
    r = subprocess.run(["gh", "api", "graphql", "-f", f"query={q}"],
                       capture_output=True, text=True)
    return r.returncode == 0

# 1. Leer items del board (paginado: GitHub limita first a 100)
items = []
cursor = None
while True:
    after = f', after: "{cursor}"' if cursor else ""
    q = f'''query {{ node(id: "{BOARD}") {{ ... on ProjectV2 {{ items(first: 100{after}) {{
      pageInfo {{ hasNextPage endCursor }}
      nodes {{ id content {{ ... on Issue {{ number title milestone {{ title }} labels(first: 10) {{ nodes {{ name }} }} }} }} }}
    }} }} }} }}'''
    data = gh(q)
    page = data["data"]["node"]["items"]
    items.extend(page["nodes"])
    if not page["pageInfo"]["hasNextPage"]:
        break
    cursor = page["pageInfo"]["endCursor"]
print(f"Items en board: {len(items)}")

# 2. Ordenar por milestone (fase) y número de issue
MS_ORDER = {"Fase 0 — Fundamentos": 0, "Fase 1 — Datos y corpus": 1,
            "Fase 2 — SST (reconocimiento)": 2, "Fase 3 — NMT (traducción)": 3, "Fase 4 — TTS (síntesis)": 4,
            "Fase 5 — Integración y publicación": 5, "Software (paralelo)": 6}
for it in items:
    c = it["content"]
    ms = (c.get("milestone") or {}).get("title") if c.get("milestone") else None
    it["ms_key"] = MS_ORDER.get(ms, 9)
    it["num"] = c["number"]
items.sort(key=lambda x: (x["ms_key"], x["num"]))

# 3. Asignar campos
pat_prefijo = re.compile(r"^(F\d+(?:\.\d+)*|CP-[A-Z0-9·.\-]+)\s*[·]\s*")
pos_por_ms = {}
updates = []
for it in items:
    c = it["content"]
    title = c["title"]
    ms = (c.get("milestone") or {}).get("title") if c.get("milestone") else None
    labels = [n["name"] for n in (c.get("labels") or {}).get("nodes", [])]

    # Acción: prefijo del título si existe, si no derivar de la fase
    pos_por_ms[it["ms_key"]] = pos_por_ms.get(it["ms_key"], 0) + 1
    pos = pos_por_ms[it["ms_key"]]
    m = pat_prefijo.match(title)
    if m:
        accion = m.group(1)
    else:
        if ms is None:
            accion = f"T{c['number']}"
        else:
            abbr = {0: "F0", 1: "F1", 2: "F2", 3: "F3", 4: "F4", 5: "F5", 6: "SW", 9: "OTRO"}[it["ms_key"]]
            accion = f"{abbr}.{90 + pos}"

    # Orden: fase*100 + posición dentro de fase
    orden = it["ms_key"] * 100 + pos

    # Agente principal: primer label agente:*
    agente = None
    for lb in labels:
        if lb.startswith("agente:"):
            agente = lb.split(":", 1)[1]
            break
    updates.append((it, accion, orden, agente))

# 4. Aplicar
ok = fail = 0
for it, accion, orden, agente in updates:
    c = it["content"]
    iid = it["id"]
    a1 = set_field(iid, FIELD_ACCION, "text", json.dumps(accion))
    a2 = set_field(iid, FIELD_ORDEN, "number", str(orden))
    a3 = False
    if agente and agente in OPT_AGENTE:
        a3 = set_field(iid, FIELD_AGENTE, "singleSelectOptionId", json.dumps(OPT_AGENTE[agente]))
    if a1 and a2:
        ok += 1
        print(f"  ✅ #{c['number']:<4} {accion:<10} orden={orden:<5} agente={agente or '-'}")
    else:
        fail += 1
        print(f"  ❌ #{c['number']} {accion}")

print(f"\nActualizados: {ok} · Fallos: {fail}")
