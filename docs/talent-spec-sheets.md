# ⚔️ Project Grimoire — Talent Spec Sheets
### Version 0.2

---

## 📐 Global Rules

### Level Cap
- **Base cap: 100** per Talent
- Expansion unlocks push cap to **120, then 150** in future releases
- Levels 101–120 require a purchased **Tome of Mastery** (premium unlock) per Talent
- Each Talent has its own progression — a player can be level 100 Foraging and level 32 Alchemy simultaneously

### Level 100 Design Philosophy
Level 100 represents **mastery** — not godhood. Capstone unlocks should feel like:
- **Reliability** — guaranteed outcomes that lower levels leave to chance
- **Efficiency** — doing the same thing faster or with less resource cost
- **Flexibility** — more options, not stronger options
- **Prestige** — cosmetic or quality of life rewards that feel earned

Rare materials, powerful Techniques, and rare zone access live at **levels 82–92**.
Level 100 capstones are about consistency, not power spikes. This preserves expansion headroom.

| Level Range | Design Role |
|-------------|-------------|
| 1–50 | Learning the Talent, unlocking the dependency chain |
| 51–75 | Mid-game depth, cross-Talent synergies opening up |
| 76–91 | Endgame specialization, rare material and zone access |
| 92–99 | Refinement, efficiency gains, rare drops improving |
| 100 | Mastery — consistency, flexibility, prestige |
| 101–120 | Expansion — new material tiers, zones, combinations |
| 121–150 | Expansion 2 — true endgame, post-story content |

### XP Rate Philosophy
- **Idle rate:** Slow and steady — modeled after Idle Clans. Meaningful milestones, never feels trivial
- **Active rate (Attunement Surge):** 1.5x–3x multiplier depending on Talent and interaction quality
- **XP curve:** Exponential — early levels fast to hook, mid levels steady, 85–100 a genuine grind

### XP Curve (Global)
| Level Range | XP Per Level (approx) | Idle Time Per Level* | Active Time Per Level* |
|-------------|----------------------|----------------------|------------------------|
| 1–20 | 100–2,000 | 5–30 min | 2–10 min |
| 21–40 | 2,000–15,000 | 30 min–2 hrs | 10–45 min |
| 41–60 | 15,000–80,000 | 2–8 hrs | 45 min–3 hrs |
| 61–80 | 80,000–400,000 | 8–36 hrs | 3–12 hrs |
| 81–99 | 400,000–2,000,000 | 36 hrs–2 weeks | 12 hrs–4 days |
| 100 | 5,000,000 | ~3 weeks | ~1 week |

*Approximate at base idle rate with no boosts. Attunement Surges, meals, potions, and equipment reduce these significantly.

### Unlock Terminology by Talent Category
| Category | Unlock Term |
|----------|-------------|
| Runesmithing, Smelting, Artificing, Tanning, Timber Shaping | **Schematic** |
| Tailoring, Arcane Weaving | **Pattern** |
| Alchemy, Cookery | **Formulae** |
| Combat Talents | **Technique** |
| All Gathering Talents | **Field Notes** |
| Inscription, Runelore, Divination, Soulbinding | **Codex Entry** |

### Weapon & Tool Quality Tiers
All assembled weapons and tools have five quality tiers. Tier is determined at the **Workbench** during Assembly.

| Tier | Color | How Achieved |
|------|-------|-------------|
| Common | White | Base components, any assembler level |
| Uncommon | Green | Base components + strong Attunement during Assembly |
| Rare | Blue | Base components + 1 Rare material added at Assembly |
| Epic | Purple | Base components + Epic material + assembler Talent 60+ |
| Legendary | Gold | Base components + Legendary material + assembler Talent 85+ |

**Assembly Rules:**
- Each weapon/tool requires exactly **2 components** — one per contributing Talent (e.g., Blade from Runesmithing + Grip from Timber Shaping)
- Rare materials are added **at the Workbench during Assembly**, not during component crafting
- Rare material is **consumed on failure** — if the target tier is not reached, material is lost, components are returned
- Assembly **success rate and rarity outcome** scale with the assembler's relevant Talent level
- **No level gate on Assembly itself** — equip and use requirements gate access naturally
- Low-level assemblers can attempt Epic/Legendary Assembly but with low success rate — creating a market for high-level assembly services and friend-to-friend crafting

### Weapon Component Structure
| Weapon | Runesmithing Component | Timber Shaping / Tanning Component |
|--------|----------------------|-------------------------------------|
| Sword | Blade | Grip (Timber Shaping) |
| Bow | Limbs | Grip (Timber Shaping) |
| Staff | Core | Shaft (Timber Shaping) |
| Axe | Head | Haft (Timber Shaping) |
| Dagger | Blade | Wrap (Tanning) |
| Spear | Head | Pole (Timber Shaping) |
| Wand | Tip | Handle (Timber Shaping) |

### Quiver & Buff System
- **Quiver** (Tailoring) = equipped item enabling ranged combat; provides infinite standard arrows while equipped
- No arrow crafting — the quiver IS the ammunition system
- **Buff coatings** (from Alchemy) apply to the quiver slot as timed effects:
  - Duration-based (e.g., Poison Coating: 10 minutes)
  - Higher fire rate = more procs per minute = coating consumed faster
  - This creates meaningful build tradeoffs between fire rate and coating efficiency
- **Elemental Quivers** (Tailoring + Arcane Weaving) grant passive elemental damage type
- **Fire rate** is a bow stat — faster bows proc coatings more, enabling poison/element stacking builds
- Build diversity: slow heavy-hit bows (Sharpshot) vs. rapid proc-stack bows (Lone Wanderer)

---

## 🌿 GATHERING TALENTS

---

### 🍃 Foraging
> Collect herbs, fungi, berries, roots, and botanicals. Feeds Alchemy, Cookery, and Inscription. Yield quality scales with level.

**Primary Stats:** DEX, LCK
**Unlock Term:** Field Notes
**Idle Action:** Auto-forages assigned zone
**Active Attunement:** Choose which plant to harvest when multiples appear — picking the rarer option yields higher quality tier

