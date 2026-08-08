---
type: design-brief
version: 0.1
updated: 2026-08-07
path: docs/ui-kit-art-brief.md
companion: art-asset-requirements.md (v0.5)
generator: Layer.ai (web UI; no MCP connection, generate manually and import to Unity)
---

# UI Kit Art Brief
### Version 0.1, first-pass component system

This brief covers the **UI chrome**: the reusable skin the whole game wears (panels, buttons,
tabs, cards, bars, chips, frames). `art-asset-requirements.md` already specifies content art
(characters, enemies, item icons, backgrounds) and lists two UI line items (96x96 9-slice panel
borders, 48x48 nav icons), but never defines the component system. That system is what this
brief adds, and it is the right art to start on now because it does not depend on any screen's
layout staying still.

---

## 1. Tooling reality (read first)

- **Generator:** Layer.ai, in its own web UI. There is **no Layer.ai MCP connection** in the build
  environment, so Claude Code cannot drive it directly. Dustin runs the generations in Layer; Claude
  supplies the prompts (Section 4) and handles Unity import and assembly (Section 8). (The separately
  connected `sprite-ai` MCP is a **different service**, not Layer.ai; ignore its token/asset-type
  economics here.)
- **Style consistency:** use a **pre-built or custom Layer model** as the fixed style anchor, the
  same approach `art-asset-requirements.md` (Workflow B) uses for characters/enemies/icons, so the
  UI chrome shares one visual DNA across every pull. Confirm generation credit cost against Layer's
  own pricing at the start of the session; this brief counts generations, not credits (Section 6).
- **Layer does the art, Unity does the assembly.** Layer paints panel faces, borders, button states,
  and bar fills. The 9-slice borders, state swaps, anchoring, and atlasing happen in Unity against
  the existing code-built UIs. Every runtime UI in the project (`RoyalMerchantUI`,
  `NavigationDrawerUI`, combat views) is built in C# with flat-color placeholders today; the kit
  swaps those placeholder `Image` colors for authored sprites.

---

## 2. Style constraints (inherit from the HD-2D Grimoire variant)

Every `ui` generation carries the same DNA so the kit reads as one system:

- Dark fantasy, HD-2D, grimoire/arcane theme. Aged parchment and dark stone surfaces, muted
  bronze/gold metal trim, deep desaturated backgrounds so bright content art and the gold currency
  accents pop against them.
