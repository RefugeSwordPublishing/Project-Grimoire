---
type: design-spec
version: 0.1
updated: 2026-07-11
promoted-from: CLAUDE.md summary
---

# Project Grimoire — Aggro System Spec
### Version 0.1

> This spec promotes the aggro model from the brief description in `CLAUDE.md` into a full
> implementable specification. It is the authoritative source for `AggroManager.cs`.

---

## Design Philosophy

Aggro determines which entity enemies target in group combat (dungeons, raids). The hybrid model
ensures tanks reliably hold threat over active damage dealers without requiring non-stop input.
Pure damage-based aggro would let an idle Warlord lose threat to an active Runeweaver; the passive
rate component prevents this.

---

## Aggro Formula

```
aggroValue = passiveRate * deltaTime
           + (damageOrHealDealt * classMultiplier)
           + tauntComboValue
```

All three terms are additive. `aggroValue` is a running float per player-entity pair, evaluated
by the enemy AI every frame to pick its current target.

---

## Passive Aggro Rate (per second)

Generated simply by being present in combat — critical for idle sessions.

| Subclass | Passive rate/sec | Notes |
|----------|-----------------|-------|
| Bulwark | 20 | Highest — pure tank identity |
| Warlord | 15 | Strong passive + taunt combos |
| Sharpshot | 2 | Low — ranged damage dealer |
| Lone Wanderer | 2 | Low — solo/stealth identity |
| Runeweaver | 3 | Standard damage dealer |
| Summoner (personal) | 2 | Constructs generate independent aggro (see below) |
| Lifebinder | 2 | Healing generates separate aggro (see below) |
| Shadowblade | **0** | Actively avoids aggro by design |

---

## Damage / Heal Aggro Multiplier

Applied to every point of damage or healing dealt:

| Subclass | Multiplier | Notes |
|----------|-----------|-------|
| Warlord | ×1.5 | Elevated — intended to out-aggro DPS even when dealing less damage |
| Bulwark | ×1.2 | Elevated — some damage, lots of passive |
| Sharpshot | ×0.8 | Reduced — high damage but should stay off primary target |
| Lone Wanderer | ×0.6 | Lowest non-zero — stealth/survival identity |
| Runeweaver | ×0.9 | Near-standard |
| Summoner (personal) | ×0.5 | Constructs generate their own aggro — see below |
| Lifebinder | ×0.4 | Healing generates aggro via separate modifier below |
| Shadowblade | ×0.3 | Near-zero — highest damage, near-invisible aggro profile |

### Lifebinder Healing Aggro

Healing generates aggro at a separate rate applied on each heal event:

| Heal type | Aggro generated |
|-----------|----------------|
| Single heal (Mend etc.) | heal amount × 0.4 |
| HOT tick | tick amount × 0.2 |
| Mass heal (all allies) | total healed × 0.6 |
| Offensive spell | damage dealt × 0.8 (standard) |

---

## Taunt Combo Values

Vanguard combo combos with taunt effects add a one-time flat spike to `aggroValue`:

| Combo | Subclass | Taunt value added |
|-------|---------|-----------------|
| G→U (Bulwark Surge) | Warlord | +200 |
| U→U (Warcry) | Warlord | +500 (AoE — applies vs all nearby enemies) |
| G→G (Shield Wall) | Bulwark | +300 |
| G→U (Aegis Surge) | Bulwark | +250 |
| G→G→U (Bulwark's Oath) | Bulwark | +400 |
| G→U→G (Fortress) | Bulwark | +350 |
| G→U→S (Titan's Blow) | Warlord | +600 (highest single taunt) |
| U→U→G (Indomitable) | Warlord | +450 |
| U→G→G (Inviolable) | Bulwark | +500 |
| All Shadowblade combos | Shadowblade | +0 (Shadowblade generates no taunt) |

Taunt effects on multi-target combos (Warcry, Whirlwind) apply the taunt value against each
enemy in range independently.

---

## Aggro Decay

Aggro decays over time to prevent permanent lock-on and give tanks room to recover:

```csharp
void Update() {
    float decayRate = isTankSubclass ? 0.02f : 0.05f;
    aggroValue *= (1f - decayRate * Time.deltaTime);
}
```

| Subclass | Decay rate |
|----------|-----------|
| Warlord, Bulwark | 2%/sec — slower decay keeps threat through brief pauses |
| All others | 5%/sec |

On combat end: all aggro values reset to 0.

---

## Summoner Constructs — Independent Aggro

Each active construct maintains its own `aggroValue` against each enemy, separate from the
Summoner's personal aggro. Enemy AI evaluates all players AND all constructs and targets the
entity with the highest aggro.

| Construct | Aggro multiplier (of damage dealt) |
|-----------|-----------------------------------|
| Stone Golem | ×2.0 — primary aggro sink |
| Storm Wisp | ×1.2 — chain attacks spread aggro |
| Ember Sprite | ×1.0 |
| Frost Shard | ×0.8 |
| Celestial Guardian | ×0.5 (of healing done) |
| Void Shade | ×0.3 — near-invisible |

Constructs use the same 5%/sec decay as non-tank entities.
Summoner personal aggro (×0.2 of all actions) means the Summoner is almost never targeted while
constructs are alive.

---

## Target Selection — Enemy AI

Enemy evaluates its target each frame:

```csharp
Entity GetTarget(Enemy enemy) {
    // Collect all players + all active constructs
    var candidates = activePlayers.Cast<Entity>()
        .Concat(activeConstructs.Cast<Entity>());

    return candidates
        .OrderByDescending(e => e.GetAggroValue(enemy))
        .First();
}
```

Ties are broken by proximity. If all aggro values are 0 (start of combat), enemy targets the
nearest entity.

---

## Implementation — AggroManager

`AggroManager.cs` is a singleton manager:

```csharp
public class AggroManager : MonoBehaviour {
    // Per enemy → per entity aggro table
    private Dictionary<Enemy, Dictionary<Entity, float>> _aggroTable;

    public void AddAggro(Enemy enemy, Entity source, float amount) {
        _aggroTable[enemy][source] += amount;
    }

    public void AddPassiveAggro(float deltaTime) {
        foreach (var player in _activePlayers)
            foreach (var enemy in _activeEnemies)
                AddAggro(enemy, player, player.passiveAggroRate * deltaTime);
    }

    public void DecayAggro(float deltaTime) {
        foreach (var enemyTable in _aggroTable.Values)
            foreach (var entity in enemyTable.Keys.ToList()) {
                float decay = entity.isTankSubclass ? 0.02f : 0.05f;
                enemyTable[entity] *= (1f - decay * deltaTime);
            }
    }

    public Entity GetTarget(Enemy enemy) =>
        _aggroTable[enemy].OrderByDescending(kv => kv.Value).First().Key;

    public void ResetOnCombatEnd() => _aggroTable.Clear();
}
```

Call `AddPassiveAggro` and `DecayAggro` from `Update`. Call `AddAggro` from:
- `CombatManager` on damage dealt (amount = damage × classMultiplier)
- `LifebinderCombat` on heal events (amount = healAmount × healAggroMultiplier)
- `VanguardCombo` on taunt combos (amount = tauntComboValue)
- `ConstructManager` on construct damage (amount = damage × constructMultiplier)

---

## Zone Combat (Solo)

In solo zone combat there is only one player entity and no other players. Aggro is irrelevant —
the single enemy always targets the player (or, for Summoner, the highest-aggro construct).
`AggroManager` still runs but with a trivial table: no tank/DPS competition.

---

## Dungeons and Raids

Aggro becomes meaningful when 2+ player entities are in the same encounter. Warlord/Bulwark must
actively maintain aggro through passive rate + taunt combos or the enemy will drift to a Runeweaver
dealing heavy damage.

Zone bosses follow the same aggro rules as dungeon bosses — active play only, same AI.

---

*Path: `docs/aggro-spec.md`*
