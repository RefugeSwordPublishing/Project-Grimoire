# ⚔️ Project Grimoire — Art Asset Requirements by Phase
### Version 0.1

> Style target throughout: Kingdom Two Crowns-inspired pixel art — clean limited palettes, strong silhouettes, hard pixel edges, dark fantasy medieval tone with amber candlelight accents. Generated via Sprite AI, refined in Aseprite as needed.

---

## 📦 Phase 1 — Launch Critical

This is what blocks Claude Code from having a playable build. Prioritize this list completely before touching Phase 2 art.

### Characters
| Asset | Notes |
|-------|-------|
| Warden base character — idle, walk, draw bow, fire bow, hit reaction, death | Over-the-shoulder back view needed in addition to standard side-view for combat |
| Sharpshot visual variant (cosmetic differences from base Warden) | Cloak/quiver detail differences if any planned |
| Lone Wanderer visual variant | Same as above |

### Enemies — Tier 1 Zones Only
| Enemy | Zone | Animation needs |
|-------|------|-----------------|
| Grimwood Brigand | Grimwood Fringe | idle, walk, attack, hit, death |
| Forest Wolf | Grimwood Fringe | idle, walk, attack, hit, death |
| Poacher | Grimwood Fringe | idle, walk, attack, hit, death |
| Grimwood Bear | Grimwood Fringe | idle, walk, attack, hit, death |
| Bandit Scout (Elite) | Grimwood Fringe | idle, walk, attack, hit, death + elite visual distinction |
| Aldric the Poacher King (Boss) | Grimwood Fringe | full boss animation set, larger/distinct silhouette |
| Saltmarsh Smuggler | Saltmarsh Shore | idle, walk, attack, hit, death |
| Shore Crab | Saltmarsh Shore | idle, walk, attack, hit, death |
| Coastal Poacher | Saltmarsh Shore | idle, walk, attack, hit, death |
| Saltmarsh Serpent | Saltmarsh Shore | idle, walk, attack, hit, death |
| Tide Lurker (Elite) | Saltmarsh Shore | idle, walk, attack, hit, death + elite distinction |
| Smuggler Captain (Elite) | Saltmarsh Shore | idle, walk, attack, hit, death + elite distinction |
| The Saltmother (Boss) | Saltmarsh Shore | full boss animation set |

> 13 enemies total for Phase 1 — this is the single largest art line item. Recommend batching all "idle/walk/attack/hit/death" as a standard 5-animation template applied per enemy to streamline Sprite AI generation.

### Environments / Backgrounds
| Asset | Notes |
|-------|-------|
| Grimwood Fringe — combat backdrop | Forest clearing, over-the-shoulder combat framing |
| Grimwood Fringe — traversal/idle backdrop | Wider forest scene for zone selection screen |
| Saltmarsh Shore — combat backdrop | Coastal cliffs/cove framing |
| Saltmarsh Shore — traversal/idle backdrop | Wider coastal scene |
| Aldric's Warren — dungeon interior tileset | Cave/camp hybrid based on dungeon theme |
| Crestfall Cove — dungeon interior tileset | Coastal cave theme |

### Items — Gathering Output (Phase 1 Talents)
| Category | Items needed |
|----------|-------------|
| Foraging | Common Herb, Ironwort, Wild Berry Cluster, Thornroot icon set |
| Trapping | Rabbit Pelt, Fox Pelt, Deer Hide, Boar Tusk, Wolf Pelt icon set |
| Dredging | Perch, Carp, Pearl, Deep Net catch icon set |
| Rare materials (Phase 1 tiers only) | Crude Amber, Crude Gemstone, Crude Phantom Pelt, Crude Abyssal Pearl, Crude Void Spore |

### Items — Processing Output (Phase 1 Talents)
| Category | Items needed |
|----------|-------------|
| Alchemy | Minor Healing Draught, Antidote Vial, Poison Coating bottle icon set |
| Cookery | Roasted Rabbit, Herb Broth, Venison Stew icon set |

### Items — Equipment (Phase 1)
| Item | Notes |
|------|-------|
| Bronze/Iron/Steel Bow (Crude–Refined tiers) | Equipped on Warden character — needs to render in character's hands |
| Standard Quiver (Crude–Refined tiers) | Worn on back — needs to render on character |
| Crude/Rough/Refined Leather Armor pieces | Helm, chest, legs, boots, gloves — render on character |
| Pine/Hardwood Grip components | Inventory icon only, doesn't need character render |

### UI Elements
| Asset | Notes |
|-------|-------|
| Pixel icon set — already drafted in mockup (bow, sword, flask, book, scales, pick, leaf, axe) | Expand to cover all Phase 1 Talents fully |
| Panel border tileset | 9-slice pixel border for consistent panel sizing |
| Button states (default/hover/pressed/disabled) | For all interactive elements |
| Grimoire visual — Sharpshot, Lone Wanderer | Book/tome icon, equipped visual |
| Currency icons — Silver Mark, Gold Mark | Small inventory/UI icon |
| Quality tier badges — Crude through Masterwork | Small corner badge overlay for item icons |
| Loading screen / splash art | First impression — worth getting right |
| App icon | Store listing requirement |

### Onboarding-Specific Art
| Asset | Notes |
|-------|-------|
| World intro panel 1 — wide world shot | Step 1 of onboarding |
| World intro panel 2 — Grimoires on a table | Step 1 of onboarding |
| World intro panel 3 — Grimwood Fringe entrance | Step 1 of onboarding |
| Grimoire selection room backdrop | Step 4 of onboarding — stone table, candlelight |

---

## 📦 Phase 2 — Full Base Game Classes

