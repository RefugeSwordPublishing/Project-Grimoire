---
type: implementation-brief
spec: runic-constellation-spec.md (v0.3)
updated: 2026-07-11
purpose: Wire ArcanistConstellationMechanic into the existing ActiveCombatMechanic seam.
         Read this alongside runic-constellation-spec.md — this brief covers the seam
         integration only, not the full spell/combo library.
---

# Arcanist Constellation — Implementation Brief

## The Seam Contract

Implement `ArcanistConstellationMechanic : ActiveCombatMechanic` mirroring
`WardenBowstringMechanic` as the template. Three methods to implement:

```csharp
public override void Configure(string subclass) {
    // Load the correct 6-node layout and SpellData lookup table
    // for Runeweaver / Summoner / Lifebinder
}

public override void SetEngaged(bool engaged) {
    // Show/hide the ConstellationUI
    // On disengage: clear any in-progress sequence, reset to idle
}

public override float OnAttackFired(float baseDamage) {
    // Called by CombatManager when a spell fires
    // Return: baseDamage × depthMultiplier × speedMultiplier × counterMultiplier
    // Lifebinder: deduct HP cost instead of mana; return heal amount (negative damage)
}
```

---

## Active vs Idle Arbitration — mirrors Bowstring exactly

```
Player touches first node
    → SetEngaged(true) fires
    → ConstellationUI activates, idle auto-attack suppressed
    → drawStartTime = Time.time

Player drags between nodes, building sequence

Player lifts finger
    → Resolve sequence → fire spell → OnAttackFired(multiplier)
    → Start 1.5s idle-return timer

If player touches a node again before 1.5s expires
    → Cancel timer, begin new draw — still in active mode

If 1.5s elapses with no new touch
    → SetEngaged(false)
    → Constellation UI deactivates
    → Idle auto-attack resumes (auto-casts last used combo at 60% potency)
```

This is identical to the Bowstring's 1.5s grace period (`_bowGracePeriod`).
Reuse the same pattern from `WardenBowstringMechanic` — just swap draw events
for node-touch events.

```csharp
private float _lastInputTime;
private const float _idleReturnDelay = 1.5f;

void Update() {
    if (_engaged && Time.time - _lastInputTime > _idleReturnDelay) {
        SetEngaged(false);
        CombatManager.IdleAttackActive = true;
    }
}

void OnNodeTouched() {
    _lastInputTime = Time.time;
    if (!_engaged) SetEngaged(true);
    CombatManager.IdleAttackActive = false;
}
```

---

## Damage Multiplier — what OnAttackFired receives

```csharp
float depthMultiplier = sequence.Count switch {
    1 => 1.0f,
    2 => 1.4f,
    3 => 1.8f,
    4 => 2.2f,
    _ => 1.0f
};

float speedMultiplier = (Time.time - drawStartTime) switch {
    < 0.4f => 1.5f,   // Lightning
    < 0.8f => 1.25f,  // Swift
    < 1.5f => 1.0f,   // Standard
    _      => 0.85f   // Slow
};

float counterMultiplier = IsCounterPair(sequence, currentSubclass) ? 1.25f : 1.0f;

float totalMultiplier = depthMultiplier * speedMultiplier * counterMultiplier;
// Pass totalMultiplier into OnAttackFired
```

For **Lifebinder**: `OnAttackFired` deducts HP cost instead of triggering damage.
Return 0 damage to `CombatManager`; apply heal to target via `PlayerData.RestoreHP`
or party heal. HP cost = `baseCost * depthMultiplier * (1 - WIL * 0.003f, max 0.3f)`.
Spell blocked (default fires instead) if cost would reduce caster HP ≤ 1.

---

## Sequence Resolution

