---
type: art-spec
version: 0.2
updated: 2026-07-11
purpose: Dimensions, safe zones, and Layer.ai prompts for the Guild Hall background art
         (8 prestige stages) so MOTD signpost / quest board overlays never clip the props.
---

# ⚔️ Project Grimoire — Guild Hall Background Art

The Guild Hall uses one full-screen **portrait background** behind the UI (MOTD signpost,
quest board, buff row, guild stats). The background **swaps per prestige stage** (8 stages).
The interactive props (signpost, quest board) are **painted into the art but stay in fixed
screen positions across all 8 stages** so the UI hotspots overlaid on them always line up.

> **Workflow:** these are **backgrounds** → use **Workflow A (painterly concept art)** from
> `art-asset-requirements.md` v0.5 — a painterly/concept-art model (FLUX, Gemini 3.1 Flash Image,
> etc.), **never the pixel sprite model**. Unlike the landscape combat backdrops (1920×1080,
> multi-layer parallax), the guild hall background is a **single flat portrait image** — no parallax
> layers needed, since UI sits on top of it, not a moving camera.

---

## 📐 Canvas, size & safe zones

The game canvas is **portrait 1080 × 1920 (9:16)**, `CanvasScaler` set to **match width**
(`matchWidthOrHeight = 0`). Because it matches width, every device is exactly **1080 units wide**,
but visible **height varies** with the phone's aspect ratio:

| Device | Visible height (ref units) |
|--------|----------------------------|
| 4:3 tablet | ~1440 |
| 9:16 phone (baseline) | 1920 |
| 9:19.5 modern iPhone | ~2340 |
| 9:21 tall Android | ~2520 |

**A flat 1080×1920 leaves gaps top/bottom on tall phones.** So:

- **Generate at 1080 × 2400** (≈9:20) — or 2× for crispness: **2160 × 4800**.
- Compose the scene + all props inside the central **1080×1920** region; let the **top (sky)
  and bottom (ground)** bleed with no important detail so they can crop away on shorter screens.
- In Unity the background `Image` is set to **crop-fill** (preserve aspect, envelope) — it always
  covers, never letterboxes.

### Safe content band (keep props + focal art here)

Within the 1080×1920 frame, UI chrome overlays the top and bottom:

```
 y 0 ────────────────────────────────
        TOP ~220px  → header (116) + tab/nav strip (84) + notch
 y 220 ══════════════════════════════
        ┃                            ┃
        ┃     SAFE CONTENT BAND      ┃  ← signpost / MOTD, quest board,
        ┃   (props + focal build)    ┃    prestige focal structure
        ┃                            ┃
 y 1720 ══════════════════════════════
        BOTTOM ~200px → nav row (100) + guild stats strip
 y 1920 ────────────────────────────────
```

- **Side margins:** keep props within **x 40–1040** (rounded corners / notch).
- **Focal band:** roughly **y 220 → 1720**.

### Fixed prop positions (identical in every stage)

| Prop | Screen position | Why fixed |
|------|-----------------|-----------|
| **Signpost** (MOTD / announcement) | lower-**left** foreground, ~x 120–430, ~y 1150–1600 | UI overlays the announcement text on it |
| **Quest board** (material requests + Guild Merchant) | lower-**right** foreground, ~x 650–960, ~y 1120–1620 | UI overlays notice cards on it |
| **Focal structure** (campfire → castle) | upper-center / mid-ground, ~y 350–1150 | evolves with prestige; no overlay |
| **Buff row** overlays around ~y 1650; **guild stats** below nav | — | keep art quiet there |

Paint the signpost board face and the quest board parchment **blank** (no lettering) — the game
draws the text. Only the scenery and the focal structure change between stages.

---

## 🎨 Background style suffix

Painterly concept art (Workflow A) — **not** pixel art. Append to every stage prompt:

```
dark fantasy medieval RPG, painterly concept art style, cinematic lighting, dusk,
warm honeyed torchlight against deep slate-blue shadows, earthy camel and tan tones,
atmospheric depth, soft god rays, gentle bloom on fires and lanterns,
high resolution game background, portrait composition 1080x2400,
no characters, no text, no UI
```

