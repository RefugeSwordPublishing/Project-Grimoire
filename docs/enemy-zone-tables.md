# ⚔️ Project Grimoire — Enemy Zone Tables
### Version 0.1

---

## 📐 Global Zone Rules

### Zone Unlock
- Zones unlock based on **highest single combat Talent** across all equipped Grimoires
- Combat Talents: Marksmanship, Slaying, Beastmastery, Wardancing, Shadowcraft, Vanguarding, Spellcasting
- Players can access zones above their combat effectiveness — risk/reward decision

### Branching Structure
Each tier offers **2 zone choices** — different biomes, enemy faction types, and drop focuses. Players choose which branch to work based on what materials they need or what playstyle they prefer. Both branches in a tier share the same level requirement.

### Zone Bosses
- **Active play only** — zone bosses do not spawn during idle auto-combat
- Boss spawn is a **random chance event** during active play sessions (roughly 1 in 20 combat encounters in that zone)
- Notification alert sent when a boss spawns so players can engage immediately
- Boss despawns after 10 minutes if not engaged
- Guaranteed rare material drop on kill — tier scales with zone tier
- Boss kill also grants bonus Slaying XP

### Dungeon Rotation
- **2 active dungeons per month**, refreshed on the 1st of each month
- Each dungeon is tied to a zone — accessing it requires that zone to be unlocked
- Dungeons are **not idle-able** — active play required throughout
- Dungeon theme matches its host zone enemy faction type
- Hard mode dungeons deferred to DLC / New Game Plus

### Raid Schedule
- **1 active raid** at a time, refreshed quarterly
- Announced 2 weeks in advance
- Active play only — no idle fallback during raid
- 25–45 minute target duration; 3-phase structure
- **Only source of Masterwork (T5) rare materials** in base game
- Raid access requires highest combat Talent 75+

### Enemy Faction Tags
Applied to all enemies from day one for DLC faction bonus compatibility:

| Tag | Enemy Types |
|-----|------------|
| `[Outlaw]` | Brigands, poachers, smugglers, deserters |
| `[Beast]` | Wolves, bears, boars, drakes, serpents |
| `[Undead]` | Skeletons, wraiths, revenants, liches |
| `[Arcane]` | Golems, elementals, rune constructs, spell-bound |
| `[Void]` | Void crawlers, shades, corruption beasts, void wraiths |
| `[Nature]` | Treants, vine horrors, spore creatures, bog lurkers |
| `[Elite]` | Named variants of any type — higher stats, better drops |
| `[Boss]` | Zone bosses, dungeon bosses |
| `[Legendary]` | Raid bosses, world event bosses |

### Quality Tier Reference (Updated)
| Tier | Name | Color |
|------|------|-------|
| 1 | Crude | Grey |
| 2 | Rough | White |
| 3 | Refined | Green |
| 4 | Pristine | Blue |
| 5 | Masterwork | Purple |
| 6 | Legendary | Gold | DLC / Events only |

---

## 🗺️ TIER 1 ZONES
**Combat Talent Requirement:** Any combat Talent 1–20
**Tone:** Familiar, approachable — the edges of civilization giving way to wilderness

---

### 🌲 Zone 1A — Grimwood Fringe
*A dense forest at the edge of the kingdom where outlaws have made camp and wild creatures roam freely. The smell of pine and woodsmoke. The sound of distant axes and hushed voices.*

**Primary Enemy Faction:** `[Outlaw]` with `[Beast]` secondary
**Biome:** Temperate forest, clearings, bandit camps
**Dungeon Eligible:** Yes — Aldric's Warren

