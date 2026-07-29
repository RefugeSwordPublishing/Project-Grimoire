---
type: design-spec-addendum
parent: daily-weekly-quest-system.md v1.0
version: 1.0
updated: 2026-07-27
path: docs/daily-weekly-quest-system-scaling.md
purpose: Scaling addendum to the built quest system. Implement in QuestManager
         at assignment time. Does not change QuestDefinition schema or the
         assignment Edge Function structure — values are computed on the fly.
---

# Quest Scaling Addendum
## Dynamic Targets and Rewards by Player Tier and Talent Level

---

## The Problem

`QuestDefinition` stores fixed `targetCount` and `rewards[]`. Every quest currently
has `maxZoneTier = 5`, so high-tier players draw quests intended for beginners.
A level-80 Felling player drawing "Earn 1,500 Felling XP" is a trivial no-op.

This addendum specifies two fixes implemented at assignment time in `QuestManager`:

1. **Pool banding** — corrected `maxZoneTier` values so players stop drawing
   quests they have outleveled, with enough eligible quests at every tier.
2. **Dynamic value scaling** — formulas applied during `assign_quests` that
   compute scaled `targetCount` and reward amounts from player state.

Neither change requires a schema migration. `QuestDefinition` ScriptableObjects
store base values; the scaler overrides them at assignment time before writing
the `player_quests` row.

---

## 1. XP Curve Dependency

The scaling formulas for `EarnTalentXP` reference the talent XP-to-next-level
function. The rest of the system uses:

```csharp
// Mirror of whatever TalentManager.XpToNextLevel uses:
static int XpToNextLevel(int level) =>
    Mathf.FloorToInt(50f * Mathf.Pow(level, 1.6f));
```

**If `TalentManager` uses a different formula, substitute it here.**
All `EarnTalentXP` targets and rewards are expressed as fractions of
`XpToNextLevel(talentLevel)` so they automatically track the real curve.

---

## 2. Pool Banding

### 2.1 The rule

A player at zone tier T draws from quests where:
```
quest.minZoneTier <= playerTier <= quest.maxZoneTier
```

Set `maxZoneTier` so quests retire when they become trivial, not at `maxZoneTier = 5`.

### 2.2 Corrected maxZoneTier values (update all QuestDefinition assets)

| questId | minZoneTier | maxZoneTier | Reason |
|---------|------------|------------|--------|
| gather_common_herb | 1 | 3 | Trivial at T4+ |
| gather_iron_ore | 2 | 4 | Retire at T5 (players farm Mithril, not Iron) |
| gather_wolf_pelts | 3 | 5 | Relevant through T5 |
| smelt_iron_bars | 2 | 4 | Steel/Void Alloy at T5 supersedes Iron |
| tan_fox_leather | 2 | 4 | Direwolf/Drake Leather at T5 supersedes Fox |
| defeat_beasts | 1 | 5 | Beast enemies exist at every tier |
| defeat_undead | 2 | 5 | Undead exist T2 through T5 |
| defeat_void | 3 | 5 | Void enemies T3 through T5 |
| defeat_elites | 2 | 5 | Relevant at every tier above T1 |
| earn_felling_xp | 1 | 4 | Still relevant through T4 (Ironwood/Heartwood) |
| earn_runesmithing_xp | 2 | 5 | Relevant all the way to Void tier |
| sell_exchange | 1 | 5 | Always relevant |
| complete_dungeon | 2 | 5 | Dungeons exist T2 through T5 |
| defeat_zone_boss | 1 | 5 | Boss exists at every tier |
| enter_cinderpeak | 3 | 4 | Discovery quest — retire once player is T5 |

### 2.3 New QuestDefinition assets required

T1 and T5 are thin without additions. Author these as new ScriptableObjects:

| questId | type | target | minZoneTier | maxZoneTier | Notes |
|---------|------|--------|------------|------------|-------|
| defeat_arcane | DefeatEnemies | [Arcane] 20 | 1 | 3 | Fills T1 gap; Arcane enemies exist from Saltmarsh |
| gather_mithril_ore | GatherItem | Mithril Ore | 4 | 5 | T4-T5 Delving quest |
| defeat_void_elite | DefeatElites | [Void] 3 | 4 | 5 | T4-T5 targeted elite quest |
| complete_t5_dungeon | CompleteDungeon | (specific T5 dungeon) | 5 | 5 | T5-only dungeon run |
| earn_smelting_xp | EarnTalentXP | Smelting | 3 | 5 | T3-T5 Smelting quest |

