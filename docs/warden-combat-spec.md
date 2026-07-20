---
type: design-spec
version: 0.2
updated: 2026-07-11
reconciled-to: warden-archery-asbuilt.md (2026-07-11)
---

# Project Grimoire — Warden Combat Spec
### Version 0.2

> **Reconciled to as-built.** The Bowstring was redesigned in-engine via playtesting
> and diverges significantly from v0.1. This spec matches what actually ships.
> See `warden-archery-asbuilt.md` for full as-built detail and divergence notes.

---

## Arc Mechanic — As-Built (do not redesign)

### Core Model

The Warden's active combat is an **arc-based aiming system** — not a timed charge.

```
Horizontal drag → horizontal aim (left/right of enemy)
Vertical drag   → draw power → arc loft (more draw = higher arch)
Release         → arrow follows the arc parabola into the scene
```

**Draw IS vertical aim.** A flat low draw hits the enemy low (body/legs). A high arch
drops onto the enemy from above, hitting the head. This is how the player aims at
weak points — by choosing the right loft, not by timing a window.

**No draw-% bar.** The live trajectory `LineRenderer` IS the feedback — it previews
the arc in real time, tinted green when it would pass through the enemy collider.
`_trajectoryReveal` truncates the line end so the exact landing can be hidden,
rewarding players who have learned to read loft at a glance.

### Hit Resolution

```
On release:
  Arc is Linecast-traced against the enemy's MeshCollider
  → if arc passes through: LANDED SHOT
      → sample hit.textureCoord against EnemyData.weakPointMask
      → weakPoint hit: × 2.0 damage multiplier
      → roll player Accuracy vs enemy Evasion and Block:
          Hit     → full damage
          Evaded  → 0 damage (enemy dodged)
          Blocked → 0.3× damage (enemy absorbed)
  → if arc misses collider: MISS (arc went past — aim error, not RNG)
```

**Active shots have no pure-RNG miss** — a well-placed arc always lands.
The skill is choosing the right loft and horizontal aim.
Idle auto-attack uses full-RNG accuracy (existing system, unchanged).

**AttackOutcome enum:** `Hit / Miss / Evaded / Blocked` — surfaced to player via
hit marker above enemy (`OnPlayerHit` event already in `ZoneCombatView`).

### Damage Formula

Draw power no longer scales damage. Stats drive base damage:

```
ShotDamage = BaseDamage × WeakPointMultiplier × OutcomeModifier

BaseDamage         = (DEX × 1.5) + BowDamage + DEXEquipBonus
WeakPointMultiplier = weakPointHit ? 2.0f : 1.0f
OutcomeModifier     = Hit: 1.0 · Blocked: 0.3 · Evaded/Miss: 0.0
```

Update `stat-scaling-combat-formulas.md` to reflect this — Warden active damage
is DEX-driven, not draw-power-driven.

### Enemy Depth

`EnemyData.combatRange` (Close / Medium / Far / VeryFar) → fixed world Z per enemy
(constant trait, same every spawn). Perspective camera + ground-plane Y-rise +
~10° downward tilt make farther enemies read as higher on screen AND smaller.
The arc loft players use to hit heads at Medium range differs from VeryFar range —
depth creates natural skill variance between enemy types.

### HP and Recovery (as-built)

- HP persists between fights — no free heal on kill
- Death = retreat to hub, no automatic heal
- HP regenerates out of battle only (`_hpRegenFraction` ~3%/sec)
- In combat: recover via hotbar consumables or idle auto-eat
- `PlayerData.CurrentHP` is the source of truth (already implemented)

### Enemy Animation (as-built)

`EnemyData` supports optional `idleFrames[]` / `attackFrames[]` / `deathFrames[]`
(Sprite arrays) + `animFPS`, falling back to static `icon`.
- Idle loops continuously
- Attack plays once → returns to idle
- Death plays once → enemy hides

`idleMasks[]` — optional per-frame weak point masks that animate with the sprite.
A wolf that bobs its head has a moving head weak point — the mask moves with it.

---

## Weak Point System

### Mask Per Enemy

Each enemy has a `weakPointMask` texture (Texture2D, Read/Write enabled).
White pixels = weak point region. Checked via `hit.textureCoord` from `RaycastHit`
on the enemy's `MeshCollider`.

Fixed multiplier: **×2.0** for all enemies.

### Animated Weak Points

