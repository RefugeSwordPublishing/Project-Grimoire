---
type: implementation-brief
spec: phase2-zone-tables.md (v0.1), combat-engagement-spec.md (v0.2)
updated: 2026-07-11
purpose: Author DungeonData ScriptableObjects for Mirefall Barrow and Warden's Folly.
         Covers room pools, enemy compositions per room, hazard types, puzzle types,
         and procedural assembly rules. Read alongside combat-engagement-spec.md.
---

# Dungeon Room Pools — Implementation Brief

## Architecture (from combat-engagement-spec.md)

Every dungeon run is procedurally assembled from a themed pool.

**Fixed structure every run:**
```
Entrance Room (always first, fixed composition)
    ↓
[3–5 randomised rooms drawn from themed pool]
    ↓
Safe Room (always before boss, fixed)
    ↓
Boss Room (always last, fixed)
```

**ScriptableObjects needed:**
```csharp
public class DungeonData : ScriptableObject {
    public string dungeonName;
    public string zoneId;           // "ashfen_mire" / "ironspine_reaches"
    public int recommendedLevel;
    public DungeonRoomData entranceRoom;
    public DungeonRoomData safeRoom;
    public DungeonRoomData bossRoom;
    public DungeonRoomPool[] roomPool; // randomised middle rooms
    public int minRooms;               // 3
    public int maxRooms;               // 5
    public string exclusivePuzzleType; // "GlyphPuzzle" / "WeightPuzzle"
}

public class DungeonRoomPool : ScriptableObject {
    public DungeonRoomData room;
    public float weight;        // relative spawn weight
    public bool guaranteedOnce; // appears at least once if weight > 0
}

public class DungeonRoomData : ScriptableObject {
    public string roomName;
    public DungeonRoomType roomType; // Standard/Elite/Trap/Puzzle/Treasure/Safe/Boss
    public EnemyData[] enemies;      // fixed composition for this room
    public int enemyCount;
    public HazardType[] possibleHazards;
    public string puzzleType;        // if puzzle room
    public LootTable roomLootTable;  // bonus loot on clear
}
```

---

## Dungeon 2A — Mirefall Barrow

**Theme:** Ancient burial barrow partially submerged in bog.
**Faction:** [Undead] heavy, [Nature] minor.
**Exclusive puzzle:** Glyph Puzzle — ancient undead rune sequences.
**Exclusive hazard:** Bog Seepage — rising water sections.
**Scrolling direction:** Top-to-bottom as per combat-engagement-spec.md.
**Visual tileset:** Stone burial chambers, submerged floors, bioluminescent fungi lighting.

---

### Fixed Rooms

**Entrance Room — "The Barrow Mouth"**
```
roomType:    Standard
enemies:     2× Rotting Soldier, 1× Bogwalker Skeleton
enemyCount:  3
hazards:     none
description: First chamber — introduces the dungeon tone.
             Torchlit stone entry, crumbling walls, bog water seeping through cracks.
             Always the same — gives new players a predictable opening.
```

**Safe Room — "The Offering Chamber"**
```
roomType:    Safe
enemies:     none
hazards:     none
description: A sealed chamber with a dry stone altar.
             HP regen active for 30 seconds on entry.
             A supply crate in the corner — always contains 1× Healing Draught
             (lowest quality in player's inventory pool, i.e. matching current tier).
             Atmospheric: candles still burning, offerings on altar.
```

**Boss Room — "Tomb of the First Lich"**
```
roomType:    Boss
enemies:     Aldrath the Sunken (see phase2-enemy-content-brief.md for full data)
hazards:     none (boss room always clean)
description: Grand circular burial chamber, submerged floor, central raised dais.
             Aldrath emerges from the bog water on player entry.
             Phylactery (weak point) glows from chest — pulses every 20s.
Boss EnemyData:
    hp:              4,800
    weakPointDesc:   "Crown — HEAD, pulses every 20 seconds"
    weakPointTier:   Obvious (during pulse window only)
    slayingXP:       1,500
    phases:
        Phase 1 (100–60%): Standard attacks + periodic Necrotic Wave
        Phase 2 (60–30%): Summons 2× Barrow Revenant, Lich's Drain beam
        Phase 3 (30–0%):  Enrage — all abilities faster, Crown pulses every 10s
    drops:
        guaranteed: Rough rare material (random from Ashfen pool)
        rare:       Barrow Knight Armor piece (Rough–Refined)
        very rare:  Aldrath's Signet (accessory — [Undead] dmg +5%, Slaying XP +10%)
```

