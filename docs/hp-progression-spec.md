---
type: design-spec
version: 1.0
updated: 2026-08-28
path: docs/hp-progression-spec.md
resolves: hp-progression-REQUEST.md
implements: PlayerData.GetMaxHP, player_stat_bonuses VIT milestones,
            HPPoolMultiplier per Grimoire, ResolveEnemyAttack mitigation cap
companion: stat-scaling-combat-formulas.md, combat-balance-reconcile.md
---

# HP and Survivability Progression
### Version 1.0

---

## 1. The Diagnosis

Enemy damage grows roughly sixfold from T1 to T5. Player max HP grows only through gear VIT, a handful
of milestones, and meals. Base VIT is seeded at 1 and never moves, so the `totalVIT * 4` term in
`GetMaxHP` is doing almost nothing and the formula is in practice `50 + 7 * (VITBonus + VITEquip)`.

That means survivability is entirely a gear function while difficulty is a content function, and the two
are not coupled. A player who has just unlocked T3 by hitting Total Combat Level 51 is fighting enemies
that hit for 18 to 35 on whatever HP their current gear happens to give them, which may be very little.

Two paths make it worse. Warden and Arcanist receive zero VIT milestones, so they gain no permanent HP
at all across an entire game's progression.

The fix has three parts, in order of importance:

1. A baseline HP term driven by Total Combat Level, so survivability is coupled to the same number that
   gates content.
2. VIT milestones for every path, weighted by identity rather than granted only to one.
3. HPPoolMultiplier per Grimoire, so tankiness is a legible identity rather than an accident of which
   armour type a class happens to wear.

---

## 2. Stage Plan

| Stage | Scope | Risk |
|---|---|---|
| 1 | Baseline HP term, VIT normalization in `GetMaxHP` | Low, one formula |
| 2 | Per-Grimoire `HPPoolMultiplier` table | Low, one lookup |
| 3 | VIT milestones for Warden and Arcanist, rebalanced for Vanguard | Low, data only |
| 4 | Mitigation cap, revive percentage, healing consumable rescale | Medium, touches combat and items |

Stages 1 to 3 are the survivability fix. Stage 4 is the set of adjacent problems the fix exposes, listed
in section 8. Stage 4 can lag but should not be skipped.

---

## 3. Stage 1, The Baseline

### 3.1 What drives it: Total Combat Level

Total Combat Level already gates every zone tier. If it gates the content, it should gate the
survivability that content assumes. That coupling is the whole point, and it is why TCL beats the
alternatives:

**Not a Vitality talent line.** Opt-in, so the players who most need a safety net, the new and the
casual, are exactly the ones who will not train it. It also adds a seventeenth talent to a game that
already asks a lot of the talent screen.

**Not per-Grimoire combat level.** A player with one Grimoire at 90 and a player with three at 30 both
stand at the same content gate. Keying HP to per-Grimoire level would give them different survivability
for the same fight, which is exactly the inconsistency this spec exists to remove.

**Not flat HP per tier band.** A step function means a player at TCL 50 and one at TCL 51 have very
different HP for the sake of a band boundary they cannot see.

### 3.2 The formula

```csharp
// PlayerData.GetMaxHP()
// baselineHP couples survivability to the stat that gates content.
// VIT is now worth the same regardless of source. See section 3.4.
int totalVIT = baseVIT + VITBonus + VITEquip;
float raw    = 50f + (TotalCombatLevel * 2.5f) + (totalVIT * 6f);
maxHP        = Mathf.RoundToInt(raw * HPPoolMultiplier);
```

Two changes from as-built: the `TotalCombatLevel * 2.5f` term is new, and the three separate VIT terms
collapse into one at a flat multiplier.

### 3.3 Why 2.5

Solved against the enemy damage curve so that baseline HP alone, with no gear at all, holds roughly nine
raw hits at every tier.

| Tier | TCL band midpoint | Enemy avg damage | Baseline HP | Raw hits to die |
|---|---|---|---|---|
| T1 | 15 | 8.0 | 88 | 10.9 |
| T2 | 35 | 16.0 | 138 | 8.6 |
| T3 | 70 | 26.5 | 225 | 8.5 |
| T4 | 115 | 37.0 | 338 | 9.1 |
| T5 | 170 | 48.5 | 475 | 9.8 |

