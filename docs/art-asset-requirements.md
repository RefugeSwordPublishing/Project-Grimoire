# ⚔️ Project Grimoire — Art Asset Requirements by Phase
### Version 0.3

> **Art Style: HD-2D (Grimoire Variant)**
> Inspired by Octopath Traveler's cinematic HD-2D approach — painterly pre-rendered backgrounds with rich atmospheric depth, expressive lighting, and strong zone identity — but with two key distinctions: **full-body realistic-proportion pixel art characters** (not chibi) and a **front-to-back scrolling camera perspective** (not side-scrolling plane).

---

## 🎨 Art Direction Reference

### Overall Style — HD-2D Grimoire Variant
| Element | Octopath Traveler | Project Grimoire |
|---------|-----------------|-----------------|
| Backgrounds | High-res painterly, parallax depth | Same — cinematic, layered, atmospheric |
| Characters | Small chibi pixel sprites | Full-body realistic/semi-realistic pixel art |
| Camera | Side-scrolling plane | Front-to-back — player moves into the screen |
| Depth of field | Side-plane depth | Front-to-back depth — foreground blurs as player moves deeper |
| Lighting | Strong mood lighting | Same + heavy bloom on torches, magic, god rays |

### Background Environments
- High resolution, painterly/pre-rendered — each zone feels cinematic and distinct
- Layered parallax depth — multiple Z-depth layers (foreground, midground, background, skybox)
- Strong mood lighting per zone — torches, magic glows, environmental light sources
- Atmospheric particles per zone — fog, drifting embers, dust motes, rain, snow
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

### Character Art — Full-Body Pixel Art
Characters depart from Octopath's chibi proportions. Grimoire characters are:
- **Realistic or semi-realistic body proportions** — closer to modern RPG character art in pixel form
- **Detailed at gameplay scale** — readable silhouette from distance, detailed up close
- **Expressive** — facial features readable, posture communicates class identity
- **Reference:** Think Blasphemous, Dead Cells, or Hollow Knight's proportional detail applied to pixel art RPG characters

### Camera & Scrolling
- **Front-to-back perspective** — player character moves into the screen depth, not left/right
- **Zone traversal:** World scrolls as player moves deeper — foreground elements pass by
- **Depth of field:** Foreground elements blur as player advances, background has atmospheric haze
- **Combat:** Over-the-shoulder view consistent with traversal direction — player behind, enemy ahead in the depth plane

### Post-Processing Stack (Unity URP)
| Effect | Setting | Notes |
|--------|---------|-------|
| Bloom | Heavy on light sources | Torches, magic effects, environmental lighting, rune glows |
| Depth of Field | Front-to-back tuned | Foreground blur on traversal, combat has shallow DOF on enemy |
| Color Grading | Per-zone LUT | Swap LUT on zone transition |
| Atmospheric Particles | Per-zone particle systems | Fog, embers, dust, rain — always subtle, never obstructive |
| God Rays | Volumetric where appropriate | Forest clearings, dungeon shafts of light, boss rooms |
| Chromatic Aberration | Subtle on hit effects only | Not constant — used for impact feedback |
| Vignette | Light ambient vignette | Frames the scene, increases during boss fights |

---

## 🖥️ Resolution Standards

Project Grimoire targets both mobile and Steam/PC. Character sprites use realistic proportions at sufficient resolution to support HD-2D visual fidelity.

| Asset Type | Resolution | Notes |
|-----------|-----------|-------|
| Standard characters | **256x256** | Full-body realistic proportion pixel art |
| Standard enemies | **256x256** | Consistent with character scale |
| Elite enemies | **256x256** | Visual distinction via design not size |
| Zone bosses | **320x320** | Larger silhouette, more imposing presence |
| Raid bosses | **512x512** | Screen-filling — maximum detail |
| Item icons (inventory) | **64x64** | Examined closely in inventory |
| Rare material icons | **64x64** | High-value items deserve detail |
| Currency icons | **48x48** | SM and GM coins |
| Quality tier badges | **32x32** | Corner overlay — needs colorblind shape variants |
| Environment backdrops | **1920x1080** | Painterly/pre-rendered, HD-2D style |
| Background layers (parallax) | **1920x1080 per layer** | 3–5 layers per zone for parallax depth |
| Foreground elements | **Variable** | Trees, rocks, debris that blur with depth of field |
| Dungeon tilesets | **32x32 per tile** | Standard tileset grid |
| UI panel borders (9-slice) | **96x96** | Clean at higher DPI |
| UI nav icons | **48x48** | Bottom nav and HUD icons |
| Grimoire icons | **96x96** | Featured items — deserve detail |
| Onboarding panels | **1920x1080** | Full screen illustrated scenes |
| App icon | **1024x1024** | App store requirement |
| Loading screen / splash | **1920x1080** | First impression — full HD-2D scene |