Optional `idleMasks[]` — one mask per idle animation frame.
If populated, `ZoneCombatView` uses `idleMasks[currentAnimFrame]` instead of
the static `weakPointMask`. Allows weak points that move with animation.
Falls back to static mask if `idleMasks` is empty.

### Visibility Tiers

```csharp
public enum WeakPointTier {
    Obvious,   // Always visible — glowing core, crystal, etc.
    Subtle,    // Brief pulse on attack or when taking damage
    Hidden     // No tell — reveals when player has reveal talent
}
```

```csharp
void UpdateWeakPointGlow() {
    bool shouldGlow = weakPointTier switch {
        WeakPointTier.Obvious => true,
        WeakPointTier.Subtle  => _enemyJustAttacked || _enemyJustTookDamage,
        WeakPointTier.Hidden  => ZoneCombatView.HasWeakPointRevealTalent(),
        _ => false
    };
    weakPointGlowRenderer.enabled = shouldGlow;
}
```

### Reveal Talent Wiring

Wire `ZoneCombatView.HasWeakPointRevealTalent()` (currently stubbed):

```csharp
bool HasWeakPointRevealTalent() =>
    TalentManager.GetTalentLevel("Tracking") >= 33      // Lone Wolf's Eye prereq
    || CombatXPManager.GetGrimoireLevel("LoneWanderer") >= 38  // Lone Wolf's Eye
    || CombatXPManager.GetGrimoireLevel("Sharpshot") >= 59;    // Deadeye
```

When true: Hidden tier weak points show the same subtle pulse as Tier 2.

---

## Ability System — Design Layer (not yet built)

The arc mechanic is built. The ability layer sits ON TOP of it without
changing the arc input. Hold duration accumulates while the player draws and aims —
both happen simultaneously. The ring icons on the right side show which ability
tier is currently active.

### Input Model — Hold Duration + Arc Aim (parallel)

```
Press → drawing begins, hold timer starts, Standard/Rapid Fire icon lights
Drag horizontally → horizontal aim (unchanged)
Drag vertically   → loft / vertical aim (unchanged)
Hold duration     → ability tier advances in background (icon stack updates)
Release           → fires whichever tier icon is currently lit
```

Arc aim and hold timer run in parallel. The player watches the icon stack
(right side) to know which tier is active while also watching the trajectory
line to aim. One deliberate decision — hold longer for better abilities,
release when aim is right.

---

## Combat View Layout

```
┌─────────────────────────────────────────┐
│                                         │
│         [Zone background]               │
│                                         │
│         [Enemy sprite]                  │
│         [Enemy HP bar below sprite]     │
│                              [ABILITY   │
│[HOT  ]                        STACK     │
│[BAR  ]                        right     │
│[vert ]                        side,     │
│[left ]                        vertical] │
│                                         │
│   [Trajectory arc preview]              │
│         [Player silhouette]             │
│                                         │
│  ████████████████  ← Player HP bar      │
│  ─────────────────────────────────────  │
│  [Ability row — tap to prime]           │
│  [Consumable hotbar — tap to use]       │
└─────────────────────────────────────────┘
```

**Hotbar** (left, vertical) — consumables: HP, class resource, antidote. Already built.
**Ability stack** (right, vertical) — draw depth indicator (visual only, see below).
**Ability row** (bottom, above hotbar) — tap-to-prime or hold-to-charge specials.
**Enemy HP bar** — below enemy sprite.

---

## Ability Row — Model C (tap to activate)

One row at screen bottom, above the consumable hotbar:

```
[Ability 1]                            ← ability row (NEW — one button per subclass)
[HP Draught] [Stamina/Mana] [Antidote] ← consumable hotbar (existing)
```

The ring handles Standard/Barbed/Full Draw/Long Shot/Rapid Fire.
The ability row handles abilities that don't fit the hold model.

### Sharpshot Ability Row
```
[ Armor Piercer ]   ← tap to prime next shot (45s CD)
```

### Lone Wanderer Ability Row
```
[ Fade / Vanishing Act ]   ← tap to activate stealth (60s CD)
```

---

## Ability Specifications

### Barbed Shot (Sharpshot, Grimoire level 31)
**Ring tier — 1.5s hold**

```
Hold 1.5s → Barbed Shot icon lights up
Release → fires normal arc shot with barbed properties
  → 20% chance to apply BleedType.Barbed DoT on hit
  → Bleed cannot stack — if bleed already active, proc does nothing
No cooldown — limited by 20% proc chance and bleed no-stack rule
```

