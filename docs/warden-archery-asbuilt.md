---
type: as-built-reconciliation
for: Chat, fold this into warden-combat-spec.md (and stat/combat formulas where noted)
updated: 2026-07-11
status: the Warden bow was redesigned in-engine via playtesting; it DIVERGES from
        warden-combat-spec v0.1 (draw-power "ability ring"). This file is the as-built truth.
---

# Warden Archery, As-Built (reconcile into warden-combat-spec)

The Bowstring was rebuilt from feel testing and no longer matches the spec's draw-power /
ability-ring model. Everything below is what actually ships in code today. Please update
`warden-combat-spec.md` to match, then design the ability layer (below) on top of it.

## Input model (as-built)
- **Aim = horizontal, absolute around a fixed screen reference** (`Aim Center X`, default 0.5 =
  screen centre), NOT relative to where the player taps. Dragging the finger left of centre
  sends the shot RIGHT (inverted, `_invertSteer` to flip). Steer is ease-in softened
  (`_steerResponse`). Enemies are centred, so finger-near-centre = straight shot.
- **Draw = vertical pull-back**, ease-in softened (`_drawResponse`). Draw power maps to the
  arc's **loft/apex height** (`_arcPeakMin`→`_arcPeakMax`): **more draw = bigger arch**.
- **No draw-% bar.** The **arc itself is the feedback**: a live trajectory LineRenderer previews
  the parabola while drawing, tinted green when it would hit, with a `_trajectoryReveal` slider
  that truncates the line so the exact landing can be hidden for skill.

## Hit resolution (as-built), replaces draw-power damage
- The arrow's parabola is **traced with Physics.Linecast against the enemy's MeshCollider**.
  **Hit = the arc physically passes through the body.** There is NO draw-matches-distance number.
- **Vertical aim comes from the arc**: a flat/low draw crosses the body low; a big-draw high arch
  drops onto the head. So *draw is effectively the vertical aim* onto the sprite.
- **Weak point = the hit UV** sampled against `EnemyData.weakPointMask` (fixed ×2.0). Optional
  per-idle-frame `EnemyData.idleMasks[]` move the weak spot with the animation. Loft onto a
  masked head → crit.
- **Then stats decide the rest**: a landed active shot rolls **player accuracy vs enemy Evasion
  (Evaded) and Block (Blocked)**, no pure-RNG "miss" on a well-placed shot. Outcomes surfaced to
  the player: **Hit / Miss (skill: off-body) / Evaded / Blocked**. Idle auto-attack keeps the old
  full-RNG accuracy model.

## Enemy depth (as-built)
- `EnemyData.combatRange` (Close / Medium / Far / VeryFar) → a **fixed world-Z per enemy**
  (a constant trait, not RNG, same every spawn). Perspective + a ground-plane Y-rise + a ~10°
  downward camera tilt make distance read (farther = higher on screen AND smaller).

## HP / recovery (as-built), differs from "full heal on death"
- **HP persists between fights.** Death = **retreat to the hub, no free heal.** HP **regenerates
  over time only OUT of battle** (`_hpRegenFraction`, ~3%/s). In combat you recover via food /
  the idle auto-eat, not passively.

## Enemy animation (as-built, engine capability now exists)
- `EnemyData` has optional `idleFrames` / `attackFrames` / `deathFrames` (Sprite[]) + `animFPS`,
  falling back to the static `icon`. Idle loops; attack plays once→idle; death plays once→hides.

---

## Divergence from warden-combat-spec v0.1 + open questions for Chat
The spec has draw *time/power* driving damage and an **ability ring**: Standard (0.3s) → Barbed
Shot (1.0s, bleed) → Full Draw (1.5s) → Long Shot (3.0s, 800%, 90s CD), plus a **Model C ability
row** (Fade / Vanishing Act, Armor Piercer). **None of that ability layer is built**, only the
core arc/aim/hit loop above is.

Please re-spec so the ability layer sits ON TOP of the as-built arc mechanic. Decisions needed:
1. **What triggers the special shots** now that draw = loft (not a timed charge)? e.g. a separate
   hold-to-charge, a button, or a full-draw+hold gesture? How do Barbed Shot / Long Shot fire?
2. **Long Shot** (800% / 90s CD) and **Barbed Shot** (bleed) as chargeable specials layered on the
   arc, define their input + cooldown UI in the touch layout.
3. **Sharpshot vs Lone Wanderer**, differ by arc tuning, ability set, or both?
4. **Model C ability row** (Fade, Armor Piercer), placement in the combat HUD.
5. **Reveal talents** (Lone Wolf's Eye L38 / Deadeye L59) → wire to the Hidden weak-point tier
   (`WeakPointTier.Hidden` already exists; `ZoneCombatView.HasWeakPointRevealTalent()` is stubbed).
6. **Damage formula**, confirm base damage now comes from stats (not draw power), with weak-point
   ×2 and evade/block as the variance. Update stat-scaling-combat-formulas if so.

## Warden remainder (not built)
Ability ring, Long Shot / Barbed Shot specials, Model C row, reveal talents, per-subclass tuning.
