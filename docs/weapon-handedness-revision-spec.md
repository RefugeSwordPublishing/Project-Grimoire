---
type: design-spec
version: 2.1
updated: 2026-09-04
path: docs/weapon-handedness-revision-spec.md
resolves: weapon-handedness-revision-REQUEST.md
supersedes: shields-crossbow-followup-spec.md v1.0 sections 5 and 6.1 to 6.3
extends: combat-attack-speed-spec.md v1.0
scope: handedness plus weapon balance. No change to the shield block channel,
       the off-hand slot, or the damage resolution order.
---

# Weapon Handedness Revision
### Version 2.0

---

## 0. The Headline

**Two numbers change and one weapon is added.** Wand goes from 0.72 back to 0.83, Staff goes
from 1.13 to 1.37, and a two-handed **Greataxe** joins the table so Vanguard has the same
power-versus-durability fork the other two paths get. Every other weapon keeps its as-built
speed and damage factor exactly.

**The roster shrinks.** Two enum values out and one in, ten ItemData out and five in. Net one
fewer weapon type and five fewer items than today.

**One piece of new code.** An item-id remap in the inventory load path, so a saved Arming
Sword resolves to a Sword. Everything else in this document is data.

**One thing the request recommended that I am not doing.** Two-handed weapons do not all get a
damage premium. Only the Staff does. Section 3.2 explains why giving the bows one would break
the crossbow.

---

## 1. Final Handedness

| Weapon | Hands | Shield | Path fit |
|---|---|---|---|
| Sword | One | Yes | Vanguard |
| Dagger | One | Yes | Vanguard |
| Axe | One | Yes | Vanguard |
| Wand | One | Yes | Arcanist |
| Crossbow | One | Yes | Warden |
| Greataxe | Two | No | Vanguard |
| Staff | Two | No | Arcanist |
| Shortbow | Two | No | Warden |
| Longbow | Two | No | Warden |

```csharp
// ItemData
public bool IsOneHanded => weaponType is WeaponType.Sword
                                       or WeaponType.Dagger
                                       or WeaponType.Axe
                                       or WeaponType.Wand
                                       or WeaponType.Crossbow;
```

Pure data change. Nothing else in the equip path moves: the off-hand still unlocks on a
one-handed weapon, a two-handed weapon still stows any shield, and a shield is still refused
without a one-handed weapon in hand.

### 1.1 The off-hand stays shield-only, and the weak fork is not a problem

The request asks whether the off-hand should ever hold something other than a shield, given
that "shield versus nothing" is a thin choice.

**It should stay shield-only, and the thin choice is fine, because it stopped being the fork.**

An empty off-hand on a one-handed build is not a decision, it is an unfilled slot, exactly like
an empty helm. Nobody agonises over whether to wear a helm. The real fork moved up a level to
weapon choice: take a two-handed weapon for the band premium, or a one-handed weapon and fill
the off-hand. Once the player has chosen one-handed, equipping a shield is the obvious
follow-through and it should be.

Off-hand alternatives such as a torch, a focus, or a parrying dagger would add texture later.
They are new content, not a fix for anything, and nothing in this design needs them.

---

## 2. Removing ArmingSword and HandAxe

### 2.1 What goes

| Item | Action |
|---|---|
| `WeaponType.ArmingSword`, `WeaponType.HandAxe` | Deprecate now, delete one release later |
| `WeaponType.Greataxe` | Add |
| 5 Arming Sword ItemData, 5 Hand Axe ItemData | Delete |
| 5 Greataxe ItemData, Bronze through Void | Add |
| ArmingSword and HandAxe `WeaponSpeed` rows | Delete |
| Greataxe `WeaponSpeed` row | Add |
| Their asset tracker slots | Delete ten, add five |

**Deprecate the enum values rather than deleting them immediately**, mirroring how `Bow` was
handled. A save referencing a deleted enum value can fail to deserialize, and the failure lands
on the player's inventory, which is the worst place for it. Keep the values, map them on load,
delete once no live save can reference them.

### 2.2 Migration

An Arming Sword becomes a Sword of the same tier and quality. A Hand Axe becomes an Axe.
Ten id mappings.

