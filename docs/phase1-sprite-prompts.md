## 📐 Sprite Sizing Reference

These rules apply to ALL phases. When in doubt refer here.

| Asset type | Generation size | Notes |
|-----------|----------------|-------|
| Character (standard) | 256×256 | Full body, transparent background, PPU 100 in Unity |
| Character (boss/large) | 320×320 | Noticeably larger silhouette than standard |
| Enemy (standard) | 256×256 | Match character scale — all enemy types including quadrupeds |
| Enemy (boss) | 320×320 | Zone bosses and dungeon bosses |
| Item icon | 64×64 cell | Atlas sheets: 4-wide grid, 256px wide total |
| Equipped layer (weapon/armor) | 256×256 | Composited over character in Unity |
| Debuff icon | 64×64 | 4×1 atlas: 3 active icons + 1 spare = 256×64 sheet |
| Quality badge | 32×32 | Corner overlay, 6×1 atlas = 192×32 sheet |
| Currency icon | 48×48 | SM + GM individual files |
| Talent nav icon | 48×48 | Per talent, individual files |
| Grimoire icon | 96×96 | Per Grimoire, individual files |
| Over-shoulder player | 256×256 | Back-facing, same as standard character |
| Onboarding panels | 1920×1080 | Landscape, painterly/HD (not pixel art) |
| Zone card thumbnail | 576×240 | Cinemascope crop from combat backdrop |
| Combat backdrop | 1920×1080 | Per layer — generate each parallax layer separately |
| App icon | 1024×1024 | App store requirement |
| Loading / splash | 1920×1080 | First impression |

**Unity import per asset type:**
- Characters/enemies: Point filter, PPU 100, Read/Write Enabled (weak point mask), Max Texture 2048 (4096 for bosses)
- Item icon atlases: Point filter, Sprite Mode Multiple, Slice Grid by Cell Size 64×64
- Backgrounds: Bilinear filter, Max Texture 4096, Lossless compression
- UI icons (talent, currency, Grimoire): Point filter, Sprite Mode Single

**Atlas sheet math:**
cells wide × 64 = sheet width · cells tall × 64 = sheet height
Example: 4×4 grid = 256×256 · 4×2 grid = 256×128 · 4×1 grid = 256×64

**Layer.ai generation model:**
- Backgrounds: FLUX or painterly model — never the pixel art model
- All sprites (characters, enemies, icons): 16-bit Pixel or Grimoire-HD2D-v1 (after training)
- Never mix workflows — background model for backgrounds, sprite model for sprites

---

## 📋 Sprite Atlas Prompt Format

All item icons are generated as **atlas sheets** — multiple icons in a uniform grid — not individual files. Use this format for all item icon generation:

**Standard atlas prompt template:**
```
item icon sheet, [NxN] grid layout, [category] items:
[item1], [item2], [item3], [item4],
[item5], [item6], [item7], empty slot,
each icon 64x64px in a uniform grid, small flat icons,
limited palette, dark pixel outline,
HD-2D pixel art style, Octopath Traveler-inspired,
transparent background, total sheet [width]x[height]
```

