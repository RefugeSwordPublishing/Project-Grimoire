---
type: design-spec
version: 0.2
updated: 2026-07-11
reconciled-to: implementation-status.md (2026-07-10)
---

# Project Grimoire — Vanguard Melee Combo System
### Version 0.3

> **Changes from v0.2:** Combo unlock levels staggered per-combo (drip-feed model)
> matching Arcanist spell pacing. Depth floors unchanged (2-input ≥15, 3-input ≥35).
> Only `unlock_grimoire_level` values changed — all combo definitions preserved.

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

### Starter Combo (Level 1)

| Sequence | Name | Unlock Level | Effect | Description |
|----------|------|-------------|--------|-------------|
| S→G | Shield Bash | **1** | Moderate damage + stagger | A quick strike into a shield slam — staggers the enemy briefly. The Warlord's first taste of mixing offense and defense. |

### 2-Input — Staggered Unlocks

| Sequence | Name | Unlock Level | Effect | Description |
|----------|------|-------------|--------|-------------|
| S→S | Cleaving Blow | **15** | +40% damage, armor pierce | Two rapid strikes in the same direction — the second tears through armor. Simple, reliable, effective. |
| G→G | Iron Stance | **15** | +20% defense 8s | Plant your feet and brace. Two guard inputs signal the Warlord to stop moving and absorb whatever comes. |
| G→U | Bulwark Surge | **19** | +15% defense + taunt | A defensive brace followed by a powerful surge — enemies can't help but focus on you. |
| G→S | Counter Strike | **21** | +50% damage (reactive) | Guard, then strike back. Works best immediately after blocking an enemy attack. |
| U→G | Fortify | **24** | +30% defense + HP regen 5s | Channel power inward — reinforce your stance and let your body recover while you hold the line. |
| S→U | Savage Strike | **27** | +80% damage | Strike to open, then surge through the gap. Raw aggression rewarded with raw damage. |
| U→U | Warcry | **31** | AoE taunt — all nearby enemies 6s | Two power surges erupting into a battlefield shout. Every enemy in range forgets your allies exist. |
| U→S | Power Blow | **34** | +100% damage | Wind up, then release everything into a single devastating strike. The hardest hit in the 2-input toolkit. |

*Design note: bread-and-butter (S→S, G→G) first; reactive counter mid-range;
high-damage and AoE taunt later; Power Blow arrives right before 3-input unlocks.*

### 3-Input — Staggered Unlocks

| Sequence | Name | Unlock Level | Effect |
|----------|------|-------------|--------|
| S→S→S | Whirlwind | **35** | AoE melee damage |
| S→S→G | Rend and Brace | **38** | +60% damage + +10% defense |
| G→G→S | Stalwart Strike | **41** | +50% damage + +30% defense 6s |
| S→G→U | Shield Surge | **44** | Moderate damage + +25% defense + taunt |
| G→G→U | Fortress Surge | **47** | +40% defense + HP regen + taunt |
| S→G→S | Riposte | **51** | Evasion state + counter +80% damage |
| U→S→S | Chain Strike | **54** | +80% damage + second hit +40% |
| S→S→U | Devastate | **57** | +150% damage |
| S→U→G | War Stance | **61** | +20% damage AND +20% defense 10s |
| G→S→S | Guardian's Fury | **64** | +70% damage (after 2+ recent Guard inputs) |
| U→S→G | Overwhelming Force | **67** | +70% damage + stagger + defense |
| S→U→S | Berserker Rush | **71** | +120% damage, −10% defense 5s |
| G→S→U | Sundering Blow | **75** | +90% damage + armor break 8s |
| U→G→S | Ironclad Counter | **79** | +90% damage + +20% defense if hit recently |
| G→U→S | Titan's Blow | **83** | +130% damage, highest taunt value |
| U→U→G | Indomitable | **88** | +50% defense + HP regen + taunt + stagger immunity 10s |
| U→U→S | Legendary Strike | **93** | +200% damage — Warlord's ultimate |

*Design note: AoE and defense extensions first; reactive/conditional combos mid-range;
high single-target damage escalates toward 90s; ultimate abilities at 88 and 93.*

---

## Combo Library — Bulwark

Focus: maximum defense, aggro control, party protection.

### Starter Combo (Level 1)

| Sequence | Name | Unlock Level | Effect | Description |
|----------|------|-------------|--------|-------------|
| G→S | Protected Strike | **1** | +40% damage, −20% damage taken 3s | Guard to absorb the blow, then strike back while your shield is still raised. The Bulwark's core rhythm from day one. |

### 2-Input — Staggered Unlocks