### Characters
| Asset | Notes |
|-------|-------|
| Arcanist base character — idle, walk, rune-draw gesture, cast, hit reaction, death | Constellation drawing animation is unique — thumb/hand gesture needs visual feedback |
| Runeweaver, Summoner, Lifebinder visual variants | Cosmetic differences per subclass |
| Vanguard base character — idle, walk, melee attack combo (3-hit), block stance, hit reaction, death | |
| Warlord, Shadowblade visual variants | Shadowblade likely needs a stealth/cloaked variant frame |

### Combat-Specific
| Asset | Notes |
|-------|-------|
| Rune Constellation UI — 8 node icons (Ignis, Glacius, Tempest, Terra, Ventus, Vita, Umbra, Lux) | Each needs a distinct glowing pixel icon |
| Rune connection line/glow effect | Visual for drawing between nodes |
| Summon creatures — Ember Sprite, Stone Golem, Frost Shard, Storm Wisp, Void Shade, Celestial Guardian | Each needs idle/attack/death at minimum |
| Melee combo hit effects | Slash marks, impact bursts for Vanguard |

### Enemies — Tier 2 Zones
| Enemy | Zone |
|-------|------|
| Bogwalker Skeleton, Ashfen Treant, Mire Wraith, Bog Lurker, Barrow Revenant (Elite), Thornwood Ancient (Elite), The Ashfen Lich (Boss) | Ashfen Mire |
| Ironspine Deserter, Mountain Golem, Warband Raider, Rune Construct, Ironspine Warlord (Elite), Awakened Stone Sentinel (Elite), The Ironspine Colossus (Boss) | Ironspine Reaches |

### Environments
| Asset | Notes |
|-------|-------|
| Ashfen Mire — combat + traversal backdrops | Swamp/bog theme |
| Ironspine Reaches — combat + traversal backdrops | Mountain pass theme |
| Mirefall Barrow — dungeon tileset | |
| Warden's Folly — dungeon tileset | |

### Items
| Category | Notes |
|----------|-------|
| Full Tier 2 rare material set | Rough tier of all 8 material types |
| Mid-tier weapon set | Staff, Wand, Sword, Dagger, Axe across Crude–Refined |
| Plate armor full set | Crude–Refined tiers |
| Magical Vestments full set | Crude–Refined tiers |
| Arcanist/Vanguard Grimoire visuals | Runeweaver, Summoner, Lifebinder, Warlord, Shadowblade |

---

## 📦 Phase 3 — Remaining Zones & Endgame

### Enemies — Tier 3, 4, 5 Zones
All enemies for Dreadhollow, Cinderpeak, Veilborn Wastes, Shattered Citadel, Ashenwold, Elder Reaches — roughly 35-40 additional enemy types following the same 5-animation template. This is the largest remaining content volume.

### Environments
6 additional zone backdrop sets (combat + traversal) + 6 additional dungeon tilesets

### Items
- Tier 3-5 rare material sets (Refined, Pristine, Masterwork)
- High-tier weapon and armor sets across all types
- Raid-exclusive visual variants for Masterwork gear

### Guild Hub Art
| Asset | Prestige Level |
|-------|----------------|
| Campfire Gathering | 0–4 |
| Tent Camp | 5–9 |
| Encampment | 10–19 |

> Later Guild Hub stages (Army Encampment through Stronghold Capital) can wait until Phase 4/5 since most guilds won't reach those Prestige levels until well post-launch.

---

## 📦 Phase 4 — Multiplayer

### UI/Social
| Asset | Notes |
|-------|-------|
| Guild roster UI elements | |
| Chat UI | Including name badge frame slots |
| Party formation UI for dungeons/raids | Bottom-of-screen formation visual |
| Raid boss intro/phase transition art | Larger illustrated moments for raid bosses specifically |

### Lifebinder Group Features
| Asset | Notes |
|-------|-------|
| Heal/buff visual effects (aura, restoration wave, revive pulse) | |

---

## 📦 Phase 5 — Steam / PC

### UI Adaptations
| Asset | Notes |
|-------|-------|
| Cursor/reticle for mouse-based Bowstring aiming | |
| Larger UI scale variants for desktop resolution | Most pixel art should scale cleanly, but panel layouts may need adjustment |
| Steam store page art — capsule images, header, screenshots | Marketing requirement, separate from in-game assets |

---

## 📦 DLC — Produce Only When Scheduled

- Beastbond familiar creatures (multiple tamed creature types)
- Warlock-specific visuals (soul effects, Black Ledger UI theme)
- Kensei-specific visuals (Focus meter, ritual weapon variants)
- Bard/Minstrel character and instrument visuals
- Faction system — 5 faction emblem/banner sets, faction zone ownership visual overlays
- Mythic tier item visual treatment (likely animated/glowing variant of Legendary)
- Later Guild Hub stages — Fortress, Castle, Castle+Village, Stronghold Capital

---

## 📊 Production Priority Summary

| Priority | What | Why |
|----------|------|-----|
| 1 | Warden character + 13 Tier 1 enemies | Nothing else matters if combat isn't playable |
| 2 | Phase 1 UI icon set + panel system | Needed for any screen to look finished |
| 3 | Phase 1 gathering/processing items | Needed for the idle loop to feel complete |
| 4 | Onboarding panels | First impression, but can use placeholder pixel scenes initially |
| 5 | Phase 2 characters and zones | Once Phase 1 is playable and validated |

**Recommendation:** Get Phase 1 fully art-complete before starting Phase 2 art. A playable, fully-dressed Phase 1 build is more valuable for testing and feedback than a partially-dressed full game.

---

*Document version 0.1 — Art Asset Requirements by Phase*
*Update this doc as new systems are designed — every new enemy, item, or zone should get added here immediately so nothing is missed during sourcing*
