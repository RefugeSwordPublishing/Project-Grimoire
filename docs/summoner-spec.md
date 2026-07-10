# ⚔️ Project Grimoire — Summoner Subclass Spec
### Version 0.1

---

## 📐 Design Philosophy

The Summoner is the most unique combat identity in Project Grimoire — a backline tactician whose constructs ARE their HP pool. Where every other class fights directly, the Summoner fights through their constructs. Managing constructs IS combat. Losing constructs IS taking damage. This creates a genuinely original mechanic that rewards careful positioning, smart deployment, and construct management as a survival skill.

**Core principles:**
- Constructs collectively form the Summoner's primary HP pool
- Summoner has a 25% personal HP buffer — survives briefly if all constructs fall
- Enemies target constructs, not the Summoner directly — as long as constructs live
- Each construct generates its own aggro based on damage dealt
- Recalling and redeploying constructs mid-combat is a survival decision
- Idle fallback: constructs auto-attack at base level (~50% of active potential) — Summoner auto-issues single-rune commands on a 4-second rotation
- Active commands unlock construct special abilities and synergy combos — the primary skill expression
- The idle vs active output gap is intentionally larger for Summoner than any other class
- In raids: constructs soak secondary enemy damage, giving Summoner a unique off-tank hybrid role

---

## 💚 HP Pool System

### Personal HP
```
Summoner Personal HP = Normal HP × 0.25
```
This is the safety buffer — only accessible when all constructs have fallen. Gives the Summoner roughly 3–5 hits to re-summon before defeat.

### Construct HP Contribution
Each active construct contributes to the Summoner's effective HP pool:

```
Effective HP = Personal HP + Sum of all active construct HP
```

| Construct Tier | HP Contribution |
|---------------|----------------|
| Crude construct | 40 HP |
| Rough construct | 80 HP |
| Refined construct | 140 HP |
| Pristine construct | 220 HP |
| Masterwork construct | 320 HP |

**Example at Refined tier with 3 constructs:**
```
Personal HP (VIT 30): 45
Construct HP (3 × 140): 420
Total Effective HP: 465
```

### Damage Routing
```
Incoming enemy damage → targets highest-aggro construct first
If no constructs alive → targets Summoner personal HP directly
```

When a construct takes damage its HP depletes first. At 0 HP the construct is destroyed and its HP contribution is removed from the effective pool. Enemy re-evaluates targets.

### Construct Revival
- Destroyed constructs can be re-summoned during combat — costs mana, 2-second cast time
- Re-summoned constructs start at 50% HP
- Maximum active simultaneously: 1 base, grows with Spellcasting level milestones

---

## 🔮 The Six Constructs

| Construct | Element | Role | Unlock |
|-----------|---------|------|--------|
| **Ember Sprite** | Fire | High damage, low HP — glass cannon | Spellcasting 1 |
| **Stone Golem** | Earth | High HP, low damage — frontline absorber | Spellcasting 1 |
| **Frost Shard** | Ice | Slows enemies, moderate damage | Spellcasting 20 |
| **Storm Wisp** | Lightning | Chain damage to multiple enemies | Spellcasting 35 |
| **Void Shade** | Shadow | Debuffs, life drain, stealth | Spellcasting 55 |
| **Celestial Guardian** | Light | Heals constructs, buffs Summoner | Spellcasting 75 |

### Construct Stats by Tier

**Ember Sprite** — damage focus
| Tier | HP | Damage/hit | Aggro Rate |
|------|----|-----------|-----------|
| Crude | 25 | 8–14 | Medium |
| Rough | 50 | 16–24 | Medium |
| Refined | 90 | 28–40 | Medium |
| Pristine | 140 | 45–65 | Medium |
| Masterwork | 200 | 70–100 | Medium |

**Stone Golem** — tank focus, highest HP and aggro
| Tier | HP | Damage/hit | Aggro Rate |
|------|----|-----------|-----------|
| Crude | 80 | 4–8 | High |
| Rough | 160 | 8–14 | High |
| Refined | 280 | 14–22 | High |
| Pristine | 440 | 22–35 | High |
| Masterwork | 640 | 35–55 | High |