#### Enemies
| Enemy | Faction Tag | Combat Level | Notable Drop |
|-------|------------|-------------|-------------|
| Grimwood Brigand | `[Outlaw]` | 1–5 | Worn Cloth, Silver Mark |
| Forest Wolf | `[Beast]` | 1–5 | Wolf Pelt (low tier), Bone Fragment |
| Poacher | `[Outlaw]` | 5–10 | Crude Trapper's Kit component, Rough Leather |
| Grimwood Bear | `[Beast]` | 8–12 | Bear Pelt, Bear Claw (Artificing component) |
| Bandit Scout `[Elite]` | `[Outlaw]` | 12–15 | Crude Gemstone, Silver Mark |
| Rabid Wolfpack Leader `[Elite]` | `[Beast]` | 15–20 | Crude Amber, Wolf Fang (rare) |

#### Drop Table
| Item | Type | Drop Chance |
|------|------|------------|
| Silver Mark | Currency | 45% |
| Worn Cloth Scraps | Component | 30% |
| Wolf Pelt | Tanning input | 25% |
| Rough Leather | Tanning input | 20% |
| Bone Fragment | Artificing input | 15% |
| Crude Gemstone | Rare Material T1 | 2% |
| Crude Amber | Rare Material T1 | 1.5% |

#### Zone Boss — *Aldric the Poacher King* `[Outlaw][Boss]`
*A barrel-chested man in mismatched plate, wanted in three kingdoms. Carries a modified crossbow and a hunting knife the size of a short sword.*
- **Spawn:** Random during active play (1 in 20 chance per encounter)
- **Guaranteed Drop:** Crude Gemstone + Crude Amber + Silver Mark pouch
- **Bonus Drop (10%):** Rough Leather Armor piece (pre-assembled, Crude quality)
- **Slaying XP:** 3x standard kill reward

---

### 🌊 Zone 1B — Saltmarsh Shore
*A grey coastal stretch where the sea mist never fully lifts. Smugglers work the coves at night. Strange things wash up from deeper waters. The gulls here don't sound quite right.*

**Primary Enemy Faction:** `[Outlaw]` with `[Beast]` secondary (aquatic)
**Biome:** Coastal cliffs, tidal caves, smuggler coves
**Dungeon Eligible:** Yes — Crestfall Cove

#### Enemies
| Enemy | Faction Tag | Combat Level | Notable Drop |
|-------|------------|-------------|-------------|
| Saltmarsh Smuggler | `[Outlaw]` | 1–5 | Silver Mark, Rough Cloth |
| Shore Crab | `[Beast]` | 1–5 | Crab Shell (Artificing), Aquatic Reagent |
| Coastal Poacher | `[Outlaw]` | 5–10 | Crude Pearl fragment, Fish scraps |
| Saltmarsh Serpent | `[Beast]` | 8–12 | Serpent Scale (Tanning input), Venom Sac (Alchemy) |
| Tide Lurker `[Elite]` | `[Beast]` | 12–15 | Crude Abyssal Pearl, Rare fish drop |
| Smuggler Captain `[Elite]` | `[Outlaw]` | 15–20 | Crude Gemstone, Contraband Goods (sell value) |

#### Drop Table
| Item | Type | Drop Chance |
|------|------|------------|
| Silver Mark | Currency | 45% |
| Rough Cloth Scraps | Component | 28% |
| Serpent Scale | Tanning input | 22% |
| Aquatic Reagent | Alchemy input | 18% |
| Crab Shell | Artificing input | 15% |
| Crude Abyssal Pearl | Rare Material T1 | 2% |
| Crude Gemstone | Rare Material T1 | 1.5% |

#### Zone Boss — *The Saltmother* `[Beast][Boss]`
*An enormous coastal serpent that has coiled itself around the main smuggler cove for decades. The smugglers leave offerings. It has started to expect them.*
- **Spawn:** Random during active play (1 in 20 chance per encounter)
- **Guaranteed Drop:** Crude Abyssal Pearl + Serpent Scale (large) + Silver Mark pouch
- **Bonus Drop (10%):** Crude Wand (pre-assembled)
- **Slaying XP:** 3x standard kill reward

---

## 🗺️ TIER 2 ZONES
**Combat Talent Requirement:** Any combat Talent 21–40
**Tone:** Darker, stranger — civilization thins out, the world gets older and less safe

