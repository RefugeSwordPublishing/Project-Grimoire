---
type: design-spec
version: 0.2
updated: 2026-07-11
reconciled-to: implementation-status.md (2026-07-10)
---

# Project Grimoire — Summoner Subclass Spec
### Version 0.2

> **Changes from v0.1:** All "Spellcasting level" references replaced with "Grimoire combat level".
> Construct special-ability trigger commands cross-checked against Summoner's 6-node layout
> (Ignis, Glacius, Tempest, Ventus, Terra, Umbra) — two conflicts fixed:
> • Celestial Guardian special was `Lux+Lux` — Lux is not in Summoner's constellation.
>   Fixed to `Terra + Ventus` (guardian plants itself and anchors).
> • Void Shade special was `Umbra+Vita` — Vita is not in Summoner's constellation.
>   Fixed to `Umbra + Glacius` (shadow-frost drain).
> Mana is used by Summoner (unlike Lifebinder). This is explicit below.

---

## Design Philosophy

The Summoner is a backline tactician whose constructs ARE their HP pool. Losing constructs IS
taking damage. Managing constructs IS combat. The idle vs active output gap is intentionally larger
than any other class — active commands unlock specials and synergies that idle cannot.

**Core principles:**
- Constructs collectively form the primary HP pool; Summoner has a 25% personal buffer
- Enemies target highest-aggro construct, not the Summoner directly
- Idle: constructs auto-attack (~50% output); active commands unlock specials and synergies (~100%)
- Summoner uses **mana** (not HP) to summon constructs — distinct from Lifebinder
- 6 active constellation nodes: Ignis, Glacius, Tempest, Ventus, Terra, Umbra

---

## HP Pool System

```
Summoner Personal HP = baseHP × 0.25
Effective HP         = Personal HP + Sum(activeConstructs[i].currentHP)
```

**Construct HP by tier:**

| Tier | HP contribution |
|------|----------------|
| Crude | 40 |
| Rough | 80 |
| Refined | 140 |
| Pristine | 220 |
| Masterwork | 320 |

**Damage routing:**
Incoming damage → highest-aggro construct. If no constructs alive → Summoner personal HP.
On construct HP = 0: destroyed, removed from effective pool, enemy re-evaluates targets.

**Implementation reference:**
```csharp
float effectiveHP = (baseHP * 0.25f) + activeConstructs.Sum(c => c.currentHP);

Construct target = activeConstructs.OrderByDescending(c => c.aggroValue).FirstOrDefault();
if (target != null) target.TakeDamage(dmg);
else summoner.TakePersonalDamage(dmg);
```

---

## The Six Constructs

| Construct | Element | Role | Grimoire combat level to unlock |
|-----------|---------|------|---------------------------------|
| **Ember Sprite** | Fire | High damage, low HP | 1 |
| **Stone Golem** | Earth | High HP, low damage — primary aggro sink | 1 |
| **Frost Shard** | Ice | Slow + moderate damage | 20 |
| **Storm Wisp** | Lightning | Chain damage to multiple targets | 35 |
| **Void Shade** | Shadow | Debuffs, low aggro | 55 |
| **Celestial Guardian** | Light | Heals constructs, buffs Summoner — never attacks | 75 |

### Stats by Tier

**Ember Sprite** (damage)
| Tier | HP | Dmg/hit | Aggro |
|------|----|---------|-------|
| Crude | 25 | 8–14 | ×1.0 |
| Rough | 50 | 16–24 | ×1.0 |
| Refined | 90 | 28–40 | ×1.0 |
| Pristine | 140 | 45–65 | ×1.0 |
| Masterwork | 200 | 70–100 | ×1.0 |

**Stone Golem** (tank — highest HP + aggro)
| Tier | HP | Dmg/hit | Aggro |
|------|----|---------|-------|
| Crude | 80 | 4–8 | ×2.0 |
| Rough | 160 | 8–14 | ×2.0 |
| Refined | 280 | 14–22 | ×2.0 |
| Pristine | 440 | 22–35 | ×2.0 |
| Masterwork | 640 | 35–55 | ×2.0 |

**Frost Shard** (utility/slow, low aggro)
| Tier | HP | Dmg/hit | Slow | Aggro |
|------|----|---------|------|-------|
| Crude | 40 | 6–10 | 2s | ×0.8 |
| Rough | 80 | 12–18 | 3s | ×0.8 |
| Refined | 140 | 20–30 | 4s | ×0.8 |
| Pristine | 220 | 32–48 | 5s | ×0.8 |
| Masterwork | 320 | 50–75 | 6s | ×0.8 |

