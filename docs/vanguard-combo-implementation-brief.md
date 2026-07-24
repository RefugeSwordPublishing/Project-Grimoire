---
type: implementation-brief
spec: vanguard-combo-system.md (v0.2)
updated: 2026-07-11
purpose: Wire VanguardComboMechanic into the existing ActiveCombatMechanic seam.
         Read alongside vanguard-combo-system.md, this brief covers seam integration,
         stamina wiring, cooldown model, and idle behaviour only.
---

# Vanguard Combo System, Implementation Brief

## The Seam Contract

Implement `VanguardComboMechanic : ActiveCombatMechanic`:

```csharp
public override void Configure(string subclass) {
    // Load combo lookup table for Warlord / Shadowblade
    // Set maxSequenceLength based on Grimoire combat level
}

public override void SetEngaged(bool engaged) {
    // Show/hide Strike/Guard/Surge buttons
    // On disengage: clear in-progress sequence
}

public override float OnAttackFired(float baseDamage) {
    // Return baseDamage × comboMultiplier × speedBonus
    // Fire taunt into AggroManager if applicable
    // Apply defense buff via BuffManager if applicable
}
```

---

## Input Model, Instant Fire, Per-Combo Cooldown

Combos fire **immediately** when the sequence is complete, no waiting.
After firing, a **per-combo cooldown** prevents entering another combo until
it expires. The player can still tap during cooldown but inputs are ignored.

```
Player taps S → G → U  (3-input sequence complete)
    → Combo fires instantly
    → Cooldown timer starts for that specific combo
    → Strike/Guard/Surge buttons show cooldown overlay
    → Inputs blocked until cooldown expires

Cooldown expires
    → Buttons re-enable
    → Player can enter next combo
```

**No 1.5s wait. No auto-fire timer. Sequence complete = fire immediately.**

Sequence is "complete" when:
- Player taps `maxSequenceLength` inputs, fires at max depth
- Player taps a valid known sequence shorter than max, fires immediately on recognition
- Player taps an unrecognised sequence, fires base attack for the first input, clears

---

## Cooldown Model

Bigger combos deal more damage so they have **longer** cooldowns. Skill expression
is knowing which combo to use, not chaining hard-hitting attacks as fast as possible.

### Base cooldown by depth

| Depth | Base cooldown |
|-------|-------------|
| 1-input | 1.0s |
| 2-input | 2.5s |
| 3-input | 4.0s |

### Per-combo overrides (defined on ComboData)

High-impact combos have their own cooldown regardless of depth:

| Combo | Override | Reason |
|-------|---------|--------|
| U→U (Warcry, AoE taunt) | 6.0s | Too powerful to spam |
| U→U→S (Legendary Strike, +200%) | 8.0s | Highest damage in game |
| U→U→G (Indomitable, full tank CD) | 10.0s | Raid survival cooldown |
| G→G→G (Immovable, Bulwark) | 8.0s | Full defensive stance |
| U→U (Void Step, Shadowblade stealth) | 8.0s | Stealth entry gated |

```csharp
float GetCooldown(ComboData combo) {
    if (combo.cooldownOverride > 0) return combo.cooldownOverride;
    return combo.sequence.Length switch {
        1 => 1.0f,
        2 => 2.5f,
        3 => 4.0f,
        _ => 1.0f
    };
}
```

---

## Cooldown UI, Shading Overlay

Each Strike/Guard/Surge button shows a **shading overlay that empties downward**
as the cooldown counts down, standard MMO cooldown style.

```csharp
// On combo fire:
float cd = GetCooldown(firedCombo);
StartCooldown(cd);

void StartCooldown(float duration) {
    _cooldownActive = true;
    _cooldownTotal = duration;
    _cooldownRemaining = duration;
    // All three buttons enter cooldown state, one combo at a time
}

void Update() {
    if (_cooldownActive) {
        _cooldownRemaining -= Time.deltaTime;
        float fillAmount = _cooldownRemaining / _cooldownTotal;
        // fillAmount drives the overlay, 1.0 = fully shaded, 0.0 = clear
        cooldownOverlay.fillAmount = fillAmount;

        if (_cooldownRemaining <= 0) {
            _cooldownActive = false;
            cooldownOverlay.fillAmount = 0;
        }
    }
}
```

**Aggro display on cooldown icon:**
When a taunt combo is active (aggro effect running), tint the cooldown overlay
red instead of the default grey. Gives Warlord/Bulwark a visual read on whether
their taunt is still holding.

```csharp
cooldownOverlay.color = combo.tauntValue > 0 ? tauntColor : defaultColor;
// tauntColor = semi-transparent red
// defaultColor = semi-transparent dark grey
```

---

## Stamina, Active and Idle

### Active play
```csharp
void FireCombo(ComboData combo) {
    int staminaCost = combo.sequence.Length switch {
        1 => 0,
        2 => 8,
        3 => 18,
        _ => 0
    };

    if (staminaCost > 0 && PlayerData.CurrentStamina < staminaCost) {
        // Insufficient stamina, fire base Strike instead, no cooldown
        ExecuteBaseAttack(ComboInput.Strike);
        return;
    }

    PlayerData.CurrentStamina -= staminaCost;
    ResolveCombo(combo);
    StartCooldown(GetCooldown(combo));
}
```

