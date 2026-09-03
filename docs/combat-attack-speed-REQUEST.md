# Combat Attack Speed, Design Request
### Weapon-type + enemy attack speed, and a tick-based timing model. Requesting Chat's spec.

---

Right now every weapon swings at the same speed and most enemies attack at one default cadence. We want
attack speed to matter: faster, lighter weapons vs slower, heavier ones, and enemies that feel noticeably
faster or slower than each other. Dustin also wants the auto-eat / timing logic to run on ticks rather
than raw real-time delays.

Read `implementation-status.md` first, then `stat-scaling-combat-formulas.md` and
`slaying-talent-spec.md` if you need the combat context. This is a NEW system layered on the existing
real-time loop.

## As-built facts (not visible in code to Chat)

- **Combat is real-time**, not turn/tick based. The player and each enemy attack on their own independent
  timer. Idle mode auto-fires the player attack when its timer fills.
- **Player attack interval is a flat 2.0s for every weapon** (`_playerAttackInterval`). Weapon TYPE does
  not affect speed at all today.
- **Enemy attack interval** defaults to 2.8s, but `EnemyData.attackCadence` already lets each enemy
  override it per-enemy. The field exists on every enemy; most are left at the default. Slows extend the
  interval (`EnemyInterval = baseCadence * (1 + slowFactor)`), and the attack-timer bar already renders
  this, so a slower enemy is already visible if its cadence is set.
- **Weapon damage** is a min-max band from **quality x material tier** (`EquipmentStats.WeaponDamage`),
  NOT from weapon type. Weapon TYPE currently only sets the favoured primary/secondary STAT it grants
  (`WeaponPrimary` / `WeaponSecondary`) and a small accuracy bonus (`WeaponAccuracyBonus`). There is no
  weapon speed stat anywhere.
- **WeaponType enum**: Bow, Sword, Dagger, Staff, Wand, Axe. Path mapping (roughly): Warden uses Bow;
  Arcanist uses Staff / Wand; Vanguard uses Sword / Dagger / Axe (confirm against the subclass specs).
- **Auto-eat (just reworked, for context):** now a PAID upgrade (no free tier). Three tiers trigger at
  30% / 40% / 70% HP, always drink the best-quality draught, and are limited only by potions carried.
  Timing is still a flat 2.0s delay, this is one of the things the tick model should absorb.

## Design asks (spec these)

1. **Weapon-type attack speed + damage tradeoff.** Give a concrete table for all six weapon types with a
   speed multiplier (or interval) and the matching per-hit damage adjustment, so faster weapons hit for
   slightly less and slower weapons hit for slightly more. Target rough DPS parity with a real feel
   difference, not one type strictly better. Dustin's examples: Dagger faster than Sword; Wand faster than
   Staff at slightly lower damage. Cover Bow and Axe too. State how the player attack interval derives from
   the equipped weapon (base interval x the type's speed factor), and how the per-hit damage adjustment
   composes with the existing quality x tier band WITHOUT double-counting the favoured-stat / accuracy
   channels those types already grant.
2. **Enemy attack-speed spread.** Guidance for authoring `attackCadence` across enemies so speed reads as a
   trait: faster skirmishers, slower brutes, banded by role / faction / tier. Keep the margin noticeable
   but not large (Dustin: "not by a large margin"). Give a target range (e.g. fastest vs slowest as a
   percentage of the 2.8s baseline) and a handful of example cadences by archetype, plus whether bosses
   sit inside or outside that band.
3. **Tick model.** Decide whether combat timing should move onto a tick (fixed cadence) system or stay
   continuous. If ticks: define the tick length, how attack intervals, DoTs, HP/mana regen, slows, and
   auto-eat / auto-drink all quantize to it, and how the existing per-timer bars keep reading smoothly.
   If staying continuous: say how auto-eat's "work in ticks" intent is best satisfied (e.g. evaluate on a
   fixed sub-second cadence) without a full rewrite.
4. **Interaction + balance.** How weapon speed interacts with the accuracy bonus and the favoured-stat
   channel; whether attack speed should be shown on the item card (it now would matter); and any PvE
   balance guardrail so a very fast weapon plus auto-eat doesn't trivialize content.

## Constraints

- Mobile-first, idle-friendly (most combat is auto-fired while idle).
- Reuse the existing timers/bars where possible; this should be a data + formula layer, not a rewrite.
- House style: no em/en dashes, no emojis, direct phrasing.

**Deliver:** the weapon-type speed/damage table, the enemy-cadence authoring guidance with example values,
the tick-vs-continuous decision with the timing quantization, and how auto-eat hooks into it.

---

*Path: docs/combat-attack-speed-REQUEST.md*
