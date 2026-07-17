---
type: implementation-brief
spec: warden-combat-spec.md (v0.1), subclass-trees-warden.md (v0.4)
updated: 2026-07-11
purpose: Wire the Warden ability ring system, per-subclass draw thresholds,
         Barbed Shot, Rapid Fire, Long Shot, and Model C abilities into the
         existing WardenBowstringMechanic. Read alongside warden-combat-spec.md.
---

# Warden Combat — Implementation Brief

## What's Already Built

Per `implementation-status.md`:
- `WardenBowstringMechanic` — press/drag/release, draw power, weak point targeting
- `BowstringMechanic` — charge meter, DRAW %, aim arrow, attack cadence bar
- Combat hotbar (left, vertical) — 3 consumable slots already built
- Enemy HP bar already positioned below enemy sprite
- `ActiveCombatMechanic` seam — `Configure(subclass)`, `SetEngaged(bool)`, `OnAttackFired(multiplier)`

---

## Step 1 — Draw Curve (exponential)

Replace linear draw fill with exponential curve:

```csharp
// In BowstringMechanic — replace current linear drawPower calculation:
float drawPower = Mathf.Pow(holdTime / maxDrawTime, 1.6f);
// maxDrawTime = 1.5f for standard full draw
// Result: harder to reach full charge, last 30% requires deliberate commitment
```

---

## Step 2 — Bow Arc Visualisation (remove DRAW % text)

Replace `drawPercentText` with bow arc fill:

```csharp
// In ZoneCombatView / BowstringMechanic:
bowArcRenderer.fillAmount = drawPower;
bowArcRenderer.color = Color.Lerp(Color.white, fullDrawColor, drawPower);
// fullDrawColor = warm amber/orange

// Remove: drawPercentText.text = $"{drawPower * 100:0}%";
// Remove: drawPercentText gameObject entirely
```

Brief screen pulse + arc glow when drawPower reaches 1.0 to confirm full charge.

---

## Step 3 — Ability Ring UI

New UI component: `WardenAbilityRingUI.cs`

**Layout:** Vertical stack of icon slots on the RIGHT side of the combat screen.
Each slot contains:
- Ability icon sprite
- Circular ring that fills clockwise as draw progresses
- Gold border pulse when ring completes (ability lit)
- Greyed + shading timer when on cooldown (Long Shot only)

**Slot visibility:** Only render slots for unlocked abilities.
Check `CombatXPManager.GetGrimoireLevel(equippedGrimoireId)` against unlock levels.

```csharp
public class WardenAbilityRingUI : MonoBehaviour {
    [SerializeField] AbilitySlot standardSlot;
    [SerializeField] AbilitySlot barbedSlot;    // Sharpshot only
    [SerializeField] AbilitySlot rapidFireSlot; // Lone Wanderer only
    [SerializeField] AbilitySlot fullDrawSlot;
    [SerializeField] AbilitySlot longShotSlot;  // Sharpshot only

    void UpdateRings(float holdTime, string subclass) {
        // Get thresholds for current subclass
        var thresholds = GetThresholds(subclass);

        // Light up icons sequentially as hold time passes each threshold
        foreach (var (slot, threshold) in thresholds) {
            float progress = Mathf.Clamp01(
                (holdTime - prevThreshold) / (threshold - prevThreshold));
            slot.SetRingFill(progress);
            slot.SetLit(holdTime >= threshold);
        }
    }
}
```

---

## Step 4 — Per-Subclass Thresholds

```csharp
// In WardenBowstringMechanic.Configure(subclass):

if (subclass == "Sharpshot") {
    _thresholds = new[] {
        (0.30f, WardShot.Standard),
        (1.00f, WardShot.Barbed),     // unlocks at Grimoire level 31
        (1.50f, WardShot.FullDraw),
        (3.00f, WardShot.LongShot),   // unlocks at Grimoire level 86
    };
}
else if (subclass == "LoneWanderer") {
    _thresholds = new[] {
        (0.30f, WardShot.RapidFire),  // unlocks at Grimoire level 44
        (1.00f, WardShot.Standard),
        (1.50f, WardShot.FullDraw),
    };
}

// Only include unlocked thresholds — check Grimoire level before adding
```

**Minimum hold:** 0.30s before any shot fires. Release before 0.30s = nothing.

**Active shot type:** Always the last threshold that was reached.

```csharp
WardShot GetActiveShotType(float holdTime) {
    WardShot active = WardShot.None;
    foreach (var (threshold, shotType) in _thresholds) {
        if (holdTime >= threshold) active = shotType;
    }
    return active;
}
```

---

## Step 5 — Shot Resolution on Release