Every stage keeps the **same camera framing and prop layout** — a wooden **signpost in the
lower-left foreground** and a **parchment quest board in the lower-right foreground**, both blank.
Only the central structure and surrounding scenery evolve.

---

## 🏰 The 8 prestige stages

> Prestige bands: **0–4 · 5–9 · 10–19 · 20–34 · 35–49 · 50–74 · 75–99 · 100+**.
> Same signpost (lower-left) + quest board (lower-right) in every one.

**1 — Campfire Gathering (Prestige 0–4)**
```
a humble guild campfire in a forest clearing at dusk, a modest crackling campfire ringed with
stones as the central focal point, a few felled logs to sit on, faint smoke rising, a blank wooden
signpost in the lower-left foreground and a small blank parchment quest board on a post in the
lower-right foreground, [background style suffix]
```

**2 — Tent Camp (Prestige 5–9)**
```
a small guild camp at dusk, two or three canvas tents pitched around a central campfire, simple
guild banner on a pole, supply sacks nearby, the blank wooden signpost in the lower-left foreground
and the blank parchment quest board in the lower-right foreground, [background style suffix]
```

**3 — Encampment (Prestige 10–19)**
```
an organized guild encampment at dusk, several tents in tidy rows around a fire pit, wooden supply
crates and barrels, guild banners, the beginnings of a low wooden palisade at the edges, the blank
wooden signpost in the lower-left foreground and the blank parchment quest board in the lower-right
foreground, [background style suffix]
```

**4 — Army Encampment (Prestige 20–34)**
```
a large guild war encampment at dusk, rows of military tents, tall war banners, a training area with
practice dummies, a sturdy wooden palisade wall enclosing the camp, watchtowers, the blank wooden
signpost in the lower-left foreground and the blank parchment quest board in the lower-right
foreground, [background style suffix]
```

**5 — Fortress (Prestige 35–49)**
```
a stone guild fortress at dusk, thick grey stone curtain walls and a gatehouse as the central focus,
lit torches along the battlements, guild banners hung from the walls, the blank wooden signpost in
the lower-left foreground and the blank parchment quest board in the lower-right foreground,
[background style suffix]
```

**6 — Castle (Prestige 50–74)**
```
a proper guild castle at dusk, multiple stone towers with conical roofs, a raised gatehouse and
drawbridge, banners flying from the turrets, warm torchlight, the blank wooden signpost in the
lower-left foreground and the blank parchment quest board in the lower-right foreground,
[background style suffix]
```

**7 — Castle with Village (Prestige 75–99)**
```
a guild castle overlooking a small village at dusk, stone castle with towers on a rise, clustered
village rooftops and lantern-lit lanes below it, market stalls, smoke from chimneys, the blank wooden
signpost in the lower-left foreground and the blank parchment quest board in the lower-right
foreground, [background style suffix]
```

**8 — Stronghold Capital (Prestige 100+)**
```
a grand guild stronghold capital at dusk, a towering fortified castle crowning a walled city,
tiered rooftops and spires, great banners and glowing braziers, distant mountains, an imposing
capital skyline, the blank wooden signpost in the lower-left foreground and the blank parchment
quest board in the lower-right foreground, [background style suffix]
```

---

## 🛠️ Unity import

- **Sprite Mode:** Single. **Filter Mode:** Bilinear (painterly background, not point). **Compression:** Lossless.
- **Max Texture Size:** 4096 (these are large backgrounds).
- Assign to the hall background `Image`; set the Image to **preserve-aspect crop-fill** so it covers all aspect ratios.
- Save to `Assets/Sprites/Environments/GuildHall/` as `guildhall_stage1_campfire` … `guildhall_stage8_capital`.
- Wire the 8 sprites in prestige order; the hall swaps to the sprite matching the guild's current prestige band.

---

## 📋 Notes

- Generate stages **1, 5, and 8 first** as a spread (low / mid / high) to validate the style, framing,
  and that the fixed prop positions read well before producing the middle stages.
- The signpost + quest board **must occupy the same footprint** in all 8 — generate one, then use it as
  a style/placement reference for the rest (Layer.ai reference image) so the UI hotspots line up.
- Buff-row and guild-stats areas (bottom) should stay visually calm — avoid busy detail there.

---

*Document version 0.1 — Guild Hall Background Art*
