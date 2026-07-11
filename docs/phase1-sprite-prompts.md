## 📋 Sprite Atlas Prompt Format

All item icons are generated as **atlas sheets** — multiple icons in a uniform grid — not individual files. Use this format for all item icon generation:

**Standard atlas prompt template:**
```
item icon sheet, 4x2 grid layout, [category] items:
[item1], [item2], [item3], [item4],
[item5], [item6], [item7], empty slot,
each icon 64x64px in a uniform grid, small flat icons,
limited palette, dark pixel outline,
HD-2D pixel art style, Octopath Traveler-inspired,
transparent background, total sheet 256x128
```

**Key rules:**
- Always specify grid dimensions (4x2, 4x4 etc.) explicitly
- Always specify individual cell size (64x64)
- Always specify total sheet size (256x128 for 4x2)
- Include "empty slot" for unused grid positions — reserves space for future items
- Use "uniform grid" to ensure consistent cell alignment for Unity slicing
- Reference an approved character sprite as style anchor for animal/creature icons

**Unity import after generation:**
Sprite Mode → Multiple → Sprite Editor → Slice → Grid by Cell Size 64x64 → Apply

---

# ⚔️ Project Grimoire — Phase 1 Sprite AI Prompt Library
### Version 0.2

> All prompts follow Sprite AI's format: subject + colors + pose + style + size. Style tag stays consistent across every prompt to lock visual cohesion.
>
> **Generation method:** Sprite AI is connected via MCP directly to Claude Code — these prompts can be handed to Claude Code to execute directly rather than pasted into the browser tool. Generate the Warden base body first and use it as a style reference for everything else to maintain consistency across the whole asset set.

---

## 🎨 Standard Style Suffix

Append this to every prompt for consistency:
```
limited palette, dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, transparent background
```

---

## 🧍 Character — Warden (Layered Approach)

Generate as **separate layers** so equipment can be swapped in Unity without regenerating the whole character.

**Layer 1 — Base Body (no equipment)**
```
warden archer base body, neutral skin tone, simple tunic, idle pose, side view, limited palette, dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, transparent background, 64x64
```

**Layer 2 — Hood/Cloak (Sharpshot variant)**
```
hooded cloak layer only, forest green fabric, worn edges, fits over base body silhouette, side view, limited palette, dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, transparent background, 64x64
```

**Layer 3 — Hood/Cloak (Lone Wanderer variant)**
```
hooded cloak layer only, amber and brown fabric, ragged edges, fits over base body silhouette, side view, limited palette, dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, transparent background, 64x64
```

**Layer 4 — Quiver (worn on back, separate layer)**
```
leather quiver layer only, worn on back position, brown leather, arrow fletching visible at top, side view, limited palette, dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, transparent background, 64x64
```

**Layer 5 — Bow (held in hand, separate layer)**
```
wooden longbow layer only, held at side grip position, simple curve, side view, limited palette, dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, transparent background, 64x64
```

**Animation passes needed per base body:**
```
idle animation, 4 frames, subtle breathing motion, loop
walk cycle, 6 frames, side view, weight shift left to right
draw bow animation, 4 frames, arm pulling back motion
fire bow animation, 2 frames, release and recoil
hit reaction, 2 frames, flinch backward
death animation, 4 frames, collapse
```

**Over-the-shoulder combat view (separate asset, not the side-view character):**
```
archer character from behind, over the shoulder view, hood visible from back, 
quiver on back visible, bow arm extended to left side, standing combat stance, 
limited palette, dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, 
transparent background, 96x96
```

---

## 👹 Enemies — Grimwood Fringe (Zone 1A)

Each enemy needs the standard 5-pass animation set: idle, walk, attack, hit, death. Base prompt shown — apply animation suffix per pass.

**Grimwood Brigand**
```
human bandit enemy, mismatched leather armor, short sword, scruffy appearance, 
side view, limited palette, dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, 
transparent background, 64x64
```

**Forest Wolf**
```
wild wolf enemy, grey-brown fur, lean build, bared teeth, four-legged stance, 
side view, limited palette, dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, 
transparent background, 64x48
```

**Poacher**
```
human poacher enemy, hunting leathers, crossbow weapon, hood up, 
side view, limited palette, dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, 
transparent background, 64x64
```

**Grimwood Bear**
```
forest bear enemy, dark brown fur, large hulking build, claws visible, 
side view, limited palette, dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, 
transparent background, 80x64
```

**Bandit Scout (Elite)**
```
elite bandit scout enemy, reinforced leather armor with metal studs, hooded, 
dual daggers, slightly larger and more detailed than common bandit, subtle golden 
trim to denote elite status, side view, limited palette, dark pixel outline, 
HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, transparent background, 64x64
```