### Unity Import Settings (apply to all sprites)
- **Filter Mode:** Point (no filter) for character/enemy/UI sprites
- **Filter Mode:** Bilinear for background environment layers (painterly, not pixel-art-strict)
- **Compression:** None for characters/enemies, Lossless for backgrounds
- **Pixels Per Unit:** 100 across all character/enemy sprites — must be consistent
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
Layer 1 — Skybox/far background (lowest parallax)
Layer 2 — Distant environment (mountains, treeline)
Layer 3 — Midground environment (primary scene)
Layer 4 — Foreground details (rocks, near trees)
Layer 5 — Particle systems (fog, embers, dust)
Layer 6 — UI overlay
```
Depth of field blurs Layer 4 as player moves deeper — gives the front-to-back parallax feel.

---

## 📦 Phase 1 — Launch Critical

This is what blocks Claude Code from having a playable build. Prioritize this list completely before touching Phase 2 art.

### Characters
| Asset | Resolution | Notes |
|-------|-----------|-------|
| Warden base body — idle, walk, draw bow, fire bow, hit reaction, death | 256x256 per frame | Side view — equipment layers composite on top |
| Warden over-the-shoulder view — idle, draw, fire, hit | 256x256 per frame | Separate asset for combat screen |
| Sharpshot cloak/hood layer | 256x256 per frame | Forest green — composites over base body |
| Lone Wanderer cloak/hood layer | 256x256 per frame | Amber/brown ragged — composites over base body |
| Quiver layer (back-worn) | 256x256 per frame | Separate layer, all animation frames |
| Bow layer — Crude/Rough/Refined tiers | 256x256 per frame | Held in hand — separate layer per quality tier |
| Leather Armor layer set — Crude/Rough/Refined | 256x256 per frame | Helm, chest, legs, boots, gloves each as separate layers |

> Layered approach: Unity composites base body + cloak + quiver + bow + armor at runtime. Each layer is a separate sprite sheet with matching frame count.

### Enemies — Tier 1 Zones Only
| Enemy | Zone | Resolution | Notes |
|-------|------|-----------|-------|
| Grimwood Brigand | Grimwood Fringe | 256x256 | idle, walk, attack, hit, death |
| Forest Wolf | Grimwood Fringe | 256x256 | idle, walk, attack, hit, death — quadruped |
| Poacher | Grimwood Fringe | 256x256 | idle, walk, attack, hit, death |
| Grimwood Bear | Grimwood Fringe | 256x256 | idle, walk, attack, hit, death — large build |
| Bandit Scout (Elite) | Grimwood Fringe | 256x256 | idle, walk, attack, hit, death + elite visual distinction |
| Aldric the Poacher King (Boss) | Grimwood Fringe | 320x320 | Full boss animation set — larger silhouette |
| Saltmarsh Smuggler | Saltmarsh Shore | 256x256 | idle, walk, attack, hit, death |
| Shore Crab | Saltmarsh Shore | 256x256 | idle, walk, attack, hit, death — low/wide stance |
| Coastal Poacher | Saltmarsh Shore | 256x256 | idle, walk, attack, hit, death |
| Saltmarsh Serpent | Saltmarsh Shore | 256x256 | idle, coil, strike, hit, death — sinuous body |
| Tide Lurker (Elite) | Saltmarsh Shore | 256x256 | idle, walk, attack, hit, death + elite distinction |
| Smuggler Captain (Elite) | Saltmarsh Shore | 256x256 | idle, walk, attack, hit, death + elite distinction |
| The Saltmother (Boss) | Saltmarsh Shore | 320x320 | Full boss animation set — large serpent |

> 13 enemies total for Phase 1. Batch together in Sprite AI — same style prompt, different descriptions. Use Warden base body as style reference for all generations.

### Environments / Backgrounds
| Asset | Resolution | Notes |
|-------|-----------|-------|
| Grimwood Fringe — combat backdrop | 1920x1080 | Forest clearing, over-the-shoulder framing |
| Grimwood Fringe — traversal/idle backdrop | 1920x1080 | Wide forest, zone selection screen |
| Saltmarsh Shore — combat backdrop | 1920x1080 | Coastal cliffs/cove |
| Saltmarsh Shore — traversal/idle backdrop | 1920x1080 | Wide coastal scene |
| Aldric's Warren — dungeon interior tileset | 32x32/tile | Cave/camp hybrid |
| Crestfall Cove — dungeon interior tileset | 32x32/tile | Coastal cave theme |

### Items — Gathering Output (Phase 1 Talents)
| Category | Resolution | Items |
|----------|-----------|-------|
| Foraging | 64x64 | Common Herb, Ironwort, Wild Berry Cluster, Thornroot |
| Trapping | 64x64 | Rabbit Pelt, Fox Pelt, Deer Hide, Boar Tusk, Wolf Pelt |
| Dredging | 64x64 | Perch, Carp, Pearl, Deep Net catch |
| Rare materials (Crude tier) | 64x64 | Crude Amber, Crude Gemstone, Crude Phantom Pelt, Crude Abyssal Pearl, Crude Void Spore |

### Items — Processing Output (Phase 1 Talents)
| Category | Resolution | Items |
|----------|-----------|-------|
| Alchemy | 64x64 | Minor Healing Draught, Antidote Vial, Poison Coating |
| Cookery | 64x64 | Roasted Rabbit, Herb Broth, Venison Stew |

### Items — Equipment (Phase 1)
| Item | Resolution | Notes |
|------|-----------|-------|
| Bow — Crude/Rough/Refined | 64x64 (icon) + 256x256 (equipped layer) | Inventory icon + character layer |
| Quiver — Crude/Rough/Refined | 64x64 (icon) + 256x256 (equipped layer) | Inventory icon + character layer |
| Leather Armor pieces — Crude/Rough/Refined | 64x64 (icon) + 256x256 (equipped layer) | Per piece: helm, chest, legs, boots, gloves |
| Assembly components (grips, leather strips etc.) | 64x64 | Inventory icon only — no character render needed |

### UI Elements
| Asset | Resolution | Notes |
|-------|-----------|-------|
| Talent nav icons (all Phase 1 talents) | 48x48 | Bow, sword, flask, book, scales, pick, leaf, axe + all missing |
| Panel border tileset (9-slice) | 96x96 | Dark Ages UI base + custom additions |
| Button states (default/hover/pressed/disabled) | 96x32 | All interactive button states |
| Grimoire visual — Sharpshot, Lone Wanderer | 96x96 | Book/tome icon with path color |
| Currency icons — Silver Mark, Gold Mark | 48x48 | Coin icons for HUD and inventory |
| Quality tier badges — Crude through Masterwork | 32x32 | Corner overlay — needs colorblind shape variants too |
| Notice Board icon (HUD) | 48x48 | Parchment/scroll icon with unread badge |
| Settings gear icon (HUD) | 48x48 | Gear/cog icon |
| Loading screen / splash art | 1920x1080 | First impression |
| App icon | 1024x1024 | App store requirement |

### Onboarding-Specific Art
| Asset | Resolution | Notes |
|-------|-----------|-------|
| World intro panel 1 — wide world shot | 1920x1080 | Step 1 of onboarding |
| World intro panel 2 — Grimoires on a table | 1920x1080 | Step 1 of onboarding |
| World intro panel 3 — Grimwood Fringe entrance | 1920x1080 | Step 1 of onboarding |
| Grimoire selection room backdrop | 1920x1080 | Step 4 — stone table, candlelight |

### Notice Board Art
| Asset | Resolution | Notes |
|-------|-----------|-------|
| Notice Board background — wooden parchment board | 1920x1080 or panel size | Pixel art pinboard UI |
| Parchment notice card | 512x256 | Individual notice card — tiled on board |

---

## 📦 Phase 2 — Full Base Game Classes

### Characters
| Asset | Resolution | Notes |
|-------|-----------|-------|
| Arcanist base character — idle, walk, rune-draw gesture, cast, hit reaction, death | 256x256 | Rune-draw gesture needs clear hand animation |
| Runeweaver, Summoner, Lifebinder visual variants | 256x256 | Cosmetic layer differences |
| Vanguard base character — idle, walk, melee combo (3-hit), block stance, hit reaction, death | 256x256 | |
| Warlord, Shadowblade visual variants | 256x256 | Shadowblade needs stealth/cloaked variant |

### Combat-Specific
| Asset | Resolution | Notes |
|-------|-----------|-------|
| Rune Constellation — 8 node icons | 64x64 each | Ignis, Glacius, Tempest, Terra, Ventus, Vita, Umbra, Lux |
| Rune connection line/glow effect | Vector/scalable | Drawing line between nodes |
| Summon creatures — 6 types | 256x256 | Ember Sprite, Stone Golem, Frost Shard, Storm Wisp, Void Shade, Celestial Guardian |
| Melee combo hit effects | 128x128 | Slash marks, impact bursts for Vanguard |

### Enemies — Tier 2 Zones
| Enemy | Resolution |
|-------|-----------|
| All Ashfen Mire enemies (7 including boss) | 256x256 standard, 320x320 boss |
| All Ironspine Reaches enemies (7 including boss) | 256x256 standard, 320x320 boss |

### Environments
| Asset | Resolution |
|-------|-----------|
| Ashfen Mire — combat + traversal | 1920x1080 each |
| Ironspine Reaches — combat + traversal | 1920x1080 each |
| Mirefall Barrow dungeon tileset | 32x32/tile |
| Warden's Folly dungeon tileset | 32x32/tile |

---

## 📦 Phase 3 — Remaining Zones & Endgame

### Enemies — Tier 3, 4, 5 Zones
~35–40 additional enemies across Dreadhollow, Cinderpeak, Veilborn Wastes, Shattered Citadel, Ashenwold, Elder Reaches — all at **256x256** standard, zone bosses at **320x320**.

### Environments
6 additional zone backdrop sets + 6 dungeon tilesets — all at **1920x1080** / **32x32 per tile**.

### Guild Hub Art
| Asset | Resolution | Prestige Level |
|-------|-----------|----------------|
| Campfire Gathering | 1920x1080 | 0–4 |
| Tent Camp | 1920x1080 | 5–9 |
| Encampment | 1920x1080 | 10–19 |

> Later Guild Hub stages (Fortress through Stronghold Capital) produced post-launch as guilds approach those Prestige levels.

---

## 📦 Phase 4 — Multiplayer

### UI/Social
| Asset | Resolution | Notes |
|-------|-----------|-------|
| Guild roster UI elements | Various | |
| Chat UI elements | Various | Name badge frame slots |
| Party formation UI | Various | Bottom-of-screen formation |
| Raid boss intro/phase transition art | 1920x1080 | Larger illustrated moments |

---

## 📦 Phase 5 — Steam / PC

### UI Adaptations
| Asset | Resolution | Notes |
|-------|-----------|-------|
| Mouse cursor / Bowstring reticle | 64x64 | Point-filtered pixel cursor |
| Steam store capsule image | 460x215 | Store listing requirement |
| Steam store header | 3840x1240 | Store listing requirement |
| Steam store screenshots | 1920x1080 | Min 5 required |

---

## 📦 DLC — Produce Only When Scheduled

All DLC sprites follow same resolution standards as base game equivalents.

- Beastbond familiar creatures — 256x256, multiple creature types
- Warlock-specific visuals — soul effects, Black Ledger UI theme
- Kensei-specific visuals — Focus meter, ritual weapon variants  
- Bard/Minstrel character and instrument visuals — 256x256
- Faction system — 5 faction emblem/banner sets (96x96 icons), faction zone visual overlays
- Mythic tier item visual treatment — animated/glowing variant of Legendary tier
- Later Guild Hub stages — Fortress, Castle, Castle+Village, Stronghold Capital — 1920x1080 each

---

## 📊 Production Priority Summary

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

*Document version 0.3 — Art Asset Requirements by Phase*
*Updated: Full HD-2D art direction added (Grimoire Variant). Full-body realistic proportion characters, front-to-back camera, post-processing stack, per-zone color grading, parallax background layers. Replaces Kingdom Two Crowns reference.*
