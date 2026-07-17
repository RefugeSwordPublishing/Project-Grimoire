---
type: implementation-brief
spec: aggro-spec.md (v0.1)
updated: 2026-07-11
purpose: Wire AggroManager.cs into the existing CombatManager, VanguardComboMechanic,
         ArcanistConstellationMechanic, and ConstructManager. Read alongside aggro-spec.md.
---

# Aggro System — Implementation Brief

## What's Already Built (hook into these)

- `CombatManager` — damage events `OnPlayerAttack`, `OnEnemyAttack` already fire
- `VanguardComboMechanic` — `OnAttackFired(multiplier)` fires on combo resolution
- `ActiveCombatMechanic` — base class all combat paths implement
- `ConstructManager` — construct damage events (built with Summoner)
- `PlayerData` — subclass identity available via `GrimoireManager.currentSubclass`

---

## AggroManager.cs — Create This

Singleton, lives on `GameManager` or its own GameObject:

```csharp
public class AggroManager : MonoBehaviour {
    public static AggroManager Instance { get; private set; }

    // Per enemy → per entity aggro table
    private Dictionary<EnemyData, Dictionary<Entity, float>> _aggroTable
        = new Dictionary<EnemyData, Dictionary<Entity, float>>();

    void Awake() => Instance = this;

    // Called by CombatManager.Update
    public void Tick(float deltaTime) {
        AddPassiveAggro(deltaTime);
        DecayAggro(deltaTime);
    }

    public void AddAggro(EnemyData enemy, Entity source, float amount) {
        if (!_aggroTable.ContainsKey(enemy))
            _aggroTable[enemy] = new Dictionary<Entity, float>();
        if (!_aggroTable[enemy].ContainsKey(source))
            _aggroTable[enemy][source] = 0f;
        _aggroTable[enemy][source] += amount;
    }

    void AddPassiveAggro(float deltaTime) {
        foreach (var player in CombatManager.ActivePlayers)
            foreach (var enemy in CombatManager.ActiveEnemies)
                AddAggro(enemy, player,
                    GetPassiveRate(player.subclass) * deltaTime);
    }

    void DecayAggro(float deltaTime) {
        foreach (var table in _aggroTable.Values)
            foreach (var entity in table.Keys.ToList()) {
                float decay = IsTankSubclass(entity) ? 0.02f : 0.05f;
                table[entity] *= (1f - decay * deltaTime);
            }
    }

    public Entity GetTarget(EnemyData enemy) {
        if (!_aggroTable.ContainsKey(enemy)
            || _aggroTable[enemy].Count == 0)
            return CombatManager.NearestEntity(enemy); // fallback

        return _aggroTable[enemy]
            .OrderByDescending(kv => kv.Value)
            .First().Key;
    }

    public void ResetOnCombatEnd() => _aggroTable.Clear();
}
```

---

## Passive Aggro Rates — Set on PlayerData or SubclassData

Store as a lookup — drive from subclass name so it's data-driven:

```csharp
float GetPassiveRate(string subclass) => subclass switch {
    "Bulwark"      => 20f,
    "Warlord"      => 15f,
    "Runeweaver"   => 3f,
    "Sharpshot"    => 2f,
    "LoneWanderer" => 2f,
    "Summoner"     => 2f,
    "Lifebinder"   => 2f,
    "Shadowblade"  => 0f,
    _              => 2f
};

bool IsTankSubclass(Entity e) =>
    e.subclass == "Warlord" || e.subclass == "Bulwark";
```

---

## Damage Multipliers — Set on SubclassData ScriptableObject

Rather than hardcoding, add `aggroMultiplier` to `GrimoireData` or a
`SubclassData` ScriptableObject. Default values:

```
Warlord:      1.5
Bulwark:      1.2
Sharpshot:    0.8
LoneWanderer: 0.6
Runeweaver:   0.9
Summoner:     0.5  (personal — constructs generate their own)
Lifebinder:   0.4  (damage only — heals use separate multipliers)
Shadowblade:  0.3
```

---

## Wire Points — Where to Call AddAggro

### 1. CombatManager — on player damage dealt

```csharp
// In CombatManager, wherever player damage is applied to enemy:
void OnPlayerDamageDealt(float damage, EnemyData enemy) {
    float multiplier = GrimoireManager.currentGrimoire.aggroMultiplier;
    AggroManager.Instance.AddAggro(enemy, localPlayer, damage * multiplier);
}
```