| Level | Unlock | Notes |
|-------|--------|-------|
| 1 | Common Herbs (Thyme, Ironwort) | Basic Alchemy Formulae input |
| 7 | Fungi zone access | Mushrooms for Cookery buffs |
| 13 | Field Notes: Wild Berry Cluster | Cookery ingredient; sell value |
| 18 | Uncommon Herbs (Shadowleaf, Goldmoss) | Mid-tier Alchemy unlocked |
| 24 | Quality Tier II yields possible on Attunement | Better reagent grade |
| 29 | Field Notes: Thornroot | Poison Formulae in Alchemy |
| 36 | Rare zone: Mirelands access | Unique reagents unavailable elsewhere |
| 43 | Field Notes: Starbloom | Inscription enchanting reagent; high sell value |
| 51 | DEX passive +2 | Stat gain milestone |
| 57 | Field Notes: Voidmoss | Soulbinding component (Warlock) |
| 63 | Quality Tier III yields possible on Attunement | Requires Alchemy 50 to use |
| 68 | Field Notes: Emberpetal | Fire-element Arcane Weaving component |
| 74 | Rare zone: Highland Peaks access | Alpine botanicals unique to zone |
| 79 | LCK passive +2 | Stat gain milestone |
| 83 | Field Notes: Moonbloom | Spawns during night cycle only |
| 87 | Quality Tier IV yields possible on Attunement | Master-grade reagents |
| 88 | Field Notes: Soulflower | Rarest botanical; Warlock + Lifebinder use |
| 91 | Rare zone: The Ashen Wastes | Post-game zone; unique flora |
| 95 | Field Notes: Celestine Sprig | Highest-tier Inscription enchanting reagent |
| 100 | Guaranteed Tier III minimum yield on all harvests | Mastery — consistency over power |

---

### 🪓 Felling
> Chop trees across biomes for timber, bark, and sap. Feeds Timber Shaping and Artificing. Wood type scales with level.

**Primary Stats:** STR
**Unlock Term:** Field Notes
**Idle Action:** Auto-chops assigned tree type
**Active Attunement:** Tap on rhythm with bark crack visual cue — timing hit gives bonus timber and rare wood chance

| Level | Unlock | Notes |
|-------|--------|-------|
| 1 | Softwood Trees (Pine, Birch) | Basic Timber Shaping input |
| 6 | Field Notes: Bark Strip | Tanning supplement |
| 14 | Hardwood Trees (Oak, Elm) | Better planks |
| 19 | Field Notes: Pine Sap | Alchemy adhesive component |
| 27 | STR passive +2 | Stat milestone |
| 33 | Ancient Trees (Ironbark, Ashwood) | Mid-tier Runesmithing hafts |
| 41 | Field Notes: Ashwood Burl | Rare drop; premium Artificing component |
| 52 | Enchanted Grove access | Magicwood trees spawn here |
| 58 | Field Notes: Magicwood | Arcane Weaving and Runesmithing high-tier |
| 66 | STR passive +3 | Stat milestone |
| 71 | Field Notes: Ironbark Heartwood | Endgame weapon handle material |
| 77 | Ancient Forest biome access | Rarest tree types |
| 84 | Field Notes: Voidtimber | Warlock staff material |
| 89 | Field Notes: Worldtree Shard | Legendary crafting material; rare drop |
| 94 | STR passive +5 | Major stat milestone |
| 100 | Bonus timber on every chop regardless of Attunement | Mastery — base yield now matches previous Attunement yield |

---

### ⛏️ Delving
> Mine ores, gems, and fossils. Feeds Smelting and Runelore. Ore grade and gem rarity scale with level.

**Primary Stats:** STR, VIT
**Unlock Term:** Field Notes
**Idle Action:** Auto-mines assigned ore node
**Active Attunement:** Tap glowing vein highlights before they fade — hits give bonus ore and gem drop chance

| Level | Unlock | Notes |
|-------|--------|-------|
| 1 | Copper Ore, Tin Ore | Basic Smelting input for Bronze |
| 8 | Field Notes: Flint Fragment | Artificing early component |
| 14 | Iron Ore | Requires Smelting 10 to process |
| 21 | Gem nodes: Quartz, Jasper | Low-tier Inscription enchanting stones |
| 28 | VIT passive +2 | Stat milestone |
| 33 | Silver Ore | Arcane Weaving component |
| 37 | Coal nodes | Required fuel for advanced Smelting |
| 44 | Field Notes: Fossil Shard | Feeds Runelore |
| 49 | Gold Ore | High economy value; Inscription enchanting |
| 53 | Gem nodes: Ruby, Sapphire | Mid-tier Inscription enchanting stones |
| 59 | STR passive +2, VIT passive +2 | Stat milestone |
| 64 | Mithril Ore | Requires Smelting 55 |
| 67 | Deep Cave zone access | Richer nodes, higher danger |
| 72 | Field Notes: Ancient Fossil | Full Runelore codex unlock |
| 76 | Adamantine Ore | Requires Smelting 65 |
| 81 | Gem nodes: Diamond, Voidstone | Inscription enchanting endgame stones |
| 86 | Field Notes: Starstone Ore | Magical weapon base material |
| 88 | Abyssal Cave zone access | Endgame zone |
| 92 | Field Notes: Soulite Ore | Soulbinding and top-tier Runesmithing |
| 97 | VIT passive +5 | Major stat milestone |
| 100 | Gem drop guaranteed on every Attunement hit | Mastery — gem farming becomes reliable |

---

### 🪤 Trapping
> Set snares and cages for animals and creatures. Feeds Tanning, Cookery, and Beastmastery.

**Primary Stats:** DEX, INT
**Unlock Term:** Field Notes
**Idle Action:** Auto-checks and resets traps on timer
**Active Attunement:** Place traps in optimal terrain positions shown briefly — better placement = higher catch rate and quality

| Level | Unlock | Notes |
|-------|--------|-------|
| 1 | Rabbit Snare | Common Pelt; Cookery meat |
| 9 | Fox Trap | Fox Pelt (Tanning tier 1) |
| 16 | Field Notes: Reinforced Snare | Higher catch rate; Artificing Schematic |
| 22 | Deer Cage Trap | Deer Hide (Tanning tier 2); Cookery venison |
| 28 | DEX passive +1 | Stat milestone |
| 34 | Field Notes: Scent Lure | Alchemy Formulae; rare catch rate up |
| 39 | Wild Boar Trap | Boar Tusks (Artificing component) |
| 46 | Live Capture unlocked | *(Reserved for Beastbond DLC — unlock stub)* |
| 53 | Field Notes: Beast Cage | Holds larger creatures; Artificing 40 required |
| 61 | Wolf Trap | Wolf Pelt (Tanning tier 3) |
| 67 | Field Notes: Shadow Snare | Catches nocturnal/rare creatures |
| 73 | Field Notes: Runed Trap | Catches magical creatures; Runelore 40 required |
| 82 | Drake Trap | Drake Scales (Arcane Weaving endgame) |
| 89 | Field Notes: Void Snare | Catches void creatures; Warlock use |
| 96 | INT passive +2 | Stat milestone |
| 100 | Traps auto-reset without manual check | Mastery — idle trap loop becomes fully autonomous |

