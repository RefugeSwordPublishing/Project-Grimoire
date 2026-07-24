# Project Grimoire, Art Asset Requirements by Phase
### Version 0.5

> **Art Style: HD-2D (Grimoire Variant)**
> Inspired by Octopath Traveler's cinematic HD-2D approach, painterly pre-rendered backgrounds with rich atmospheric depth, expressive lighting, and strong zone identity, but with two key distinctions: **full-body realistic-proportion pixel art characters** (not chibi) and a **front-to-back scrolling camera perspective** (not side-scrolling plane).

---

## Art Direction Reference

### Overall Style, HD-2D Grimoire Variant
| Element | Octopath Traveler | Project Grimoire |
|---------|-----------------|-----------------|
| Backgrounds | High-res painterly, parallax depth | Same, cinematic, layered, atmospheric |
| Characters | Small chibi pixel sprites | Full-body realistic/semi-realistic pixel art |
| Camera | Side-scrolling plane | Front-to-back, player moves into the screen |
| Depth of field | Side-plane depth | Front-to-back depth, foreground blurs as player moves deeper |
| Lighting | Strong mood lighting | Same + heavy bloom on torches, magic, god rays |

### Background Environments
- High resolution, painterly/pre-rendered, each zone feels cinematic and distinct
- Layered parallax depth, multiple Z-depth layers (foreground, midground, background, skybox)
- Strong mood lighting per zone, torches, magic glows, environmental light sources
- Atmospheric particles per zone, fog, drifting embers, dust motes, rain, snow
- God rays and volumetric light where zone atmosphere warrants it

**Per-zone color grading (post-processing LUT per zone):**
| Zone | Color Grade | Atmosphere |
|------|------------|-----------|
| Grimwood Fringe | Cool greens, dappled light | Forest, filtered sunlight |
| Saltmarsh Shore | Teal/grey, sea haze | Coastal fog, salt spray |
| Ashfen Mire | Desaturated greens/grays | Swamp murk, sickly glow |
| Ironspine Reaches | Warm amber/rust | Arid mountain, dust haze |
| Dreadhollow (Tier 3) | Deep purple/black | Shadow and rot |
| Cinderpeak (Tier 3) | Orange/red, ember glow | Volcanic, ember particles |

### Character Art, Full-Body Pixel Art
Characters depart from Octopath's chibi proportions. Grimoire characters are:
- **Realistic or semi-realistic body proportions**, closer to modern RPG character art in pixel form
- **Detailed at gameplay scale**, readable silhouette from distance, detailed up close
- **Expressive**, facial features readable, posture communicates class identity
- **Reference:** Think Blasphemous, Dead Cells, or Hollow Knight's proportional detail applied to pixel art RPG characters

### Camera & Scrolling
- **Front-to-back perspective**, player character moves into the screen depth, not left/right
- **Zone traversal:** World scrolls as player moves deeper, foreground elements pass by
- **Depth of field:** Foreground elements blur as player advances, background has atmospheric haze
- **Combat:** Over-the-shoulder view consistent with traversal direction, player behind, enemy ahead in the depth plane

### Post-Processing Stack (Unity URP)
| Effect | Setting | Notes |
|--------|---------|-------|
| Bloom | Heavy on light sources | Torches, magic effects, environmental lighting, rune glows |
| Depth of Field | Front-to-back tuned | Foreground blur on traversal, combat has shallow DOF on enemy |
| Color Grading | Per-zone LUT | Swap LUT on zone transition |
| Atmospheric Particles | Per-zone particle systems | Fog, embers, dust, rain, always subtle, never obstructive |
| God Rays | Volumetric where appropriate | Forest clearings, dungeon shafts of light, boss rooms |
| Chromatic Aberration | Subtle on hit effects only | Not constant, used for impact feedback |
| Vignette | Light ambient vignette | Frames the scene, increases during boss fights |

---

## Layer.ai, Two Separate Generation Workflows

The HD-2D style means backgrounds and sprites are fundamentally different asset types. They use different Layer.ai models, different generation prompts, and different Unity import settings. **Never use the sprite workflow for backgrounds or vice versa.**

---

### Workflow A, Background Environments (Painterly / HD)

Backgrounds are NOT pixel art. They are high-resolution painterly environments, essentially concept art pieces that sit behind the pixel art characters.

