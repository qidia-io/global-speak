#!/usr/bin/env python3
"""Compara campos de fecha entre board 1 (Detalle) y board 2 (Fases)."""
import json, subprocess

BOARD1 = "PVT_kwHOENGz784Bh_XW"
BOARD2 = "PVT_kwHOENGz784Bh_iW"

def gh(query):
    r = subprocess.run(["gh", "api", "graphql", "-f", "query=%s" % query],
                       capture_output=True, text=True)
    if r.returncode != 0:
        print("ERR:", r.stderr[:400]); return None
    return json.loads(r.stdout)

for bname, bid in (("BOARD 1 (Detalle)", BOARD1), ("BOARD 2 (Fases)", BOARD2)):
    q = '''query { node(id: "%s") { ... on ProjectV2 { fields(first: 50) { nodes {
      ... on ProjectV2Field { id name dataType }
    } } } } }''' % bid
    d = gh(q)
    if not d:
        continue
    print("=== %s ===" % bname)
    for f in d["data"]["node"]["fields"]["nodes"]:
        if f.get("dataType"):
            mark = " <-- CANÓNICO" if f["name"] in ("Start date", "Date") else ""
            print("  %-20s %-42s %s%s" % (f["name"], f["id"], f["dataType"], mark))
