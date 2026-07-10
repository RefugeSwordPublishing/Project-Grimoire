# ⚔️ Project Grimoire — Vanguard Melee Combo System
### Version 0.1

---

> **2D Combat Note:** "Dodge" and "evasion" in this doc refer to a **combat state** — not physical repositioning. In the over-the-shoulder 2D view, dodging means the player character enters an evasion state where the next enemy attack misses entirely. There is no physical movement away from the enemy. This applies to all Feint, dodge, and evasion references throughout.

---

## 📐 Design Philosophy

The Vanguard combo system rewards pattern knowledge and execution speed while never punishing casual play. Spamming Strike produces results — just basic ones. Learning combinations produces dramatically better outcomes. The system is inspired by the LOTRO Warden gambit system and Capcom combo systems — mastery feels genuinely rewarding without being required.

**Core principles:**
- Three inputs: Strike, Guard, Surge — distinct, readable, always within thumb reach
- Combos fire automatically after a short 1.5-second input pause — no confirm button needed
- Unknown or incomplete sequences fire a base attack — never a wasted tap
- Combo depth starts at 2-input and grows with Bulwark/Wardancing level unlocks
- Maximum 3 inputs in base game — expandable via DLC
- Idle fallback: auto-queues the last used combo on a fixed interval at 70% potency
- Subclass determines the combo library — Warlord gets heavy damage combos, Shadowblade gets evasion/burst combos, Warlord/Bulwark gets aggro/defense combos

---

## 🎮 The Three Inputs

| Input | Button | Combat Role | Visual |
|-------|--------|------------|--------|
| **Strike** | S | Primary damage input — sword swing, axe blow | Orange/red flash on tap |
| **Guard** | G | Defensive input — raises shield, braces stance | Blue/silver flash on tap |
| **Surge** | U | Power input — channels force, wind-up | Purple/gold flash on tap |

**Button layout on mobile:**
Three large buttons arranged in a triangle at the bottom of the combat screen — within thumb reach, same principle as the Runic Constellation arch:

```
        [ Surge ]
   [ Strike ] [ Guard ]
        [Player]
```

Each button is large enough for reliable mobile tapping — minimum 80x80px touch target. Color-coded so players can identify inputs at a glance without reading labels.

---

## ⏱️ Execution Timer

- Player taps inputs to build a combo sequence
- A brief visual queue shows current inputs (e.g. S → G → _)
- **1.5 seconds after the last tap** → combo fires automatically
- If player taps a new input before 1.5 seconds: timer resets, input added to sequence
- Maximum 3 inputs — on the 3rd tap the combo fires immediately (no wait needed)
- Skilled players who know their combos can chain all 3 inputs quickly and fire instantly
- Casual players who tap once get a 1.5-second pause then a basic attack — natural and forgiving

**Input queue display:**
Small row of input icons above the buttons showing the current sequence:
```
[ S ] [ G ] [ _ ]   ← waiting for 3rd input or 1.5s timer
```
Filled icons = tapped, empty = available slot. Fires and clears after execution.

---

## 📊 Combo Depth — Unlock by Talent Level

| Bulwark / Wardancing Level | Combo Depth Available |
|--------------------------|----------------------|
| 1 | 1-input (base attacks only) |
| 15 | 2-input combos unlock |
| 35 | 3-input combos unlock |
| DLC (Kensei) | 4-input combos |
| DLC (Kensei 80+) | 5-input combos |

---

## 📋 Base Attack (No Combo / Unknown Sequence)

If the player taps any single input and waits, or taps an unrecognized sequence:
- **Strike alone:** Basic melee swing — base Attack damage
- **Guard alone:** Brace stance — +5% defense for 3 seconds, no damage
- **Surge alone:** Power stance — +10% next hit damage, no immediate damage
- Unrecognized sequence: strongest applicable single input fires

---

## ⚔️ Combo Library — Warlord Subclass

Warlord combos focus on **heavy damage, crowd control, and raid utility**. More offensive than Bulwark, less evasion-focused than Shadowblade.

### 2-Input Combos (Bulwark/Wardancing 15+)

| Sequence | Combo Name | Effect | Notes |
|----------|-----------|--------|-------|
| S → S | Cleaving Blow | +40% damage, armor pierce | Basic damage spam reward |
| S → G | Shield Bash | Moderate damage + stagger enemy | Interrupts enemy actions |
| S → U | Savage Strike | +80% damage, no defense buff | High risk, high reward |
| G → S | Counter Strike | +50% damage, only usable after Guard | Reads as reactive defense |
| G → G | Iron Stance | +20% defense for 8 seconds | Pure tank mode |
| G → U | Bulwark Surge | +15% defense + taunt (raid: forces enemy to target you) | Core raid aggro tool |
| U → S | Power Blow | +100% damage, single target | Warlord's hardest hit |
| U → G | Fortify | +30% defense + HP regen for 5 seconds | Survival combo |
| U → U | Warcry | AoE taunt — all nearby enemies target you for 6 seconds | Raid essential |