---

### 🌑 Zone 2A — Ashfen Mire
*A sprawling bog where the trees grow black and the water smells of sulfur. The undead here aren't recent — they've been walking these paths for centuries. Something below the surface stirs.*

**Primary Enemy Faction:** `[Undead]` with `[Nature]` secondary
**Biome:** Swamp, foggy bog, ancient burial mounds
**Dungeon Eligible:** Yes — Mirefall Barrow
**Monthly Dungeon Pool:** Eligible for dungeon rotation slot

#### Enemies
| Enemy | Faction Tag | Combat Level | Notable Drop |
|-------|------------|-------------|-------------|
| Bogwalker Skeleton | `[Undead]` | 21–26 | Bone Shard, Grave Dust (Alchemy) |
| Ashfen Treant | `[Nature]` | 21–26 | Ashwood Burl, Bark Strip |
| Mire Wraith | `[Undead]` | 26–32 | Phantom Pelt (low tier), Grave Cloth |
| Bog Lurker | `[Nature]` | 28–34 | Vine Rope (Artificing), Spore Sac (Alchemy) |
| Barrow Revenant `[Elite]` | `[Undead]` | 32–38 | Rough Phantom Pelt, Old Coin |
| Thornwood Ancient `[Elite]` | `[Nature]` | 34–40 | Rough Amber, Ironbark Fragment |

#### Drop Table
| Item | Type | Drop Chance |
|------|------|------------|
| Silver Mark | Currency | 40% |
| Bone Shard | Artificing/Alchemy input | 30% |
| Grave Dust | Alchemy input | 25% |
| Bark Strip | Felling supplement | 20% |
| Grave Cloth | Tailoring input | 18% |
| Rough Phantom Pelt | Rare Material T2 | 2.5% |
| Rough Amber | Rare Material T2 | 2% |

#### Zone Boss — *The Ashfen Lich* `[Undead][Boss]`
*What was once a court sorcerer, now a skeletal figure in rotting ceremonial robes. It remembers the kingdom that abandoned it. It has a very long memory.*
- **Spawn:** Random during active play (1 in 20 chance per encounter)
- **Guaranteed Drop:** Rough Phantom Pelt + Grave Dust (large) + Old Coin pouch
- **Bonus Drop (10%):** Rough Magical Vestments piece (pre-assembled)
- **Slaying XP:** 4x standard kill reward

---

### 🏔️ Zone 2B — Ironspine Reaches
*A jagged mountain range where outlaw warbands control the passes and something ancient has woken in the deep caves. The stone here is rich with ore — and with danger.*

**Primary Enemy Faction:** `[Outlaw]` with `[Arcane]` secondary
**Biome:** Mountain passes, rocky outcrops, shallow cave entrances
**Dungeon Eligible:** Yes — Warden's Folly
**Monthly Dungeon Pool:** Eligible for dungeon rotation slot

#### Enemies
| Enemy | Faction Tag | Combat Level | Notable Drop |
|-------|------------|-------------|-------------|
| Ironspine Deserter | `[Outlaw]` | 21–26 | Iron Scraps, Worn Steel |
| Mountain Golem | `[Arcane]` | 23–28 | Rough Gemstone, Iron Ore chunk |
| Warband Raider | `[Outlaw]` | 26–32 | Silver Mark, Crude weapon component |
| Rune Construct | `[Arcane]` | 28–34 | Rough Runic Cog, Ancient Sigil fragment |
| Ironspine Warlord `[Elite]` | `[Outlaw]` | 32–38 | Rough Gemstone, Steel Scraps |
| Awakened Stone Sentinel `[Elite]` | `[Arcane]` | 35–40 | Rough Ancient Sigil, Refined Gemstone |

