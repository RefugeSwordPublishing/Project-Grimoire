---
type: design-spec
version: 0.1
updated: 2026-07-11
purpose: Complete Warden combat UI layout, Bowstring draw system, ability icon stack,
         and all Technique implementations. Read alongside combat-engagement-spec.md
         and subclass-trees-warden.md.
---

# Project Grimoire — Warden Combat Spec
### Version 0.1

---

## Combat View Layout

```
┌─────────────────────────────────────────┐
│                                         │
│         [Zone background]               │
│                                         │
│         [Enemy sprite]                  │
│         [Enemy HP bar — below sprite]   │
│                              [ABILITY   │
│[HOT  ]                        STACK     │
│[BAR  ]                        right     │
│[vert ]                        side,     │
│[left ]                        vertical] │
│                                         │
│         [Player silhouette]             │
│         [Bow arc fills on draw]         │
│                                         │
│  ████████████████  ← Player HP bar      │
│  ─────────────────────────────────────  │
│  [Fade] [Trap Layer] [Armor Piercer]    │
│           ← Model C ability row         │
└─────────────────────────────────────────┘
```

**Hotbar** (left, vertical) — consumables: HP slot, class resource slot, antidote slot.
Same as all other paths — Warden uses same 3-slot hotbar.

**Ability stack** (right, vertical) — Bowstring draw abilities. See below.

**Ability row** (bottom, below HP bar) — tap-activated Model C abilities.
Positioned below HP bar to prevent accidental taps during Bowstring draws.

**Enemy HP bar** — displayed below the enemy sprite, not above.

---

## Bowstring Draw — Updated System

### Draw Curve

Draw power follows an **exponential curve** — easy to reach 50–60%, meaningfully
harder to push to full charge. The final 30% requires deliberate commitment.

```csharp
// Replace linear fill with exponential curve:
float drawPower = Mathf.Pow(holdTime / maxDrawTime, 1.6f);
// At 0.5s of 1.5s max: linear would be 33%, exponential gives ~21%
// At 1.0s: linear 67%, exponential gives ~49%
// Full draw still reached at maxDrawTime — just harder to stay there
```

### Draw Visualisation — Bow Arc

The draw % is shown graphically as a **filling arc on the bow sprite** — no text.

- At 0% draw: bow string at rest, arc at minimum
- As draw increases: arc bends progressively, string pulls back visibly
- Color shifts along the arc: white → amber → orange as draw power increases
- At full draw: arc glows briefly, slight screen pulse to confirm full charge
- No DRAW % text — the bow arc IS the feedback

```csharp
// In BowstringMechanic:
bowArcRenderer.fillAmount = drawPower; // 0.0–1.0
bowArcRenderer.color = Color.Lerp(Color.white, fullDrawColor, drawPower);
// Remove drawPercentText entirely
```

---

## Ability Icon Stack — Right Side Vertical

### Layout

Four icon slots arranged vertically on the right side of the screen.
Only unlocked abilities are visible — locked slots don't appear (stack grows as
player levels).

**Sharpshot ring:**
```
[ Long Shot ]     ← top     (3.0s threshold)
[ Full Draw ]     ← third   (1.5s threshold)
[ Barbed Shot ]   ← second  (1.0s threshold)
[ Standard Shot ] ← bottom  (0.3s threshold)
```

**Lone Wanderer ring:**
```
[ Full Draw ]     ← top     (1.5s threshold)
[ Standard Shot ] ← third   (1.0s threshold)
[ Rapid Fire ]    ← bottom  (0.3s threshold)
```
Note: Long Shot is Sharpshot-exclusive. Rapid Fire is Lone Wanderer-exclusive.
The ring only shows abilities unlocked for the equipped Grimoire.

Each icon has a **circular ring** that loads around it as the draw progresses.

### Ring Loading Behaviour

