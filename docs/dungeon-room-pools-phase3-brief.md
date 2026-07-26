---
type: implementation-brief
spec: enemy-zone-tables.md (v0.2)
updated: 2026-07-25
purpose: Author DungeonData ScriptableObjects for Gravenspire and Ignarath's Maw.
         Covers room pools, enemy compositions, hazard types, puzzle types,
         and procedural assembly rules. Read alongside dungeon-room-pools-brief.md
         (Phase 2) for the shared DungeonGenerator.cs architecture.
---

# Dungeon Room Pools — Phase 3 Implementation Brief

## Architecture

Same fixed structure as Phase 2. No changes to DungeonGenerator.cs required.
T3 dungeons use the same ScriptableObject types. Recommended level and first-clear
XP bonus scale to T3 (see end of doc).

```
Entrance Room (fixed)
    |
[3-5 randomised rooms from pool]
    |
Safe Room (fixed, second-to-last)
    |
Boss Room (fixed, last)
```

---

## Dungeon 3A, Gravenspire

**Host Zone:** Dreadhollow (Zone 3A)
**Theme:** A cathedral spire that sank halfway into the dead earth. The undead
clergy still hold services. The void corruption spreading through the lower levels
is changing them into something that was never alive to begin with.
**Faction:** `[Undead]` heavy, `[Void]` minor.
**Exclusive puzzle:** Pyre Puzzle — extinguishing void-corrupted flames in the
correct order to unseal a door.
**Exclusive hazard:** Void Seep — patches of ground where void energy leaks up,
dealing DoT and briefly reducing player evasion.
**Visual tileset:** Collapsed stone cathedral interior, black dead-wood pews,
void-corrupted stained glass, shadow-touched floors.

---

### Fixed Rooms

**Entrance Room, "The Fallen Nave"**
```
roomType:    Standard
enemies:     2x Dreadhollow Revenant, 1x Bone Archer
enemyCount:  3
hazards:     none
description: The main hall of the cathedral, half-collapsed. Rotted pews line
             the walls. Void-tainted light filters through ruined windows above.
             Bone Archer fires from a raised choir loft at the far end.
             Always the same — establishes the dungeon's tone clearly.
```

**Safe Room, "The Sacristy"**
```
roomType:    Safe
enemies:     none
hazards:     none
description: A side vestry sealed from the rest of the cathedral. Small, intact.
             HP regen active for 30 seconds on entry.
             A locked reliquary in the corner — always contains 1x Healing Draught
             (matching current tier) and a small Gold Mark bonus (10-25 GM).
             Atmospheric: intact candles, religious iconography now feels wrong.
```

**Boss Room, "The High Chancel"**
```
roomType:    Boss
enemies:     The Hollow Archbishop (see enemy-zone-tables.md for description)
hazards:     none (boss room always clean)
description: The cathedral's highest interior chamber. Void energy has corrupted
             every surface. The Archbishop stands at a ruined altar, back to the
             player, mid-sermon to an audience of empty air.
             Turns on player entry. Fight begins.

Boss EnemyData:
    hp:              9,200
    weakPointDesc:   "Corrupted Holy Symbol — CHEST, pulses every 15s during Phase 2+"
    weakPointTier:   Subtle (Phase 1), Obvious (Phase 2+)
    slayingXP:       2,800
    phases:
        Phase 1 (100-65%): Bone Lance ranged attacks, occasional Wight summon (1 per phase)
        Phase 2 (65-35%): Void Corruption aura activates — void seep patches
                          spread across the room floor, Holy Symbol begins pulsing,
                          summons 1x Void Shade
        Phase 3 (35-0%):  Enrage — Bone Lance rapid-fire, Holy Symbol pulses every 7s,
                          void seep patches cover 40% of floor
    drops:
        guaranteed:  Refined Phantom Pelt + Refined Void Spore + Gold Mark pouch
        rare (15%):  Wight Commander Armor piece (Refined-Pristine, pre-assembled)
        very rare (3%): Archbishop's Seal (accessory: [Undead] dmg +8%, void resistance +10%)
```