#### Drop Table
| Item | Type | Drop Chance |
|------|------|------------|
| Silver Mark | Currency | 40% |
| Iron Scraps | Smelting input | 28% |
| Worn Steel | Smelting salvage | 22% |
| Ancient Sigil Fragment | Runelore input | 18% |
| Rough Gemstone | Rare Material T2 | 2.5% |
| Rough Runic Cog | Rare Material T2 | 2% |
| Rough Ancient Sigil | Rare Material T2 | 1.5% |

#### Zone Boss — *The Ironspine Colossus* `[Arcane][Boss]`
*A mountain golem the size of a watchtower, animated by a runic core that predates the kingdom by a thousand years. The warband has been trying to control it. They have not succeeded.*
- **Spawn:** Random during active play (1 in 20 chance per encounter)
- **Guaranteed Drop:** Rough Gemstone + Rough Runic Cog + Silver Mark pouch
- **Bonus Drop (10%):** Rough Plate Armor piece (pre-assembled)
- **Slaying XP:** 4x standard kill reward

---

## 🗺️ TIER 3 ZONES
**Combat Talent Requirement:** Any combat Talent 41–60
**Tone:** Hostile and ancient — these places have not been safe for a long time

---

### 💀 Zone 3A — Dreadhollow
*A forest that has been dead for a hundred years but refuses to lie down. The trees move when you're not watching. The undead here are organized — someone is giving them orders.*

**Primary Enemy Faction:** `[Undead]` with `[Void]` secondary
**Biome:** Dead forest, collapsed villages, shadow-touched clearings
**Dungeon Eligible:** Yes — Gravenspire
**Monthly Dungeon Pool:** Eligible for dungeon rotation slot

#### Enemies
| Enemy | Faction Tag | Combat Level | Notable Drop |
|-------|------------|-------------|-------------|
| Dreadhollow Revenant | `[Undead]` | 41–47 | Refined Phantom Pelt, Grave Dust |
| Void Shade | `[Void]` | 43–49 | Refined Void Spore, Shadow Essence |
| Bone Archer | `[Undead]` | 46–52 | Bone Arrow component, Grave Cloth |
| Corruption Beast | `[Void]` | 48–54 | Refined Void Spore, Void Ichor (Alchemy) |
| Wight Commander `[Elite]` | `[Undead]` | 52–58 | Refined Phantom Pelt, Old Coin pouch |
| Void Stalker `[Elite]` | `[Void]` | 54–60 | Refined Ancient Sigil, Void Crystal |

#### Drop Table
| Item | Type | Drop Chance |
|------|------|------------|
| Gold Mark | Currency | 35% |
| Grave Cloth | Tailoring input | 25% |
| Shadow Essence | Alchemy input | 22% |
| Void Ichor | Alchemy input | 18% |
| Refined Phantom Pelt | Rare Material T3 | 3% |
| Refined Void Spore | Rare Material T3 | 2.5% |
| Refined Ancient Sigil | Rare Material T3 | 2% |

#### Zone Boss — *The Hollow Archbishop* `[Undead][Void][Boss]`
*Once the head of a religious order. Now a towering skeletal figure in tattered ceremonial robes, channeling void energy through a corrupted holy symbol. The orders it gives are in a language no living person speaks.*
- **Spawn:** Random during active play (1 in 20 chance per encounter)
- **Guaranteed Drop:** Refined Phantom Pelt + Refined Void Spore + Gold Mark pouch
- **Bonus Drop (15%):** Refined weapon (pre-assembled, player class appropriate)
- **Slaying XP:** 5x standard kill reward

---

### 🌋 Zone 3B — Cinderpeak
*A volcanic highland where drake packs hunt and fire elementals patrol ancient lava flows. The air tastes of ash. The ground is warm underfoot. Something larger lives in the caldera.*

**Primary Enemy Faction:** `[Beast]` with `[Arcane]` secondary
**Biome:** Volcanic rock, lava channels, highland ridges, thermal vents
**Dungeon Eligible:** Yes — Ignarath's Maw
**Monthly Dungeon Pool:** Eligible for dungeon rotation slot

