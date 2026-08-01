---
type: design-spec
version: 1.0
updated: 2026-07-31
path: docs/slaying-content-spec.md
resolves: slaying-content-REQUEST.md
implements: SlayingTalent, SlayingPanelUI, HuntManager, SlayerBountyBoard,
            EnemyData (Hunted variants), CombatManager (hunt spawn logic)
---

# Slaying Content Spec
### Version 1.0

---

## Design Principle

Slaying should feel like a reason to hunt, not a passive number.
Three layers, each at a different engagement level:

1. **Passive spawn bonuses + Hunted variants**, always active, no friction,
   rewards players who fight a lot without asking them to do anything different.
2. **Slayer Hunts**, optional timed engagements the player activates, higher
   difficulty, exclusive rewards. Deliberate choice.
3. **Faction Mastery titles**, long-term collection goal, cosmetic, permanent.

Zone access stays gated by Total Combat Level. Slaying gates only its own content.

---

## 1. Navigation Home: Combat Tab

`SlayingPanelUI` lives on the **Combat Tab** under Character, below the
per-Grimoire level list. It is not a top-level nav entry.

```
COMBAT TAB
─────────────────────
  Per-Grimoire levels (existing)
  Sharpshot         Lv 45   [XP bar]
  Runeweaver        Lv 12   [XP bar]
  Total Combat Level: 57

─────────────────────  (divider)

SLAYING MASTERY       Lv 38   [XP bar]
  Elite spawn bonus:  +8%
  Active Hunt:        [None, Unlock at Lv40]
  Faction Mastery:    [Outlaw Slayer] [Beast Slayer]

  [ View Full Slaying Page ]
```

Tapping "View Full Slaying Page" opens `SlayingPanelUI` as a sub-panel or
modal, showing the full unlock ladder, active hunt status, bounty targets,
faction kill counts, and titles earned.

---

## 2. Full Level Unlock Ladder

Builds on the existing spec anchors (Lv10 Finishing Blow, spawn bonus tiers,
Lv25 fourth task slot). Every unlock is additive, nothing is gated behind
Slaying that removes existing functionality.

| Level | Unlock | Notes |
|-------|--------|-------|
| 1 | Slaying XP from all kills | Baseline |
| 5 | Elite spawn +2% | First spawn bonus increment |
| 10 | **Finishing Blow** | Active: execute an enemy below 15% HP instantly. Cooldown 30s. Grants full slayingXP even on execute. |
| 15 | **Hunted Variants** unlock | Rare variant of each enemy type begins spawning passively. See Section 3. |
| 20 | Elite spawn +5% (cumulative) | Spec anchor |
| 25 | **4th Task Slot** | Spec anchor, fourth simultaneous task available |
| 30 | **Faction Tracking** | Slaying page shows per-faction kill counts. Progress toward Faction Mastery titles begins. |
| 35 | Elite spawn +10% (cumulative) | |
| 40 | **Slayer Hunts unlock** | Player can activate Hunts from the Slaying page. See Section 4. |
| 45 | **Finishing Blow upgrade** | Execute threshold rises to 20% HP. |
| 50 | **Bounty Board** unlocks | Three rotating weekly bounty targets appear on the Slaying page. See Section 5. |
| 55 | Elite spawn +15% (cumulative) | |
| 60 | **Hunt Reward bonus** | Completing a Hunt awards +20% bonus Slaying XP. |
| 65 | **Hunted Variant drop boost** | Hunted Variants now have a 5% chance to drop a Pristine rare material regardless of zone tier. |
| 70 | **Second active Hunt slot** | Player can run two concurrent Hunts. |
| 75 | Elite spawn +18% (cumulative) | |
| 80 | **Finishing Blow upgrade** | Execute threshold rises to 25% HP. CD reduced to 20s. |
| 85 | **Boss Hunt** unlock | Hunts can now target zone bosses specifically. See Section 4.3. |
| 90 | **Slayer's Eye** | Passive: weak-point tier on Hunted Variants displays as one tier higher than normal (Hidden shows as Subtle; Subtle shows as Obvious). |
| 95 | Elite spawn +20% (cumulative, cap) | Max spawn bonus |
| 100 | **Capstone: The Grimoire's Bane** | Permanent +5% damage to ALL enemy faction types. Unlocks "The Grimoire's Bane" title. |

