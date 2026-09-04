---
type: design-spec
version: 1.0
updated: 2026-08-31
path: docs/warden-weapons-shield-spec.md
resolves: warden-weapons-shield-REQUEST.md
extends: combat-attack-speed-spec.md v1.0
implements: WeaponType additions, WeaponSpeed rows, EquipmentSlot.OffHand,
            ShieldData, player block channel, Brace active
scope: data, one slot, one formula. No combat rewrite.
---

# Warden Weapon Types and the Shield Off-Hand
### Version 1.0

---

## 1. The Three Bows

### 1.1 Speed and damage, extending the existing table

| Weapon | Speed factor | Interval | Damage factor | DPS index | Feel |
|---|---|---|---|---|---|
| Shortbow | 0.82 | 1.64s | 0.85 | 1.037 | Brisk |
| Longbow | 1.18 | 2.36s | 1.15 | 0.975 | Weighty |
| Crossbow | 1.45 | 2.90s | 1.34 | 0.924 | Ponderous |

These sit on the same gradient as the six existing types, where the DPS index trends
slightly higher for faster weapons to offset the fact that heavy weapons extract more from
every crit multiplier. Shortbow lands beside Wand, Longbow beside Staff, and Crossbow past
Axe as the slowest weapon in the game.

Crossbow at 2.90s is deliberately outside the range the original table established. It is
the only weapon in the game slower than 2.50s and that slowness is the archetype.

"Ponderous" is a new speed word for the item card, below Heavy.

### 1.2 New enum values, not an archetype field

Add `Shortbow`, `Longbow`, and `Crossbow` to `WeaponType`. Keep `Bow` in the enum, deprecated,
mapping to Longbow on load.

An archetype field on Bow would be cheaper to author and more expensive everywhere else.
Three systems already key on `WeaponType`: the `WeaponSpeed` lookup, the handedness rule this
spec adds, and the Bowstring mechanic gate. Each would need a special case that reads "if the
type is Bow, then look at the archetype field," which is three branches to maintain against
three enum values to add once.

The enum is also what the item card, the tooltip, and the Grimoire book all read to name the
weapon, and "Bow (Crossbow)" is worse copy than "Crossbow."

### 1.3 What happens to the existing per-tier bows

The five existing bows (Bronze, Iron, Steel, Mithril, Void) become **Longbows**, renamed in
place. Longbow is the closest thing to what "a bow" has meant in this game so far, and
renaming preserves every existing item instance rather than invalidating it.

**Item authoring:**

| Line | Count | Action |
|---|---|---|
| Bronze through Void Longbow | 5 | Rename existing, set `weaponType = Longbow` |
| Bronze through Void Shortbow | 5 | New ItemData |
| Bronze through Void Crossbow | 5 | New ItemData |
| Bronze through Void Shield | 5 | New ItemData, section 3 |

Twenty ItemData total, of which five are renames.

**Save migration:** any equipped or stored item with `weaponType == Bow` resolves to the same
tier Longbow. One mapping, no data loss, and a player who logs in holding a Steel Bow finds a
Steel Longbow with identical quality and stats except the new speed row.

---

## 2. Handedness and the Off-Hand Slot

### 2.1 Handedness

```csharp
// On WeaponData
public bool isOneHanded;   // true only for Crossbow at launch
```

A bool rather than a `Handedness` enum, because there are exactly two states and the request
is explicit that no other weapon is being reclassified. When sword and shield arrives it flips
to true on three more types and nothing else changes.

| Weapon | Handed | Off-hand |
|---|---|---|
| Crossbow | One | Unlocked |
| Shortbow, Longbow | Two | Blocked |
| Sword, Dagger, Axe, Staff, Wand | Two for now | Blocked, see section 7 |

### 2.2 The slot

```csharp
public enum EquipmentSlot { None, Weapon, OffHand, Helm, Chest, Legs,
                            Boots, Gloves, Quiver, Grimoire, Accessory }
```

`OffHand` accepts shields only at launch. The Quiver is untouched and stays a worn slot, so a
crossbow Warden equips a Crossbow, a Quiver, and a Shield at the same time. That is the point
of the build and it is why the shield needed a new slot rather than borrowing the quiver's.

### 2.3 Swap behaviour

**Equipping a two-handed weapon while a shield is equipped** unequips the shield to inventory
first, then equips the weapon. If the inventory has no room, the swap is refused with "No room
to stow your shield" and nothing changes. Refusing beats dropping the item or blocking the
inventory in a state the player did not ask for.

