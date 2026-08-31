#!/usr/bin/env python3
"""Cierra issue #2 en GitHub y lo mueve a Done en el board."""
import json, subprocess, sys

BOARD = "PVT_kwHOENGz784Bh_XW"
FIELD_STATUS = "PVTSSF_lAHOENGz784Bh_XWzhg5D6Q"
OPT_DONE = "6bec6106"
ISSUE = 2

def gh(query, **kw):
    cmd = ["gh", "api", "graphql", "-f", "query=%s" % query]
    for k, v in kw.items():
        cmd += ["-F", "%s=%s" % (k, v)]
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode != 0:
        print("ERR:", r.stderr[:500]); sys.exit(1)
    return json.loads(r.stdout)

# 1. Encontrar el item del board del issue #2
items, cursor = [], None
while True:
    q = '''query($c: String) {
      node(id: "%s") { ... on ProjectV2 {
        items(first: 100, after: $c) { pageInfo { hasNextPage endCursor }
          nodes { id content { ... on Issue { number } } } } } } }''' % BOARD
    d = gh(q, c=cursor or "null")
    ni = d["data"]["node"]["items"]
    for it in ni["nodes"]:
        if it["content"] and it["content"].get("number") == ISSUE:
            items.append(it["id"])
    if not ni["pageInfo"]["hasNextPage"]:
        break
    cursor = ni["pageInfo"]["endCursor"]

if not items:
    print("Issue #%d NO está en el board" % ISSUE); sys.exit(1)

item_id = items[0]
print("Item del board para #%d: %s" % (ISSUE, item_id))

# 2. Estado -> Done en el board
q = '''mutation {
  u: updateProjectV2ItemFieldValue(input: {
    projectId: "%s", itemId: "%s", fieldId: "%s",
    value: { singleSelectOptionId: "%s" }
  }) { projectV2Item { id } } }''' % (BOARD, item_id, FIELD_STATUS, OPT_DONE)
r = gh(q)
print("Board -> Done:", "OK" if r.get("data", {}).get("u") else "FAIL")

# 3. Cerrar issue en GitHub
q = 'mutation { c: closeIssue(input: { issueId: "I_issue_%d" }) { issue { number state } } }' % ISSUE
r = gh(q)
print("GitHub close:", json.dumps(r.get("data", {}).get("c", r), ensure_ascii=False)[:200])