---

## 3. Hunted Variants (Slaying 15+)

Passive, no player activation required. Once the player reaches Slaying 15,
a rare variant of each enemy type begins spawning alongside normal enemies.

### 3.1 What is a Hunted Variant

A Hunted Variant is the same `EnemyData` enemy with three changes:

```csharp
// Applied as an overlay on spawn, does not require a separate ScriptableObject:
enemy.isHunted       = true;
enemy.hp             *= 1.4f;               // 40% more HP
enemy.damageMin      = Mathf.RoundToInt(enemy.damageMin * 1.15f);  // 15% more damage
enemy.dropTableBonus = 0.30f;               // +30% drop rate on all drop table items
enemy.slayingXP      *= 2f;                 // double Slaying XP on kill
```

Visually: Hunted Variants display a small orange hunting mark icon above their
head (same slot as the elite amber-gold trim, but distinct, a crosshair or
diamond mark). Players learn to recognize them as higher-value targets.

### 3.2 Spawn rate

```csharp
// In CombatManager.SpawnEnemy():
float huntedChance = SlayingTalent.GetHuntedSpawnChance();

static float GetHuntedSpawnChance() =>
    slayingLevel >= 15 ? Mathf.Lerp(0.05f, 0.15f, (slayingLevel - 15) / 85f) : 0f;
// L15: 5%, L100: 15%, linear interpolation
```

At Slaying 15, roughly 1 in 20 enemies is a Hunted Variant. At Slaying 100,
roughly 1 in 7. Never replaces elites, the Hunted check fires on non-elite
standard enemy spawns only.

### 3.3 Hunted Variant faction kill tracking

Kills of Hunted Variants increment faction kill counters separately from
standard kills. These counters feed Faction Mastery titles (Section 6).
The Slaying page shows both total kills and Hunted kills per faction.

---

## 4. Slayer Hunts (Slaying 40+)

A Hunt is an optional, player-activated timed engagement. The player selects
a Hunt target from the Slaying page, activates it, and then enters a zone to
fight. The Hunt modifies enemy behavior in the active zone for the Hunt duration.

### 4.1 Hunt structure

```csharp
public class HuntData : ScriptableObject
{
    public string huntId;
    public string displayName;
    public string description;
    public int    minSlayingLevel;      // minimum Slaying to unlock this Hunt
    public EnemyFactionTag targetFaction;
    public int    killTarget;           // number of kills to complete the Hunt
    public float  durationMinutes;      // time limit
    public HuntReward[] rewards;        // see 4.2
}

public class HuntReward
{
    public QuestRewardType type;
    public string id;
    public int amount;
    public float dropChance;  // for item rewards: chance to drop on Hunt complete
}
```

**Activation flow:**
1. Player opens Slaying page, selects a Hunt from the available list.
2. Confirmation: "Hunt the [Faction] for [N] minutes. Kill [X] to complete."
3. Confirm: Hunt activates. Timer starts. `HuntManager.StartHunt(huntId)` called.
4. Player enters any eligible zone and fights.
5. On completion (kills met or timer expires): Hunt resolves, rewards granted.