**Aldric the Poacher King (Boss)**
```
boss enemy, barrel-chested bandit leader, mismatched plate armor, large modified 
crossbow, oversized hunting knife at belt, imposing stance, larger than standard 
enemy silhouette, side view, limited palette, dark pixel outline, Kingdom Two Crowns 
pixel art style, transparent background, 96x96
```

---

## 👹 Enemies — Saltmarsh Shore (Zone 1B)

**Saltmarsh Smuggler**
```
human smuggler enemy, dark coastal clothing, cutlass weapon, weathered look, 
side view, limited palette, dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, 
transparent background, 64x64
```

**Shore Crab**
```
giant shore crab enemy, hardened shell, large pincers, low crouched stance, 
side view, limited palette, dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, 
transparent background, 64x40
```

**Coastal Poacher**
```
human coastal poacher enemy, fishing net weapon, oilskin coat, 
side view, limited palette, dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, 
transparent background, 64x64
```

**Saltmarsh Serpent**
```
coastal sea serpent enemy, long sinuous body, dark green scales, partially 
coiled stance, side view, limited palette, dark pixel outline, Kingdom Two Crowns 
pixel art style, transparent background, 96x48
```

**Tide Lurker (Elite)**
```
elite aquatic creature enemy, humanoid amphibious form, barnacle-covered skin, 
glowing eyes, subtle blue elite trim, side view, limited palette, dark pixel outline, 
HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, transparent background, 64x64
```

**Smuggler Captain (Elite)**
```
elite smuggler captain enemy, ornate coat, tricorn hat, rapier weapon, 
confident stance, subtle gold elite trim, side view, limited palette, 
dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, transparent background, 64x64
```

**The Saltmother (Boss)**
```
boss enemy, massive coastal serpent, ancient barnacle-scarred scales, 
coiled imposing form, glowing eyes, larger than standard enemy silhouette, 
side view, limited palette, dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, 
transparent background, 128x96
```

---

## 🌍 Environments — Backdrops

**Grimwood Fringe — Combat Backdrop**
```
forest clearing background, pine and oak trees, dirt path, dappled sunlight, 
distant campfire smoke, side view scene composition, limited palette, 
HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, 16:9, no characters
```

**Grimwood Fringe — Traversal Backdrop**
```
wide forest landscape, layered tree depth, worn path winding through, 
distant mountains, limited palette, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, 
16:9, no characters
```

**Saltmarsh Shore — Combat Backdrop**
```
coastal cove background, rocky cliffs, tide pools, grey overcast sky, 
side view scene composition, limited palette, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, 
16:9, no characters
```

**Saltmarsh Shore — Traversal Backdrop**
```
wide coastal landscape, cliff edges, distant sea, scattered driftwood, 
limited palette, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, 16:9, no characters
```

**Aldric's Warren — Dungeon Interior**
```
bandit camp cave interior tileset, wooden support beams, scattered crates, 
torchlight, dirt floor, modular tile pieces, limited palette, 
HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, no characters
```

**Crestfall Cove — Dungeon Interior**
```
coastal smuggler cave interior tileset, wooden crates and barrels, 
hanging nets, torchlight, damp stone floor, modular tile pieces, 
limited palette, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, no characters
```

---

## 📦 Items — Gathering Resources

**Foraging Set**
```
item icon set, fantasy herbs and botanicals: common herb, ironwort, 
wild berry cluster, thornroot, small flat icons, limited palette, 
dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, transparent background, 32x32
```

**Trapping Set**
```
item icon set, animal pelts and parts: rabbit pelt, fox pelt, deer hide, 
boar tusk, wolf pelt, small flat icons, limited palette, dark pixel outline, 
HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, transparent background, 32x32
```

**Dredging Set**
```
item icon set, fish and aquatic items: perch, carp, pearl, small flat icons, 
limited palette, dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, 
transparent background, 32x32
```

**Rare Materials — Crude Tier**
```
item icon, crude raw amber chunk, golden orange translucent resin, 
irregular shape, limited palette, dark pixel outline, Kingdom Two Crowns 
pixel art style, transparent background, 32x32
```
```
item icon, crude uncut gemstone, grey-blue rough stone, irregular fracture lines, 
limited palette, dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, 
transparent background, 32x32
```
```
item icon, crude phantom pelt, ghostly pale fur with faint blue glow, 
limited palette, dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, 
transparent background, 32x32
```
```
item icon, crude abyssal pearl, dark teal pearl with faint shimmer, 
limited palette, dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, 
transparent background, 32x32
```
```
item icon, crude void spore, dark purple fungal spore pod, faint glow, 
limited palette, dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, 
transparent background, 32x32
```