**Layer.ai setup:**
- Use a high-quality painterly/concept art model, FLUX, Gemini 3.1 Flash Image, or similar
- Do NOT use pixel art models for backgrounds
- Do NOT use the custom Grimoire sprite model for backgrounds

**Generation approach:**
- Generate at 1920×1080 (full HD)
- Prompt for atmospheric environments, rich lighting, layered depth
- Generate each parallax layer separately (3-5 layers per zone)
- Layers from back to front: skybox → distant environment → midground scene → foreground detail → particle layer (Unity, not Layer.ai)

**Example prompt structure:**
```
[zone name] environment, [mood/atmosphere descriptor], dark fantasy medieval RPG,
painterly concept art style, cinematic lighting, [time of day],
atmospheric depth, god rays, [zone-specific color grade],
high resolution game background, no characters, no UI
```

**Example, Grimwood Fringe midground layer:**
```
Ancient forest clearing, dark fantasy medieval RPG, painterly concept art,
dappled sunlight through forest canopy, cool greens and amber light,
atmospheric fog in background, mossy ruins, cinematic depth of field,
game environment art, no characters
```

**Unity import settings for backgrounds:**
- Filter Mode: **Bilinear** (painterly, NOT point filter)
- Max Texture Size: **4096**
- Compression: **Lossless**
- Each parallax layer on its own `SpriteRenderer` at a different Z depth
- Post-processing (bloom, DOF, LUT) applies fully to background layers

---

### Workflow B, Characters, Enemies & Icons (Pixel Art)

All characters, enemies, and item icons are pixel art. These are the crisp sprites that float in front of the painterly backgrounds, the contrast between them is what creates the HD-2D look.

**Layer.ai setup, two stages:**

**Stage 1 (now): Use a pre-built Layer model**
Browse Layer's 40+ custom model library for the closest match to your style target. Look for: `dark fantasy pixel`, `pixel RPG`, `indie pixel art`, `retro game sprite`. Using a pre-built model immediately solves the style inconsistency problem (the bear issue) without needing training data.

**Stage 2 (after 10-15 approved sprites): Train your custom Grimoire model**
1. Generate Warden base body + 5-10 enemy sprites using the pre-built model
2. Refine in Aseprite until approved
3. In Layer: Models → Train Custom Model
4. Upload 10-20 approved sprites as training data
5. Name: `Grimoire-HD2D-v1`
6. Training time: ~30-60 minutes
7. All future prompts: append `using Grimoire-HD2D-v1 model`

From this point forward every character, enemy, and icon shares the same visual DNA, outline thickness, shading approach, color palette, pixel density, proportional conventions, automatically enforced by the model.

**Generation approach:**
- Characters/enemies: 256×256 with transparent background
- Item icons: generate as atlas sheets (4-wide grid, 64×64 cells, 256px wide total)
- Always include a reference image of an approved sprite as style anchor
- Use the approved Warden sprite as the style reference for all first-generation enemies

**Example prompt structure:**
```
[subject description], dark fantasy medieval RPG enemy sprite,
full-body pixel art, realistic proportions, transparent background,
[pose], [size reference], limited palette, dark pixel outline,
HD-2D pixel art style, [approved sprite] as style reference
```

**Style reference for animal enemies, critical addition:**
```
pixel art shading only, no realistic fur texture, no 3D rendering,
same pixel art style as [approved human enemy sprite]
```

**Unity import settings for sprites:**
- Filter Mode: **Point (no filter)**, hard pixel edges, no blur
- Compression: **None**
- Pixels Per Unit: **100**, must be consistent across ALL sprites
- Max Texture Size: **2048** (characters), **4096** (bosses)
- Sprite Mode: **Multiple** for sprite sheets, **Single** for individual sprites

---

### Why the contrast works

When both layers render together in Unity with post-processing active:
- The bloom from a torch in the background softly glows and bleeds into the scene
- The depth of field softens foreground background trees as the player moves deeper
- The Warden character stays **crisp and readable** in front of all of it, Point filter keeps hard pixel edges regardless of what the post-processing does to the layers behind

The characters are exempt from depth-of-field blur because they sit on their own sprite layer with a Z value that keeps them outside the DOF blur range. This is the core technique that makes HD-2D work, the post-processing affects the world, not the characters.

---

### Generation Order (start here)

