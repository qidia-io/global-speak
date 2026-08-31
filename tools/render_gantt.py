#!/usr/bin/env python3
"""Genera PNG del Gantt de board 1 con colores por fase (PIL puro, sin deps)."""
import json, subprocess, sys
from datetime import date, datetime
from PIL import Image, ImageDraw, ImageFont

BOARD = "PVT_kwHOENGz784Bh_XW"
OUT = "/root/proyecto/repo/docs/gantt_global_speak.png"

COLORES_FASE = {
    "F0": (181, 49, 78),    # granate
    "F1": (29, 125, 219),   # azul
    "F2": (14, 138, 22),    # verde
    "F3": (251, 202, 4),    # amarillo
    "F4": (217, 63, 11),    # naranja
    "F5": (112, 87, 255),   # violeta
    "SW": (83, 20, 231),    # púrpura
}

def gh(query):
    r = subprocess.run(["gh", "api", "graphql", "-f", "query=%s" % query],
                       capture_output=True, text=True)
    if r.returncode != 0:
        print("ERR:", r.stderr[:400]); sys.exit(1)
    return json.loads(r.stdout)

# leer items con fase + fechas
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

FASE_MS = {
    "Fase 0 — Fundamentos": "F0", "Fase 1 — Datos y corpus": "F1",
    "Fase 2 — SST (reconocimiento)": "F2", "Fase 3 — NMT (traducción)": "F3",
    "Fase 4 — TTS (síntesis)": "F4", "Fase 5 — Integración y publicación": "F5",
    "Software (paralelo)": "SW",
}
rows = []
for it in items:
    c = it["content"]
    ms = (c.get("milestone") or {}).get("title") if c.get("milestone") else None
    fase = FASE_MS.get(ms, "?")
    start = date_ = None
    for fv in it.get("fieldValues", {}).get("nodes", []):
        if fv.get("field"):
            n = fv["field"].get("name")
            if n == "Start date" and fv.get("date"):
                start = date.fromisoformat(fv["date"])
            if n == "Date" and fv.get("date"):
                date_ = date.fromisoformat(fv["date"])
    if not start or not date_:
        continue
    rows.append({"num": c["number"], "fase": fase, "start": start, "end": date_})

rows.sort(key=lambda r: (r["start"], r["num"]))
D0, D1 = date(2026, 9, 1), date(2026, 11, 15)
SPAN = (D1 - D0).days + 1

# ── layout ──
W, H = 2200, 1200
M_L, M_R, M_T, M_B = 380, 40, 90, 90
CHART_W = W - M_L - M_R
CHART_H = H - M_T - M_B
ROW_H = CHART_H / max(len(rows), 1)

img = Image.new("RGB", (W, H), (13, 17, 23))
d = ImageDraw.Draw(img)
try:
    f_big = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 34)
    f_mid = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 22)
    f_sm = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 17)
except Exception:
    f_big = f_mid = f_sm = ImageFont.load_default()

d.text((M_L, 22), "global-speak · Gantt de ejecución (152 tareas) · 01-sep → 15-nov-2026",
       fill=(240, 240, 240), font=f_big)

def x(date_):
    return M_L + (date_ - D0).days / SPAN * CHART_W

# grid mensual
for mday in [date(2026, 9, 1), date(2026, 9, 15), date(2026, 10, 1), date(2026, 10, 15),
             date(2026, 11, 1), date(2026, 11, 15)]:
    xx = x(mday)
    d.line([(xx, M_T), (xx, M_T + CHART_H)], fill=(60, 66, 78), width=1)
    d.text((xx - 20, M_T + CHART_H + 8), mday.strftime("%d %b"), fill=(200, 205, 215), font=f_mid)

# barras
for i, r in enumerate(rows):
    y = M_T + i * ROW_H
    col = COLORES_FASE.get(r["fase"], (150, 150, 150))
    x0, x1 = x(r["start"]), x(r["end"])
    if x1 - x0 < 4:
        x1 = x0 + 4
    d.rectangle([x0, y + 2, x1, y + ROW_H - 3], fill=col, outline=(255, 255, 255, 180))
    d.text((M_L - 14, y + 2), "#%s" % r["num"], anchor="ra", fill=(200, 205, 215), font=f_sm)

# leyenda de fases
ly = M_T + CHART_H - 60
for i, (k, v) in enumerate(COLORES_FASE.items()):
    lx = M_L + i * 280
    d.rectangle([lx, ly, lx + 26, ly + 20], fill=v)
    d.text((lx + 34, ly), k, fill=(240, 240, 240), font=f_mid)

img.save(OUT)
print("PNG guardado: %s (%dx%d, %d filas)" % (OUT, W, H, len(rows)))
