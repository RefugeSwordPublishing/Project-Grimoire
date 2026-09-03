---
type: design-spec
version: 1.0
updated: 2026-08-31
path: docs/combat-attack-speed-spec.md
resolves: combat-attack-speed-REQUEST.md
implements: WeaponSpeed table, CombatManager player interval derivation,
            EnemyData.attackCadence authoring, CombatTick evaluator
companion: stat-scaling-combat-formulas.md, combat-balance-reconcile.md
scope: data and formula layer, no rewrite of the real-time loop
---

# Combat Attack Speed
### Version 1.0

---

## 1. Weapon Type Speed and Damage

### 1.1 The table

```csharp
// Assets/Scripts/Data/WeaponSpeed.cs
// speedFactor multiplies the base interval. damageFactor multiplies the
// weapon's own damage band, nothing else. See section 1.3.
const float BASE_ATTACK_INTERVAL = 2.0f;
```

| Weapon | Speed factor | Interval | Damage factor | DPS index | Feel |
|---|---|---|---|---|---|
| Dagger | 0.70 | 1.40s | 0.74 | 1.057 | Fast |
| Wand | 0.80 | 1.60s | 0.83 | 1.037 | Brisk |
| Sword | 0.95 | 1.90s | 0.96 | 1.011 | Steady |
| Bow | 1.00 | 2.00s | 1.00 | 1.000 | Steady |
| Staff | 1.15 | 2.30s | 1.13 | 0.983 | Weighty |
| Axe | 1.25 | 2.50s | 1.20 | 0.960 | Heavy |

The interval spread is 1.40s to 2.50s, which is a 1.79x range. That is wide enough to feel
immediately different in the hand and narrow enough that no type is unusable.

### 1.2 Why the DPS index is not flat

Perfect inverse compensation would set `damageFactor = speedFactor` and give every type
identical DPS. That is safe and it makes speed purely cosmetic, which defeats the request.

The table instead gives fast weapons a small paper DPS edge, about 10 percent from Axe to
Dagger. The reason is that **critical hits and weak points multiply per-hit damage**, so
heavy weapons already extract more from every crit, every weak-point hit, and every ability
ring multiplier. A 100 damage Axe swing that crits at 1.6x gains 60. A 62 damage Dagger
swing gains 37. Give both types identical base DPS and the Axe wins every crit-focused build
outright.

The 10 percent paper edge to fast weapons is the counterweight. In practice the two
converge, and which one is ahead depends on how much of a build's damage flows through
multipliers rather than through base hits.

If playtesting shows this reads as fast weapons being strictly better, the fix is one
column: set `damageFactor` equal to `speedFactor` and accept flat DPS.

### 1.3 How the interval derives

```csharp
float PlayerAttackInterval()
{
    var weapon = Equipment.GetEquipped(Slot.Weapon);
    float factor = weapon != null
        ? WeaponSpeed.SpeedFactor[weapon.weaponType]
        : 1.0f;                                  // unarmed falls back to base
    return BASE_ATTACK_INTERVAL * factor;
}
```

Recompute on equip change, not per frame. The existing attack timer and its bar consume the
value as they do today, so nothing about the timer or its rendering changes. A player
swapping from an Axe to a Dagger sees the bar start filling faster on the next swing.

Any future haste or slow effect multiplies on top of this result, exactly as enemy slows
already multiply `attackCadence`.

### 1.4 Where the damage factor applies, and what it must not touch

Weapon type already grants two things: a favored primary and secondary stat, and an accuracy
bonus. Speed is a third channel and it must stay orthogonal to both.

```csharp
// Correct. The type factor scales the weapon's own band only.
int   bandRoll = EquipmentStats.WeaponDamage(quality, materialTier).Roll();
float typed    = bandRoll * WeaponSpeed.DamageFactor[weapon.weaponType];
float attack   = (effStat * 1.2f) + typed + statEquip;
```

**Do not multiply total attack by the damage factor.** The favored-stat channel already
credits the weapon for the stat it grants. Scaling the whole attack value would scale that
stat contribution a second time, which means a Dagger's own DEX grant would come back
reduced by the Dagger's own damage factor. That is the double-count to avoid.

**Do not touch `WeaponAccuracyBonus`.** Accuracy is a separate axis and section 4.1 covers
how the two should relate.

One consequence worth stating plainly. Because the factor scales only the weapon band, its
absolute effect grows with gear tier: at T1 the band is a small part of total attack and the
stat term dominates, while at T5 the band dominates. Weapon type choice therefore matters
more the more a player has invested in weapons, which is the right direction. The interval
difference is felt identically at every tier regardless, because 1.40s against 2.50s is
obvious on the first swing.

### 1.5 Worked example, T3 Refined

Weapon band before type scaling is 59 to 83.

