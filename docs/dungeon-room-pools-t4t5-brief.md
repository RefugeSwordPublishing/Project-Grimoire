---
type: implementation-brief
spec: enemy-zone-tables.md (v0.2), dungeon-room-pools-phase3-brief.md (T3 reference)
updated: 2026-07-31
path: docs/dungeon-room-pools-t4t5-brief.md
purpose: Author DungeonData ScriptableObjects for The Breach (4A), Valdren's Keep (4B),
         The Pale Vault (5A), and Firststone Sanctum (5B). Mirrors the format of
         dungeon-room-pools-phase3-brief.md exactly. No DungeonGenerator.cs changes needed.
---

# Dungeon Room Pools, T4/T5 Implementation Brief

## Architecture

Same fixed structure as T1-T3. No changes to DungeonGenerator.cs.

```
Entrance Room (fixed)
    |
[3-5 randomised rooms from pool]
    |
Safe Room (fixed, second-to-last)
    |
Boss Room (fixed, last)
```

T4 bosses: 3 phases (same as T3 zone bosses).
T5 bosses: 4 phases (new at T5, appropriate endgame escalation).
First-clear XP: 3,500 for T4 dungeons, 5,000 for T5 dungeons.

## Open Questions Answered

1. One dungeon per zone (four total). Two T4, two T5. Doubles monthly rotation depth.
2. Puzzles: T4 reuses Glyph (Breach) and Weight/counterweight (Valdren's Keep).
   T5 introduces two new puzzles: Void Rift Seal (Pale Vault) and Rune Lock (Firststone).
3. New hazards: one new per dungeon, plus existing hazards reused where thematic.
4. T4 bosses 3 phases; T5 bosses 4 phases.

---

## Dungeon 4A, The Breach

**Host zone:** Veilborn Wastes (Zone 4A)
**Theme:** A fractured military outpost that sits directly on top of a void tear.
The void has been leaking through for three years. Whatever was posted here to
guard the tear is still here, in a manner of speaking.
**Faction:** `[Void]` heavy, `[Undead]` minor.
**Exclusive puzzle:** Glyph Rune Sequence (reuse existing, rune pads lit in sequence,
player repeats the order). Thematic fit: the void tears in the walls flash arcane
rune patterns as they open and close.
**Exclusive hazard:** Reality Fracture, a section of the room floor phases into
the void for 2 seconds, any entity standing in it takes 10 void DoT per second.
No telegraph visual (the fracture appears without warning, reading enemy patterns
is the player's warning). Resets after 5s.
**Visual tileset:** Ruined stone military outpost interior, walls partially phased
into void, cracked floors with void light bleeding through, void tears as
window-sized rifts in the walls.
**Recommended level:** 65.

---

### Fixed Rooms

**Entrance Room, "The Outer Gate"**
```
roomType:    Standard
enemies:     2x Void Crawler, 1x Veilborn Wraith
enemyCount:  3
hazards:     none
description: The outpost's main entrance, half-collapsed. Void Crawlers patrol
             the floor; the Veilborn Wraith drifts near the far wall. A faded
             military crest on the wall, whoever was stationed here took their
             duty seriously. Establishes both faction types immediately.
```

**Safe Room, "The Sealed Chamber"**
```
roomType:    Safe
enemies:     none
hazards:     none
description: A room the soldiers managed to seal with runic barriers before
             the end. The void hasn't touched it. HP regen 30s on entry.
             Always contains 1x Healing Draught (tier-appropriate) +
             1x Soul Residue (zone drop, useful for Soulbinding pipeline).
```

**Boss Room, "The Tear"**
```
roomType:    Boss
enemies:     The Veil Harbinger
hazards:     none
description: The room at the outpost's center where the void tear is largest.
             The void tear dominates the far wall, a slowly pulsing rift ten
             feet tall. The Veil Harbinger emerges from it on player entry.

Boss EnemyData:
    enemyName:       "The Veil Harbinger"
    factionTags:     ["Void", "Undead"]
    isBoss:          true
    isDungeonBoss:   true
    dungeonId:       "the_breach"
    hp:              18,500   (solo) / 29,600 (2p) / 40,700 (3p)
    damageMin:       45
    damageMax:       70
    attackCadence:   2.0s
    weakPointDesc:   "Void Core, CHEST (pulsing orb, Obvious always)"
    weakPointTier:   Obvious
    weakPointMultiplier: 2.0
    slayingXP:       4,800
    phases:
        Phase 1 (100-70%): Void Lance ranged attack, Reality Fracture hazard activates
                           in 2 floor zones each 12s
        Phase 2 (70-40%):  Summons 1x Reality Shade to assist. Void Lance rate doubles.
                           Void Core pulses every 10s (additional obvious crit window).
        Phase 3 (40-0%):   Enrage. Reality Fracture expands to 3 zones per pulse.
                           Veil Step: Harbinger teleports to a random room position
                           every 15s (void flash telegraph 1s before teleport).
    drops:
        guaranteed:  Pristine Void Spore + Pristine Phantom Pelt + Gold Mark (80-160)
        rare (20%):  Pristine weapon piece (class appropriate, pre-assembled)
        rare (5%):   Harbinger's Mark (accessory: [Void] dmg +10%, void resistance +12%)
```

---

### Room Pool, The Breach

**Pool size:** 8 room types. Each run draws 3-5.

---

**Room 1, "The Guard Hall" (Standard), guaranteed once**
```
weight:       28
roomType:     Standard
enemies:      2x Void Crawler, 1x Reality Shade
enemyCount:   3
hazards:      Reality Fracture (one zone, 12s cycle)
loot:         Standard drops + Soul Residue (+15% drop rate)
description:  The main guard hall, longest room in the dungeon. Reality Shade
              appears through a void tear mid-room. Fracture teaches the hazard
              mechanic in a controlled setting. Most common room.
```

**Room 2, "The Barracks" (Standard)**
```
weight:       22
roomType:     Standard
enemies:      1x Veilborn Wraith, 1x Void Crawler, 1x Corruption Titan
enemyCount:   3
hazards:      none
loot:         Standard drops
description:  The soldiers' barracks, beds now occupied by wraiths. Corruption
              Titan at the far end, the heaviest non-elite enemy in the dungeon.
              No hazard; complexity comes from the enemy mix.
```

**Room 3, "The Armoury" (Standard/Hazard)**
```
weight:       18
roomType:     Standard
enemies:      2x Reality Shade
enemyCount:   2
hazards:      Reality Fracture (two zones, offset 8s cycle)
loot:         Higher Void Crystal drop rate (+20%), Pristine Ancient Sigil bonus
description:  The outpost armoury, void-corrupted weapons on the racks. Two
              Reality Shades emerge from opposite tears. Two fracture zones make
              positioning demanding. Fewer enemies, more hazard complexity.
```

**Room 4, "The Command Post" (Elite)**
```
weight:       15
roomType:     Elite
enemies:      1x Veil Stalker, 1x Sundered Revenant
enemyCount:   2
hazards:      none
loot:         Elite drop table + Pristine Void Spore (55% chance)
description:  The outpost command room, maps and orders still on the table.
              The Veil Stalker and Sundered Revenant together are the hardest
              non-boss fight in the dungeon. Best Pristine rare drop source.
```

**Room 5, "The Signal Chamber" (Puzzle, EXCLUSIVE)**
```
weight:       22
guaranteed:   false (70% inclusion chance per run)
roomType:     Puzzle
puzzleType:   GlyphRuneSequence
enemies:      none
hazards:      none
description:  A runic communication chamber. Void tears flash open briefly,
              each revealing a glowing glyph on the far wall, in sequence.
              Player must tap the rune pads on the floor in the order the
              tears revealed them. Wrong order: void DoT 5s, reset.
              Thematic: the tears are still broadcasting something. What,
              nobody knows.
loot (success): 1x Pristine rare material (random from Veilborn pool)
```

**Room 6, "The Stockroom" (Treasure)**
```
weight:       10
roomType:     Treasure
enemies:      none
hazards:      Reality Fracture (30% chance, one zone, slow 15s cycle)
loot:         2x random Pristine materials + Gold Marks (60-150)
description:  The outpost supply stockroom, largely intact, the void warped
              the doorframe but didn't get inside. High value, low risk.
              Fracture hazard is slow-cycling and avoidable.
```

**Room 7, "The Collapsed Corridor" (Trap)**
```
weight:       15
roomType:     Trap
enemies:      none
hazards:      Reality Fracture cascade (three zones activate in sequence,
              4s apart, 2s duration each, then 10s reset)
loot:         none
description:  A long corridor where the void is unstable. Three fracture zones
              light up in sequence. Players who rush through catch the second
              or third. Teaches reading the cascade pattern.
```

**Room 8, "The Watchtower Base" (Standard, pre-boss)**
```
weight:       18
roomType:     Standard
enemies:      1x Veil Stalker, 1x Veilborn Wraith
enemyCount:   2
hazards:      Reality Fracture (one zone, slow 15s cycle)
loot:         Standard elite drops + outpost log (lore item, last entry
              describes the tear opening, the decision to stay and guard it)
description:  The base of the outpost's watchtower, now half-phased into the void.
              Signals the boss chamber is above. Adjacent to Safe Room when present.
```

---

### The Breach Assembly Rules

```csharp
DungeonData theBreach = {
    dungeonName:       "The Breach",
    zoneId:            "veilborn_wastes",
    recommendedLevel:  65,
    firstClearXP:      3500,
    minRooms:          3,
    maxRooms:          5,
    entranceRoom:      "The Outer Gate",
    safeRoom:          "The Sealed Chamber",
    bossRoom:          "The Tear",
    exclusivePuzzle:   "GlyphRuneSequence",
    exclusiveHazard:   "RealityFracture",
    roomPool:          [rooms 1-8 with weights above]
}
// Assembly: Room 1 guaranteed. Room 5 at 70%. Room 8 adjacent to Safe Room.
```

---

## Dungeon 4B, Valdren's Keep

**Host zone:** Shattered Citadel (Zone 4B)
**Theme:** The private keep of Arcanist Valdren the Unfinished, the court's head
sorcerer whose soul is now bound into a construct body. His experiment is still
running in the keep's lower levels. The constructs still follow his old orders.
**Faction:** `[Arcane]` heavy, `[Outlaw]` minor (looters who got in and couldn't get out).
**Exclusive puzzle:** Weight Counterweight Balance (reuse existing). Thematic fit:
Valdren's keep uses mechanical counterweight locks on its inner doors, an arcane
engineering quirk that predates his construct transition.
**Exclusive hazard:** Arcane Surge, unstable magical node in the room pulses
every 10s, releasing a ring of arcane energy that deals 8 arcane DoT to anyone
in a 3-unit radius of the node. The node's position is visible (glowing column);
the pulse has a 1.5s wind-up shimmer before it fires.
**Visual tileset:** Stone citadel interior, arcane machinery half-buried in rubble,
rune-carved floors, construct patrol routes still active, magical residue glowing
in cracks.
**Recommended level:** 70.

---

### Fixed Rooms

**Entrance Room, "The Gatehouse"**
```
roomType:    Standard
enemies:     2x Citadel Automaton, 1x Ruin Scavenger
enemyCount:  3
hazards:     none
description: The keep's gatehouse. Two Automatons on patrol routes; Scavenger
             is looting a fallen construct in the corner, notices the player
             at the same time as the Automatons. Establishes both factions.
```

**Safe Room, "The Dormant Lab"**
```
roomType:    Safe
enemies:     none
hazards:     none
description: A side laboratory Valdren sealed before the catastrophe, his
             private workspace, undisturbed. HP regen 30s on entry.
             Always contains 1x Healing Draught (tier-appropriate) +
             1x Arcane Residue (zone drop, useful for Artificing pipeline).
```

**Boss Room, "The Experiment Chamber"**
```
roomType:    Boss
enemies:     Valdren the Unfinished
hazards:     none
description: The keep's central laboratory. Valdren's experiment occupies
             the far wall, a vast arcane apparatus still running. Valdren
             himself stands with his back to the entrance, adjusting something.
             Does not stop adjusting until the player gets close.

Boss EnemyData:
    enemyName:       "Valdren the Unfinished"
    factionTags:     ["Arcane"]
    isBoss:          true
    isDungeonBoss:   true
    dungeonId:       "valdrens_keep"
    hp:              20,000   (solo) / 32,000 (2p) / 44,000 (3p)
    damageMin:       48
    damageMax:       75
    attackCadence:   2.2s
    weakPointDesc:   "Runic Core, CENTER MASS (glowing amber orb, Subtle P1,
                      Obvious P2+ when core exposed by damage)"
    weakPointTier:   Subtle (Phase 1) / Obvious (Phase 2 onward)
    weakPointMultiplier: 2.0
    slayingXP:       5,200
    phases:
        Phase 1 (100-65%): Arcane Bolt ranged attack (3s telegraph, slow but
                           heavy), Arcane Surge nodes active (2 nodes in room).
                           Runic Core Subtle, not obviously targetable.
        Phase 2 (65-35%):  Construct Shell cracks, Runic Core exposed, Obvious
                           tier. Summons 1x Spell-Bound Sentinel to assist.
                           Arcane Bolt fires twice in rapid succession.
        Phase 3 (35-0%):   Overload, Arcane Surge nodes pulse twice as fast.
                           Valdren teleports to Runic Core position every 20s
                           (arcane flash telegraph 1.5s). Experiment Feedback:
                           the apparatus in the background fires stray arcane
                           bolts into the room every 15s (random target position,
                           visible targeting reticle 2s before).
    drops:
        guaranteed:  Pristine Gemstone + Pristine Runic Cog + Gold Mark (100-180)
        rare (20%):  Pristine Magical Vestments piece (pre-assembled)
        rare (5%):   Valdren's Apparatus Key (accessory: [Arcane] dmg +10%,
                     arcane resistance +12%)
```

---

### Room Pool, Valdren's Keep

**Pool size:** 8 room types. Each run draws 3-5.

---

**Room 1, "The Patrol Circuit" (Standard), guaranteed once**
```
weight:       28
roomType:     Standard
enemies:      2x Citadel Automaton, 1x Relic Guardian
enemyCount:   3
hazards:      Arcane Surge (one node, 10s cycle)
loot:         Standard drops + Pristine Ancient Sigil (+15% drop rate)
description:  A wide corridor the Automatons still patrol in a loop they've run
              for a hundred years. Relic Guardian at the end of the patrol
              circuit. Arcane Surge node teaches the hazard timing.
```

**Room 2, "The Construct Bay" (Standard)**
```
weight:       22
roomType:     Standard
enemies:      1x Relic Guardian, 1x Spell-Bound Sentinel, 1x Citadel Archmage
enemyCount:   3
hazards:      none
loot:         Standard drops + Arcane Residue bonus
description:  Where constructs were assembled and charged. Three distinct enemy
              types, each with different behaviors. No hazard, the complexity
              is the enemy mix. Archmage is the most dangerous non-elite in
              the dungeon.
```

**Room 3, "The Unstable Ward" (Standard/Hazard)**
```
weight:       18
roomType:     Standard
enemies:      2x Spell-Bound Sentinel
enemyCount:   2
hazards:      Arcane Surge (two nodes, offset 8s cycles)
loot:         Higher Pristine Gemstone drop rate (+20%)
description:  A warded chamber whose containment has been failing for decades.
              Two Arcane Surge nodes create overlapping danger zones. Fewer
              enemies, more spatial management needed.
```

**Room 4, "The Officer's Quarters" (Elite)**
```
weight:       15
roomType:     Elite
enemies:      1x Citadel Archmage, 1x Ruin Lord
enemyCount:   2
hazards:      none
loot:         Elite drop table + Pristine Runic Cog (55% chance)
description:  The quarters of Valdren's senior staff. Ruin Lord scavenging
              from the Archmage's notes, an uncomfortable alliance. Both are
              elite-tier. Best Pristine rare material source in the dungeon.
```

**Room 5, "The Lock Chamber" (Puzzle, EXCLUSIVE)**
```
weight:       22
guaranteed:   false (70% inclusion chance per run)
roomType:     Puzzle
puzzleType:   WeightCounterweightBalance
enemies:      none
hazards:      none
description:  A mechanical counterweight door lock of Valdren's design. Three
              counterweight blocks on pedestals; a wall diagram shows the target
              weight configuration. Player taps blocks in the correct order to
              balance the scale and open the door. Wrong order: arcane bolt
              (10 flat damage), reset. The diagram is always visible.
loot (success): 1x Pristine rare material (random from Shattered Citadel pool)
```

**Room 6, "The Records Room" (Treasure)**
```
weight:       10
roomType:     Treasure
enemies:      none
hazards:      Arcane Surge (25% chance, one node, slow 15s cycle)
loot:         2x random Pristine materials + Gold Marks (70-160) +
              Lost Schematic (guaranteed, one random mid-tier crafting schematic)
description:  Valdren's records and research archives. Largely intact, the
              most organized room in the dungeon. Lost Schematic guaranteed here.
```

**Room 7, "The Overloaded Corridor" (Trap)**
```
weight:       15
roomType:     Trap
enemies:      none
hazards:      Arcane Surge cascade (three nodes activate in sequence, 5s apart,
              2s pulse each, 12s reset before next cascade)
loot:         none
description:  A corridor where the magical infrastructure has been overloaded
              for decades. Three nodes pulse in sequence. Same cascade pattern
              as The Breach's corridor, players who've run both recognize the
              timing teaches transferable skills.
```

**Room 8, "The Antechamber" (Standard, pre-boss)**
```
weight:       18
roomType:     Standard
enemies:      1x Citadel Archmage, 1x Relic Guardian
enemyCount:   2
hazards:      Arcane Surge (one node, 12s cycle)
loot:         Standard drops + research notes (lore item, Valdren's final
              experiment log entry, references the catastrophe and his plan
              to survive it)
description:  The antechamber to the Experiment Chamber. Elevated constructs
              signal the boss is close. Lore item rewards thorough players.
              Adjacent to Safe Room when present.
```

---

### Valdren's Keep Assembly Rules

```csharp
DungeonData valdrensKeep = {
    dungeonName:       "Valdren's Keep",
    zoneId:            "shattered_citadel",
    recommendedLevel:  70,
    firstClearXP:      3500,
    minRooms:          3,
    maxRooms:          5,
    entranceRoom:      "The Gatehouse",
    safeRoom:          "The Dormant Lab",
    bossRoom:          "The Experiment Chamber",
    exclusivePuzzle:   "WeightCounterweightBalance",
    exclusiveHazard:   "ArcaneSurge",
    roomPool:          [rooms 1-8 with weights above]
}
// Assembly: Room 1 guaranteed. Room 5 at 70%. Room 8 adjacent to Safe Room.
```

---

## Dungeon 5A, The Pale Vault

**Host zone:** Ashenwold (Zone 5A)
**Theme:** A buried vault from the ancient void war, a containment facility for
void entities captured by the side that lost. The containment failed a thousand
years ago. What remains is an ash-choked archive of things that should not exist,
still catalogued, still sealed in cases that no longer hold.
**Faction:** `[Void]` and `[Undead]` equally, both factions were involved in the
ancient war and both haunt this place.
**Exclusive puzzle:** Void Rift Seal (NEW). See Section below.
**Exclusive hazard:** Ash Storm, a rolling ash cloud moves across the room floor
every 20s (visible as a grey advancing line, 3s warning). Contact applies
movement -20% and 6 DoT per second for 4s. Passable, players can push through
at the cost of DoT.
**Visual tileset:** Ancient stone vault interior buried under ash, ash drifts on
the floor, containment cases along the walls (some cracked open), void energy
leaking from old case seals, bone-field ash visible through wall fissures.
**Recommended level:** 82.

---

### New Puzzle Type: Void Rift Seal

Five small void rifts appear in the room walls, each glowing a different
intensity of purple (dim, faint, medium, bright, brilliant, indicating the
order they must be sealed). Player must tap each rift in ascending intensity
order within 8 seconds. The rifts flicker (intensity pulses), requiring
observation rather than pure memorization. Wrong order: void DoT 8s (12 per
second), all rifts re-open, reset. Each successful seal plays a tone (low to
high pitch as seals complete) giving audio feedback on progress.

```csharp
public class VoidRiftSealPuzzle : IDungeonPuzzle {
    int[]   correctOrder;         // indices 0-4, sorted by intensity ascending
    float[] riftIntensity;        // randomised per run, 5 values
    float   timeLimit = 8f;
    float   failDoT   = 12f;      // per second for 8s on fail
    int     currentStep = 0;
    float   timer = 0f;

    void OnRiftTapped(int riftIndex) {
        if (riftIndex == correctOrder[currentStep]) {
            currentStep++;
            PlaySealTone(currentStep);
            if (currentStep == 5) OnSuccess();
        } else {
            OnFail();
        }
    }

    void Update() {
        if (puzzleActive) {
            timer += Time.deltaTime;
            if (timer > timeLimit) OnFail();
        }
    }
}
```

---

### Fixed Rooms

**Entrance Room, "The Ash Corridor"**
```
roomType:    Standard
enemies:     2x Ancient Void Crawler, 1x Ashen Revenant
enemyCount:  3
hazards:     Ash Storm (one pass, 20s after room entry, teaches timing)
description: The vault's outer corridor, buried under decades of ash. Ancient
             Void Crawlers patrol the ash-covered floor. The Ashen Revenant
             drifts near the far wall. Ash Storm arrives 20s in, enough time
             to engage enemies before managing the hazard. Establishes both
             factions and the hazard.
```

**Safe Room, "The Intact Seal"**
```
roomType:    Safe
enemies:     none
hazards:     none
description: The one containment bay where the seal held. Still perfectly sealed
             a thousand years later. HP regen 30s on entry.
             Always contains 1x Healing Draught (tier-appropriate) +
             1x Void Core (zone drop, Soulbinding input).
```

**Boss Room, "The Core Archive"**
```
roomType:    Boss
enemies:     The Pale Vault Warden
hazards:     none
description: The vault's central archive, the highest-security containment
             chamber. The Warden is what was assigned to guard it. It has
             been alone in here for a thousand years and has become the most
             dangerous thing it was guarding.

Boss EnemyData:
    enemyName:       "The Pale Vault Warden"
    factionTags:     ["Void", "Undead"]
    isBoss:          true
    isDungeonBoss:   true
    dungeonId:       "the_pale_vault"
    hp:              32,000   (solo) / 51,200 (2p) / 70,400 (3p)
    damageMin:       58
    damageMax:       88
    attackCadence:   1.8s
    weakPointDesc:   "Void Seal, CHEST (cracked containment seal, Obvious always)"
    weakPointTier:   Obvious
    weakPointMultiplier: 2.0
    slayingXP:       7,500
    phases:
        Phase 1 (100-75%): Void Lance, Ash Storm activates in room (one 15s cycle).
                           Void Seal always Obvious.
        Phase 2 (75-50%):  Summons 2x Ancient Void Crawler. Void Lance rate increases.
                           Ash Storm frequency doubles (one pass every 7s).
        Phase 3 (50-25%):  Enrage. Calls Ashen Warlord to assist (from vault catacombs).
                           Void Chains: player movement -25% for 3s, 12s cooldown,
                           telegraphed by ground rune circle.
        Phase 4 (25-0%):   Final form. Ash Storm becomes continuous (slow-moving cloud
                           that stays in the room, forcing player to kite around it).
                           Void Lance fires in a triple burst. Void Seal multiplier
                           increases to 2.5x in this phase only.
    drops:
        guaranteed:  Masterwork Void Spore + Masterwork Phantom Pelt + Large Gold Mark (120-240)
        rare (25%):  Masterwork weapon piece (class appropriate, pre-assembled)
        rare (5%):   Warden's Seal (accessory: [Void] dmg +12%, [Undead] dmg +8%,
                     void resistance +15%)
        rare (3%):   Summoner's Tome (unlocks Summoner deep subclass tree)
```

---

### Room Pool, The Pale Vault

**Pool size:** 8 room types. Each run draws 3-5.

---

**Room 1, "The Containment Gallery" (Standard), guaranteed once**
```
weight:       28
roomType:     Standard
enemies:      2x Ancient Void Crawler, 1x Void Titan
enemyCount:   3
hazards:      Ash Storm (one pass per 25s)
loot:         Standard drops + Masterwork Void Spore (+12% drop rate)
description:  Long gallery of containment cases, most cracked open decades ago.
              Void Titan at the far end is the heaviest standard enemy in T5.
              Ash Storm arrives once during a normal fight, unavoidable,
              teaches the hazard's movement penalty.
```

**Room 2, "The Bone Archive" (Standard)**
```
weight:       22
roomType:     Standard
enemies:      2x Ashen Revenant, 1x Corruption Ancient
enemyCount:   3
hazards:      none
loot:         Standard drops + Soul Essence bonus
description:  The vault's record archive, bone-bound journals and stone tablets.
              Ashen Revenants emerge from ash drifts; Corruption Ancient is
              slow but devastating. No hazard, the Corruption Ancient's long
              reach already punishes positioning mistakes.
```

**Room 3, "The Failed Seals" (Standard/Hazard)**
```
weight:       18
roomType:     Standard
enemies:      2x Void Titan
enemyCount:   2
hazards:      Ash Storm (one pass per 12s, faster than standard)
loot:         Higher Masterwork Ancient Sigil drop rate (+18%)
description:  A bay where multiple seals failed simultaneously, still venting
              ash. Ash Storm cycles faster here; two Void Titans force players
              to keep moving anyway. Hazard and enemies reinforce each other.
```

**Room 4, "The Deep Wing" (Elite)**
```
weight:       15
roomType:     Elite
enemies:      1x Ashen Warlord, 1x Void Archon
enemyCount:   2
hazards:      none
loot:         Elite drop table + Masterwork Void Spore (60% chance) +
              Masterwork Phantom Pelt (40% chance)
description:  The vault's high-security wing, guarded by elites assigned a
              thousand years ago who never left. Ashen Warlord and Void Archon
              together are the hardest non-boss fight in any dungeon.
```

**Room 5, "The Rift Chamber" (Puzzle, EXCLUSIVE)**
```
weight:       22
guaranteed:   false (70% inclusion chance per run)
roomType:     Puzzle
puzzleType:   VoidRiftSeal
enemies:      none
hazards:      none
description:  A small circular chamber with five active void rifts in the walls.
              The rifts pulse at different intensities. Player must seal them
              in ascending intensity order within 8 seconds. The flicker
              requires observation, not memorization.
loot (success): 1x Masterwork rare material (random from Ashenwold pool)
```

**Room 6, "The Intact Gallery" (Treasure)**
```
weight:       10
roomType:     Treasure
enemies:      none
hazards:      Ash Storm (40% chance, one slow pass, 30s after entry)
loot:         2x random Masterwork materials + Large Gold Mark (100-200) +
              Void Core (guaranteed 1x)
description:  The one gallery where all cases are still sealed. The most
              valuable room in the dungeon, and the only genuinely calm one.
              Ash Storm occasionally drifts through, it's the vault, not
              a safe room, but it's as close as this place gets.
```

**Room 7, "The Ash Corridor, Deep" (Trap)**
```
weight:       15
roomType:     Trap
enemies:      none
hazards:      Continuous Ash Storm (cloud moves slowly back and forth across
              the full corridor width, never stops; movement -20% + 6 DoT/s
              while in cloud contact)
loot:         none
description:  A deeper section of the main corridor where ash accumulation
              has created a permanent storm effect. The cloud never stops
              moving. Players must time movement to the cloud's direction,
              not wait for a clear moment. The hardest trap room in any dungeon.
```

**Room 8, "The Warden's Antechamber" (Standard, pre-boss)**
```
weight:       18
roomType:     Standard
enemies:      1x Void Archon, 1x Ashen Revenant
enemyCount:   2
hazards:      Ash Storm (one pass, slow 20s cycle)
loot:         Standard elite drops + vault record (lore item, the original
              Warden's assignment orders, a thousand years old, detail what
              it was guarding and why)
description:  The antechamber to the Core Archive. Void Archon guaranteed
              here, signals the difficulty level of what follows. Lore item
              provides context for the Warden's nature. Adjacent to Safe Room.
```

---

### The Pale Vault Assembly Rules

```csharp
DungeonData thePaleVault = {
    dungeonName:       "The Pale Vault",
    zoneId:            "ashenwold",
    recommendedLevel:  82,
    firstClearXP:      5000,
    minRooms:          3,
    maxRooms:          5,
    entranceRoom:      "The Ash Corridor",
    safeRoom:          "The Intact Seal",
    bossRoom:          "The Core Archive",
    exclusivePuzzle:   "VoidRiftSeal",
    exclusiveHazard:   "AshStorm",
    roomPool:          [rooms 1-8 with weights above]
}
// Assembly: Room 1 guaranteed. Room 5 at 70%. Room 8 adjacent to Safe Room.
```

---

## Dungeon 5B, Firststone Sanctum

**Host zone:** Elder Reaches (Zone 5B)
**Theme:** A pre-civilisation sanctum built by whatever came before. The construction
methods are unknown. The runes are in no recorded language. Arcane constructs of
an entirely different design pattern from anything in the Shattered Citadel are
still active, and they did not build themselves. Something older built them and
something older is still here, at the center.
**Faction:** `[Arcane]` heavy, `[Beast]` minor (primordial creatures that have made
the outer chambers their den).
**Exclusive puzzle:** Rune Lock (NEW). See Section below.
**Exclusive hazard:** Stone Collapse, ancient ceiling sections give way, marked
by a shadow circle on the floor (2s warning, same as Collapsing Masonry) but with
a wider radius (3-unit instead of 1-unit) and heavier damage (20 flat). Telegraph
is the same mechanic players know; the larger radius and heavier hit reward the
skill investment from earlier dungeons.
**Visual tileset:** Pre-civilisation stone of unknown quarry, impossibly precise
construction, rune script on every surface in an unrecognised language, arcane
constructs of alien design, large primordial beast dens in outer chambers, no
evidence of any human presence, ever.
**Recommended level:** 90.

---

### New Puzzle Type: Rune Lock

A circular stone lock mechanism with three concentric rune wheels (inner, middle,
outer). Each wheel has 6 rune symbols. A reference panel on the wall shows the
target configuration (which symbol must be at the 12 o'clock position on each
wheel). Each wheel can be rotated clockwise or counter-clockwise by tapping
left/right arrows. All three wheels must be at their target symbol simultaneously
to unlock. Wheels interact: rotating the outer wheel also shifts the middle wheel
one position in the same direction. Rotating the middle wheel also shifts the
inner wheel one position. Inner wheel rotation is independent.

Strategy: set inner wheel first (no knock-on effects), then middle (affects
inner, adjust), then outer (affects middle, chain-adjust inner again if needed).
Wrong simultaneous configuration if player holds Confirm: 10 flat damage, no reset
(wheels stay where they are, the mistake is mechanical, not a full restart).
No time limit.

```csharp
public class RuneLockPuzzle : IDungeonPuzzle {
    int innerPos, middlePos, outerPos;         // current wheel positions (0-5)
    int targetInner, targetMiddle, targetOuter; // target positions

    void RotateOuter(int direction) {           // +1 or -1
        outerPos  = (outerPos  + direction + 6) % 6;
        middlePos = (middlePos + direction + 6) % 6;  // chain effect
    }
    void RotateMiddle(int direction) {
        middlePos = (middlePos + direction + 6) % 6;
        innerPos  = (innerPos  + direction + 6) % 6;  // chain effect
    }
    void RotateInner(int direction) {
        innerPos  = (innerPos  + direction + 6) % 6;  // independent
    }
    bool TryConfirm() {
        if (innerPos == targetInner && middlePos == targetMiddle && outerPos == targetOuter) {
            OnSuccess();
            return true;
        }
        ApplyDamage(10f);
        return false;
    }
}
```

---

### Fixed Rooms

**Entrance Room, "The Outer Threshold"**
```
roomType:    Standard
enemies:     2x World Golem, 1x Primordial Drake
enemyCount:  3
hazards:     Stone Collapse (one section, 25s cycle, first exposure)
description: The sanctum's outer entrance. World Golems on patrol routes that
             have never varied; Primordial Drake has made the threshold its
             den. Stone Collapse teaches the wider radius compared to earlier
             dungeons. Establishes both faction types.
```

**Safe Room, "The Still Chamber"**
```
roomType:    Safe
enemies:     none
hazards:     none
description: The only room in the sanctum where nothing moves, no rune scripts
             on the walls, no construct on patrol, no wind. It is perfectly
             silent. HP regen 30s on entry.
             Always contains 1x Healing Draught (tier-appropriate) +
             1x Starstone Ore Chunk (zone drop, Smelting input).
```

**Boss Room, "The Center"**
```
roomType:    Boss
enemies:     The Firststone Warden
hazards:     none
description: The sanctum's central chamber. The room is circular, perfectly
             symmetrical, with a single construct standing at the exact center.
             It has been standing there since before recorded history began.
             It does not react to the player entering. It reacts to the player
             approaching.

Boss EnemyData:
    enemyName:       "The Firststone Warden"
    factionTags:     ["Arcane", "Beast"]
    isBoss:          true
    isDungeonBoss:   true
    dungeonId:       "firststone_sanctum"
    hp:              38,000   (solo) / 60,800 (2p) / 83,600 (3p)
    damageMin:       65
    damageMax:       95
    attackCadence:   2.5s (slow but each hit is severe)
    weakPointDesc:   "Rune Core, CENTER MASS (ancient rune symbol, Subtle P1-P2,
                      Obvious P3-P4 when Warden's outer shell is compromised)"
    weakPointTier:   Subtle (P1-P2) / Obvious (P3-P4)
    weakPointMultiplier: 2.0
    slayingXP:       9,000
    phases:
        Phase 1 (100-75%): Heavy melee, Stone Collapse (one section, 18s cycle).
                           Rune Core Subtle, only faintly visible on the shell.
        Phase 2 (75-50%):  Summons 1x Elder Construct to assist. Rune Shockwave:
                           slams ground, stone shockwave moves outward across
                           floor (dodge required, 2s telegraph by ground crack
                           lines spreading from the Warden's feet).
        Phase 3 (50-25%):  Outer shell cracks, Rune Core exposed and Obvious.
                           Stone Collapse accelerates (two sections, 12s cycle).
                           Summons 1x World Golem. Rune Core multiplier 2.0.
        Phase 4 (25-0%):   Final form. Outer shell fully shed, Warden is
                           smaller but faster (attackCadence 1.6s). Rune Core
                           multiplier increases to 2.5x. Rune Shockwave fires
                           twice in 3s. Stone Collapse continuous (one section
                           falls every 8s). World Golem summon from P3 is
                           still present if not killed.
    drops:
        guaranteed:  Masterwork Gemstone + Masterwork Amber + Large Gold Mark (150-280)
        rare (25%):  Masterwork weapon piece (class appropriate, pre-assembled)
        rare (5%):   Firststone Key (accessory: [Arcane] dmg +12%, [Beast] dmg +8%,
                     arcane resistance +15%)
        rare (3%):   Worldtree Shard (Legendary crafting material, 0.5% in zone, 
                     dungeon boss raises this to 3%)
        rare (3%):   Summoner's Tome (unlocks Summoner deep subclass tree)
```

---

### Room Pool, Firststone Sanctum

**Pool size:** 8 room types. Each run draws 3-5.

---

**Room 1, "The Outer Ring" (Standard), guaranteed once**
```
weight:       28
roomType:     Standard
enemies:      2x World Golem, 1x Elder Construct
enemyCount:   3
hazards:      Stone Collapse (one section, 20s cycle)
loot:         Standard drops + Masterwork Gemstone (+12% drop rate)
description:  The sanctum's outer ring corridor. World Golems on patrol routes;
              Elder Construct stationed at the inner door. Stone Collapse
              ceiling is the primary hazard, the sanctum is old and the
              ceilings know it.
```

**Room 2, "The Drake Den" (Standard)**
```
weight:       22
roomType:     Standard
enemies:      2x Primordial Drake, 1x Ancient Wyvern
enemyCount:   3
hazards:      none
loot:         Standard drops + Masterwork Amber bonus + Drake Scale (masterwork)
description:  The outer chambers the primordial creatures have claimed. Two
              Primordial Drakes and an Ancient Wyvern, the densest Beast
              room in any dungeon. No hazard; the beast mix is the challenge.
              Best Drake Scale (masterwork) source in the dungeon.
```

**Room 3, "The Rune Gallery" (Standard/Hazard)**
```
weight:       18
roomType:     Standard
enemies:      1x Elder Construct, 1x Rune Colossus
enemyCount:   2
hazards:      Stone Collapse (two sections, offset 15s cycles)
loot:         Higher Masterwork Runic Cog drop rate (+18%)
description:  A gallery where every surface is covered in unknown rune script.
              The two constructs are the heaviest enemy pair in the dungeon
              outside the elite room. Two stone collapse sections and a narrow
              gallery combine to punish stationary play hard.
```

**Room 4, "The Ancient Post" (Elite)**
```
weight:       15
roomType:     Elite
enemies:      1x Rune Colossus, 1x Primordial Alpha
enemyCount:   2
hazards:      none
loot:         Elite drop table + Masterwork Gemstone (60% chance) +
              Ancient Fang (45% chance, Legendary component)
description:  A guard post that predates naming. Rune Colossus and Primordial
              Alpha both elite-tier, different factions, completely indifferent
              to each other, they attack the player, not each other. Hardest
              non-boss fight. Ancient Fang drop rate is the best outside a raid.
```

**Room 5, "The Lock Antechamber" (Puzzle, EXCLUSIVE)**
```
weight:       22
guaranteed:   false (70% inclusion chance per run)
roomType:     Puzzle
puzzleType:   RuneLock
enemies:      none
hazards:      none
description:  A chamber with a three-wheel rune lock mechanism protecting an
              inner archive door. The reference panel shows the target
              configuration. Outer wheel rotation affects middle; middle
              affects inner. No time limit, the puzzle rewards careful
              reasoning, not speed. Wrong simultaneous configuration costs
              10 flat damage but does not reset.
loot (success): 1x Masterwork rare material (random from Elder Reaches pool)
```

**Room 6, "The Repository" (Treasure)**
```
weight:       10
roomType:     Treasure
enemies:      none
hazards:      Stone Collapse (45% chance, one section, slow 30s cycle)
loot:         2x random Masterwork materials + Large Gold Mark (120-220) +
              Starstone Ore Chunk (guaranteed 2x) +
              Worldtree Shard (1% chance, same rarity as zone drop, but
              concentrated in this room to reward exploration)
description:  The sanctum's materials repository, where it stored everything
              it gathered, for purposes unknown. The highest-value room in any
              dungeon. Stone Collapse is slow and avoidable if the player
              pays attention.
```

**Room 7, "The Collapse Zone" (Trap)**
```
weight:       15
roomType:     Trap
enemies:      none
hazards:      Stone Collapse barrage (five sections, each 10s cycle, all
              staggered by 2s, constant overlapping shadow circles across
              the whole room floor)
loot:         none
description:  A chamber where the ceiling has been actively failing for
              centuries, accelerating. Five overlapping collapse zones with
              staggered timing mean a shadow circle is almost always present
              somewhere. Players must navigate through active collapse fields,
              not wait for a safe moment. The hardest trap room in any dungeon.
```

**Room 8, "The Inner Threshold" (Standard, pre-boss)**
```
weight:       18
roomType:     Standard
enemies:      1x Rune Colossus, 1x Elder Construct
enemyCount:   2
hazards:      Stone Collapse (one section, 15s cycle)
loot:         Standard drops + stone inscription (lore item, the only legible
              text in the entire sanctum, a single word in an ancient script.
              The word is not translated. Reward for finding it.)
description:  The final threshold before the Center. The two heaviest construct
              types in the dungeon. Lore item is a single untranslated word, 
              reward is the mystery, not the answer. Adjacent to Safe Room.
```

---

### Firststone Sanctum Assembly Rules

```csharp
DungeonData firststoneSanctum = {
    dungeonName:       "Firststone Sanctum",
    zoneId:            "elder_reaches",
    recommendedLevel:  90,
    firstClearXP:      5000,
    minRooms:          3,
    maxRooms:          5,
    entranceRoom:      "The Outer Threshold",
    safeRoom:          "The Still Chamber",
    bossRoom:          "The Center",
    exclusivePuzzle:   "RuneLock",
    exclusiveHazard:   "StoneCollapse_Wide",  // new variant of StoneCollapse, wider radius
    roomPool:          [rooms 1-8 with weights above]
}
// Assembly: Room 1 guaranteed. Room 5 at 70%. Room 8 adjacent to Safe Room.
```

---

## New Hazards

Add to the shared hazard table:

| Hazard | Trigger | Effect | Warning |
|--------|---------|--------|---------|
| Reality Fracture | Timed, 12-15s cycle | 10 void DoT/s for 2s while in zone | No telegraph, zone appears without warning |
| Arcane Surge | Timed, 8-10s cycle | 8 arcane DoT in 3-unit radius of node | 1.5s shimmer on node before pulse |
| Ash Storm | Timed, 7-25s cycle (varies by room) | Movement -20%, 6 DoT/s for 4s on contact | Visible advancing cloud line, 3s lead time |
| Stone Collapse (Wide) | Timed, 8-30s cycle | 20 flat damage in 3-unit radius | Shadow circle 2s before impact, wider than standard |

Note: StoneCollapse_Wide is a variant of the existing StoneCollapse hazard.
If `DungeonHazard` is an enum, add `StoneCollapseWide` as a new value with
the larger radius and heavier damage. The existing `StoneCollapse` (1-unit,
moderate damage) used in Gravenspire is unchanged.

## New Puzzles

Add to `DungeonPuzzleUI`:

| Puzzle | Dungeon | Key mechanic |
|--------|---------|-------------|
| VoidRiftSeal | The Pale Vault (5A) | Tap 5 rifts in ascending intensity order within 8s. Audio feedback per seal. |
| RuneLock | Firststone Sanctum (5B) | Three interdependent rune wheels. Set inner first (independent), then middle (shifts inner), then outer (shifts middle). Wrong confirm = 10 damage, no reset. |

## First Clear XP

```csharp
// T4 dungeons:
if (IsFirstClear(playerId, "the_breach"))        AwardXP(equippedGrimoire, 3500);
if (IsFirstClear(playerId, "valdrens_keep"))     AwardXP(equippedGrimoire, 3500);

// T5 dungeons:
if (IsFirstClear(playerId, "the_pale_vault"))    AwardXP(equippedGrimoire, 5000);
if (IsFirstClear(playerId, "firststone_sanctum")) AwardXP(equippedGrimoire, 5000);
```

---

*Path: docs/dungeon-room-pools-t4t5-brief.md*
*Resolves: dungeon-room-pools-t4t5-REQUEST.md*
*Covers: The Breach (4A), Valdren's Keep (4B), The Pale Vault (5A), Firststone Sanctum (5B).*
*New hazards: Reality Fracture, Arcane Surge, Ash Storm, StoneCollapse_Wide.*
*New puzzles: VoidRiftSeal, RuneLock.*