---

### 🎣 Dredging
> Fish, net, and dive in water zones. Feeds Cookery and Alchemy. Fish size and rarity scale with level.

**Primary Stats:** DEX, LCK
**Unlock Term:** Field Notes
**Idle Action:** Auto-fishes assigned water zone
**Active Attunement:** Cast timing and line tension management — perfect hold yields larger and rarer fish

| Level | Unlock | Notes |
|-------|--------|-------|
| 1 | Freshwater Fish (Perch, Carp) | Basic Cookery ingredient |
| 11 | Saltwater zone access | Coastal fish; better Cookery buffs |
| 17 | Field Notes: Pearl Dive | Pearl nodes; Arcane Weaving component |
| 23 | LCK passive +1 | Stat milestone |
| 31 | Field Notes: Deep Net | Catches multiple fish per action |
| 38 | Field Notes: Aquatic Reagents | Rare fish organs for Alchemy |
| 47 | Abyssal fishing zone | Rare deep-sea creatures |
| 56 | Field Notes: Leviathan Lure | Alchemy Formulae; rare boss-fish encounter |
| 64 | LCK passive +2 | Stat milestone |
| 73 | Dragon Eel | High Cookery buff; rare Arcane Weaving scale |
| 84 | Field Notes: Void Kraken Ink | Inscription endgame; rarest aquatic drop |
| 93 | Deep net passive double-catch chance | Efficiency gain |
| 100 | Rare fish guaranteed on Attunement cast | Mastery — active fishing always yields rare tier |

---

### 🔍 Gleaning
> Scavenge battlefields, ruins, and dungeons. Rare find rate and salvage quality scale with LCK and level.

**Primary Stats:** LCK
**Unlock Term:** Field Notes
**Idle Action:** Auto-scavenges assigned ruin zone
**Active Attunement:** Spot and tap hidden cache icons before they fade — reveals bonus loot tier

| Level | Unlock | Notes |
|-------|--------|-------|
| 1 | Common Salvage (scrap metal, worn cloth) | Smelting and Tailoring low input |
| 12 | Field Notes: Ruin Search | Better loot table in ancient zones |
| 23 | LCK passive +2 | Stat milestone |
| 31 | Old Coin drops | Grand Exchange currency value |
| 38 | Field Notes: Ancient Text Fragment | Feeds Inscription and Runelore |
| 47 | Dungeon Gleaning unlocked | Post-combat loot room access |
| 54 | Battlefield Gleaning unlocked | Hostile zone scavenging |
| 63 | Field Notes: Lost Schematic | Random mid-tier Schematic drop |
| 71 | LCK passive +3 | Stat milestone |
| 79 | Assembly Rare Material drops added to loot table | Key economic unlock |
| 86 | Field Notes: Vault Cache | Rare high-value multi-item find |
| 92 | Epic Assembly Material drops possible | Rare; drives economy |
| 100 | Hidden cache always visible in current zone | Mastery — no more missed spawns |

---

### 🌾 Cultivation
> Farm crops, grow reagent plants, and tend orchards. Yield quantity and rare plant availability scale with level.

**Primary Stats:** WIL
**Unlock Term:** Field Notes
**Idle Action:** Auto-tends crop plots (time-gated by growth cycle)
**Active Attunement:** Water, prune, or treat plants when prompt appears — boosts yield quantity and quality tier

| Level | Unlock | Notes |
|-------|--------|-------|
| 1 | Basic Crops (Wheat, Potato) | Cookery staple ingredients |
| 8 | Herb Garden plots | Alchemy input supplement |
| 13 | Fiber Crops (Flax, Cotton) | Tailoring input |
| 19 | Field Notes: Compost Formulae | Boosts crop yield rate |
| 24 | Paper Plants (Reed, Papyrus) | Inscription input |
| 32 | Orchard plots | Fruit for Cookery; rare seed drops |
| 38 | WIL passive +2 | Stat milestone |
| 44 | Field Notes: Alchemical Garden | Grows Alchemy-grade reagents |
| 53 | Field Notes: Enchanted Soil | Rare plant growth unlocked |
| 61 | Moonflower plots | Night-cycle only; Alchemy and Inscription enchanting |
| 69 | WIL passive +3 | Stat milestone |
| 76 | Field Notes: Void Bloom Cultivation | Warlock reagent; very slow growth |
| 84 | Field Notes: Worldseed | Legendary crop; one plot per account |
| 93 | Growth cycles reduced by 20% | Efficiency gain |
| 100 | Crop plots never fail or wither | Mastery — idle cultivation fully reliable |

---

### 🐾 Tracking
> Read terrain to locate rare creatures and hidden resource nodes. Feeds Trapping, Beastmastery, and Gleaning.

**Primary Stats:** DEX, INT
**Unlock Term:** Field Notes
**Idle Action:** Passively reveals node locations in current zone
**Active Attunement:** Follow trail indicators on screen — successfully tracking reveals creature location for Trapping or Beastmastery

| Level | Unlock | Notes |
|-------|--------|-------|
| 1 | Basic Animal Tracks | Reveals common creature zones |
| 11 | Field Notes: Terrain Reading | Bonus node reveal in Foraging zones |
| 22 | Rare Creature Trails | Feeds high-tier Trapping |
| 33 | Field Notes: Monster Sign | Builds elite encounter queue (max 3) — successful tracking attunement adds a guaranteed elite encounter to queue, pulled before random spawns. +20% drop rate on queued elites |
| 44 | DEX passive +2, INT passive +1 | Stat milestone |
| 53 | Field Notes: Ancient Trail | Reveals hidden Gleaning cache locations |
| 63 | Void Creature Tracks | Endgame creature locations |
| 74 | Field Notes: Legendary Spoor | Tracks legendary creatures *(Beastmastery taming reserved for Beastbond DLC)* |
| 87 | INT passive +3 | Stat milestone |
| 100 | All active rare nodes visible across current biome passively | Mastery — no active tracking needed in mastered biome |

---

## ⚙️ PROCESSING TALENTS

---

### 🧪 Alchemy
> Brew potions, poisons, elixirs, and reagent compounds. Formulae complexity and potency scale with level.

**Primary Stats:** INT, LCK
**Unlock Term:** Formulae
**Idle Action:** Auto-brews assigned Formulae in queue
**Active Attunement:** Stir timing mini-game — hit the correct window for +1 extra output per batch