---

### Room Pool — Mirefall Barrow

**Pool size:** 8 room types. Each run draws 3–5 rooms from this pool.
Weights are relative — higher weight = more likely to appear.

---

**Room 1 — "Rotting Barracks" (Standard)**
```
weight:       30
guaranteed:   true (always appears at least once)
roomType:     Standard
enemies:      3× Rotting Soldier
enemyCount:   3
hazards:      Pressure Plate (25% chance — triggers Bog Seepage if stepped on)
loot:         Standard enemy drops + small Silver Mark bonus (5–15 SM)
description:  Former sleeping quarters, now collapsed bunks and rusted armor.
              Most common room — establishes baseline difficulty.
```

**Room 2 — "The Drowned Gallery" (Standard)**
```
weight:       25
guaranteed:   false
roomType:     Standard
enemies:      2× Bogwalker Skeleton, 1× Mire Wraith
enemyCount:   3
hazards:      Bog Seepage (floor partially flooded — slows player movement 20%)
loot:         Standard drops
description:  Long corridor with knee-deep bog water. Mire Wraith emerges from
              the water as player approaches. Atmospheric — unsettling.
```

**Room 3 — "Spore Garden" (Standard/Hazard)**
```
weight:       20
guaranteed:   false
roomType:     Standard
enemies:      2× Spore Crawler, 1× Bogwalker Skeleton
enemyCount:   3
hazards:      Poison Gas (bioluminescent spores release on Spore Crawler death —
              player takes DoT damage for 5s if standing in area)
loot:         Higher Void Spore drop rate (+15%)
description:  Chamber overrun with glowing fungal growth. Spore Crawlers nest here.
              Their death releases spores — players should move after killing them.
```

**Room 4 — "The Revenant's Vault" (Elite)**
```
weight:       15
guaranteed:   false
roomType:     Elite
enemies:      1× Barrow Revenant, 1× Rotting Soldier
enemyCount:   2
hazards:      none
loot:         Elite drop table + bonus Rough Gemstone (40% chance)
description:  Sealed vault chamber — Barrow Revenant guards the contents.
              Harder fight, better loot. Players who want Rough Gemstones
              prioritise this room.
```

**Room 5 — "Glyph Chamber" (Puzzle — EXCLUSIVE to Mirefall Barrow)**
```
weight:       25
guaranteed:   false  (70% chance per run — high but not guaranteed)
roomType:     Puzzle
enemies:      none (puzzle must be solved to proceed)
hazards:      none
puzzleType:   GlyphPuzzle
description:  Stone door sealed with a sequence of glowing runes.
              Player must tap the runes in the correct sequence shown briefly
              at the start (3–5 runes, shown for 2 seconds then hidden).
              Failure: minor damage penalty, sequence resets.
              Success: door opens + bonus loot chest.
loot (success): 1× Rough rare material (random from Ashfen pool)
loot (failure): no bonus — can still proceed
classHint:    Arcanist players recognise the rune sequence faster (highlight
              duration +1 second for Arcanist path players).
```

**Room 6 — "The Ancestor's Rest" (Treasure)**
```
weight:       10
guaranteed:   false
roomType:     Treasure
enemies:      none
hazards:      Cursed Sarcophagus (25% chance — touching it applies Weaken 10s)
loot:         2× random Rough materials from Ashfen pool + Silver Marks (20–50 SM)
description:  Small side chamber with sealed stone sarcophagi. Optional detour.
              No combat — pure loot. Risk: cursed sarcophagus.
```

**Room 7 — "Bog Trap Corridor" (Trap)**
```
weight:       15
guaranteed:   false
roomType:     Trap
enemies:      none
hazards:      Pressure Plates (3 plates — stepping on any triggers Bog Seepage
              in a section of corridor, slowing player and dealing minor damage).
              Plates are visible — player can navigate around them.
loot:         none (trap rooms have no loot — risk without reward teaches avoidance)
description:  Narrow corridor with flagstone pressure plates. The trap room that
              teaches players to watch their footing.
```