### 2. VanguardComboMechanic — taunt combos

Already stubbed in the combo brief. Wire here:

```csharp
// In ResolveCombo(), after OnAttackFired:
if (combo.tauntValue > 0)
    AggroManager.Instance.AddAggro(
        CombatManager.CurrentEnemy,
        localPlayer,
        combo.tauntValue);
```

Taunt value spikes aggro independently of damage — it's a flat addition,
not multiplied by the class multiplier.

### 3. ArcanistConstellationMechanic — on spell damage

```csharp
// In OnAttackFired for Arcanist:
void OnAttackFired(float damageDealt) {
    float multiplier = GrimoireManager.currentGrimoire.aggroMultiplier;
    AggroManager.Instance.AddAggro(
        CombatManager.CurrentEnemy,
        localPlayer,
        damageDealt * multiplier);
}
```

### 4. Lifebinder — on heal events

```csharp
// In LifebinderCombat, on each heal applied:
void OnHealApplied(float healAmount, HealType healType) {
    float healAggro = healType switch {
        HealType.SingleHeal => healAmount * 0.4f,
        HealType.HOTTick    => healAmount * 0.2f,
        HealType.MassHeal   => healAmount * 0.6f,
        _                   => healAmount * 0.4f
    };
    // Aggro goes against all active enemies — healer draws attention
    foreach (var enemy in CombatManager.ActiveEnemies)
        AggroManager.Instance.AddAggro(enemy, localPlayer, healAggro);
}
```

### 5. ConstructManager — on construct damage

```csharp
// In ConstructManager, on each construct hit:
void OnConstructDamageDealt(Construct construct, float damage, EnemyData enemy) {
    float multiplier = GetConstructAggroMultiplier(construct.type);
    AggroManager.Instance.AddAggro(enemy, construct, damage * multiplier);
}

float GetConstructAggroMultiplier(ConstructType type) => type switch {
    ConstructType.StoneGolem        => 2.0f,
    ConstructType.StormWisp         => 1.2f,
    ConstructType.EmberSprite       => 1.0f,
    ConstructType.FrostShard        => 0.8f,
    ConstructType.CelestialGuardian => 0.5f, // of healing done
    ConstructType.VoidShade         => 0.3f,
    _                               => 1.0f
};
```

Note: Constructs are `Entity` subclass — `AggroManager` treats them the same
as players in the targeting table. `GetTarget()` will return a construct
if it has the highest aggro value.

---

## Enemy Target Selection — Wire Into Enemy AI

Currently enemies target the player directly. Replace with:

```csharp
// In EnemyAI or CombatManager, wherever enemy picks its target:
Entity target = AggroManager.Instance.GetTarget(currentEnemy);
// Attack target instead of hardcoded player reference
```

In solo zone combat this always returns the player (or highest-aggro construct
for Summoner) — no behavioural change for solo play.

---

## CombatManager.Tick — Add AggroManager.Tick

```csharp
// In CombatManager.Update():
void Update() {
    // ... existing combat loop ...
    AggroManager.Instance.Tick(Time.deltaTime);
}
```

---

## Reset on Combat End

```csharp
// In CombatManager, when combat session ends (player leaves zone,
// enemy defeated and no respawn pending, or retreat):
AggroManager.Instance.ResetOnCombatEnd();
```

---

## Solo Zone Combat — No Behaviour Change

In solo zone combat `CombatManager.ActivePlayers` has one entry.
Aggro still runs but trivially — only one target exists so `GetTarget()`
always returns the player. No special-casing needed.

Summoner is the exception — constructs register as separate entities,
so the Stone Golem will correctly absorb enemy targeting in solo combat.
This is intentional and the whole point of the Summoner HP pool mechanic.

---

## Phase 1 Goal

1. `AggroManager.cs` created as singleton
2. `Tick()` called from `CombatManager.Update()`
3. Passive aggro generating from subclass rates
4. Damage aggro wired from `CombatManager.OnPlayerDamageDealt`
5. Enemy target selection reading from `AggroManager.GetTarget()`
6. `ResetOnCombatEnd()` called on zone exit

Taunt combo wiring, Lifebinder heal aggro, and construct aggro
layer on top once the basic system is confirmed working.

---

*Path: `docs/aggro-implementation-brief.md`*