---

### Room Pool, Gravenspire

**Pool size:** 8 room types. Each run draws 3-5 from this pool.

---

**Room 1, "The Bone Choir" (Standard)**
```
weight:       30
guaranteed:   true
roomType:     Standard
enemies:      2x Bone Archer, 1x Dreadhollow Revenant
enemyCount:   3
hazards:      Void Seep (two patches on the floor near the choir risers)
loot:         Standard drops + small Gold Mark bonus (8-20 GM)
description:  The cathedral's choir loft area. Bone Archers occupy the upper
              risers and fire down. Dreadhollow Revenant advances from the centre.
              Most common room. Teaches players to handle ranged + melee split.
```

**Room 2, "The Transept" (Standard)**
```
weight:       22
guaranteed:   false
roomType:     Standard
enemies:      2x Dreadhollow Revenant, 1x Void Shade
enemyCount:   3
hazards:      Void Seep (single large patch, centre of the room)
loot:         Standard drops + higher Shadow Essence drop rate (+18%)
description:  A wide crossing chamber. The Void Shade materialises from the
              central void seep patch. Players are forced to engage around it.
              Atmospheric — the Shade emerging from the floor is unsettling.
```

**Room 3, "The Ossuary" (Standard/Hazard)**
```
weight:       18
guaranteed:   false
roomType:     Standard
enemies:      3x Bone Archer
enemyCount:   3
hazards:      Collapsing Masonry (25% chance per archer death — ceiling section
              falls, shadow circle warning 1.5s, moderate damage if hit)
loot:         Higher Bone Arrow component drop rate (+20%), Grave Cloth bonus
description:  A vault crammed with stacked bones and crumbling stonework.
              Three Bone Archers from elevated positions. The collapses punish
              players who stay stationary after kills.
```

**Room 4, "Wight's Chapel" (Elite)**
```
weight:       15
guaranteed:   false
roomType:     Elite
enemies:      1x Wight Commander, 1x Dreadhollow Revenant
enemyCount:   2
hazards:      none
loot:         Elite drop table + Refined Phantom Pelt (45% chance)
description:  A private chapel, now the Wight Commander's command post.
              War Cry ability active on engagement. Players who want Refined
              Phantom Pelt target this room. Hard fight, worth it.
```

**Room 5, "The Pyre Chamber" (Puzzle, EXCLUSIVE to Gravenspire)**
```
weight:       22
guaranteed:   false (70% chance per run)
roomType:     Puzzle
enemies:      none
hazards:      none
puzzleType:   PyrePuzzle
description:  A sealed antechamber with five void-corrupted braziers mounted on
              the walls, each burning with black-purple flame. Above the door:
              carved symbols indicating the required extinguishing sequence.
              Symbols are shown for 2.5 seconds, then fade.
              Player must tap the braziers in the correct order to unseal the door.
              Wrong order: all flames reignite, minor void DoT applied (5s),
              sequence resets. Can attempt as many times as needed.
              Success: door opens + bonus loot chest.
loot (success): 1x Refined rare material (random from Dreadhollow pool)
loot (failure): no bonus loot, can still proceed after door is eventually solved
classHint:    Arcanist path players recognise the void rune sequence faster
              (symbol display duration +1.5 seconds).
```

**Room 6, "The Reliquary Vault" (Treasure)**
```
weight:       10
guaranteed:   false
roomType:     Treasure
enemies:      none
hazards:      Cursed Reliquary (30% chance — opening the wrong case applies
              Weaken 15s and triggers 1x Dreadhollow Revenant spawn)
loot:         2x random Refined materials from Dreadhollow pool +
              Gold Marks (30-80 GM)
description:  A sealed vault of religious relics, most now void-tainted.
              Three cases — only one is safe. No indicator which.
              Pure risk/reward. High value if lucky.
```