**Sheet size formula:** cells wide × 64 = width · cells tall × 64 = height
- 4×4 grid = 256×256
- 4×2 grid = 256×128
- 4×1 grid = 256×64

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
warden archer base body, neutral skin tone, simple tunic, idle pose, side view, limited palette, dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, transparent background, 256x256
```

**Layer 2 — Hood/Cloak (Sharpshot variant)**
```
hooded cloak layer only, forest green fabric, worn edges, fits over base body silhouette, side view, limited palette, dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, transparent background, 256x256
```

**Layer 3 — Hood/Cloak (Lone Wanderer variant)**
```
hooded cloak layer only, amber and brown fabric, ragged edges, fits over base body silhouette, side view, limited palette, dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, transparent background, 256x256
```

**Layer 4 — Quiver (worn on back, separate layer)**
```
leather quiver layer only, worn on back position, brown leather, arrow fletching visible at top, side view, limited palette, dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, transparent background, 256x256
```

**Layer 5 — Bow (held in hand, separate layer)**
```
wooden longbow layer only, held at side grip position, simple curve, side view, limited palette, dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, transparent background, 256x256
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
transparent background, 256x256
```

---

## 👹 Enemies — Grimwood Fringe (Zone 1A)

Each enemy needs the standard 5-pass animation set: idle, walk, attack, hit, death. Base prompt shown — apply animation suffix per pass.

**Grimwood Brigand**
```
human bandit enemy, mismatched leather armor, short sword, scruffy appearance, 
side view, limited palette, dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, 
transparent background, 256x256
```

**Forest Wolf**
```
wild wolf enemy, grey-brown fur, lean build, bared teeth, four-legged stance, 
side view, limited palette, dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, 
transparent background, 256x256
```

**Poacher**
```
human poacher enemy, hunting leathers, crossbow weapon, hood up, 
side view, limited palette, dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, 
transparent background, 256x256
```

**Grimwood Bear**
```
forest bear enemy, dark brown fur, large hulking build, claws visible, 
side view, limited palette, dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, 
transparent background, 256x256
```

**Bandit Scout (Elite)**
```
elite bandit scout enemy, reinforced leather armor with metal studs, hooded, 
dual daggers, slightly larger and more detailed than common bandit, subtle golden 
trim to denote elite status, side view, limited palette, dark pixel outline, 
HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, transparent background, 256x256
```

**Aldric the Poacher King (Boss)**
```
boss enemy, barrel-chested bandit leader, mismatched plate armor, large modified 
crossbow, oversized hunting knife at belt, imposing stance, larger than standard 
enemy silhouette, side view, limited palette, dark pixel outline, Kingdom Two Crowns 
pixel art style, transparent background, 256x256
```

---

## 👹 Enemies — Saltmarsh Shore (Zone 1B)

**Saltmarsh Smuggler**
```
human smuggler enemy, dark coastal clothing, cutlass weapon, weathered look, 
side view, limited palette, dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, 
transparent background, 256x256
```

**Shore Crab**
```
giant shore crab enemy, hardened shell, large pincers, low crouched stance, 
side view, limited palette, dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, 
transparent background, 256x256
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
coiled stance, side view, limited palette, dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, transparent background, 256x256
```

**Tide Lurker (Elite)**
```
elite aquatic creature enemy, humanoid amphibious form, barnacle-covered skin, 
glowing eyes, subtle blue elite trim, side view, limited palette, dark pixel outline, 
HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, transparent background, 256x256
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
boar tusk, wolf pelt, small flat icons, 4x2 icon grid, limited palette, dark pixel outline, 
HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, transparent background, total sheet 256x128, each icon 64x64
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
pixel art style, transparent background, 64x64
```
```
item icon, crude uncut gemstone, grey-blue rough stone, irregular fracture lines, 
limited palette, dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, 
transparent background, 64x64
```
```
item icon, crude phantom pelt, ghostly pale fur with faint blue glow, 
limited palette, dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, 
transparent background, 64x64
```
```
item icon, crude abyssal pearl, dark teal pearl with faint shimmer, 
limited palette, dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, 
transparent background, 64x64
```
```
item icon, crude void spore, dark purple fungal spore pod, faint glow, 
limited palette, dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, 
transparent background, 64x64
```

---

## 🧪 Items — Processing Output

**Alchemy Set**
```
item icon set, glass potion bottles: healing draught (red liquid), 
antidote vial (green liquid), poison coating (purple liquid), corked tops, 
limited palette, dark pixel outline, HD-2D pixel art style, 4x1 icon grid, transparent background, total sheet 256x64, each icon 64x64
```

**Cookery Set**
```
item icon set, cooked food items: roasted rabbit on skewer, herb broth in bowl, 
venison stew in pot, small flat icons, 4x2 icon grid, limited palette, dark pixel outline, 
HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, transparent background, total sheet 256x128, each icon 64x64
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
transparent background, 48x48
```
```
item icon, gold coin with grimoire sigil engraving, 
limited palette, dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, 
transparent background, 48x48
```

**Quality Tier Badges**
```
small corner badge icon set, quality tier indicators: grey crude badge, 
white rough badge, green refined badge, blue pristine badge, purple masterwork 
badge, small gem-shaped icons, limited palette, dark pixel outline, 
HD-2D pixel art style, 6x1 grid, transparent background, total sheet 192x32, each badge 32x32
```

**Grimoire Visuals**
```
item icon and equipped visual, leather-bound spellbook, forest green cover, 
golden clasp, glowing faint aura, Sharpshot Grimoire, limited palette, 
dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, transparent background, 96x96
```
```
item icon and equipped visual, leather-bound spellbook, amber brown cover, 
worn edges, glowing faint aura, Lone Wanderer Grimoire, limited palette, 
dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, transparent background, 96x96
```

---

## 🎬 Onboarding Panels

**World Intro Panel 1**
```
wide illustrated scene, fantasy world overview, forest mountain and coastline 
visible, small lone figure in foreground, atmospheric lighting, 
limited palette, dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, 1920x1080
```

**World Intro Panel 2**
```
illustrated scene, several leather-bound grimoires resting on wooden table, 
each glowing a different color, candlelight, limited palette, dark pixel outline, 
HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, 1920x1080
```

**World Intro Panel 3**
```
illustrated scene, forest path entrance, worn dirt trail, distant campfire 
glow, dusk lighting, limited palette, dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, 1920x1080
```

**Grimoire Selection Room**
```
illustrated scene, stone chamber interior, candlelit table with multiple 
glowing grimoires arranged in a row, warm amber lighting, limited palette, 
dark pixel outline, HD-2D pixel art style — full-body realistic proportions, Octopath Traveler-inspired atmospheric lighting, 1920x1080
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

