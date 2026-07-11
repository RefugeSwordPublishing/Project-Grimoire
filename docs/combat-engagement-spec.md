---
type: design-spec
version: 0.2
updated: 2026-07-11
reconciled-to: implementation-status.md (2026-07-10)
---

# Project Grimoire — Combat Engagement Spec
### Version 0.2

> **As-built note:** The combat hub (zone/dungeon tiles, lock state, enemy roster with
> `EnemyData.spawnWeight`) and `ZoneAccess.cs` are built — see `implementation-status.md`.
> `CombatManager.EnterZone` is a stub waiting on this spec. Raids are Phase 4 deferred — raid
> sections below are design intent only, not pending implementation.

---

## Design Philosophy

Combat scales in complexity from zone grinding (semi-idle, active for bonuses) through dungeons
(structured, not idleable) to raids (fully active, Phase 4). The visual language is consistent —
over-the-shoulder throughout. The zone combat loop is the foundation everything else builds on.

---

## Zone Combat

### Visual — Over-the-Shoulder (all classes)
- Player character silhouette visible from behind in foreground
- Enemy visible ahead in the mid-ground; zone environment fills background
- Combat UI overlays bottom of screen — class-specific inputs never overlap the enemy view

| Class | Unique UI element |
|-------|-----------------|
| Warden | Bowstring draw bar, aim arc, weak-point glow |
| Arcanist | Runic Constellation arch (bottom 40% of screen) |
| Vanguard | Strike / Guard / Surge triangle buttons, combo queue row |

### In-Zone Combat Loop (implement this in `EnterZone`)

This is the concrete loop `CombatManager.EnterZone` must run:

```
1. SPAWN
   Pick next enemy via weighted-random draw over EnemyData.spawnWeight for this zone.
   Standard enemies form the base pool.
   After each standard spawn, roll elite check (see Elite Cadence below).
   After each encounter resolved, roll boss check (see Boss Cadence below).

2. RESOLVE (one enemy at a time)
   Idle path:   server-side damage formula ticks at IdleTickRate (see below).
                Enemy deals damage back at its base rate. No input from player.
   Active path: player inputs (Bowstring / Constellation / Combo) modify damage/loot.
                Both paths use the same underlying combat math — active play adds
                attunement bonuses on top, it does not replace the idle calculation.

3. LOOT
   On enemy death: roll loot table from EnemyData. Apply any active drop-rate buffs
   (guild Prospector's Fortune, Hunter's Providence, Lucky Charm — drop/yield only,
   NOT spawn rate — see Spawn-Rate Buff section below).
   Award Grimoire combat XP to currently equipped Grimoire via CombatXPManager.

4. REPEAT from step 1.
   Zone session continues until player leaves the zone or session ends.
```

**Idle tick rate:** one combat tick every 2.0 seconds base, scaling with equipped gear.

### Enemy Selection — Weighted Random

`EnemyData.spawnWeight` is a relative integer weight already stored on each ScriptableObject.
Selection algorithm:

```csharp
EnemyData PickEnemy(ZoneData zone) {
    // Filter to standard (non-elite, non-boss) enemies for this zone
    var pool = zone.enemies.Where(e => !e.isElite && !e.isBoss).ToList();
    int totalWeight = pool.Sum(e => e.spawnWeight);
    int roll = Random.Range(0, totalWeight);
    int cumulative = 0;
    foreach (var enemy in pool) {
        cumulative += enemy.spawnWeight;
        if (roll < cumulative) return enemy;
    }
    return pool.Last(); // fallback
}
```

### Elite Cadence

After each standard enemy is defeated, roll for elite:

```
baseEliteChance = 0.06f  (6%)
eliteBonus      = Mathf.Clamp(grimoireCombatLevel * 0.001f, 0f, 0.09f)
                  // +0.1% per combat level, caps at +9% at level 90
finalChance     = baseEliteChance + eliteBonus
```

So the range is **6% at combat level 1** → **~15% at combat level 90+**.
This uses the currently equipped Grimoire's combat level, not Total Combat Level.

Elite enemies are drawn from `zone.enemies.Where(e => e.isElite)` — same weighted-random as
standard pool but restricted to the elite subset.

### Boss Cadence

Zone bosses are **active play only** — they do not spawn during idle sessions.
After each encounter resolved during an active session:

```
bossChance = 1f / 20f  (5%)
```

Roll is flat — no scaling. If the zone has no active player session (server-side idle), the roll
is skipped entirely. Boss despawns after **10 minutes** if the player fails to engage.
Only one boss active per zone per player at a time.

Boss enemy drawn from `zone.enemies.Where(e => e.isBoss)`.