### 2.4 Eligible quest count after banding

| Player tier | Daily eligible | Notes |
|------------|---------------|-------|
| T1 | 6 | Minimum viable — no room for more retirements at T1 |
| T2 | 13 | Comfortable |
| T3 | 17 | Comfortable |
| T4 | 17 | Comfortable |
| T5 | 13 | Comfortable |

T1 is the tightest. Do not reduce the T1-eligible set further without adding
new T1 quest definitions.

---

## 3. Dynamic Value Scaling

Applied in `QuestManager` at assignment time. The `QuestDefinition` base values
are used as the T1/low-level reference. The scaler computes actual values from
player state and writes them into the `player_quests` row.

### 3.1 Scaler inputs

```csharp
public struct QuestScalerInput
{
    public int playerZoneTier;         // 1-5, from playerHighestZoneTier
    public int relevantTalentLevel;    // level of the quest's targetId talent (EarnTalentXP)
    public int playerCombatLevel;      // Total Combat Level (DefeatEnemies/Boss)
    public QuestCadence cadence;       // Daily / Weekly
}
```

`relevantTalentLevel` is looked up from `TalentManager` using `quest.targetId`
when `quest.type == QuestType.EarnTalentXP`. For all other quest types pass 0.

### 3.2 EarnTalentXP: talent-level-relative scaling

This is the most important case. Target and reward both track the relevant
talent's current XP-to-next-level, ensuring the quest always represents
a meaningful fraction of a level regardless of progression stage.

```csharp
// Target: approximately 60% of one level's XP at the player's current talent level
// Rounded to nearest 50 for clean UI display
int ScaleEarnTalentXpTarget(int talentLevel) {
    int xpToNext = XpToNextLevel(talentLevel);
    return Mathf.RoundToInt(xpToNext * 0.60f / 50f) * 50;
}

// Reward: approximately 25% of one level's XP
// Rationale: earn 60% of a level to complete, receive 25% back — net 35% level progress
// for doing the quest, on top of the XP earned naturally while completing it.
int ScaleEarnTalentXpReward(int talentLevel) {
    int xpToNext = XpToNextLevel(talentLevel);
    return Mathf.RoundToInt(xpToNext * 0.25f / 50f) * 50;
}
```

**Worked examples — "Earn Felling XP" quest:**

| Felling level | XP to next | Target (60%) | Reward (25%) | Feel |
|--------------|-----------|-------------|-------------|------|
| 5 | 656 | 400 | 150 | 5-minute idle run |
| 20 | 6,034 | 3,600 | 1,500 | ~20 min at normal idle rate |
| 40 | 18,292 | 11,000 | 4,550 | Meaningful half-session |
| 60 | 34,995 | 21,000 | 8,750 | Full session of focused Felling |
| 80 | 55,451 | 33,250 | 13,850 | Appropriate stretch for a dedicated Feller |
| 100 | 79,244 | 47,550 | 19,800 | Near-cap challenge |

The old fixed target of 1,500 XP is correct at approximately Felling level 20.
It is trivial at level 40 and invisible at level 80.

**Weekly multiplier:** apply `* 3.5` to both target and reward for weekly
`EarnTalentXP` quests. This gives roughly one day of focused talent work as
the weekly target, which feels proportionate.

### 3.3 DefeatEnemies / DefeatElites: tier-relative scaling

Enemy count scales with player zone tier. The base count in the QuestDefinition
is the T1 value.

```csharp
static readonly float[] enemyCountMultiplier = { 0, 1.0f, 1.3f, 1.7f, 2.2f, 2.8f };
// index 0 unused; indices 1-5 = zone tiers

int ScaleEnemyTarget(int baseCount, int playerTier) =>
    Mathf.RoundToInt(baseCount * enemyCountMultiplier[playerTier]);
```

