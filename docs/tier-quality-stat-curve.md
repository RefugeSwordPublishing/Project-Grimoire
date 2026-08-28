---
type: design-spec
version: 1.0
updated: 2026-08-28
path: docs/tier-quality-stat-curve.md
resolves: tier-quality-stat-curve-REQUEST.md, bug #54
implements: EquipmentStats.cs (two new tables, optionally four), EquipmentManager
---

# Tier vs Quality Stat Curve
### Version 1.0

---

## 1. The Rule

**One material tier is worth two quality steps of stat.**

Measured as: the tier bonus equals the cumulative primary gain from Crude to Refined,
which is two upgrades. A fresh Tier N piece therefore beats a Tier N-1 piece upgraded
once by a clear margin, ties one upgraded twice, and loses to one upgraded three times.

That last clause is the part that keeps quality meaningful. A player who has poured four
upgrades into a Tier 1 staff still has something worth carrying past a raw Tier 2 drop,
which is the behavior the Quality-vs-Tier rule demands.

I would not tune it higher. At three steps per tier, a fresh tier beats a fully Pristine
previous tier and the quality lever stops mattering for gear retention. At one step, the
bug returns in milder form. Two is the only value where both axes keep a job.

---

## 2. The Tables

Drop into `EquipmentStats.cs` in the existing style. Index is `materialTier` 1 to 5,
index 0 unused, T1 is zero.

```csharp
// Flat TIER bonus applied to the piece's stat bonus, added on top of the quality base.
// Mirrors how TierWeaponBonus adds to the damage band.
TierPrimaryBonus   = { -, 0, 7, 15, 24, 34 };   // favoured stat
TierSecondaryBonus = { -, 0, 5, 11, 18, 26 };   // second stat
```

Deltas per tier step are 7, 8, 9, 10 on primary and 5, 6, 7, 8 on secondary. Both
accelerate at the same rate the quality ladder does (quality primary deltas are 3, 4, 5,
6), so the two-step relationship holds at every tier boundary rather than drifting.

Secondary lands at 76 percent of primary at T5, against 75 percent in the quality table
at Masterwork. The existing primary-to-secondary ratio is preserved rather than
re-invented.

### 2.1 Verification, the relationship holds at every boundary

Primary stat, fresh Tier N Crude against the full Tier N-1 ladder:

| Fresh piece | Value | Prev tier Rough | Prev tier Refined | Prev tier Pristine |
|---|---|---|---|---|
| T2 Crude | 9 | 5 | 9 | 14 |
| T3 Crude | 17 | 12 | 16 | 21 |
| T4 Crude | 26 | 20 | 24 | 29 |
| T5 Crude | 36 | 29 | 33 | 38 |

Every row: beats Rough decisively, ties or narrowly beats Refined, loses to Pristine.
Secondary behaves identically (T2 Crude 6 against T1 Refined 6, and so on down).

---

## 3. Worked Check on Bug #54

Pine staff is Tier 1, Ash staff is Tier 2. `TierPrimaryBonus[2] = 7`.

| Piece | INT (primary) | Damage band |
|---|---|---|
| Pine T1 Crude | 2 | 4-8 |
| Pine T1 Rough | 5 | 8-14 |
| Pine T1 Refined | 9 | 14-22 |
| Pine T1 Pristine | 14 | 22-32 |
| **Ash T2 Crude** | **9** | **24-28** |

**The reported case.** Ash Crude INT 9 against Pine Rough INT 5. Ash wins by 4, which is
80 percent more INT, and it also wins the damage band 24-28 against 8-14. The fresh tier
now beats the one-upgrade piece on both axes. Bug closed.

**Two upgrades.** Ash Crude 9 ties Pine Refined 9 exactly on INT, and still wins the
damage band 24-28 against 14-22. So a player who has upgraded Pine twice should keep
using it until Ash gets its first upgrade, at which point Ash pulls ahead permanently.
That is a real decision rather than a foregone one.

**Three upgrades.** Pine Pristine 14 beats Ash Crude 9 on INT. An Arcanist who invested
four Binding Sigils into their Pine staff keeps the better INT until they upgrade Ash
once. Quality investment is protected.

---

## 4. Reconciling Against the Physical Curve

### 4.1 Where the physical curve sits today

Cumulative quality gain on `WeaponDmgMin` from Crude is 4, 10, 18, 28. `TierWeaponBonus`
at T2 is 20, which sits between Pristine and Masterwork. So on the physical band, one
tier is currently worth roughly three quality steps, against the two steps I am
proposing for the stat.

That mismatch is acceptable and mildly intentional. The physical band is the whole
contribution of a weapon, while the stat bonus stacks across up to six slots. A slightly
gentler stat curve keeps total gear contribution from compounding, for the reasons in
section 6.

### 4.2 What I think is wrong with the physical tier bonuses

Flagging as requested. I am not changing these without your say-so.

**TierWeaponBonus accelerates past the point where quality matters.** The deltas are 20,
25, 35, 45. The entire Crude-to-Masterwork quality span on minimum damage is 28. So the
single step from T4 to T5 is worth more than every quality upgrade in the game combined.
At the top of the ladder, quality stops being a lever on weapon damage at all, which
breaks the same rule this spec exists to protect.

Suggested correction, if you want it:

```csharp
TierWeaponBonus = { -, 0, 20, 42, 68, 98 };   // deltas 20, 22, 26, 30
```