```
**Sharpshot:**
Player presses and holds
    ↓
Ring begins loading on STANDARD SHOT icon (bottom)
    ↓
At 0.3s: Standard Shot ring completes — icon lights up
    ↓
If still holding: ring begins loading on BARBED SHOT icon
    ↓
At 1.0s: Barbed Shot ring completes — icon lights up, Standard dims
    ↓
If still holding: ring begins loading on FULL DRAW icon
    ↓
At 1.5s: Full Draw ring completes — icon lights up, Barbed dims
         (Hunter's Patience and Sniper's Vantage bonuses now active)
    ↓
If still holding AND Long Shot unlocked:
    ring begins loading on LONG SHOT icon (slow — takes until 3.0s total)
    ↓
Player releases at any point
    → fires whichever icon is CURRENTLY LIT (last completed ring)

**Lone Wanderer:**
Player presses and holds
    ↓
Ring begins loading on RAPID FIRE icon (bottom)
    ↓
At 0.3s: Rapid Fire ring completes — icon lights up
    ↓
If still holding: ring begins loading on STANDARD SHOT icon
    ↓
At 1.0s: Standard Shot ring completes — icon lights up, Rapid Fire dims
    ↓
If still holding: ring begins loading on FULL DRAW icon
    ↓
At 1.5s: Full Draw ring completes — icon lights up, Standard dims
    ↓
Player releases at any point
    → fires whichever icon is CURRENTLY LIT
```

**Only the currently lit icon fires** — the ring system makes it unambiguous.
A player who releases at 0.8s gets Rapid Fire (lit at 0.3s, Standard not yet lit).
A player who releases at 1.2s gets Standard Shot (lit at 1.0s, Full Draw not yet lit).

### Icon Visual States

| State | Visual |
|-------|--------|
| Locked | Not rendered — slot doesn't exist |
| Available, not charging | Icon at 50% opacity, ring empty |
| Ring loading | Ring fills clockwise, icon at 75% opacity |
| **Lit — ready to fire** | Icon fully bright, gold border pulse |
| Fired — cooling down (Standard/Rapid) | Brief flash, returns to available state |
| On cooldown (Long Shot) | Icon greyed out, shading timer empties clockwise |

### Standard Shot Icon

Standard Shot is not an "ability" — it represents the normal Bowstring release
with all passive modifiers applied (Steady Hand, Hunter's Patience, Sniper's Vantage etc.).
No cooldown. The default state after Rapid Fire window closes.

---

## Draw Thresholds and What Fires

| Hold time | Icon lit | What fires | Notes |
|-----------|---------|-----------|-------|
| 0–0.29s | None | Nothing — too short | Accidental tap prevention |
| 0.3–0.99s | **Standard Shot** | Single shot, base draw power | Quick — no bonuses |
| 1.0–1.49s | **Barbed Shot** | Single shot + 20% bleed proc | Patience rewarded — bleed DoT |
| 1.5–2.99s | **Full Draw** | Single shot, max draw power | Hunter's Patience + Sniper's Vantage |
| 3.0s+ | **Long Shot** | Single devastating shot | 90s cooldown, must be unlocked |

**Minimum hold time of 0.3s** prevents accidental Rapid Fire on screen taps.
If the player releases before 0.3s nothing fires.

---

## Ability Stack — Implementation per Technique

### Rapid Fire (Lone Wanderer only, Grimoire level 44)
**Model B — draw duration trigger (0.3s)**

```csharp
void OnRapidFireRelease() {
    for (int i = 0; i < 3; i++) {
        float damage = baseDamage * 0.65f;

        // Reduced proc chance — flat -12% hit chance for proc roll
        float procHitChance = 0.88f; // 12% less likely to trigger the proc roll
        bool procRollHappens = Random.value < procHitChance;
        bool coatingProcs = procRollHappens && Random.value < coatingProcChance;
        // e.g. coatingProcChance = 0.40f → effective rate = 0.88 × 0.40 = 35.2%

        FireShot(damage, coatingProcs);
    }
    // No cooldown on Rapid Fire itself — gated by 0.3–1.0s window only
}
```

Aim direction is fixed at release for all 3 shots — slight spread (±5°) between
each to feel like a burst, not a perfect triple tap.

