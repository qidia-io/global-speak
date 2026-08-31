#!/usr/bin/env python3
"""Inspecciona el orden de vistas del board 1 y su configuración visible."""
import json, subprocess

BOARD = "PVT_kwHOENGz784Bh_XW"

def gh(query):
    r = subprocess.run(["gh", "api", "graphql", "-f", "query=%s" % query],
                       capture_output=True, text=True)
    if r.returncode != 0:
        print("ERR:", r.stderr[:400]); return None
    return json.loads(r.stdout)

q = '''query { node(id: "%s") { ... on ProjectV2 { views(first: 10) { nodes {
  id name layout
} } } } }''' % BOARD
d = gh(q)
if d:
    for i, v in enumerate(d["data"]["node"]["views"]["nodes"], 1):
        print("vista %d: %s  %s  %s" % (i, v["name"], v["layout"], v["id"]))