Flat with a gentle rise at the top. The rise is deliberate: progression should feel like getting
tougher, not like running to stand still.

The linear term works because both Total Combat Level and enemy damage climb roughly linearly across the
game. That is a happy accident of the existing curves and it means no lookup table is needed here.

### 3.4 Normalizing the VIT double-count

Normalize it. Today base VIT is worth 4 HP and bonus or equipment VIT is worth 7, because `totalVIT`
already contains bonus and equipment before the extra `* 3` terms are added. That is an accident of how
the expression was written, not a design.

Keeping it costs more than it buys. Base VIT is seeded at 1 and never grows, so the inconsistency is
currently invisible, which is precisely why it will bite: the first time anything grants base VIT, it
will silently be worth 43 percent less than the same point from a meal, and whoever balances that will
not know why.

Flat 6 HP per VIT point preserves about 86 percent of current gear HP value. The new baseline term more
than covers the difference at every tier, so no build gets weaker.

---

## 4. Stage 2, Per-Grimoire Tank Identity

`HPPoolMultiplier` becomes a per-Grimoire value rather than a Lifebinder special case.

| Grimoire | Path | Multiplier | Identity |
|---|---|---|---|
| Warlord | Vanguard | 1.25 | The tank. Highest baseline pool. |
| Bulwark subclass | Vanguard | 1.40 | Tank subclass, applied in place of 1.25 |
| Shadowblade | Vanguard | 1.00 | Vanguard frame, rogue survivability |
| Sharpshot | Warden | 1.00 | The reference point |
| Lone Wanderer | Warden | 0.95 | Fastest and most mobile, thinnest Warden |
| Runeweaver | Arcanist | 0.90 | Squishiest, leans on range |
| Summoner | Arcanist | 0.90 | Constructs absorb, own effectiveHP path unchanged |
| Lifebinder | Arcanist | 1.60 | Unchanged. HP is the casting resource. |

The spread from 0.90 to 1.40 is deliberate and modest. A wider spread would make Arcanist builds
unplayable at the top tiers, where a single T5 swing is 33 to 64. The real differentiation between paths
is mitigation and avoidance, not the pool, which is section 5.

Bulwark replaces the Warlord multiplier rather than stacking with it.

---

## 5. Stage 3, Survivability Identity Across the Three Paths

Survivability is HP times mitigation times avoidance. Each path should win one of the three and lose
another, which keeps all three viable without any of them being safest.

| Path | HP pool | Mitigation | Avoidance | Net identity |
|---|---|---|---|---|
| Vanguard | Highest | Highest, Plate | Lowest | Absorbs everything, slowly |
| Warden | Middle | Middle, Leather | Highest, evasion | Takes fewer hits |
| Arcanist | Lowest | Lowest, Vestments | Middle, shields and range | Takes fewer hits differently |

No change to how defense or evasion are computed is proposed in this pass, with one exception in section
8.1. The armour rating tier bonuses already encode the mitigation half of this table: Plate 50 at T5,
Leather 35, Vestment 22.

### 5.1 VIT milestones for every path

Currently only Vanguard receives VIT, at Lv 47 and Lv 81. Every path gets a ladder, weighted by
identity. These write to `player_stat_bonuses` and are permanent and cross-path, as today.

| Path | Milestones | Total VIT |
|---|---|---|
| Vanguard | Lv 23 +1, Lv 47 +2, Lv 61 +2, Lv 81 +3 | 8 |
| Warden | Lv 31 +1, Lv 61 +1, Lv 85 +2 | 4 |
| Arcanist | Lv 39 +1, Lv 73 +2 | 3 |

At 6 HP per point that is 48, 24, and 18 HP before the pool multiplier. Small in absolute terms, which
is correct: milestones are flavour and identity, the baseline is the safety net, and gear is the
aspirational lever. Section 6 shows the split.

---

## 6. Layering

How the four sources compose, for a fully geared T5 Warlord:

| Source | HP contributed | Share |
|---|---|---|
| Baseline, Total Combat Level | 475 | 44 percent |
| Gear VIT | 540 | 51 percent |
| Milestone VIT | 48 | 4 percent |
| Base VIT | 6 | 1 percent |
| Subtotal before multiplier | 1,069 | |
| After 1.25 multiplier | **1,336** | |

Gear stays the largest single contributor, so chasing better armour still matters more than anything
else. The baseline is large enough that an undergeared player at the right Total Combat Level is not
fighting on a T1 pool, which is the entire complaint.

Meals sit on top as temporary VIT, unchanged, and are worth 6 HP per point like every other source. A
meal granting +10 VIT is +60 HP before the multiplier, which reads as meaningful at T1 and as a top-up
at T5. That decay is correct: meals should be a real decision early and a convenience later.

---

## 7. Numbers Pass

Assumptions stated so they can be checked: enemy average damage is the midpoint of the tier band,
mitigation lets through 45 percent of raw for Vanguard, 60 for Warden, 65 for Arcanist, and enemy swings
connect 78, 58, and 70 percent of the time respectively. Representative gear VIT is 10 at T1, 45 at T3,
90 at T5.

**T1, enemy average damage 8.0**

| Grimoire | Max HP | Raw hits to die | Effective damage per swing | Swings to die |
|---|---|---|---|---|
| Warlord | 192 | 24.0 | 2.8 | 68 |
| Bulwark | 215 | 26.9 | 2.8 | 77 |
| Shadowblade | 154 | 19.2 | 2.8 | 55 |
| Sharpshot | 154 | 19.2 | 2.8 | 55 |
| Lone Wanderer | 146 | 18.2 | 2.8 | 52 |
| Runeweaver | 138 | 17.2 | 3.6 | 38 |
| Summoner | 138 | 17.2 | 3.6 | 38 |
| Lifebinder | 246 | 30.8 | 3.6 | 68 |

**T3, enemy average damage 26.5**

| Grimoire | Max HP | Raw hits to die | Effective damage per swing | Swings to die |
|---|---|---|---|---|
| Warlord | 664 | 25.1 | 9.3 | 71 |
| Bulwark | 743 | 28.0 | 9.3 | 80 |
| Shadowblade | 531 | 20.0 | 9.3 | 57 |
| Sharpshot | 513 | 19.4 | 9.2 | 56 |
| Lone Wanderer | 487 | 18.4 | 9.2 | 53 |
| Runeweaver | 456 | 17.2 | 12.1 | 38 |
| Summoner | 456 | 17.2 | 12.1 | 38 |
| Lifebinder | 811 | 30.6 | 12.1 | 67 |

**T5, enemy average damage 48.5**

| Grimoire | Max HP | Raw hits to die | Effective damage per swing | Swings to die |
|---|---|---|---|---|
| Warlord | 1,336 | 27.5 | 17.0 | 79 |
| Bulwark | 1,497 | 30.9 | 17.0 | 88 |
| Shadowblade | 1,069 | 22.0 | 17.0 | 63 |
| Sharpshot | 1,045 | 21.5 | 16.9 | 62 |
| Lone Wanderer | 993 | 20.5 | 16.9 | 59 |
| Runeweaver | 935 | 19.3 | 22.1 | 42 |
| Summoner | 935 | 19.3 | 22.1 | 42 |
| Lifebinder | 1,662 | 34.3 | 22.1 | 75 |

### Reading the tables

**Raw hits to die stays in a 17 to 34 band at every tier.** That is the number that answers the original
complaint. Today it would fall steadily across tiers for anyone without top gear, and for Warden and
Arcanist it would fall regardless.

**The path spread is consistent and legible.** Warlord holds roughly 40 percent more raw damage than
Runeweaver at every tier, and Bulwark roughly 60 percent more. A player can feel that without reading a
number.

**Runeweaver and Summoner are the floor at 38 to 42 swings.** That is thin but not unviable, and it is
the correct consequence of choosing the squishiest frame. Their answer is shields, range, and killing
things faster, not a bigger pool. If playtesting shows 38 swings is genuinely too fragile, the lever is
Arcanist mitigation or shield strength, not the multiplier, because raising the multiplier erases the
identity.