**Example — "Defeat [Beast] Enemies", base count 20:**

| Tier | Multiplier | Target |
|------|-----------|--------|
| T1 | 1.0 | 20 |
| T2 | 1.3 | 26 |
| T3 | 1.7 | 34 |
| T4 | 2.2 | 44 |
| T5 | 2.8 | 56 |

Combat XP reward scales by the same multiplier, applied to the base reward value.

### 3.4 DefeatBoss: fixed count, scaled reward only

Boss quests stay at `targetCount = 1` (one boss kill per quest regardless of tier).
Killing a T5 zone boss is already categorically harder than killing a T1 boss.
Scale only the reward:

```csharp
static readonly float[] bossRewardMultiplier = { 0, 1.0f, 1.6f, 2.4f, 3.5f, 5.0f };

int ScaleBossReward(int baseReward, int playerTier) =>
    Mathf.RoundToInt(baseReward * bossRewardMultiplier[playerTier]);
```

**Example — "Defeat Zone Boss", base CombatXP reward 1,000:**

| Tier | Multiplier | CombatXP reward |
|------|-----------|----------------|
| T1 | 1.0 | 1,000 |
| T2 | 1.6 | 1,600 |
| T3 | 2.4 | 2,400 |
| T4 | 3.5 | 3,500 |
| T5 | 5.0 | 5,000 |

### 3.5 GatherItem / ProcessItem / CraftItem: tier-relative scaling

Gather and process targets scale with tier. Processing targets scale more
slowly than combat because idle gathering rate also increases with better tools.

```csharp
static readonly float[] gatherCountMultiplier  = { 0, 1.0f, 1.25f, 1.6f, 2.0f, 2.5f };
static readonly float[] processCountMultiplier = { 0, 1.0f, 1.2f,  1.5f, 1.8f, 2.2f };
```

**Example — "Gather Wolf Pelts", base 10, player at T4:**
`10 * 2.0 = 20 pelts`

**Example — "Smelt Iron Bars", base 10, player at T3:**
`10 * 1.5 = 15 bars`

### 3.6 SellOnExchange / CompleteDungeon: fixed count

These are naturally self-scaling (selling at T5 is harder than at T1 because
the items are harder to produce; completing a T5 dungeon is harder than T2).
Keep `targetCount` fixed at the QuestDefinition value. Scale rewards only via
the tier multipliers in 3.8.

### 3.7 Currency (GoldMarks / SilverMarks): tier multiplier

Currency scales modestly with tier. The goal is a noticeable but not inflating
reward — high-tier players earn more GM per quest, but not dramatically so.

```csharp
static readonly float[] currencyMultiplier = { 0, 1.0f, 1.4f, 1.9f, 2.5f, 3.2f };

int ScaleCurrency(int baseAmount, int playerTier) =>
    Mathf.RoundToInt(baseAmount * currencyMultiplier[playerTier]);
```

**Example — daily quest base reward 12 GM:**

| Tier | Multiplier | GM reward |
|------|-----------|----------|
| T1 | 1.0 | 12 |
| T2 | 1.4 | 17 |
| T3 | 1.9 | 23 |
| T4 | 2.5 | 30 |
| T5 | 3.2 | 38 |

### 3.8 Summary: which scaling applies to which quest type

| Quest type | Target scaling | Reward (TalentXP/CombatXP) | Reward (currency) |
|------------|--------------|--------------------------|------------------|
| EarnTalentXP | 60% of XpToNextLevel(talentLevel) | 25% of XpToNextLevel | currencyMultiplier |
| DefeatEnemies | enemyCountMultiplier | enemyCountMultiplier | currencyMultiplier |
| DefeatElites | enemyCountMultiplier | enemyCountMultiplier | currencyMultiplier |
| DefeatBoss | fixed (1) | bossRewardMultiplier | currencyMultiplier |
| GatherItem | gatherCountMultiplier | gatherCountMultiplier | currencyMultiplier |
| ProcessItem | processCountMultiplier | processCountMultiplier | currencyMultiplier |
| CraftItem | processCountMultiplier | processCountMultiplier | currencyMultiplier |
| CompleteDungeon | fixed | bossRewardMultiplier | currencyMultiplier |
| SellOnExchange | fixed | currencyMultiplier (on GM only) | currencyMultiplier |
| ReachZone | fixed (1) | fixed | fixed |