### Standard Shot (always available at 1.0s)
**Model B — draw duration**

Normal Bowstring shot. All passive modifiers apply:
- Draw power multiplier from bow arc fill
- Weak point multiplier if aimed correctly
- Hunter's Patience bonus if held beyond 1.5s
- Sniper's Vantage bonus at Full Draw
- Coating proc at full proc chance

No cooldown. The default shot type.

### Full Draw (Grimoire level 1 — always available after 1.5s)
Same as Standard Shot but held to full draw power.
Hunter's Patience (+8% per 0.5s beyond 1.5s, max +24%) activates here.
Sniper's Vantage (+15% damage) activates here.
Piercing Shot activates here if unlocked (Grimoire level 9).

### Long Shot (Grimoire level 86, 90-second cooldown)
**Model B — extended hold (5.0s)**

```csharp
void OnLongShotRelease() {
    if (_longShotCooldown > 0) return; // shouldn't reach here but safety check

    float damage = baseDamage * 6.0f; // 600% damage
    bool ignoresArmor = true;
    bool ignoresResistances = true;

    FireShot(damage, ignoresArmor, ignoresResistances);

    _longShotCooldown = 90f;
    StartCooldownDisplay(longShotIcon, 90f);
}
```

During the 5.0s hold the Long Shot icon ring loads slowly — visually communicates
the commitment. Screen edges vignette slightly to signal the charge.
On cooldown: icon greyed out with circular shading timer emptying clockwise.

---

## Model C Ability Row — Bottom of Screen

Tap-activated abilities sit in a dedicated row **below the HP bar**.
This placement prevents accidental taps while dragging the Bowstring draw.

```
  [Player HP bar]
  ───────────────────────────────────────
  [ Fade ]  [ Armor Piercer ]
```

Each slot shows: ability icon + shading cooldown timer when on cooldown.
Only unlocked abilities visible — empty slots don't render.

### Fade (Lone Wanderer, Grimoire level 24) — 60s cooldown
**Model C — tap button**

```csharp
void OnFadeTap() {
    if (_fadeCooldown > 0) return;

    EnterShroud(duration: 8f);
    _comingFromShroud = true; // next shot fires stealth opener (+150% damage)
    _fadeCooldown = 60f;
}

// On next Bowstring release while _comingFromShroud:
float damage = baseDamage * drawMultiplier * 2.5f; // +150% on top of draw power
ShowCriticalLabel();
_comingFromShroud = false;
```

**Vanishing Act (Lone Wanderer, Grimoire level 93)** — same button, replaces Fade:
- Stealth duration extends to 20 seconds
- Coating DoTs continue ticking on last targeted enemy during stealth

### Barbed Shot (Sharpshot ring — 1.0s threshold)
**Model B — draw duration trigger**

At 1.0s hold the Barbed Shot icon lights up. Release fires a standard shot
with a **20% chance to apply bleed DoT**. If bleed is already active on the
enemy, a proc does nothing — no stack, no refresh. Bleed runs its full duration
and expires before another can be applied.

```csharp
void OnBarbedShotRelease(float drawPower) {
    float damage = baseDamage * drawPower; // standard draw damage

    FireShot(damage);

    // 20% bleed proc — only if no active bleed
    if (barbedShotUnlocked && !currentEnemy.HasBleed()
        && Random.value < 0.20f) {
        currentEnemy.ApplyBleed(bleedDamagePerTick, bleedDuration);
    }
    // If already bleeding: do nothing — no reset, no stack
}
```

Bleed values scale with equipped quiver tier:
| Quiver tier | Bleed damage/tick | Duration |
|-------------|-----------------|---------|
| Crude | 3/sec | 6s |
| Rough | 6/sec | 8s |
| Refined | 10/sec | 10s |
| Pristine | 15/sec | 12s |
| Masterwork | 22/sec | 15s |

> 20% proc chance is intentionally conservative — adjust during playtesting.
> The natural rhythm: most 1.0s shots deal standard damage, occasionally bleed
> is applied and the Sharpshot capitalises with a Full Draw or Long Shot while it ticks.

