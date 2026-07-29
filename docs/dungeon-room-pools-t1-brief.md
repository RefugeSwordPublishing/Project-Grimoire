---
type: implementation-brief
spec: enemy-zone-tables.md (v0.2), dungeon-room-pools-brief.md (T2 reference)
updated: 2026-07-27
purpose: Author DungeonData ScriptableObjects for Aldric's Warren and Crestfall Cove.
         Covers room pools, enemy compositions, hazard types, and procedural assembly
         rules. Read alongside dungeon-room-pools-brief.md for the shared
         DungeonGenerator.cs architecture. T1 dungeons use the same ScriptableObject
         types and assembly logic — no changes to DungeonGenerator.cs required.
---

# Dungeon Room Pools, T1 Implementation Brief

## Architecture

Same fixed structure as T2 and T3. No changes to DungeonGenerator.cs required.

```
Entrance Room (fixed)
    |
[2-3 randomised rooms from pool]
    |
Safe Room (fixed, second-to-last)
    |
Boss Room (fixed, last)
```

T1 dungeons differ from T2/T3 in three ways only:

- minRooms 2, maxRooms 3 (shorter runs — T2/T3 use 3-5)
- 2 enemies per standard room instead of 3
- No puzzle rooms. No puzzle ScriptableObject required for T1.

The boss has two phases instead of three. First-clear XP bonus is 500
(half the T2 value of 1,000).