```csharp
void OnRelease(float holdTime, Vector2 aimDirection) {
    WardShot shotType = GetActiveShotType(holdTime);

    switch (shotType) {
        case WardShot.None:
            return; // sub-0.3s — nothing fires

        case WardShot.Standard:
            FireStandardShot(holdTime, aimDirection);
            break;

        case WardShot.Barbed:     // Sharpshot only
            FireBarbedShot(holdTime, aimDirection);
            break;

        case WardShot.RapidFire:  // Lone Wanderer only
            FireRapidFire(aimDirection);
            break;

        case WardShot.FullDraw:
            FireFullDraw(holdTime, aimDirection);
            break;

        case WardShot.LongShot:   // Sharpshot only
            FireLongShot(aimDirection);
            break;
    }
}
```

---

## Step 6 — Shot Implementations

### Standard Shot
```csharp
void FireStandardShot(float holdTime, Vector2 aim) {
    float drawPower = Mathf.Pow(holdTime / maxDrawTime, 1.6f);
    float weakPointMult = GetWeakPointMultiplier(aim);
    float damage = baseDamage * drawPower * weakPointMult;
    OnAttackFired(damage);
    TryCoatingProc(damage);
}
```

### Barbed Shot (Sharpshot, unlocks Grimoire level 31)
```csharp
void FireBarbedShot(float holdTime, Vector2 aim) {
    // Same as Standard Shot
    float drawPower = Mathf.Pow(holdTime / maxDrawTime, 1.6f);
    float weakPointMult = GetWeakPointMultiplier(aim);
    float damage = baseDamage * drawPower * weakPointMult;
    OnAttackFired(damage);
    TryCoatingProc(damage);

    // Barbed bleed proc — 20% chance, only if no active Barbed bleed
    if (!currentEnemy.HasBleed(BleedType.Barbed) && Random.value < 0.20f) {
        float tickDamage = GetBarbedBleedTick(); // scales with quiver tier
        currentEnemy.ApplyBleed(BleedType.Barbed, tickDamage, bleedDuration);
    }
    // No stack, no refresh — if bleed already active, proc does nothing
}
```

### Rapid Fire (Lone Wanderer, unlocks Grimoire level 44)
```csharp
void FireRapidFire(Vector2 aim) {
    // Fixed aim direction — slight spread between shots
    for (int i = 0; i < 3; i++) {
        Vector2 spread = aim + Random.insideUnitCircle * 0.05f;
        float damage = baseDamage * 0.65f;
        OnAttackFired(damage);

        // Reduced proc chance — 12% less likely to trigger coating proc roll
        if (Random.value < 0.88f)
            TryCoatingProc(damage);
    }
    // No cooldown on Rapid Fire — gated by 0.3–1.0s window
}
```

### Full Draw (all Wardens, always available at 1.5s)
```csharp
void FireFullDraw(float holdTime, Vector2 aim) {
    float drawPower = 1.0f; // at full draw
    float weakPointMult = GetWeakPointMultiplier(aim);

    // Hunter's Patience bonus (Sharpshot, Grimoire level 17)
    float patienceBonus = 1.0f;
    if (huntersPatienceUnlocked) {
        float extraHold = Mathf.Clamp(holdTime - 1.5f, 0f, 1.5f);
        patienceBonus = 1.0f + (extraHold / 0.5f) * 0.08f; // +8% per 0.5s, max +24%
        patienceBonus = Mathf.Min(patienceBonus, 1.24f);
    }

    // Sniper's Vantage bonus (Sharpshot, Grimoire level 44)
    float vantageBonus = snipersVantageUnlocked ? 1.15f : 1.0f;

    float damage = baseDamage * drawPower * weakPointMult
                 * patienceBonus * vantageBonus;

    // Piercing Shot (Sharpshot, Grimoire level 9)
    if (piercingShotUnlocked)
        _nextEnemyTakesDamage = damage * 0.60f;

    // Sharpshot's Resolve — guaranteed weak point on next shot
    if (_nextShotGuaranteedWeakPoint) {
        damage *= GetWeakPointMultiplier(perfectAim);
        _nextShotGuaranteedWeakPoint = false;
    }

    OnAttackFired(damage);
    TryCoatingProc(damage);

    // Sharpshot's Resolve (level 79) — weak point hit chains
    if (weakPointMult > 1.0f && sharpshotResolveUnlocked)
        _nextShotGuaranteedWeakPoint = true;

    // Mark of the Hunt proc (level 24)
    if (weakPointMult > 1.0f && markOfHuntUnlocked)
        SetMark(currentEnemy, duration: 15f, damageBonus: 1.20f);

    // Barbed Shot bleed proc on Full Draw too (if unlocked)
    if (barbedShotUnlocked && !currentEnemy.HasBleed(BleedType.Barbed)
        && Random.value < 0.20f)
        currentEnemy.ApplyBleed(BleedType.Barbed,
            GetBarbedBleedTick(), bleedDuration);
}
```