```
1. Choose a pre-built Layer model from the library (closest to dark fantasy pixel RPG)
2. Generate Warden base body idle pose, 256×256
3. Refine in Aseprite until approved, this is your style anchor
4. Generate Grimwood Fringe midground background, 1920×1080 (painterly model)
5. Test both in Unity, verify the contrast reads correctly before generating more
6. Generate 5-10 enemies using Warden sprite as style reference
7. Once 10-15 sprites approved → train Grimoire-HD2D-v1 custom model
8. All subsequent sprites use Grimoire-HD2D-v1
9. Backgrounds continue using painterly model (never the sprite model)
```

---

*Path: `docs/art-asset-requirements.md`*

Project Grimoire targets both mobile and Steam/PC. Character sprites use realistic proportions at sufficient resolution to support HD-2D visual fidelity.

| Asset Type | Resolution | Notes |
|-----------|-----------|-------|
| Standard characters | **256x256** | Full-body realistic proportion pixel art |
| Standard enemies | **256x256** | Consistent with character scale |
| Elite enemies | **256x256** | Visual distinction via design not size |
| Zone bosses | **320x320** | Larger silhouette, more imposing presence |
| Raid bosses | **512x512** | Screen-filling, maximum detail |
| Item icons (inventory) | **64x64** | Examined closely in inventory |
| Rare material icons | **64x64** | High-value items deserve detail |
| Currency icons | **48x48** | SM and GM coins |
| Quality tier badges | **32x32** | Corner overlay, needs colorblind shape variants |
| Environment backdrops | **1920x1080** | Painterly/pre-rendered, HD-2D style |
| Background layers (parallax) | **1920x1080 per layer** | 3-5 layers per zone for parallax depth |
| Foreground elements | **Variable** | Trees, rocks, debris that blur with depth of field |
| Dungeon tilesets | **32x32 per tile** | Standard tileset grid |
| UI panel borders (9-slice) | **96x96** | Clean at higher DPI |
| UI nav icons | **48x48** | Bottom nav and HUD icons |
| Grimoire icons | **96x96** | Featured items, deserve detail |
| Onboarding panels | **1920x1080** | Full screen illustrated scenes |
| App icon | **1024x1024** | App store requirement |
| Loading screen / splash | **1920x1080** | First impression, full HD-2D scene |

### Unity Import Settings (apply to all sprites)
- **Filter Mode:** Point (no filter) for character/enemy/UI sprites
- **Filter Mode:** Bilinear for background environment layers (painterly, not pixel-art-strict)
- **Compression:** None for characters/enemies, Lossless for backgrounds
- **Pixels Per Unit:** 100 across all character/enemy sprites, must be consistent
- **Max Texture Size:** 2048 for standard sprites, 4096 for boss and background sprites
- **Sprite Mode:** Multiple (sprite sheets), Single (icons, backgrounds)

### Sprite Sheet Format
Characters and enemies exported as uniform grid sprite sheets:
- Each animation on its own row
- All frames same size (matching resolution standard above)
- Animations ordered: idle → walk → attack → hit → death
- Equipment layers as separate sprite sheets matching frame count exactly

### Background Layer Stack (per zone)
Each zone environment is composed of multiple layers rendered at different Z depths:
```
Layer 1, Skybox/far background (lowest parallax)
Layer 2, Distant environment (mountains, treeline)
Layer 3, Midground environment (primary scene)
Layer 4, Foreground details (rocks, near trees)
Layer 5, Particle systems (fog, embers, dust)
Layer 6, UI overlay
```
Depth of field blurs Layer 4 as player moves deeper, gives the front-to-back parallax feel.


### Sprite Atlas Organization, Item Icons

All item icons use a **Sprite Atlas (sheet) approach** rather than individual files. This reduces draw calls dramatically, critical for mobile performance when the inventory displays 70+ slots simultaneously.

**How it works in Unity:**
1. Generate icon sheet as a single image with uniform grid layout
2. Import as Sprite → Sprite Mode → Multiple
3. Sprite Editor → Slice → Grid by Cell Size (64x64)
4. Unity auto-slices into individually addressable sprites
5. Rename sprites in editor to semantic names (icon_perch, icon_carp etc.)
6. Adding new items: fill empty slots on existing sheet, re-import, re-slice, existing references don't break

**Sheet grid format for generation prompts:**
- Each cell: 64x64px
- Sheet layout: 4-wide grid (256px wide) × as many rows as needed
- Always include empty/blank slots at the end for future additions
- Total sheet width: 256px (4 icons wide), consistent across all sheets

**Sprite Atlas Master List:**

