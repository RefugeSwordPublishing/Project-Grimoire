---
type: design-brief
version: 1.0
updated: 2026-07-31
path: docs/hub-hud-station-brief.md
resolves: Hub HUD design request
implements: HubSceneUI (Unity), ui_hub_stations sheet (A1-A4 asset tracker)
---

# Project Grimoire, Main Hub HUD: Station Art and Placement Brief
### Version 1.0

---

## 1. Design Intent

The hub should read as a living place, not a menu screen wearing a background.
Each navigation destination becomes a physical prop in the guild hall — something
that exists in the world and invites interaction, rather than a button label that
floats over wallpaper.

The four stations occupy different depths in the scene (foreground, near-mid,
mid), which reinforces the parallax layering of the background and gives the
hub genuine spatial weight. A player glancing at the screen should immediately
read which stations are available and which have something waiting for them,
without reading a single label.

---

## 2. Generation Prompts (PixelLab)

All four prompts use the same style suffix:

> HD-2D pixel art, dark medieval fantasy, front-facing, transparent background,
> warm amber torchlight from the left side, dark pixel outline, 256x384

---

### A1 — Quest Board

```
tall notice board of dark weathered wood with a thick frame of iron corner brackets,
surface covered in layered parchment job postings and wanted posters pinned with iron
tacks, curling edges on older parchments, a red wax seal visible on one prominent
posting, small skull-and-crossbones stamp on a bounty parchment at eye level,
warm amber torchlight catching the top of the board and casting a long downward shadow,
subtle amber glow from the board itself suggesting an active state,
front-facing, transparent background,
HD-2D pixel art, dark medieval fantasy, dark pixel outline, 256x384
```

**Notes:** The board should lean very slightly backward as if wall-mounted or post-mounted.
The parchments should overlap and vary in age — some fresh white, some yellowed.
The red wax seal is the visual anchor that draws the eye. Active-state glow is a very
subtle warm backlight on the board edges, not a cartoon shine.

**Weak-point mask:** If an unread-quest badge is added at runtime, position it at
the top-right corner of the board frame. The badge should sit over the iron bracket,
not over the parchment surface.

---

### A2 — Upgrade Terminal (Arcane Anvil)

```
arcane blacksmith's anvil of dark iron fused with arcane rune apparatus,
thick flat anvil face with rune script etched deep into the surface glowing amber-gold,
two arcane apparatus arms rising from the sides like a runic measurement instrument,
a few scattered tools laid on a low shelf at the base — iron hammer, tongs, a rune chisel,
steady amber-gold arcane light emanating from the rune etching on the anvil face,
front-facing, transparent background,
HD-2D pixel art, dark medieval fantasy, dark pixel outline, 256x384
```

**Notes:** The rune apparatus arms should have the same visual language as the
Artificer apparatus items — gear-and-rune construction. The anvil itself is the
anchor shape (wide base, narrow waist, flat face). The amber glow from the rune
etching is the active-state cue — it reads as "ready for use" without needing a label.
The scattered tools on the shelf give the prop depth and tell the player this is a
workshop, not just a menu button.

---

### A3 — Slayer Hub (Bounty Post)

```
heavy dark wooden bounty post with a mounted iron hook rack at the top bearing
three rolled parchment contracts tied with red cord, a preserved trophy skull mounted
above the hook rack on an iron spike — heavy bone, yellowed with age,
two crossed blades pinned behind the skull as a symbol of the slayer's trade,
a worn leather contract satchel hanging from the post base,
subtle amber torch reflection on the skull surface catching from the left,
front-facing, transparent background,
HD-2D pixel art, dark medieval fantasy, dark pixel outline, 256x384
```

**Notes:** The skull is the visual identity of this prop — it should be unmistakably
the Slayer Hub at a glance. The contract rolls on the hook rack give it function.
Avoid making it look like a death prop in isolation — the parchment contracts and
satchel ground it as a professional station, not a threat.

**Badge position:** A "hunt active" indicator (orange pulse dot) sits on the
central contract roll when a Hunt is running. An "unread bounties" badge sits at
the top-left of the hook rack.

---

### A4 — Notice Board (Herald Board)

```
formal proclamation board of dark polished wood with carved guild heraldry at the top,
a framed glass-covered central panel showing a freshly posted proclamation parchment
with decorative borders, a brass herald bell mounted on an arm extending from the
upper-right corner of the frame, a tallow candle in an iron holder at the lower-left
corner of the board casting warm light upward across the glass,
the herald bell has a faint glow suggesting it recently rang,
front-facing, transparent background,
HD-2D pixel art, dark medieval fantasy, dark pixel outline, 256x384
```

