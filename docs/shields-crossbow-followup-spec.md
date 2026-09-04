---
type: design-spec
version: 1.0
updated: 2026-09-04
path: docs/shields-crossbow-followup-spec.md
resolves: shields-crossbow-followup-REQUEST.md
extends: warden-weapons-shield-spec.md v1.0, combat-attack-speed-spec.md v1.0
implements: Warden technique crossbow conversions, three crossbow branch entries,
            ArmingSword and HandAxe WeaponTypes, Wand reclassified one-handed
---

# Crossbow Progression and Shields Beyond the Crossbow
### Version 1.0

---

## 0. Scope Answer First

**Sword and board needs no combat rewrite.** It is two new `WeaponType` values, two rows in
the `WeaponSpeed` table, ten new ItemData, and one flag change on Wand. Handedness is already
type-derived, `damageFactor` is already the penalty channel, and the block channel is already
generic to the player rather than Warden-specific. Nothing in Question 2 touches
`ResolveEnemyAttack`.

**The crossbow conversions in Question 1 are the part with real scope risk**, and how much
depends on one thing I cannot see: whether `WardenTechniqueLibrary` effects carry a condition
field or are hardcoded triggers. Section 3.4 covers both cases.

---

## 1. Question 1 Is Almost Entirely A Sharpshot Problem

Before designing the conversion, I audited both Warden trees against the crossbow. The result
reframes the question.

| Subclass | Unlocks that work as-is | Unlocks that are dead | Dead share |
|---|---|---|---|
| Sharpshot | 2 of 15 | 12, plus 1 partial | 80 percent |
| Lone Wanderer | 12 of 15 | 2, plus 1 partial | 13 percent |

The request says "most of the Warden technique ladder gates on draw strength." That is true
for Sharpshot and false for Lone Wanderer. Lone Wanderer's tree is built on coatings, stealth,
solo bonuses, and drop rates, almost none of which touch the draw.

**Two consequences.** A blanket draw-gate conversion pass would be aimed at the wrong target,
and Lone Wanderer is already very close to a shippable crossbow subclass while Sharpshot is
not. If scope forces a choice, converting Sharpshot alone fixes 12 of the 14 dead entries in
the game.

---

## 2. Sharpshot Conversions

Applied only while a Crossbow is equipped. Swapping back to any bow restores the original
behaviour with no state to migrate.

**Conversion principle:** an active that demands timing is worth more than a passive that is
always on, so converted forms land at roughly half the active's peak value, or trade a
guaranteed trigger for a per-shot chance at the same magnitude.

| Lv | Technique | Original | Crossbow form |
|---|---|---|---|
| 1 | Steady Hand | Draw +20%, damage +30% | Damage per shot +20%. The draw cost is gone, so the payout drops with it. |
| 9 | Piercing Shot | Full draw 1.5s penetrates for 60% | 25% chance per shot to penetrate for 60% |
| 17 | Hunter's Patience | Up to +24% for holding 3s | Flat +12% damage |
| 24 | Mark of the Hunt | Weak-point hit Marks for 15s, +20% | First shot on any new enemy Marks it for 15s, +20% |
| 31 | Barbed Shot | Ring at 1.0s hold, 20% bleed | 20% chance per shot to apply the same bleed, no ring |
| 38 | Fletchery | Second coating slot | Unchanged, works as-is |
| 44 | Sniper's Vantage | +15% on full-draw shots | Flat +8% damage |
| 52 | Killshot | Full draw executes below 20% HP | Shots against enemies below 20% HP deal 250%. No execute. |
| 59 | Deadeye | Weak point glow +50% | **No passive form. Branch entry, section 3.1** |
| 66 | Crosswind Read | Marked enemies weak-point mult +0.25 | Marked enemies take +10% additional damage |
| 73 | Armor Piercer | Full draw triggers armour ignore | 20% chance per shot to ignore enemy armour rating |
| 79 | Sharpshot's Resolve | Weak-point hit guarantees the next | **No passive form. Branch entry, section 3.2** |
| 86 | The Long Shot | 5s hold, 600%, 5 min cooldown | Every 60s the next shot deals 300% automatically |
| 93 | Precision Mastery | Halves Steady Hand's draw penalty | **No passive form. Branch entry, section 3.3** |
| 100 | Master's Draw | Idle fires at 80% of active | Unchanged, works as-is |

### 2.1 Notes on the three most consequential conversions

**Mark of the Hunt** is the best conversion in the table because it changes only the trigger.
Weak-point hit becomes first-contact, everything downstream keeps working, and first-contact
fires reliably in idle where a weak-point trigger never would. Crosswind Read then has
something to modify, which saves a second entry.

