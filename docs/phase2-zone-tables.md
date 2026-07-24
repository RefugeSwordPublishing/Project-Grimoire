# Project Grimoire, Phase 2 Zone Tables
### Version 0.1

---

## Zone System Notes

- **Tier 2 zones** unlock when highest combat Talent reaches level 21+
- **1 dungeon per zone**, thematically matched, added to the global rotation pool
- **Rotation pool by end of Phase 2:** 4 dungeons total (2 Tier 1 + 2 Tier 2), 3 active per month
- **Slaying task gating:** Below Slaying 20, elite and boss tasks only. Slaying 20+, dungeon tasks added, filtered by accessible dungeons from active rotation
- **??? display:** Inaccessible rotation dungeons show as ??? with unlock hint, motivates progression
- **Post-launch playtesting item:** Rotation accessibility edge cases to be revisited based on real player data

---

## Zone 2A, Ashfen Mire

**Tier:** 2
**Unlock:** Highest combat Talent level 21+
**Biome:** Swamp / bog, dark waterlogged marshland, twisted trees, fog
**Faction tags:** `[Undead]` `[Nature]`
**Tone:** Ancient burial ground reclaimed by bog, the dead don't rest here, and the corrupted forest grows over their remains

**Gathering available:**
- Foraging: Bog Herbs, Mireroot, Ashfen Spore (rare)
- Dredging: Murk Eel, Bog Pearl, Swamp Carp
- Trapping: Mire Fox, Bog Hare, Ashfen Serpent hide
- Felling: Deadwood, Blightbark (rare)

**Zone resource bonus (Inscription Zone Map, Ashfen Mire):**
- Rough Map: +8% yield, +4% drop rate
- Refined Map: +12% yield, +6% drop rate
- Pristine Map: +15% yield, +8% drop rate
- Masterwork Map: +18% yield, +10% drop rate

---

### Enemy Roster, Ashfen Mire

**Standard Enemies (common spawns)**

| Enemy | Faction | HP | Damage Range | Weak Point | Drop Focus |
|-------|---------|----|-----------|-----------|-----------| 
| Bogwalker Skeleton | [Undead] | 95 | 10-18 | Skull, HEAD | Bone Fragments, Crude Gemstone |
| Ashfen Treant | [Nature] | 140 | 12-22 | Root Mass, CHEST | Blightbark, Rough Amber |
| Mire Wraith | [Undead] | 75 | 8-16 | Core, CHEST | Void Spore, Ectoplasm |
| Bog Lurker | [Nature] | 110 | 14-20 | Eye, HEAD | Bog Hide, Ashfen Spore |
| Rotting Soldier | [Undead] | 120 | 11-19 | Helm, HEAD | Crude weapons, Tarnished Marks |
| Spore Crawler | [Nature] | 65 | 6-12 | Sac, CHEST | Void Spore (higher rate), Crude Aetheric Filament |

**Spawn weights:**
- Bogwalker Skeleton: 25%, most common, introduces [Undead] faction
- Bog Lurker: 22%
- Rotting Soldier: 18%
- Ashfen Treant: 15%
- Mire Wraith: 12%, rarer, higher value drops
- Spore Crawler: 8%, least common, best rare material drop rate

---

**Elite Enemies (~5-8% base spawn, scales with Slaying level)**

| Elite | Faction | HP | Special | Drop |
|-------|---------|----|---------|----|
| Barrow Revenant | [Undead] | 380 | Necrotic aura, reduces player healing by 25% while active | Rough Gemstone, Spectral Essence |
| Thornwood Ancient | [Nature] | 450 | Root snare, immobilizes player for 3 seconds | Rough Amber, Ancient Bark |

**Elite visual distinction:** Both elites are significantly larger than standard enemies with a visible aura effect, Barrow Revenant has a green spectral glow, Thornwood Ancient has visible pulsing root veins across its bark.

---

**Zone Boss, The Ashfen Lich**

| Field | Value |
|-------|-------|
| Faction | [Undead] [Arcane] |
| HP | 2,400 |
| Spawn chance | ~1 in 20 encounters during active combat |
| Despawn timer | 10 minutes |
| Active play only | Yes, does not spawn during idle |
| Weak point | Phylactery, glowing orb at chest, 3-second window |

**Boss abilities:**
- **Necrotic Wave**, AoE damage + 15% healing reduction for 8s
- **Summon Bog Wraiths**, spawns 2 Mire Wraiths at 50% HP
- **Death's Grasp**, targets player, immobilizes for 2s then heavy damage
- **Lich's Phylactery**, if weak point not hit during vulnerability window, Lich regenerates 10% HP