---

## 4. Weekly Quest Scaling

Weekly quests use the same formulas with a `weeklyFactor` applied on top:

```csharp
const float weeklyFactor = 3.5f;

// Apply after tier scaling:
scaledTarget  = Mathf.RoundToInt(dailyScaledTarget * weeklyFactor);
scaledReward  = Mathf.RoundToInt(dailyScaledReward * weeklyFactor);
```

**Exception:** `EarnTalentXP` weekly target uses `* 3.5` applied to the
daily-scaled target, not to the QuestDefinition base. This ensures the weekly
always feels like "about a week of dailies" at any talent level.

---

## 5. Implementation — QuestScaler Class

```csharp
public static class QuestScaler
{
    static readonly float[] enemyMult    = { 0, 1.0f, 1.3f, 1.7f, 2.2f, 2.8f };
    static readonly float[] gatherMult   = { 0, 1.0f, 1.25f,1.6f, 2.0f, 2.5f };
    static readonly float[] processMult  = { 0, 1.0f, 1.2f, 1.5f, 1.8f, 2.2f };
    static readonly float[] bossMult     = { 0, 1.0f, 1.6f, 2.4f, 3.5f, 5.0f };
    static readonly float[] currencyMult = { 0, 1.0f, 1.4f, 1.9f, 2.5f, 3.2f };

    const float weeklyFactor = 3.5f;

    // Call this during assign_quests before writing the player_quests row.
    // Returns scaled copies; does not mutate the QuestDefinition.
    public static (int scaledTarget, QuestReward[] scaledRewards) Scale(
        QuestDefinition def,
        QuestScalerInput input)
    {
        bool isWeekly = def.cadence == QuestCadence.Weekly;
        float wf = isWeekly ? weeklyFactor : 1f;
        int tier = Mathf.Clamp(input.playerZoneTier, 1, 5);

        int scaledTarget = def.targetCount;
        QuestReward[] scaledRewards = CloneRewards(def.rewards);

        switch (def.type)
        {
            case QuestType.EarnTalentXP:
                int talentLvl = Mathf.Max(1, input.relevantTalentLevel);
                int xpNext = XpToNextLevel(talentLvl);
                scaledTarget = RoundTo50(xpNext * 0.60f * wf);
                foreach (var r in scaledRewards)
                {
                    if (r.type == QuestRewardType.TalentXP || r.type == QuestRewardType.CombatXP)
                        r.amount = RoundTo50(xpNext * 0.25f * wf);
                    else if (r.type is QuestRewardType.GoldMarks or QuestRewardType.SilverMarks)
                        r.amount = Mathf.RoundToInt(r.amount * currencyMult[tier] * wf);
                }
                break;

            case QuestType.DefeatEnemies:
            case QuestType.DefeatElites:
                scaledTarget = Mathf.RoundToInt(def.targetCount * enemyMult[tier] * wf);
                ApplyXpAndCurrencyScale(scaledRewards, enemyMult[tier] * wf, currencyMult[tier] * wf);
                break;

            case QuestType.DefeatBoss:
            case QuestType.CompleteDungeon:
                // target stays fixed
                ApplyXpAndCurrencyScale(scaledRewards, bossMult[tier] * wf, currencyMult[tier] * wf);
                break;

            case QuestType.GatherItem:
                scaledTarget = Mathf.RoundToInt(def.targetCount * gatherMult[tier] * wf);
                ApplyXpAndCurrencyScale(scaledRewards, gatherMult[tier] * wf, currencyMult[tier] * wf);
                break;

            case QuestType.ProcessItem:
            case QuestType.CraftItem:
                scaledTarget = Mathf.RoundToInt(def.targetCount * processMult[tier] * wf);
                ApplyXpAndCurrencyScale(scaledRewards, processMult[tier] * wf, currencyMult[tier] * wf);
                break;

            case QuestType.SellOnExchange:
                // target fixed; scale currency reward only
                foreach (var r in scaledRewards)
                    if (r.type is QuestRewardType.GoldMarks or QuestRewardType.SilverMarks)
                        r.amount = Mathf.RoundToInt(r.amount * currencyMult[tier] * wf);
                break;

            case QuestType.ReachZone:
                // nothing scales — target is always 1, reward is a fixed nudge
                break;
        }

        return (scaledTarget, scaledRewards);
    }

    static void ApplyXpAndCurrencyScale(QuestReward[] rewards, float xpFactor, float currFactor)
    {
        foreach (var r in rewards)
        {
            if (r.type is QuestRewardType.TalentXP or QuestRewardType.CombatXP)
                r.amount = Mathf.RoundToInt(r.amount * xpFactor);
            else if (r.type is QuestRewardType.GoldMarks or QuestRewardType.SilverMarks)
                r.amount = Mathf.RoundToInt(r.amount * currFactor);
        }
    }

    static int XpToNextLevel(int level) =>
        Mathf.FloorToInt(50f * Mathf.Pow(level, 1.6f));

    static int RoundTo50(float value) =>
        Mathf.RoundToInt(value / 50f) * 50;

    static QuestReward[] CloneRewards(QuestReward[] source)
    {
        var copy = new QuestReward[source.Length];
        for (int i = 0; i < source.Length; i++)
            copy[i] = new QuestReward { type = source[i].type, id = source[i].id, amount = source[i].amount };
        return copy;
    }
}
```