---

## 🧪 Items — Processing Output

**Alchemy Set**
```
item icon set, glass potion bottles: healing draught (red liquid), 
antidote vial (green liquid), poison coating (purple liquid), corked tops, 
limited palette, dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, 
transparent background, 32x32
```

**Cookery Set**
```
item icon set, cooked food items: roasted rabbit on skewer, herb broth in bowl, 
venison stew in pot, small flat icons, limited palette, dark pixel outline, 
HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, transparent background, 32x32
```

---

## ⚔️ Items — Equipment (Layered for Character Rendering)

**Bow Tiers (each as separate generation)**
```
item icon and equipped layer, bronze shortbow, simple wood and metal, 
crude quality, limited palette, dark pixel outline, Kingdom Two Crowns 
pixel art style, transparent background, 64x64
```
```
item icon and equipped layer, iron reinforced bow, sturdier limbs, 
rough quality, limited palette, dark pixel outline, Kingdom Two Crowns 
pixel art style, transparent background, 64x64
```
```
item icon and equipped layer, steel longbow, refined curves, polished finish, 
refined quality, limited palette, dark pixel outline, Kingdom Two Crowns 
pixel art style, transparent background, 64x64
```

**Quiver Tiers**
```
item icon and equipped back layer, standard leather quiver, brown leather, 
visible arrow fletching, crude quality, limited palette, dark pixel outline, 
HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, transparent background, 64x64
```
```
item icon and equipped back layer, reinforced quiver, metal-trimmed leather, 
rough quality, limited palette, dark pixel outline, Kingdom Two Crowns 
pixel art style, transparent background, 64x64
```

**Leather Armor Pieces (Crude tier shown — repeat per tier)**
```
item icon and equipped layer set, crude leather armor: chest piece, 
helm, boots, gloves, rough stitching, worn brown leather, limited palette, 
dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, transparent background, 64x64
```

---

## 🖼️ UI Elements

**Currency Icons**
```
item icon, silver coin with grimoire sigil engraving, 
limited palette, dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, 
transparent background, 24x24
```
```
item icon, gold coin with grimoire sigil engraving, 
limited palette, dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, 
transparent background, 24x24
```

**Quality Tier Badges**
```
small corner badge icon set, quality tier indicators: grey crude badge, 
white rough badge, green refined badge, blue pristine badge, purple masterwork 
badge, small gem-shaped icons, limited palette, dark pixel outline, 
HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, transparent background, 16x16
```

**Grimoire Visuals**
```
item icon and equipped visual, leather-bound spellbook, forest green cover, 
golden clasp, glowing faint aura, Sharpshot Grimoire, limited palette, 
dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, transparent background, 48x48
```
```
item icon and equipped visual, leather-bound spellbook, amber brown cover, 
worn edges, glowing faint aura, Lone Wanderer Grimoire, limited palette, 
dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, transparent background, 48x48
```

---

## 🎬 Onboarding Panels

**World Intro Panel 1**
```
wide illustrated scene, fantasy world overview, forest mountain and coastline 
visible, small lone figure in foreground, atmospheric lighting, 
limited palette, dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, 16:9
```

**World Intro Panel 2**
```
illustrated scene, several leather-bound grimoires resting on wooden table, 
each glowing a different color, candlelight, limited palette, dark pixel outline, 
HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, 16:9
```

**World Intro Panel 3**
```
illustrated scene, forest path entrance, worn dirt trail, distant campfire 
glow, dusk lighting, limited palette, dark pixel outline, Kingdom Two Crowns 
pixel art style, 16:9
```

**Grimoire Selection Room**
```
illustrated scene, stone chamber interior, candlelit table with multiple 
glowing grimoires arranged in a row, warm amber lighting, limited palette, 
dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, 16:9
```

---

## 📋 Generation Order Recommendation

1. **Warden base body + animations** — get the core character locked first, everything else compares against it
2. **Bow + Quiver layers** — test the layering approach works in Unity before generating more equipment
3. **13 Tier 1 enemies** — batch these together, same prompt structure each time
4. **Gathering/Processing item icons** — quick wins, small and simple
5. **Environments** — needed once character and enemies work in-engine
6. **UI elements** — can run in parallel with above since it's a separate kit purchase + custom icons
7. **Onboarding panels** — lowest priority, can use rough placeholders until everything else is solid

---

*Document version 0.2 — Phase 1 Sprite AI Prompt Library*
*Add new prompts here as Phase 2+ art work begins*