**Drops:**
- Guaranteed: Rough Gemstone OR Rough Void Spore (random)
- Rare: Spectral Tome (Inscription unlock, Undead Faction Letter DLC stub)
- Very rare: Ashfen Lich's Crown (Pristine helm, [Undead] damage +8%)
- Slaying XP: 480 (moderate, Tier 2 boss)

---

### Dungeon 2A, Mirefall Barrow

**Theme:** Ancient burial barrow partially submerged in bog, three chambers of escalating undead threat
**Faction:** [Undead] heavy, [Nature] minor
**Recommended combat level:** 25+
**Estimated completion time:** 15-20 minutes

**Structure:**
```
Entrance → Chamber 1 (Rotting Soldiers + Bogwalkers)
         → Chamber 2 (Barrow Revenants + Mire Wraiths, elite density)
         → Tomb of the First Lich (Boss room)
```

**Boss, Aldrath the Sunken**

| Field | Value |
|-------|-------|
| HP | 4,800 |
| Faction | [Undead] [Arcane] |
| Weak point | Crown, HEAD, pulses every 20 seconds |

**Phase 1 (100-60% HP):** Standard attacks, periodic Necrotic Wave
**Phase 2 (60-30% HP):** Summons Barrow Revenant adds, Lich's Drain beam
**Phase 3 (30-0% HP):** Enrage, all abilities faster, Crown pulses every 10 seconds

**Guaranteed drops:**
- Rough rare material (random from zone pool)
- Slaying XP: 1,500

**Rare drops:**
- Barrow Knight Armor set piece (Rough-Refined quality)
- Summoner's Tome (very rare, see Phase 1 design doc)
- Aldrath's Signet (accessory, [Undead] damage +5%, Slaying XP +10%)

---

## Zone 2B, Ironspine Reaches

**Tier:** 2
**Unlock:** Highest combat Talent level 21+
**Biome:** Mountain pass, jagged peaks, abandoned military outposts, rocky terrain, sparse pine
**Faction tags:** `[Outlaw]` `[Beast]`
**Tone:** A mountain pass contested by a deserter warband and the predatory creatures that were there before them, neither welcome players

**Gathering available:**
- Delving: Iron Ore, Mithril Vein (rare), Mountain Quartz
- Felling: Pine, Ironbark (rare)
- Trapping: Mountain Goat, Snow Fox, Rock Hawk
- Foraging: Mountain Herb, Frostbloom, Ironwort (higher rate)

**Zone resource bonus (Inscription Zone Map, Ironspine Reaches):**
- Rough Map: +8% yield, +4% drop rate
- Refined Map: +12% yield, +6% drop rate
- Pristine Map: +15% yield, +8% drop rate
- Masterwork Map: +18% yield, +10% drop rate

---

### Enemy Roster, Ironspine Reaches

**Standard Enemies (common spawns)**

| Enemy | Faction | HP | Damage Range | Weak Point | Drop Focus |
|-------|---------|----|-----------|-----------|-----------| 
| Ironspine Deserter | [Outlaw] | 105 | 12-20 | Helm, HEAD | Iron Scraps, Silver Marks |
| Mountain Golem | [Beast] | 160 | 14-24 | Core Crystal, CHEST | Mountain Quartz, Crude Gemstone |
| Warband Raider | [Outlaw] | 115 | 13-22 | Chest, CHEST | Rough Leather, Crude weapons |
| Rune Construct | [Arcane] | 130 | 10-18 | Rune Core, CHEST | Runic Cog (higher rate), Arcane Dust |
| Ironspine Scout | [Outlaw] | 85 | 10-16 | Head, HEAD | Crude Gemstone, Marks |
| Mountain Hawk | [Beast] | 70 | 9-15 | Wing joint, CHEST | Feathers, Beast Hide |

**Spawn weights:**
- Ironspine Deserter: 24%
- Warband Raider: 22%
- Mountain Golem: 18%
- Ironspine Scout: 16%
- Rune Construct: 12%, rarer, best Runic Cog source in Tier 2
- Mountain Hawk: 8%

---

**Elite Enemies (~5-8% base spawn, scales with Slaying level)**

| Elite | Faction | HP | Special | Drop |
|-------|---------|----|---------|----|
| Ironspine Warlord | [Outlaw] | 420 | War cry, +20% damage to all nearby [Outlaw] enemies for 8s | Rough Gemstone, Warlord's Badge |
| Awakened Stone Sentinel | [Beast] [Arcane] | 500 | Stone skin, blocks next 3 hits entirely, then vulnerable | Rough Runic Cog, Mountain Core |

**Elite visual distinction:** Ironspine Warlord wears a distinctive red-plumed helm. Stone Sentinel glows with rune engravings that fade when stone skin is active and pulse when vulnerable.

---

**Zone Boss, The Ironspine Colossus**