**Room 7, "Void Corridor" (Trap)**
```
weight:       15
guaranteed:   false
roomType:     Trap
enemies:      none
hazards:      Void Seep Cascade (three void seep patches arranged across the
              corridor. Each activates in sequence, 2 seconds apart.
              Patches are visible before activation — dark shimmer on floor.
              DoT + evasion reduction while standing in any patch.)
loot:         none
description:  A long narrow corridor with void energy leaking through the floor
              in waves. Patches light up in sequence. Players learn to time
              movement between the waves. Punishes rushing.
```

**Room 8, "The Vestry Antechamber" (Standard, pre-boss atmosphere)**
```
weight:       18
guaranteed:   false
roomType:     Standard
enemies:      1x Wight Commander, 1x Void Shade
enemyCount:   2
hazards:      Void Seep (one patch near the far door)
loot:         Standard elite drops + lore parchment (Archbishop's final sermon —
              readable, reveals the void corruption history)
description:  Directly adjacent to the boss chamber. Elevated enemies signal
              the boss is near. Lore item rewards thorough players.
              Assembly rule: places adjacent to Safe Room when both present.
```

---

### Gravenspire Assembly Rules

```csharp
DungeonData gravenspire = {
    dungeonName:       "Gravenspire",
    zoneId:            "dreadhollow",
    recommendedLevel:  45,
    minRooms:          3,
    maxRooms:          5,
    entranceRoom:      "The Fallen Nave",
    safeRoom:          "The Sacristy",
    bossRoom:          "The High Chancel",
    exclusivePuzzle:   "PyrePuzzle",
    roomPool:          [rooms 1-8 with weights above]
}

// Assembly rules:
// 1. Entrance Room always first
// 2. Room 1 (The Bone Choir) guaranteed at least once
// 3. Draw remaining rooms by weight
// 4. Room 5 (Pyre Chamber): 70% chance to include
// 5. Safe Room second-to-last
// 6. Boss Room last
// 7. Shuffle middle rooms (Room 8 adjacent to Safe Room if present)
```

---

## Dungeon 3B, Ignarath's Maw

**Host Zone:** Cinderpeak (Zone 3B)
**Theme:** A collapsed caldera tunnel system where Ignarath's drake pack nests.
Arcane lava constructs built by a long-dead civilisation still patrol the lower
tunnels, partially melted and very confused about who to attack.
**Faction:** `[Beast]` heavy, `[Arcane]` minor.
**Exclusive puzzle:** Pressure Valve Puzzle — managing lava flow through a
network of valves to cool a sealed door without flooding the room.
**Exclusive hazard:** Lava Vent — timed jets of flame erupting from floor
grates, telegraphed by a heat shimmer and a hiss before firing.
**Visual tileset:** Volcanic rock tunnels, hardened lava flows, drake nest
chambers, ancient arcane machinery half-buried in cooled magma.

---

### Fixed Rooms

**Entrance Room, "The Caldera Mouth"**
```
roomType:    Standard
enemies:     2x Cinderpeak Drake, 1x Lava Construct
enemyCount:  3
hazards:     Lava Vent (one vent near the far wall, 4s cycle)
description: The tunnel entrance — wide, low-ceilinged, heat haze visible.
             Drakes patrol the floor; Lava Construct guards the far passage.
             Vent teaches the hazard mechanic immediately.
             Always the same — introduces both enemy factions from room one.
```

**Safe Room, "The Cooling Pool"**
```
roomType:    Safe
enemies:     none
hazards:     none
description: A naturally occurring thermal pool where cool water filters in
             through volcanic rock. One of the few tolerable spots in the dungeon.
             HP regen active for 30 seconds on entry.
             A submerged cache nearby — always contains 1x Healing Draught
             (matching current tier) and Ember Core (Alchemy input, 1x guaranteed).
             Atmospheric: the relief of cool air after the tunnels.
```