**Room 8 — "The Lich's Antechamber" (Standard — pre-boss atmosphere)**
```
weight:       20
guaranteed:   false
roomType:     Standard
enemies:      1× Mire Wraith, 2× Bogwalker Skeleton
enemyCount:   3
hazards:      none
loot:         Standard drops
description:  Grander architecture — player knows the boss is close.
              Spectral lights, elaborate stonework, the air feels wrong.
              Always places directly before the Safe Room if it appears.
```

---

### Mirefall Barrow — Assembly Rules

```csharp
DungeonData mirefall = {
    dungeonName:       "Mirefall Barrow",
    zoneId:            "ashfen_mire",
    recommendedLevel:  25,
    minRooms:          3,
    maxRooms:          5,
    entranceRoom:      "The Barrow Mouth",
    safeRoom:          "The Offering Chamber",
    bossRoom:          "Tomb of the First Lich",
    exclusivePuzzle:   "GlyphPuzzle",
    roomPool:          [rooms 1–8 with weights above]
}

// Assembly on run start:
// 1. Always place Entrance Room first
// 2. Guarantee Room 1 (Rotting Barracks) appears at least once
// 3. Randomly draw (minRooms–1) to (maxRooms–1) more rooms by weight
//    (minus 1 because Room 1 is guaranteed)
// 4. Room 5 (Glyph Chamber): roll separately — 70% chance to include
// 5. Always place Safe Room second-to-last
// 6. Always place Boss Room last
// 7. Shuffle middle rooms (keep Room 8 adjacent to Safe Room if present)
```

---

## Dungeon 2B — Warden's Folly

**Theme:** Abandoned military fortress overrun by Ironspine deserter warband.
**Faction:** [Outlaw] heavy, [Arcane] minor (automated Rune Construct defense).
**Exclusive puzzle:** Weight/Scale Puzzle — counterbalance mechanisms.
**Exclusive hazard:** Tripwire — deserter traps throughout the fortress.
**Visual tileset:** Military stone fortress — barracks, armory, ramparts, great hall.
**Scrolling direction:** Top-to-bottom.

---

### Fixed Rooms

**Entrance Room — "The Gatehouse"**
```
roomType:    Standard
enemies:     2× Ironspine Deserter, 1× Ironspine Scout
enemyCount:  3
hazards:     none
description: The fortress gatehouse — rusted portcullis half-raised, deserters
             standing watch. Introduces the [Outlaw] faction tone.
             Always the same opening composition.
```

**Safe Room — "The Abandoned Shrine"**
```
roomType:    Safe
enemies:     none
hazards:     none
description: A small shrine room the deserters avoided out of superstition.
             Untouched compared to the rest of the fortress. HP regen 30s.
             Supply chest: 1× Healing Draught or 1× Endurance Draught
             (class-appropriate — Vanguard gets Endurance, others get Healing).
```

**Boss Room — "Commander's Hall"**
```
roomType:    Boss
enemies:     Commander Valdris the Turncoat
hazards:     none
description: The fortress great hall. Valdris's personal banner on the wall
             (Valdris's War Banner is a guaranteed rare drop from this room).
             Throne at the far end — Valdris stands before it.
Boss EnemyData:
    hp:              5,200
    weakPointDesc:   "Chest insignia — CHEST (always visible, small target)"
    weakPointTier:   Subtle (Phase 1+2) → Obvious (Phase 3, head exposed)
    slayingXP:       1,500
    phases:
        Phase 1 (100–60%): Standard melee + Rune Construct summons
        Phase 2 (60–30%): War Cry permanent — all adds +20% damage
        Phase 3 (30–0%):  Berserker mode — discards shield, HEAD becomes weak point
    drops:
        guaranteed: Rough rare material (random from Ironspine pool)
        rare:       Deserter's Arms set piece (Rough–Refined)
        rare:       Valdris's War Banner (guild cosmetic — display in Guild Hall)
        very rare:  Turncoat's Blade (Rough Sword — [Outlaw] dmg +6%)
```

*Implementation note: Valdris has a SHIFTING weak point — Chest in Phase 1+2,
HEAD in Phase 3 (berserker, no shield). `UpdateWeakPointMask()` must swap the
active mask reference when Phase 3 triggers. Two mask textures on `EnemyData`:
`weakPointMaskPhase1` and `weakPointMaskPhase3`.*

