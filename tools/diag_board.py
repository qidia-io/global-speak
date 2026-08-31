#!/usr/bin/env python3
"""Diagnóstico completo del board 1: vistas, campos canónicos, cobertura de fechas."""
import json, subprocess, sys
from collections import Counter

BOARD = "PVT_kwHOENGz784Bh_XW"

def gh(query):
    r = subprocess.run(["gh", "api", "graphql", "-f", "query=%s" % query],
                       capture_output=True, text=True)
    if r.returncode != 0:
        print("ERR:", r.stderr[:400]); sys.exit(1)
    return json.loads(r.stdout)

# 1. Vistas del board
q = '''query { node(id: "%s") { ... on ProjectV2 { views(first: 10) { nodes { id name layout } } } } }''' % BOARD
d = gh(q)
print("=== VISTAS ===")
for v in d["data"]["node"]["views"]["nodes"]:
    print("  %-28s %-22s %s" % (v["name"], v["id"], v["layout"]))

# 2. Campos
q = '''query { node(id: "%s") { ... on ProjectV2 { fields(first: 50) { nodes {
  ... on ProjectV2Field { id name dataType }
  ... on ProjectV2SingleSelectField { id name }
} } } } }''' % BOARD
d = gh(q)
print("\n=== CAMPOS ===")
for f in d["data"]["node"]["fields"]["nodes"]:
    if f.get("dataType"):
        print("  %-22s %s (%s)" % (f["name"], f["id"], f["dataType"]))

# 3. Items con fechas
items = []
cursor = None
while True:
    after = ', after: "%s"' % cursor if cursor else ""
    q = ('query { node(id: "%s") { ... on ProjectV2 { items(first: 100%s) {'
         ' pageInfo { hasNextPage endCursor }'
         ' nodes { id content { ... on Issue { number } }'
         ' fieldValues(first: 30) { nodes {'
         '   ... on ProjectV2ItemFieldDateValue { field { ... on ProjectV2Field { name } } date }'
         ' } } } } } } }' % (BOARD, after))
    d = gh(q)
    page = d["data"]["node"]["items"]
    items.extend(page["nodes"])
    if not page["pageInfo"]["hasNextPage"]:
        break
    cursor = page["pageInfo"]["endCursor"]

print("\n=== ITEMS: %d ===" % len(items))
n_start = n_date = 0
campos_vistos = Counter()
for it in items:
    seen = set()
    for fv in it.get("fieldValues", {}).get("nodes", []):
        n = fv["field"]["name"]
        seen.add(n)
        campos_vistos[n] += 1
        if n == "Start date" and fv.get("date"): n_start += 1
        if n == "Date" and fv.get("date"): n_date += 1
print("  con Start date: %d" % n_start)
print("  con Date: %d" % n_date)
print("  campos de fecha vistos en fieldValues: %s" % dict(campos_vistos))
