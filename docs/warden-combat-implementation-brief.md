---
type: implementation-brief
spec: warden-combat-spec.md (v0.2)
updated: 2026-07-11
reconciled-to: warden-archery-asbuilt.md
purpose: Build the Warden ability layer on top of the as-built arc mechanic.
         Everything in the as-built doc is already done — do NOT rebuild it.
         This brief covers only what is NOT yet built.
---

# Warden Combat — Ability Layer Implementation Brief

## What's Already Built — Do Not Rebuild

Per `warden-archery-asbuilt.md` and `implementation-status.md`:

- ✅ Arc aim (horizontal = steer, vertical = loft)
- ✅ Trajectory LineRenderer preview with `_trajectoryReveal`
- ✅ Physics.Linecast against enemy MeshCollider for hit detection
- ✅ `hit.textureCoord` → `weakPointMask` → ×2.0 multiplier
- ✅ `AttackOutcome` (Hit/Miss/Evaded/Blocked)
- ✅ Accuracy vs Evasion/Block roll (active shots only)
- ✅ `EnemyData.combatRange` → world Z
- ✅ `idleFrames/attackFrames/deathFrames` animation
- ✅ `idleMasks[]` per-frame weak point masks
- ✅ `WeakPointTier` enum + `HasWeakPointRevealTalent()` stub
- ✅ 3D combat scene (perspective camera, RenderTexture, quads)

---

## What This Brief Covers (not yet built)

1. Ability row UI (above hotbar)
2. Prime/charge state system
3. Each ability implementation
4. Reveal talent wiring
5. Stat formula update
6. Loft indicator UI (right side)

---

## Step 1 — Icon Stack UI (Right Side)

Vertical stack of ability tier icons on the RIGHT side of the combat screen.
Icons light up sequentially as hold time crosses each threshold.
No ring loader — icons simply activate instantly at each threshold.

```csharp
public class WardenAbilityIconStack : MonoBehaviour {
    [SerializeField] AbilityIconSlot standardSlot;
    [SerializeField] AbilityIconSlot barbedSlot;     // Sharpshot only
    [SerializeField] AbilityIconSlot rapidFireSlot;  // Lone Wanderer only
    [SerializeField] AbilityIconSlot fullDrawSlot;
    [SerializeField] AbilityIconSlot longShotSlot;   // Sharpshot only

    public void UpdateForHoldTime(float holdTime, string subclass) {
        AbilityType active = GetActiveTier(holdTime, subclass);
        // Light up active, dim all others
        foreach (var slot in allSlots)
            slot.SetActive(slot.abilityType == active);
    }

    AbilityType GetActiveTier(float holdTime, string subclass) {
        if (subclass == "Sharpshot") {
            if (holdTime >= 4.0f && longShotReady) return AbilityType.LongShot;
            if (holdTime >= 2.5f) return AbilityType.FullDraw;
            if (holdTime >= 1.5f && barbedUnlocked) return AbilityType.BarbedShot;
            if (holdTime >= 0.3f) return AbilityType.Standard;
        }
        else if (subclass == "LoneWanderer") {
            if (holdTime >= 2.5f) return AbilityType.FullDraw;
            if (holdTime >= 1.5f) return AbilityType.Standard;
            if (holdTime >= 0.3f && rapidFireReady) return AbilityType.RapidFire;
            if (holdTime >= 0.3f) return AbilityType.Standard; // RF on cooldown
        }
        return AbilityType.None;
    }
}
```

Only show slots for unlocked abilities. Long Shot on cooldown: greyed + shading timer.
Rapid Fire on cooldown: slot skips to Standard at 0.3s instead.

## Step 1b — Ability Row UI (Bottom, One Button Per Subclass)

Minimal row above hotbar — only abilities that don't fit the hold model:

```
[Player HP bar]
────────────────────────────────────────────
[Armor Piercer]                        ← Sharpshot (tap, 45s CD)
[Fade/Vanishing Act]                   ← Lone Wanderer (tap, 60s CD)
[HP]        [Stamina]   [Antidote]     ← existing hotbar
```

---

## Step 2 — Hold Timer + Active Tier Resolution

Add to `WardenBowstringMechanic`:

```csharp
private float _holdTime = 0f;
private AbilityType _activeTier = AbilityType.None;

// Called every frame while finger is held down:
void OnDrawHeld(float holdTime) {
    _holdTime = holdTime;
    _activeTier = iconStack.UpdateForHoldTime(holdTime, currentSubclass);
}

// On release — fire the active tier:
void OnRelease() {
    var tier = _activeTier;
    _holdTime = 0f;
    _activeTier = AbilityType.None;
    iconStack.UpdateForHoldTime(0f, currentSubclass); // reset icons

    if (tier == AbilityType.None) return; // sub-0.3s — nothing fires
    OnShotFired(tier);
}
```