**Notes:** The glass-covered proclamation panel is the "new content" surface — at runtime,
a "NEW" stamp animates onto the parchment face when there is an unread announcement.
The herald bell is the "has notification" visual cue — it gains a gentle swing animation
and a small amber pulse at its rim when new content is available.
The heraldry carving at the top gives the prop rank and formality versus the rough-hewn Quest Board.

---

## 3. Portrait Layout Spec

Reference device: Samsung S10e, 1080x2280px, ~429ppi.
Safe area top: ~80px (notch + status bar). Existing persistent top bar: ~140px total (pinned).
Bottom nav drawer: ~200px. Usable scene height: approximately 1,940px.

All positions are described as proportional anchors to the scene rect (below the
persistent top bar, above the bottom nav). **Do not use absolute pixel values** —
express all positions as percentages of the usable viewport width (VW) and
usable viewport height (VH).

---

### Scene Depth Layers

```
Layer 0 (farthest):  Guild hall background (FLUX painterly, static)
Layer 1 (mid-far):   Background detail props — shelving, wall weapons (future)
Layer 2 (mid):       Quest Board, Notice Board
Layer 3 (near-mid):  Slayer Hub
Layer 4 (near):      Upgrade Terminal (foreground, largest apparent size)
Layer 5 (front):     Ambient particles, floating badge overlays, active pings
```

Parallax: on player swipe/tilt, Layer 2 shifts ±1.5%, Layer 3 ±2.5%, Layer 4 ±4%.
The background (Layer 0) shifts ±0.5%. This creates readable depth without
making the scene feel unstable.

---

### Station Placements

#### A1 — Quest Board

```
Position:    Left side, lower-mid scene
Anchor:      Bottom-left of board frame anchored to 10% from left edge, 72% VH from top
Width:       ~26% VW (scales to ~280px on 1080)
Height:      Proportional (~39% VW) — approximately 42% VH visible
Z-layer:     Layer 2 (mid)
Parallax:    ±1.5%
Tappable:    Full board rect plus 8% margin (finger reach on left edge)
```

The Quest Board sits against the left wall — the leftmost of the four stations.
It should feel wall-mounted, as if pinned to the guild hall interior wall, not
freestanding. The floor line of the background should pass approximately 10-15%
below the bottom edge of the board sprite, so the post or bracket base appears
to touch the floor.

**Badge:** Unread-quest badge (gold circle, numbered) at top-right corner of
frame, Layer 5. Visible when `dailyQuestSlots > 0` has unclaimed quests.

---

#### A4 — Notice Board

```
Position:    Right side, lower-mid scene (mirrors Quest Board)
Anchor:      Bottom-right of board frame at 90% from left edge, 68% VH from top
Width:       ~26% VW
Height:      Proportional, approximately same as Quest Board
Z-layer:     Layer 2 (mid)
Parallax:    ±1.5%
Tappable:    Full board rect plus 8% margin (finger reach on right edge)
```

The Notice Board mirrors the Quest Board on the right side, creating a balanced
bookend composition. It is slightly higher on the VH axis than the Quest Board
to avoid perfect symmetry — the slight offset reads as natural placement.

**Badge:** Herald bell swing animation (Layer 5, plays once on open if new
content exists, then settles into a slow idle glow). "NEW" stamp appears on
the proclamation parchment face. No numeric badge — notifications are binary
(something new / nothing new).

---

#### A3 — Slayer Hub

```
Position:    Right of center, lower scene
Anchor:      Base of post at 62% from left edge, 82% VH from top
Width:       ~22% VW (narrower silhouette — the post is tall, not wide)
Height:      Proportional (~50% VW) — approximately 50% VH
Z-layer:     Layer 3 (near-mid)
Parallax:    ±2.5%
Tappable:    25% VW wide centered on the post anchor (generous for skull and satchel reach)
```

The Slayer Hub sits right-of-center, closer to the viewer than the Notice Board,
reinforcing depth. Its tall post silhouette is distinct from the rectangular boards
on either side. The base of the post should align with or slightly below the
background floor line — this is where grounding matters. Flag this anchor for
the camera/floor-line alignment task.

**Badge:** "Hunt active" orange pulse on the central contract roll (animated dot,
Layer 5). "Bounties available" badge at top-left of hook rack.

---

#### A2 — Upgrade Terminal

```
Position:    Left of center, lower scene (foreground)
Anchor:      Base of anvil at 38% from left edge, 86% VH from top
Width:       ~30% VW (widest station — heaviest, foreground)
Height:      Proportional (~42% VW) — approximately 40% VH
Z-layer:     Layer 4 (near/foreground)
Parallax:    ±4%
Tappable:    32% VW wide, centered on anvil (generous — anvil face is the tap target)
```

The Upgrade Terminal is the frontmost station and the largest apparent size.
The anvil's low, wide silhouette fills more horizontal space than the other props
and feels physically closest to the player. Its base should land on or just
below the floor line.