*Document version 0.4 — Phase 1 Sprite AI Prompt Library*
*Sizes reconciled to art-asset-requirements.md v0.5 from repo*
*Add new prompts here as Phase 2+ art work begins*

---

## 👹 Enemies — Phase 2 Sprite Prompts

> **Version note:** Phase 2 enemies follow the same style suffix as Phase 1.
> Use approved Phase 1 enemy sprites as style reference at 30–40% similarity
> in Layer.ai to maintain visual consistency across tiers.
> All sprites: 256×256 standard, 320×320 bosses. Transparent background.
> Point filter, PPU 100, Read/Write Enabled in Unity.

---

## 👹 Enemies — Ashfen Mire (Zone 2A)

**Palette:** Desaturated greens, greys, sickly yellows.
Bioluminescent blue-green accents on undead enemies.
Dead trees, bog water, swamp atmosphere throughout.
Reference Phase 1 style but shift palette toward cold desaturated tones.

---

**Bogwalker Skeleton**
```
humanoid skeleton enemy, tattered bog-soaked rags, one arm missing at shoulder,
bones stained dark green-grey from swamp submersion, wisps of bog gas rising,
idle upright stance, subtle forward lean, side view,
skull clearly defined at top 20% of sprite — Subtle weak point tier,
desaturated green-grey palette, bioluminescent blue-green accent on eye sockets,
dark pixel outline, HD-2D pixel art style — full-body realistic proportions,
Octopath Traveler-inspired atmospheric lighting, transparent background, 256x256
```
*Weak point mask: white oval covering skull — top 20% of sprite height.*

---

**Ashfen Treant**
```
twisted dead tree given crude humanoid form, gnarled branch limbs,
hollow face carved into bark with empty dark eye sockets,
root cluster visible at chest center — tangled mass of roots (Hidden weak point),
no glow on weak point — Hidden tier, players learn over time,
bark texture heavy and detailed, patches of dead moss,
wide stable stance, arms slightly raised, side view,
desaturated dark brown and grey palette, dead wood tones,
dark pixel outline, HD-2D pixel art style — full-body realistic proportions,
Octopath Traveler-inspired atmospheric lighting, transparent background, 256x256
```
*Weak point mask: oval covering root mass at center chest — no glow rendered on sprite.*

---

**Mire Wraith**
```
translucent ghostly humanoid form, body partially see-through,
spectral core — glowing green-white orb visible through translucent chest,
flowing ragged ethereal robes trailing below body, wispy edges,
Obvious weak point — core always pulsing green-white glow,
arms outstretched in drifting pose, slight forward tilt, side view,
desaturated blue-green and white palette, ghostly translucency,
dark pixel outline, HD-2D pixel art style — full-body realistic proportions,
Octopath Traveler-inspired atmospheric lighting, transparent background, 256x256
```
*Weak point mask: circle at sprite center covering spectral core — ~25% of sprite area.*

---

**Bog Lurker**
```
amphibious predator, frog-crocodile hybrid, low to ground wide body,
large wide jaw with visible teeth, four squat powerful legs,
mottled green-brown skin, bog water dripping from body,
small eye positioned top-right of head — Hidden weak point, no glow,
aggressive low crouch attack stance, wide mouth open, side view,
murky green-brown swamp palette, wet skin sheen,
dark pixel outline, HD-2D pixel art style — full-body realistic proportions,
Octopath Traveler-inspired atmospheric lighting, transparent background, 256x256
```
*Weak point mask: tiny circle at eye position — top-right of sprite, Hidden tier.*

---

**Rotting Soldier**
```
armored humanoid skeleton in corroded plate armor, heavy decay,
visor helm with narrow eye slit gap — Subtle weak point,
sword held at side, shield arm raised, military stance, side view,
armor heavily corroded and patched with rust and bog stain,
visor slit pulses faintly when attacking — Subtle tier behavior noted in sprite,
dark corroded steel and bone palette, swamp-stained,
dark pixel outline, HD-2D pixel art style — full-body realistic proportions,
Octopath Traveler-inspired atmospheric lighting, transparent background, 256x256
```
*Weak point mask: thin horizontal strip at visor slit — top 25% of sprite.*

---

**Spore Crawler**
```
small insectoid creature, six legs, chitinous shell,
large pulsing translucent spore sac on back — Obvious weak point, always glowing,
spore sac visibly bioluminescent purple-white, takes up significant back area,
compact body, legs spread low to ground, slightly raised sac visible clearly,
side view, small overall — smallest enemy in Ashfen Mire,
dark chitin body contrasting with glowing sac, purple-white bioluminescent palette,
dark pixel outline, HD-2D pixel art style — full-body realistic proportions,
Octopath Traveler-inspired atmospheric lighting, transparent background, 256x256
```
*Weak point mask: large oval covering full spore sac — center-back, ~35% of sprite.*