#### Enemies
| Enemy | Faction Tag | Combat Level | Notable Drop |
|-------|------------|-------------|-------------|
| Cinderpeak Drake | `[Beast]` | 41–47 | Drake Scale, Refined Amber |
| Fire Elemental | `[Arcane]` | 43–49 | Ember Core (Alchemy), Refined Gemstone |
| Highland Wyvern | `[Beast]` | 46–52 | Wyvern Hide, Wyvern Talon (Artificing) |
| Lava Construct | `[Arcane]` | 48–54 | Refined Runic Cog, Starstone Fragment |
| Drake Pack Alpha `[Elite]` | `[Beast]` | 52–58 | Refined Amber, Drake Fang (rare component) |
| Greater Fire Elemental `[Elite]` | `[Arcane]` | 54–60 | Refined Gemstone, Ember Shard (Enchanting) |

#### Drop Table
| Item | Type | Drop Chance |
|------|------|------------|
| Gold Mark | Currency | 35% |
| Drake Scale | Tanning/Arcane Weaving input | 28% |
| Ember Core | Alchemy input | 22% |
| Wyvern Hide | Tanning input | 18% |
| Refined Amber | Rare Material T3 | 3% |
| Refined Gemstone | Rare Material T3 | 2.5% |
| Refined Runic Cog | Rare Material T3 | 2% |

#### Zone Boss — *Ignarath the Ashborn* `[Beast][Boss]`
*The eldest drake in the Cinderpeak range. Ignarath has lived long enough to develop a crude intelligence. It hoards refined metal and has been known to wear scraps of armor it has taken from adventurers.*
- **Spawn:** Random during active play (1 in 20 chance per encounter)
- **Guaranteed Drop:** Refined Amber + Drake Scale (masterwork grade) + Gold Mark pouch
- **Bonus Drop (15%):** Refined Leather Armor piece (pre-assembled)
- **Slaying XP:** 5x standard kill reward

---

## 🗺️ TIER 4 ZONES
**Combat Talent Requirement:** Any combat Talent 61–80
**Tone:** Endgame adjacent — these places actively resist being explored

---

### 👁️ Zone 4A — Veilborn Wastes
*A landscape that exists partially in the void. The sky here is wrong — too many stars, in the wrong places. Void creatures pour through tears in reality. The ground shifts.*

**Primary Enemy Faction:** `[Void]` with `[Undead]` secondary
**Biome:** Corrupted plains, void tears, reality fractures, ruined outposts
**Dungeon Eligible:** Yes — The Breach
**Monthly Dungeon Pool:** Eligible for dungeon rotation slot

#### Enemies
| Enemy | Faction Tag | Combat Level | Notable Drop |
|-------|------------|-------------|-------------|
| Void Crawler | `[Void]` | 61–67 | Pristine Void Spore, Void Ichor |
| Veilborn Wraith | `[Undead]` | 63–69 | Pristine Phantom Pelt, Soul Residue |
| Reality Shade | `[Void]` | 66–72 | Void Crystal, Pristine Ancient Sigil |
| Corruption Titan | `[Void]` | 68–74 | Pristine Void Spore, Void Core (Soulbinding) |
| Veil Stalker `[Elite]` | `[Void]` | 72–78 | Pristine Void Spore, Void Shard (Enchanting) |
| Sundered Revenant `[Elite]` | `[Undead][Void]` | 74–80 | Pristine Phantom Pelt, Soul Essence (rare) |

#### Drop Table
| Item | Type | Drop Chance |
|------|------|------------|
| Gold Mark | Currency | 30% |
| Soul Residue | Soulbinding input | 25% |
| Void Crystal | Enchanting input | 22% |
| Void Core | Soulbinding input | 15% |
| Pristine Void Spore | Rare Material T4 | 3.5% |
| Pristine Phantom Pelt | Rare Material T4 | 3% |
| Pristine Ancient Sigil | Rare Material T4 | 2.5% |