**Boss Room, "The Broodchamber"**
```
roomType:    Boss
enemies:     Ignarath the Ashborn (see enemy-zone-tables.md for description)
hazards:     none (boss room always clean, Ignarath controls the hazards himself)
description: The deepest chamber — a massive cathedral-scale cavern of hardened
             lava and drake nests. Drake eggs line the walls. Ignarath is at the
             far end, wearing scraps of adventurer armor, apparently sleeping.
             Does not sleep through player entry.

Boss EnemyData:
    hp:              10,400
    weakPointDesc:   "Throat scales — NECK, exposed during Fire Breath channel"
    weakPointTier:   Subtle (normal stance), Obvious (during Fire Breath only)
    slayingXP:       3,000
    phases:
        Phase 1 (100-70%): Claw swipe melee, occasional Fire Breath channel
                           (3s channel — throat exposed, massive damage if hit
                           during channel, but Ignarath is also vulnerable)
        Phase 2 (70-40%): Calls 1x Drake Pack Alpha to assist.
                          Fire Breath frequency increases.
                          Lava Surge: slams ground, lava wave across floor (dodge roll required)
        Phase 3 (40-0%):  Enrage — Lava Surge every 8s, Fire Breath no longer
                          telegraphed with channel animation (fires immediately),
                          throat weak point remains exposed 1.5s post-breath only
    drops:
        guaranteed:  Refined Amber + Drake Scale (masterwork grade) + Gold Mark pouch
        rare (15%):  Wyvern Hide Armor piece (Refined-Pristine, Leather, pre-assembled)
        very rare (3%): Ignarath's Fang (accessory: [Beast] dmg +8%, fire resistance +12%)
```

---

### Room Pool, Ignarath's Maw

**Pool size:** 8 room types.

---

**Room 1, "The Drake Runs" (Standard)**
```
weight:       30
guaranteed:   true
roomType:     Standard
enemies:      2x Cinderpeak Drake, 1x Highland Wyvern
enemyCount:   3
hazards:      Lava Vent (two vents, 5s cycle, offset timing)
loot:         Standard drops + Drake Scale bonus (+15% drop rate)
description:  Wide tunnel sections where drakes patrol in packs.
              The Highland Wyvern is slower but hits harder. Vents force
              players to stay mobile. Most common room.
```

**Room 2, "The Construct Station" (Standard)**
```
weight:       22
guaranteed:   false
roomType:     Standard
enemies:      2x Lava Construct, 1x Cinderpeak Drake
enemyCount:   3
hazards:      Arcane Discharge (Lava Construct death — 35% chance,
              lava splash AoE, moderate damage in small radius)
loot:         Higher Runic Cog drop rate (+25%), Starstone Fragment bonus
description:  An ancient maintenance station, still partially operational.
              Two Lava Constructs on patrol routes. Drake nesting nearby.
              The Arcane Discharge is wider than the Phase 2 version — T3 scaling.
```

**Room 3, "The Nest Hollow" (Standard/Hazard)**
```
weight:       18
guaranteed:   false
roomType:     Standard
enemies:      3x Cinderpeak Drake
enemyCount:   3
hazards:      Hatching Egg (25% chance per drake killed — a nearby egg cracks,
              spawning 1x Drake Hatchling that attacks once then flees;
              hatchlings deal minor damage, more of a nuisance than a threat)
loot:         Higher Drake Fang drop rate (+20%), Wyvern Hide chance
description:  A nesting hollow. Eggs cover the walls. Three Drakes defend the nest.
              Hatching Eggs are reactive to combat noise — killing a drake triggers
              nearby eggs. Players who clear quickly face fewer hatchlings.
```

**Room 4, "Alpha's Den" (Elite)**
```
weight:       15
guaranteed:   false
roomType:     Elite
enemies:      1x Drake Pack Alpha, 1x Cinderpeak Drake
enemyCount:   2
hazards:      none
loot:         Elite drop table + Refined Amber (50% chance)
description:  A larger chamber claimed by the Alpha. Pack Drake is a genuine
              threat alongside the Alpha. Players who want Refined Amber
              target this room. Best loot source in the dungeon outside the boss.
```