### 3-Input Combos (Bulwark/Wardancing 35+)

| Sequence | Combo Name | Effect | Notes |
|----------|-----------|--------|-------|
| S → S → S | Whirlwind | AoE melee damage — hits all enemies in range | Warlord's AoE signature |
| S → S → G | Rend and Brace | +60% damage + +10% defense | Balanced offense/defense |
| S → S → U | Devastate | +150% damage, single target | Highest single-hit damage in 3-input |
| S → G → S | Riposte | Dodge + counter — +80% damage after absorbing a hit | Timing-based reward |
| S → G → U | Shield Surge | Moderate damage + +25% defense + taunt | Versatile aggro combo |
| S → U → S | Berserker Rush | +120% damage, -10% defense for 5s | Warlord goes full offense |
| S → U → G | War Stance | +20% damage AND +20% defense for 10s | Warlord's premium buff |
| G → S → S | Guardian's Fury | +70% damage, unlocked only after 2+ Guard inputs used recently | Rewards patient play |
| G → S → U | Sundering Blow | +90% damage + armor break 8s | Weakens enemy defense |
| G → G → S | Stalwart Strike | +50% damage + +30% defense for 6s | Tank's reliable offensive |
| G → G → U | Fortress Surge | +40% defense + HP regen + taunt | Full raid tank mode |
| G → U → S | Titan's Blow | +130% damage, highest taunt value | Warlord raid signature |
| U → S → S | Chain Strike | +80% damage + second hit at +40% | Two-hit sequence |
| U → S → G | Overwhelming Force | +70% damage + stagger + defense | Crowd control |
| U → G → S | Ironclad Counter | +90% damage + +20% defense if enemy attacked recently | Reactive combo |
| U → U → S | Legendary Strike | +200% damage — Warlord's ultimate attack | Requires two Surge warmups |
| U → U → G | Indomitable | +50% defense + HP regen + taunt + stagger immunity 10s | Raid cooldown ability |

---

## 🛡️ Combo Library — Bulwark Subclass

Bulwark combos focus on **maximum defense, aggro control, and team protection**. Less damage than Warlord, far more survivability and raid utility.

### 2-Input Combos (Bulwark 15+)

| Sequence | Combo Name | Effect | Notes |
|----------|-----------|--------|-------|
| S → S | Heavy Blow | +30% damage | Base damage — less than Warlord |
| S → G | Defensive Strike | +20% damage + +15% defense | Always adds defense |
| S → U | Focused Hit | +60% damage, self-buff for next hit | Setup for 3-input |
| G → S | Protected Strike | +40% damage, -20% damage taken for 3s | Bulwark's reliable attack |
| G → G | Shield Wall | +40% defense for 10s, taunt | Core Bulwark ability |
| G → U | Aegis Surge | +35% defense + aggro generation | Always drawing attention |
| U → S | Empowered Strike | +70% damage | Bulwark's hardest hit |
| U → G | Unyielding | +30% defense + 5% HP regen | Signature survival |
| U → U | Rally Cry | +15% defense to ALL party members for 8s | Party-wide defense buff |

### 3-Input Combos (Bulwark 35+)

| Sequence | Combo Name | Effect | Notes |
|----------|-----------|--------|-------|
| G → G → G | Immovable | +60% defense + stagger immunity + taunt | Bulwark's ultimate stance |
| G → G → U | Bulwark's Oath | +50% defense + party shield 5% HP buffer | Protects party |
| G → U → G | Fortress | +40% defense + +25% all party defense 6s | Raid essential |
| U → G → G | Inviolable | +55% defense + HP regen + full aggro | Full tank mode |
| U → U → G | Guardian's Resolve | +45% defense + revive immunity 15s | Cannot be killed |
| S → G → G | Protected Advance | +30% damage + +35% defense | Move forward safely |
| G → S → G | Parry and Shield | Absorb next hit + counter + defense | Timing reactive |
| U → G → S | Guardian Strike | +80% damage — Bulwark's biggest hit, high taunt | Proving defense isn't passive |

---

## 🗡️ Combo Library — Shadowblade Subclass

Shadowblade combos focus on **burst damage, evasion, debuffs, and stealth openers**. Different rhythm entirely — fast, aggressive, punishing. Less Guard, more Strike and Surge.

### 2-Input Combos (Wardancing 15+)

| Sequence | Combo Name | Effect | Notes |
|----------|-----------|--------|-------|
| S → S | Twin Fangs | +50% damage, two rapid hits | Shadowblade's bread and butter |
| S → U | Hemorrhage | +40% damage + bleed 10s | Damage over time stacker |
| S → G | Feint | Dodge next attack + +60% damage on counter | Evasion-offense hybrid |
| U → S | Shadow Strike | +90% damage, requires stealth or Feint | Opener bonus |
| U → U | Void Step | Enter stealth for 3s + next attack +100% | Setup for big opener |
| G → S | Blind Spot | +70% damage + enemy accuracy -20% for 5s | Debuff combo |
| G → U | Shadow Surge | Enter brief stealth + evasion +30% for 4s | Defensive escape |
| U → G | Phantom Step | Evasion +50% for 3s, no damage | Pure survival |