```csharp
void OnFingerLifted() {
    _lastInputTime = Time.time;

    if (currentSequence.Count == 0) return;

    // Order-independent lookup — sort before key
    var key = new HashSet<RuneType>(currentSequence);
    SpellData spell = subclassSpellTable.TryGetValue(key, out var s)
                    ? s
                    : defaultWeakSpell; // 40% potency Ignis blast

    FireSpell(spell);
    lastUsedSequence = new List<RuneType>(currentSequence);
    currentSequence.Clear();
}
```

---

## Idle Auto-Cast

When `SetEngaged(false)` and combat is running:

```csharp
void IdleCast() {
    // Use lastUsedSequence if available, else single Ignis
    var idleSequence = lastUsedSequence?.Count > 0
                     ? lastUsedSequence
                     : new List<RuneType> { RuneType.Ignis };

    SpellData spell = subclassSpellTable.TryGetValue(
                        new HashSet<RuneType>(idleSequence), out var s)
                    ? s : defaultWeakSpell;

    // Fire at 60% potency — no speed or counter bonus
    float idleMultiplier = GetDepthMultiplier(idleSequence.Count) * 0.6f;
    OnAttackFired(idleMultiplier);
}
```

Idle cast interval: same 2s `_playerAttackInterval` already in `CombatManager`.
Counter bonus DOES apply during idle if `lastUsedSequence` is a counter pair —
it was a deliberate knowledge choice. Speed bonus does NOT apply.

---

## Subclass Node Layouts

Load on `Configure(subclass)`:

```csharp
// activeNodes drives which node buttons render in ConstellationUI
activeNodes = subclass switch {
    "Runeweaver" => new[] { Ignis, Glacius, Tempest, Ventus, Umbra, Lux },
    "Summoner"   => new[] { Ignis, Glacius, Tempest, Ventus, Terra, Umbra },
    "Lifebinder" => new[] { Ignis, Glacius, Tempest, Ventus, Vita, Lux },
    _ => new[] { Ignis, Glacius, Tempest, Ventus, Umbra, Lux }
};

// Load matching SpellData lookup table
subclassSpellTable = subclass switch {
    "Runeweaver" => RuneweaverSpells,
    "Summoner"   => SummonerSpells,
    "Lifebinder" => LifebinderSpells,
    _ => RuneweaverSpells
};
```

Inactive nodes (2 per subclass) are not rendered — just don't instantiate buttons
for nodes not in `activeNodes`. No blocking logic needed.

---

## Combination Depth Unlocks

Gate in `Configure` based on `CombatXPManager.GetGrimoireLevel(equippedGrimoireId)`:

```csharp
int combatLevel = CombatXPManager.GetGrimoireLevel(equippedGrimoireId);
maxSequenceLength = combatLevel switch {
    >= 88 => 4,
    >= 42 => 3,  // Runeweaver: >= 35
    >= 16 => 2,
    _     => 1
};
```

On reaching max length, fire immediately — don't wait for finger lift.

---

## No-Crit Enforcement

```csharp
// In CombatManager when Arcanist path equipped:
critChance = 0f;
weakPointEnabled = false;
// Warden weak-point system unaffected
```

---

## Mana Cost (Runeweaver + Summoner only)

```csharp
int manaCost = maxSequenceLength switch {
    1 => 5,
    2 => 10,
    3 => 18,
    4 => 28,
    _ => 2  // default weak spell
};

if (PlayerData.CurrentMana < manaCost) {
    FireSpell(defaultWeakSpell); // 2 mana cost
    return;
}
PlayerData.CurrentMana -= manaCost;
```

Lifebinder: skip this block entirely (`hasManaPool = false`).

---

## What's NOT in this brief

Full spell library, counter pair tables, Summoner construct commands, Lifebinder
HOT system — all in `runic-constellation-spec.md`, `summoner-spec.md`,
`lifebinder-spec.md`. Phase 1 of implementation: get the seam wired, single-rune
spells firing, idle return working. Spell library and subclass-specific behaviour
layer on top once the seam is confirmed working.

---

*Path: `docs/constellation-implementation-brief.md`*