| Sequence | Name | Unlock Level | Effect | Description |
|----------|------|-------------|--------|-------------|
| S→S | Heavy Blow | **15** | +30% damage | Two measured strikes — not flashy, just effective. The Bulwark doesn't need to be clever to hurt. |
| G→G | Shield Wall | **15** | +40% defense 10s, taunt | Two guard inputs lock the Bulwark into a defensive wall. Everything wants to hit you, and nothing gets through. |
| S→G | Defensive Strike | **17** | +20% damage + +15% defense | Hit them, then cover up. The Bulwark always has the next hit in mind. |
| G→U | Aegis Surge | **19** | +35% defense + aggro generation | Brace, then surge outward — broadcasting your presence to every enemy on the field. |
| U→G | Unyielding | **25** | +30% defense + 5% HP regen | Channel power into your body rather than outward — you hold the line and heal as you do. |
| S→U | Focused Hit | **28** | +60% damage | Strike to find the gap, then surge through it. The Bulwark's hardest 2-input hit. |
| U→S | Empowered Strike | **31** | +70% damage | Build power, release it cleanly. Simple, devastating. |
| U→U | Rally Cry | **34** | +15% defense to ALL party 8s | Two surges that overflow into a shout — your allies feel it too. Everyone holds a little firmer. |

*Design note: single-target damage and core defense first; party-wide support (Rally Cry)
arrives last — a taste of the Bulwark's group identity before 3-input.*

### 3-Input — Staggered Unlocks

| Sequence | Name | Unlock Level | Effect | Description |
|----------|------|-------------|--------|-------------|
| S→G→G | Protected Advance | **35** | +30% damage + +35% defense | Strike to create space, guard twice — the Bulwark moves forward safely, daring enemies to stop them. |
| G→G→U | Bulwark's Oath | **39** | +50% defense + party shield (5% HP buffer) | Two guard stances held until a surge of protective energy radiates outward — your allies feel it as a brief buffer against the next blow. |
| G→S→G | Parry and Shield | **43** | Absorb next hit + counter + defense | Guard, punish the attack, guard again. The Bulwark turns the enemy's aggression into a net loss. |
| G→U→G | Fortress | **48** | +40% defense + +25% all party defense 6s | Guard, surge outward in a wave, guard again — the battlefield around you becomes hostile to the enemy. |
| U→G→S | Guardian Strike | **53** | +80% damage + high taunt | Build power, brace, then release it in a strike that demands attention from everything in range. |
| G→G→G | Immovable | **59** | +60% defense + stagger immunity + taunt | Three guard inputs. The Bulwark becomes an object. Cannot be staggered, cannot be ignored. |
| U→G→G | Inviolable | **66** | +55% defense + HP regen + full aggro | Surge all power into a defensive state — you regenerate and you hold absolute attention. |
| U→U→G | Guardian's Resolve | **79** | +45% defense + revive immunity 15s | Two surges of pure will channeled into protection — for the next 15 seconds, no single hit can kill you. |

*Design note: Bulwark has fewer 3-input combos — all are high-impact, spread wider.
Guardian's Resolve (revive immunity) is the capstone at 79.*

---

## Combo Library — Shadowblade

Focus: burst damage, evasion states, debuffs, stealth openers. No crit — all multipliers are flat.

### Shadow's Edge — Passive (always active)
First attack from stealth deals **×1.8 damage** (flat multiplier). Displayed as "Critical!" in the
UI for player satisfaction. `critChance` remains 0.

### Starter Combo (Level 1)

| Sequence | Name | Unlock Level | Effect | Description |
|----------|------|-------------|--------|-------------|
| S→S | Twin Fangs | **1** | +50% damage, two rapid hits | Two fast strikes in quick succession. The Shadowblade's opening lesson: speed is damage. |

### 2-Input — Staggered Unlocks

| Sequence | Name | Unlock Level | Effect | Description |
|----------|------|-------------|--------|-------------|
| U→G | Phantom Step | **15** | Evasion +50% 3s, no damage | Surge into a ghost-step — the next attack passes through you. No damage, pure survival. |
| S→G | Feint | **18** | Evasion state + +60% damage on counter | Fake a strike, let them commit, punish the overextension. Timing matters. |
| S→U | Hemorrhage | **21** | +40% damage + bleed 10s | A precise strike followed by a surge of force — opens a wound that keeps giving. |
| G→S | Blind Spot | **24** | +70% damage + enemy accuracy −20% 5s | Move into their blind spot, strike hard — they'll swing wide for the next few seconds. |
| G→U | Shadow Surge | **27** | Brief stealth + evasion +30% 4s | Guard to buy a breath, surge into shadow — brief but enough to reset the engagement. |
| U→S | Shadow Strike | **31** | +90% damage (bonus from stealth/Feint) | Build power in silence, release it in a single strike. Hits hardest from concealment. |
| U→U | Void Step | **34** | Enter stealth 3s + next attack +100% | Surge twice into the void — vanish completely, and emerge with your next blow doubled. |