#### Zone Boss — *The Veil Sovereign* `[Void][Boss]`
*Not a creature native to this world. The Veil Sovereign is a vast intelligence that slipped through a void tear three years ago and has been slowly consuming the landscape ever since. It wears the form of a knight in black armor that doesn't quite sit right on its body.*
- **Spawn:** Random during active play (1 in 20 chance per encounter)
- **Guaranteed Drop:** Pristine Void Spore + Pristine Phantom Pelt + Gold Mark pouch
- **Bonus Drop (20%):** Pristine weapon (pre-assembled, class appropriate)
- **Slaying XP:** 6x standard kill reward

---

### 🏯 Zone 4B — Shattered Citadel
*The ruins of a fortress that destroyed itself from within when its court sorcerers attempted something catastrophic. Arcane constructs still patrol the halls following orders from commanders who died a century ago. The magic here is thick and unstable.*

**Primary Enemy Faction:** `[Arcane]` with `[Outlaw]` secondary (looters and scavengers)
**Biome:** Ruined fortress, collapsed towers, unstable magical zones, overgrown courtyards
**Dungeon Eligible:** Yes — Valdren's Keep
**Monthly Dungeon Pool:** Eligible for dungeon rotation slot

#### Enemies
| Enemy | Faction Tag | Combat Level | Notable Drop |
|-------|------------|-------------|-------------|
| Citadel Automaton | `[Arcane]` | 61–67 | Pristine Runic Cog, Mithril Scrap |
| Relic Guardian | `[Arcane]` | 63–69 | Pristine Ancient Sigil, Starstone Fragment |
| Ruin Scavenger | `[Outlaw]` | 65–71 | Gold Mark, Salvaged Component |
| Spell-Bound Sentinel | `[Arcane]` | 68–74 | Pristine Gemstone, Arcane Residue |
| Citadel Archmage `[Elite]` | `[Arcane]` | 72–78 | Pristine Void Spore, Aetheric Fragment |
| Ruin Lord `[Elite]` | `[Outlaw][Arcane]` | 74–80 | Pristine Runic Cog, Lost Schematic |

#### Drop Table
| Item | Type | Drop Chance |
|------|------|------------|
| Gold Mark | Currency | 30% |
| Mithril Scrap | Smelting salvage | 25% |
| Arcane Residue | Arcane Weaving input | 22% |
| Salvaged Component | Artificing input | 18% |
| Pristine Gemstone | Rare Material T4 | 3.5% |
| Pristine Runic Cog | Rare Material T4 | 3% |
| Pristine Ancient Sigil | Rare Material T4 | 2.5% |
| Lost Schematic | Random mid-tier Schematic | 1% |

#### Zone Boss — *Arcanist Valdren the Unfinished* `[Arcane][Boss]`
*The court's head sorcerer, who survived the catastrophe by binding his soul into his own construct body. He has been wandering the ruins ever since, still trying to finish the experiment. He is very close to a breakthrough. This would be bad.*
- **Spawn:** Random during active play (1 in 20 chance per encounter)
- **Guaranteed Drop:** Pristine Gemstone + Pristine Runic Cog + Gold Mark pouch
- **Bonus Drop (20%):** Pristine Magical Vestments piece (pre-assembled)
- **Slaying XP:** 6x standard kill reward

---

## 🗺️ TIER 5 ZONES
**Combat Talent Requirement:** Any combat Talent 81–100
**Tone:** True endgame — these zones are not meant to be survived, they are meant to be conquered

---

### 🌑 Zone 5A — Ashenwold
*The site of a war between the void and everything else, fought a thousand years ago. Neither side won. The void creatures that remain are ancient and territorial. The ground is made of ash three feet deep. Nothing grows here. Nothing should.*

**Primary Enemy Faction:** `[Void]` with `[Undead]` secondary
**Biome:** Ash fields, void-scarred ruins, bone fields, collapsed reality zones
**Dungeon Eligible:** Yes — The Pale Vault (dungeon rotation eligible)
**Raid Eligible:** Yes — *Voidthrone* (quarterly raid)