---

**Barrow Revenant (Elite)**
```
undead elite humanoid, powerful imposing form, ornate corroded armor,
ornate crown with large dark gemstone at center — Subtle weak point,
crown pulses faintly when attacking, dark gem flickers,
necrotic energy radiating from hands and shoulders,
amber-gold elite trim on crown and armor edges,
commanding aggressive stance, side view,
dark corroded armor and bone palette, necrotic purple-black energy accents,
amber elite trim, bioluminescent eye glow,
dark pixel outline, HD-2D pixel art style — full-body realistic proportions,
Octopath Traveler-inspired atmospheric lighting, transparent background, 256x256
```
*Weak point mask: oval covering crown area — top 20% of sprite.*

---

**Thornwood Ancient (Elite)**
```
massive ancient dead tree in humanoid form, far larger than standard Treant,
exposed glowing amber heartwood vein running through center chest — Obvious weak point,
heartwood always visibly glowing amber-gold, large and prominent,
thick gnarled branch arms with thorns along edges,
deep cracks in bark revealing amber glow beneath,
wide imposing stance, arms spread, side view,
very dark bark tones contrasting sharply with bright amber heartwood glow,
amber-gold elite trim on thorn tips,
dark pixel outline, HD-2D pixel art style — full-body realistic proportions,
Octopath Traveler-inspired atmospheric lighting, transparent background, 256x256
```
*Weak point mask: vertical line covering amber heartwood vein — center chest.*

---

**Ashfen Lich — Zone Boss (320×320)**
```
powerful undead lich sorcerer, tall imposing robed figure,
tattered dark robes with spectral wisps trailing from hem,
phylactery — glowing orb visible at chest center through robes — Obvious weak point,
orb pulses on 3-second cycle when vulnerable,
ornate horned helm, skeletal hands raised with crackling necrotic energy,
spectral crown of dark arcane power,
commanding threatening boss stance, floating slightly above ground, side view,
deep dark robes, pale bone, necrotic purple-black energy,
phylactery glows green-white when active,
dark pixel outline, HD-2D pixel art style — full-body realistic proportions,
Octopath Traveler-inspired atmospheric lighting, transparent background, 320x320
```
*Weak point mask: circle at phylactery — center chest. Only active during 3s window.*

---

## 👹 Enemies — Ironspine Reaches (Zone 2B)

**Palette:** Warm amber and rust, arid mountain light, harsh shadows.
Battered military gear on Outlaw enemies.
Stone and etched metal textures on Construct enemies.
Shift palette warm — oranges, rusts, earthy browns.

---

**Ironspine Deserter**
```
armored military deserter, battered plate armor with unit insignia scratched off,
closed visor helm with narrow slit gap — Subtle weak point,
tattered unit tabard visible beneath armor, worn and dirty,
sword and shield, defensive aggressive stance, side view,
visor slit briefly flickers when attacking — Subtle tier,
warm rust and amber armor tones, worn leather straps,
dark pixel outline, HD-2D pixel art style — full-body realistic proportions,
Octopath Traveler-inspired atmospheric lighting, transparent background, 256x256
```
*Weak point mask: thin horizontal strip at visor slit — top 25%.*

---

**Mountain Golem**
```
large stone humanoid construct, rough mountain granite body,
crystal core visible in chest cavity — Obvious weak point,
core glows blue-white constantly, large and unmissable,
heavy stone fists, wide powerful stance,
cracks in stone body with light leaking from core,
imposing wide build, side view,
grey mountain granite palette with blue-white crystal glow at core,
dark pixel outline, HD-2D pixel art style — full-body realistic proportions,
Octopath Traveler-inspired atmospheric lighting, transparent background, 256x256
```
*Weak point mask: large circle at chest core — always glowing.*

---

**Warband Raider**
```
heavy outlaw fighter, mismatched salvaged plate and leather armor,
horizontal gap in chest plate exposing gap between pieces — Subtle weak point,
gap pulses briefly when raider attacks — Subtle tier,
aggressive forward-leaning stance, axe raised, side view,
scarred face visible under open helm,
warm rust and brown salvaged armor palette, worn leather visible through gaps,
dark pixel outline, HD-2D pixel art style — full-body realistic proportions,
Octopath Traveler-inspired atmospheric lighting, transparent background, 256x256
```
*Weak point mask: thin horizontal band at chest gap — center sprite.*

---

**Rune Construct**
```
angular stone-and-metal construct, geometric angular body construction,
etched rune markings covering all surfaces,
central chest rune glows orange when charging attack — Obvious weak point,
mechanical jointed limbs, slightly hunched ready stance, side view,
rune glow visible at all times but most intense when attacking,
dark stone and tarnished metal palette, orange rune glow at center chest,
dark pixel outline, HD-2D pixel art style — full-body realistic proportions,
Octopath Traveler-inspired atmospheric lighting, transparent background, 256x256
```
*Weak point mask: circle at central chest rune — always glowing orange.*