| Weapon | Scaled band | Mid | Interval | DPS |
|---|---|---|---|---|
| Dagger | 44 to 61 | 52.5 | 1.40s | 37.5 |
| Wand | 49 to 69 | 59.0 | 1.60s | 36.9 |
| Sword | 57 to 80 | 68.5 | 1.90s | 36.1 |
| Bow | 59 to 83 | 71.0 | 2.00s | 35.5 |
| Staff | 67 to 94 | 80.5 | 2.30s | 35.0 |
| Axe | 71 to 100 | 85.5 | 2.50s | 34.2 |

Dagger against Sword and Wand against Staff both land where the request asked: the faster
one hits noticeably less per swing, swings noticeably more often, and ends up marginally
ahead on sustained damage before crits enter the picture.

---

## 2. Enemy Cadence Authoring

### 2.1 The bands

Baseline stays 2.8s. Author against these bands rather than picking freely.

| Role | Cadence band | As a share of baseline |
|---|---|---|
| Standard | 2.1s to 3.4s | 75 to 121 percent |
| Elite | 1.8s to 3.2s | 64 to 114 percent |
| Boss | 1.6s to 2.6s | 57 to 93 percent |

Hard floor 1.6s and hard ceiling 3.6s. Below the floor the attack-timer bar is unreadable on
a phone and the player cannot react. Above the ceiling the enemy reads as broken rather than
slow.

Standard enemies span roughly a 1.6x range, which is the same order as the weapon spread and
is what "noticeable but not by a large margin" means in practice.

### 2.2 Archetypes

| Archetype | Cadence | Damage relationship | Reads as |
|---|---|---|---|
| Skirmisher | 2.1 to 2.4s | Low per hit | Harrying, chip damage, hard to ignore |
| Standard | 2.6 to 2.9s | Mid | The reference enemy |
| Caster | 2.9 to 3.2s | Mid, telegraphed | Windows to punish between casts |
| Brute | 3.2 to 3.4s | High per hit | Slow and dangerous, dodgeable |
| Construct | 2.8 to 3.4s | High, blockable | Mechanical, metronomic |

The pairing rule matters more than the numbers. **A fast enemy must hit for less and a slow
enemy must hit for more.** A fast, hard-hitting enemy has no counterplay on mobile, and a
slow, weak one is ignorable. If an enemy sits at 2.1s, its damage band belongs at the bottom
of its tier.

### 2.3 Examples against enemies already authored

| Enemy | Tier | Archetype | Cadence |
|---|---|---|---|
| Forest Wolf | T1 | Skirmisher | 2.2s |
| Grimwood Brigand | T1 | Standard | 2.7s |
| Grimwood Bear | T1 | Brute | 3.3s |
| Saltmarsh Corsair | T1 | Skirmisher | 2.3s |
| Bogwalker Skeleton | T2 | Standard | 2.8s |
| Mountain Golem | T2 | Construct | 3.3s |
| Void Shade | T3 | Skirmisher | 2.1s |
| Cinderpeak Drake | T3 | Standard | 2.6s |
| Lava Construct | T3 | Construct | 3.0s |
| Reality Shade | T4 | Skirmisher | 2.1s |
| Citadel Automaton | T4 | Construct | 3.2s |
| Corruption Titan | T4 | Brute | 3.4s |
| World Golem | T5 | Brute | 3.4s |
| Void Titan | T5 | Brute | 3.2s |

Several enemies already carry authored cadences from the content briefs. Where an existing
value sits outside these bands, the band wins and the value moves. The Veil Stalker at 1.6s
is an elite and belongs at 1.8s under this model.

### 2.4 Bosses sit inside the band, and enrage moves them

Bosses author a base cadence in the 1.6s to 2.6s band. They are fast by default because a
boss fight is sustained pressure rather than a single dangerous swing, and because a boss
swinging every 3.4s gives a player too much free time to heal.

**Enrage phases multiply the base cadence down**, floored at 1.6s:

```csharp
float BossCadence(BossData boss, int phase)
    => Mathf.Max(1.6f, boss.attackCadence * boss.phaseCadenceMultiplier[phase]);
```

A boss at 2.4s with a Phase 3 multiplier of 0.75 lands at 1.8s. This matches how the T3 to
T5 boss specs already describe their phases, so those documents need no change, only the
multiplier authored where the text says the boss speeds up.

---

## 3. Tick Model

### 3.1 Decision: keep attack timers continuous, add a 250ms evaluation tick

A full tick conversion would be a rewrite and the constraint forbids one. It would also
damage the thing the request most wants: quantizing attack intervals to a tick would round
the 1.40s Dagger and the 1.60s Wand toward the same bucket unless the tick were very fine,
which is exactly the distinction being introduced.