**Lifebinder sits near Warlord,** which is correct given HP is their casting resource. They are spending
that pool constantly, so a large number on the character sheet does not translate into a large number in
practice.

---

## 8. Things Wrong Beyond The Brief

**8.1 Mitigation is uncapped and will eventually zero out damage.** `finalDamage = max(1, rawDamage -
playerDefense * 0.4)` is linear with no ceiling. A geared T5 player with several hundred defense
subtracts more than any enemy in the game deals, and every hit lands for the floor of 1. At that point
HP, tiers, and this entire spec stop mattering. Cap it:

```csharp
float mitigated = Mathf.Min(playerDefense * 0.4f, rawDamage * 0.75f);
finalDamage     = Mathf.Max(1f, rawDamage - mitigated);
```

A 75 percent ceiling keeps defense valuable while guaranteeing a quarter of every swing lands. This is
the single most important item in this section and it may already be live in a mild form. Verify before
shipping the baseline, because a bigger HP pool on top of uncapped mitigation makes the player immortal
rather than durable.

**8.2 The 10 percent revive is punishing at high tiers and gets worse as HP grows.** A revived T5
Warlord stands up with 134 HP against enemies swinging for 33 to 64. That is two to four hits, in a
fight they have already lost once, with no out-of-combat regen to recover. Recommend 25 percent plus two
seconds of post-revive immunity. The immunity matters more than the percentage, because without it the
player can be hit during the revive animation.

**8.3 Healing consumables must be rescaled alongside this.** A Crude Healing Draught restoring a fixed
amount is a full heal at T1 and a rounding error against 1,336 HP. Either scale healing items by tier,
or make them restore a percentage of max HP. Percentage is simpler and keeps the item list from
tripling. This is the largest knock-on and it belongs in Stage 4.

**8.4 Evasion appears to be rolled twice.** `hitChance = clamp(accuracy - evasion, 5, 95)` and then a
second evasion roll. If both are live, evasion is worth roughly double its face value and Warden
survivability is already higher than any table suggests. Confirm whether the second roll is intentional.
If it is, the Warden mitigation figures in section 7 are conservative and Warden may not need the
milestone VIT proposed in 5.1.

**8.5 I could not verify the mitigation assumptions.** The armour rating quality table was not in the
brief, only the tier bonuses. The 45, 60, and 65 percent figures in the numbers pass are design targets,
not measurements. Send the armour rating quality table and I will recompute the swings-to-die column
against real defense values. The max HP column is unaffected.

**8.6 Summoner's separate effectiveHP path needs a decision.** Constructs form the pool, which means the
baseline term and the pool multiplier may apply to the wrong number for that Grimoire. Either the
baseline flows into construct HP, or Summoner opts out of the baseline and gets construct scaling
instead. The second is more honest to the fantasy but needs its own small table. Flagged rather than
solved, since the brief listed it as a special case rather than a target.

---

## 9. Acceptance Criteria

- `GetMaxHP` includes a `TotalCombatLevel * 2.5` term inside the pool multiplier.
- All VIT is worth 6 HP per point regardless of source. No source is weighted differently.
- A player at Total Combat Level 51 with no gear has at least 175 max HP.
- `HPPoolMultiplier` is read from a per-Grimoire table, not hardcoded per class.
- Warden and Arcanist each receive at least one permanent VIT milestone before Lv 40.
- Meal VIT still stacks on top and is worth the same per point as gear VIT.
- Raw hits to die for a representative build stays between 17 and 35 at T1, T3, and T5.
- No path falls below 35 swings to die against a tier-appropriate standard enemy.
- Mitigation is capped so at least 25 percent of every raw hit lands.
- No change to STR, DEX, INT, WIL, or LCK, and no new stat is introduced.

---

*Path: docs/hp-progression-spec.md*
*Baseline HP driven by Total Combat Level at 2.5 per level, VIT normalized to 6 per point,*
*per-Grimoire pool multipliers from 0.90 to 1.40 with Lifebinder unchanged at 1.60,*
*VIT milestones for all three paths. Mitigation cap and revive percentage flagged as*
*adjacent problems the fix exposes.*