- Limited palette, readable at mobile scale. Clean dark outline on framed elements.
- Restrained ornament: a corner flourish and a beveled metal edge, legible at 48-96px, never busy.
- Import at **Point filter, no compression** (matches the spec's UI rule) so edges stay crisp.

**Palette anchors** (hand these to Layer and keep them fixed across every UI generation):
- Panel base: dark warm charcoal `#211E24` to `#2A2620`
- Parchment inset: `#EDE8D2` aged cream
- Metal trim: bronze `#8A6E3C` with gold highlight `#DCC47C`
- Positive/buy: mossy green `#4C6B33`
- Danger/cancel: oxblood `#8A2B2B`
- Text on dark: `#E8E1D4`; text on parchment: `#2A241C`

---

## 3. Component inventory (the kit)

Grouped by how they generate. Sizes are the Layer.ai generation size; Unity slices/imports down.

### 3.1 Frames and panels (9-slice, generate at 96x96 unless noted)
| Component | Gen size | Notes |
|-----------|---------|-------|
| Primary panel skin | 96x96 | Main page/modal background, dark stone + bronze edge, 9-slice |
| Card / list-row skin | 96x96 | Store rows, inventory rows, quest cards; lighter inner fill |
| Modal / dialog frame | 128x128 | Heavier ornate border for confirm dialogs and banners |
| Tooltip skin | 64x64 | Small, thin border, high contrast for readability |
| Inventory slot, empty | 64x64 | Sunken socket look |
| Inventory slot, highlight | 64x64 | Selected/equipped ring, same footprint |

### 3.2 Buttons and tabs (generate at 96x96, 9-slice)
| Component | States | Notes |
|-----------|--------|-------|
| Primary button | up / down / disabled | Green-trim buy/confirm; author all three faces |
| Secondary button | up / down / disabled | Neutral stone; cancel/back reuse with oxblood tint |
| Tab | active / inactive | For the Royal Merchant and Exchange tab bars |
| Icon button (round) | up / down | Close, nav, small HUD actions |

### 3.3 Bars and meters (generate frame + fill separately)
| Component | Pieces | Notes |
|-----------|--------|-------|
| Resource bar (HP / idle) | frame + fill | Fill is a flat tileable strip tinted in Unity |
| Boss HP bar | frame + fill | Wider, ornate; used by the boss banner |

### 3.4 Chips and badges (small)
| Component | Gen size | Notes |
|-----------|---------|-------|
| Currency chip / pill | 64x32 | Background for the GM/SM balance readout |
| Count / notification badge | 32x32 | Corner count bubble |

> Quality tier badges are already owned by `icons_quality_badges.png` in the art spec. Do not
> duplicate them here.

### 3.5 Nav and HUD icons (icon workflow, not `ui` chrome)
The drawer/nav glyphs (Inventory, Character, Gathering, Processing, Combat, Crafting, Exchange,
Guild, Quests, Slaying, Royal Merchant, Settings) generate as a **48x48 pixel-icon sheet** through
the same icon workflow as item icons (4-wide grid), separate from the parchment chrome. They are
content glyphs, so they share the pixel-art DNA of the item icons rather than the panel skin.

The currency and slot-ticket icons the Royal Merchant work needs (Gold Mark coin, Silver Mark coin,
Inventory/Quest/Slaying/Exchange Slot Tickets) already have a home: `icons_currency_ui.png` in the
art spec's atlas list. Generate that sheet when the icon batch runs.

---

## 4. UI-chrome prompt template

Fill the bracket, keep the suffix fixed on every UI-chrome generation:

```
[component description], dark fantasy game UI, aged parchment and dark stone,
muted bronze and gold metal trim, [state], centered, single element on transparent
background, clean dark outline, limited palette, HD-2D grimoire aesthetic, crisp at
small size, no text, no characters, no drop shadow outside the element
```

Worked examples:
- Primary panel: `ornate rectangular panel background, dark fantasy game UI, aged parchment inset with dark stone border and bronze corner flourish, 9-slice friendly with plain center, single element on transparent background, ...`
- Buy button (up): `wide rounded button, dark fantasy game UI, dark stone face with mossy green bevel and bronze rim, resting state, single element on transparent background, ...`
- Buy button (down): same, `pressed state, inset shadow, slightly darker`
- Tab (active): `tab shape, dark fantasy game UI, lit parchment face with gold underline, active selected state, ...`
- Currency chip: `small horizontal pill background, dark fantasy game UI, dark stone with thin gold rim, room for a coin icon and number, ...`

Generate button/tab **states as separate pulls at the same size** so they register pixel-for-pixel
in Unity.

---

## 5. Generation order

Produce in this order so the most-reused pieces land first and the rest inherit their look:

1. **Primary panel skin** (everything sits on it; sets the palette).
2. **Card/list-row skin** (the most repeated element in the game).
3. **Primary + secondary button, all states.**
4. **Tab, active/inactive** (unblocks the Royal Merchant and Exchange tab bars).
5. **Modal frame, tooltip skin.**
6. **Resource bar + boss bar** (frame + fill).
7. **Inventory slot empty/highlight, currency chip, count badge.**
8. **Nav-icon sheet + `icons_currency_ui.png`** (icon workflow).

---

## 6. Generation count (size the session)

Counted as distinct Layer generations, not credits (confirm credit cost against Layer's pricing):

| Batch | Generations |
|-------|-------------|
| Panels + cards + modal + tooltip + slots | 6 |
| Buttons + tabs (each state a separate pull) | ~7 |
| Bars (frame + fill x2) | 4 |
| Chips + badges | 2 |
| Nav-icon sheet + currency/UI icon sheet | 2 |
| **First-pass kit** | **~21 generations** |

Budget extra pulls for the panel skin (step 1) specifically: everything downstream matches it, so
2-3 rerolls there is normal and worth it before committing to the rest.

---

## 7. What NOT to generate yet

Hold per-screen final art (custom backgrounds, framed HUDs, decorated one-off panels) until each
screen's layout is locked. These are still moving and would be repainted:
- Royal Merchant (just restructured into 5 tabs, Phase 2 wiring ongoing)
- Guild screens
- Slaying pages (Hunts + Bounty Board are days old)

Screens stable enough to consider per-screen art after the kit lands: inventory, gathering,
processing, crafting, character.

---

## 8. Unity assembly checklist (after generation)

- Import UI chrome sprites: Sprite Mode Single, Point filter, no compression.
- Mark 9-slice sprites with borders in the Sprite Editor; use `Image type = Sliced`.
- Keep the RectMask2D rule (DX12): never the `Mask` component.
- Swap placeholder `Image.color` fills in the runtime UIs for the authored sprites one component
  at a time; the code-built layout stays, only the skin changes.

---

*Path: docs/ui-kit-art-brief.md*
*Builds on: art-asset-requirements.md (v0.5) resolution table + atlas list.*
*Generation: Layer.ai web UI (funded); no Layer.ai MCP connection, so Dustin runs the pulls with*
*these prompts and Claude handles Unity import + assembly.*