So attack timers, both player and enemy, stay continuous and their bars keep rendering
exactly as they do now.

Everything that is a **check** rather than a swing moves onto a fixed **250ms combat tick**.

### 3.2 Why 250ms

Four evaluations per second is fast enough that auto-eat never feels late, since the worst
case delay between crossing a threshold and drinking is a quarter second. It is coarse
enough to be cheap on a phone at 240 evaluations per minute. And it divides evenly into one
second, so per-second effects land on every fourth tick with no drift.

### 3.3 What runs on the tick

| System | Behaviour on tick |
|---|---|
| Auto-eat and auto-drink | Threshold checked every tick, consume gated by cooldown, section 3.4 |
| Damage over time | Accumulated per tick at one quarter of the per-second rate, applied and displayed every fourth tick |
| HP and mana regen | Same, accumulated per tick, applied every fourth tick |
| Slow and buff durations | Decremented by 0.25s per tick |
| Weak-point window state | Opened and closed on tick boundaries |
| Zone event windows | Opened and closed on tick boundaries |

DoT and regen accumulate per tick but surface once per second so floating combat text stays
readable. A 12 damage per second DoT ticks 3 damage internally four times and shows one 12.

### 3.4 What does not run on the tick

Player attack timer, enemy attack timers, the bowstring draw, the constellation trace, and
the Vanguard combo window all stay continuous. These are all things the player is watching
or holding, and quantizing them would be felt as input lag.

### 3.5 Auto-eat under the tick model

This is the piece the request specifically asks for.

```csharp
// Evaluated every tick. Cooldown is in ticks, not seconds.
const int AUTO_CONSUME_COOLDOWN_TICKS = 8;     // 2.0s, unchanged pacing

void OnCombatTick()
{
    if (_ticksSinceConsume < AUTO_CONSUME_COOLDOWN_TICKS) { _ticksSinceConsume++; return; }
    float pct = CurrentHP / MaxHP;
    if (pct <= AutoEatThreshold(playerTier))    // 30 / 40 / 70 percent
    {
        if (TryConsumeBestDraught()) _ticksSinceConsume = 0;
    }
}
```

The pacing between consumes is unchanged at 2.0 seconds, which is what keeps the potion
economy where it is. What changes is the **latency to the first consume**: today a flat 2.0s
delay means the player can sit below the threshold for up to two full seconds while an enemy
swings again. Under the tick model the first drink lands within 250ms of crossing.

That is a real improvement in how auto-eat feels and it costs one evaluator.

### 3.6 The bars keep reading smoothly

Nothing about the attack timer bars changes, because the attack timers did not move.

Bars for tick-driven effects, meaning DoT duration and buff duration, interpolate between
tick boundaries for display while their authoritative state updates on the tick. A 250ms
step is below the threshold where a filling bar reads as stuttering, so linear interpolation
is sufficient and no smoothing curve is needed.

---

## 4. Interaction and Balance

### 4.1 Speed against accuracy

`WeaponAccuracyBonus` already exists per type. Speed must not stack with it in the same
direction or the fast types win both axes.

**Standing rule: no weapon type may sit in the top third of both speed and accuracy.**

The natural pairing is that heavy weapons are more accurate, since a committed swing is
better aimed than a flurry. If the current authored accuracy values put Dagger at the top of
both, move Dagger's accuracy down rather than moving its speed.

This spec does not change any accuracy value. It states the constraint so the next person to
tune one does not break the balance by accident.

### 4.2 Speed against the favored stat

No interaction, by construction. The favored stat is granted by the weapon and feeds attack
through the stat term. The damage factor scales only the weapon band. The two channels never
touch, which is the whole reason section 1.4 restricts where the factor applies.

### 4.3 Show speed on the item card

Yes. It now changes how the weapon plays and hiding it would make weapon choice feel arbitrary.

**On the card, show a word.** Fast, Brisk, Steady, Weighty, Heavy, from the table in section
1.1. A word scans in a grid at a glance and does not imply false precision.

**On the detail view, show the interval and the trade.** For example: "Attacks every 1.40s.
Lower damage per hit." Naming the tradeoff on the same line prevents a player reading Fast as
strictly better.

Speed is a property of the weapon type, not the instance, so it does not vary by quality or
tier and should render in the type line rather than the stat block.

### 4.4 The PvE guardrail that actually matters

The stated worry is a fast weapon plus auto-eat trivializing content. Working through it,
that specific combination is less dangerous than it looks, and a different one is worse.

**Why fast weapon plus auto-eat is not the problem.** A faster player weapon does not reduce
incoming damage. Enemies swing on their own independent cadence, so the damage the player
takes per second is unchanged by what they are holding. A Dagger shortens the fight, which
reduces total damage taken over the fight, but the 2.0s consume cooldown and the potion count
are both untouched by weapon speed. The lever is fight duration, and a 10 percent DPS spread
moves it by about 10 percent.