Thresholds are checked in `iconStack.GetActiveTier()` (Step 1).
No separate prime/expiry state needed — the tier is live while holding.

---

## Step 3 — Shot Resolution by Tier

```csharp
void OnShotFired(AbilityType tier) {
    // Perform the arc linecast (existing system)
    var (hit, isWeakPoint) = PerformArcLinecast();

    float damage = CalculateBaseDamage(); // DEX × 1.5 + BowDamage
    bool ignoreArmor = false;
    bool allCoatingsProc = false;
    bool guaranteedWeakPoint = false;

    switch (tier) {
        case AbilityType.Standard:
            break; // base damage, no modifiers

        case AbilityType.BarbedShot:
            TryApplyBarbedBleed();
            break;

        case AbilityType.RapidFire:
            FireRapidBurst(); // fires 3 shots, returns early
            return;

        case AbilityType.FullDraw:
            damage *= GetHuntersPatienceBonus(_holdTime);    // +8%/0.5s, max +24%
            damage *= snipersVantageUnlocked ? 1.15f : 1.0f; // +15%
            if (piercingShotUnlocked) _nextEnemyTakesDamage = damage * 0.60f;
            break;

        case AbilityType.LongShot:
            if (_longShotCooldown > 0) { tier = AbilityType.FullDraw; break; }
            damage *= 8.0f;
            ignoreArmor = true;
            guaranteedWeakPoint = true;
            allCoatingsProc = true;
            if (currentEnemy == markedEnemy) damage *= 1.5f;
            StartCooldown(AbilityType.LongShot, 90f);
            break;
    }

    // Weak point
    float weakMult = (isWeakPoint || guaranteedWeakPoint) ? 2.0f : 1.0f;
    damage *= weakMult;

    // Armor piercer from ability row
    if (_armorPiercerActive) { ignoreArmor = true; _armorPiercerActive = false; }

    damage = ApplyOutcome(damage, ignoreArmor);

    if (allCoatingsProc) ForceAllCoatingProcs();
    else TryCoatingProc();

    OnAttackFired(damage);
}
```

Note: Long Shot while on cooldown silently falls back to Full Draw tier.
Player sees the Long Shot icon greyed — they know it's not available.

---

## Step 4 — Each Ability

### Barbed Shot

```csharp
void TryApplyBarbedBleed() {
    if (!currentEnemy.HasBleed(BleedType.Barbed) && Random.value < 0.20f) {
        float tickDmg = GetBarbedBleedTick(); // from quiver tier
        currentEnemy.ApplyBleed(BleedType.Barbed, tickDmg, bleedDuration);
    }
    // If already bleeding: do nothing — no stack, no refresh
    // No cooldown — limited by 20% proc and no-stack rule
}
```

### Long Shot (hold to arm)

```csharp
void ArmLongShot() {
    if (_longShotCooldown > 0) return;
    _longShotArmed = true;
    trajectoryLine.color = goldColor; // gold trajectory when armed
    abilityRow.SetArmed(AbilityType.LongShot, true);
}
```

Fires in `OnShotFired()` above when `_longShotArmed == true`.

### Rapid Fire

```csharp
void FireRapidBurst() {
    // Called from OnShotFired when tier == RapidFire
    float lockedAimX = _currentAimX; // locked at release moment
    float lockedLoft = _currentLoft;

    for (int i = 0; i < 3; i++) {
        float loftSpread = Random.Range(-0.05f, 0.05f);
        float shotDamage = CalculateBaseDamage() * 0.65f;

        bool procRoll = Random.value < 0.88f; // -12% proc hit chance
        var (hit, isWeakPoint) = PerformArcLinecast(lockedAimX,
                                    lockedLoft + loftSpread);
        if (hit) {
            float weakMult = isWeakPoint ? 2.0f : 1.0f;
            float damage = ApplyOutcome(shotDamage * weakMult, false);
            if (procRoll) TryCoatingProc();
            OnAttackFired(damage);
        }
    }
    StartCooldown(AbilityType.RapidFire, 8f);
}
```

Rapid Fire fires on release at the 0.3s tier — same gesture as any other shot,
just a shorter hold. Three shots at the release aim position with slight loft spread.

### Armor Piercer

Applied in `OnShotFired()` above. Simple — next shot ignores armor.

### Fade / Vanishing Act