**Killshot** loses the execute deliberately. A passive, always-on execute would be very strong
in idle, where the player is not choosing when to spend it. 250 percent on sub-20 percent
targets is a finisher without an instant-kill button that fires unattended.

**The Long Shot** becomes automatic rather than held, and its cooldown drops from five minutes
to sixty seconds to compensate for the halved multiplier and the loss of player choice about
when it lands. An auto-firing five-minute cooldown would be invisible.

---

## 3. The Crossbow Branch, Three Entries

Three Sharpshot unlocks have no honest passive form because they modify a mechanic the
crossbow does not have: weak-point glow duration, weak-point chaining, and a draw-time
penalty. Converting them would mean inventing an unrelated effect and calling it the same
name, which is worse than replacing them.

These three are the seed of the dedicated branch the request wants later. Author them now as
crossbow-conditional replacements at the same levels.

### 3.1 Bulwark Sights, level 59, replaces Deadeye

While a shield is equipped, damage +10 percent.

Ties the two systems the crossbow build depends on into one another. A crossbow without a
shield is a slow bow, and this is the first unlock that says the pairing is the build.

### 3.2 Braced Resolve, level 79, replaces Sharpshot's Resolve

While Brace is active, the crossbow continues firing at 50 percent rate.

This fixes the largest weakness of Brace, which is that bracing stops the player's damage
entirely. At level 79 the player has earned the right to do both at once, badly. It also gives
Brace a reason to exist at high level rather than being an early-game panic button.

Depends on Brace being wired, which is currently deferred. If Brace does not ship, hold this
entry and use the fallback in section 3.5.

### 3.3 Repeating Action, level 93, replaces Precision Mastery

Crossbow attack interval reduced from 2.90s to 2.60s.

The crossbow's version of "you no longer sacrifice speed for power." It takes the slowest
weapon in the game from 2.90s to 2.60s, which is still slower than every other weapon, so the
archetype survives the buff. DPS index rises from 0.924 to 1.031, roughly parity with a
shortbow, which is a fair place for a level 93 capstone-adjacent unlock to land.

### 3.4 Implementation shape, and the scope question

Every conversion in section 2 is a conditional variant of an existing effect. Whether that is
data or code depends on the library.

**If `WardenTechniqueLibrary` effects carry a condition field**, each conversion is one
authored variant row keyed on `weaponType == Crossbow`, and the whole of section 2 is data.
The three branch entries are three new rows.

**If effects are hardcoded triggers**, each conversion is a branch in that technique's
resolver, which is twelve small code changes plus three new effects. Still not a rewrite, but
it is a day rather than an afternoon.

Check this before scheduling. It is the only real uncertainty in this document.

### 3.5 Fallback if Brace stays unwired

Replace Braced Resolve with **Bolt Reserve**: every fifth shot fires two bolts. Same level,
no Brace dependency, and it fits the crossbow fantasy without needing new input.

---

## 4. Lone Wanderer Conversions

Only three entries need anything.

| Lv | Technique | Original | Crossbow form |
|---|---|---|---|
| 38 | Lone Wolf's Eye | All weak points always visible | +10% damage to all enemies in the current zone |
| 44 | Rapid Fire | 0.3s hold fires 3 shots at 65% | Every 8s the next shot fires as a 3-shot burst at 65% each, automatically |
| 100 | Wanderer's Mastery | XP +20%, Rapid Fire fires 4 | XP +20% unchanged, the auto-burst fires 4 |

Rapid Fire's original 0.3 second hold is barely an input, so converting it to an automatic
burst on the same 8 second cooldown loses almost nothing and keeps the level 100 capstone
meaningful. Everything else in the Lone Wanderer tree already works on a crossbow untouched.

**Worth saying plainly:** Lone Wanderer plus crossbow plus shield is a coherent, nearly
complete build today. Coatings, bleeds, stealth, solo bonuses, and drop rates all function.
If the crossbow needs to prove itself in playtest before the Sharpshot conversion work is
scheduled, that is the pairing to test.

---

## 5. Question 2, The Handedness Model

**Per-type one-handed variants. Model (a).**

Model (b), a universal any-weapon-plus-shield penalty, loses on three counts. It needs a new
penalty channel that does not exist, when `damageFactor` already is one. It breaks the
type-derived handedness rule, so the equip system would have to reason about combinations
rather than reading a property off a type. And a single flat penalty cannot be tuned per
weapon, so the same number would be punishing on a fast weapon and trivial on a slow one,
which is exactly the problem the per-type `damageFactor` design exists to avoid.

Model (a) adds nothing. `ItemData.IsOneHanded` gains two more types in its expression, the
speed table gains two rows, and the penalty rides on a field that already scales the band.