---

**Ironspine Scout**
```
lightly armored hooded outlaw scout, leather armor only — no helm,
head completely exposed and unarmored — Hidden weak point, no glow or tell,
lean agile build, crouched ready stance, side view,
short blades at hip, hood partially obscuring face,
head clearly visible at top 25% with no protective covering,
warm brown leather and dark cloth palette,
dark pixel outline, HD-2D pixel art style — full-body realistic proportions,
Octopath Traveler-inspired atmospheric lighting, transparent background, 256x256
```
*Weak point mask: oval at head — top 25%. No glow — Hidden tier.*

---

**Mountain Hawk**
```
large predatory bird of prey, wingspan partially spread in threat display,
dark brown and amber feather coloring, sharp curved beak, fierce eyes,
wing joint clearly visible where wing connects to body — Hidden weak point,
no special marking or glow at wing joint — Hidden tier,
aggressive forward-facing display stance, wings partially raised, side view,
dark brown and amber feather palette, sharp contrast between wing and body,
dark pixel outline, HD-2D pixel art style — full-body realistic proportions,
Octopath Traveler-inspired atmospheric lighting, transparent background, 256x256
```
*Weak point mask: small oval at wing joint — center-side of sprite. Hidden tier.*

---

**Ironspine Warlord (Elite)**
```
elite military commander, heavy ornate plate armor, commanding imposing build,
distinctive red-plumed helm crest prominently displayed — Subtle weak point,
plume pulses subtly when warlord uses War Cry ability,
battle-scarred armor with unit markings, large two-handed war axe,
amber-gold elite trim on armor edges and plume base,
powerful aggressive stance, axe raised to shoulder, side view,
dark military steel armor palette with distinctive red plume,
amber elite trim accents,
dark pixel outline, HD-2D pixel art style — full-body realistic proportions,
Octopath Traveler-inspired atmospheric lighting, transparent background, 256x256
```
*Weak point mask: plume area — top 20% of sprite.*

---

**Awakened Stone Sentinel (Elite)**
```
massive animated stone guardian, ancient military sentinel design,
rune engravings covering entire body surface,
rune heart at chest — pulses brightly only when Stone Skin ability is down,
during Stone Skin: rune engravings fade and dim — Obvious tier but only when vulnerable,
enormous build, significantly larger than Mountain Golem,
ancient carved stone face, military posture, side view,
amber-gold elite trim on carved armor elements,
grey ancient stone palette, rune glow pulses amber-gold when vulnerable,
dark pixel outline, HD-2D pixel art style — full-body realistic proportions,
Octopath Traveler-inspired atmospheric lighting, transparent background, 256x256
```
*Weak point mask: center chest rune heart. Glow only renders when stoneSkinActive is false.*

---

**Ironspine Colossus — Zone Boss (320×320)**
```
enormous stone-and-rune construct boss, towering military fortress given form,
heavily armored stone exterior with rune etching across all surfaces,
rune heart exposed at chest — Obvious weak point,
rune heart only visible when Colossus rears back for heavy attack,
multiple cannon-like rune emitters on shoulders,
four massive stone legs, wide imposing stance, side view,
significantly larger than any standard enemy,
dark mountain granite and ancient metal palette,
amber-gold rune glow at heart and emitters, elite amber trim on carved edges,
dark pixel outline, HD-2D pixel art style — full-body realistic proportions,
Octopath Traveler-inspired atmospheric lighting, transparent background, 320x320
```
*Weak point mask: large oval at chest rune heart. Visible only when rearing back.*

---

## 👹 Dungeon Bosses — Phase 2

---

**Aldrath the Sunken — Mirefall Barrow Boss (320×320)**
```
ancient drowned lich, partially submerged aesthetic — waterlogged robes and armor,
bog water dripping from all surfaces, aquatic plants tangled in robes,
phylactery crown — ornate waterlogged crown with glowing gem at forehead,
crown pulses on vulnerability cycle — Obvious weak point during window,
spectral green fire in eye sockets, grasping waterlogged hands,
powerful imposing boss stance, side view,
deep waterlogged dark tones — grey-green drowned palette,
spectral green crown gem glow, bioluminescent bog accents,
dark pixel outline, HD-2D pixel art style — full-body realistic proportions,
Octopath Traveler-inspired atmospheric lighting, transparent background, 320x320
```

---

