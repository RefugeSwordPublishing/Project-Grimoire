---
type: design-spec
version: 1.0
updated: 2026-07-31
path: docs/combat-balance-reconcile.md
implements: BowstringMechanic, WardenBowstringMechanic, PlayerData.GetRangedAttack,
            CombatMechanics, CreateZoneEnemies (zone-1 defense values)
companion: stat-scaling-combat-formulas.md, combat-balance-reconcile-REQUEST.md
---

# Combat Balance Reconcile
### Version 1.0

Resolves the five design questions in `combat-balance-reconcile-REQUEST.md`
and the one clear bug. Implement these in one pass; the multiplier stacking
is the root cause of the level-13 2-shot issue and must all be fixed together.

---

## 1. The One Bug (fix first, independently if needed)

`PlayerData.GetRangedAttack()` double-counts DEX equipment bonus:

```
current: (effDEX incl. DEXEquip) × 1.2 + bowRoll + DEXEquip
```

Equipment DEX enters the ×1.2 multiplier AND is added flat again. This makes
equipment DEX worth approximately ×2.2 rather than ×1.0 as a flat bonus.

**Fix:**

```csharp
// effDEX = base DEX only (talent milestones + raw stat points, no equipment)
// DEXEquip = sum of DEX bonuses from all equipped items
float GetRangedAttack() =>
    (effDEX * 1.2f) + bowRoll + DEXEquip;
```

Equipment DEX is NOT inside the ×1.2 term. It adds flat on top. Separate the
two components in `EffectiveDEX` if they are currently merged.

---

## 2. Weak-Point Crit Value

**Hold ×1.6 from the design doc.** The code's ×2.0 is reverted.

```csharp
// BowstringMechanic:
const float weakPointCritMultiplier = 1.6f;  // was 2.0f, now 1.6f
```

×1.6 rewards accurate active play without making the gap between a crit and a
non-crit wide enough to make enemy HP pools feel arbitrary (at zone-1 HP values
of 50-90, ×2.0 causes one-shot flips on every crit; ×1.6 does not).

---

## 3. Ability Ring: Replace Crit, Do Not Stack

The ability ring multiplier **replaces** the weak-point crit multiplier. It does
not stack on top of it. Crit is the baseline reward for hitting a weak point with
a basic shot. A charged ability is a different choice that overrides crit entirely.

```csharp
// Active shot resolution in WardenBowstringMechanic:
float multiplier = isWeakPointHit ? weakPointCritMultiplier : 1.0f;

if (abilityRingActive && currentAbility != null)
    multiplier = currentAbility.damageMultiplier;  // replaces, does not stack

// Armor Piercer: additive to the ring multiplier, not a separate multiplication
if (armorPiercerActive)
    multiplier += 0.15f;

// Hard cap, no active shot exceeds this regardless of combinations
multiplier = Mathf.Clamp(multiplier, 1.0f, maxActiveMultiplier);

float postDef = Mathf.Max(1f, rawDamage - enemyDefense * 0.4f);
float final   = postDef * multiplier;
```

### 3.1 Revised ability ring multipliers

| Ability | Old value | New value | Notes |
|---------|----------|----------|-------|
| Full Draw | ×1.30 | ×1.30 | Unchanged, fine as-is |
| Aimed | ×2.0 | ×1.8 | Slight reduction |
| Pierce | ×1.5 | ×1.5 | Unchanged |
| Long Shot | ×8.0 | ×3.0 | Major reduction, see note |
| Armor Piercer | ×1.15 multiplicative | +0.15 additive | Becomes additive to ring mult |

**Long Shot:** ×8.0 produces ~400 damage at endgame even without crit stacking,
which 2-shots T3 zone bosses. ×3.0 is a high-commitment, high-reward shot that
feels powerful without deleting encounters. Revisit after T3 enemy tuning if it
still feels out of place. Long Shot should also have a travel-time mechanic that
causes it to miss fast-moving targets, this increases counterplay and justifies
its lower multiplier relative to the old value.

### 3.2 Combined multiplier cap

```csharp
const float maxActiveMultiplier = 2.5f;
```

No active shot deals more than ×2.5 base damage regardless of how multipliers
combine. At endgame Masterwork Void gear, a capped ×2.5 Aimed weak-point shot
should feel powerful without one-shotting bosses.

The cap applies after the additive Armor Piercer modifier:
- Long Shot (×3.0) + Armor Piercer (+0.15) = ×3.15, clamped to ×2.5.
- Aimed (×1.8) + Armor Piercer (+0.15) = ×1.95, under cap.
- Full Draw (×1.30) + Armor Piercer (+0.15) = ×1.45, under cap.