**Equipping a shield while a two-handed weapon is equipped** is refused, with the reason named:
"Two-handed weapon equipped." Do not silently unequip the weapon, because the weapon is the
larger commitment and the player almost certainly meant to change something else.

**Equipping a crossbow while a two-handed bow is equipped** simply swaps the weapon and leaves
the off-hand empty and now unlocked.

### 2.4 Character page

New baked region on the equipment layout, mirroring the existing slot regions.

```
OffHandSlot
  Icon         (Image)        shield sprite when equipped
  Empty        (GameObject)   shown when unlocked and empty
  Locked       (GameObject)   shown when a two-handed weapon is equipped
  LockLabel    (Text)         "Two-handed weapon equipped"
```

The locked state matters more than the empty one. A slot that vanishes teaches nothing, and a
slot that reads empty when it cannot be filled is a bug report. A visible locked slot naming
its own condition teaches the handedness rule the first time a player looks at it.

Place it opposite the Weapon slot in the layout so the pairing reads as a pairing.

---

## 3. Shields and Player Block

### 3.1 Block is new, and it is a chance to reduce

Today the player has flat mitigation through `armorRating` and an avoidance channel through
evasion. Block becomes a third channel and it must not behave like either of the other two.

**Block is a chance to reduce incoming damage by a percentage, not a chance to negate it.**

Full negate was the alternative and it is wrong here for two reasons. Stacked against evasion,
which already fully negates, it produces strings of zero-damage swings that read as random
rather than as durable. And in idle play the player is not watching, so an occasional total
negate is invisible while a frequent partial reduction shows up as a health bar that simply
falls slower. A tank archetype in an idle game wants steady, legible durability.

### 3.2 Shield stats

| Stat | Source | Notes |
|---|---|---|
| `blockChance` | Quality | 20 to 34 percent |
| `blockReduction` | Material tier | 50 percent at T1, plus 2 points per tier |
| `armorRating` | Material tier | 2 per tier, deliberately small, see 3.4 |

**Block chance by quality:**

| Quality | Crude | Rough | Refined | Pristine | Masterwork |
|---|---|---|---|---|---|
| Chance | 20% | 23% | 26% | 30% | 34% |

**Block reduction by tier:** T1 50%, T2 52%, T3 54%, T4 56%, T5 58%.

Splitting the two stats across the two axes means quality and tier both matter to a shield and
neither is redundant, which matches how every other equipment piece already works.

### 3.3 Resolution order

```csharp
// ResolveEnemyAttack, player side
float damage = enemyRawDamage;

// 1. Evade. Full avoidance, unchanged.
if (Roll() < EvasionChance()) return 0f;

// 2. Block. New. Only when a shield occupies the off-hand.
if (shield != null && Roll() < shield.blockChance)
    damage *= (1f - shield.blockReduction);

// 3. Mitigate. Flat, unchanged, and capped.
float mitigated = Mathf.Min(playerArmorRating * 0.4f, damage * 0.75f);
damage = Mathf.Max(1f, damage - mitigated);

return damage;
```

Evade first because avoiding a hit entirely should short-circuit everything after it. Block
before mitigation because block is proportional and mitigation is flat, and applying a
percentage before a subtraction is the order that keeps flat mitigation meaningful at high
block. Reversed, a blocked hit would often reach the floor of 1 regardless of the shield, and
the shield would stop mattering exactly when it should matter most.

### 3.4 Why shield armorRating is small, and a dependency

Flat mitigation subtracts `armorRating * 0.4` from every hit. A shield carrying armour
comparable to a chest piece would subtract enough to push most hits to the floor of 1 by
itself, and the shield would stop being a block item and start being an immunity item.

So shields carry a token 2 armour per tier, 2 at T1 through 10 at T5, for flavour rather than
for function. Their defensive contribution is the block channel.

**This depends on the mitigation cap.** `hp-progression-spec.md` section 8.1 recommends
capping mitigation at 75 percent of raw damage, and the code block above assumes it. If that
cap is not live, add it as part of this work. Without it, a well-armoured Warden adding any
shield at all trivializes incoming damage and every number in section 4 is wrong.

### 3.5 Effective HP returned

Expected damage reduction is `blockChance * blockReduction`, so effective HP is
`1 / (1 - chance * reduction)`.

| Quality | T1 | T2 | T3 | T4 | T5 |
|---|---|---|---|---|---|
| Crude | +11.1% | +11.6% | +12.1% | +12.6% | +13.1% |
| Rough | +13.0% | +13.6% | +14.2% | +14.8% | +15.4% |
| Refined | +14.9% | +15.6% | +16.3% | +17.0% | +17.8% |
| Pristine | +17.6% | +18.5% | +19.3% | +20.2% | +21.1% |
| Masterwork | +20.5% | +21.5% | +22.5% | +23.5% | +24.6% |