**Puzzle do-not-build flag (implementation-status.md):** That flag covers
the puzzle minigame system (GlyphPuzzle, WeightPuzzle, PyrePuzzle,
PressureValvePuzzle). T1 dungeons have no puzzles and are unaffected.
Before building T2 dungeons (Mirefall Barrow, Warden's Folly), confirm
the puzzle flag is lifted. If not lifted, stub T2 puzzle rooms as Treasure
rooms until cleared.

---

## Dungeon 1A, Aldric's Warren

**Host zone:** Grimwood Fringe (Zone 1A)
**Theme:** An old bandit leader's underground hideout dug into the roots of
the ancient Grimwood. Cramped earthen tunnels, stolen goods, rotting wooden
supports.
**Faction:** [Outlaw] only. T1 uses a single faction — no secondary.
**No puzzle.** No hazards in middle rooms.
**Visual tileset:** Earthen tunnels, rough-hewn wooden supports, crate-stacked
walls, torchlight. Uses Grimwood Fringe enemy assets already in game.
**Recommended level:** 8

---

### Fixed Rooms

**Entrance Room, "The Smugglers' Entrance"**
```
roomType:    Standard
enemies:     2x Grimwood Bandit
enemyCount:  2
hazards:     none
description: The tunnel entrance, two bandits standing watch just inside.
             Torchlit earthen walls, stolen crates stacked against the sides.
             Introduces the dungeon tone. Always the same composition.
```

**Safe Room, "The Stash"**
```
roomType:    Safe
enemies:     none
hazards:     none
description: A hidden alcove used as a supply cache.
             HP regen active for 30 seconds on entry.
             Always contains 1x Crude Healing Draught.
             A locked strongbox sits in the corner — cannot be opened here.
             Aldric's Key (rare boss drop) opens it for a cosmetic lore note.
             Atmospheric detail that rewards players who find Aldric's Key.
```

**Boss Room, "Aldric's Den"**
```
roomType:    Boss
enemies:     Aldric the Wolf
hazards:     none
description: An earthen chamber at the deepest point of the warren.
             A crude throne of stolen goods at the far end.
             Aldric paces before it. Fight begins on player entry.

Boss EnemyData:
    enemyName:       "Aldric the Wolf"
    factionTags:     ["Outlaw"]
    isBoss:          true
    hp:              1800   (solo) / 2880 (2p) / 3960 (3p)
    damageMin:       6
    damageMax:       12
    attackCadence:   2.2s
    weakPointDesc:   "Old scar — LEFT SHOULDER, always visible, Subtle tier"
    weakPointTier:   Subtle
    weakPointMultiplier: 2.0
    slayingXP:       600
    phases:
        Phase 1 (100-50%): Standard melee, Cheap Shot every 12s
                           (stuns player 0.8s, telegraphed by a wind-up animation)
        Phase 2 (50-0%):   Calls 1x Grimwood Bandit to assist.
                           Aldric damage +15%, attack cadence tightens to 1.8s.
    drops:
        guaranteed:  Rough Gemstone (Crude quality) + Silver Marks (15-40 SM)
        rare (20%):  Aldric's Key (opens the Stash strongbox — cosmetic;
                     strongbox contains a handwritten note, Aldric's backstory)
        rare (8%):   Worn Bandit Cowl (Crude Leather Helm, [Outlaw] dmg +3%)
```

---

### Room Pool, Aldric's Warren

**Pool size:** 5 room types. Each run draws 2-3.
No puzzle room. No trap room. T1 keeps room types simple.

---

**Room 1, "The Common Room" (Standard)**
```
weight:          30
guaranteed:      true
roomType:        Standard
enemies:         2x Grimwood Bandit
enemyCount:      2
hazards:         none
loot:            Standard drops + Silver Marks (5-15 SM)
description:     A shared sleeping and eating area — rough bedrolls, fire pit,
                 stolen provisions. The most common room.
                 Establishes baseline: two Bandits, no surprises.
```

**Room 2, "The Guard Post" (Standard)**
```
weight:          25
guaranteed:      false
roomType:        Standard
enemies:         1x Grimwood Scout, 1x Grimwood Bandit
enemyCount:      2
hazards:         none
loot:            Standard drops
description:     A narrow side tunnel with a lookout post. The Scout is ranged
                 and holds distance. Teaches players to prioritise target types.
                 First encounter where a ranged enemy complicates the fight.
```

**Room 3, "Stolen Goods" (Treasure)**
```
weight:          15
guaranteed:      false
roomType:        Treasure
enemies:         none
hazards:         none
loot:            Silver Marks (10-30 SM) + 1x Crude raw material
                 (random from Grimwood pool: Common Herb, Rabbit Pelt, Pine Log)
description:     A side alcove stacked with stolen goods. No combat.
                 First Treasure room most players encounter in the game.
                 Teaches the room type: safe, worth exploring.
```

**Room 4, "The Lookout Tunnel" (Standard)**
```
weight:          20
guaranteed:      false
roomType:        Standard
enemies:         2x Grimwood Scout
enemyCount:      2
hazards:         none
loot:            Standard drops + slightly higher Fox Fur drop rate (+10%)
description:     A longer tunnel with two Scouts holding opposite ends.
                 Ranged-only room — harder than standard for early players.
                 Weight slightly lower so it doesn't appear every run.
```

**Room 5, "Aldric's Antechamber" (Standard, pre-boss)**
```
weight:          20
guaranteed:      false
roomType:        Standard
enemies:         1x Grimwood Bandit, 1x Grimwood Scout
enemyCount:      2
hazards:         none
loot:            Standard drops
description:     A wider chamber just before the boss, slightly better appointed
                 than the rest of the Warren — crude tapestries, a rough map
                 of the tunnel system pinned to the wall.
                 Signals the boss is close.
                 Assembly rule: places adjacent to Safe Room when both present.
```

---

### Aldric's Warren Assembly Rules

```csharp
DungeonData aldricsWarren = {
    dungeonName:       "Aldric's Warren",
    zoneId:            "grimwood_fringe",
    recommendedLevel:  8,
    minRooms:          2,
    maxRooms:          3,
    entranceRoom:      "The Smugglers' Entrance",
    safeRoom:          "The Stash",
    bossRoom:          "Aldric's Den",
    exclusivePuzzle:   null,   // T1 has no puzzle
    roomPool:          [rooms 1-5 with weights above]
}

// Assembly rules:
// 1. Entrance Room always first
// 2. Room 1 (The Common Room) guaranteed at least once
// 3. Draw remaining 1-2 rooms by weight from rooms 2-5
// 4. No puzzle roll (T1 has no puzzle room)
// 5. Safe Room second-to-last
// 6. Boss Room last
// 7. Room 5 (Aldric's Antechamber) adjacent to Safe Room if present
```

---

## Dungeon 1B, Crestfall Cove

**Host zone:** Saltmarsh Shore (Zone 1B)
**Theme:** A sea cave used as a smuggling operation by a piratical crew.
Tidal tunnels, barnacled stone, smuggled cargo, a flooded lower section.
**Faction:** [Outlaw] only.
**No puzzle.** One optional hazard in one room (Tidal Surge — movement
penalty only, no damage). No other hazards in the dungeon.
**Visual tileset:** Sea cave rock, barnacled walls, tidal pools, wooden
crates and barrels, rope rigging, lantern light. Uses Saltmarsh Shore
enemy assets already in game.
**Recommended level:** 12

---

### Fixed Rooms

**Entrance Room, "The Cave Mouth"**
```
roomType:    Standard
enemies:     2x Saltmarsh Corsair
enemyCount:  2
hazards:     none
description: The cave entrance, two Corsairs blocking the way in.
             Sea light filtering through a crack in the ceiling above.
             Smell of brine and wet rope. Always the same composition.
```

**Safe Room, "The Smuggler's Cache"**
```
roomType:    Safe
enemies:     none
hazards:     none
description: A dry alcove above the tide line, hidden from the main tunnel.
             HP regen active for 30 seconds on entry.
             Always contains 1x Crude Healing Draught + 1x random Saltmarsh
             raw material (Pond Fish, Eel Skin, or Crab Shell — always useful
             at this tier, reinforces Dredging as a zone talent).
```

**Boss Room, "The Captain's Grotto"**
```
roomType:    Boss
enemies:     Captain Mirra Vane
hazards:     none
description: The deepest chamber, a natural grotto with a smuggler's throne
             of stacked crates and a Corsair flag hanging from the ceiling.
             Mirra is examining a map when the player enters.
             Turns immediately. Fight begins.

Boss EnemyData:
    enemyName:       "Captain Mirra Vane"
    factionTags:     ["Outlaw"]
    isBoss:          true
    hp:              2100   (solo) / 3360 (2p) / 4620 (3p)
    damageMin:       8
    damageMax:       14
    attackCadence:   1.6s   (fastest T1 boss — dual cutlass, quick)
    weakPointDesc:   "Belt buckle — TORSO CENTER, always visible, Subtle tier"
    weakPointTier:   Subtle
    weakPointMultiplier: 2.0
    slayingXP:       700
    phases:
        Phase 1 (100-50%): Dual cutlass melee at 1.6s cadence, occasional
                           Parry (blocks next player attack, 0 damage, 8s cooldown)
        Phase 2 (50-0%):   Calls 1x Saltmarsh Corsair to assist.
                           Throws a flare every 15s — briefly blinds player 1.5s
                           (screen dims, attack interval gap, telegraphed by wind-up)
    drops:
        guaranteed:  Rough Amber (Crude quality) + Silver Marks (20-50 SM)
        rare (20%):  Mirra's Compass (cosmetic trinket — displays the current
                     zone name in the inventory description field; flavour item)
        rare (8%):   Corsair's Coat (Crude Leather Chest, [Outlaw] dmg +3%)
```

---

### Room Pool, Crestfall Cove

**Pool size:** 5 room types. Each run draws 2-3.
No puzzle room. One room has a mild optional hazard.

---

**Room 1, "The Loading Dock" (Standard)**
```
weight:          30
guaranteed:      true
roomType:        Standard
enemies:         2x Saltmarsh Corsair
enemyCount:      2
hazards:         none
loot:            Standard drops + Silver Marks (8-20 SM)
description:     A wide cave section used as a cargo staging area — crates,
                 barrels, rope-tied bundles. Two Corsairs on guard.
                 Most common room. Baseline encounter for the dungeon.
```

**Room 2, "The Lookout Tunnel" (Standard)**
```
weight:          25
guaranteed:      false
roomType:        Standard
enemies:         1x Saltmarsh Corsair, 1x Corsair Archer
enemyCount:      2
hazards:         none
loot:            Standard drops
description:     A narrower passage with a Corsair Archer holding the far end.
                 First ranged enemy in Crestfall Cove. Teaches target priority.
```

**Room 3, "The Tidal Chamber" (Standard)**
```
weight:          20
guaranteed:      false
roomType:        Standard
enemies:         2x Saltmarsh Corsair
enemyCount:      2
hazards:         Tidal Surge (40% chance this room has the hazard active):
                     water rises slowly across the chamber floor over 8s,
                     movement speed -15% while ankle-deep, drains after 8s.
                     No damage — movement penalty only.
                     Visual: water level visibly rising from floor cracks.
                     This is the only hazard in either T1 dungeon.
loot:            Standard drops
description:     A lower cave section where the sea water pushes in at high tide.
                 Corsairs are used to it; new players are not.
                 40% chance the hazard is active this run. When active, the
                 movement penalty makes the fight slightly harder.
                 Teaches hazard awareness without punishing early players.
                 No damage — purely a learning moment.
```

**Room 4, "Stolen Cargo" (Treasure)**
```
weight:          15
guaranteed:      false
roomType:        Treasure
enemies:         none
hazards:         none
loot:            Silver Marks (15-40 SM) + 1x Crude raw material
                 (random from Saltmarsh pool: Eel Skin, Crab Shell, Pond Weed)
description:     Smuggled goods stacked against the cave wall — barrels of
                 salted fish, crates of raw materials lifted from fishing boats.
                 No combat. Saltmarsh-flavoured loot.
                 Same teaching moment as Warren's Stolen Goods: explore, get rewarded.
```

**Room 5, "First Mate's Quarters" (Standard, pre-boss)**
```
weight:          20
guaranteed:      false
roomType:        Standard
enemies:         1x Saltmarsh Corsair, 1x Corsair Archer
enemyCount:      2
hazards:         none
loot:            Standard drops + ship's logbook (lore item — readable,
                 Mirra's smuggling route notes, flavour only)
description:     A carved-out alcove claimed by Mirra's first mate (long gone).
                 Hammock, personal effects, a logbook on a crate-desk.
                 Slightly grander than the rest of the cave. Boss is near.
                 Lore item rewards thorough players.
                 Assembly rule: places adjacent to Safe Room when present.
```

---

### Crestfall Cove Assembly Rules

```csharp
DungeonData crestfallCove = {
    dungeonName:       "Crestfall Cove",
    zoneId:            "saltmarsh_shore",
    recommendedLevel:  12,
    minRooms:          2,
    maxRooms:          3,
    entranceRoom:      "The Cave Mouth",
    safeRoom:          "The Smuggler's Cache",
    bossRoom:          "The Captain's Grotto",
    exclusivePuzzle:   null,   // T1 has no puzzle
    roomPool:          [rooms 1-5 with weights above]
}

// Assembly rules:
// 1. Entrance Room always first
// 2. Room 1 (The Loading Dock) guaranteed at least once
// 3. Draw remaining 1-2 rooms by weight from rooms 2-5
// 4. No puzzle roll (T1 has no puzzle room)
// 5. Safe Room second-to-last
// 6. Boss Room last
// 7. Room 5 (First Mate's Quarters) adjacent to Safe Room if present
```

---

## Shared Implementation Notes (T1 specific)

### New Hazard: Tidal Surge

Add to the shared hazard table in dungeon-room-pools-brief.md:

| Hazard | Trigger | Effect | Visual warning |
|--------|---------|--------|---------------|
| Tidal Surge | Room entry (40% chance in Tidal Chamber) | Movement -15% for 8s, no damage | Water visibly rising from floor cracks, 2s before full effect |

Tidal Surge is the mildest hazard in the game by design. Movement penalty only, no DoT.
Duration 8s then drains. Does not re-trigger mid-combat.

```csharp
// HazardType enum addition:
TidalSurge,  // movement penalty only, no damage, 8s duration

// In HazardManager:
case HazardType.TidalSurge:
    PlayerController.MovementSpeedMultiplier *= 0.85f;
    yield return new WaitForSeconds(8f);
    PlayerController.MovementSpeedMultiplier /= 0.85f;
    break;
```

### New Enemy: Aldric the Wolf

Author as a new EnemyData ScriptableObject. Uses existing Grimwood Fringe
enemy sprite style (Outlaw faction). Weak point mask: left shoulder area,
top-left quadrant of sprite, roughly 15% of sprite area. Subtle tier.

Cheap Shot ability: wind-up animation 0.5s, then stun 0.8s. Stun does not
prevent the player from using active abilities. Cadence 12s.

### New Enemy: Captain Mirra Vane

Author as a new EnemyData ScriptableObject. Uses existing Saltmarsh Shore
enemy sprite style (Outlaw faction). Weak point mask: torso center, small
buckle-shaped oval, roughly 10% of sprite area. Subtle tier.

Parry ability: on cooldown (8s), the next player melee hit deals 0 damage.
Visual indicator: Mirra raises both blades for 0.5s before the parry window opens.
Window is 1.5s. Does not apply to ranged or magic attacks.

Flare ability (Phase 2): dims screen to 20% brightness for 1.5s.
Attack button still functional during blind. Wind-up 0.6s (Mirra reaches to belt).

### First Clear Bonus (T1)

```csharp
if (IsFirstClear(playerId, dungeonId)) {
    CombatXPManager.AwardXP(equippedGrimoire, 500); // T1 first clear bonus
    PlayerPrefs.SetInt($"dungeon_cleared_{dungeonId}", 1);
}
```

### Wiring to Existing Placeholder Tiles

The dungeon tiles for Aldric's Warren and Crestfall Cove already exist in the
Grimwood Fringe and Saltmarsh Shore zone UIs as named placeholders. They
currently do nothing on tap. Wire them to launch the DungeonManager with
the corresponding DungeonData ScriptableObject on tap, same as the T2/T3
dungeon tile wiring.

---

## T1 vs T2 vs T3 Comparison

| Property | T1 (Warren / Cove) | T2 (Mirefall / Folly) | T3 (Gravenspire / Maw) |
|----------|--------------------|-----------------------|------------------------|
| Middle rooms | 2-3 | 3-5 | 3-5 |
| Enemies per room | 2 | 3 | 3 |
| Hazard types | 0-1 (mild, optional) | Multiple | Multiple |
| Puzzle | None | Exclusive puzzle, 65-70% | Exclusive puzzle, 68-70% |
| Boss phases | 2 | 3 | 3 |
| Boss HP (solo) | 1,800-2,100 | 4,800-5,200 | 9,200-10,400 |
| First-clear XP | 500 | 1,000 | 2,000 |
| Recommended level | 8 / 12 | 25 | 45 |

---

*Path: docs/dungeon-room-pools-t1-brief.md*
*Covers: Aldric's Warren (Zone 1A Grimwood Fringe) and Crestfall Cove (Zone 1B Saltmarsh Shore).*
*New hazard: Tidal Surge (movement penalty only, no damage, Crestfall Cove only).*
*No puzzles. No new DungeonGenerator.cs changes required.*