```csharp
void ActivateFade() {
    if (_fadeCooldown > 0) return;

    float duration = vanishingActUnlocked ? 20f : 8f;
    EnterShroud(duration);
    _comingFromShroud = true;

    // Vanishing Act: coating DoTs continue during stealth
    // Handled by CombatManager.TickEnemyDot — not interrupted by shroud state

    StartCooldown(AbilityType.Fade, 60f);
}

// In OnShotFired(), apply Shadow's Edge if from Shroud:
if (_comingFromShroud) {
    damage *= 2.5f; // +150% — same as Shadowblade's Shadow's Edge
    ShowCriticalLabel();
    _comingFromShroud = false;
    ExitShroud();
}
```

---

## Step 5 — Reveal Talent Wiring

Wire the existing stub:

```csharp
// In ZoneCombatView:
public bool HasWeakPointRevealTalent() =>
    TalentManager.GetTalentLevel("Tracking") >= 33
    || CombatXPManager.GetGrimoireLevel("LoneWanderer") >= 38
    || CombatXPManager.GetGrimoireLevel("Sharpshot") >= 59;
```

`UpdateWeakPointGlow()` already calls this — no further changes needed once wired.

---

## Step 6 — Stat Formula Update

Update `stat-scaling-combat-formulas.md`:

```
WARDEN ACTIVE COMBAT DAMAGE (replaces draw-power model):
  BaseDamage = (DEX × 1.5) + BowDamage + DEXEquipmentBonus
  ShotDamage = BaseDamage × WeakPointMultiplier × OutcomeModifier
  WeakPointMultiplier = 2.0 (hit UV inside weakPointMask) or 1.0
  OutcomeModifier: Hit=1.0, Blocked=0.3, Evaded/Miss=0.0
```

---

## Step 7 — Loft Indicator UI (Right Side)

Passive visual guide — three labelled zones on the right side of the combat screen:

```
[ ↑ HEAD  ]   ← high loft region
[ → CHEST ]   ← medium loft region
[ ↓ BODY  ]   ← low loft region
```

These map the loft range (`_arcPeakMin` to `_arcPeakMax`) to body regions.
Not interactive — purely educational. A horizontal line moves up/down as the
player draws to show current loft position within the zones.

Hidden condition: Grimoire level 50+ OR player toggles off in settings.

```csharp
loftIndicator.SetActive(
    GrimoireManager.GetCurrentGrimoireLevel() < 50
    && PlayerSettings.showLoftIndicator
);
```

---

## Step 8 — Subclass Tuning

Set in inspector on `WardenBowstringMechanic` per subclass (configured in
`WardenBowstringMechanic.Configure(subclass)`):

```csharp
if (subclass == "Sharpshot") {
    _arcPeakMax     = 6.0f;   // higher loft ceiling
    _trajectoryReveal = 0.55f; // more hidden — read by feel
    _steerResponse  = 0.4f;   // slower steering — precision
    _drawResponse   = 0.4f;   // slower draw — deliberate
}
else if (subclass == "LoneWanderer") {
    _arcPeakMax     = 4.0f;   // flatter arcs
    _trajectoryReveal = 0.80f; // more visible line — reactive play
    _steerResponse  = 0.7f;   // faster steering — agility
    _drawResponse   = 0.7f;   // faster draw — aggressive
}
```

Tune these values during playtesting — the spec sets intent, numbers are final
only after feel testing.

---

## Implementation Order

1. `WardenAbilityIconStack` component — right side, per-subclass slots, threshold lighting
2. Hold timer fed into `iconStack.UpdateForHoldTime()` each frame while drawing
3. `OnRelease()` reads active tier → routes to `OnShotFired(tier)`
4. `OnShotFired(tier)` switch — Standard, Barbed, FullDraw, LongShot, RapidFire
5. Barbed Shot bleed proc (20%, no stack/refresh)
6. Rapid Fire burst (3 shots in `FireRapidBurst()`)
7. Full Draw Hunter's Patience + Sniper's Vantage bonuses
8. Long Shot (×8.0, armor ignore, guaranteed weak point, 90s CD + greyed icon)
9. Ability row panel (one button per subclass — Armor Piercer / Fade)
10. Armor Piercer `_armorPiercerActive` flag checked in `OnShotFired()`
11. Fade/Vanishing Act stealth + shroud opener
12. Reveal talent `HasWeakPointRevealTalent()` wired
13. Stat formula update in `stat-scaling-combat-formulas.md`
14. Subclass tuning in `Configure(subclass)` — tune in playtesting

---

*Path: `docs/warden-combat-implementation-brief.md`*