**Storm Wisp** (chain damage)
| Tier | HP | Dmg/hit | Chain targets | Aggro |
|------|----|---------|--------------|-------|
| Crude | 35 | 5–9 | +1 | ×1.2 |
| Rough | 70 | 10–16 | +2 | ×1.2 |
| Refined | 120 | 18–28 | +3 | ×1.2 |
| Pristine | 190 | 28–44 | +3 | ×1.2 |
| Masterwork | 275 | 45–70 | +4 | ×1.2 |

**Void Shade** (debuff, near-zero aggro)
| Tier | HP | Dmg/hit | Debuff | Aggro |
|------|----|---------|--------|-------|
| Crude | 30 | 4–8 | −5% accuracy | ×0.3 |
| Rough | 60 | 8–14 | −8% acc + weaken | ×0.3 |
| Refined | 105 | 14–22 | −12% acc + weaken | ×0.3 |
| Pristine | 165 | 22–35 | −18% acc + life drain | ×0.3 |
| Masterwork | 240 | 35–55 | −25% acc + drain + void DoT | ×0.3 |

**Celestial Guardian** (support — never attacks)
| Tier | HP | Heal/tick | Summoner buff | Aggro |
|------|----|---------|--------------|-------|
| Crude | 60 | 4 HP/3s (weakest construct) | +5% INT | ×0.5 |
| Rough | 120 | 8 HP/3s | +8% INT | ×0.5 |
| Refined | 210 | 14 HP/3s | +12% INT + mana regen | ×0.5 |
| Pristine | 330 | 22 HP/3s | +18% INT + mana regen | ×0.5 |
| Masterwork | 480 | 35 HP/3s | +25% INT + mana regen + revive 1 construct (once/combat) | ×0.5 |

---

## Active Engagement — Commands and Specials

### System 1 — Construct Special Abilities

Only trigger via specific player commands. Auto-attack without commands.

> All trigger commands use only the Summoner's 6 active nodes:
> **Ignis, Glacius, Tempest, Ventus, Terra, Umbra**

| Construct | Special | Trigger | Cooldown |
|-----------|---------|---------|---------|
| Ember Sprite | **Conflagration** — AoE fire burst, ×3 damage | Ignis + Terra | 12s |
| Stone Golem | **Titan Slam** — stagger all enemies, taunt spike | Terra + Tempest | 15s |
| Frost Shard | **Blizzard Field** — AoE slow field 8s | Glacius + Ventus | 18s |
| Storm Wisp | **Thunderstorm** — chain lightning ×3 all enemies | Tempest + Tempest (double-tap) | 20s |
| Void Shade | **Soul Siphon** — drains 15% enemy HP, heals weakest construct | Umbra + Glacius | 25s |
| Celestial Guardian | **Divine Barrier** — all constructs take 0 damage 4s | Terra + Ventus (hold) | 30s |

### System 2 — Construct Synergy Combos

Two or more constructs active → coordinating them unlocks synergy effects. Last 8s, must be
re-triggered.

| Constructs | Trigger | Synergy | Duration |
|-----------|---------|---------|---------|
| Stone Golem + Ember Sprite | Terra + Ignis | Siege Formation — Golem shields Sprite, +80% combined damage | 8s |
| Frost Shard + Storm Wisp | Glacius + Tempest | Arctic Storm — slowed targets take double chain lightning | 8s |
| Void Shade + Ember Sprite | Umbra + Ignis | Soulfire Assault — debuffed targets +60% fire damage | 8s |
| Stone Golem + Celestial Guardian | Terra + Ventus | Inviolable Wall — Golem aggro maxed, Guardian heals it | 8s |
| Storm Wisp + Void Shade | Tempest + Umbra | Storm of Shadows — debuff + chain all targets simultaneously | 8s |
| All 3 active constructs | Any 3-rune command | Trinity Formation — all specials fire, 10s duration | 10s |

### Output Gap

| Mode | Output |
|------|--------|
| Full idle | ~50% — auto-attacks only |
| Occasional commands | ~70% |
| Active command loop | ~100% — specials + synergies maintained |

---

## Runic Constellation — Summoner Commands

6 active nodes: **Ignis, Glacius, Tempest, Ventus, Terra, Umbra**
(No Vita, no Lux — no direct healing or party buffs; Celestial Guardian handles healing passively.)