```csharp
// Consulted during inventory and equipment deserialization,
// BEFORE the ItemData lookup, since the target assets are gone.
static readonly Dictionary<string,string> ItemIdMigrations = new() {
    ["arming_sword_bronze"]  = "sword_bronze",
    ["arming_sword_iron"]    = "sword_iron",
    ["arming_sword_steel"]   = "sword_steel",
    ["arming_sword_mithril"] = "sword_mithril",
    ["arming_sword_void"]    = "sword_void",
    ["hand_axe_bronze"]      = "axe_bronze",
    ["hand_axe_iron"]        = "axe_iron",
    ["hand_axe_steel"]       = "axe_steel",
    ["hand_axe_mithril"]     = "axe_mithril",
    ["hand_axe_void"]        = "axe_void",
};
```

**Client-side on load, not a bulk SQL migration.** Player inventory and equipment are own-row
RLS and the client already reads and rewrites its own rows, so remapping at load handles every
player the moment they log in, with no bulk update against live player data and no window where
a partially migrated row exists. The stale ids sit harmlessly in the database until each player
next plays.

A bulk SQL pass is optional cleanup later. It is not needed for correctness.

**The upgrade path is neutral.** An Arming Sword and a Sword of the same tier and quality
differ only in `damageFactor`, so a migrated weapon becomes slightly stronger (0.80 to 0.96 at
the same speed band). Nobody loses anything, which is the right direction for a forced
conversion.

---

## 3. Rebalancing the Damage Factors

### 3.1 The reference curve inverts

The `combat-attack-speed-spec.md` gradient, `index(s) = 1.057 - 0.176 * (s - 0.70)`, was
previously the **two-handed baseline** with one-handed variants priced 13 percent below it.

With most weapons now one-handed, that reading flips. **The curve is now the one-handed
baseline, and a two-handed weapon earns a premium above it.**

That single reframing is why almost nothing changes. Dagger, Sword, Axe, and Crossbow were
already on the curve and stay exactly where they are. The Wand's 0.72 was a one-handed penalty
that no longer has a concept behind it, so it reverts. Only the Staff needs a new number.

### 3.2 The bows do not get a premium, and this is the important call

The request recommends a damage premium on all three two-handed weapons. Applying it to the
bows would break the crossbow.

A bow's advantage over a crossbow is already the Bowstring weak point, which
`warden-weapons-shield-spec.md` costs at roughly 24 percent of active damage. That mechanic
**is** the two-handed premium for Warden, and it is a large one. Stacking a band premium on top
would put a shortbow 42 percent ahead of a crossbow in active play, at which point the crossbow
is not a durable build, it is a mistake.

So Shortbow and Longbow keep their as-built values, and the crossbow's v1.0 pricing survives
this revision unchanged. The Warden fork was already correct and did not need touching.

The Staff is different because it has no mechanical differentiator at all. Wand and Staff both
cast through the constellation, so the only levers are cast interval and damage band. Without a
band premium there is no reason to hold a Staff.

**The general rule worth carrying forward: a two-handed weapon earns a band premium only when
it has no mechanical advantage to serve as one.**

### 3.3 The final table

| Weapon | Hands | Speed | Interval | Damage | DPS index | Change |
|---|---|---|---|---|---|---|
| Dagger | 1H | 0.70 | 1.40s | 0.74 | 1.057 | unchanged |
| Wand | 1H | 0.80 | 1.60s | **0.83** | 1.037 | 0.72 to 0.83 |
| Shortbow | 2H | 0.82 | 1.64s | 0.85 | 1.037 | unchanged |
| Sword | 1H | 0.95 | 1.90s | 0.96 | 1.011 | unchanged |
| Staff | 2H | 1.15 | 2.30s | **1.37** | 1.191 | 1.13 to 1.37 |
| Longbow | 2H | 1.18 | 2.36s | 1.15 | 0.975 | unchanged |
| Axe | 1H | 1.25 | 2.50s | 1.20 | 0.960 | unchanged |
| **Greataxe** | 2H | **1.35** | **2.70s** | **1.49** | **1.104** | new |
| Crossbow | 1H | 1.45 | 2.90s | 1.34 | 0.924 | unchanged |