*Design note: fast damage first; evasion and survival tools mid-range; stealth
toolkit (Shadow Strike, Void Step) arrives last — these define the Shadowblade.*

### 3-Input — Staggered Unlocks

| Sequence | Name | Unlock Level | Effect | Description |
|----------|------|-------------|--------|-------------|
| S→S→S | Flurry | **35** | +70% damage × 3 rapid hits | Three strikes so fast they blur — the Shadowblade's first expression of pure speed at 3-input depth. |
| G→S→S | Counter Flurry | **40** | +60% damage × 2 after evasion state | Guard to bait the attack, then two rapid retaliating strikes while they're still committed. |
| S→S→U | Rupture | **45** | +80% damage + hemorrhage stack | Two strikes open the wound, the surge drives it deep — adds a hemorrhage stack on top of any bleed running. |
| S→U→S | Relentless | **51** | +100% damage + bleed + second hit | Strike, surge through, strike again — relentless pressure that opens a bleed and keeps hitting. |
| S→G→S | Blade Dance | **57** | +80% damage + evasion + +70% damage | Strike, slip aside, strike again — a fluid exchange that deals damage while staying impossible to pin down. |
| U→G→S | Shadow Dance | **64** | Evasion + stealth + massive counter hit | Surge, step into shadow, emerge with a counter that ends the conversation. |
| U→S→U | Death Mark | **72** | +120% damage + weaken + void DoT | Build power, strike with precision, surge the void into the wound — a mark that drains and weakens simultaneously. |
| U→U→S | Void Assassin | **86** | +250% damage from stealth — Shadowblade signature | Two surges into absolute darkness, then a single strike that rewards mastery of stealth with mastery of damage. Only truly potent from concealment. |

*Design note: straight damage first; evasion combos mid-range; stealth-synergy
and DoT in 50–70 range; Void Assassin at 86 as the late-game stealth payoff.*

---

## Stamina Resource (Vanguard only)

Stamina is a burst resource that limits how many high-cost combos can be chained during
active play. It **never depletes during idle auto-combat** — idle always uses 1-input
Strike which costs 0 stamina.

```
Max Stamina = 30 + (VIT × 1.5)
Stamina Regen = 2/sec passive (always active in combat)
             + 4/sec bonus when no combo input for 3+ seconds
             + 4/sec additional out of combat entirely
```

### Stamina Costs per Combo Depth

| Depth | Cost | Notes |
|-------|------|-------|
| 1-input (Strike/Guard/Surge alone) | 0 | Always free — idle fallback |
| 2-input | 8 | Standard combo |
| 3-input | 18 | Full combo |

At 0 stamina: auto-fires single Strike — same behaviour as idle. Never hard-locked.

At VIT 30 (mid game): ~75 max stamina → 4 three-input combos before needing to let
singles regen. The natural burst-regen rhythm pairs well with the 1.5s auto-fire timer.

**Stamina consumables** (see `docs/consumables-spec.md`):
- Endurance Draught (Alchemy) — instant restore, hotbar slot 2, Vanguard only
- Warrior's Ration (Cookery) — +Max Stamina buff 20 min, inventory only
- Hearty Stew (Cookery) — +Stamina regen/sec buff 20 min, inventory only

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
unlock_grimoire_level (int), idle_potency (float, default 0.70), animation_id (string),
description (string — displayed in Grimoire Book UI as flavour/handbook text)`

**Subclass filtering:**
Load only combos matching `GrimoireManager.currentSubclass`. Switching Grimoires reloads the
dictionary — no cross-subclass bleed.

**Stamina check before combo execution:**
```csharp
bool TryExecuteCombo(ComboData combo) {
    int cost = combo.inputCount == 1 ? 0
             : combo.inputCount == 2 ? 8 : 18;
    if (PlayerStats.currentStamina < cost) {
        // Fall back to single Strike
        ExecuteBaseAttack(currentSequence[0]);
        return false;
    }
    PlayerStats.currentStamina -= cost;
    Execute(combo);
    return true;
}
```

**Stamina — idle auto-combat always uses Strike (cost 0):**
```csharp
void AutoCombo() {
    // Idle path — always single Strike, never costs stamina
    ExecuteBaseAttack(ComboInput.Strike);
}
```
```csharp
if (currentGrimoire.path == GrimoirePath.Vanguard) { critChance = 0f; weakPointEnabled = false; }
// Shadow's Edge is implemented as: damage *= 1.8f; — not as a crit
```

**Aggro (taunt combos):**
Taunt combos feed `AggroManager` — see `aggro-spec.md`. Warlord/Bulwark replenish aggro
constantly; Shadowblade has near-zero taunt values.

---

*Document version 0.3 — staggered per-combo unlock levels*
*Path: `docs/vanguard-combo-system.md`*