| Level | Formulae Unlock | Requires | Output |
|-------|----------------|----------|--------|
| 1 | Minor Healing Draught | Ironwort (Foraging 1) | +20 HP restore |
| 7 | Antidote Vial | Thornroot (Foraging 29) | Cures poison |
| 13 | Minor Stamina Elixir | Goldmoss (Foraging 18) | +10% active Attunement window |
| 19 | Poison Coating | Thornroot + Fox Bile (Trapping 9) | Quiver buff — X min; procs per hit |
| 26 | INT passive +1 | — | Stat milestone |
| 32 | Taming Lure | Shadowleaf + Honey (Cultivation 32) | Beastmastery catch rate +25% |
| 38 | Fire Coating | Emberpetal (Foraging 68) | Quiver buff — fire damage procs per hit |
| 44 | Major Healing Draught | Starbloom (Foraging 43) + Pearl (Dredging 17) | +80 HP restore |
| 51 | Strength Elixir | Ironbark Sap (Felling 14) | STR +5 for 10 min |
| 57 | INT passive +3 | — | Stat milestone |
| 63 | Frost Coating | Glacial Moss (Foraging 74) | Quiver buff — frost slow procs per hit |
| 68 | Shadow Blend | Voidmoss (Foraging 57) | Stealth potion; bonus scales with Shadowblade Warfare level |
| 74 | Leviathan Lure | Dragon Eel Oil (Dredging 73) | Rare fish encounter trigger |
| 79 | Fortify Elixir | Adamantine Dust (Delving 76) | VIT +10 for dungeon duration |
| 86 | Void Coating | Soulite Dust (Delving 92) + Voidmoss | Quiver buff — stacking void debuff procs |
| 91 | Master Healing Draught | Celestine Sprig (Foraging 95) | Full HP restore |
| 100 | All Formulae produce minimum 2 outputs per batch | Mastery — consistent yield floor guaranteed |

---

### 🍖 Cookery
> Prepare meals for stat buffs, HP recovery, and dungeon provisions. Food buffs and potion buffs stack — Cookery cannot be replaced by Alchemy.

**Primary Stats:** VIT, INT
**Unlock Term:** Formulae
**Idle Action:** Auto-cooks assigned Formulae in queue
**Active Attunement:** Heat management mini-game — keep temperature in correct zone for bonus portions or quality upgrade

| Level | Formulae Unlock | Requires | Output / Buff |
|-------|----------------|----------|---------------|
| 1 | Roasted Rabbit | Rabbit Meat (Trapping 1) | +10 HP; minor VIT buff |
| 8 | Herb Broth | Thyme (Foraging 1) + Water | Minor stamina regen |
| 14 | Venison Stew | Venison (Trapping 22) + Potato (Cultivation 1) | +30 HP; STR +2 for 15 min |
| 21 | Hunter's Ration | Any meat + Wheat (Cultivation 1) | Portable field food; no cook time penalty |
| 27 | VIT passive +1 | — | Stat milestone |
| 33 | Focus Meal | Perch (Dredging 1) + Herb (Foraging 7) | Crit chance +5% for 20 min |
| 39 | Endurance Feast | Boar Meat (Trapping 39) + Grain | HP regen +10/min in combat |
| 46 | Alchemist's Lunch | Goldmoss Tea + Carp (Dredging 1) | INT +3 for 30 min |
| 54 | Dungeon Provision Pack | 3x any meal combined | Party-shareable; feeds party larder in dungeons |
| 61 | VIT passive +3 | — | Stat milestone |
| 67 | Warden's Focus Meal | Dragon Eel (Dredging 73) + Moonflower Oil | Crit chance +15%; DEX +5 for dungeon |
| 73 | Formulae: Masterwork Feast | Worldseed Grain (Cultivation 84) | All stats +5 for 1 hr |
| 83 | Formulae: Feast of the Grimoire | Legendary multi-ingredient | All stats +8 for 2 hrs; full HP on consume |
| 100 | Meals never burn during idle cook — quality always maintained | Mastery — idle Cookery queue is fully reliable |

---

### 🪣 Tanning
> Process raw hides and pelts into leather. Leather grade scales with pelt quality and Tanning level.

**Primary Stats:** DEX, INT
**Unlock Term:** Schematic
**Idle Action:** Auto-processes assigned pelt type
**Active Attunement:** Scraping rhythm mini-game — correct timing yields bonus leather strips

| Level | Schematic Unlock | Requires | Output |
|-------|-----------------|----------|--------|
| 1 | Rough Leather | Common Pelt (Trapping 1) | Tailoring tier 1 input |
| 12 | Cured Leather | Fox Pelt (Trapping 9) + Salt | Tailoring tier 2 |
| 23 | Fine Leather | Deer Hide (Trapping 22) | Light armor base |
| 37 | Hardened Leather | Boar Hide (Trapping 39) | Medium armor base |
| 49 | Wolf Leather | Wolf Pelt (Trapping 61) | High-tier light armor |
| 62 | DEX passive +2 | — | Stat milestone |
| 71 | Schematic: Scale Preparation | Drake Scales (Trapping 82) | Arcane Weaving component |
| 83 | Masterwork Leather | Multi-pelt compound process | Endgame light armor base |
| 91 | Schematic: Void Hide | Void creature pelt (Trapping 89) | Legendary armor material |
| 100 | Pelt processing never downgrades leather quality | Mastery — output tier always matches input pelt quality |

---

### 🔥 Smelting
> Refine raw ores into metal bars and alloys. Feeds Runesmithing and Artificing.

**Primary Stats:** STR, INT
**Unlock Term:** Schematic
**Idle Action:** Auto-smelts assigned ore in furnace queue
**Active Attunement:** Bellows pump timing — maintain heat in optimal range for bonus bar yield

| Level | Schematic Unlock | Requires | Output |
|-------|-----------------|----------|--------|
| 1 | Bronze Bar | Copper + Tin Ore (Delving 1) | Basic Runesmithing input |
| 11 | Iron Bar | Iron Ore (Delving 14) | Mid-tier gear base |
| 22 | Steel Bar | Iron Bar + Coal (Delving 37) | Better weapons and armor |
| 33 | Silver Bar | Silver Ore (Delving 33) | Inscription enchanting foci; jewelry |
| 43 | Gold Bar | Gold Ore (Delving 49) | High economy value |
| 54 | Mithril Bar | Mithril Ore (Delving 64) | Endgame light armor |
| 63 | STR passive +2 | — | Stat milestone |
| 68 | Adamantine Bar | Adamantine Ore (Delving 76) | Endgame heavy armor |
| 76 | Starstone Bar | Starstone Ore (Delving 86) | Magical weapon base |
| 84 | Void Alloy | Soulite Ore (Delving 92) + Voidtimber Ash | Legendary weapon/armor base |
| 93 | Schematic: Grimoire Steel | Multi-ore legendary alloy | Endgame forge only |
| 100 | Smelting never produces impure bars | Mastery — all output bars are full quality regardless of ore condition |