---

### Room Pool — Warden's Folly

**Pool size:** 8 room types.

---

**Room 1 — "The Courtyard" (Standard)**
```
weight:       30
guaranteed:   true
roomType:     Standard
enemies:      2× Ironspine Deserter, 1× Warband Raider
enemyCount:   3
hazards:      Tripwire (20% chance — triggers if player rushes forward,
              deals minor damage and briefly stuns 1s)
loot:         Standard drops + Silver Marks (8–20 SM)
description:  Open courtyard, broken barricades, scattered military equipment.
              The heart of the deserter camp. Most common room.
```

**Room 2 — "The Armory" (Standard)**
```
weight:       22
guaranteed:   false
roomType:     Standard
enemies:      1× Warband Raider, 2× Ironspine Scout
enemyCount:   3
hazards:      Falling Debris (25% chance — unstable ceiling, shadow indicator warning)
loot:         Higher weapon/armor drop rate (+20%), Iron Scraps bonus
description:  The fortress armory — weapon racks (mostly empty), crates, forges.
              Rune Constructs were deployed here for automated defense but most
              have been deactivated.
```

**Room 3 — "Rune Construct Station" (Standard/Arcane)**
```
weight:       18
guaranteed:   false
roomType:     Standard
enemies:      2× Rune Construct, 1× Ironspine Deserter
enemyCount:   3
hazards:      Arcane Discharge (Rune Construct death releases energy burst —
              30% chance, minor AoE damage to player if adjacent)
loot:         Higher Runic Cog drop rate (+25%), Arcane Dust bonus
description:  Automated construct deployment bay. Deserters reactivated some
              of the constructs for their own use — imperfectly. The Arcane
              Discharge hazard represents unstable reactivation.
```

**Room 4 — "The Warlord's Barracks" (Elite)**
```
weight:       15
guaranteed:   false
roomType:     Elite
enemies:      1× Ironspine Warlord, 1× Ironspine Deserter
enemyCount:   2
hazards:      none
loot:         Elite drop table + bonus Warlord's Badge (50% chance)
description:  The senior officers' quarters. Ironspine Warlord holds rank here.
              War Cry ability is active immediately on engagement — challenging.
```

