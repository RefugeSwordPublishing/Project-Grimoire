---
type: reconcile-spec
version: 1.0
updated: 2026-07-27
path: docs/combat-progression-reconcile.md
implements: CombatXPManager, CombatMechanics (hit events), CombatTabUI
supersedes: CLAUDE.md "locked design decisions" section on combat levels
---

# Project Grimoire — Combat Progression Reconcile Spec
### Version 1.0

---

## Problem Statement

Three things are currently in conflict:

1. **CLAUDE.md** states per-Grimoire combat levels, Total Combat Level = sum of Grimoire levels.
2. **Code** routes bow/melee/spell hits to shared path talents (`Marksmanship`, `Spellcasting`,
   `Warfare`), and `CombatXPManager.AddCombatXP` (the per-Grimoire system) is only called
   by a dev button and quest rewards — never by normal combat.
3. **Design intent** (Dustin): progression should be per-Grimoire, shown as "Sharpshot Lv 45,
   Summoner Lv 23." No separately visible Marksmanship/Spellcasting/Warfare talent.

This spec locks the per-Grimoire model and tells Code exactly what to change.
After this is implemented, update `implementation-status.md` and retire the stale
CLAUDE.md section.

---

## 1. XP Routing (the core change)

### 1.1 What changes

Every combat hit and kill that currently awards XP to a shared path talent
(`Marksmanship`, `Spellcasting`, `Warfare`) is rerouted to
`CombatXPManager.AddCombatXP(equippedGrimoireId, amount)`.

No other combat XP destination exists. After this change, `Marksmanship`,
`Spellcasting`, and `Warfare` receive zero XP from combat.

### 1.2 XP amounts per event

Keep the existing damage/hit-based values already computed in the combat
mechanics. Restate them here for clarity; do not change the amounts,
only the destination.

```csharp
// In CombatMechanics (or wherever hit resolution fires):

// On any hit (weapon contact, spell impact):
float baseXp = damageDealt * 1.0f;

// Weak point hit bonus:
if (isWeakPointHit)
    baseXp *= 1.5f;

// Kill bonus:
if (isKill)
    baseXp += enemy.slayingXP * 0.25f;   // 25% of slayingXP goes to Grimoire

// Route to equipped Grimoire — NOT to Marksmanship/Spellcasting/Warfare:
CombatXPManager.AddCombatXP(PlayerState.equippedGrimoireId, Mathf.RoundToInt(baseXp));
```

If the current damage-based formula differs from the above, use whatever is
already in code — the point is the destination, not the amount. The amounts
only need changing if they produce broken level speeds once rerouted (tune
separately if needed, see Section 1.3).

### 1.3 XP curve dependency

`CombatXPManager` must use the same XP-to-next-level curve as `TalentManager`
for all UI displays (time-to-level parity). If `CombatXPManager` has its own
curve, reconcile it to `TalentManager.XpToNextLevel` or document the difference.

**Rate-of-leveling check:** a player actively fighting in a tier-appropriate
zone should level their equipped Grimoire at approximately the same rate they
level their primary combat talent (Felling, Slaying, etc.) — roughly 1-2 levels
per focused session. If rerouting the same XP values produces a dramatically
faster or slower rate, apply a scalar:

```csharp
const float grimoireXpScalar = 1.0f;  // tune here if needed after profiling
CombatXPManager.AddCombatXP(grimoireId, Mathf.RoundToInt(baseXp * grimoireXpScalar));
```

---

## 2. Shared Path Talents: Retirement Plan

### 2.1 Decision

`Marksmanship`, `Spellcasting`, and `Warfare` are **retired as visible talents**.
They are not deleted from code yet — they serve as the invisible per-path
aggregate that `TalentManager.GetHighestCombatTalentLevel` currently reads.
See Section 3 for how Total Combat Level is rerouted off them.

After Total Combat Level is rerouted (Section 3), these talents can be deleted
in a follow-up cleanup pass. Do not delete them in this implementation — wait
until zone gating is confirmed working from the new source.

### 2.2 What "retired as visible" means

- Remove `Marksmanship`, `Spellcasting`, `Warfare` from the talent panel UI.
  They do not appear anywhere a player can see.
- Remove them from any talent-panel queries, XP display, or milestone lists.
- They remain as `TalentType` enum values and `TalentData` ScriptableObjects
  until the cleanup pass.
- They receive zero XP after this change (no combat routes to them).

### 2.3 Migration: banked XP in shared talents

Players on the dev build may have XP banked in `Marksmanship`, `Spellcasting`,
or `Warfare` from prior testing. On first launch after this change:

```csharp
// One-time migration on app start, keyed by a migration flag:
if (!PlayerPrefs.HasKey("migration_v2_combat_xp_rerouted"))
{
    // Convert banked shared-talent XP to the player's currently equipped Grimoire.
    // Use a 1:1 conversion ratio.
    int bankedXp = TalentManager.GetBankedXP(TalentType.Marksmanship)
                 + TalentManager.GetBankedXP(TalentType.Spellcasting)
                 + TalentManager.GetBankedXP(TalentType.Warfare);

    if (bankedXp > 0)
        CombatXPManager.AddCombatXP(PlayerState.equippedGrimoireId, bankedXp);

    // Zero out the shared talents (they receive no more XP anyway, but clean state):
    TalentManager.SetBankedXP(TalentType.Marksmanship, 0);
    TalentManager.SetBankedXP(TalentType.Spellcasting, 0);
    TalentManager.SetBankedXP(TalentType.Warfare, 0);

    PlayerPrefs.SetInt("migration_v2_combat_xp_rerouted", 1);
}
```

If `TalentManager` does not expose `GetBankedXP` / `SetBankedXP`, add them or
read/write the underlying Supabase column directly. The migration only runs once.

For a production launch with real player data, run this as a Supabase migration
instead of a client-side one-time block, so it applies to all accounts atomically.

---

## 3. Total Combat Level and Zone Gating

### 3.1 Current state (broken)

`TalentManager.GetHighestCombatTalentLevel` sums (or maxes) the shared path
talents. Since those talents receive no XP from normal combat, Total Combat Level
is stuck at its initial value for all players.

### 3.2 New definition

```
Total Combat Level = sum of levels of all Grimoires owned by the player
```

Each Grimoire has its own level in `CombatXPManager`. A player with three Grimoires
at levels 31, 12, and 8 has Total Combat Level = 51.

```csharp
// New implementation of the total combat level getter:
public static int GetTotalCombatLevel()
{
    int total = 0;
    foreach (var grimoireId in PlayerState.ownedGrimoireIds)
        total += CombatXPManager.GetGrimoireLevel(grimoireId);
    return total;
}
```

### 3.3 Zone gating

Replace all calls to `TalentManager.GetHighestCombatTalentLevel` in zone-access
logic with `GetTotalCombatLevel()`. There must be exactly one place in code
that computes zone eligibility — find it and swap the call.

```csharp
// Zone access gates (as designed):
// T1: Total Combat Level >= 1   (open from start)
// T2: Total Combat Level >= 21
// T3: Total Combat Level >= 51
// T4: Total Combat Level >= 91
// T5: Total Combat Level >= 141
```

If `ZoneAccess.cs` already uses a constant-or-method for this, replace only
the data source, not the gate logic.

### 3.4 Guild roster display

The guild roster currently shows "combat level" per member via a PostgREST embed.
If that column is derived from the shared path talents, update the embed to use
the new total. Confirm whether this is computed client-side or server-side:

- If client-side: update `GetTotalCombatLevel()` and the display feeds from it.
- If server-side (Supabase view or RPC): update the SQL to sum Grimoire levels
  from the `grimoire_levels` table (or equivalent) instead of the shared talent column.

---

## 4. Milestone Stat Bonuses

### 4.1 Confirmed model

Milestone stat bonuses (e.g. Warden Grimoire level 23 → DEX +1) fire from
per-Grimoire levels in `CombatXPManager`. This is already the design intent
and already the location in code — this section is a confirmation, not a change.

### 4.2 What to verify

Ensure milestone checks fire in `CombatXPManager.AddCombatXP` when a level
threshold is crossed, not on a separate poll. They should fire exactly once
per threshold, in the same call that causes the level-up.

```csharp
// Inside CombatXPManager.AddCombatXP after XP is added:
int newLevel = GetGrimoireLevel(grimoireId);
if (newLevel > previousLevel)
{
    // Check milestones for every level in the range (in case of large XP grants):
    for (int lvl = previousLevel + 1; lvl <= newLevel; lvl++)
        ApplyMilestonesForLevel(grimoireId, lvl);
}
```

### 4.3 Milestone tables (per path)

These live in the Grimoire ScriptableObjects or a companion milestone table.
The stat-scaling-combat-formulas.md character sheet mockup confirms the
expected output ("SHARPSHOT LV 31", derived stats shown). The milestone tables
themselves are not duplicated here — they belong in the Grimoire ScriptableObjects.
This spec only confirms the trigger: level-up in `CombatXPManager` fires them.

---

## 5. Slaying Talent

### 5.1 Confirmed model

Slaying is a single global mastery talent, separate from per-Grimoire combat level.
It is NOT rerouted. It stays where it is.

Slaying XP sources remain:
- Enemy kills (the `slayingXP` field on `EnemyData`)
- Elite kills (higher `slayingXP` value)
- Dungeon completion bonuses
- Quest rewards that specifically award Slaying XP

The `isKill` XP that goes to the Grimoire (25% of `slayingXP`, see Section 1.2)
is additive — the kill awards both Slaying XP (full amount) AND Grimoire XP
(25% of slaying value). These are separate, not a split.