---

### 🪵 Timber Shaping
> Mill and shape logs into planks, grips, hafts, poles, and shafts for weapon assembly. One component per weapon.

**Primary Stats:** STR, DEX
**Unlock Term:** Schematic
**Idle Action:** Auto-mills assigned timber type
**Active Attunement:** Grain-following mini-game — trace the wood grain path for bonus output

| Level | Schematic Unlock | Requires | Output / Use |
|-------|-----------------|----------|-------------|
| 1 | Pine Grip | Pine (Felling 1) | Sword/Dagger grip; basic bow grip |
| 9 | Softwood Haft | Birch (Felling 1) | Axe and spear haft |
| 16 | Hardwood Grip | Oak (Felling 14) | Better sword and bow grip |
| 23 | Hardwood Shaft | Elm (Felling 14) | Staff and wand shaft |
| 31 | STR passive +1 | — | Stat milestone |
| 37 | Ashwood Pole | Ashwood (Felling 33) | Spear and halberd pole |
| 44 | Ironbark Grip | Ironbark (Felling 33) | Heavy weapon grips |
| 52 | Magicwood Shaft | Magicwood (Felling 52) | Arcane staff and wand shafts |
| 59 | DEX passive +2 | — | Stat milestone |
| 66 | Ironbark Heartwood Grip | Ironbark Heartwood (Felling 71) | Endgame weapon grips |
| 74 | Voidtimber Shaft | Voidtimber (Felling 84) | Warlock staff shaft |
| 81 | STR passive +3 | — | Stat milestone |
| 89 | Worldtree Grip | Worldtree Shard (Felling 89) | Legendary weapon component |
| 100 | Wood grain always optimal — bonus output on every mill | Mastery — Attunement bonus becomes baseline |

---

### ⚒️ Runesmithing
> Forge weapon blades, heads, tips, and armor from refined metal. One metal component per weapon — assembled with Timber Shaping or Tanning component at Workbench.

**Primary Stats:** STR, INT
**Unlock Term:** Schematic
**Idle Action:** Auto-forges queued Schematics
**Active Attunement:** Strike timing on the anvil — hit the glowing point for bonus quality on the component

| Level | Schematic Unlock | Requires | Output |
|-------|-----------------|----------|--------|
| 1 | Bronze Blade | Bronze Bar (Smelting 1) | Sword/Dagger component |
| 6 | Bronze Limbs | Bronze Bar | Bow component |
| 13 | Iron Blade | Iron Bar (Smelting 11) | Mid-tier sword/dagger |
| 19 | Iron Arrowtip | Iron Bar | Quiver reinforcement (Tailoring) |
| 27 | Steel Blade | Steel Bar (Smelting 22) | Better sword component |
| 34 | Steel Limbs | Steel Bar | Mid-tier bow component |
| 41 | Silver Tip | Silver Bar (Smelting 33) | Wand tip; Arcanist focus |
| 48 | Schematic: Runed Blade | Steel Bar + Runelore 30 | Inscription enchanting-ready slot |
| 56 | Mithril Limbs | Mithril Bar (Smelting 54) | High-tier bow component |
| 62 | STR passive +2 | — | Stat milestone |
| 67 | Adamantine Plate components | Adamantine Bar (Smelting 68) | Heavy armor; Vanguard |
| 73 | Starstone Tip | Starstone Bar (Smelting 76) | Arcanist endgame wand |
| 78 | Starstone Core | Starstone Bar | Staff core component |
| 84 | Void Limbs | Void Alloy (Smelting 84) | Warden legendary bow component |
| 88 | Void Blade | Void Alloy | Legendary sword component |
| 94 | Grimoire Steel components | Grimoire Steel (Smelting 93) | All weapon types; endgame |
| 100 | Assembly Attunement bonus permanently active for all Runesmithing components | Mastery — components always at peak quality |

---

### 🧵 Tailoring
> Craft cloth and leather armor, cloaks, quivers, and bags. Quiver is the Warden's core equipment item.

**Primary Stats:** DEX
**Unlock Term:** Pattern
**Idle Action:** Auto-crafts queued Patterns
**Active Attunement:** Thread-pulling mini-game — consistent tension for bonus armor rating on output

| Level | Pattern Unlock | Requires | Output |
|-------|---------------|----------|--------|
| 1 | Rough Cloth Tunic | Flax (Cultivation 13) | Basic armor |
| 8 | Leather Vest | Rough Leather (Tanning 1) | Light armor tier 1 |
| 14 | Standard Quiver | Cured Leather (Tanning 12) | Warden core item; infinite arrows |
| 21 | Fine Leather Armor | Fine Leather (Tanning 23) | Light armor tier 2 |
| 29 | DEX passive +1 | — | Stat milestone |
| 36 | Warden's Cloak | Wolf Leather (Tanning 49) + Starbloom thread | DEX +3; Attunement window +5 sec |
| 43 | Pattern: Reinforced Quiver | Hardened Leather (Tanning 37) | Better quiver; fire rate +5% |
| 51 | Enchantment-Ready Garment | Masterwork Leather + Silver Thread | Inscription enchanting slot unlocked |
| 58 | Pattern: Shadowweave Cloak | Voidmoss thread + Wolf Leather | Stealth bonus scales with Shadowblade Warfare level |
| 67 | Pattern: Elemental Quiver | Arcane Weaving 40 + Fine Leather | Passive elemental coating slot |
| 74 | Pattern: Arcane Vestments | Arcane Weaving output + Fine Leather | Arcanist armor; INT +5 |
| 83 | Pattern: Masterwork Quiver | Masterwork Leather + Magicwood frame | Fire rate +15%; 2 coating slots |
| 91 | DEX passive +4 | — | Major stat milestone |
| 100 | Quiver coating duration never degrades on idle | Mastery — coatings tick at full rate even offline |

---

### 🔮 Arcane Weaving
> Craft magical items, foci, and enchanted components. Requires both material and Arcane knowledge prerequisites.

**Primary Stats:** INT, WIL
**Unlock Term:** Pattern
**Idle Action:** Auto-weaves queued Patterns
**Active Attunement:** Mana thread alignment — drag threads into correct formation for bonus magical potency

