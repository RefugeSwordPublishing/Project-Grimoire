---
type: design-spec
version: 0.2
updated: 2026-07-11
reconciled-to: implementation-status.md (2026-07-10)
---

# Project Grimoire — Vanguard Melee Combo System
### Version 0.2

> **Changes from v0.1:** All "Bulwark/Wardancing level" references replaced with "Grimoire combat
> level" — Bulwark and Wardancing do not exist as shared Talents; Warfare is the per-Grimoire
> combat progression for Vanguard subclasses. Idle interval table updated accordingly.
> Shadow's Edge explicitly documented as flat damage multiplier (not crit) per architecture rules.

---

> **2D Combat Note:** "Dodge" and "evasion" refer to a **combat state** — not physical
> repositioning. In the over-the-shoulder 2D view, dodging means the next enemy attack misses
> entirely. No physical movement away from the enemy occurs.

---

## Design Philosophy

Pattern knowledge + execution speed, never punishing casual play. Spamming Strike always works;
learning combos works dramatically better. Inspired by the LOTRO Warden gambit system and Capcom
combo systems — mastery feels rewarding without being required.

**Core principles:**
- Three inputs: Strike (S), Guard (G), Surge (U)
- Combos auto-fire 1.5s after last tap — no confirm button needed
- Unknown sequences fire a base attack — never a wasted tap
- Maximum 3 inputs in base game (DLC: 4–5)
- Idle fallback: last used combo at 70% potency
- No crit system for any Vanguard subclass — `critChance = 0f`, `weakPointEnabled = false`
- Shadow's Edge (Shadowblade) shows "Critical!" visually — backend is ×1.8 flat multiplier

---

## The Three Inputs

| Input | Button | Role | Visual |
|-------|--------|------|--------|
| **Strike** | S | Primary damage | Orange/red flash |
| **Guard** | G | Defensive / reactive | Blue/silver flash |
| **Surge** | U | Power / wind-up | Purple/gold flash |

**Mobile layout:**
```
        [ Surge ]
   [ Strike ] [ Guard ]
        [Player]
```
Minimum 80×80px touch target per button. Keyboard shortcuts on PC: Q=S, W=G, E=U.

---

## Execution Timer

- Taps build the sequence; 1.5s after last tap → fires automatically
- New tap before 1.5s → timer resets, input added
- 3rd tap → fires immediately (no wait)
- Unrecognised sequence → strongest applicable single input fires

**Input queue display:**
```
[ S ] [ G ] [ _ ]   ← waiting for 3rd input or 1.5s
```

---

## Combo Depth Unlocks

Gated by **Grimoire combat level** (per-Grimoire level in `player_grimoire_levels`,
managed by `CombatXPManager`). Each Vanguard Grimoire levels independently.

| Grimoire Combat Level | Depth Available |
|----------------------|----------------|
| 1 | 1-input only (base attacks) |
| 15 | 2-input combos |
| 35 | 3-input combos |
| DLC (Kensei) | 4-input combos |
| DLC (Kensei 80+) | 5-input combos |

---

## Base Attacks (No Combo / Unknown Sequence)

| Input | Effect |
|-------|--------|
| S alone | Basic melee swing — base damage |
| G alone | Brace stance — +5% defense 3s, no damage |
| U alone | Power stance — +10% next hit damage, no immediate damage |
| Unknown sequence | Strongest applicable single input fires |

---

## Combo Library — Warlord

Focus: heavy damage, crowd control, raid utility.

### 2-Input (Combat Level 15+)

| Sequence | Name | Effect |
|----------|------|--------|
| S→S | Cleaving Blow | +40% damage, armor pierce |
| S→G | Shield Bash | Moderate damage + stagger |
| S→U | Savage Strike | +80% damage |
| G→S | Counter Strike | +50% damage (reactive) |
| G→G | Iron Stance | +20% defense 8s |
| G→U | Bulwark Surge | +15% defense + taunt |
| U→S | Power Blow | +100% damage |
| U→G | Fortify | +30% defense + HP regen 5s |
| U→U | Warcry | AoE taunt — all nearby enemies 6s |

