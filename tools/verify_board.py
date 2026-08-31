#!/usr/bin/env python3
import json, subprocess
from collections import Counter

BOARD = "PVT_kwHOENGz784Bh_XW"

def gh(query):
    r = subprocess.run(["gh", "api", "graphql", "-f", f"query={query}"],
                       capture_output=True, text=True)
    if r.returncode != 0:
        print("ERR:", r.stderr[:300]); return None
    return json.loads(r.stdout)

items = []
cursor = None
while True:
    after = ', after: "%s"' % cursor if cursor else ""
    q = ('query { node(id: "%s") { ... on ProjectV2 { items(first: 100%s) {'
         ' pageInfo { hasNextPage endCursor }'
         ' nodes { id content { ... on Issue { number title milestone { title } } } } } } } }'
         % (BOARD, after))
    d = gh(q)
    if d is None:
        break
    page = d["data"]["node"]["items"]
    items.extend(page["nodes"])
    if not page["pageInfo"]["hasNextPage"]:
        break
    cursor = page["pageInfo"]["endCursor"]

ms = Counter()
for it in items:
    c = it["content"]
    m = (c.get("milestone") or {}).get("title") if c.get("milestone") else "SIN MILESTONE"
    ms[m] += 1

print("TOTAL: %d items" % len(items))
for m, n in ms.most_common():
    print("  %s: %d" % (m, n))

nums = [it["content"]["number"] for it in items]
print("\n#33 en board? %s" % ("SÍ (ERROR)" if 33 in nums else "NO (correcto)"))