**Frost Shard** — utility/slow focus, low aggro
| Tier | HP | Damage/hit | Slow Duration | Aggro Rate |
|------|----|-----------|--------------|-----------|
| Crude | 40 | 6–10 | 2s | Low |
| Rough | 80 | 12–18 | 3s | Low |
| Refined | 140 | 20–30 | 4s | Low |
| Pristine | 220 | 32–48 | 5s | Low |
| Masterwork | 320 | 50–75 | 6s | Low |

**Storm Wisp** — chain damage, moderate aggro
| Tier | HP | Damage/hit | Chain Targets | Aggro Rate |
|------|----|-----------|--------------|-----------|
| Crude | 35 | 5–9 | 1 additional | Medium |
| Rough | 70 | 10–16 | 2 additional | Medium |
| Refined | 120 | 18–28 | 3 additional | Medium |
| Pristine | 190 | 28–44 | 3 additional | Medium |
| Masterwork | 275 | 45–70 | 4 additional | Medium |

**Void Shade** — debuff focus, near-zero aggro
| Tier | HP | Damage/hit | Debuff | Aggro Rate |
|------|----|-----------|--------|-----------|
| Crude | 30 | 4–8 | -5% accuracy | Very Low |
| Rough | 60 | 8–14 | -8% accuracy + weaken | Very Low |
| Refined | 105 | 14–22 | -12% accuracy + weaken | Very Low |
| Pristine | 165 | 22–35 | -18% accuracy + life drain | Very Low |
| Masterwork | 240 | 35–55 | -25% accuracy + life drain + void DoT | Very Low |

**Celestial Guardian** — support only, never attacks
| Tier | HP | Heal/tick | Summoner Buff | Aggro Rate |
|------|----|---------|--------------|-----------|
| Crude | 60 | 4 HP/3s to weakest construct | +5% INT | Low |
| Rough | 120 | 8 HP/3s | +8% INT | Low |
| Refined | 210 | 14 HP/3s | +12% INT + mana regen | Low |
| Pristine | 330 | 22 HP/3s | +18% INT + mana regen | Low |
| Masterwork | 480 | 35 HP/3s | +25% INT + mana regen + revive one construct once per combat | Low |

---

## ⚡ Active Engagement — Why Commands Matter

Constructs auto-attack at base level during idle — the Summoner is never useless without input. However active command drawing unlocks dramatically better output through two systems:

### System 1 — Construct Special Abilities
Each construct has a powerful special ability that only triggers via specific player command combinations. Without commands constructs use basic auto-attacks only.

| Construct | Special Ability | Trigger Command | Cooldown |
|-----------|---------------|----------------|---------|
| Ember Sprite | **Conflagration** — AoE fire burst, 3x damage | Ignis + Lux | 12s |
| Stone Golem | **Titan Slam** — stagger all enemies, high taunt spike | Terra + Surge (U) | 15s |
| Frost Shard | **Blizzard Field** — AoE slow field for 8s | Glacius + Ventus | 18s |
| Storm Wisp | **Thunderstorm** — chain lightning hits all enemies 3x | Tempest + Tempest (double tap) | 20s |
| Void Shade | **Soul Siphon** — drains 15% enemy HP, heals weakest construct | Umbra + Vita | 25s |
| Celestial Guardian | **Divine Barrier** — all constructs take 0 damage for 4s | Lux + Lux (double tap) | 30s |

### System 2 — Construct Synergy Combos
When two or more specific constructs are active simultaneously, coordinating them via commands produces synergy effects far beyond their individual output. Synergies last 8 seconds then reset — must be re-triggered actively.