### 3-Input (Combat Level 35+)

| Sequence | Name | Effect |
|----------|------|--------|
| S→S→S | Whirlwind | AoE melee damage |
| S→S→G | Rend and Brace | +60% damage + +10% defense |
| S→S→U | Devastate | +150% damage |
| S→G→S | Riposte | Evasion state + counter +80% damage |
| S→G→U | Shield Surge | Moderate damage + +25% defense + taunt |
| S→U→S | Berserker Rush | +120% damage, −10% defense 5s |
| S→U→G | War Stance | +20% damage AND +20% defense 10s |
| G→S→S | Guardian's Fury | +70% damage (unlocks after 2+ recent Guard inputs) |
| G→S→U | Sundering Blow | +90% damage + armor break 8s |
| G→G→S | Stalwart Strike | +50% damage + +30% defense 6s |
| G→G→U | Fortress Surge | +40% defense + HP regen + taunt |
| G→U→S | Titan's Blow | +130% damage, highest taunt value |
| U→S→S | Chain Strike | +80% damage + second hit +40% |
| U→S→G | Overwhelming Force | +70% damage + stagger + defense |
| U→G→S | Ironclad Counter | +90% damage + +20% defense if enemy attacked recently |
| U→U→S | Legendary Strike | +200% damage — Warlord's ultimate |
| U→U→G | Indomitable | +50% defense + HP regen + taunt + stagger immunity 10s |

---

## Combo Library — Bulwark

Focus: maximum defense, aggro control, party protection.

### 2-Input (Combat Level 15+)

| Sequence | Name | Effect |
|----------|------|--------|
| S→S | Heavy Blow | +30% damage |
| S→G | Defensive Strike | +20% damage + +15% defense |
| S→U | Focused Hit | +60% damage |
| G→S | Protected Strike | +40% damage, −20% damage taken 3s |
| G→G | Shield Wall | +40% defense 10s, taunt |
| G→U | Aegis Surge | +35% defense + aggro generation |
| U→S | Empowered Strike | +70% damage |
| U→G | Unyielding | +30% defense + 5% HP regen |
| U→U | Rally Cry | +15% defense to ALL party 8s |

### 3-Input (Combat Level 35+)

| Sequence | Name | Effect |
|----------|------|--------|
| G→G→G | Immovable | +60% defense + stagger immunity + taunt |
| G→G→U | Bulwark's Oath | +50% defense + party shield (5% HP buffer) |
| G→U→G | Fortress | +40% defense + +25% all party defense 6s |
| U→G→G | Inviolable | +55% defense + HP regen + full aggro |
| U→U→G | Guardian's Resolve | +45% defense + revive immunity 15s |
| S→G→G | Protected Advance | +30% damage + +35% defense |
| G→S→G | Parry and Shield | Absorb next hit + counter + defense |
| U→G→S | Guardian Strike | +80% damage + high taunt |

---

## Combo Library — Shadowblade

Focus: burst damage, evasion states, debuffs, stealth openers. No crit — all multipliers are flat.

### Shadow's Edge — Passive (always active)
First attack from stealth deals **×1.8 damage** (flat multiplier). Displayed as "Critical!" in the
UI for player satisfaction. `critChance` remains 0.

### 2-Input (Combat Level 15+)

| Sequence | Name | Effect |
|----------|------|--------|
| S→S | Twin Fangs | +50% damage, two rapid hits |
| S→U | Hemorrhage | +40% damage + bleed 10s |
| S→G | Feint | Evasion state + +60% damage on counter |
| U→S | Shadow Strike | +90% damage (bonus if from stealth/Feint) |
| U→U | Void Step | Enter stealth 3s + next attack +100% |
| G→S | Blind Spot | +70% damage + enemy accuracy −20% 5s |
| G→U | Shadow Surge | Brief stealth + evasion +30% 4s |
| U→G | Phantom Step | Evasion +50% 3s, no damage |