**Room 5, "The Pressure Valve Chamber" (Puzzle, EXCLUSIVE to Ignarath's Maw)**
```
weight:       22
guaranteed:   false (68% chance per run)
roomType:     Puzzle
enemies:      none
hazards:      none
puzzleType:   PressureValvePuzzle
description:  A chamber with an ancient arcane valve system controlling lava flow.
              A sealed door is held shut by lava pressure. A visible pipe diagram
              on the wall shows three valves and the flow direction.
              Player must turn the valves in the correct order to divert flow,
              cool the door seal, and open it — without causing a lava overflow.
              Wrong sequence: lava overflows a channel briefly, minor burn damage,
              system resets. Can retry as many times as needed.
              Success: door opens + bonus loot chest.
loot (success): 1x Refined rare material (random from Cinderpeak pool)
loot (failure): no bonus loot, can still proceed after puzzle is eventually solved
classHint:    Runesmithing 42+ players recognise the flow mechanics faster
              (correct valve highlighted briefly on room entry).
```

**Room 6, "The Lava Cache" (Treasure)**
```
weight:       10
guaranteed:   false
roomType:     Treasure
enemies:      none
hazards:      Unstable Lava Shelf (35% chance — if player moves to the far end
              too quickly, shelf collapses, minor lava splash damage, 1.5s warning
              via audible cracking sound before collapse)
loot:         2x random Refined materials from Cinderpeak pool +
              Gold Marks (35-90 GM) + Ember Core (guaranteed 1x)
description:  A hardened lava tube with a natural alcove where valuables have
              been collecting for years — dropped by previous victims.
              High value, moderate hazard. Lava shelf is avoidable if player
              listens for the crack before advancing.
```

**Room 7, "The Vent Gauntlet" (Trap)**
```
weight:       15
guaranteed:   false
roomType:     Trap
enemies:      none
hazards:      Lava Vents (four vents arranged across a long corridor, 3s cycle,
              all slightly offset. Heat shimmer 1s before each vent fires.
              Moderate damage if caught — not fatal, but significant.)
loot:         none
description:  A purpose-built ancient gauntlet corridor — originally a test for
              the civilisation that built these tunnels. The vents still work
              perfectly. Players must time movement through the gaps.
              Teaches vent timing before the boss room's Phase 3.
```

**Room 8, "The Old Throne" (Standard, pre-boss atmosphere)**
```
weight:       18
guaranteed:   false
roomType:     Standard
enemies:      1x Greater Fire Elemental, 1x Lava Construct
enemyCount:   2
hazards:      Lava Vent (one vent, 4s cycle, near the far door)
loot:         Standard elite drops + carved tablet (lore item — readable,
              describes the ancient civilisation that built the tunnels
              and their attempt to harness Ignarath)
description:  A large chamber with a crumbling throne of cooled lava.
              The Greater Fire Elemental is the hardest non-boss enemy in
              the dungeon. Lore item rewards thorough players.
              Assembly rule: places adjacent to Safe Room when both present.
```

---

### Ignarath's Maw Assembly Rules

```csharp
DungeonData ignarathsMaw = {
    dungeonName:       "Ignarath's Maw",
    zoneId:            "cinderpeak",
    recommendedLevel:  45,
    minRooms:          3,
    maxRooms:          5,
    entranceRoom:      "The Caldera Mouth",
    safeRoom:          "The Cooling Pool",
    bossRoom:          "The Broodchamber",
    exclusivePuzzle:   "PressureValvePuzzle",
    roomPool:          [rooms 1-8 with weights above]
}

// Assembly rules:
// 1. Entrance Room always first
// 2. Room 1 (The Drake Runs) guaranteed at least once
// 3. Draw remaining rooms by weight
// 4. Room 5 (Pressure Valve): 68% chance to include
// 5. Safe Room second-to-last
// 6. Boss Room last
// 7. Shuffle middle rooms (Room 8 adjacent to Safe Room if present)
```

---

## New Hazards (Phase 3)

Add these to the shared hazard table in dungeon-room-pools-brief.md:

| Hazard | Trigger | Effect | Visual warning |
|--------|---------|--------|---------------|
| Void Seep | On room entry / timed spread (Phase 2) | DoT + evasion -10% while standing in patch | Dark shimmer on floor, purple edge glow |
| Void Seep Cascade | Sequence activation | DoT + evasion reduction, patches activate in order | Patches glow dim before full activation |
| Collapsing Masonry | Enemy death (25%) | Moderate damage in AoE | Shadow circle 1.5s before impact |
| Cursed Reliquary | Player opens wrong case | Weaken 15s + 1x Revenant spawn | Crackling dark energy on tainted cases |
| Lava Vent | Timed (3-5s cycle) | Moderate fire damage | Heat shimmer + audible hiss 1s before |
| Unstable Lava Shelf | Player enters far zone too fast | Minor splash damage | Audible cracking sound 1.5s before |
| Hatching Egg | Beast enemy death (25%) | 1x Hatchling spawns, attacks once then flees | Egg visibly cracks on enemy kill |
| Arcane Discharge (T3) | Lava Construct death (35%) | Lava splash AoE moderate damage | Orange energy burst, wider radius than T2 |

All hazards are avoidable with observation. None are instant-kill.

---

## First Clear Bonus (T3)

```csharp
// On dungeon boss defeat:
if (IsFirstClear(playerId, dungeonId)) {
    CombatXPManager.AwardXP(equippedGrimoire, 2000); // T3 first clear bonus
    PlayerPrefs.SetInt($"dungeon_cleared_{dungeonId}", 1);
}
```

---

## New Puzzle Types

### PyrePuzzle (Gravenspire exclusive)

Five void-corrupted braziers on walls, numbered in a random order each run.
Correct extinguishing sequence shown for 2.5s at room entry (symbols above the door).
Player taps braziers in the shown order.
Wrong tap: all reignite, void DoT 5s, reset.
No run limit on attempts.

```csharp
public class PyrePuzzle : IDungeonPuzzle {
    int[]  correctSequence;   // length 3-5, randomised per run
    float  displayDuration = 2.5f;
    int    currentStep = 0;
    float  failDoT = 8f;      // damage per second for 5s on fail

    void OnBrazierTapped(int index) {
        if (index == correctSequence[currentStep]) {
            currentStep++;
            if (currentStep == correctSequence.Length) OnSuccess();
        } else {
            OnFail();
        }
    }
}
```

### PressureValvePuzzle (Ignarath's Maw exclusive)

Three valves on a pipe diagram. Each valve controls a flow direction.
Correct turn order shown on the wall diagram — static, always visible (no memory test).
The challenge is understanding the pipe diagram and executing the correct sequence
without triggering an overflow.
Wrong sequence: minor lava damage (12 flat), system resets.

```csharp
public class PressureValvePuzzle : IDungeonPuzzle {
    int[]  correctOrder;      // [0,1,2] or [2,0,1] etc., randomised per run
    bool[] valveState;        // open/closed state of each valve
    int    currentStep = 0;
    float  failDamage = 12f;

    void OnValveTurned(int valveIndex) {
        if (valveIndex == correctOrder[currentStep]) {
            currentStep++;
            valveState[valveIndex] = !valveState[valveIndex];
            if (currentStep == correctOrder.Length) OnSuccess();
        } else {
            OnFail();
        }
    }
}
```

---

*Path: `docs/dungeon-room-pools-phase3-brief.md`*
*Covers: Gravenspire (Zone 3A Dreadhollow) and Ignarath's Maw (Zone 3B Cinderpeak).*
*New hazards: Void Seep, Void Seep Cascade, Lava Vent, Collapsing Masonry, Hatching Egg.*
*New puzzles: PyrePuzzle, PressureValvePuzzle.*
