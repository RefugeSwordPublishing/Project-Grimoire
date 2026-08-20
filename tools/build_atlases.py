#!/usr/bin/env python3
# Atlas compositor (correctness by construction). Pulls each material sheet's per-cell approved art
# from the tracker (Supabase asset_files) and stitches it into an ordered atlas so the physical cell
# layout matches sheets.js cell->name exactly. Then a slice named "<sheet>_A1" really is cell A1.
#
# Writes:
#   - Assets/Sprites/icons/<sheet>_icon_atlas.png   (overwrite in place; GUID/.meta preserved)
#   - Assets/Sprites/icons/icon_atlas_manifest.json (name<->cell, only cells that got art)
#   - scratchpad/contact/<sheet>.png                (labeled name-under-art, for human verification)
import re, json, os, io, urllib.request
from collections import Counter
from PIL import Image, ImageDraw

ICON_DIR  = r"C:/Dev/RefugeAndSword/games/project-grimoire/ProjectGrimoire/Assets/Sprites/icons"
SHEETS_JS = r"C:/Dev/RefugeAndSword/games/asset_tracker/src/data/sheets.js"
CONTACT   = r"C:/Users/dusty/AppData/Local/Temp/claude/C--Dev-RefugeAndSword-games-project-grimoire/fd289b48-96cf-445b-af3d-9b5a61d90880/scratchpad/contact"
CELL      = 64
COLS      = 4
USABLE    = {"Approved", "Imported to Unity"}

# atlas file basename (minus _icon_atlas) -> tracker sheet id, where they differ
ALIAS = {"cookerymeals": "cookery", "delving": "delving_ores",
         "felling": "felling_logs", "runesmithing_components": "runesmithing"}
# atlas files with no clean 1:1 item sheet yet (weapon/armor type-matched, or unmapped)
SKIP = {"cultivation", "delving_special", "tailoring_armor", "tailoring_cloth"}

env  = open(r"C:/Dev/RefugeAndSword/games/asset_tracker/.env.local", encoding="utf-8").read()
SUPA = re.search(r"https://[a-z0-9]+\.supabase\.co", env).group(0)
ANON = re.search(r"ANON_KEY=(.+)", env).group(1).strip().strip('"').strip("'")
def get(path):
    req = urllib.request.Request(f"{SUPA}/rest/v1/{path}", headers={"apikey": ANON, "Authorization": "Bearer " + ANON})
    return json.loads(urllib.request.urlopen(req, timeout=30).read())

# --- sheets.js: sheet_id -> {cell: name} ---
js = open(SHEETS_JS, encoding="utf-8").read()
sheet_cells = {}
for m in re.finditer(r'id:\s*"([^"]+)"', js):
    sid = m.group(1)
    itstart = js.find("items:", m.end())
    if itstart < 0: continue
    br = js.find("[", itstart); end = js.find("]", br)
    cells = {}
    for it in re.finditer(r'\{([^}]*)\}', js[br:end]):
        body = it.group(1)
        nm = re.search(r'name:\s*"([^"]+)"', body); cl = re.search(r'cell:\s*"([^"]+)"', body)
        if nm and cl: cells[cl.group(1)] = nm.group(1)
    if cells: sheet_cells[sid] = cells

# --- tracker: file url + status per (sheet, cell) ---
files  = {(r["sheet_id"], r["cell"]): r["file_url"] for r in get("asset_files?select=sheet_id,cell,file_url&limit=5000")}
status = {(r["sheet_id"], r["cell"]): r["status"] for r in get("asset_statuses?select=sheet_id,cell,status&limit=5000")}

def cell_pos(cell):           # A1 -> (col, row), row-major, A=row0, 1=col0
    return int(cell[1:]) - 1, ord(cell[0]) - ord("A")

os.makedirs(CONTACT, exist_ok=True)
dl_cache = {}
def load(url):
    if url not in dl_cache:
        dl_cache[url] = Image.open(io.BytesIO(urllib.request.urlopen(url, timeout=60).read())).convert("RGBA")
    return dl_cache[url]

manifest, report = [], []
for f in sorted(os.listdir(ICON_DIR)):
    if not f.endswith("_icon_atlas.png"): continue
    base = f[:-len(".png")]; key = base[:-len("_icon_atlas")]
    if key in SKIP: report.append(f"SKIP {key} (needs manual mapping)"); continue
    sid = ALIAS.get(key, key)
    names = sheet_cells.get(sid)
    if not names: report.append(f"NOMAP {key} -> {sid} (no sheets.js entry)"); continue

    # cells that have usable art
    art = {cell: files[(sid, cell)] for cell in names
           if (sid, cell) in files and status.get((sid, cell)) in USABLE}
    if not art:
        report.append(f"EMPTY {key} -> {sid} (no Approved/Imported art)"); continue

    rows = max(cell_pos(c)[1] for c in art) + 1
    atlas = Image.new("RGBA", (COLS * CELL, rows * CELL), (0, 0, 0, 0))
    placed = 0
    for cell, url in art.items():
        col, row = cell_pos(cell)
        if col >= COLS: report.append(f"  {key} {cell} col>{COLS-1}, skipped"); continue
        icon = load(url)
        if icon.size != (CELL, CELL): icon = icon.resize((CELL, CELL), Image.NEAREST)
        atlas.paste(icon, (col * CELL, row * CELL), icon)
        manifest.append({"sheet": base, "cell": cell, "name": names[cell]})
        placed += 1
    atlas.save(os.path.join(ICON_DIR, f))

    # contact sheet: art with the item name printed beneath each cell
    LBL = 16
    cs = Image.new("RGBA", (COLS * CELL, rows * (CELL + LBL)), (28, 28, 30, 255))
    d = ImageDraw.Draw(cs)
    for cell, url in art.items():
        col, row = cell_pos(cell)
        if col >= COLS: continue
        x, y = col * CELL, row * (CELL + LBL)
        cs.paste(load(url).resize((CELL, CELL), Image.NEAREST), (x, y), load(url).resize((CELL, CELL), Image.NEAREST))
        d.text((x + 1, y + CELL + 3), f"{cell} {names[cell]}"[:16], fill=(210, 200, 170, 255))
    cs.save(os.path.join(CONTACT, f"{key}.png"))
    report.append(f"OK   {key:24s} -> {sid:20s} {placed:2d} cells, {rows} rows")

json.dump(manifest, open(os.path.join(ICON_DIR, "icon_atlas_manifest.json"), "w", encoding="utf-8"), indent=1)
print("\n".join(report))
print(f"\nWrote {len(manifest)} manifest entries. Contact sheets in {CONTACT}")