### Spawn-Rate Buff Model — Explicit Decision

**No active buff modifies enemy spawn rate in Phase 2 or the base game.**

Guild buffs (Prospector's Fortune, Bountiful Harvest, Hunter's Providence, Lucky Charm,
Merchant's Window) affect **drops, yield, marks, and LCK** — none touch spawn cadence.
Personal Cookery / Alchemy buffs similarly affect drops and stats, not spawn frequency.

**Action for Claude Code:** Remove `CombatHubUI.SpawnBonusPercent()` and its UI slot entirely.
The "(+X%)" spawn bonus display should not appear. If the hook is wired elsewhere, stub it to
always return 0 and add a `// spawn-rate buffs not implemented — by design` comment.

This may be revisited if a future Slaying talent milestone or DLC mechanic specifically grants
spawn-rate bonuses — but nothing in the current design does.

### Slaying Talent — Elite Spawn Rate Bonus

The Slaying talent (not a Grimoire combat level) grants a separate elite spawn bonus at level
milestones. This stacks additively with the combat-level scaling above:

| Slaying Level | Elite Spawn Bonus |
|--------------|------------------|
| 1–19 | +0% |
| 20 | +2% |
| 40 | +5% |
| 60 | +9% |
| 80 | +14% |
| 100 | +20% |

`finalEliteChance = baseEliteChance + combatLevelBonus + slayingBonus`

---

## Shadow Step — Shadowblade Zone Combat

Shadow Step is a combat state, not physical repositioning (2D over-the-shoulder — no "behind"):

```
U→U combo fires
  → Shadowblade enters Shroud state (renderer alpha → 0.2)
  → nextEnemyAttackMissed = true
  → onNextStrikeInput += ApplyShadowStepBonus (+80% flat multiplier, NOT a crit)
On next Strike input:
  → damage × 1.8 applied
  → renderer restored, state = Active
```

The UI shows "Critical!" on the hit for player satisfaction — the backend is a flat ×1.8
multiplier. `critChance` remains 0 for all Vanguard subclasses.

---

## Dungeon Combat

### Visual — Top-to-Bottom Scrolling Approach

Dungeon phase uses a top-to-bottom scroll — player anchored near bottom, dungeon tileset
scrolling upward, enemies descending from the top:

```
┌─────────────────────────────┐
│  [Enemy / event entering] ▼ │  ← appear at top
│                             │
│  [Tileset scrolling up]     │  ← camera fixed, world moves
│                             │
│  [Player character]         │  ← anchored near bottom
└─────────────────────────────┘
```

When an enemy reaches engagement range the scroll pauses and transitions seamlessly to the
over-the-shoulder combat view (same perspective — no camera flip needed).

### Dungeon Randomization

Every run is procedurally assembled from a dungeon-specific room pool.

**Fixed structure (every run):**
```
Entrance Room → [3–5 randomised rooms from pool] → Safe Room → Boss Room
```

**Dungeon room pools (themed per dungeon):**

| Dungeon | Zone | Exclusive hazard/puzzle | Room themes |
|---------|------|------------------------|-------------|
| Aldric's Warren | Grimwood Fringe | Forge Puzzle | Bandit camp, weapon caches, cells |
| Crestfall Cove | Saltmarsh Shore | Flood Trap | Smuggler holds, sea caves, dock |
| Mirefall Barrow | Ashfen Mire | Glyph Puzzle | Burial chambers, crypt corridors |
| Warden's Folly | Ironspine Reaches | Weight/Scale Puzzle | Barracks, armory, command rooms |

**Room types:** Standard (2–4 enemies) · Elite (1–2 elites) · Trap · Puzzle · Treasure · Safe ·
Boss.

Dungeons are **not idleable** — hazards during the approach phase require active player input.
The combat loop inside dungeon rooms follows the same resolve logic as zone combat, without the
spawn roll (rooms have fixed enemy compositions from their ScriptableObject pool).

---

## Raids — Phase 4 Design Intent (do not implement now)

> Raids are explicitly deferred to Phase 4. The following is design intent only.
> See `docs/deferred-systems-dlc-notes.md` for the do-not-build list.

Raids use a turn-based grid map for exploration (5-second turn timer, all players move
simultaneously) with dynamic encounter joining (Rush mechanic — 2 tiles/turn toward combat vs 1).
Boss fights use full-screen over-the-shoulder. Floor objectives gate progression between floors.

Supabase write load at 25 simultaneous raids ≈ 35 writes/sec (well within Small compute) because
the turn-based model batches all position updates once per turn rather than streaming continuously.

---

*Path: `docs/combat-engagement-spec.md`*