| Constructs | Trigger | Synergy Effect | Duration |
|-----------|---------|---------------|---------|
| Stone Golem + Ember Sprite | Terra + Ignis | Siege Formation — Golem shields Sprite, Sprite attacks from cover, +80% combined damage | 8s |
| Frost Shard + Storm Wisp | Glacius + Tempest | Arctic Storm — slowed enemies take double chain lightning damage | 8s |
| Void Shade + Ember Sprite | Umbra + Ignis | Soulfire Assault — debuffed enemies take +60% fire damage | 8s |
| Stone Golem + Celestial Guardian | Terra + Lux | Inviolable Wall — Golem aggro maxed, Guardian keeps it at full HP | 8s |
| Storm Wisp + Void Shade | Tempest + Umbra | Storm of Shadows — all enemies debuffed + chained simultaneously | 8s |
| All 3 active constructs | Any 3-rune command | Trinity Formation — all specials trigger simultaneously, 10s duration | 10s |

### Idle vs Active Output Gap
The gap between idle and active is intentionally larger for Summoner than any other class:

| Mode | Output |
|------|--------|
| Full idle (no commands) | ~50% of active potential — constructs auto-attack at base level only |
| Occasional commands | ~70% — specials trigger occasionally, no sustained synergies |
| Active command loop | ~100% — specials on cooldown, synergies maintained, coordinated assaults |

This makes the Summoner's active play loop feel essential rather than optional — and gives dedicated Summoner players a genuinely high skill ceiling in raids and dungeons.

### The Active Loop in Practice
A skilled active Summoner follows a rhythm:
1. Deploy 3 constructs
2. Trigger a synergy combo (8s of bonus damage)
3. While synergy is active, use construct specials (Conflagration, Titan Slam etc.)
4. Synergy expires — retrigger while managing any destroyed constructs
5. Re-summon if a construct falls — brief 2s vulnerability window
6. Repeat — each full cycle is roughly 15–20 seconds of active engagement

---

Same 8-node layout as other Arcanists — but combinations issue commands to constructs rather than direct spells.

### Summoner Rune Meanings (6 active nodes: Ignis, Glacius, Tempest, Ventus, Terra, Umbra)
| Rune | Command |
|------|---------|
| **Ignis** | Command Ember Sprite — focus fire |
| **Glacius** | Command Frost Shard — slow priority target |
| **Tempest** | Command Storm Wisp — chain attack |
| **Ventus** | Recall all constructs — defensive repositioning |
| **Terra** | Command Stone Golem — charge/advance |
| **Umbra** | Command Void Shade — apply debuffs |

> Note: Vita and Lux are NOT in the Summoner constellation — no direct healing or party buffs. The Celestial Guardian handles healing passively. Summoner is purely construct command and control.

### 2-Rune Commands
| Combination | Effect |
|------------|--------|
| Ignis + Tempest | Ember Sprite + Storm Wisp coordinate — fire + chain lightning burst |
| Terra + Ignis | Golem advances, Sprite follows — focused assault |
| Glacius + Umbra | Frost Shard slows + Void Shade debuffs simultaneously |
| Umbra + Tempest | Void Shade + Storm Wisp — debuff + chain all targets |
| Terra + Glacius | Frozen Vanguard — Golem taunts + Frost Shard slows everything targeting it |
| Ignis + Umbra | Soulfire Assault — Sprite + Void Shade coordinate, debuffed targets take +60% fire damage |
| Tempest + Glacius | Arctic Storm — slowed enemies take double chain lightning damage |
| Terra + Tempest | Seismic Chain — Golem stagger + Storm Wisp chains across all staggered enemies |
| Ventus + Umbra | Shadow Recall — Void Shade recalled and redeployed behind enemy, next attack +100% damage |

### 3-Rune Commands (Spellcasting 42+)
| Combination | Effect |
|------------|--------|
| Terra + Ignis + Tempest | Trinity Assault — Golem, Sprite, Wisp coordinate burst on single target |
| Umbra + Glacius + Tempest | Total Debilitation — accuracy down + slow + chain damage simultaneously |
| Terra + Ignis + Umbra | Siege of Shadows — Golem tanks, Sprite damages, Void Shade debuffs |
| Ignis + Tempest + Glacius | Elemental Triad — fire + chain + slow — highest offensive output |
| Ventus + Umbra + Glacius | Shadow Frost Recall — Void Shade recalled + Frost Shard slows everything + reposition |
| Terra + Glacius + Umbra | Frozen Grave — Golem taunts + Frost freezes + Void Shade weakens — total lockdown |