**Room 5 — "The Counterweight Room" (Puzzle — EXCLUSIVE to Warden's Folly)**
```
weight:       22
guaranteed:   false  (65% chance per run)
roomType:     Puzzle
enemies:      none
puzzleType:   WeightPuzzle
description:  A portcullis gate locked by a counterweight mechanism.
              Two scales — player must place the correct combination of items
              from their inventory to balance them and open the gate.
              Required items are drawn from common Ironspine drops (Iron Scraps,
              Rough Leather, Mountain Quartz) — player must have these in inventory.
              If player lacks items: gate stays closed, must find another path.
              (Alternative path always exists — puzzle is optional, not mandatory.)
loot (success): 1× Rough rare material + bonus Silver Marks (30–80 SM)
classHint:    Runesmithing 27+ players recognise the weight ratios faster
              (correct combination highlighted).
```

**Room 6 — "The Powder Store" (Treasure/Hazard)**
```
weight:       10
guaranteed:   false
roomType:     Treasure
enemies:      none
hazards:      Powder Keg (stepping on the keg triggers explosion — telegraphed
              by a sparking fuse visible on the ground, 2s warning)
loot:         Bonus Iron Ore, Mithril Vein fragment (rare), Silver Marks (25–60 SM)
description:  The fortress powder and supply store. High value — high risk.
              Powder Keg is avoidable if player watches for the fuse spark.
```

**Room 7 — "Tripwire Corridor" (Trap)**
```
weight:       15
guaranteed:   false
roomType:     Trap
enemies:      none
hazards:      Tripwires (3 wires visible across corridor — crossing triggers
              a Ironspine Scout ambush: 1 Scout spawns from the wall, attacks once,
              then flees. Minor damage if hit.)
loot:         none
description:  A narrow corridor strung with deserter tripwires. The Scout
              ambush is distinctive — small, fast, punishing if ignored.
              Teaches players to watch for the wire shimmer.
```

**Room 8 — "The Captain's Study" (Standard — pre-boss atmosphere)**
```
weight:       18
guaranteed:   false
roomType:     Standard
enemies:      1× Ironspine Warlord, 1× Rune Construct
enemyCount:   2
hazards:      none
loot:         Standard elite drops + personal journal (lore item — readable,
              explains Valdris's betrayal backstory)
description:  Valdris's former second-in-command's quarters. Elevated enemies
              signal the boss is near. Lore item rewards thorough players.
              Always places adjacent to Safe Room if present.
```

---

### Warden's Folly — Assembly Rules

```csharp
DungeonData wardensFolly = {
    dungeonName:       "Warden's Folly",
    zoneId:            "ironspine_reaches",
    recommendedLevel:  25,
    minRooms:          3,
    maxRooms:          5,
    entranceRoom:      "The Gatehouse",
    safeRoom:          "The Abandoned Shrine",
    bossRoom:          "Commander's Hall",
    exclusivePuzzle:   "WeightPuzzle",
    roomPool:          [rooms 1–8 with weights above]
}

// Assembly rules same as Mirefall Barrow:
// 1. Entrance Room always first
// 2. Room 1 (The Courtyard) guaranteed at least once
// 3. Draw remaining rooms by weight
// 4. Room 5 (Counterweight): 65% chance to include
// 5. Safe Room second-to-last
// 6. Boss Room last
// 7. Shuffle middle rooms (Room 8 adjacent to Safe Room if present)
```

---

## Shared Implementation Notes

### DungeonGenerator.cs

```csharp
List<DungeonRoomData> AssembleRun(DungeonData dungeon) {
    var rooms = new List<DungeonRoomData>();

    // Fixed start
    rooms.Add(dungeon.entranceRoom);

    // Guaranteed room
    var guaranteed = dungeon.roomPool
        .Where(r => r.guaranteedOnce).Select(r => r.room);
    rooms.AddRange(guaranteed);

    // Randomised fill
    int remaining = Random.Range(dungeon.minRooms, dungeon.maxRooms + 1)
                  - guaranteed.Count();
    var pool = dungeon.roomPool.Where(r => !r.guaranteedOnce).ToList();

    for (int i = 0; i < remaining; i++) {
        rooms.Add(WeightedRandom(pool, r => r.weight).room);
    }

    // Exclusive puzzle roll
    var puzzleRoom = dungeon.roomPool
        .FirstOrDefault(r => r.room.roomType == DungeonRoomType.Puzzle);
    if (puzzleRoom != null && Random.value < 0.68f) // ~70% average
        rooms.Add(puzzleRoom.room);

    // Shuffle middle (keep boss-adjacent room last if present)
    ShuffleMiddleRooms(rooms);

    // Fixed end
    rooms.Add(dungeon.safeRoom);
    rooms.Add(dungeon.bossRoom);

    return rooms;
}
```

### Hazard Implementation

| Hazard | Trigger | Effect | Visual warning |
|--------|---------|--------|---------------|
| Bog Seepage | Pressure plate / timed | Movement −20%, minor DoT | Water rising from floor cracks |
| Poison Gas | Spore Crawler death | DoT 5s in area | Green mist cloud |
| Tripwire | Player crosses wire | Minor damage + 1s stun | Thin wire shimmer visible |
| Falling Debris | Timed (random) | Moderate damage | Shadow circle on floor |
| Cursed Sarcophagus | Player interaction | Weaken 10s | Crackling dark energy |
| Arcane Discharge | Rune Construct death | AoE minor damage | Blue energy burst |
| Powder Keg | Player steps near | AoE heavy damage | Sparking fuse (2s) |

All hazards are **avoidable** with observation. None are instant-kill. Failure = damage penalty, not run end.

### First Clear Bonus

```csharp
// On dungeon boss defeat:
if (IsFirstClear(playerId, dungeonId)) {
    CombatXPManager.AwardXP(equippedGrimoire,
        dungeon.tier == 2 ? 1000 : 500); // Tier 2 = 1,000 first clear bonus
    PlayerPrefs.SetInt($"dungeon_cleared_{dungeonId}", 1);
}
```

---

*Path: `docs/dungeon-room-pools-brief.md`*