### 3-Input (Combat Level 35+)

| Sequence | Name | Effect |
|----------|------|--------|
| S→S→S | Flurry | +70% damage × 3 rapid hits |
| S→S→U | Rupture | +80% damage + hemorrhage stack |
| U→U→S | Void Assassin | +250% damage from stealth — Shadowblade's signature |
| S→U→S | Relentless | +100% damage + bleed + second hit |
| G→S→S | Counter Flurry | +60% damage × 2 after evasion state |
| U→G→S | Shadow Dance | Evasion + stealth + massive counter hit |
| S→G→S | Blade Dance | +80% damage + evasion + +70% damage |
| U→S→U | Death Mark | +120% damage + weaken + void DoT |

---

## Combo Interactions

- Defense buffs: stack additively up to +60% cap
- Damage multipliers: highest active applies (no stacking)
- DoT effects (bleed, void, hemorrhage): stack independently, multiple can run simultaneously
- Taunt effects: most recent wins

### Combo Streak Bonus (unlocks at Grimoire combat level 38)
3 different unique combos in a row (no repeat):

| Streak | Bonus |
|--------|-------|
| 3 | +10% damage on next combo |
| 5 | +20% damage + 5% loot bonus |
| 10 | +30% damage + 10% loot bonus + visual indicator |

Streak breaks on: taking heavy damage (>30% max HP), repeating a sequence, or idle taking over.

---

## Idle Behaviour

Auto-queues last manually used combo on interval. Fires at **70% potency**.

| Grimoire Combat Level | Auto-combo interval |
|----------------------|-------------------|
| 1–20 | 4.0s |
| 21–40 | 3.5s |
| 41–60 | 3.0s |
| 61–80 | 2.5s |
| 81–100 | 2.0s |

Streak does not build during idle.

---

## Attunement — Active Play Bonus

| Condition | Bonus |
|-----------|-------|
| Complete a 3-input combo | +50% XP + Combo Streak contribution |
| All 3 inputs under 1.0s (full speed) | +25% damage on that combo |
| Counter combo (G→S variants) immediately after taking damage | +75% damage + 15% loot |
| Maintain Combo Streak 5+ | Persistent +10% drop rate while streak active |

---

## Technical Notes

**Input handling:**
```csharp
// On button tap:
currentSequence.Add(input);
ResetTimer(1.5f);

// On timer expire OR sequence.Count == 3:
string key = string.Concat(currentSequence.Select(b => b.ToString()[0]));
ComboData combo = subclassComboTable.TryGetValue(key, out var c) ? c : GetBaseAttack(currentSequence[0]);
Execute(combo);
currentSequence.Clear();
```

**ComboData ScriptableObject fields:**
`combo_id, sequence (string e.g. "SGU"), combo_name, subclass (VanguardSubclass enum),
damage_multiplier (float), defense_modifier (float), duration_seconds (float),
effect_type (ComboEffect enum), effect_value (float), taunt_value (int),
unlock_grimoire_level (int), idle_potency (float, default 0.70), animation_id (string)`

**Subclass filtering:**
Load only combos matching `GrimoireManager.currentSubclass`. Switching Grimoires reloads the
dictionary — no cross-subclass bleed.

**No-crit enforcement:**
```csharp
if (currentGrimoire.path == GrimoirePath.Vanguard) { critChance = 0f; weakPointEnabled = false; }
// Shadow's Edge is implemented as: damage *= 1.8f; — not as a crit
```

**Aggro (taunt combos):**
Taunt combos feed `AggroManager` — see `aggro-spec.md`. Warlord/Bulwark replenish aggro
constantly; Shadowblade has near-zero taunt values.

---

*Path: `docs/vanguard-combo-system.md`*