Greataxe becomes the highest damage factor in the game and the slowest melee weapon, which is
what a two-handed axe should be. Staff sits above the slightly slower Longbow, which is correct
rather than an error: the Longbow carries the Bowstring and the Staff carries nothing, so the
Staff has to pay for itself in the band.

The three slowest weapons separate cleanly at 2.50s, 2.70s, and 2.90s, so Axe, Greataxe, and
Crossbow each read distinctly in the hand.

### 3.4 Sizing the Staff premium

The shield returns 16 to 25 percent effective HP depending on quality and tier, with a
realistic mid-game shield around 16 percent and a fully invested endgame one around 25.

**Staff sits 14.8 percent above Wand.** That lands just under a mid-game shield's return and
well under an endgame one, which means a player who actually invests in their shield comes out
slightly ahead on paper, and a player who equips whatever shield they found does not.

**Greataxe sits 15.0 percent above Axe**, deliberately matched to the Staff so both two-handed
premiums are the same size and neither path gets a better version of the same trade.

The trade stays content-dependent, which is the goal. DPS is worth more when clearing zones and
farming idle, and effective HP is worth more against a dungeon boss. Neither answer is correct
everywhere and both are correct somewhere.

**One caveat on reading the Greataxe against Dagger and Sword.** Its raw index is only 4.4
percent above Dagger and 9.2 percent above Sword, which looks like a weak premium against the
faster weapons. It is not, because the gradient in `combat-attack-speed-spec.md` already tilts
about 10 percent toward fast weapons to offset the fact that slow weapons extract more from
every crit and weak-point multiplier. Comparing Greataxe to Axe, its own line with the same
crit profile, is the honest comparison, and once crit scaling is included the roughly 15 percent
premium holds against all three.

### 3.5 Within-path forks after the change

| Path | Fork | Gap |
|---|---|---|
| Arcanist | Staff 2H vs Wand 1H plus shield | Staff +14.8 percent damage |
| Warden | Bows 2H vs Crossbow 1H plus shield | Crossbow 5 to 11 percent behind idle, 23 to 28 percent behind active |
| Vanguard | Greataxe 2H vs Sword, Dagger, or Axe 1H plus shield | Greataxe +15.0 percent damage over Axe |

---

## 4. The Four Class Angles

### 4.1 Vanguard gets the Greataxe, and the gap closes

Sword, Dagger, and Axe are all one-handed, so without a two-handed option every Vanguard would
be shield-capable and none could trade the off-hand for power. Warden and Arcanist would each
get that trade while the melee path, where greatsword versus sword and board is the most
familiar version of exactly that decision, would not.

**The Greataxe closes it with one weapon.** Two-handed, 2.70s, damage factor 1.49, sitting 15.0
percent above the Axe to match the Staff's premium over the Wand exactly. Vanguard's fork
becomes Greataxe for raw power against any of the three one-handed weapons plus a shield.

**Why the axe line and not the sword line.** The Axe is already the heaviest and slowest of the
three Vanguard weapons at 2.50s, so it is the one with a natural two-handed big brother. Sword
and Dagger stay the agile one-handed pair. That reads as a coherent weapon family rather than an
arbitrary hole, and it means one addition covers the gap instead of two.

A Greatsword remains available later if Vanguard ever wants a second two-handed option, using
the same premium against the Sword. It is not needed now and adding it would be the bloat this
revision is trying to avoid.

### 4.2 Warden is unchanged and was already right

Crossbow one-handed with a shield, Shortbow and Longbow two-handed with the Bowstring. No
number moves. The revision retroactively justifies the v1.0 crossbow pricing: the crossbow sits
on the one-handed curve because being one-handed is now the baseline, and it pays for its
shield with the weak-point loss rather than with a band cut.

### 4.3 Arcanist gains the cleanest fork in the game

Wand at 1.60s, one-handed, shield-capable, band 0.83. Staff at 2.30s, two-handed, band 1.37.

Fast and durable against slow and powerful, with no mechanical asymmetry muddying it, on the
path that most needs a defensive option given its 0.90 HP multiplier. This is the fork the
revision was designed to produce and it is worth the two changed numbers on its own.