Bleed DoT scales with quiver tier:
| Quiver | Damage/tick | Duration |
|--------|-----------|---------|
| Crude | 3/sec | 6s |
| Rough | 6/sec | 8s |
| Refined | 10/sec | 10s |
| Pristine | 15/sec | 12s |
| Masterwork | 22/sec | 15s |

---

### Long Shot (Sharpshot, Grimoire level 86) — 90s cooldown
**Ring tier — 4.0s hold**

```
Hold 4.0s → Long Shot icon lights up gold
Release → fires Long Shot arc:
  → 800% damage
  → Ignores armor and resistances
  → Guaranteed weak point hit regardless of loft
  → All active coatings proc simultaneously
  → If enemy is Marked: × 1.5 bonus
90s cooldown starts after firing — icon greyed with shading timer
```

**The "guaranteed weak point" is the key feel** — the player still aims for
loft satisfaction but Long Shot finds the weak point regardless of where the
arc lands. The gold icon border communicates the shot is ready.

On cooldown: Long Shot icon greyed out with clockwise shading timer.
Holding past 4.0s while on cooldown: arc stays at Full Draw tier — Long Shot
icon stays greyed and doesn't activate until cooldown clears.

---

### Rapid Fire (Lone Wanderer, Grimoire level 44) — 8s cooldown
**Ring tier — 0.3s hold**

```
Hold 0.3s → Rapid Fire icon lights up
Release → fires 3 rapid shots at current aim:
  → Each shot: 65% base damage
  → Slight loft spread between shots (±5° loft variance)
  → Each shot: −12% hit chance for coating proc roll
     (effective: ~88% × coating proc chance per shot)
  → All 3 shots fire from same horizontal aim position at release
8s cooldown after firing — icon greyed while cooling
```

The 0.3s threshold is easy to reach — Lone Wanderer naturally fires bursts.
The loft spread across 3 shots means at least one may hit a weak point.
On cooldown, the 0.3s tier jumps straight to Standard Shot (1.5s tier).

---

### Armor Piercer (Sharpshot, Grimoire level 73) — 45s cooldown
**Tap to prime**

```
Tap → Armor Piercer primes (icon glows, shield-break visual on trajectory)
Draw + release → fires normal arc shot that ignores enemy armor rating
45s cooldown after firing
```

Simple. No visual change to trajectory beyond the icon glow.
Most useful against heavily armored elites and bosses.

---

### Fade (Lone Wanderer, Grimoire level 24) — 60s cooldown
### Vanishing Act (Lone Wanderer, Grimoire level 93) — replaces Fade
**Tap to activate (not prime — takes effect immediately)**

```
Tap → player enters Shroud state immediately
  → player renderer fades (alpha 0.2)
  → next enemy attack misses entirely
  → _comingFromShroud = true
  → Fade: 8s duration
  → Vanishing Act: 20s duration, coating DoTs continue ticking during stealth

On next shot release from Shroud:
  → Shadow's Edge equivalent: × 2.5 damage ("Critical!" displayed)
  → _comingFromShroud = false, renderer restores
60s cooldown (both tiers)
```

Note: Fade is the only ability that takes effect immediately (not a prime).
All others prime the next shot. Fade activates stealth NOW, then the
player draws and fires when ready.

---

## Ability Icon Stack — Right Side Vertical

Icon stack showing current ability tier. Icons light up as hold time crosses
each threshold. Only the highest lit icon fires on release. Previous icons dim
when a higher tier activates.

**Sharpshot stack (bottom to top):**
```
[ Long Shot  ]  ← lights at 4.0s (90s CD — greyed when on cooldown)
[ Full Draw  ]  ← lights at 2.5s
[ Barbed Shot]  ← lights at 1.5s
[ Standard   ]  ← lights at 0.3s (always bottom)
```

**Lone Wanderer stack (bottom to top):**
```
[ Full Draw  ]  ← lights at 2.5s
[ Standard   ]  ← lights at 1.5s
[ Rapid Fire ]  ← lights at 0.3s (always bottom)
```

### Hold Time Windows (widened for aiming overhead)