| Field | Value |
|-------|-------|
| Faction | [Beast] [Arcane] |
| HP | 2,800 |
| Spawn chance | ~1 in 20 encounters during active combat |
| Despawn timer | 10 minutes |
| Active play only | Yes |
| Weak point | Rune Heart, CHEST, exposed only when Colossus rears back |

**Boss abilities:**
- **Seismic Slam**, AoE stagger, interrupts active combat inputs for 2s
- **Stone Skin**, absorbs next 5 hits, then weak point exposed for 4s
- **Golem Summon**, spawns 2 Mountain Golems at 50% HP
- **Ironspine Roar**, all [Outlaw] enemies in zone get +15% damage for 10s (unique cross-enemy interaction)

**Drops:**
- Guaranteed: Rough Gemstone OR Rough Runic Cog (random)
- Rare: Colossus Core (Artificing component, rare material, Rough tier)
- Very rare: Ironspine Colossus Pauldrons (Pristine plate shoulder, [Beast] damage +8%)
- Slaying XP: 480

---

### Dungeon 2B, Warden's Folly

**Theme:** Abandoned military fortress overrun by the Ironspine deserter warband, former order turned into chaos
**Faction:** [Outlaw] heavy, [Arcane] minor (Rune Constructs deployed as automated defense)
**Recommended combat level:** 25+
**Estimated completion time:** 15-20 minutes

**Structure:**
```
Gatehouse → Courtyard (Deserters + Raiders + automated Rune Constructs)
          → Barracks (elite Ironspine Warlords)
          → Commander's Hall (Boss room)
```

**Boss, Commander Valdris the Turncoat**

| Field | Value |
|-------|-------|
| HP | 5,200 |
| Faction | [Outlaw] |
| Weak point | Chest insignia, CHEST, always visible but small target |

**Phase 1 (100-60% HP):** Standard melee + Rune Construct summoning
**Phase 2 (60-30% HP):** War cry active permanently, all adds deal +20% damage
**Phase 3 (30-0% HP):** Berserker mode, rapid attacks, discards shield (new weak point: HEAD)

**Guaranteed drops:**
- Rough rare material (random from zone pool)
- Slaying XP: 1,500

**Rare drops:**
- Deserter's Arms set piece (Rough-Refined quality)
- Valdris's War Banner (guild cosmetic item, first dungeon drop with guild functionality)
- Turncoat's Blade (Rough Sword, [Outlaw] damage +6%)

---

## Tier 2 Drop Table Summary

### Rare Material Sources by Zone

| Rare Material | Primary Tier 2 Source | Drop Rate |
|--------------|----------------------|----------|
| Rough Gemstone | Mountain Golem, Rune Construct, both bosses | 8-12% |
| Rough Amber | Ashfen Treant, Felling in both zones | 6-10% |
| Rough Void Spore | Mire Wraith, Spore Crawler | 8-14% |
| Rough Phantom Pelt | Trapping in both zones (Mire Fox, Snow Fox) | Via Trapping only |
| Rough Abyssal Pearl | Dredging in Ashfen Mire | Via Dredging only |
| Rough Runic Cog | Rune Construct (Ironspine), Gleaning | 6-10% |
| Rough Aetheric Filament | Spore Crawler, Alchemy (combined source) | 4-8% |
| Rough Ancient Sigil | Tracking in both zones | Via Tracking only |

### Silver Mark Drop Ranges (Tier 2)
| Enemy Type | SM Drop Range |
|-----------|-------------|
| Standard enemy | 12-28 SM |
| Elite enemy | 80-160 SM |
| Zone boss | 400-800 SM |
| Dungeon boss | 800-1,600 SM |

---

## Dungeon Rotation Pool, End of Phase 2

| Dungeon | Zone | Tier | Added |
|---------|------|------|-------|
| Aldric's Warren | Grimwood Fringe | 1 | Phase 1 |
| Crestfall Cove | Saltmarsh Shore | 1 | Phase 1 |
| Mirefall Barrow | Ashfen Mire | 2 | Phase 2 |
| Warden's Folly | Ironspine Reaches | 2 | Phase 2 |

3 of 4 active per month. Each dungeon appears roughly 9 times per year in the rotation.

**Slaying task gating by pool:**
- Slaying 1-19: Elite hunting and zone boss tasks only (no dungeon tasks)
- Slaying 20+: Dungeon tasks added, filtered to accessible zones
- Locked rotation dungeons show as ??? with unlock hint

**Post-launch playtesting note:** Rotation accessibility edge cases (player has access to fewer dungeons than the 3-slot rotation) to be revisited based on real player data.

---

*Document version 0.1, Phase 2 Zone Tables*
*Next: Phase 3 zone design (Dreadhollow, Cinderpeak) · Attunement data for Phase 2 · Shadowblade/Black Ledger depth*