#### Enemies
| Enemy | Faction Tag | Combat Level | Notable Drop |
|-------|------------|-------------|-------------|
| Ancient Void Crawler | `[Void]` | 81–87 | Masterwork Void Spore, Soulite Dust |
| Ashen Revenant | `[Undead]` | 83–89 | Masterwork Phantom Pelt, Soul Essence |
| Void Titan | `[Void]` | 86–92 | Masterwork Void Spore, Void Core (rare) |
| Corruption Ancient | `[Void]` | 88–94 | Masterwork Ancient Sigil, Void Shard |
| Ashen Warlord `[Elite]` | `[Undead][Void]` | 91–97 | Masterwork Phantom Pelt, Soulite Fragment |
| Void Archon `[Elite]` | `[Void]` | 94–100 | Masterwork Void Spore, Void Core (guaranteed) |

#### Drop Table
| Item | Type | Drop Chance |
|------|------|------------|
| Gold Mark | Currency | 28% |
| Soulite Dust | Soulbinding input | 25% |
| Soul Essence | Soulbinding input | 20% |
| Void Core | Soulbinding/Arcane input | 15% |
| Masterwork Void Spore | Rare Material T5 | 4% |
| Masterwork Phantom Pelt | Rare Material T5 | 3.5% |
| Masterwork Ancient Sigil | Rare Material T5 | 3% |

#### Zone Boss — *The Ashen Sovereign* `[Void][Legendary][Boss]`
*The last general of the void army from the ancient war. It has been waiting a thousand years for reinforcements that will never come. It has become something else entirely in the waiting.*
- **Spawn:** Random during active play (1 in 15 chance per encounter — slightly higher at endgame)
- **Guaranteed Drop:** Masterwork Void Spore + Masterwork Phantom Pelt + Large Gold Mark pouch
- **Bonus Drop (25%):** Legendary material component or pre-assembled Legendary weapon
- **Slaying XP:** 8x standard kill reward

---

### ⚔️ Zone 5B — Elder Reaches
*The oldest place in the known world. Ancient fortresses of unknown origin stand half-buried in rock. The creatures here predate recorded history. Scholars have theorized about what lies at the center. Nobody who went to check has come back to confirm.*

**Primary Enemy Faction:** `[Arcane]` with `[Beast]` secondary (primordial creatures)
**Biome:** Ancient ruins, primordial wilderness, arcane-scarred landscape, world-old stone
**Dungeon Eligible:** Yes — Firststone Sanctum (dungeon rotation eligible)
**Raid Eligible:** Yes — *Elderthrone* (quarterly raid)

#### Enemies
| Enemy | Faction Tag | Combat Level | Notable Drop |
|-------|------------|-------------|-------------|
| World Golem | `[Arcane]` | 81–87 | Masterwork Gemstone, Starstone Ore chunk |
| Primordial Drake | `[Beast]` | 83–89 | Masterwork Amber, Drake Scale (masterwork) |
| Elder Construct | `[Arcane]` | 86–92 | Masterwork Runic Cog, Grimoire Steel fragment |
| Ancient Wyvern | `[Beast]` | 88–94 | Masterwork Amber, Wyvern Heart (rare Alchemy) |
| Rune Colossus `[Elite]` | `[Arcane]` | 91–97 | Masterwork Gemstone, Worldtree Shard (rare) |
| Primordial Alpha `[Elite]` | `[Beast]` | 94–100 | Masterwork Amber, Ancient Fang (Legendary component) |

#### Drop Table
| Item | Type | Drop Chance |
|------|------|------------|
| Gold Mark | Currency | 28% |
| Starstone Ore Chunk | Smelting input | 25% |
| Drake Scale (masterwork) | Tanning/Arcane input | 20% |
| Wyvern Heart | Alchemy input | 15% |
| Masterwork Gemstone | Rare Material T5 | 4% |
| Masterwork Amber | Rare Material T5 | 3.5% |
| Masterwork Runic Cog | Rare Material T5 | 3% |
| Worldtree Shard | Legendary crafting material | 0.5% |