| Rune | Command |
|------|---------|
| Ignis | Command Ember Sprite — focus fire |
| Glacius | Command Frost Shard — slow priority target |
| Tempest | Command Storm Wisp — chain attack |
| Ventus | Recall all constructs |
| Terra | Command Stone Golem — charge/advance |
| Umbra | Command Void Shade — apply debuffs |

### 2-Rune Commands (Combat Level 16+)

| Combination | Effect |
|------------|--------|
| Ignis + Tempest | Ember Sprite + Storm Wisp — fire + chain lightning burst |
| Terra + Ignis | Golem advances, Sprite follows — focused assault |
| Glacius + Umbra | Frost Shard slows + Void Shade debuffs simultaneously |
| Umbra + Tempest | Void Shade + Storm Wisp — debuff + chain all targets |
| Terra + Glacius | Frozen Vanguard — Golem taunts + Frost Shard slows everything targeting it |
| Ignis + Umbra | Soulfire Assault — debuffed targets take +60% fire damage |
| Tempest + Glacius | Arctic Storm — slowed enemies take double chain lightning |
| Terra + Tempest | Seismic Chain — Golem stagger + Wisp chains across staggered enemies |
| Ventus + Umbra | Shadow Recall — Void Shade recalled + redeployed, next attack +100% damage |

### 3-Rune Commands (Combat Level 42+)

| Combination | Effect |
|------------|--------|
| Terra + Ignis + Tempest | Trinity Assault — Golem, Sprite, Wisp burst single target |
| Umbra + Glacius + Tempest | Total Debilitation — accuracy down + slow + chain |
| Terra + Ignis + Umbra | Siege of Shadows — Golem tanks, Sprite damages, Shade debuffs |
| Ignis + Tempest + Glacius | Elemental Triad — fire + chain + slow (highest offensive output) |
| Ventus + Umbra + Glacius | Shadow Frost Recall — Shade recalled + Shard slows + reposition |
| Terra + Glacius + Umbra | Frozen Grave — Golem taunts + Shard freezes + Shade weakens |

---

## Summoning System

### Maximum Active Constructs

| Grimoire Combat Level | Max Constructs |
|----------------------|---------------|
| 1–24 | 1 |
| 25–49 | 2 |
| 50+ | 3 |
| DLC (Summoner's Tome) | 4 |

### Mana Costs (Summoner uses mana — not HP)

| Construct | Summon | Re-summon (50% HP) |
|-----------|--------|--------------------|
| Ember Sprite | 8 | 8 |
| Stone Golem | 12 | 12 |
| Frost Shard | 10 | 10 |
| Storm Wisp | 11 | 11 |
| Void Shade | 9 | 9 |
| Celestial Guardian | 14 | 14 |

Re-summon during combat: 2-second cast time, Summoner briefly exposed.

At max constructs: must recall one before summoning a new type.

---

## Aggro Generation

| Construct | Aggro multiplier |
|-----------|-----------------|
| Stone Golem | ×2.0 of damage |
| Storm Wisp | ×1.2 of damage |
| Ember Sprite | ×1.0 of damage |
| Frost Shard | ×0.8 of damage |
| Celestial Guardian | ×0.5 of healing |
| Void Shade | ×0.3 of damage |
| Summoner personal | ×0.2 of all actions |

Aggro decays 5%/sec per construct (same decay as `AggroManager` — see `aggro-spec.md`).

---

## Idle Behaviour

- Constructs auto-attack their targets
- Summoner auto-issues single-rune commands on 4-second rotation
- Priority: Ventus (recall if construct critical HP) → Terra (Golem charge) → Ignis (Sprite focus)
- No specials or synergies during idle — active play only
- Idle output ≈ 50% of active potential

---

## Technical Notes

**ScriptableObject — ConstructData:**
```
construct_id, construct_name, element (ElementType enum), role (ConstructRole enum),
hp_by_tier float[], damage_by_tier float[], aggro_multiplier float, mana_cost int,
unlock_grimoire_level int, idle_behavior (ConstructIdleBehavior enum),
special_effect (ConstructEffect enum), special_trigger_combo string
```

**Runic Constellation integration:**
- `GrimoireManager.currentSubclass == Summoner` → load `SummonerSpells` lookup table
- Commands route to `ConstructManager.GetConstructByElement(ElementType)`
- `Ventus` → `ConstructManager.RecallAll()`

**No crit enforcement:**
```csharp
if (currentGrimoire.path == GrimoirePath.Arcanist) { critChance = 0f; weakPointEnabled = false; }
```

---

*Path: `docs/summoner-spec.md`*