---

## 4. Defense Application Order

Defense applies **before** the multiplier. The current code has this correct.
No change needed.

```
postDef = max(1, raw - enemyDefense × 0.4)
final   = postDef × multiplier
```

This is correct because the multiplier represents skill (shot placement, charge
level), not raw power. Defense should mitigate the incoming hit before skill
amplifies what gets through. Inverting the order would make heavy armor nearly
irrelevant against active players.

---

## 5. Zone-1 Enemy Defense Adjustment

**Increase zone-1 enemy defense from 3-10 to 10-18.**

At the corrected multiplier values, a level-13 Sharpshot with ~20 base DEX and
a Crude Bronze bow produces:

```
effDEX 20 × 1.2 + bowRoll (4-8) + DEXEquip 3 = 31-35 pre-defense
With old defense 3-10: postDef = 21-34   (too high)
With new defense 10-18: postDef = 13-25  (target: 14-18 for non-crit)
```

Against a Brigand (55 HP) at postDef ~16 non-crit:
- Non-crit active: ~16 per shot → 3-4 shots to kill. ✓
- Crit (×1.6): ~26 per shot → 2-3 shots. ✓
- Idle auto (×0.80): ~13 per shot → 4-5 shots. ✓

### 5.1 Updated zone-1 defense ranges

| Enemy | HP | Old defense | New defense |
|-------|----|------------|------------|
| Grimwood Brigand | 55 | 3-6 | 10-14 |
| Forest Wolf | 50 | 3-5 | 10-12 |
| Grimwood Poacher | 90 | 5-8 | 12-16 |
| Saltmarsh Corsair | 60 | 4-7 | 10-15 |
| (Zone-1 Bear / Elite) | 140-210 | 6-10 | 14-18 |
| Zone-1 Boss | 600 | 8-10 | 16-20 |

Apply in `CreateZoneEnemies.cs` zone-1 enemy definitions. Zone T2+ defense
values are not changed by this spec, review them separately once zone-1 is
confirmed balanced.

---

## 6. Target Time-to-Kill (Zone 1, Lv13 Sharpshot)

| Enemy | HP | Target active TTK | Target idle TTK |
|-------|----|------------------|----------------|
| Basic (Brigand, Wolf) | 50-60 | 3-4 shots | 5-7 shots |
| Poacher | 90 | 5-6 shots | 8-10 shots |
| Bear | 140 | 7-9 shots | 11-14 shots |
| Zone-1 Elite | 180-210 | 10-13 shots | 16-20 shots |
| Zone-1 Boss | 600 | 30-40 shots (multi-phase feel) | not solo-idle-able |

These are design targets. Tune the `grimoireXpScalar` in `CombatXPManager`
(see combat-progression-reconcile.md) if leveling speed diverges once TTK is
corrected.

---

## 7. Summary of Changes

```
BowstringMechanic:
  weakPointCritMultiplier: 2.0f → 1.6f

WardenBowstringMechanic:
  Long Shot multiplier:    8.0f → 3.0f
  Aimed multiplier:        2.0f → 1.8f
  Armor Piercer:           × 1.15f → + 0.15f (additive, not multiplicative)
  Stacking model:          multiplier × abilityRing → abilityRing replaces crit
  Cap added:               Mathf.Clamp(multiplier, 1.0f, 2.5f)

PlayerData.GetRangedAttack:
  effDEX:                  was (baseDEX + DEXEquip), now baseDEX only
  formula:                 (effDEX × 1.2) + bowRoll + DEXEquip  (unchanged shape, corrected inputs)

CreateZoneEnemies (zone-1 only):
  Enemy defense:           3-10 → 10-18 range (per enemy table in Section 5.1)
```

---

## 8. Acceptance Criteria

- A level-13 Sharpshot with Crude Bronze bow and no ability ring ability takes
  3-4 active shots to kill a Grimwood Brigand (55 HP).
- A charged Long Shot (×3.0, capped at ×2.5 with no Armor Piercer) deals
  approximately 2.5× a non-crit active shot on the same enemy.
- DEX equipment bonus is counted exactly once in `GetRangedAttack`.
- Idle auto-attacks are unaffected by ability ring or crit multipliers
  (they pass `active:false` and receive ×0.80 as before).
- A zone-1 boss at 600 HP takes 30+ active shots from a level-13 Sharpshot,
  making it a genuine multi-phase encounter.

---

*Path: docs/combat-balance-reconcile.md*
*Resolves: combat-balance-reconcile-REQUEST.md (all 5 questions + bug).*
*Does not change: idle multiplier (×0.80), defense formula, non-Warden classes.*