| Level | Pattern Unlock | Requires | Output |
|-------|---------------|----------|--------|
| 1 | Basic Wand Tip wrap | Softwood + Quartz (Delving 21) | Arcanist focus supplement |
| 11 | Foci Orb | Silver Bar (Smelting 33) + Pearl (Dredging 17) | Arcanist Grimoire combat amplifier — boosts constellation spell power |
| 22 | Emberpetal Weave | Emberpetal (Foraging 68) + Fine Leather | Fire resistance armor component |
| 34 | WIL passive +2 | — | Stat milestone |
| 43 | Drake Scale Mantle | Drake Scales (Tanning 71) + Silver thread | High magic resist |
| 53 | INT passive +2 | — | Stat milestone |
| 62 | Pattern: Elemental Quiver base | Fine Leather + Starbloom thread | Feeds Tailoring 67 unlock |
| 69 | Pattern: Void Foci | Voidstone (Delving 81) + Voidmoss thread | Warlock casting item |
| 77 | Pattern: Celestine Robe | Celestine Sprig thread + Starstone Bar | Top-tier Arcanist armor |
| 86 | WIL passive +4 | — | Major stat milestone |
| 100 | Woven items never lose magical potency on idle queue | Mastery — Arcane Weaving idle output always at peak quality |

---

### 🔧 Artificing
> Build mechanical devices, traps, contraptions, and tools that assist idle tasks and combat.

**Primary Stats:** INT, DEX
**Unlock Term:** Schematic
**Idle Action:** Auto-crafts queued Schematics
**Active Attunement:** Assembly sequence mini-game — connect components in correct order for bonus durability

| Level | Schematic Unlock | Requires | Output |
|-------|-----------------|----------|--------|
| 1 | Reinforced Snare | Iron Bar + Softwood | Trapping upgrade |
| 13 | Clockwork Trap | Steel Bar + Hardwood | Auto-resets; no manual check needed |
| 22 | Tinderbox | Flint Fragment + Iron | Cookery fire starter |
| 33 | Schematic: Portable Forge | Iron Bar + Hardwood Beam | Field Smelting at reduced rate |
| 43 | Schematic: Beast Cage | Adamantine Bar + Hardwood | Live capture; Beastmastery tier 2 |
| 51 | INT passive +2 | — | Stat milestone |
| 58 | Schematic: Auto-Fisher | Mithril Bar + Magicwood | Dredging idle speed +25% |
| 67 | Schematic: Field Workbench | Adamantine Bar + Ironbark Heartwood | Assembly available in field |
| 76 | Schematic: Runed Contraption | Starstone Bar + Ancient Fossil | Arcane-enhanced idle device |
| 84 | Schematic: Grimoire Engine | Grimoire Steel + Worldtree Timber | Unlocks 2 bonus idle Talent slots |
| 100 | Artificed devices never break or degrade | Mastery — devices run indefinitely without repair |

---

### 📜 Inscription
> Create scrolls, spellbooks, zone maps, and diplomatic texts. Also handles gear enchanting directly — Enchanting is merged into this Talent. Feeds Divination and Runelore.

**Primary Stats:** INT, WIL
**Unlock Term:** Codex Entry
**Idle Action:** Auto-inscribes queued Codex Entries
**Active Attunement:** Calligraphy stroke accuracy — trace glyph paths correctly for bonus scroll charges or potency