### 3-Input Combos (Wardancing 35+)

| Sequence | Combo Name | Effect | Notes |
|----------|-----------|--------|-------|
| S → S → S | Flurry | +70% damage × 3 rapid hits | Speed signature |
| S → S → U | Rupture | +80% damage + hemorrhage stack | DoT maximizer |
| U → U → S | Void Assassin | +250% damage from stealth — Shadowblade's signature | Requires stealth entry first |
| S → U → S | Relentless | +100% damage + bleed + second hit | Sustained burst |
| G → S → S | Counter Flurry | +60% damage × 2 after dodge | Reactive burst |
| U → G → S | Shadow Dance | Evade + stealth + massive counter hit | Full evasion combo |
| S → G → S | Blade Dance | +80% damage + dodge + +70% damage | Two-hit evasion |
| U → S → U | Death Mark | +120% damage + weaken + void DoT | Maximum debuff stack |

---

## 🔄 Combo Interactions & System Rules

### Stacking Rules
- Defense buffs from combos stack additively up to a cap of +60% total defense
- Damage multipliers from combos do not stack — the highest active multiplier applies
- DoT effects (bleed, void, hemorrhage) stack independently — multiple can run simultaneously
- Taunt effects override each other — most recent taunt wins

### Combo Streak Bonus
Successfully executing 3 different unique combos in a row (no repeated sequences) grants a **Combo Streak**:
- Streak 3: +10% damage on next combo
- Streak 5: +20% damage + 5% loot chance bonus
- Streak 10: +30% damage + 10% loot chance bonus — visual streak indicator on screen
- Streak breaks on: taking heavy damage, missing a combo, or idol combat taking over

### Idle Behavior
When player is not actively inputting:
- Auto-queues the last manually used combo on a fixed interval
- Fires at **70% potency** — same philosophy as Runic Constellation idle
- Idle cast interval by Bulwark/Wardancing level:

| Level | Auto-Combo Interval |
|-------|-------------------|
| 1–20 | Every 4.0s |
| 21–40 | Every 3.5s |
| 41–60 | Every 3.0s |
| 61–80 | Every 2.5s |
| 81–100 | Every 2.0s |

---

## 🎯 Attunement — Active Play Bonus

| Condition | Attunement Bonus |
|-----------|----------------|
| Complete a 3-input combo | +50% XP + Combo Streak contribution |
| Land a combo at full speed (all 3 inputs under 1.0s) | +25% damage bonus on that combo |
| Use a counter combo (G → S variants) immediately after taking damage | +75% damage + +15% loot |
| Maintain a Combo Streak of 5+ | Persistent +10% drop rate while streak active |

---

## 🔧 Technical Notes for Implementation

**Input handling:**
- Three buttons: `ComboButton.Strike`, `ComboButton.Guard`, `ComboButton.Surge`
- On button tap: add to `List<ComboButton> currentSequence`, reset 1.5s timer
- On timer expire OR sequence length == 3: look up combo, execute, clear sequence
- Combo lookup: `Dictionary<string, ComboData>` where key is sequence string e.g. "SGU"
- If key not found: fire base attack for the first input in sequence
- Track `drawStartTime` on first input for speed bonus calculation

**Combo lookup key format:**
```csharp
string key = string.Concat(currentSequence.Select(b => b.ToString()[0]));
// "SSS", "SGU", "GGG" etc.
```

**ComboData ScriptableObject:**
```
combo_id           string
sequence           string (e.g. "SGU")
combo_name         string
subclass           VanguardSubclass enum
damage_multiplier  float
defense_modifier   float
duration_seconds   float
effect_type        ComboEffect enum (Damage/Defense/Taunt/Stealth/DoT/AoE/Regen)
effect_value       float
taunt_value        int
unlock_level       int (Bulwark or Wardancing level required)
idle_potency       float (default 0.70)
animation_id       string
```

**Subclass filtering:**
- Load only combos matching `GrimoireManager.currentSubclass` into the lookup dictionary
- Switching Grimoires reloads combo dictionary — no cross-subclass combo bleed

**PC/Steam input:**
- Keyboard shortcuts: Q = Strike, W = Guard, E = Surge
- Mouse clicks on buttons also work
- Input display shows keyboard hints on PC

**Raid taunt system:**
- Taunt combos set `player.aggroValue` — enemy AI targets highest aggro player
- Taunt value decays 10% per second when no taunt combo is used
- Warlord/Bulwark taunt combos replenish aggro — constant upkeep needed in raids
- Shadowblade has near-zero taunt values — stays off enemy radar

---

*Document version 0.1 — Vanguard Melee Combo System*
*Next: Summoner construct system · Lifebinder healing · Phase 2 zone design · Phase 2 handoff*