#### Zone Boss — *The World Warden* `[Arcane][Beast][Legendary][Boss]`
*A creature so old it predates naming. Equal parts construct and living thing. It guards the center of the Elder Reaches with complete indifference to why — it simply always has. Its movements cause minor earthquakes.*
- **Spawn:** Random during active play (1 in 15 chance per encounter)
- **Guaranteed Drop:** Masterwork Gemstone + Masterwork Amber + Large Gold Mark pouch
- **Bonus Drop (25%):** Legendary material component or Worldtree Shard
- **Slaying XP:** 8x standard kill reward

---

## 🏰 DUNGEON & RAID SUMMARY

### Monthly Dungeon Rotation Pool
Two dungeons active per month, drawn from this pool:

| Dungeon | Host Zone | Enemy Focus | Boss |
|---------|-----------|------------|------|
| Aldric's Warren | Zone 1A | `[Outlaw][Beast]` | Aldric's Lieutenant |
| Crestfall Cove | Zone 1B | `[Outlaw][Beast]` | Saltmother's Brood |
| Mirefall Barrow | Zone 2A | `[Undead][Nature]` | Barrow King |
| Warden's Folly | Zone 2B | `[Outlaw][Arcane]` | Iron Commander |
| Gravenspire | Zone 3A | `[Undead][Void]` | Gravenspire Council |
| Ignarath's Maw | Zone 3B | `[Beast][Arcane]` | Ignarath's Broodmother |
| The Breach | Zone 4A | `[Void][Undead]` | Veil Harbinger |
| Valdren's Keep | Zone 4B | `[Arcane][Outlaw]` | Valdren's Final Experiment |
| The Pale Vault | Zone 5A | `[Void][Undead]` | Pale Vault Council |
| Firststone Sanctum | Zone 5B | `[Arcane][Beast]` | Firststone Warden |

> Lower tier dungeons remain in rotation pool — useful for players still progressing
> Each month's 2 active dungeons announced at month start
> Dungeon boss always drops 1 tier higher rare material than the host zone standard
> Summoner's Tome: rare drop from dungeon bosses (Tier 3+) and raid bosses — unlocks Summoner deep subclass tree

### Quarterly Raid Schedule
One raid active per quarter:

| Raid | Host Zone | Scale | Boss | Masterwork Drop |
|------|-----------|-------|------|----------------|
| Voidthrone | Zone 5A | 10+ players | The Void Sovereign (raid form) | Masterwork Void Spore, Phantom Pelt |
| Elderthrone | Zone 5B | 10+ players | The World Warden (raid form) | Masterwork Gemstone, Amber |

> Additional raids added with multiplayer expansion (Phase 4)
> Mythic tier material drops added as DLC event content above Legendary

---

## 📊 Zone Progression Summary

| Tier | Zones | Combat Req | Primary Rare Materials | Dungeon | Raid |
|------|-------|-----------|----------------------|---------|------|
| 1 | Grimwood Fringe, Saltmarsh Shore | 1–20 | Crude T1 | Eligible | No |
| 2 | Ashfen Mire, Ironspine Reaches | 21–40 | Rough T2 | Eligible | No |
| 3 | Dreadhollow, Cinderpeak | 41–60 | Refined T3 | Eligible | No |
| 4 | Veilborn Wastes, Shattered Citadel | 61–80 | Pristine T4 | Eligible | No |
| 5 | Ashenwold, Elder Reaches | 81–100 | Masterwork T5 | Eligible | Yes |

---

*Document version 0.2 — Enemy Zone Tables*
*Next: Subclass deep tree specs · Stat scaling formulas · Daily/weekly quest structure · Onboarding flow*