### 5.1 The numbers

The two-handed weapons sit on the gradient established in `combat-attack-speed-spec.md`.
**One-handed variants sit deliberately 13 to 15 percent below that curve, and that gap is the
price of the off-hand.**

| Weapon | Speed | Interval | Damage | DPS index | Against curve | Hands |
|---|---|---|---|---|---|---|
| Sword | 0.95 | 1.90s | 0.96 | 1.011 | on curve | Two |
| **Arming Sword** | 0.90 | 1.80s | **0.80** | 0.889 | -13.0% | **One** |
| Axe | 1.25 | 2.50s | 1.20 | 0.960 | on curve | Two |
| **Hand Axe** | 1.10 | 2.20s | **0.94** | 0.855 | -13.4% | **One** |
| Staff | 1.15 | 2.30s | 1.13 | 0.983 | on curve | Two |
| **Wand** | 0.80 | 1.60s | **0.72** | 0.900 | -13.4% | **One** |
| Crossbow | 1.45 | 2.90s | 1.34 | 0.924 | on curve | One |

Against their two-handed parent: Arming Sword loses 12.1 percent DPS to Sword, Hand Axe loses
10.9 percent to Axe, Wand loses 8.4 percent to Staff.

The one-handed variants are slightly faster than their parents, which reads correctly for a
lighter weapon, and take the whole trade on the damage band.

### 5.2 Why 13 percent

The shield returns 16 to 25 percent effective HP. Pricing the trade at 13 percent damage puts
sword and board slightly ahead on paper in survival terms and behind on clear speed, which is
the shape a defensive option should have in a game where most content is DPS-limited.

Pricing it at parity, around 20 percent, would make the shield a pure downgrade for anyone not
actively dying. Pricing it under 10 percent would make it a default. Thirteen is where a
player choosing between them has to think about the content in front of them.

Note the crossbow is on the curve rather than below it. It already paid for its shield by
losing the weak-point crit entirely, which section 4.2 of v1.0 costs at 23 to 28 percent in
active play. The melee and arcane one-handers keep their full mechanic, so their price is in
the band instead.

### 5.3 The crossbow anomaly, resolved

With Arming Sword, Hand Axe, and Wand all sitting 13 percent below curve, the crossbow at
on-curve now looks generous. It is not, because of the weak point. But if playtest disagrees,
the clean fix is dropping crossbow `damageFactor` from 1.34 to about 1.20, which puts it in
line with the others. Do not change its speed, since 2.90s is the archetype.

---

## 6. The Four Class Decisions

### 6.1 Vanguard aggro: lower the shield to +10 percent, flat, for everyone

The +15 percent was sized for a Warden whose baseline aggro is near zero, where it is a nudge.
On a Vanguard, whose baseline is already the highest in the game, the same percentage compounds
a large number and risks making shield Vanguard the only correct tank.

**Reduce the shield's aggro bonus to +10 percent and keep it identical across paths.**

A class-conditional value was the alternative and it is worse. It needs path awareness the
equip system does not have, and it makes the shield's tooltip tell one class something untrue.
If shield Vanguard reads as too sticky when parties ship in Phase 4, the correct lever is
Vanguard's base aggro, not a special case on the shield.

The value is inert until Phase 4, so changing it now costs one authored number.

### 6.2 Vanguard combos are not gated. They keep working one-handed.

**The principle, and it is the useful one to carry forward: a mechanic is lost when its input
cannot exist, not when the weapon changes.**

The crossbow lost draw techniques because a crossbow has no draw. There is no timing to hold,
no strength to build, and no amount of design can put one there. A Vanguard combo is a
sequence of Strike, Guard, and Surge taps. Nothing about that sequence requires two hands, and
an arming sword can be struck, guarded with, and surged with exactly as a greatsword can.

**Why keeping combos is not strictly better than a two-handed weapon.** Combos multiply
damage, and the one-handed variant's `damageFactor` cuts the number being multiplied. A combo
chain on an Arming Sword produces 12 percent less than the same chain on a Sword, at every
step. The penalty is not bypassed by the mechanic, it is amplified by it, which means the
two-handed weapon is the correct choice for a combo-focused build and the shield is the
correct choice for a survival-focused one. That is the fork working as intended.

### 6.3 Wand becomes one-handed. Staff stays two-handed.

**Ship it, and do it by reclassifying the existing Wand rather than adding a fourth arcane
weapon.**

The identity concern is real but it points the other way once examined. Arcanist is the
squishiest path at a 0.90 HP multiplier, so it is the path that most needs a defensive option,
and a battlemage holding a wand and a shield is not a dilution of the arcane fantasy so much
as one of its oldest images. The constellation trace is a single-finger drag, so nothing about
casting requires the off-hand.