| Atlas File | Contents | Grid | Sheet Size |
|-----------|---------|------|-----------|
| `icons_gathering_foraging.png` | Common Herb, Ironwort, Wild Berry Cluster, Thornroot, Ashfen Spore, Mountain Herb, Frostbloom, empty | 4×2 | 256×128 |
| `icons_gathering_dredging.png` | Perch, Carp, Pearl, Deep Net catch, Murk Eel, Bog Pearl, Swamp Carp, empty | 4×2 | 256×128 |
| `icons_gathering_trapping.png` | Rabbit Pelt, Fox Pelt, Deer Hide, Boar Hide, Wolf Pelt, Mire Fox pelt, Snow Fox pelt, empty | 4×2 | 256×128 |
| `icons_gathering_felling.png` | Pine Log, Hardwood Log, Ashwood Log, Ironbark Log, Blightbark, empty, empty, empty | 4×2 | 256×128 |
| `icons_gathering_delving.png` | Iron Ore, Coal, Silver Ore, Gold Ore, Mithril Vein, Mountain Quartz, empty, empty | 4×2 | 256×128 |
| `icons_gathering_gleaning.png` | Battlefield Scrap, Runic Fragment, Lost Cache, empty, empty, empty, empty, empty | 4×2 | 256×128 |
| `icons_gathering_cultivation.png` | Wheat, Potato, Flax, Reed Paper, Moonflower, Worldseed, empty, empty | 4×2 | 256×128 |
| `icons_gathering_tracking.png` | Monster Sign scroll, Ancient Trail scroll, empty, empty | 4×1 | 256×64 |
| `icons_rare_materials_crude.png` | Crude Amber, Crude Gemstone, Crude Phantom Pelt, Crude Abyssal Pearl, Crude Void Spore, Crude Runic Cog, Crude Aetheric Filament, Crude Ancient Sigil | 4×2 | 256×128 |
| `icons_rare_materials_rough.png` | Rough tier, same 8 types | 4×2 | 256×128 |
| `icons_rare_materials_refined.png` | Refined tier, same 8 types | 4×2 | 256×128 |
| `icons_rare_materials_pristine.png` | Pristine tier, same 8 types | 4×2 | 256×128 |
| `icons_rare_materials_masterwork.png` | Masterwork tier, same 8 types | 4×2 | 256×128 |
| `icons_consumables_alchemy.png` | Minor Healing Draught, Antidote Vial, Poison Coating, Shadow Blend, empty, empty, empty, empty | 4×2 | 256×128 |
| `icons_consumables_cookery.png` | Roasted Rabbit, Herb Broth, Venison Stew, Hunter's Ration, empty, empty, empty, empty | 4×2 | 256×128 |
| `icons_equipment_weapons.png` | Bow, Sword, Battle Axe, Dagger, Spear, Staff, Wand, Felling Axe (one icon per weapon type) | 4×2 | 256×128 |
| `icons_equipment_armor_warden.png` | Leather Helm, Chest, Legs, Boots, Gloves (one icon per piece) | 4×2 | 256×128 |
| `icons_equipment_armor_vanguard.png` | Plate Helm, Chest, Legs, Boots, Gloves | 4×2 | 256×128 |
| `icons_equipment_armor_arcanist.png` | Vestment Cowl, Robe, Leggings, Boots, Gloves | 4×2 | 256×128 |
| `icons_tools.png` | Pickaxe, Felling Axe, Fishing Rod, Trapper's Kit, Smith's Hammer, Tanning Frame, Weaving Loom, empty | 4×2 | 256×128 |
| `icons_kits.png` | Inscription Set, Cookery Set, Alchemy Kit, Carpenter's Kit, empty, empty, empty, empty | 4×2 | 256×128 |
| `icons_currency_ui.png` | Silver Mark coin, Gold Mark coin, Inventory Slot Ticket, Quest Slot Ticket, Slaying Task Ticket, Exchange Slot Ticket, empty, empty | 4×2 | 256×128 |
| `icons_grimoires.png` | All 7 base game Grimoire book icons | 4×2 | 256×128 |
| `icons_debuffs.png` | Poison (coating DoTs), Barbed Bleed (arrow/thorn, Sharpshot), Hemorrhage Bleed (blood drop, Shadowblade) | 4×1 | 256×64 |
| `icons_quality_badges.png` | Crude, Rough, Refined, Pristine, Masterwork, Legendary badges (+ colorblind variants on rows below) | 4×4 | 256×256 |