| Level | Codex Entry Unlock | Requires | Output |
|-------|-------------------|----------|--------|
| 1 | Rough Zone Map | Reed Paper (Cultivation 24) + Ink | Zone-specific: +5% yield, +2% drop rate for 1hr in that zone. Player-sellable on Exchange |
| 25 | Refined Zone Map | Papyrus + Silver Ink | +8% yield, +4% drop rate for 1hr — higher Exchange value |
| 51 | Pristine Zone Map | Papyrus + Starbloom Ink | +12% yield, +6% drop rate for 1hr |
| 76 | Masterwork Zone Map | Grimoire Root Ink | +15% yield, +8% drop rate for 1hr — endgame farming staple |
| 22 | Faction Letter | Papyrus (Cultivation 24) + Silver Ink | Faction Reputation gain item |
| 33 | Spellbook Page | Papyrus + Starbloom Ink | Arcanist Technique carrier |
| 41 | WIL passive +2 | — | Stat milestone |
| 44 | Crude gear enchantment | Any Crude tier gear owned | Imbue stat bonuses on Crude weapons/armor |
| 55 | Rough gear enchantment | Rough tier gear owned | Imbue stat bonuses on Rough weapons/armor |
| 66 | Refined gear enchantment | Refined tier gear owned | Imbue stat bonuses on Refined weapons/armor |
| 77 | Pristine gear enchantment | Pristine tier gear owned | Dual enchant slot unlocked |
| 88 | Masterwork gear enchantment | Masterwork tier gear owned | Triple enchant slot unlocked |
| 48 | Codex Entry: Ancient Text Copy | Ancient Text Fragment (Gleaning 38) | Feeds Runelore deep unlock |
| 56 | Treasure Map | Dragon Eel Ink (Dredging 73) | Reveals hidden Gleaning cache |
| 64 | INT passive +2 | — | Stat milestone |
| 72 | Codex Entry: Diplomatic Charter | Grimoire Root Ink (Foraging 83) | High Faction Reputation item |
| 81 | *(Summoner's Tome removed — now a rare dungeon/raid drop, not crafted)* | — | — |
| 91 | Codex Entry: The Living Grimoire | Soulflower Ink + Worldseed Paper | Passive XP boost to all Talents |
| 100 | All scrolls produced with maximum charge count | Mastery — scroll output always at charge cap |

---

## ⚔️ COMBAT TALENTS — REMOVED

> **Combat Talents have been removed from the Talent system.**
> Marksmanship, Spellcasting, and Warfare (Warden/Arcanist/Vanguard combat progressions) now live as **Grimoire Combat Progression** on each individual Grimoire — not as shared Talents.
>
> - Each Grimoire has its own combat level (1–100) tracked independently
> - Switching Grimoires starts fresh on that Grimoire's combat progression
> - Combat unlocks (Techniques, combos, rune combinations) live on the Grimoire's Combat Tab
> - Zone unlock gate = Total Combat Level (sum of all owned Grimoire levels)
> - Slaying XP feeds the currently equipped Grimoire's combat level
>
> See docs/wayferers-exchange-and-grimoire-system.md for full Grimoire combat progression spec.

---

### 🏹 Marksmanship — REMOVED (moved to Grimoire)
> Ranged combat proficiency — accuracy, draw speed, crit chance, and Bowstring mechanic depth. Warden primary combat Talent.

**Primary Stats:** DEX, LCK
**Unlock Term:** Technique
**Idle Action:** Auto-combat at base accuracy with no Attunement bonus
**Active Attunement:** Full Bowstring mechanic — draw direction, power hold, timing, and crit zone targeting

| Level | Technique Unlock | Notes |
|-------|-----------------|-------|
| 1 | Basic Draw | Bowstring mechanic active |
| 9 | Technique: Aimed Shot | Manual crit zone targeting unlocked |
| 17 | DEX passive +1 | Stat milestone |
| 24 | Coating application unlocked | Poison/elemental quiver buff access |
| 31 | Technique: Rapid Fire | 3-shot burst; Attunement XP bonus |
| 38 | LCK passive +2 | Stat milestone |
| 44 | Technique: Headshot | Instant kill on normal enemies; stagger elites |
| 52 | Technique: Trick Shot | Sharpshot exclusive; bank shots off terrain |
| 59 | DEX passive +3 | Stat milestone |
| 66 | Technique: Volley | AoE arrow spread; crowd control |
| 73 | LCK passive +3 | Stat milestone |
| 79 | Technique: Void Arrow | Requires Void Limb bow (Runesmithing 84) |
| 86 | Technique: Hunter's Instinct | Weak points always visible on enemies |
| 93 | Draw speed cap raised | Allows faster fire rate ceiling for rapid builds |
| 100 | Idle auto-combat uses last active Technique at 75% potency | Mastery — active playstyle persists partially into idle |

---

### ⚔️ Slaying
> General monster combat for XP and item drops. Scales with equipped gear and class. The universal combat Talent.

**Primary Stats:** STR or DEX or INT (class dependent)
**Unlock Term:** Technique
**Idle Action:** Auto-combat in assigned zone
**Active Attunement:** Class-specific active input (Bowstring for Warden; rune constellation for Arcanist; melee combos for Vanguard)

| Level | Technique Unlock | Notes |
|-------|-----------------|-------|
| 1 | Basic Combat | Zone 1 enemies |
| 11 | Technique: Finishing Blow | Execute low-HP enemies for bonus XP |
| 22 | Technique: Combat Awareness | Dodge window unlocked |
| 33 | Technique: Hunter's Mark | Mark target for +20% damage |
| 57 | Technique: Slayer's Focus | +20% XP from combat for 10 min cooldown |

> Note: Zone access no longer gated by Slaying level — gated by Total Combat Level instead. Slaying governs task board content and spawn rate bonuses only.
| 100 | Idle auto-combat never retreats from Zone 4 or lower | Mastery — reliable high-zone idle farming |

---

### 🐾 Beastmastery
> Tame, train, and command creatures for combat and idle task assistance. Familiar quality and slots scale with level.

**Primary Stats:** CHA, DEX
**Unlock Term:** Technique
**Idle Action:** Familiars assist assigned idle Talent automatically
**Active Attunement:** Taming encounter — weaken creature then apply Taming Lure at correct moment

| Level | Technique Unlock | Notes |
|-------|-----------------|-------|
| 1 | 1 Familiar slot | Basic animals only |
| 13 | Technique: Basic Command | Familiar assists Foraging or Trapping |
| 24 | 2 Familiar slots | |
| 33 | Rare creature taming | Trapping 46 required |
| 44 | 3 Familiar slots | |
| 53 | Technique: Combat Familiar | Familiar attacks during Slaying |
| 62 | Magical creature taming | Trapping 73 + Runelore 40 required |
| 71 | 4 Familiar slots | Grand Exchange creature listing unlocked |
| 82 | Technique: Pack Bond | All familiars +20% efficiency |
| 91 | 5 Familiar slots | |
| 100 | Familiars never lose assigned task on session restart | Mastery — familiar queue persists across sessions reliably |

---

## 🔮 ARCANE TALENTS

---

### ✨ Enchanting
> ⚠️ MERGED INTO INSCRIPTION — Enchanting is no longer a separate Talent. Gear enchanting unlocks are now gated within the Inscription Talent by equipment tier ownership. See Inscription spec above for full enchanting unlock table.

*This section retained for reference only — do not implement as a separate Talent.*

| Level | Codex Entry Unlock | Requires | Output |
|-------|-------------------|----------|--------|
| 1 | Minor Accuracy | Quartz dust + Minor Scroll | +2% hit chance on weapon |
| 16 | Minor Fortify | Jasper dust + Scroll | +5 armor rating |
| 27 | Elemental Edge (Fire) | Ruby dust + Fire Coating Formulae | Fire damage on weapon |
| 38 | Elemental Edge (Frost) | Sapphire dust + Frost Coating | Frost slow on weapon |
| 48 | INT passive +2, LCK passive +2 | — | Stat milestone |
| 56 | Major Accuracy | Diamond dust + Spellbook Page | +10% crit chance |
| 64 | Elemental Edge (Void) | Voidstone dust + Void Foci | Void damage + debuff |
| 73 | Second enchantment slot unlock | Inscription 64 required | Dual enchant on gear |
| 83 | Major Fortify | Celestine dust + Living Grimoire page | +25 armor rating |
| 91 | Third enchantment slot unlock | Inscription 81 required | Triple enchant on gear |
| 100 | Enchantment application never fails | Mastery — no more lost reagents on failed application |

---

### 🔭 Divination — DEFERRED
> Divination has been removed from the base game Talent roster. Mechanically overlaps with Tracking's node-reveal functions. Reserved for a future Arcane or Faction DLC where "reading omens to predict faction movements, rare spawn windows, or future events" becomes a genuinely distinct mechanic.
>
> Do not implement in Phase 1 or Phase 2. Talent slot reserved on the Talents page with a "???" placeholder.

---

### 📖 Runelore
> Study and decode ancient runes for passive bonuses and crafting unlocks. Fed by Gleaning and Inscription.

**Primary Stats:** INT
**Unlock Term:** Codex Entry
**Idle Action:** Auto-studies assigned texts and fossils
**Active Attunement:** Glyph matching — decode rune sequences for bonus study XP

| Level | Codex Entry Unlock | Effect |
|-------|-------------------|--------|
| 1 | Basic Rune Reading | Unlocks Runesmithing Runed Blade at level 48 |
| 18 | Ancient Script | Inscription bonus: +1 scroll charge per batch |
| 33 | INT passive +2 | Stat milestone |
| 43 | Runed Trap unlock | Trapping 73 magical creatures |
| 58 | Deep Rune Mastery | Runesmithing output: +5% stat bonus on forged items |
| 71 | INT passive +3 | Stat milestone |
| 84 | Elder Tongue Fragment | Hidden Runesmithing Schematics accessible |
| 100 | Rune study never produces failed reads | Mastery — all Gleaning ancient texts yield Runelore XP |

---

### 🌑 Spellcasting — Runic Constellation System
> The Arcanist's primary combat Talent. Spells are cast by drawing lines between rune nodes on the Runic Constellation. Rune combinations determine spell type and effect. Subclass alters rune behavior, not rune availability — same gesture, different outcome.

**Primary Stats:** INT, WIL
**Unlock Term:** Technique
**Idle Action:** Auto-casts last queued single-rune spell at 60% potency
**Active Attunement:** Draw rune combinations on the constellation — speed affects cast time, accuracy affects potency

### Rune Types (unlocked by Spellcasting level — available to all subclasses)
| Rune | Element | Unlocked At |
|------|---------|-------------|
| Ignis | Fire | Level 1 |
| Glacius | Frost | Level 1 |
| Tempest | Lightning | Level 13 |
| Terra | Earth | Level 13 |
| Ventus | Wind | Level 27 |
| Vita | Life | Level 27 |
| Umbra | Void/Dark | Level 44 |
| Lux | Light | Level 44 |

### Subclass Rune Behavior
Same rune, same gesture — different effect based on subclass:

| Rune | Runeweaver | Warlock | Summoner | Lifebinder |
|------|-----------|---------|----------|------------|
| Vita | Minor self-heal | Drain life from enemy | Heal familiar | Heal ally |
| Umbra | Void damage burst | Soul harvest trigger | Summon shade | Purge debuff from ally |
| Ignis | Fire damage | Hellfire DoT | Fire familiar buff | Cauterize — stop bleed |
| Glacius | Frost AoE slow | Freeze single target | Freeze familiar-assist | Cryo-stasis ally (brief invincible) |
| Lux | Blind enemy | Weaken undead | Empower familiar | Major heal + shield |
| Tempest | Chain lightning | Curse arc | Lightning familiar | Revive pulse (multiplayer) |
| Terra | Rock wall barrier | Entomb enemy | Summon stone guardian | Ground ally (prevent knockback) |
| Ventus | Wind knockback | Vortex pull | Speed familiar | Haste buff on ally |

### Spell Combination Tiers (all subclasses)
| Spellcasting Level | Unlock |
|-------------------|--------|
| 1 | Single rune casts — basic elemental effect |
| 16 | 2-rune combinations — compound spells |
| 33 | Counter-element combos (Ignis+Glacius = Steam Burst, etc.) |
| 47 | 3-rune combinations — advanced spells |
| 63 | Resonance combos — same rune twice amplifies rather than cancels |
| 78 | 4-rune combinations — complex spells |
| 88 | Full constellation draws — all available runes in sequence |
| 100 | Idle fallback upgrades to 2-rune auto-cast at 75% potency | Mastery — idle Arcanist now uses compound spells automatically |

### Example Combinations
| Combination | Effect |
|-------------|--------|
| Ignis → Glacius | Steam Burst — AoE blind + slow |
| Ignis → Ignis | Fireball — high single damage |
| Umbra → Vita | Soul Drain — damage + self-heal (Warlock: bonus soul harvest) |
| Tempest → Ventus | Storm Surge — AoE knockback + chain lightning |
| Terra → Terra | Earthquake — AoE stun |
| Lux → Umbra | Eclipse — high damage + debuff strip |
| Glacius → Ventus → Glacius | Blizzard — sustained AoE frost field |
| Vita → Lux → Vita | Restoration Wave (Lifebinder) — full party heal pulse |

---

### 👻 Soulbinding
> Warlock exclusive. Bind spirits and harvest souls from defeated enemies for a passive soul resource idle loop.

**Primary Stats:** WIL, LCK
**Unlock Term:** Codex Entry
**Idle Action:** Soul Harvest runs passively after each Slaying action; souls accumulate in Soul Reservoir
**Active Attunement:** Binding ritual timing — catch the spirit at the moment of enemy death for bonus soul quality

| Level | Codex Entry Unlock | Effect |
|-------|-------------------|--------|
| 1 | Minor Soul Harvest | 1 soul per kill; fills Soul Reservoir |
| 14 | Codex Entry: Spirit Bind | Bound spirit assists one idle Talent |
| 27 | WIL passive +2 | Stat milestone |
| 38 | Soul Forge | Convert souls into Soulite Ore equivalent |
| 51 | Greater Soul Harvest | 3 souls per kill; rare soul type possible |
| 63 | WIL passive +3 | Stat milestone |
| 74 | Codex Entry: Dark Pact | Trade souls for temporary major stat boost |
| 84 | Rare soul types feed Arcane Weaving endgame | Cross-Talent economic unlock |
| 100 | Soul Reservoir never decays during idle | Mastery — souls persist indefinitely between sessions |

---

## 📊 Cross-Dependency Gate Summary

| To Unlock | You Need |
|-----------|----------|
| Steel Gear Assembly | Smelting 22 + Timber Shaping 16 + Runesmithing 27 |
| Mithril Gear Assembly | Smelting 54 + Timber Shaping 52 + Runesmithing 56 |
| Warden's Focus Meal | Dredging 73 + Cultivation 61 |
| Magical Creature Taming | Trapping 73 + Runelore 43 |
| Poison Quiver Buff | Alchemy 19 + Tailoring 14 + Warden Grimoire combat level 24 |
| Elemental Quiver | Tailoring 67 + Arcane Weaving 62 |
| Void Gear Assembly | Smelting 84 + Delving 92 + Timber Shaping 74 + Runesmithing 84 |
| Triple Enchant Slot | Inscription 88 (Masterwork gear enchantment unlock) |
| Legendary Assembly | Assembler Talent 85+ + Legendary material + relevant components |
| Full Constellation Casting | Arcanist Grimoire combat level 88 + Arcane Weaving 69 + Inscription 55 |

---

*Document version 0.5 — Talent Spec Sheets*
*Key changes: Shadowcraft → Warfare, Enchanting → Inscription, Divination deferred, Beastmastery DLC stubs, combat cross-dependencies updated*
*Key change: Combat Talents (Marksmanship, Spellcasting, Warfare) removed from Talent system — moved to Grimoire Combat Progression*
*Key change: Enchanting merged into Inscription. Summoner's Tome moved to dungeon/raid drop. Zone Maps now consumable buffs with tier progression.*
*Next: Enemy zone tables · Assembly material tables · Grand Exchange baseline item values · Subclass deep tree specs · Stat scaling formulas*