The amber-gold rune glow on the anvil face is the most persistent light source
of the four stations — it should always be warm and visible. When an upgrade is
available (player has a tool or piece of gear that can be quality-upgraded), the
glow brightens and slow-pulses (~1.5s cycle).

**Badge:** Quality-upgrade available indicator — a small forge hammer icon (not a
number) at the top of the apparatus arm, Layer 5, appears when at least one
upgrade is available. Clear when all pending upgrades are dismissed.

---

### Compositional Overview

```
VW  0%    10%   20%   30%   40%   50%   60%   70%   80%   90%   100%
    |      |      |      |      |      |      |      |      |      |

Top of scene (below persistent status bar)
~20%VH  [                   empty scene / sky / upper hall                    ]

~45%VH  [Quest Board L2]                              [Notice Board L2]
        (wall-mounted, left)                           (wall-mounted, right)

~60%VH  [Quest Board continues]    [Upgrade  ] [Slayer Hub L3]  [Notice Board]
                                   [Terminal  ]                  [continues]
                                   [L4 front  ]

~80%VH  [  floor line zone (background horizon / tavern floor visible here)   ]
        [QuestBoard base]  [Anvil base]  [Post base]  [NoticeBoard base]

~90%VH  [  bottom of scene — clears bottom nav                                ]
```

Floor-line dependency note: all four prop bases are designed to align to the
background's interior floor line. The exact VH% of that floor line depends on
which guild-hall background stage is active (P0 campfire has a different horizon
than P50 castle hall). When grounding is implemented as a separate task:

- Expose a `floorLineVH` parameter per background asset.
- Each station anchor's Y is computed as `floorLineVH + stationBaseOffset`.
- Default `stationBaseOffset`: Quest Board 0%, Upgrade Terminal +2% (anvil sits
  slightly in front of the floor plane), Slayer Hub 0%, Notice Board -1%.

---

## 4. Animation and Ambient Life

### Ambient props (no interaction, Layer 1-2)

These are additional sprite props that make the hub feel inhabited without
adding nav complexity. Author as 2-4 frame looping animations or static sprites.

| Prop | Position | Note |
|------|----------|------|
| Hanging lantern (left wall) | ~8% VW, ~38% VH, Layer 2 | Slow 4-frame flame flicker loop |
| Hanging lantern (right wall) | ~92% VW, ~38% VH, Layer 2 | Same loop, offset by 1s |
| Guild banner (center, upper) | ~50% VW, ~25% VH, Layer 1 | Slow 4-frame wave ripple |
| Brazier embers (floor level) | ~25% VW, ~82% VH, Layer 3 | 4-frame ember pulse |
| Scattered coin pile | ~55% VW, ~84% VH, Layer 4 | Static prop, flavour |

These props are seeded in the asset tracker as `ui_hub_ambient` sheet (not yet
created — add with cells A1-A5 for the five entries above).

### Notification pulse behavior

All badge animations use the same easing curve to feel like a unified system:

```
Unread badge (numeric): scale bounce on appear (0→1.15→1.0, 200ms), then static.
New content ping:        radial pulse ring expands from badge center (300ms, fade out), repeats every 8s.
Active hunt dot:         slow opacity pulse (0.6→1.0→0.6, 1.5s loop), orange tint.
Upgrade available forge: ambient glow brightness 0.6→1.0→0.6, 1.5s loop, amber tint.
Herald bell on open:     10-degree swing left-right (300ms), 3 oscillations, settle.
```

All notification animations respect Unity's `reducedMotion` accessibility setting:
if enabled, replace pulse animations with static highlight state only.

---

## 5. Asset Tracker Updates

Update the `ui_hub_stations` sheet seed prompts with the refined prompts from
Section 2. No cells change — only the `prompt` field updates on A1-A4.

New sheet to create: `ui_hub_ambient`, cells A1-A5, with short description prompts
for the five ambient props (lantern, banner, brazier, coin pile).

---

## 6. Open Dependencies

| Dependency | Owner | Blocks |
|------------|-------|--------|
| Background floor-line value per guild hall stage | Claude Code | Prop grounding for Upgrade Terminal and Slayer Hub |
| `reducedMotion` flag exposed in Unity settings | Claude Code | All badge pulse animations |
| `dailyQuestSlots` unclaimed count readable by HubSceneUI | Claude Code | Quest Board badge |
| Hunt active state readable by HubSceneUI | Claude Code | Slayer Hub pulse dot |
| Upgrade available check (any gear/tool upgradeable) | Claude Code | Upgrade Terminal glow state |
| Herald announcement unread flag | Claude Code | Notice Board bell and NEW stamp |

---

*Path: docs/hub-hud-station-brief.md*
*Covers: PixelLab generation prompts for A1-A4, portrait placement spec,*
*depth layering, badge behavior, ambient prop list, open dependencies.*