| Window | Sharpshot fires | Lone Wanderer fires |
|--------|----------------|-------------------|
| 0–0.29s | Nothing (accidental tap prevention) | Nothing |
| 0.3–1.49s | Standard Shot | Rapid Fire (3 shots, 65%, −12% proc) |
| 1.5–2.49s | Barbed Shot (20% bleed proc) | Standard Shot |
| 2.5–3.99s | Full Draw (Hunter's Patience + Sniper's Vantage) | Full Draw |
| 4.0s+ | Long Shot (800%, 90s CD) | Full Draw (no Long Shot) |

Windows are wider than v0.1 because the player is simultaneously aiming.
A player focusing on loft and horizontal aim naturally holds 1–2 seconds —
this lands them in Standard Shot territory without any deliberate timing.
Barbed Shot and Full Draw require intentional hold. Long Shot is a clear commitment.

### Icon Visual States

| State | Visual |
|-------|--------|
| Not yet reached | Icon at 40% opacity |
| Currently active (lit) | Icon fully bright, gold border |
| Previous tier (dimmed) | Icon at 40% opacity — superseded |
| Long Shot on cooldown | Icon greyed, shading timer empties clockwise |

No ring loader — icons simply light up instantly when threshold is crossed.
Clean and readable during active aiming.

---

## Subclass Tuning Parameters

Both subclasses use the same arc system. Differentiation via inspector parameters
on `WardenBowstringMechanic`:

| Parameter | Sharpshot | Lone Wanderer | Effect |
|-----------|-----------|--------------|--------|
| `_arcPeakMax` | Higher (bigger loft range) | Lower (flatter arcs) | Sharpshot can aim at heads from farther; Lone Wanderer fires flatter |
| `_trajectoryReveal` | Lower (more hidden) | Higher (more visible) | Sharpshot reads the arc by feel; Lone Wanderer sees more of the line |
| `_steerResponse` | Slower ease | Faster ease | Sharpshot precision; Lone Wanderer agility |
| `_drawResponse` | Slower ease | Faster ease | Sharpshot deliberate; Lone Wanderer reactive |

These are tuning values set by Claude Code during playtesting — the spec sets
intent, numbers are adjusted to feel right.

---

## Bleed System

Two independent types, never share a pool:

```csharp
public enum BleedType {
    Barbed,      // Sharpshot — scales with quiver tier, no stack, no refresh
    Hemorrhage   // Shadowblade — scales with Alchemy, stacks twice via talent
}
```

Each enemy tracks both independently. Separate debuff icons:
- Barbed Bleed: arrow/thorn icon
- Hemorrhage Bleed: blood drop icon

Only 3 debuff icons ever shown: Poison · Barbed Bleed · Hemorrhage Bleed.

---

## What Claude Code Needs to Build

**New — ability row UI:**
1. Ability row panel above hotbar — 2-3 slots per subclass
2. Tap-to-prime state (icon glow, trajectory line tint)
3. Hold-to-charge state (Long Shot — 1.5s hold, gold trajectory)
4. Prime expiry timer (8s, Barbed Shot and Armor Piercer)
5. Cooldown display (shading timer on ability icon)
6. Fade immediate-activation (not prime)

**New — shot property system:**
7. `_primedAbility` field on `WardenBowstringMechanic`
8. In `OnShotFired()`: check `_primedAbility` → apply modifiers → clear prime
9. Barbed Shot bleed proc (20%, no stack if already active)
10. Long Shot properties (800%, armor ignore, guaranteed weak point, all coatings)
11. Rapid Fire burst (3 shots, 65% each, loft spread, −12% proc)
12. Armor Piercer flag (ignoreArmor next shot)

**New — reveal talent wiring:**
13. Wire `HasWeakPointRevealTalent()` per formula above

**New — loft indicator UI (right side):**
14. Three passive zone labels (Head/Chest/Body) — visual guide, not interactive
15. Settings toggle to hide after level 50

**Stat formula update:**
16. Update `stat-scaling-combat-formulas.md`:
    Active Warden damage = `(DEX × 1.5) + BowDamage` base
    (remove draw-power damage scaling)

**Already built — do not rebuild:**
- Arc aim mechanic (horizontal drag = steering, vertical = loft)
- Linecast hit detection against MeshCollider
- `hit.textureCoord` → `weakPointMask` check
- `AttackOutcome` enum
- Accuracy vs Evasion/Block roll
- `EnemyData.combatRange` → world Z placement
- `idleFrames/attackFrames/deathFrames` animation
- `idleMasks[]` per-frame weak point

---

*Path: `docs/warden-combat-spec.md`*