---

## 🏗️ Summoning System

### Maximum Active Constructs
| Spellcasting Level | Max Constructs |
|-------------------|---------------|
| 1–24 | 1 |
| 25–49 | 2 |
| 50+ | 3 |
| DLC (Summoner's Tome deep tree) | 4 |

### Mana Cost per Summon
| Construct | Mana Cost | Re-summon Cost |
|-----------|-----------|---------------|
| Ember Sprite | 8 | 8 (starts at 50% HP) |
| Stone Golem | 12 | 12 (starts at 50% HP) |
| Frost Shard | 10 | 10 |
| Storm Wisp | 11 | 11 |
| Void Shade | 9 | 9 |
| Celestial Guardian | 14 | 14 |

Re-summons during combat have a 2-second cast time — Summoner is briefly exposed.

---

## 📊 Aggro Generation

| Construct | Aggro Multiplier | Notes |
|-----------|----------------|-------|
| Stone Golem | ×2.0 of damage dealt | Primary aggro sink |
| Storm Wisp | ×1.2 of damage dealt | Chain attacks spread aggro across targets |
| Ember Sprite | ×1.0 of damage dealt | Standard aggro |
| Frost Shard | ×0.8 of damage dealt | Utility focus — low profile |
| Celestial Guardian | ×0.5 of healing done | Healers draw some attention |
| Void Shade | ×0.3 of damage dealt | Near-invisible to enemies |
| Summoner personal | ×0.2 of all actions | Rarely targeted directly |

---

## ⚔️ Raid Role — Off-Tank Hybrid

In raid content the Summoner fills a unique role no other class can:

- **Stone Golem** positioned against secondary/add enemies — soaks adds so Warlord/Bulwark focuses boss
- **Celestial Guardian** maintains construct HP throughout the raid — sustained healing
- **Void Shade** stacks debuffs on the raid boss — amplifies party-wide damage
- **Storm Wisp** handles AoE enemy groups — add clear
- **Ember Sprite** focuses the boss for sustained damage

A skilled Summoner managing 3 constructs simultaneously as both their HP pool AND a tactical toolkit has the highest skill ceiling of any base game class in raid content.

---

## 🔧 Technical Notes for Implementation

**HP system:**
```csharp
float effectiveHP = (baseHP * 0.25f) + 
    activeConstructs.Sum(c => c.currentHP);
```

**Damage routing:**
```csharp
Construct target = activeConstructs
    .OrderByDescending(c => c.aggroValue)
    .FirstOrDefault();

if (target != null)
    target.TakeDamage(incomingDamage);
else
    summoner.TakePersonalDamage(incomingDamage);
```

**Aggro per construct:**
```csharp
void OnDamageDealt(float damage) {
    aggroValue += damage * aggroMultiplier;
}
void Update() {
    // 5% decay per second
    aggroValue *= (1f - 0.05f * Time.deltaTime);
}
```

**Construct ScriptableObject:**
```
construct_id          string
construct_name        string
element               ElementType enum
role                  ConstructRole enum
hp_by_tier            float[]
damage_by_tier        float[]
aggro_multiplier      float
mana_cost             int
summon_unlock_level   int
idle_behavior         ConstructIdleBehavior enum
special_effect        ConstructEffect enum
```

**Runic Constellation integration:**
- `GrimoireManager.currentSubclass == Summoner` loads SummonerSpells lookup table
- Spell effects target constructs via `ConstructManager.GetConstructByElement()`
- Emergency Recall (Ventus) calls `ConstructManager.RecallAll()`

**Maximum construct enforcement:**
- `activeConstructs` list enforced at capacity before new summon allowed
- Player must recall a construct to swap types at max capacity
- Recall button always visible in combat UI alongside Runic Constellation

---

*Document version 0.1 — Summoner Subclass Spec*
*Next: Lifebinder healing spec · Phase 2 zone design · Phase 2 handoff*
