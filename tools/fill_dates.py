#!/usr/bin/env python3
"""Asigna Fecha estimada a los items del board 1 según calendario comprimido."""
import json, subprocess, sys, datetime

BOARD = "PVT_kwHOENGz784Bh_XW"
FIELD_FECHA = "PVTF_lAHOENGz784Bh_XWzhg5CjU"

def gh(query):
    r = subprocess.run(["gh", "api", "graphql", "-f", f"query={query}"],
                       capture_output=True, text=True)
    if r.returncode != 0:
        print("ERR:", r.stderr[:500]); sys.exit(1)
    return json.loads(r.stdout)

# Leer items del board (paginado)
items = []
cursor = None
while True:
    after = f', after: "{cursor}"' if cursor else ""
    q = f'''query {{ node(id: "{BOARD}") {{ ... on ProjectV2 {{ items(first: 100{after}) {{
      pageInfo {{ hasNextPage endCursor }}
      nodes {{ id content {{ ... on Issue {{ number title milestone {{ title }} }} }} }}
    }} }} }} }}'''
    data = gh(q)
    page = data["data"]["node"]["items"]
    items.extend(page["nodes"])
    if not page["pageInfo"]["hasNextPage"]:
        break
    cursor = page["pageInfo"]["endCursor"]

MS_ORDER = {"Fase 0 — Fundamentos": 0, "Fase 1 — Datos y corpus": 1,
            "Fase 2 — SST (reconocimiento)": 2, "Fase 3 — NMT (traducción)": 3, "Fase 4 — TTS (síntesis)": 4,
            "Fase 5 — Integración y publicación": 5, "Software (paralelo)": 6}
for it in items:
    c = it["content"]
    ms = (c.get("milestone") or {}).get("title") if c.get("milestone") else None
    it["ms_key"] = MS_ORDER.get(ms, 9)
    it["num"] = c["number"]
items.sort(key=lambda x: (x["ms_key"], x["num"]))

# Ventanas por fase (calendario comprimido)
RANGOS = {0: ("2026-09-01", "2026-09-13"), 1: ("2026-09-14", "2026-09-27"),
          2: ("2026-09-28", "2026-10-11"), 3: ("2026-10-12", "2026-10-25"),
          4: ("2026-10-26", "2026-11-04"), 5: ("2026-11-05", "2026-11-15"),
          6: ("2026-09-01", "2026-11-15"), 9: ("2026-09-01", "2026-11-15")}

def fecha_para(ms_key, idx, total):
    inicio, fin = RANGOS[ms_key]
    d0 = datetime.date.fromisoformat(inicio)
    d1 = datetime.date.fromisoformat(fin)
    span = (d1 - d0).days
    if total <= 1:
        d = d0
    else:
        d = d0 + datetime.timedelta(days=round(idx * span / (total - 1)))
    return d.isoformat()

# Contar por fase
counts = {}
for it in items:
    counts[it["ms_key"]] = counts.get(it["ms_key"], 0) + 1
seens = {}
ok = fail = 0
for it in items:
    seens[it["ms_key"]] = seens.get(it["ms_key"], 0) + 1
    fecha = fecha_para(it["ms_key"], seens[it["ms_key"]] - 1, counts[it["ms_key"]])
    q2 = f'mutation {{ a: updateProjectV2ItemFieldValue(input: {{ projectId: "{BOARD}", itemId: "{it["id"]}", fieldId: "{FIELD_FECHA}", value: {{ date: "{fecha}" }} }}) {{ projectV2Item {{ id }} }} }}'
    r = subprocess.run(["gh", "api", "graphql", "-f", f"query={q2}"],
                       capture_output=True, text=True)
    if r.returncode == 0:
        ok += 1
        print(f"  ✅ #{it['num']:<4} {fecha}")
    else:
        fail += 1
        print(f"  ❌ #{it['num']} {r.stderr[:200]}")

print(f"\nFechas asignadas: {ok} · Fallos: {fail}")