**Commander Valdris the Turncoat — Warden's Folly Boss (320×320)**
```
military commander turned traitor, ornate commander's plate armor,
unit insignia deliberately defaced and replaced with own mark,
shifting weak point — Phase 1 and 2: commander's chest insignia badge,
Phase 3 berserker mode: discards shield revealing unprotected head,
two weapon stances: sword and shield (Phase 1–2), dual blades (Phase 3),
battle-damaged armor showing evidence of hard-fought career,
imposing battle-worn commander stance, side view,
dark military steel with commander's personal amber-gold markings,
red personal banner motif on shield,
dark pixel outline, HD-2D pixel art style — full-body realistic proportions,
Octopath Traveler-inspired atmospheric lighting, transparent background, 320x320
```
*Two weak point masks needed: chest insignia (Phase 1–2) and head (Phase 3 berserker).*

---

## 📝 Phase 2 Sprite Generation Notes

**Ashfen Mire style anchor:**
Generate Bogwalker Skeleton first — most recognisable and clearly defined.
Use it as style reference (30% similarity) for all subsequent Ashfen enemies.
Desaturated green-grey palette with blue-green bioluminescent accents is the consistent thread.

**Ironspine Reaches style anchor:**
Generate Ironspine Deserter first — most straightforward humanoid.
Use it as style reference (30% similarity) for all subsequent Ironspine enemies.
Warm rust and amber with dark stone tones is the consistent thread.

**Weak point mask workflow:**
After approving each sprite — open in Aseprite, create a new layer named `weak_point_mask`,
paint white over the weak point region described in the prompt notes,
export as a separate PNG with `_mask` suffix.
Both sprite and mask go in the same Unity folder.

**Elite distinction:**
All Phase 2 elites use the same amber-gold elite trim approach as Phase 1.
Trim appears on armor edges, weapon accents, or distinctive features.
Amount of trim should be subtle — enough to distinguish, not enough to dominate.

**Boss scale:**
Both zone bosses (Lich, Colossus) and both dungeon bosses (Aldrath, Valdris) are 320×320.
They should feel noticeably larger than standard 256×256 enemies when placed at Z=10 in the scene.

---

*Document version 0.4 — Phase 1 and Phase 2 Sprite AI Prompt Library*
*Added: Phase 2 Ashfen Mire enemies (6 standard, 2 elite, 1 boss),*
*Ironspine Reaches enemies (6 standard, 2 elite, 1 boss),*
*Mirefall Barrow dungeon boss, Warden's Folly dungeon boss.*

---

## 🌍 Backgrounds — Zone Combat Backdrops

> **Model:** FLUX or painterly model — NOT the 16-bit pixel art model.
> Backgrounds are painterly/cinematic, not pixel art.
> Combat zones use a single 1920×1080 image — no parallax layers.
> Dungeons use 3 separate parallax layers for room scrolling.
>
> **Unity import:** Bilinear filter, Max Texture 4096, Lossless compression.
> **Zone card:** Crop the approved combat backdrop to 576×240
> (center of frame) — no separate generation needed.

---

### 🌲 Grimwood Fringe — Combat Backdrop

**File:** `Assets/Sprites/Backgrounds/Grimwood/grimwood_combat.png`
**Size:** 1920×1080

```
ancient dark fantasy forest combat arena, painterly concept art style,
towering ancient oak trees with gnarled roots, dappled golden light
filtering through dense canopy above,
mossy stone ruins partially swallowed by undergrowth in midground,
thick atmospheric ground fog at base of trees,
cool green and deep shadow palette with warm golden light shafts,
sense of depth — clear foreground ground plane, midground trees,
distant forest fading to atmospheric haze,
HD fantasy game background, cinematic composition,
no characters, no UI, no text, 1920x1080
```

**Zone card crop:** center 576×240 — captures midground tree line and ruins.

---

### 🌊 Saltmarsh Shore — Combat Backdrop

**File:** `Assets/Sprites/Backgrounds/Saltmarsh/saltmarsh_combat.png`
**Size:** 1920×1080

```
dark fantasy coastal combat arena, painterly concept art style,
weathered stone dock ruins on a rocky shoreline,
overcast sky with dramatic storm light breaking through clouds,
sea mist and salt spray in the air, tide pools and wet rock in foreground,
rotting dock timbers, rusted chains, barnacle-covered stone,
teal and grey coastal palette with cold light,
sense of depth — rocky foreground, ruined dock midground,
choppy sea horizon in far distance fading to grey haze,
HD fantasy game background, cinematic composition,
no characters, no UI, no text, 1920x1080
```

**Zone card crop:** center 576×240 — captures dock ruins and sea horizon.

---

### 🌿 Ashfen Mire — Combat Backdrop

**File:** `Assets/Sprites/Backgrounds/Ashfen/ashfen_combat.png`
**Size:** 1920×1080

```
dark fantasy swamp combat arena, painterly concept art style,
dead twisted trees rising from dark still bog water,
bioluminescent fungi and floating spores providing eerie blue-green glow,
sunken stone ruins barely visible through murky water and hanging moss,
thick oppressive atmosphere, low visibility beyond midground,
desaturated green-grey palette with cold bioluminescent blue-green accents,
sense of depth — dark bog water foreground, dead tree midground,
distant mire fading to murky atmospheric haze,
HD fantasy game background, cinematic composition,
no characters, no UI, no text, 1920x1080
```