### Idle play, stamina IS used, random selection

Idle Vanguard runs the same "do this until done or out of resources" loop as
every other idle talent. No queue, no player preferences, just the idle loop.

```csharp
void IdleCast() {
    // Get all unlocked combos affordable with current stamina
    var affordable = unlockedCombos
        .Where(c => GetStaminaCost(c) <= PlayerData.CurrentStamina)
        .ToList();

    if (affordable.Count == 0) {
        // No stamina for any combo, fire free Strike
        ExecuteBaseAttack(ComboInput.Strike);
        return;
    }

    // Weighted random, cheaper combos fire more often (stamina-weighted)
    // This naturally biases toward shorter combos, lower output than active
    ComboData selected = WeightedRandom(affordable,
        c => 1f / Mathf.Max(1, GetStaminaCost(c)));

    int cost = GetStaminaCost(selected);
    PlayerData.CurrentStamina -= cost;

    // Idle fires at 70% potency, no speed bonus
    float idleMultiplier = selected.damageMultiplier * 0.7f;
    OnAttackFired(idleMultiplier);

    // Idle respects cooldown too, next idle cast delayed by combo cooldown
    StartCooldown(GetCooldown(selected));
}
```

Stamina regens at 2/sec during combat (already in `CombatManager.TickResources`).
When stamina runs low idle naturally shifts to cheaper combos and eventually single
Strike until it regens, no special-case logic needed.

**Idle output is lower than active because:**
- Random selection is suboptimal (player would pick better combos)
- 70% potency multiplier applied
- No speed bonus (can't measure draw time on automated cast)
- Heavier combos occasionally selected draining stamina faster than ideal

---

## Active vs Idle Arbitration

```csharp
void OnButtonTapped(ComboInput input) {
    if (_cooldownActive) return; // blocked during cooldown

    if (!_engaged) {
        SetEngaged(true);
        CombatManager.IdleAttackActive = false;
    }

    currentSequence.Add(input);
    TryResolve();
}

void TryResolve() {
    string key = string.Concat(currentSequence.Select(i => i.ToString()[0]));

    // Check if current sequence matches a known combo
    bool exactMatch = subclassComboTable.ContainsKey(key);
    bool maxDepth = currentSequence.Count >= maxSequenceLength;

    if (exactMatch || maxDepth) {
        ComboData combo = subclassComboTable.TryGetValue(key, out var c)
                        ? c : GetBaseAttack(currentSequence[0]);
        FireCombo(combo);
        currentSequence.Clear();
    }
    // else: sequence still building, wait for next tap
}

// Return to idle when cooldown expires and no input arrives
void Update() {
    // ... cooldown tick ...

    if (!_cooldownActive && _engaged
        && Time.time - _lastInputTime > 1.5f) {
        SetEngaged(false);
        CombatManager.IdleAttackActive = true;
    }
}
```

The 1.5s here is the **idle return after cooldown expires**, not a combo fire delay.
Player has 1.5s after their cooldown clears to tap again before idle resumes.

---

## Combo Depth Unlocks

```csharp
int combatLevel = CombatXPManager.GetGrimoireLevel(equippedGrimoireId);
maxSequenceLength = combatLevel switch {
    >= 35 => 3,
    >= 15 => 2,
    _     => 1
};
```

---

## Shadow's Edge, Shadowblade passive

```csharp
if (currentSubclass == "Shadowblade" && _comingFromShroud) {
    multiplier *= 1.8f;       // flat multiplier, NOT a crit
    ShowCriticalLabel();       // "Critical!" UI only
    _comingFromShroud = false;
}
```

`U→U` (Void Step) sets `_comingFromShroud = true`. Next Strike clears it.
`critChance` remains 0, never a crit proc.

---

## No-Crit Enforcement

```csharp
if (currentGrimoire.path == GrimoirePath.Vanguard) {
    critChance = 0f;
    weakPointEnabled = false;
}
```

---

## ComboData ScriptableObject

```csharp
public class ComboData : ScriptableObject {
    public string sequence;           // "SGU", "SS", "GGG"
    public string subclass;           // "Warlord" or "Shadowblade"
    public float damageMultiplier;
    public float defenseModifier;     // 0 if none
    public float durationSeconds;     // for defense buff duration
    public int tauntValue;            // 0 if no taunt
    public int unlockGrimoireLevel;   // 1, 15, or 35
    public float cooldownOverride;    // 0 = use depth default
}
```

---

## Phase 1 Goal

Get the seam wired with a minimal combo set first:
- S, G, U singles (depth 1)
- S→S, S→G, G→S, G→U, U→S, U→U (depth 2 starter set)
- Cooldown overlay on buttons working
- Stamina depleting and regen confirmed
- Idle random selection confirmed

Full combo library, streak system, and per-combo taunt/defense effects
layer on top once the seam is confirmed working.

Full combo library: `vanguard-combo-system.md`
Aggro wiring: `aggro-spec.md`

---

*Path: `docs/vanguard-combo-implementation-brief.md`*
