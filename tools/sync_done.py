#!/usr/bin/env python3
"""
Watchdog global-speak: issues CLOSED en GitHub -> "Done" en board 1 + documenta commits.
Uso: python3 sync_done.py [--quiet]
  --quiet: solo imprime si hay cambios (para cron no_agent -> silencio si nada).
Salida con cambios: lineas por item movido + commits documentados.
"""
import json, subprocess, sys

BOARD = "PVT_kwHOENGz784Bh_XW"
FIELD_STATUS = "PVTSSF_lAHOENGz784Bh_XWzhg5D6Q"
OPT_DONE = "6bec6106"
FIELD_COMMITS = "PVTF_lAHOENGz784Bh_XWzhg7zbc"
REPO = "qidia-io/global-speak"

QUIET = "--quiet" in sys.argv

def gh(query, **kw):
    cmd = ["gh", "api", "graphql", "-f", "query=%s" % query]
    for k, v in kw.items():
        cmd += ["-F", "%s=%s" % (k, v)]
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode != 0:
        print("ERR:", r.stderr[:300], file=sys.stderr)
        sys.exit(1)
    return json.loads(r.stdout)

def gh_cmd(*args):
    r = subprocess.run(["gh"] + list(args), capture_output=True, text=True)
    if r.returncode != 0:
        print("ERR:", r.stderr[:300], file=sys.stderr)
        sys.exit(1)
    return r.stdout

def get_board_items():
    """item_id -> (numero issue, estado board, commits_actuales)"""
    items, cursor = {}, None
    while True:
        q = '''query($c: String) {
          node(id: "%s") { ... on ProjectV2 {
            items(first: 100, after: $c) { pageInfo { hasNextPage endCursor }
              nodes {
                id
                content { ... on Issue { number state } }
                fieldValues(first: 15) {
                  nodes {
                    ... on ProjectV2ItemFieldSingleSelectValue { name
                      field { ... on ProjectV2SingleSelectField { id } } }
                    ... on ProjectV2ItemFieldTextValue { text
                      field { ... on ProjectV2FieldCommon { id } } }
                  }
                }
              } } } } }''' % BOARD
        d = gh(q, c=cursor or "null")
        ni = d["data"]["node"]["items"]
        for it in ni["nodes"]:
            st, commits = None, ""
            for fv in it["fieldValues"]["nodes"]:
                fid = (fv.get("field") or {}).get("id")
                if fid == FIELD_STATUS:
                    st = fv.get("name")
                elif fid == FIELD_COMMITS:
                    commits = fv.get("text") or ""
            if it["content"] and it["content"].get("number"):
                items[it["id"]] = (it["content"]["number"], st, commits)
        if not ni["pageInfo"]["hasNextPage"]:
            break
        cursor = ni["pageInfo"]["endCursor"]
    return items

def get_issue_commits(num):
    """Commits que referencian el issue #num via REST timeline (referenced/cross-referenced)."""
    out = []
    try:
        r = subprocess.run(
            ["gh", "api", "repos/qidia-io/global-speak/issues/%d/timeline" % num,
             "--paginate", "--jq", ".[] | select(.event==\"referenced\" or .event==\"cross-referenced\") | .commit_id // .source.commit_id // empty"],
            capture_output=True, text=True, timeout=60)
        if r.returncode == 0 and r.stdout.strip():
            for line in r.stdout.splitlines():
                line = line.strip()
                if line:
                    out.append(line)
    except subprocess.TimeoutExpired:
        pass
    # resolver SHA -> mensaje corto
    resolved = []
    for oid in out:
        rr = subprocess.run(
            ["gh", "api", "repos/qidia-io/global-speak/commits/%s" % oid,
             "--jq", ".sha[0:7] + \" \" + (.commit.message | split(\"\\n\")[0])"],
            capture_output=True, text=True, timeout=30)
        if rr.returncode == 0 and rr.stdout.strip():
            resolved.append(rr.stdout.strip())
    # dedupe manteniendo orden
    seen, uniq = set(), []
    for line in resolved:
        if line not in seen:
            seen.add(line); uniq.append(line)
    return uniq

def set_commits_field(item_id, text):
    q = '''mutation {
      u: updateProjectV2ItemFieldValue(input: {
        projectId: "%s", itemId: "%s", fieldId: "%s",
        value: { text: %s }
      }) { projectV2Item { id } } }''' % (BOARD, item_id, FIELD_COMMITS, json.dumps(text))
    r = gh(q)
    return bool(r.get("data", {}).get("u"))

def set_done(item_id):
    q = '''mutation {
      u: updateProjectV2ItemFieldValue(input: {
        projectId: "%s", itemId: "%s", fieldId: "%s",
        value: { singleSelectOptionId: "%s" }
      }) { projectV2Item { id } } }''' % (BOARD, item_id, FIELD_STATUS, OPT_DONE)
    r = gh(q)
    return bool(r.get("data", {}).get("u"))

def main():
    items = get_board_items()

    closed = set()
    out = gh_cmd("issue", "list", "--repo", REPO, "--state", "closed",
                 "--limit", "200", "--json", "number")
    for it in json.loads(out):
        closed.add(it["number"])

    actions = []
    for iid, (num, st, commits_old) in items.items():
        if num not in closed:
            continue
        if st != "Done":
            actions.append(("DONE", iid, num))
        commits = get_issue_commits(num)
        if commits and "\n".join(commits) != commits_old:
            actions.append(("COMMITS", iid, num, commits))

    if not actions:
        if not QUIET:
            print("Sin cambios: todo sincronizado.")
        return

    for a in actions:
        if a[0] == "DONE":
            _, iid, num = a
            ok = set_done(iid)
            print("%s #%d -> Done" % ("OK" if ok else "FAIL", num))
        else:
            _, iid, num, commits = a
            ok = set_commits_field(iid, "\n".join(commits))
            print("%s #%d Commits documentados (%d):" % ("OK" if ok else "FAIL", num, len(commits)))
            for c in commits:
                print("   %s" % c)

    print("Acciones: %d" % len(actions))

if __name__ == "__main__":
    main()