A realistic mid-game shield returns roughly 16 percent effective HP and a fully invested
endgame shield roughly 25 percent.

---

## 4. The Crossbow Archetype and Whether It Is a Trap

### 4.1 What it gives up

Two separate costs, and they land very differently.

**Speed.** The DPS index is 0.924 against Shortbow at 1.037 and Longbow at 0.975.

**The Bowstring weak point.** A crossbow has no draw, so it cannot use the mechanic at all.
Assuming a competent active player lands weak points on 40 percent of shots at the 1.6x
multiplier, the bow types carry an effective 1.24x active multiplier that the crossbow does not.

| Comparison | Idle DPS | Active DPS |
|---|---|---|
| Crossbow vs Shortbow | -10.8% | -28.1% |
| Crossbow vs Longbow | -5.2% | -23.5% |

### 4.2 The asymmetry is the design

Idle auto-attacks do not roll weak points, so **the crossbow loses almost nothing in idle and
a great deal in active play.**

That produces a genuinely clean fork, and it is the most valuable property of this whole design:

**Idle-leaning player.** Pays 5 to 11 percent DPS, gains 16 to 25 percent effective HP. That
is a good trade and it should be, because it means the tanky ranged build is the one that
survives overnight sessions unattended, which is what an idle-leaning player wants.

**Active-leaning player.** Pays 23 to 28 percent DPS for the same 16 to 25 percent effective
HP. That is a bad trade for clearing zones and a defensible one for a dungeon boss they keep
dying to. It is a judgment call by content rather than a strictly better answer.

So the crossbow is not a trap and it is not a must-pick. It is the idle build and the
emergency build, and a player who mostly plays actively should carry one and swap to it rather
than living in it. Weapon swapping is free and instant, which makes that the intended pattern.

### 4.3 Aggro

A tankier Warden is only meaningful when something else can be attacked instead, which means
party content, which is Phase 4.

**Shields grant a flat +15 percent aggro while equipped.** In solo and idle play this does
nothing, because there is one target and it is the player. In a party it lets a crossbow Warden
hold some attention without becoming a Vanguard, which is the intended ceiling: the archetype
is durable ranged, not a tank replacement.

No aggro work is needed now. Author the value on the shield and let it sit inert until parties
exist.

---

## 5. What the Crossbow Does Instead of Drawing

### 5.1 The technique kit, kept and lost

| Warden system | Crossbow |
|---|---|
| Quiver coatings | Kept. Bolts coat exactly as arrows do. |
| Bleed DoT scaling with quiver tier | Kept |
| Reinforced Quiver second coating slot | Kept |
| Bowstring weak-point crit | Lost, no draw |
| Draw-strength techniques (Full Draw, Aimed, Long Shot, hold thresholds) | Lost, all gate on draw time |
| Passive Warden techniques | Kept |

The quiver relationship is the reason this archetype works at all. A crossbow Warden keeps
their coatings and bleeds, which is most of what makes the Warden kit feel like the Warden kit,
and loses only the aiming layer.

### 5.2 Brace, the crossbow active

Auto-fire only would be idle-friendly and would give an active player nothing to do, which is a
worse version of the problem this spec exists to fix.

**Brace.** Press and hold on the shield side of the screen. While braced, `blockChance` gains
25 percentage points and `blockReduction` rises to 75 percent, and the crossbow does not fire.
Release to resume firing.

This is the deliberate mirror of the Bowstring. A bow's active play trades time for damage. A
crossbow's active play trades damage for defense. Same verb shape, opposite axis, and it suits
an archetype whose entire identity is being the Warden that does not die.

Idle never braces, so idle crossbow is pure auto-fire plus passive block, exactly as section
4.2 assumes. The active option changes nothing about the idle numbers.

**If scope is tight,** ship auto-fire only and add Brace later. The archetype works without it,
the numbers in section 4 do not depend on it, and it is additive.

### 5.3 The progression problem this creates

Flagging rather than solving, because it is larger than this spec.

Most of the Warden technique ladder gates on draw strength. A crossbow user loses those unlocks
entirely, which means a Warden who commits to crossbow watches most of their technique tree
arrive as unusable entries. That is a progression problem, not a balance one, and it will read
as broken.

Two workable answers. Convert draw-gated techniques to passive equivalents when a crossbow is
equipped, so the unlock still does something. Or author a short crossbow-specific branch of
five or six unlocks that fills the same levels. The first is cheaper and the second is better.