### Long Shot (Sharpshot only, Grimoire level 86)
```csharp
void FireLongShot(Vector2 aim) {
    if (_longShotCooldown > 0) return;

    float damage = baseDamage * 8.0f; // 800% base damage

    // Mark of the Hunt bonus
    if (currentEnemy == markedEnemy) damage *= 1.5f;

    // All coatings proc simultaneously — guaranteed
    ForceAllCoatingProcs();

    // Guaranteed weak point regardless of aim
    damage *= GetWeakPointMultiplier(perfectAim);

    // Ignore armor and resistances
    OnAttackFired(damage, ignoreArmor: true, ignoreResistances: true);

    _longShotCooldown = 90f;
    abilityRingUI.StartCooldownDisplay(longShotSlot, 90f);
}
```

---

## Step 7 — Killshot (Sharpshot passive, Grimoire level 52)

Check on every Full Draw release:

```csharp
void FireFullDraw(float holdTime, Vector2 aim) {
    // ... existing damage calc ...

    // Killshot — execute below 20% HP (30s cooldown)
    if (killshotUnlocked && _killshotCooldown <= 0
        && currentEnemy.HPPercent < 0.20f) {
        damage = currentEnemy.currentHP * 10f; // guaranteed kill
        _killshotCooldown = 30f;
    }

    OnAttackFired(damage);
}
```

---

## Step 8 — Model C Ability Row

**New UI row** below the HP bar. Two slots for Sharpshot, one for Lone Wanderer.

```
  [Player HP bar]
  ───────────────────────────────
  [ Fade ]  [ Armor Piercer ]    ← Sharpshot
  [ Fade ]                       ← Lone Wanderer (Vanishing Act replaces at level 93)
```

### Fade / Vanishing Act (Lone Wanderer)
```csharp
void OnFadeTap() {
    if (_fadeCooldown > 0) return;

    float duration = vanishingActUnlocked ? 20f : 8f;
    EnterShroud(duration);
    _comingFromShroud = true;
    _fadeCooldown = 60f;
}

// On next shot release while _comingFromShroud:
// In FireStandardShot / FireFullDraw:
if (_comingFromShroud) {
    damage *= 2.5f; // +150% — same as Shadow's Edge
    ShowCriticalLabel();
    _comingFromShroud = false;

    // Vanishing Act: coating DoTs continue during stealth
    // handled in CombatManager.TickEnemyDot — not interrupted by stealth
}
```

### Armor Piercer (Sharpshot, Grimoire level 73)
```csharp
void OnArmorPiercerTap() {
    if (_armorPiercerCooldown > 0) return;
    _armorPiercerActive = true;
    armorPiercerSlot.SetActive(true); // glow border
    _armorPiercerCooldown = 45f;
}

// On next shot release:
if (_armorPiercerActive) {
    ignoreArmor = true;
    _armorPiercerActive = false;
    armorPiercerSlot.SetActive(false);
}
```

---

## Step 9 — Bleed System

Two independent bleed types — never share a pool:

```csharp
public enum BleedType {
    Barbed,      // Sharpshot source — scales with quiver tier
    Hemorrhage   // Shadowblade source — scales with Alchemy level
}

// On enemy:
Dictionary<BleedType, BleedEffect> activeBleedsByType;

bool HasBleed(BleedType type) =>
    activeBleedsByType.ContainsKey(type) && activeBleedsByType[type].IsActive;

void ApplyBleed(BleedType type, float tickDamage, float duration) {
    // No stack within same type — replace only if not active
    if (!HasBleed(type))
        activeBleedsByType[type] = new BleedEffect(tickDamage, duration);
    // If already active: do nothing (no reset, no stack)
}
```

Shadowblade's Hemorrhage Mastery (stack twice) uses `BleedType.Hemorrhage` with
a max stack count of 2 — independent of `BleedType.Barbed` entirely.

---

## Step 10 — Idle Behaviour (unchanged seam)

Warden idle fires via the existing `ActiveCombatMechanic` fallback — auto-fires
when the player isn't drawing. No changes needed to idle path.

Sharpshot idle: fires Standard Shot at reduced rate, targeting highest HP enemy.
Lone Wanderer idle: fires Standard Shot at standard fire rate, coating active if applied.

---

## Phase 1 Goal

1. Exponential draw curve replacing linear
2. Bow arc fill replacing DRAW % text
3. Ability ring UI rendering correct slots per subclass
4. Per-subclass thresholds routing release to correct shot type
5. Barbed Shot (Sharpshot, 1.0s, 20% bleed proc, no stack)
6. Rapid Fire (Lone Wanderer, 0.3s, 3 shots, reduced proc)
7. Full Draw with Hunter's Patience + Sniper's Vantage
8. Long Shot (3.0s, 800%, all coatings, 90s cooldown)
9. Fade / Vanishing Act tap button
10. Armor Piercer tap button
11. Bleed system with two independent BleedTypes

Passive wiring (Mark of the Hunt, Killshot, Sharpshot's Resolve, Piercing Shot)
layers on top once shot resolution is confirmed working.

---

*Path: `docs/warden-combat-implementation-brief.md`*