### 5.2 Display location

Slaying displays in the Combat Tab under Character, as a standalone mastery
separate from the Grimoire level list. It is visible, not hidden. It shows
level, XP bar, and milestone unlocks (elite spawn bonus etc.) the same way
other talent tiles show.

It does NOT appear in the talent panel alongside gathering/crafting talents.
It is combat-specific and belongs on the Combat Tab.

---

## 6. Display: CombatTabUI

### 6.1 What the Combat Tab shows

```
COMBAT PROGRESSION

[Sharpshot]           Lv 45   [XP bar]
[Runeweaver]          Lv 12   [XP bar]
[Lone Wanderer]       Lv 8    [XP bar]

Total Combat Level: 65

─────────────────────────────────────────
SLAYING MASTERY

[Slaying]             Lv 23   [XP bar]
  Elite Spawn Bonus: +4%
  Dungeon Bonus XP: +8%
```

- One row per owned Grimoire, sorted by level descending.
- Equipped Grimoire is highlighted (bold name or accent color).
- XP bar shows progress toward next level.
- Total Combat Level shown as a derived sum below the Grimoire list.
- Slaying section is visually separated (divider line or card boundary).

### 6.2 What does NOT appear here

- Marksmanship, Spellcasting, Warfare — not shown anywhere.
- Per-stat breakdowns — those live on the Character Sheet tab.
- Talent milestones list — milestone bonuses are applied silently and shown
  on the Character Sheet as current stat values, not as a milestone log.

### 6.3 Level-up notification

On Grimoire level-up, fire the existing level-up notification (same as talent
level-up). Show: "Sharpshot reached level 46!" with any milestone bonus if
applicable ("DEX +1 from Sharpshot Lv 46").

---

## 7. Implementation Checklist

In order:

- [ ] `CombatMechanics`: reroute all hit/kill XP from `TalentManager.AddXP(Marksmanship/
      Spellcasting/Warfare)` to `CombatXPManager.AddCombatXP(equippedGrimoireId, amount)`
- [ ] `CombatXPManager`: confirm `AddCombatXP` fires milestone checks on level-up
- [ ] `GetTotalCombatLevel()`: implement as sum of all owned Grimoire levels
- [ ] `ZoneAccess.cs`: swap `TalentManager.GetHighestCombatTalentLevel` for `GetTotalCombatLevel()`
- [ ] Guild roster combat level: update data source to use new total
- [ ] One-time XP migration: convert banked Marksmanship/Spellcasting/Warfare XP
      to equipped Grimoire (migration flag guards re-run)
- [ ] Talent panel UI: remove Marksmanship, Spellcasting, Warfare tiles
- [ ] CombatTabUI: implement per-Grimoire level list + Slaying section per Section 6
- [ ] `implementation-status.md`: update to reflect rerouting is live
- [ ] CLAUDE.md "locked design decisions": update or remove the stale combat level section

**Deferred (cleanup pass, after zone gating is confirmed working):**
- [ ] Delete `TalentType.Marksmanship`, `TalentType.Spellcasting`, `TalentType.Warfare`
      enum values and their ScriptableObjects
- [ ] Remove `TalentManager.GetHighestCombatTalentLevel` entirely

---

## 8. Acceptance Criteria

- Equipping a Grimoire and fighting in a zone causes that Grimoire's level to
  increase from normal play, with no dev-button press required.
- Switching to a different Grimoire mid-session routes XP to the newly equipped one.
- Zone T2 unlocks when Total Combat Level (sum of all Grimoire levels) reaches 21,
  regardless of which Grimoires contributed.
- Slaying XP is awarded separately on every kill, in addition to Grimoire XP.
- Marksmanship, Spellcasting, and Warfare tiles do not appear anywhere in the UI.
- The CombatTabUI shows one row per owned Grimoire plus a separate Slaying section.
- Milestone stat bonuses (e.g. DEX +1 at Sharpshot Lv 23) fire exactly once when
  the Grimoire crosses the threshold, not on every XP award.
- A player who had banked XP in shared path talents receives that XP credited to
  their equipped Grimoire on first launch after the migration, exactly once.

---

## 9. Unequipped Grimoires Receive No XP (confirmed)

Fighting with Sharpshot equipped awards zero XP to any other Grimoire the player
owns. `AddCombatXP` targets only `PlayerState.equippedGrimoireId`. Unequipped
Grimoires level only when equipped and actively used in combat.

This is the correct model: each Grimoire represents a distinct combat identity
the player invests in deliberately. Parallel leveling would remove the choice
of which Grimoire to develop.

---

*Path: docs/combat-progression-reconcile.md*
*Implements: CombatXPManager routing, shared-talent retirement, Total Combat Level*
*source-of-truth fix, CombatTabUI display.*
*After implementation: update implementation-status.md and retire stale CLAUDE.md section.*
