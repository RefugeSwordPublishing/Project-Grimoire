# Weapon Handedness Revision, Design Request
### Simplify the one-handed model: base melee + wand are one-handed and shield-capable; drop the per-type 1H variants. Requesting Chat's spec.

---

Dustin is revising the handedness design from `shields-crossbow-followup-spec.md` v1.0. That spec added
one-handed VARIANTS (Arming Sword, Hand Axe) so a shield had something to pair with while the base Sword/Axe
stayed two-handed. Dustin's simpler intent: **the base melee weapons and the wand are just one-handed, so a
shield attaches to them directly, and the separate 1H variants go away.**

Read `implementation-status.md` (the as-built state), then `warden-weapons-shield-spec.md` v1.0 and
`shields-crossbow-followup-spec.md` v1.0 (the two specs this revises), and `combat-attack-speed-spec.md`
v1.0 (the speed/damage table).

## The revised handedness (Dustin's call)

| Weapon | Hands | Shield? |
|---|---|---|
| Sword | One | Yes |
| Dagger | One | Yes |
| Axe | One | Yes |
| Wand | One | Yes |
| Crossbow | One | Yes |
| Staff | Two | No |
| Shortbow | Two | No |
| Longbow | Two | No |

The through-line: **almost everything is one-handed and shield-capable; the two-handed weapons are Staff and
the two drawn bows (Shortbow, Longbow), which is exactly the set that trades the off-hand for raw power.**
Crossbow stays one-handed (its whole identity is the durable ranged build). Wand vs Staff becomes the clean
Arcanist fork: one-handed wand (battlemage, can shield) vs two-handed staff (more power, no shield).

**Drop Arming Sword and Hand Axe entirely** (the WeaponType values, the 10 ItemData, and their tracker
slots). They only existed to be the 1H version of a 2H weapon; with the base weapon now 1H they are redundant.

## As-built facts (not visible to Chat)

- **`WeaponType` enum:** None, Bow (deprecated -> Longbow), Sword, Dagger, Staff, Wand, Axe, Shortbow,
  Longbow, Crossbow, ArmingSword, HandAxe. Handedness is `ItemData.IsOneHanded`, currently true for
  Crossbow, ArmingSword, HandAxe, Wand. This revision makes it true for Sword, Dagger, Axe, Wand, Crossbow,
  and false for Staff, Shortbow, Longbow. ArmingSword/HandAxe get removed.
- **`WeaponSpeed` table (speed factor / damage factor), as-built:** Dagger 0.70/0.74, Wand 0.80/0.72,
  Shortbow 0.82/0.85, ArmingSword 0.90/0.80, Sword 0.95/0.96, HandAxe 1.10/0.94, Staff 1.15/1.13,
  Longbow 1.18/1.15, Axe 1.25/1.20, Crossbow 1.45/1.34. `damageFactor` scales the weapon damage BAND only.
- **Shields + block are built and live:** off-hand slot (`EquipmentSlot.OffHand`), `ShieldData`-equivalent
  block channel (chance to REDUCE, never negate; chance by quality 20-34%, reduction by tier 50-58%; ~16-25%
  effective HP), resolving evade -> block -> mitigate. Equipping a 2H weapon stows the shield; a shield needs
  a 1H weapon equipped. Migration 060/061 (lobby member state, unrelated) is separate; the block channel is
  client-side. None of the shield mechanics change here, only WHICH weapons unlock the off-hand.
- **The prior spec's balance model:** it priced the 1H variants ~13% below the two-handed DPS gradient (the
  band cut was the price of the off-hand), and gave the Wand a band cut (0.83 -> 0.72) for going one-handed.
  With this revision there is no per-type 1H/2H pair, so that pricing mechanism no longer applies as written.

## The balance question this revision creates (the real design work)

If a Sword is inherently one-handed and shield-capable at no damage cost, a shield becomes free defense and
the off-hand "shield vs nothing" fork is weak. The tension has to move to the **two-handed weapons**:

**Recommended direction to evaluate:** two-handed weapons (Staff, Shortbow, Longbow) carry a **damage
premium** precisely because they give up the shield, and one-handed weapons sit lower. That turns weapon
choice itself into the "raw power vs durability" fork, at the archetype level, with no per-type variants:
- Go two-handed (staff / drawn bow) for the higher band, no shield.
- Go one-handed (sword / axe / dagger / wand / crossbow) for a shield and steady durability at a lower band.

Design the numbers: rebalance the `WeaponSpeed` damage factors so the 2H weapons sit a defensible margin
above their 1H counterparts (the shield returns ~16-25% effective HP, so the 2H premium should be sized
against that, the same way the old spec sized the 1H penalty). Confirm whether the off-hand should ever hold
anything other than a shield for a 1H build (empty vs shield is the only fork today), or whether that is fine.

## What Chat should return

One spec that:
- States the final handedness table and updates `IsOneHanded`.
- Removes ArmingSword and HandAxe (enum values, the 10 ItemData, tracker slots), and says what a player
  holding one becomes on load (migrate an Arming Sword to a Sword, a Hand Axe to an Axe).
- Rebalances the `WeaponSpeed` damage factors for the new 1H/2H split (2H premium vs 1H, sized against the
  shield's effective-HP return), including the Wand (revisit the 0.72 cut) and Staff.
- Resolves the four class angles briefly: Vanguard (sword/axe now 1H + shield), Warden (crossbow 1H, bows 2H),
  Arcanist (wand 1H vs staff 2H battlemage fork), and whether Vanguard shield aggro (currently 10%) still fits.
- Flags anything that needs a save migration or new work versus a pure data change.

Keep the shield block channel, the off-hand slot, and the resolution order as-is; this is a handedness +
weapon-balance revision, not a shield-system change.

---

*Path: docs/weapon-handedness-revision-REQUEST.md*