No single tier step then exceeds the full quality span, and the T5 total drops from 125
to 98, which also relieves some of the endgame damage pressure that
combat-balance-reconcile.md was already fighting.

**TierVestmentBonus is very small next to Plate.** 22 at T5 against Plate's 50. If that
is a deliberate statement that cloth gains little from material tier, it is fine and
consistent. Confirm it is deliberate rather than a decayed placeholder, because an
Arcanist currently gets almost no armour rating from climbing tiers.

**I could not check the armour ratio.** The quality base table for armour rating was not
in the request, only `BonusPrimary`, `BonusSecondary`, and the weapon damage bands. Send
me the armour rating quality table and I will verify that the Plate, Leather, and
Vestment tier bonuses sit at a sensible multiple of it the same way I checked the weapon
band.

---

## 5. Weapons and Armour Want Different Tables

You asked. The answer is yes, and the reason is slot count.

A weapon occupies one slot. Armour occupies five. If both use `TierPrimaryBonus` at full
value, the tier component is multiplied by six across a full set while the quality
component always was too, so the inflation compounds on an already-multiplied base.

Taking a build where three of six slots favour the same primary stat, at Tier 5
Masterwork:

| Model | Primary from gear | Against current |
|---|---|---|
| Current, quality only | 60 | baseline |
| Single table everywhere | 162 | 2.70x |
| Weapon full, armour at 60 percent | 134 | 2.23x |

### 5.1 Recommended armour tables

```csharp
// Applied to armour pieces only. Weapons and foci use the full tables above.
TierArmourPrimaryBonus   = { -, 0, 4,  9, 14, 20 };
TierArmourSecondaryBonus = { -, 0, 3,  7, 11, 16 };
```

The relationship weakens on armour but stays positive: a T2 Crude piece gives 6 primary
against a T1 Rough piece at 5, so a fresh tier still beats one upgrade. It ties closer to
one step than two, which is the price of not tripling endgame stats.

### 5.2 If you would rather ship two tables than four

Use the full `TierPrimaryBonus` and `TierSecondaryBonus` on both weapons and armour and
accept the 2.70x figure. The bug closes either way. Treat the armour split as the first
lever to reach for if endgame damage tests hot, since it is a drop-in change that does
not touch the weapon line or reopen bug #54.

---

## 6. Knock-On Effects To Watch

**Total stat inflation is the main one.** Even with the armour split, endgame gear
contributes roughly 2.2x the primary stat it does today. Stats feed damage directly
through the attack formulas, so enemy defense and HP at Tiers 4 and 5 will need a
verification pass against the new numbers. This is the item most likely to require
follow-up tuning, and it is worth instrumenting before the change ships to players.

**Secondary scaling is deliberately slower.** 76 percent of primary at T5, matching the
existing 75 percent quality ratio. No change in how the two stats relate, only in how
far they both travel.

**Low-tier Masterwork stays viable, by design.** A T1 Masterwork piece gives 20 primary,
which beats a T3 Crude piece at 17. That looks surprising but it is correct: the T3 piece
wins decisively on the physical band, so the two pieces trade rather than one dominating.
Preserving that trade is the whole reason the tier bonus is set at two quality steps and
not three.

**Legendary index stays unused.** The quality tables carry a sixth entry for it. The tier
tables have no Legendary dimension and need none, since Legendary is a quality value and
not a tier.

**No new enums, no formulas.** Both tables are flat integer lookups in the existing style.

---

## 7. Implementation

**EquipmentStats.cs**, add two tables (or four if taking the armour split):

```csharp
TierPrimaryBonus   = { -, 0, 7, 15, 24, 34 };
TierSecondaryBonus = { -, 0, 5, 11, 18, 26 };

// Optional, recommended, armour pieces only:
TierArmourPrimaryBonus   = { -, 0, 4,  9, 14, 20 };
TierArmourSecondaryBonus = { -, 0, 3,  7, 11, 16 };
```

**EquipmentManager**, add the tier term alongside the existing quality lookup, in the
same shape as the existing damage band code:

```csharp
primary   = BonusPrimary[quality]   + TierPrimaryBonus[materialTier];
secondary = BonusSecondary[quality] + TierSecondaryBonus[materialTier];
```

If taking the armour split, branch on whether the piece has an `armorType` other than
`None` and read the armour tables instead.

---

## 8. Acceptance Criteria

- A Tier 2 Crude staff has strictly higher INT than a Tier 1 Rough staff.
- A Tier 2 Crude staff has INT equal to a Tier 1 Refined staff.
- A Tier 1 Pristine staff has strictly higher INT than a Tier 2 Crude staff.
- The same three relationships hold at the T3, T4, and T5 boundaries.
- Secondary stat follows the identical pattern at its own values.
- `TierPrimaryBonus[1]` and `TierSecondaryBonus[1]` are 0, so no Tier 1 item changes.
- No existing item's quality contribution changes. Only the tier term is additive and new.
- Armour rating and weapon damage band values are unchanged unless the section 4.2
  correction is explicitly adopted.

---

*Path: docs/tier-quality-stat-curve.md*
*Resolves bug #54. One material tier equals two quality steps of stat.*
*Two tables required, four recommended. Flags TierWeaponBonus acceleration at T5 as a*
*separate issue worth correcting.*