> **Growth rule:** Each sheet has empty slots reserved for future items. When all slots fill, create a new sheet with the same naming convention (e.g. `icons_gathering_foraging_2.png`). Never expand sheet dimensions mid-project, keep all sheets at 256px wide for consistency.

---

## Phase 1, Launch Critical

This is what blocks Claude Code from having a playable build. Prioritize this list completely before touching Phase 2 art.

### Characters
| Asset | Resolution | Notes |
|-------|-----------|-------|
| Warden base body, idle, walk, draw bow, fire bow, hit reaction, death | 256x256 per frame | Side view, equipment layers composite on top |
| Warden over-the-shoulder view, idle, draw, fire, hit | 256x256 per frame | Separate asset for combat screen |
| Sharpshot cloak/hood layer | 256x256 per frame | Forest green, composites over base body |
| Lone Wanderer cloak/hood layer | 256x256 per frame | Amber/brown ragged, composites over base body |
| Quiver layer (back-worn) | 256x256 per frame | Separate layer, all animation frames |
| Bow layer, Crude/Rough/Refined tiers | 256x256 per frame | Held in hand, separate layer per quality tier |
| Leather Armor layer set, Crude/Rough/Refined | 256x256 per frame | Helm, chest, legs, boots, gloves each as separate layers |

> Layered approach: Unity composites base body + cloak + quiver + bow + armor at runtime. Each layer is a separate sprite sheet with matching frame count.

### Enemies, Tier 1 Zones Only
| Enemy | Zone | Resolution | Notes |
|-------|------|-----------|-------|
| Grimwood Brigand | Grimwood Fringe | 256x256 | idle, walk, attack, hit, death |
| Forest Wolf | Grimwood Fringe | 256x256 | idle, walk, attack, hit, death, quadruped |
| Poacher | Grimwood Fringe | 256x256 | idle, walk, attack, hit, death |
| Grimwood Bear | Grimwood Fringe | 256x256 | idle, walk, attack, hit, death, large build |
| Bandit Scout (Elite) | Grimwood Fringe | 256x256 | idle, walk, attack, hit, death + elite visual distinction |
| Aldric the Poacher King (Boss) | Grimwood Fringe | 320x320 | Full boss animation set, larger silhouette |
| Saltmarsh Smuggler | Saltmarsh Shore | 256x256 | idle, walk, attack, hit, death |
| Shore Crab | Saltmarsh Shore | 256x256 | idle, walk, attack, hit, death, low/wide stance |
| Coastal Poacher | Saltmarsh Shore | 256x256 | idle, walk, attack, hit, death |
| Saltmarsh Serpent | Saltmarsh Shore | 256x256 | idle, coil, strike, hit, death, sinuous body |
| Tide Lurker (Elite) | Saltmarsh Shore | 256x256 | idle, walk, attack, hit, death + elite distinction |
| Smuggler Captain (Elite) | Saltmarsh Shore | 256x256 | idle, walk, attack, hit, death + elite distinction |
| The Saltmother (Boss) | Saltmarsh Shore | 320x320 | Full boss animation set, large serpent |

> 13 enemies total for Phase 1. Batch together in Sprite AI, same style prompt, different descriptions. Use Warden base body as style reference for all generations.

### Environments / Backgrounds
| Asset | Resolution | Notes |
|-------|-----------|-------|
| Grimwood Fringe, combat backdrop | 1920x1080 | Forest clearing, over-the-shoulder framing |
| Grimwood Fringe, traversal/idle backdrop | 1920x1080 | Wide forest, zone selection screen |
| Saltmarsh Shore, combat backdrop | 1920x1080 | Coastal cliffs/cove |
| Saltmarsh Shore, traversal/idle backdrop | 1920x1080 | Wide coastal scene |
| Aldric's Warren, dungeon interior tileset | 32x32/tile | Cave/camp hybrid |
| Crestfall Cove, dungeon interior tileset | 32x32/tile | Coastal cave theme |

### Items, Gathering Output (Phase 1 Talents)
All item icons generated as **sprite atlas sheets**, see Sprite Atlas Organization section above.