**Zone card crop:** center 576×240 — captures dead trees and bioluminescent water.

---

### 🏔️ Ironspine Reaches — Combat Backdrop

**File:** `Assets/Sprites/Backgrounds/Ironspine/ironspine_combat.png`
**Size:** 1920×1080

```
dark fantasy arid mountain combat arena, painterly concept art style,
eroded stone ruins of a military outpost on a rocky mountain plateau,
harsh directional light from a low sun casting long shadows,
dust haze in the air, sparse dry scrub, crumbling fortification walls,
distant mountain peaks visible through amber dust haze,
warm amber and rust palette, baked stone and dry earth tones,
sense of depth — rocky rubble foreground, ruined walls midground,
mountain peaks fading into amber dust haze in far distance,
HD fantasy game background, cinematic composition,
no characters, no UI, no text, 1920x1080
```

**Zone card crop:** center 576×240 — captures ruined walls and mountain backdrop.

---

## 🏰 Dungeon Parallax Backgrounds

> Dungeons use 3 parallax layers because the player scrolls
> through rooms. Each layer moves at a different speed as the
> player advances, creating depth of field.
>
> Generate all 3 layers for each dungeon separately.
> Layers must be visually consistent — same lighting, same palette,
> same art direction — so they composite cleanly.
>
> Layer movement speeds (for Claude Code):
> - Far layer: 0.1× scroll speed (barely moves)
> - Mid layer: 0.4× scroll speed
> - Near layer: 0.8× scroll speed

---

### ⚰️ Mirefall Barrow — Dungeon Parallax (Phase 2)

**Folder:** `Assets/Sprites/Backgrounds/Ashfen/MirefallBarrow/`
**Theme:** Ancient stone burial barrow, submerged in bog water, torch and fungi lighting.

**Far Layer — Stone walls and torchlight**
**File:** `mirefall_far.png` — 1920×1080
```
ancient stone burial barrow interior, far background layer,
rough-hewn stone block walls with carved burial markings,
wall-mounted iron torch sconces casting warm orange light,
heavy shadows between torch pools, vaulted stone ceiling above,
dark desaturated stone palette with warm torch light accents,
painterly concept art style, no characters, seamlessly tileable horizontally,
1920x1080
```

**Mid Layer — Pillars, doorways, bog seepage**
**File:** `mirefall_mid.png` — 1920×1080
```
ancient stone burial barrow interior, mid background layer,
stone pillars with carved runes, arched stone doorways to side chambers,
bog water seeping through floor cracks and wall joints,
bioluminescent fungi clusters at pillar bases,
submerged grave markers partially visible through standing water,
same torch lighting as far layer, cooler tones near bog water,
painterly concept art style, no characters, seamlessly tileable horizontally,
1920x1080
```

**Near Layer — Floor detail and debris**
**File:** `mirefall_near.png` — 1920×1080
```
ancient stone burial barrow interior, near foreground layer,
cracked stone floor tiles with standing bog water in the cracks,
scattered bone fragments, rotted wood offerings, corroded grave goods,
bioluminescent fungi patches at floor level,
close-up stone texture, wet reflective floor surface,
warm torch and cold fungi lighting mixing at floor level,
painterly concept art style, no characters, seamlessly tileable horizontally,
1920x1080
```

---

### 🏯 Warden's Folly — Dungeon Parallax (Phase 2)

**Folder:** `Assets/Sprites/Backgrounds/Ironspine/WardensFolly/`
**Theme:** Abandoned military fortress, occupied by deserters, torchlit stone corridors.

**Far Layer — Fortress walls and arrow slits**
**File:** `wardens_folly_far.png` — 1920×1080
```
abandoned military fortress interior, far background layer,
thick stone fortress walls with narrow arrow slit windows,
harsh exterior light cutting through slits in shafts,
military banners — faded, some torn, hanging from upper walls,
iron wall brackets with torches, heavy stone construction,
warm amber torch light with cold light shafts from arrow slits,
painterly concept art style, no characters, seamlessly tileable horizontally,
1920x1080
```

**Mid Layer — Corridors, barricades, deserter camp details**
**File:** `wardens_folly_mid.png` — 1920×1080
```
abandoned military fortress interior, mid background layer,
stone corridor with improvised deserter barricades — stacked crates and furniture,
scratched-out unit insignia on walls, personal marks replacing them,
weapon racks — some empty, some still holding spears and shields,
bedrolls and camp detritus suggesting recent occupation,
same lighting as far layer, warmer near torch sources,
painterly concept art style, no characters, seamlessly tileable horizontally,
1920x1080
```

