#!/usr/bin/env python3
import json, subprocess

def gh(query):
    r = subprocess.run(["gh", "api", "graphql", "-f", "query=%s" % query],
                       capture_output=True, text=True)
    if r.returncode != 0:
        print("ERR:", r.stderr[:400]); return None
    return json.loads(r.stdout)

q = '''query {
  node(id: "PVT_kwHOENGz784Bh_XW") {
    ... on ProjectV2 {
      fields(first: 50) {
        nodes {
          ... on ProjectV2Field {
            id name dataType
          }
          ... on ProjectV2SingleSelectField {
            id name
            options { id name color }
          }
        }
      }
    }
  }
}'''
d = gh(q)
if d:
    for f in d["data"]["node"]["fields"]["nodes"]:
        if f.get("dataType"):
            print("%-22s %s  (%s)" % (f["name"], f["id"], f["dataType"]))
        else:
            opts = ", ".join("%s=%s" % (o["name"], o["color"]) for o in f["options"])
            print("%-22s %s  [SS] %s" % (f["name"], f["id"], opts))
