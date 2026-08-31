#!/usr/bin/env python3
"""Verifica Fase + Start date + Date en board 1 (muestra ejemplos de cada fase)."""
import json, subprocess, sys
from collections import Counter, defaultdict

BOARD = "PVT_kwHOENGz784Bh_XW"

def gh(query):
    r = subprocess.run(["gh", "api", "graphql", "-f", "query=%s" % query],
                       capture_output=True, text=True)
    if r.returncode != 0:
        print("ERR:", r.stderr[:400]); sys.exit(1)
    return json.loads(r.stdout)

items = []
cursor = None
while True:
    after = ', after: "%s"' % cursor if cursor else ""
    q = ('query { node(id: "%s") { ... on ProjectV2 { items(first: 100%s) {'
         ' pageInfo { hasNextPage endCursor }'
         ' nodes { id content { ... on Issue { number title milestone { title } } }'
         ' fieldValues(first: 30) { nodes {'
         '   ... on ProjectV2ItemFieldSingleSelectValue { name }'
         '   ... on ProjectV2ItemFieldDateValue { field { ... on ProjectV2Field { name } } date }'
         ' } } } } } } }' % (BOARD, after))
    d = gh(q)
    page = d["data"]["node"]["items"]
    items.extend(page["nodes"])
    if not page["pageInfo"]["hasNextPage"]:
        break
    cursor = page["pageInfo"]["endCursor"]

stats = defaultdict(lambda: {"total": 0, "fase": 0, "start": 0, "date": 0})
for it in items:
    c = it["content"]
    ms = (c.get("milestone") or {}).get("title") if c.get("milestone") else "SIN MS"
    s = stats[ms]
    s["total"] += 1
    fase = start = date_ = False
    for fv in it.get("fieldValues", {}).get("nodes", []):
        if fv.get("name") and fv["name"].startswith(("F0", "F1", "F2", "F3", "F4", "F5", "SW")):
            fase = True
        if fv.get("field"):
            n = fv["field"].get("name")
            if n == "Start date" and fv.get("date"):
                start = True
            if n == "Date" and fv.get("date"):
                date_ = True
    if fase: s["fase"] += 1
    if start: s["start"] += 1
    if date_: s["date"] += 1

print("=== Cobertura por milestone ===")
for ms, s in sorted(stats.items()):
    print("%-38s total=%3d  fase=%3d  start=%3d  date=%3d" % (
        ms, s["total"], s["fase"], s["start"], s["date"]))

print("\n=== Ejemplos (3 por fase) ===")
shown = Counter()
for it in items:
    c = it["content"]
    ms = (c.get("milestone") or {}).get("title") if c.get("milestone") else "SIN MS"
    if shown[ms] >= 3:
        continue
    vals = {}
    for fv in it.get("fieldValues", {}).get("nodes", []):
        if fv.get("name"):
            vals["fase"] = fv["name"]
        if fv.get("field"):
            n = fv["field"].get("name")
            if n in ("Start date", "Date") and fv.get("date"):
                vals[n] = fv["date"]
    print("#%-4d %-28s fase=%-16s start=%-12s date=%s" % (
        c["number"], ms[:28], vals.get("fase", "-"), vals.get("Start date", "-"), vals.get("Date", "-")))
    shown[ms] += 1