The natural mapping is also the intuitive one. A wand is a one-handed thing and a staff is a
two-handed thing. Adding a third arcane weapon to express that would be inventing an object to
avoid renaming a property.

**What the Wand loses: its damage band, from `damageFactor` 0.83 to 0.72.** Not cast speed,
because 1.60s is the Wand's identity within the Arcanist fork and slowing it would collapse the
distinction from Staff. Not a mechanic, because the constellation is the path's whole
expression and gating it would recreate the Sharpshot problem in a second path.

**Flag: this is a live balance change to a shipped weapon.** Every existing Wand becomes 13
percent weaker offensively and gains access to the off-hand. Anyone currently holding one
without a shield is straightforwardly worse off until they equip one. Worth a patch note and
worth considering a one-time compensation, or the conservative alternative below.

**Conservative alternative if that change is unwelcome:** leave Wand two-handed at 0.83 and add
a **Focus** at speed 0.80 and `damageFactor` 0.72 as a fourth arcane weapon. Five more ItemData
and a third choice in a two-choice fork, in exchange for touching nothing that shipped.

### 6.4 No per-class shield restriction. The penalty is the gate.

Weapons are not path-gated today and shields should not be the exception.

A hard gate is new work, since the equip system has no path awareness, and it would be the
first hard class wall in a system that has always steered with stats instead. It would also
punish exactly the experimentation that makes a build system worth having.

The steering already exists and it is stronger than a wall. A shield is only reachable through
a one-handed weapon, every one-handed weapon carries a 13 percent damage cut, and each one
favours a stat only its natural path benefits from. A Warden who picks up an Arming Sword to
get a shield trades DEX scaling for STR scaling and loses far more than the shield returns.

**The `damageFactor` penalty is the gate, and it is a better gate than a class check because
it is a price rather than a wall.** A player who pays it anyway has made a real choice, and
occasionally they will have found something the designer did not, which is the point.

---

## 7. Build Scope

**Drops into the as-built architecture, no new mechanic:**

| Item | Kind |
|---|---|
| `ArmingSword` and `HandAxe` added to `WeaponType` | Data |
| Two rows added to the `WeaponSpeed` table | Data |
| `IsOneHanded` expression extended to three more types | One line |
| Wand `damageFactor` 0.83 to 0.72 | Data |
| Ten new ItemData, five Arming Swords and five Hand Axes | Data |
| Five new Shield ItemData if not already authored per tier | Data |
| Shield aggro 15 to 10 percent | Data |
| Ponderous already exists as a speed word, no new labels needed | None |

**Needs a code path, size depends on section 3.4:**

| Item | Kind |
|---|---|
| Twelve Sharpshot technique conversions | Data if conditional effects exist, otherwise twelve small branches |
| Three Lone Wanderer conversions | Same |
| Three crossbow branch entries | Three new effects either way |

**Already deferred, unchanged:**

Brace input wiring. Braced Resolve depends on it, with a fallback in section 3.5.

**Not needed:**

No change to `ResolveEnemyAttack`, the block channel, the off-hand slot, the swap and refusal
rules, the mitigation cap, evasion, or any damage band table.

---

## 8. Acceptance Criteria

- Every Sharpshot unlock does something while a Crossbow is equipped, either its original
  effect, its converted form, or its branch replacement.
- Every Lone Wanderer unlock does something while a Crossbow is equipped.
- Swapping from Crossbow to any bow restores every original technique with no state carried.
- Converted techniques never fire their original trigger and never double-apply.
- Equipping an Arming Sword, Hand Axe, or Wand unlocks the off-hand slot.
- Equipping a Sword, Axe, Staff, Shortbow, or Longbow blocks and stows the off-hand.
- The three one-handed variants sit 13 to 14 percent below the two-handed DPS gradient.
- Vanguard combos function identically on a one-handed weapon, and produce lower total damage
  purely because the band is lower.
- The shield grants +10 percent aggro to every path identically.
- No path is prevented from equipping any weapon or shield.
- No change is made to `ResolveEnemyAttack` or the block resolution order.

---

*Path: docs/shields-crossbow-followup-spec.md*
*Q1 is a Sharpshot problem, 12 of 15 dead there against 2 of 15 for Lone Wanderer. Twelve*
*conversions plus three branch entries. Q2 uses per-type one-handed variants at 13 percent*
*below the two-handed gradient. Combos are not gated, Wand becomes one-handed, shield aggro*
*drops to 10 percent flat, and no class restriction. Sword and board needs no combat rewrite.*