### Armor Piercer (Sharpshot, Grimoire level 73) — 45s cooldown
**Model C — tap button**

Tap to activate — **next Bowstring release** ignores enemy armor entirely.
Active state shown as a glowing border on the Armor Piercer icon.

```csharp
void OnArmorPiercerTap() {
    if (_armorPiercerCooldown > 0) return;
    _armorPiercerActive = true;
    // Icon shows active glow
    _armorPiercerCooldown = 45f;
}

// On next shot release:
if (_armorPiercerActive) {
    ignoreArmor = true;
    _armorPiercerActive = false;
    // Icon returns to normal
}
```

---

## Passive Technique Implementation

These require no UI element — they modify shot behaviour automatically
when conditions are met.

| Technique | Trigger | Implementation |
|-----------|---------|----------------|
| **Steady Hand** | Always | `drawTime *= 1.2f; baseDamage *= 1.3f` on equip |
| **Hunter's Patience** | Full Draw hold beyond 1.5s | `+8% damage per 0.5s, max +24%` |
| **Mark of the Hunt** | After any weak-point hit | `markedEnemy = currentEnemy; damage *= 1.2f` for 15s |
| **Sniper's Vantage** | Full Draw release | `damage *= 1.15f` when at full draw power |
| **Lone Wolf's Eye** | Always when unlocked | `weakPointsAlwaysVisible = true` |
| **Poison Proficiency** | Always when unlocked | `coatingDuration *= 1.25f; procChance += 0.10f` |
| **Sharpshot's Resolve** | After weak-point hit | `_nextShotGuaranteedWeakPoint = true` |
| **Piercing Shot** | Full Draw release | Shot continues through enemy — applies 60% damage to next spawned enemy |
| **Killshot** | Release against enemy <20% HP | Auto-triggers execute on release, 30s cooldown |
| **Deadeye** | Always when unlocked | `weakPointGlowDuration *= 1.5f` |
| **Crosswind Read** | When enemy is Marked | `weakPointMultiplier += 0.25f` on Marked target |

---

## Aim System — Unchanged

Aim direction is determined by **drag direction** while holding:
- Horizontal drag: adjusts left-right aim arc
- Vertical drag: adjusts elevation (affects whether weak points are targeted)
- Weak point glow visible when aim arc overlaps the weak point zone
- Aim arrow rotates to show current trajectory

No changes to this system from current implementation.

---

## Summary — What Claude Code Needs to Build

**New UI elements:**
1. Ability icon stack (right side, vertical) — 4 slots with ring loaders
2. Ring loading system — fills clockwise per threshold, lights up on complete
3. Model C ability row (bottom, below HP bar) — tap buttons with cooldown timers
4. Bow arc fill visualisation — replaces DRAW % text
5. Remove DRAW % text from `ZoneCombatView`

**Behaviour changes:**
6. Draw curve → exponential (`Mathf.Pow(holdTime / maxDrawTime, 1.6f)`)
7. Minimum 0.3s hold before any shot fires
8. Rapid Fire burst (3 shots at 65% damage, −12% proc hit chance each) — Lone Wanderer only
9b. Barbed Shot (1.0s threshold) — standard damage + 20% bleed proc, no stack — Sharpshot only
9. Long Shot extended hold (3.0s), 90s cooldown, 800% damage, ignores armor + armor, guaranteed weak point, all coatings proc
10. Fade / Vanishing Act stealth state with `_comingFromShroud` flag
11. Trap Layer cooldown gated to respawn window only
12. Armor Piercer one-shot state with `_armorPiercerActive` flag

**Passive wiring** (most already stubbed — just need condition checks):
13. Hunter's Patience damage accumulation beyond 1.5s
14. Mark of the Hunt 15s damage buff on marked target
15. Sharpshot's Resolve guaranteed weak point after weak-point hit
16. Piercing Shot carry-through damage on next spawn
17. Killshot execute below 20% HP

---

*Path: `docs/warden-combat-spec.md`*