| Atlas | Phase 1 items to populate | Notes |
|-------|--------------------------|-------|
| `icons_gathering_foraging.png` | Common Herb, Ironwort, Wild Berry Cluster, Thornroot | Leave 4 slots empty for Phase 2+ |
| `icons_gathering_dredging.png` | Perch, Carp, Pearl, Deep Net catch | Leave 4 slots empty |
| `icons_gathering_trapping.png` | Rabbit Pelt, Fox Pelt, Deer Hide, Boar Tusk, Wolf Pelt | Leave 3 slots empty |
| `icons_rare_materials_crude.png` | All 8 crude rare materials | Full sheet, generate all at once |

### Items, Processing Output (Phase 1 Talents)
| Atlas | Phase 1 items to populate | Notes |
|-------|--------------------------|-------|
| `icons_consumables_alchemy.png` | Minor Healing Draught, Antidote Vial, Poison Coating | Leave 5 slots empty |
| `icons_consumables_cookery.png` | Roasted Rabbit, Herb Broth, Venison Stew | Leave 5 slots empty |

### Items, Equipment (Phase 1)
| Item | Resolution | Notes |
|------|-----------|-------|
| Bow, Crude/Rough/Refined | 64x64 (icon) + 256x256 (equipped layer) | Inventory icon + character layer |
| Quiver, Crude/Rough/Refined | 64x64 (icon) + 256x256 (equipped layer) | Inventory icon + character layer |
| Leather Armor pieces, Crude/Rough/Refined | 64x64 (icon) + 256x256 (equipped layer) | Per piece: helm, chest, legs, boots, gloves |
| Assembly components (grips, leather strips etc.) | 64x64 | Inventory icon only, no character render needed |

### UI Elements
| Asset | Resolution | Notes |
|-------|-----------|-------|
| Talent nav icons (all Phase 1 talents) | 48x48 | Bow, sword, flask, book, scales, pick, leaf, axe + all missing |
| Panel border tileset (9-slice) | 96x96 | Dark Ages UI base + custom additions |
| Button states (default/hover/pressed/disabled) | 96x32 | All interactive button states |
| Grimoire visual, Sharpshot, Lone Wanderer | 96x96 | Book/tome icon with path color |
| Currency icons, Silver Mark, Gold Mark | 48x48 | Coin icons for HUD and inventory |
| Quality tier badges, Crude through Masterwork | 32x32 | Corner overlay, needs colorblind shape variants too |
| Notice Board icon (HUD) | 48x48 | Parchment/scroll icon with unread badge |
| Settings gear icon (HUD) | 48x48 | Gear/cog icon |
| Loading screen / splash art | 1920x1080 | First impression |
| App icon | 1024x1024 | App store requirement |

### Onboarding-Specific Art
| Asset | Resolution | Notes |
|-------|-----------|-------|
| World intro panel 1, wide world shot | 1920x1080 | Step 1 of onboarding |
| World intro panel 2, Grimoires on a table | 1920x1080 | Step 1 of onboarding |
| World intro panel 3, Grimwood Fringe entrance | 1920x1080 | Step 1 of onboarding |
| Grimoire selection room backdrop | 1920x1080 | Step 4, stone table, candlelight |

### Notice Board Art
| Asset | Resolution | Notes |
|-------|-----------|-------|
| Notice Board background, wooden parchment board | 1920x1080 or panel size | Pixel art pinboard UI |
| Parchment notice card | 512x256 | Individual notice card, tiled on board |

---

## Phase 2, Full Base Game Classes

### Characters
| Asset | Resolution | Notes |
|-------|-----------|-------|
| Arcanist base character, idle, walk, rune-draw gesture, cast, hit reaction, death | 256x256 | Rune-draw gesture needs clear hand animation |
| Runeweaver, Summoner, Lifebinder visual variants | 256x256 | Cosmetic layer differences |
| Vanguard base character, idle, walk, melee combo (3-hit), block stance, hit reaction, death | 256x256 | |
| Warlord, Shadowblade visual variants | 256x256 | Shadowblade needs stealth/cloaked variant |

### Combat-Specific
| Asset | Resolution | Notes |
|-------|-----------|-------|
| Rune Constellation, 8 node icons | 64x64 each | Ignis, Glacius, Tempest, Terra, Ventus, Vita, Umbra, Lux |
| Rune connection line/glow effect | Vector/scalable | Drawing line between nodes |
| Summon creatures, 6 types | 256x256 | Ember Sprite, Stone Golem, Frost Shard, Storm Wisp, Void Shade, Celestial Guardian |
| Melee combo hit effects | 128x128 | Slash marks, impact bursts for Vanguard |