**Mid-hunt behavior:**
- Hunt target faction enemies spawn at double the normal rate in the active zone.
- Non-target faction enemies still spawn normally (Hunts don't empty the zone).
- Hunted Variants of the target faction spawn at 3x normal rate during a Hunt.

**On expiry (timer, not kills):**
- Partial rewards: if player got 50%+ of target kills, grant half the Hunt rewards.
- Below 50%: no rewards, Hunt slot clears, cooldown applies.

**Cooldown:** 4 hours per Hunt slot after completion or expiry.

### 4.2 Hunt reward types

Hunt rewards are richer than equivalent quest rewards, scaled to the Hunt's
difficulty (kill count, duration, minimum Slaying level).

```
Standard Hunt reward example (Lv40 unlock):
  Complete 40 [Beast] kills in 20 minutes
  Reward: 3,000 Slaying XP + 2x Refined rare material + 30 GM

Hard Hunt reward example (Lv60+):
  Complete 60 [Void] kills in 25 minutes
  Reward: 6,000 Slaying XP + 2x Pristine rare material + 60 GM
          + 10% chance: exclusive Hunt drop (see 4.4)
```

### 4.3 Boss Hunt (Slaying 85+)

Boss Hunts target zone bosses specifically. Activating a Boss Hunt raises the
zone boss spawn chance from the standard 1-in-20 to 1-in-5 for the Hunt
duration (30 minutes). The boss must be defeated (not just encountered) to
complete the Hunt.

```csharp
public class BossHuntData : HuntData
{
    public string targetBossEnemyName;  // matches EnemyData.enemyName
    public int    bossKillTarget = 1;   // usually 1; may be 2 for lower-tier bosses
}
```

Boss Hunt rewards are the best Slaying rewards in the base game outside raids:

```
Boss Hunt reward example:
  Kill The Hollow Archbishop within 30 minutes
  Reward: 8,000 Slaying XP + 1x Pristine Phantom Pelt (guaranteed) + 80 GM
          + 15% chance: Boss Hunt Trophy (cosmetic, faction-flavored accessory)
```

### 4.4 Exclusive Hunt Drops

Hunts introduce a small set of items obtainable only by completing Hunts.
These are not powerful gear upgrades, they are cosmetic or flavour items
that mark the player as a dedicated hunter. Code authors as ItemData with
`isHuntExclusive = true`.

| Item | Faction | Hunt tier |
|------|---------|-----------|
| Outlaw Trophy | [Outlaw] | Lv40 Hunt |
| Beast Fang Necklace | [Beast] | Lv40 Hunt |
| Wraith Binding | [Undead] | Lv50 Hunt |
| Void Shard Pendant | [Void] | Lv60 Hunt |
| Arcane Focus Shard | [Arcane] | Lv60 Hunt |
| Nature Crown | [Nature] | Lv70 Hunt |
| Boss Hunt Trophy | [Boss] | Lv85 Boss Hunt |

All are accessories in the accessory slot with minor stat effects (e.g.
+2% damage to the relevant faction) and a visible cosmetic identifier on
the character portrait. The Slaying page shows which Hunt Trophies the
player has earned.

---

## 5. Bounty Board (Slaying 50+)

Three rotating weekly bounties appear on the Slaying page. Bounties are
more specific than Hunts, they target a named enemy or a specific elite
encounter, and they pay out more precisely.

### 5.1 Bounty structure

```csharp
public class BountyTarget
{
    public string bountyId;
    public string displayName;           // "Wanted: The Wight Commander"
    public string targetEnemyName;       // matches EnemyData.enemyName
    public EnemyFactionTag faction;
    public int    killsRequired;         // 1 for bosses/elites, 5-10 for standard
    public BountyReward reward;
    public DateTime expiresAt;           // Monday 00:00 UTC, same as weekly quests
}
```

**Bounty pool:** 15 named bounty definitions. Three drawn per week (weighted
random, same pattern as the quest pool). Bounties reference named enemies
from across all zones, including elites from zones the player may not yet
have access to (those bounties are visible but marked "Zone access required").

**Example bounties:**
- "Wanted: The Ashfen Lich, Kill the Zone 2A boss. Reward: 5,000 Slaying XP + 2x Rough Phantom Pelt + 40 GM"
- "Wanted: Wight Commanders, Kill 5 Wight Commander elites. Reward: 4,000 Slaying XP + 1x Refined Phantom Pelt + 35 GM"
- "Wanted: Void Crawlers, Kill 10 Void Crawlers (any zone). Reward: 3,000 Slaying XP + 1x Pristine Void Spore + 30 GM"

### 5.2 Bounty claiming

Same server RPC pattern as quest rewards (`collect_quest_reward`). Bounty
progress tracked in `player_quests` table with `cadence = 'bounty'` to
distinguish from daily/weekly quests. Existing infrastructure handles it.

### 5.3 Bounty Board display on Slaying page

```
BOUNTY BOARD  (resets Monday 00:00 UTC)

[Wanted: Ashfen Lich]
Kill the Ashfen Lich (Zone 2A boss)
Progress: 0 / 1
Reward: 5,000 Slaying XP  2x Rough Phantom Pelt  40 GM
[ Claim ]  (greyed until complete)

[Wanted: Void Crawlers]
Kill 10 Void Crawlers (any zone)
Progress: 3 / 10
...
```

---

## 6. Faction Mastery Titles (Slaying 30+)

Faction kill counters unlock permanently when the player reaches Slaying 30.
Titles are earned by reaching kill milestones in each faction.

### 6.1 Title thresholds

| Kills | Title earned | Faction |
|-------|-------------|---------|
| 100 | "[Faction] Hunter" | Any faction |
| 500 | "[Faction] Slayer" | Any faction |
| 1,000 | "[Faction] Bane" | Any faction |
| 2,500 | "Master [Faction] Slayer" | Any faction |

Applied for each faction tag (`[Outlaw]`, `[Beast]`, `[Undead]`, `[Arcane]`,
`[Void]`, `[Nature]`). A player who has killed 500 Undead and 100 Beasts holds
"Undead Slayer" and "Beast Hunter" simultaneously.

### 6.2 Title display

Active title displays on the guild roster beneath the player's username, and
on their character portrait tooltip. Player can select which earned title to
display from the Slaying page.

The Lv100 capstone title "The Grimoire's Bane" overrides all faction titles
if selected, but the player can choose any earned title to display instead.

### 6.3 Title data

```csharp
public class SlayerTitle
{
    public string titleId;
    public string displayText;       // "Undead Slayer", "Beast Bane", etc.
    public EnemyFactionTag faction;  // EnemyFactionTag.None for cross-faction titles
    public int killsRequired;
    public bool isCapstone;          // Lv100 "The Grimoire's Bane" flag
}
```

Titles stored on the player record. `player.equippedTitleId` references the
active display title. RLS-safe: only the player writes their own title.

---

## 7. Slaying Page Full Layout

```
╔═══════════════════════════════════════╗
║  SLAYING MASTERY          Level 54    ║
║  ████████████░░░  12,400 / 18,000 XP  ║
╠═══════════════════════════════════════╣
║  PASSIVE BONUSES                      ║
║  Elite spawn bonus:  +15%             ║
║  Hunted variant rate: ~10%            ║
║  Finishing Blow:  Execute below 20%   ║
╠═══════════════════════════════════════╣
║  ACTIVE HUNTS                         ║
║  Slot 1: [No Hunt active]  [Activate] ║
║  Slot 2: Locked (Slaying 70)          ║
╠═══════════════════════════════════════╣
║  BOUNTY BOARD  (resets in 3d 14h)    ║
║  > Wanted: Wight Commanders  3/5      ║
║  > Wanted: Void Crawlers     10/10 ✓ ║
║  > Wanted: Ashfen Lich       0/1      ║
╠═══════════════════════════════════════╣
║  FACTION MASTERY                      ║
║  [Outlaw]  ████░░  320 / 500  Slayer  ║
║  [Beast]   ██░░░░  180 / 500          ║
║  [Undead]  ██████  1,240  Bane        ║
║  [Void]    ░░░░░░   45                ║
║  [Arcane]  █░░░░░   88                ║
║  [Nature]  ░░░░░░   12                ║
╠═══════════════════════════════════════╣
║  TITLES EARNED                        ║
║  Outlaw Hunter  |  Undead Bane        ║
║  [ Active: Undead Bane ▼ ]            ║
╠═══════════════════════════════════════╣
║  NEXT UNLOCKS                         ║
║  Slaying 55: Elite spawn +15% → +18%  ║
║  Slaying 60: Hunt Reward +20% XP      ║
║  Slaying 65: Hunted drop boost        ║
╚═══════════════════════════════════════╝
```

---

## 8. Implementation Checklist

### Data and infrastructure
- [ ] `HuntData` and `BossHuntData` ScriptableObjects
- [ ] `HuntManager`, activation, timer, kill tracking, reward grant
- [ ] `SlayerTitle` data, title definitions, player equipped title field
- [ ] `player_quests` table reuse for bounties (`cadence = 'bounty'`)
- [ ] Faction kill counters in player data (6 counters, one per faction tag)
- [ ] `isHunted` flag on enemy spawn overlay (not a new ScriptableObject)

### Combat wiring
- [ ] `CombatManager.SpawnEnemy`: apply Hunted Variant overlay at `huntedChance`
- [ ] `CombatManager.SpawnEnemy`: raise target faction spawn rate 2x during Hunt
- [ ] `CombatManager.SpawnEnemy`: raise boss spawn chance to 1-in-5 during Boss Hunt
- [ ] Hunted Variant visual mark (orange crosshair icon above head)
- [ ] Faction kill counter increments on every kill (Slaying 30+ only)
- [ ] Hunted kill counter increments separately on Hunted Variant kills

### SlayingPanelUI
- [ ] Wire `SlayingPanelUI` to Combat Tab (existing panel, existing code, just needs home)
- [ ] Hunt slot UI: activate button, timer display, kill progress bar
- [ ] Bounty Board section: three bounty rows, progress, claim button
- [ ] Faction Mastery section: six faction rows with kill counts and title indicators
- [ ] Title selector dropdown from earned titles
- [ ] Next Unlocks section: shows next 3 unreached ladder milestones

### Unlock ladder
- [ ] All ladder milestones in `SlayingTalent.GetUnlocksForLevel(int level)`
      covering Lv1 through Lv100 per the table in Section 2
- [ ] Finishing Blow ability: active button in combat UI, executes sub-threshold enemy,
      30s cooldown, upgrades at Lv45 (20%) and Lv80 (25%, 20s CD)
- [ ] Slayer's Eye (Lv90): weak-point tier display upgrade for Hunted Variants only

### 15 Bounty definitions
Author as ScriptableObjects covering all zone tiers, both boss and elite targets.
Minimum 3 per zone tier to ensure rotation variety at all player levels.

---

## 9. Acceptance Criteria

- Reaching Slaying 15 causes roughly 1 in 20 standard enemy spawns to be a
  Hunted Variant, visually marked, with 40% more HP and 2x Slaying XP.
- Reaching Slaying 40 shows the Hunt activation UI on the Slaying page.
  Activating a Hunt doubles the target faction spawn rate for the Hunt duration.
- Reaching Slaying 50 shows three weekly bounty targets on the Slaying page.
- Faction kill counters increment at Slaying 30. Earning 500 kills against
  any single faction awards the "[Faction] Slayer" title.
- Finishing Blow executes an enemy below 15% HP and grants full slayingXP.
- The Slaying page is reachable via the Combat Tab and contains all sections
  per the layout in Section 7.
- Reaching Slaying 100 grants +5% damage to all enemy types and unlocks
  "The Grimoire's Bane" title.
- Zone access is not affected by Slaying level at any point.

---

*Path: docs/slaying-content-spec.md*
*Resolves: slaying-content-REQUEST.md*
*Covers: full Lv1-100 unlock ladder, Hunted Variants (passive), Slayer Hunts (active),*
*Boss Hunts (Lv85), Bounty Board (Lv50), Faction Mastery Titles (Lv30),*
*SlayingPanelUI layout and navigation home.*