Worth resolving before the crossbow ships, because a build whose unlocks do nothing is worse
than a build that does not exist.

---

## 6. Balance Guardrails

**Proc normalization already covers the speed spread.** `combat-attack-speed-spec.md` section
4.4 requires every per-swing proc to scale by `attackInterval / 2.0`. At 2.90s the crossbow
gets 1.45x the per-swing proc chance of a baseline weapon, so coatings and bleeds land at the
same rate per second as they do on a shortbow. No separate rule needed, but this is the spec
where it would break loudest if it were missing.

**Block does not stack with itself.** One off-hand, one shield, one block roll. No effect
anywhere may add a second block roll.

**Brace does not stack with evasion.** Bracing does not raise evasion, only block. Two
avoidance channels rising together would produce the zero-damage strings section 3.1 rejects.

**Shields are Warden-crossbow-only at launch** by virtue of `isOneHanded` being true on
exactly one weapon type. No other path can equip one, so no other path's balance moves.

---

## 7. Sword and Shield, Flagged Not Scoped

Everything in this spec generalizes. Setting `isOneHanded = true` on Sword, Dagger, and Axe
would give Vanguard the same fork with no new systems: the slot exists, block exists, shields
exist, and the resolution order already handles them.

What would need deciding first, and is out of scope here:

- Whether a shield-bearing Vanguard needs its own aggro treatment, since Vanguard aggro is
  already the highest in the game and 15 percent on top may be too much.
- Whether Vanguard combos gate on being two-handed, the way Warden draw techniques do.
- Whether Staff and Wand should ever be one-handed, which is an Arcanist identity question
  rather than a mechanical one.

Do not set `isOneHanded` on anything but Crossbow in this pass.

---

## 8. Implementation Summary

| Change | Where | Kind |
|---|---|---|
| Shortbow, Longbow, Crossbow added to `WeaponType`, Bow deprecated | Enum | Data |
| Three rows added to the `WeaponSpeed` table | Static data | Data |
| `isOneHanded` on `WeaponData`, true for Crossbow only | Data model | Data |
| `OffHand` added to `EquipmentSlot` | Enum | Data |
| `ShieldData` with blockChance, blockReduction, armorRating | New ItemData type | Data |
| Twenty ItemData: five renamed, fifteen new | Item assets | Data |
| Bow to Longbow save migration | Load path | Formula |
| Block roll inserted between evade and mitigate | `ResolveEnemyAttack` | Formula |
| Mitigation cap, if not already live | `ResolveEnemyAttack` | Formula |
| Off-hand swap and refusal rules | Equipment logic | Formula |
| `OffHandSlot` region on the character page | Baked UI | UI |
| Ponderous added to the speed word set | Item card | UI text |
| Brace active, optional | Combat input | System |

No change to the Quiver, the Bowstring mechanic itself, evasion, the damage band tables, or
any other path.

---

## 9. Acceptance Criteria

- Equipping a Shortbow, Longbow, or Crossbow produces 1.64s, 2.36s, and 2.90s respectively.
- Existing bows load as the same tier Longbow with quality and stats unchanged.
- The off-hand slot is unlocked only while a one-handed weapon is equipped.
- Equipping a two-handed weapon with a shield equipped stows the shield, and refuses the swap
  with a named reason if the inventory is full.
- Equipping a shield with a two-handed weapon equipped is refused with a named reason and does
  not unequip the weapon.
- The character page shows the off-hand slot in a locked state, not a hidden one, when a
  two-handed weapon is equipped.
- A crossbow Warden can equip a Crossbow, a Quiver, and a Shield at the same time.
- Damage resolves in the order evade, block, mitigate.
- Block reduces damage by a percentage on a chance. It never fully negates.
- Mitigation is capped so at least 25 percent of every raw hit lands.
- A Crossbow cannot trigger the Bowstring weak-point crit under any condition.
- A Crossbow keeps quiver coatings and bleed scaling.
- Per-swing procs on a Crossbow land at the same rate per second as on a Shortbow.
- `isOneHanded` is true on Crossbow and false on every other weapon type.

---

*Path: docs/warden-weapons-shield-spec.md*
*Shortbow 1.64s, Longbow 2.36s, Crossbow 2.90s and one-handed. New OffHand slot, shields with*
*a chance-to-reduce block channel returning 16 to 25 percent effective HP. Crossbow pays 5 to*
*11 percent DPS in idle and 23 to 28 percent in active play, which makes it the idle build*
*rather than a trap or a must-pick.*