**Near Layer — Floor rubble and scattered equipment**
**File:** `wardens_folly_near.png` — 1920×1080
```
abandoned military fortress interior, near foreground layer,
stone floor with rubble and debris — broken pottery, scattered coins,
discarded military equipment — worn boots, torn gloves, broken sword hilts,
dried blood stains on stone, scorch marks from old fires,
cold stone floor texture, warm reflected torch light from above,
painterly concept art style, no characters, seamlessly tileable horizontally,
1920x1080
```

---

## 🏰 Guild Hall Prestige Backgrounds

> Single 1920×1080 image per prestige stage.
> Painterly FLUX model. Each replaces the previous as prestige increases.
> P0–P34 already generated this session — prompts below cover P35+.
> See session history for P0–P34 prompts.

---

**P35–49 — Fortress**
**File:** `Assets/Sprites/Backgrounds/GuildHall/guild_p35.png`
```
dark fantasy guild fortress, painterly concept art style,
stone fortress hall interior, high vaulted ceilings, guild banner prominently displayed,
long wooden feasting tables with members eating and drinking,
weapons mounted on walls, fireplace roaring at far end,
warm amber torch and firelight, sense of organised military strength,
HD fantasy game background, no UI, no text, 1920x1080
```

**P50–74 — Castle**
**File:** `Assets/Sprites/Backgrounds/GuildHall/guild_p50.png`
```
dark fantasy guild castle great hall, painterly concept art style,
grand stone castle interior, carved stone pillars, high arched windows,
elaborate guild tapestries on walls, long banquet tables fully set,
guild members in various activities — feasting, planning, sparring in background,
warm golden candlelight and fireplace, sense of established wealth and power,
HD fantasy game background, no UI, no text, 1920x1080
```

**P75–99 — Castle with Village**
**File:** `Assets/Sprites/Backgrounds/GuildHall/guild_p75.png`
```
dark fantasy guild castle with thriving village visible through grand windows,
painterly concept art style, elaborate great hall interior,
arched stone windows showing village lights and market below,
richly decorated hall — carved stonework, guild heraldry everywhere,
members and NPCs visible in background, prosperous busy atmosphere,
warm golden interior light contrasting with cool village exterior,
HD fantasy game background, no UI, no text, 1920x1080
```

**P100 — Stronghold Capital**
**File:** `Assets/Sprites/Backgrounds/GuildHall/guild_p100.png`
```
dark fantasy guild stronghold capital throne room, painterly concept art style,
massive vaulted throne room, carved stone columns lining the hall,
guild throne at far end on raised dais, guild banner above,
stained glass windows casting coloured light across polished stone floors,
sense of absolute prestige and power — the pinnacle of guild achievement,
warm dramatic light, deep rich colours, epic scale,
HD fantasy game background, no UI, no text, 1920x1080
```

---

## 🎬 Onboarding Panels

> Painterly style — not pixel art.
> Used in the onboarding flow introducing the world.
> Can use rough painterly style — these are seen once.

**World Intro Panel 1 — Wide world shot**
**File:** `Assets/UI/Onboarding/onboarding_01.png`
```
dark fantasy world establishing shot, painterly concept art style,
wide vista of a medieval fantasy landscape — forest, coastline, mountains visible,
dramatic sky with god rays breaking through clouds,
sense of a vast world to explore, adventurous and inviting tone,
deep rich colours, painterly brushwork, cinematic composition,
no characters, no UI, no text, 1920x1080
```

**World Intro Panel 2 — Grimoires on table**
**File:** `Assets/UI/Onboarding/onboarding_02.png`
```
dark fantasy study interior, painterly concept art style,
stone desk with multiple leather-bound grimoires laid open,
glowing magical runes visible on pages, candlelight illuminating the scene,
quill, ink, scattered parchment notes, arcane instruments,
warm amber candlelight, sense of ancient knowledge and power,
no characters, no UI, no text, 1920x1080
```

**World Intro Panel 3 — Grimwood entrance path**
**File:** `Assets/UI/Onboarding/onboarding_03.png`
```
dark fantasy forest path, painterly concept art style,
ancient forest path leading into deep shadow between enormous trees,
dappled light filtering through canopy, inviting but slightly foreboding,
mossy stones and roots framing the path edges,
a sense of the adventure beginning — the player's first step,
cool green and warm gold palette, painterly brushwork,
no characters, no UI, no text, 1920x1080
```

**Grimoire Selection Room**
**File:** `Assets/UI/Onboarding/onboarding_grimoire_select.png`
```
dark fantasy circular stone chamber, painterly concept art style,
seven stone pedestals arranged in a circle, each holding a glowing grimoire,
each grimoire a different colour — green, amber, blue, purple, red, black, teal,
magical light rising from each book, arcane symbols floating above them,
vaulted stone ceiling with skylight above casting dramatic light,
the player's choice moment — inviting and dramatic,
no characters, no UI, no text, 1920x1080
```

---

*Document version 0.4 — Phase 1 and Phase 2 Sprite and Background AI Prompt Library*