The Wand reverting from 0.72 to 0.83 is not a buff so much as the removal of a penalty that
described a concept this revision deletes.

### 4.4 Shield aggro at 10 percent still fits, but its purpose changed

Under v1.0 a shield was rare, reachable only through a crossbow or one of the two variants now
being deleted, so 10 percent aggro was a build differentiator.

Now nearly every Vanguard carries one by default. Ten percent applied to nearly everyone shifts
the baseline without changing relative threat between players, which is the only thing threat
actually measures. Its remaining job is smaller: nudging a one-handed player to fill the
off-hand slot rather than leave it empty.

**Keep it at 10 percent.** It is inert until Phase 4, the value is defensible for its new
smaller purpose, and changing it now would be tuning a system nobody has played. The thing to
record is the reasoning change, so that whoever balances threat in Phase 4 knows the lever for
Vanguard aggro is Vanguard's base aggro and not the shield.

---

## 5. Build Scope

### 5.1 Pure data, no code

| Change | Where |
|---|---|
| `IsOneHanded` expression covers Sword, Dagger, Axe, Wand, Crossbow | One expression |
| Wand `damageFactor` 0.72 to 0.83 | `WeaponSpeed` table |
| Staff `damageFactor` 1.13 to 1.37 | `WeaponSpeed` table |
| Remove ArmingSword and HandAxe `WeaponSpeed` rows | `WeaponSpeed` table |
| Add Greataxe `WeaponSpeed` row, 1.35 and 1.49 | `WeaponSpeed` table |
| Add `WeaponType.Greataxe` | Enum |
| Delete 10 ItemData assets, add 5 Greataxe | Item assets |
| Remove 10 asset tracker slots, add 5 | Tracker |
| Shield aggro stays 10 percent | No change |

### 5.2 New code, one item

| Change | Where | Size |
|---|---|---|
| `ItemIdMigrations` consulted during inventory and equipment load | Deserialization path | One dictionary and one lookup |

### 5.3 Save migration

Client-side on load, section 2.2. No SQL migration required and none recommended.

### 5.4 Deferred by one release

Deleting `WeaponType.ArmingSword` and `WeaponType.HandAxe` from the enum, once no live save
can reference them.

### 5.5 Explicitly unchanged

The off-hand slot, the block channel, block chance and reduction tables, the evade then block
then mitigate resolution order, the mitigation cap, the equip swap and refusal rules, every
crossbow technique conversion from v1.0, and all three crossbow branch entries.

---

## 6. Acceptance Criteria

- `IsOneHanded` returns true for Sword, Dagger, Axe, Wand, and Crossbow, and false for Staff,
  Shortbow, Longbow, and Greataxe.
- Equipping a Sword, Dagger, Axe, Wand, or Crossbow unlocks the off-hand slot.
- Equipping a Staff, Shortbow, Longbow, or Greataxe stows any equipped shield and locks the slot.
- Wand `damageFactor` is 0.83, Staff is 1.37, and Greataxe is 1.49 at speed 1.35. No other
  weapon's speed or damage factor moves.
- Staff DPS index sits between 14 and 16 percent above Wand, and Greataxe the same above Axe.
- Five Greataxe ItemData exist, Bronze through Void.
- Vanguard combos function identically on a Greataxe.
- Shortbow, Longbow, and Crossbow damage factors are unchanged from as-built.
- A saved Arming Sword loads as a Sword of the same tier and quality, and a Hand Axe as an Axe.
- No inventory or equipment load throws on a save containing a removed item id.
- No Arming Sword or Hand Axe ItemData exists in the project.
- The project has one fewer WeaponType and five fewer weapon ItemData than before this change.
- No change is made to the block channel, the off-hand slot behaviour, or the damage
  resolution order.

---

*Path: docs/weapon-handedness-revision-spec.md*
*One-handed: Sword, Dagger, Axe, Wand, Crossbow. Two-handed: Staff, Shortbow, Longbow, Greataxe.*
*The gradient is now the one-handed baseline. Staff and Greataxe each earn a 15 percent two-handed*
*premium; the bows do not, because they already have the Bowstring. Two damage factors change,*
*ten ItemData are deleted and five added, and the only new code is an item-id remap on load.*