### Enemies, Tier 2 Zones
| Enemy | Resolution |
|-------|-----------|
| All Ashfen Mire enemies (7 including boss) | 256x256 standard, 320x320 boss |
| All Ironspine Reaches enemies (7 including boss) | 256x256 standard, 320x320 boss |

### Environments
| Asset | Resolution |
|-------|-----------|
| Ashfen Mire, combat + traversal | 1920x1080 each |
| Ironspine Reaches, combat + traversal | 1920x1080 each |
| Mirefall Barrow dungeon tileset | 32x32/tile |
| Warden's Folly dungeon tileset | 32x32/tile |

---

## Phase 3, Remaining Zones & Endgame

### Enemies, Tier 3, 4, 5 Zones
~35-40 additional enemies across Dreadhollow, Cinderpeak, Veilborn Wastes, Shattered Citadel, Ashenwold, Elder Reaches, all at **256x256** standard, zone bosses at **320x320**.

### Environments
6 additional zone backdrop sets + 6 dungeon tilesets, all at **1920x1080** / **32x32 per tile**.

### Guild Hub Art
| Asset | Resolution | Prestige Level |
|-------|-----------|----------------|
| Campfire Gathering | 1920x1080 | 0-4 |
| Tent Camp | 1920x1080 | 5-9 |
| Encampment | 1920x1080 | 10-19 |

> Later Guild Hub stages (Fortress through Stronghold Capital) produced post-launch as guilds approach those Prestige levels.

---

## Phase 4, Multiplayer

### UI/Social
| Asset | Resolution | Notes |
|-------|-----------|-------|
| Guild roster UI elements | Various | |
| Chat UI elements | Various | Name badge frame slots |
| Party formation UI | Various | Bottom-of-screen formation |
| Raid boss intro/phase transition art | 1920x1080 | Larger illustrated moments |

---

## Phase 5, Steam / PC

### UI Adaptations
| Asset | Resolution | Notes |
|-------|-----------|-------|
| Mouse cursor / Bowstring reticle | 64x64 | Point-filtered pixel cursor |
| Steam store capsule image | 460x215 | Store listing requirement |
| Steam store header | 3840x1240 | Store listing requirement |
| Steam store screenshots | 1920x1080 | Min 5 required |

---

## DLC, Produce Only When Scheduled

All DLC sprites follow same resolution standards as base game equivalents.

- Beastbond familiar creatures, 256x256, multiple creature types
- Warlock-specific visuals, soul effects, Black Ledger UI theme
- Kensei-specific visuals, Focus meter, ritual weapon variants  
- Bard/Minstrel character and instrument visuals, 256x256
- Faction system, 5 faction emblem/banner sets (96x96 icons), faction zone visual overlays
- Mythic tier item visual treatment, animated/glowing variant of Legendary tier
- Later Guild Hub stages, Fortress, Castle, Castle+Village, Stronghold Capital, 1920x1080 each

---

## Production Priority Summary

| Priority | What | Why |
|----------|------|-----|
| 1 | Warden base body + equipment layers | Nothing renders without the character |
| 2 | Test layering in Unity before proceeding | Verify 256x256 layers composite correctly |
| 3 | 13 Tier 1 enemies | Combat isn't playable without enemies |
| 4 | Phase 1 UI icon set + panel system | Needed for any screen to look finished |
| 5 | Phase 1 item icons | Idle loop needs items to feel real |
| 6 | Environment backdrops | Needed once character and enemies work in-engine |
| 7 | Onboarding panels | Can use placeholders until everything else is solid |

**Recommendation:** Generate Warden base body first, verify Unity import settings (Point filter, PPU 100) and layering work correctly before generating any other character or enemy. One test asset done right saves regenerating everything later.

---

*Document version 0.6, Art Asset Requirements by Phase*
*Added: Sprite Atlas organization system, sheet format standards, full atlas master list*
*Updated: Full HD-2D art direction added (Grimoire Variant). Full-body realistic proportion characters, front-to-back camera, post-processing stack, per-zone color grading, parallax background layers. Replaces Kingdom Two Crowns reference.*
*Updated v0.6: Zone card thumbnails (576×240 cinemascope crop from combat backdrop). Combat backdrops generated at 1920×1080, zone cards cropped from approved backdrop — same asset, no re-generation needed. Portrait combat backdrops (1080×2400) noted as separate asset from landscape zone backdrops. Guild Hall prestige art generated at 1920×1080 portrait through P20-34.*
