# Shields Beyond the Crossbow + the Crossbow Progression Gap, Design Request
### Two follow-ups to warden-weapons-shield-spec.md v1.0, now that it is built. Requesting Chat's spec.

---

`warden-weapons-shield-spec.md` v1.0 is implemented and about to be compiled. It shipped the crossbow
(one-handed), a shield off-hand, and a player block channel. Two things it deliberately left open now need
a design pass, and Dustin wants them designed together because they share the same slot and the same block
system.

Read `implementation-status.md` (the 2026-09-04 Warden entry is the current as-built state), then
`warden-weapons-shield-spec.md` v1.0 (this extends it), `combat-attack-speed-spec.md` v1.0 (the speed/damage
table), and the Vanguard + Arcanist subclass specs (combo and casting mechanics these questions touch).

## As-built facts (not visible in code to Chat)

- **Shields are ordinary `ItemData` on `EquipmentSlot.OffHand`, not a separate `ShieldData` type.** Block
  stats derive from (quality, tier) through a `ShieldStats` table, mirroring how every other piece derives
  from its type: block CHANCE by quality (Crude 20% to Masterwork 34%), block REDUCTION by tier (T1 50% to
  T5 58%), plus a token 2-per-tier armour rating and an authored-but-inert +15% aggro (Phase 4).
- **Handedness is TYPE-DERIVED, not authored per item.** `ItemData.IsOneHanded => weaponType == Crossbow`.
  The off-hand slot unlocks only while a one-handed weapon is equipped; a two-handed weapon stows any shield
  first (refused if the bag is full), and a shield is refused unless a one-handed weapon is in hand.
- **The block channel resolves evade -> block -> mitigate** in `ResolveEnemyAttack`: a chance to REDUCE the
  hit by a percentage, never to negate it. Mitigation is capped at 75% of the raw hit (so at least a quarter
  always lands). This is generic to the player, not Warden-specific.
- **`damageFactor` scales the weapon's damage BAND only** (not the stat term or accuracy). A one-handed
  weapon expressing a "minor attack penalty" is just a lower `damageFactor` on that type. The crossbow, for
  reference, is speed factor 1.45 (2.90s) / damage factor 1.34.
- **Weapons are NOT path-gated in code.** Any path can equip any weapon; class fit comes from favoured stats
  and mechanics, not a hard gate. So "Warden-only" or "Vanguard-only" is not enforced by the equip system
  today. If a class restriction is wanted, say so and it becomes new work.
- **The Bowstring weak-point is gated OFF for the crossbow** (it resolves as pure auto-fire). Draw-strength
  techniques (Full Draw, Aimed, Long Shot, hold thresholds) all key on draw time, which a crossbow does not
  have. Quiver coatings, bleed scaling, and the Reinforced Quiver second coating slot are all KEPT.
- **Brace (the crossbow's hold-to-defend active) has data hooks but no input wiring.** `PlayerData.braceActive`
  plus `GetBlockChance`/`GetBlockReduction` fold in the +25pt chance / 75% reduction boost when set; nothing
  sets it yet. Spec 5.2 allowed shipping auto-fire first, so this is deferred, not cut.

---

## Question 1, the crossbow progression gap (spec 5.3)

Most of the Warden technique ladder gates on draw strength. A crossbow user loses those unlocks entirely, so
a Warden who commits to crossbow watches most of their technique tree arrive as dead entries. That reads as
broken, and it is a progression problem, not a balance one. Spec 5.3 named two answers:

- **Convert draw-gated techniques to passive equivalents when a crossbow is equipped**, so each unlock still
  does something (cheaper).
- **Author a short crossbow-specific branch of five or six unlocks** that fills the same levels (better).

Dustin leans toward a small passive-conversion pass now and a dedicated branch later. Design the answer:
which techniques convert to what passive form, at which levels, and what (if any) short crossbow branch fills
the gaps. Keep it concrete enough to author against the real technique list. If a technique has no sensible
passive form, say so and give the branch entry that replaces it.

## Question 2, shields for sword, axe, and wand (spec 7)

Dustin wants the shield to reach beyond the crossbow: a **one-handed sword, axe, and wand**, each able to
carry a shield, trading a **minor attack penalty for the block channel's defence.** This is the Vanguard
"sword and board" and an Arcanist "battlemage" archetype. Design it. The open questions the spec flagged:

- **Handedness model.** Two candidates. (a) Per-type one-handed VARIANTS, an Arming Sword vs a Greatsword,
  a Hand Axe vs a Battle Axe, a one-handed Wand vs a Staff, authored like Shortbow/Longbow/Crossbow, where
  the one-handed variant simply carries a lower `damageFactor` (that IS the attack penalty) and unlocks the
  off-hand. (b) A universal rule: any weapon may pair with a shield at a flat attack penalty, decoupling
  shields from weapon type. Recommend one. Code note: (a) drops into the existing type-based handedness and
  `damageFactor` design with zero new mechanic; (b) needs a new penalty channel and breaks the "one-handed
  is a property of the type" model. Give the exact `damageFactor` (or penalty) numbers either way, sized so
  the shield's ~16-25% effective HP is paid for by a MINOR attack loss, not a wash.
- **Vanguard aggro.** Vanguard aggro is already the highest in the game. The shield's flat +15% aggro may be
  too much on top. Decide whether a shield-bearing Vanguard keeps +15%, gets a reduced value, or none.
- **Combo gating.** Do Vanguard combos gate on being two-handed, the way Warden draw techniques do? If a
  one-handed sword loses combos, it needs the same passive-conversion treatment as Question 1. If it keeps
  them, say why that is not a strictly-better answer versus the two-handed weapon.
- **Arcanist wand identity.** Should a wand ever be one-handed? Spec 7 calls this an identity question, not a
  mechanical one. A wand + shield battlemage trades cast power for durability; decide whether that fits the
  Arcanist fantasy or dilutes it, and if it ships, what the wand loses (band, cast speed, or a mechanic).
- **Per-class shield restriction.** Since weapons are not path-gated, a shield today is reachable by anyone
  holding a one-handed weapon. Decide whether shields (or specific one-handed weapons) should be soft- or
  hard-restricted per path, or left open with stat incentives doing the steering as they do now.

## What Chat should return

One spec resolving both questions: the crossbow technique-conversion table (Q1), and the sword/axe/wand
one-handed model with exact numbers plus the four class decisions (Q2). Flag anything that needs a new system
versus anything that drops into the as-built handedness / `damageFactor` / block architecture, so the build
scope is clear before authoring. Sword-and-board should not require a combat rewrite; if it does, that is the
first thing to surface.

---

*Path: docs/shields-crossbow-followup-REQUEST.md*