**The real exposure is on-hit effects.** Anything that rolls per swing pays out 1.79 times as
often on a Dagger as on an Axe. Weak-point crit chance, Slaying procs, weapon coatings, and
any future on-hit effect all fall into this. Left unnormalized, fast weapons would not be 10
percent better, they would be dominant for every proc-based build.

**Standing rule, and the most important line in this document:**

```csharp
// Any per-swing proc must be normalized against the base interval,
// so procs per second are independent of weapon speed.
float effectiveProcChance = baseProcChance * (attackInterval / BASE_ATTACK_INTERVAL);
```

A 20 percent proc on a 2.0s baseline becomes 14 percent on a 1.40s Dagger and 25 percent on a
2.50s Axe. Procs per second come out equal, and the weapon speed choice stays a feel choice
rather than a build requirement.

Apply this to weak-point crit chance, coating application, and every Slaying proc at the
point this ships, not afterwards.

**Idle mode needs no separate guardrail.** Idle auto-fires on timer fill, so a Dagger idles
faster, and the existing 0.80 idle damage multiplier already taxes idle output. Weapon speed
applies identically in idle and active, and active play stays ahead because of the multiplier
rather than because of the interval.

---

## 5. Open Point Worth Raising

**Warden has no weapon speed choice.** The path mapping gives Bow to Warden, Staff and Wand
to Arcanist, and Sword, Dagger, and Axe to Vanguard. Arcanist gets a real decision between a
1.60s Wand and a 2.30s Staff. Vanguard gets three options spanning 1.40s to 2.50s. Warden
gets one weapon at exactly the baseline and therefore gets nothing from this system.

That is a content gap rather than a design flaw in the model, and it does not block shipping.
The natural fix later is a second bow archetype, a shortbow at roughly 1.65s with a lower
band and a longbow at roughly 2.35s with a higher one, which would use the existing table
with two new `WeaponType` values and no new mechanics.

Flagging rather than solving, since adding a weapon type touches item authoring, the
constellation and bowstring mechanics, and the art tracker.

---

## 6. Implementation Summary

| Change | Where | Kind |
|---|---|---|
| `WeaponSpeed.SpeedFactor` and `DamageFactor` tables | New static data | Data |
| Player interval derived from equipped weapon | `CombatManager` | Formula |
| Damage factor applied to the weapon band roll only | Damage resolution | Formula |
| `attackCadence` reauthored to the section 2 bands | `EnemyData` assets | Data |
| Boss `phaseCadenceMultiplier` | `BossData` | Data |
| 250ms combat tick evaluator | New, small | System |
| Auto-eat moved onto the tick with an 8 tick cooldown | Auto-eat logic | Formula |
| DoT, regen, durations moved onto the tick | Effect resolution | Formula |
| Proc normalization against base interval | Every per-swing proc | Formula |
| Speed word on the item card, interval on detail | Item UI | UI text |

No change to the attack timer, the timer bars, the bowstring mechanic, the constellation
mechanic, the combo window, or the damage band tables.

---

## 7. Acceptance Criteria

- Equipping each of the six weapon types produces the interval in the section 1.1 table.
- Unarmed falls back to 2.0s.
- The type damage factor scales the weapon damage band only and never the stat contribution.
- Swapping weapon type changes neither the favored stat grant nor the accuracy bonus.
- Measured DPS across the six types at equal quality and tier stays within a 12 percent band.
- No standard enemy has a cadence below 2.1s or above 3.4s.
- No enemy of any kind has a cadence below 1.6s or above 3.6s.
- Every enemy at the fast end of its band sits at the low end of its tier damage range.
- Boss cadence is authored inside 1.6s to 2.6s, with enrage applied as a multiplier floored
  at 1.6s.
- The combat tick runs at 250ms and drives auto-eat, DoT, regen, and durations.
- Attack timers and their bars remain continuous and visually unchanged.
- Auto-eat triggers within 250ms of crossing its threshold and cannot consume more often
  than once per 2.0s.
- Every per-swing proc chance is normalized by `attackInterval / 2.0`.
- The item card shows a speed word and the detail view shows the interval and the tradeoff.

---

*Path: docs/combat-attack-speed-spec.md*
*Six weapon types spanning 1.40s to 2.50s with a 10 percent DPS gradient favoring speed to*
*offset crit scaling. Enemy cadence banded 2.1s to 3.4s for standards, bosses 1.6s to 2.6s.*
*Attack timers stay continuous; a 250ms tick drives auto-eat, DoT, regen, and durations.*
*Per-swing procs must be normalized by interval or fast weapons dominate.*
