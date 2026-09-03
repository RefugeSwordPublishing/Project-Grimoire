# Warden Weapon Types + Shield / Off-Hand, Design Request
### Filling the Warden weapon-speed gap with three bows, one of them shield-capable. Requesting Chat's spec.

---

The attack-speed system (combat-attack-speed-spec.md v1.0) gives Arcanist a Wand/Staff speed choice and
Vanguard a Sword/Dagger/Axe spread, but Warden has one weapon (Bow) at the baseline, so the system does
nothing for it. Dustin wants three Warden bows: **shortbow** (fast), **longbow** (slow, steady), and
**crossbow** (one-handed, much slower, but frees the off-hand for a SHIELD). The crossbow is the point,
it gives Warden a defensive, tanky-ranged archetype no other path has.

Read `implementation-status.md`, then `combat-attack-speed-spec.md` (the speed table this extends),
`slaying-talent-spec.md` / the Warden subclass spec (Bowstring + Marksmanship mechanics), and
`stat-scaling-combat-formulas.md` (the damage/defense formula).

## As-built facts (not visible in code to Chat)

- **WeaponType enum:** None, Bow, Sword, Dagger, Staff, Wand, Axe. There is ONE Bow today; bows are
  authored per tier (Bronze / Iron / Steel / Mithril / Void Bow).
- **WeaponSpeed table (just shipped):** each type has a speed factor (interval = 2.0s base x factor) and a
  damage factor scaling the weapon BAND only. Bow is currently 1.00 / 2.00s / 1.00. New bow types extend
  this table; no new mechanic is needed for their speed.
- **EquipmentSlot enum:** None, Weapon, Helm, Chest, Legs, Boots, Gloves, Quiver, Grimoire, Accessory.
  There is NO off-hand / shield slot.
- **The Quiver is a SEPARATE worn slot, not the held off-hand.** Warden equips a Bow (Weapon) AND a Quiver
  at the same time; the quiver rides on the back. It boosts the Warden kit: bleed DoT scales with quiver
  tier, and a Reinforced Quiver unlocks a second weapon-coating slot (WardenTechniqueLibrary). So a shield
  does NOT compete with the quiver, a crossbow build would keep its quiver (bolts + coatings) AND add a
  shield. The shield needs a brand-new off-hand slot.
- **There is no weapon "handedness" concept.** Every weapon occupies only the Weapon slot; nothing gates an
  off-hand today.
- **Block is ENEMY-only.** The player takes a block roll against `enemy.blockChance`; the PLAYER has no
  block channel. Player defense today is `armorRating` (flat mitigation) + an evasion rating. A shield that
  actually does something means adding player-side block, which is new.
- **Bowstring weak-point is a Warden-only DRAW mechanic** (active aim gives a damage multiplier + the
  weak-point crit). A crossbow is point-and-shoot with no draw, so it cannot use the same mechanic.

## Decisions already leaning (design within, or push back)

- Keep shields **Warden-crossbow-only for now.** Do NOT reclassify every weapon's handedness. Shortbow and
  longbow stay two-handed (no off-hand), and only the crossbow is one-handed and shield-capable. Sword +
  shield for Vanguard is a natural future extension, flag it but do not scope it here.
- The crossbow **trades the Bowstring weak-point crit for the shield.** Aim-for-crit bow vs defensive
  crossbow is the intended fork. Confirm and say how the mechanic gates on bow type.

## Design asks (spec these)

1. **Three bow types + speed/damage.** Add Shortbow, Longbow, Crossbow to the WeaponSpeed table with speed
   factors and matching damage factors in the spirit of the existing table (Dustin: shortbow fast,
   longbow steady/slow, crossbow much slower). Give exact numbers and the resulting DPS index, and say
   whether these are new `WeaponType` enum values or the existing Bow plus an archetype field (and the item
   authoring that implies: do the existing per-tier bows become one archetype, or split three ways?).
2. **Handedness + shield off-hand slot.** Define how a one-handed weapon (crossbow) unlocks a new off-hand
   / shield slot while two-handed weapons leave it blocked. Where the slot lives (new EquipmentSlot), what
   happens to an equipped shield if the player swaps to a two-handed bow, and how the character page shows it.
3. **Shield items + player-side block.** The shield's stats (a block chance and/or block mitigation, plus
   armour), how it tiers, and the new player-block formula, reconciled with the existing `armorRating` +
   evasion so defense does not double-dip. Give the damage-resolution order (evade, then block, then
   mitigate). State whether block is a chance-to-halve, a flat reduction, or a full negate, and why.
4. **The crossbow archetype + balance.** Crossbow loses DPS to its slow speed and loses the weak-point
   crit, and gains survivability from the shield. Target the tank-ranged identity: quantify the DPS it
   gives up and the effective-HP the shield returns, so the build is a real choice, not a trap or a
   must-pick. Note the interaction with aggro (a tankier Warden may want more aggro to matter).
5. **What the crossbow does for a mechanic**, since it has no draw. Does it keep the rest of the Warden
   technique kit (coatings, bleeds via quiver) minus the weak-point, does it auto-fire only, or does it get
   a small crossbow-specific active? Keep it idle-friendly.

## Constraints

- Mobile-first, idle-friendly. Reuse the existing slot/stat/damage systems; this is a data + one-slot +
  one-formula addition, not a combat rewrite.
- UI is authored/skinned in Unity (baked, populate-only), so name any new character-page slot region.
- House style: no em/en dashes, no emojis, direct phrasing.

**Deliver:** the three bow types (speed/damage + enum/authoring plan), the handedness + off-hand slot rules,
the shield item stats + the player-block formula and its place in damage resolution, the crossbow archetype
targets, and the crossbow's mechanic. Flag sword+shield as a future extension.

---

*Path: docs/warden-weapons-shield-REQUEST.md*