---

## 6. Where to Call the Scaler

In `QuestManager.AssignQuests()`, after drawing the quest from the pool and
before writing the `player_quests` row:

```csharp
// After drawing questDef from pool:
var input = new QuestScalerInput {
    playerZoneTier      = player.highestZoneTier,
    relevantTalentLevel = def.type == QuestType.EarnTalentXP
                          ? TalentManager.GetLevel(def.targetId)
                          : 0,
    playerCombatLevel   = player.totalCombatLevel,
    cadence             = def.cadence,
};

var (scaledTarget, scaledRewards) = QuestScaler.Scale(def, input);

// Write to player_quests using scaledTarget and scaledRewards,
// not the raw def values.
```

The `QuestDefinition` ScriptableObject is never mutated. Scaled values live
only in the `player_quests` row.

---

## 7. "10-15% of Daily XP" Check

The scaling goal is preserved because both sides of the ratio scale together:

- `EarnTalentXP` target scales with `XpToNextLevel(talentLevel)` (the denominator)
- `EarnTalentXP` XP reward is 25% of `XpToNextLevel(talentLevel)` (the numerator)
- The ratio is fixed: 25% back on a target that is 60% of a level, every day,
  across all levels.

For combat and gather quests, the enemy/gather count scales with tier while
the XP reward scales by the same multiplier, so the ratio of quest XP to zone XP
stays constant across tiers.

The only case where the ratio can drift is `ReachZone` and `SellOnExchange`,
which have fixed targets. These are designed as outliers — low-XP nudge quests,
not XP-efficiency quests — so flat behavior is correct.

---

## 8. Acceptance Criteria

- A Felling-80 player drawing "Earn Felling XP" gets a target near 33,000 XP,
  not the base 1,500.
- A T5 player drawing "Defeat [Beast] Enemies" gets a target near 56 enemies,
  not the base 20.
- A T1 player drawing any quest gets the base QuestDefinition values unchanged
  (all multipliers at tier 1 are 1.0).
- Weekly quests have targets and rewards approximately 3.5x the daily equivalent
  at the same player state.
- `QuestDefinition` ScriptableObjects are never mutated — scaling is applied
  only at assignment time.
- `XpToNextLevel` in `QuestScaler` must match `TalentManager.XpToNextLevel`
  exactly. If they diverge, `EarnTalentXP` scaling breaks. Add a unit test
  asserting the two return the same value for levels 1, 20, 50, 100.

---

*Path: docs/daily-weekly-quest-system-scaling.md*
*Addendum to daily-weekly-quest-system.md v1.0.*
*Implement in QuestManager and QuestScaler. Update QuestDefinition maxZoneTier*
*values on all existing assets per Section 2.2. Author 5 new QuestDefinition*
*assets per Section 2.3.*
