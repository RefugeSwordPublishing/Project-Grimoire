# ⚔️ Project Grimoire — Stat Scaling & Combat Formulas
### Version 0.1

---

## 📐 Design Philosophy

- **Simple with diminishing returns** — every stat point matters early, returns gradually reduce past soft cap
- **Hybrid gain** — milestone passives from Talent levels + equipment bonuses + Enchanting on top
- **Hybrid UI** — character sheet shows derived stats (Attack, Defense, Crit %, Evasion, Block) not raw formulas
- **No separate stat XP bar** — stats grow as a reward for Talent progression and gear upgrades
- **Idle compatible** — all formulas work the same during idle auto-combat, just without player-triggered bonuses

---

## 📊 Core Stats Reference

| Stat | Abbreviation | Primary Role | Secondary Role |
|------|-------------|-------------|---------------|
| **Strength** | STR | Melee damage, carry weight | Felling/Delving efficiency |
| **Dexterity** | DEX | Accuracy (all classes), evasion contribution | Gathering speed |
| **Vitality** | VIT | Max HP, stamina pool | Idle task persistence supplement |
| **Intelligence** | INT | Spell damage, Enchanting potency | Alchemy effectiveness |
| **Willpower** | WIL | Mana pool, healing boost, debuff resistance | Idle queue persistence |
| **Luck** | LCK | Rare drop rate, passive combat wild card | Gleaning bonus |
| **Charisma** | CHA | Exchange margins, NPC rewards | DLC faction/Bard mechanics |

---

## 📈 Stat Gain Sources

### 1. Talent Milestone Passives
Automatically awarded at specific Talent levels — already embedded in Talent spec sheets.
Small permanent increases. No player action required.

**Examples from spec sheets:**
- Foraging 51 → DEX +2
- Delving 28 → VIT +2
- Runesmithing 62 → STR +2
- Inscription 41 → WIL +2
- Gleaning 23 → LCK +2

Full list lives in the Talent Spec Sheets doc — not duplicated here.

### 2. Equipment Bonuses
The largest source of stat gains. Scales with Assembly quality tier.

| Quality Tier | Stat Bonus Range (per piece) |
|-------------|---------------------------|
| Crude | +1 to +2 per relevant stat |
| Rough | +3 to +5 per relevant stat |
| Refined | +6 to +9 per relevant stat |
| Pristine | +10 to +14 per relevant stat |
| Masterwork | +15 to +20 per relevant stat |
| Legendary | +25 to +35 per relevant stat *(DLC)* |

**Weapon stat focus by type:**
| Weapon | Primary Stat | Secondary Stat |
|--------|-------------|---------------|
| Bow | DEX | LCK |
| Sword | STR | VIT |
| Dagger | DEX | STR |
| Staff | INT | WIL |
| Wand | INT | LCK |
| Axe (tool/weapon) | STR | DEX |

**Armor stat focus by type:**
| Armor | Primary Stat | Secondary Stat |
|-------|-------------|---------------|
| Plate | VIT | STR |
| Leather | DEX | VIT |
| Magical Vestments | INT | WIL |

### 3. Enchanting Bonuses
Applied on top of base equipment stats. Stacks additively.

| Enchantment Tier | Bonus |
|-----------------|-------|
| Minor (Enchanting 1–30) | +2 to +4 to target stat |
| Major (Enchanting 31–70) | +5 to +9 to target stat |
| Greater (Enchanting 71–100) | +10 to +15 to target stat |

Max enchantment slots per item:
- Base: 1 slot
- Tailoring 51 unlock: 2 slots
- Enchanting 73 unlock: 3 slots
- Enchanting 91 unlock: 4 slots *(endgame)*

---

## 🎯 Derived Combat Stats

These are what players see on their character sheet. Calculated from raw stats + equipment + enchants.

### Attack (Melee)
```
Attack = (STR × 1.5) + Weapon Damage + STR Equipment Bonus
```
Weapon Damage is a flat range per weapon tier:
| Tier | Damage Range |
|------|-------------|
| Crude | 4–8 |
| Rough | 8–14 |
| Refined | 14–22 |
| Pristine | 22–32 |
| Masterwork | 32–45 |

### Attack (Ranged — Warden)
```
Ranged Attack = (DEX × 1.2) + Bow Damage + DEX Equipment Bonus
```
Active play modifier (Bowstring mechanic):
- Body hit: Ranged Attack × 1.0
- Weak point hit: Ranged Attack × 1.6 (crit)
- Draw power modifier: 0.70 at half draw → 1.0 at full draw
- Idle baseline: Ranged Attack × 0.80 (mid-draw simulation)

### Attack (Magic — Arcanist)
```
Magic Attack = (INT × 1.8) + Staff/Wand Damage + INT Equipment Bonus
```
Rune combination modifier:
- Single rune: Magic Attack × 1.0
- 2-rune combo: Magic Attack × 1.4
- 3-rune combo: Magic Attack × 1.8
- 4-rune combo: Magic Attack × 2.2
- Counter-element combo: Additional × 1.25
- Idle fallback (single rune): Magic Attack × 0.60

### Defense
```
Defense = (VIT × 0.8) + Armor Rating + VIT Equipment Bonus
```
Armor Rating flat value by tier:
| Tier | Plate | Leather | Vestments |
|------|-------|---------|-----------|
| Crude | 4 | 2 | 1 |
| Rough | 8 | 5 | 3 |
| Refined | 14 | 9 | 6 |
| Pristine | 22 | 15 | 10 |
| Masterwork | 32 | 22 | 15 |

Defense reduces incoming damage after hit/block resolution:
```
Damage Taken = Max(1, Raw Damage - (Defense × 0.4))
```
The ×0.4 factor means Defense never fully negates damage — always at least 1 damage gets through. Keeps combat meaningful at all tiers.

### Max HP
```
Max HP = 50 + (VIT × 4) + VIT Equipment Bonus × 3
```
| VIT | Base HP |
|-----|---------|
| 10 | 90 |
| 25 | 150 |
| 50 | 250 |
| 75 | 350 |
| 100 | 450 |

HP Regen (out of combat):
```
HP Regen/min = 2 + (VIT × 0.1)
```
In combat HP regen only from Cookery meals or Lifebinder skills.

### Mana Pool (Arcanist)
```
Max Mana = 20 + (WIL × 3) + WIL Equipment Bonus × 2
```
Mana cost per cast:
- Single rune: 5 mana
- 2-rune combo: 10 mana
- 3-rune combo: 18 mana
- 4-rune combo: 28 mana
Mana regen: 3/sec out of combat, 1/sec in combat

---

## 🎲 Combat Resolution Loop

Every attack — player or enemy — resolves in this order:

```
Step 1: Hit Roll
Step 2: Evasion Check (if hit)
Step 3: Block Check (if not evaded)
Step 4: Damage Roll (if not blocked or partially blocked)
Step 5: LCK Wild Card (passive, any step)
Step 6: Debuff Application (if applicable)
```

---

### Step 1 — Hit Roll

Attacker's accuracy vs defender's evasion rating:
```
Hit Chance = Attacker Accuracy - Defender Evasion Rating
Hit Chance clamped: minimum 5%, maximum 95%
```
Roll 1–100. If roll ≤ Hit Chance → Hit. Else → Miss (0 damage).

**Accuracy by class:**
```
Player Accuracy = 60 + (DEX × 0.8) + Weapon Accuracy Bonus
Enemy Accuracy = Base Enemy Accuracy (set per enemy type in zone tables)
```
DEX is the universal accuracy stat for all Grimoires — rewards investing in it regardless of class.

**Enemy accuracy examples:**
| Enemy | Base Accuracy |
|-------|--------------|
| Grimwood Brigand | 55 |
| Forest Wolf | 62 |
| Bandit Scout ★ | 70 |
| Zone 3 enemies | 72–78 |
| Zone 5 enemies | 82–90 |
| Raid bosses | 88–95 |

---

### Step 2 — Evasion Check

Only checked if Step 1 results in a Hit.
```
Player Evasion Rating = Armor Evasion Base + (DEX × 0.4)
```

**Armor evasion base by type and tier:**
| Tier | No Armor | Leather | Vestments | Plate |
|------|----------|---------|-----------|-------|
| Crude | 15 | 12 | 10 | 4 |
| Rough | 15 | 14 | 11 | 5 |
| Refined | 15 | 16 | 13 | 6 |
| Pristine | 15 | 18 | 14 | 7 |
| Masterwork | 15 | 21 | 16 | 8 |

No armor has a fixed 15% evasion base — DEX contributes on top.
Plate nearly eliminates evasion — compensated by high block (Step 3).

Roll 1–100. If roll ≤ Evasion Rating → Evaded (0 damage). Else → proceed to Step 3.

---

### Step 3 — Block Check

Only checked if Step 2 results in not evaded.
Evasion and Block are separate rolls — a hit that isn't evaded can still be blocked.

```
Block Chance = Armor Block Base (% by tier and type)
```

**Block % by armor type and tier:**
| Tier | No Armor | Leather | Vestments | Plate |
|------|----------|---------|-----------|-------|
| Crude | 0% | 3% | 2% | 12% |
| Rough | 0% | 5% | 3% | 16% |
| Refined | 0% | 8% | 5% | 21% |
| Pristine | 0% | 11% | 7% | 27% |
| Masterwork | 0% | 15% | 10% | 34% |

Roll 1–100. If roll ≤ Block Chance:
```
Blocked Damage = Raw Damage × (1 - Block %)
```
Block reduces damage by the tier's block percentage — not a full negate.
A Masterwork Plate block reduces incoming damage by 34%.

If roll > Block Chance → full damage proceeds to Step 4.

---

### Step 4 — Damage Roll

```
Raw Damage = Attacker Attack Stat + Random(Weapon Damage Range)
Final Damage = Max(1, Raw Damage - (Defender Defense × 0.4))
```

**Enemy damage ranges by zone tier:**
| Zone Tier | Enemy Damage Range |
|-----------|------------------|
| Tier 1 | 4–12 |
| Tier 2 | 10–22 |
| Tier 3 | 18–35 |
| Tier 4 | 28–50 |
| Tier 5 | 40–70 |
| Dungeon boss | Tier +50% |
| Raid boss | Tier ×2 |

**Debuff modifiers (applied after block):**
| Debuff | Damage Modifier |
|--------|----------------|
| Poison (Alchemy) | +X damage/tick for Y seconds |
| Frost slow | Enemy accuracy -15% while active |
| Void stack | +8% damage per stack (max 3) |
| Hemorrhage (Shadowblade) | +5 damage/tick for 30 sec |
| Burn (Fire coating) | +6 damage/tick for 15 sec |

---

### Step 5 — LCK Wild Card

Passive random check on every combat action — player only, not enemies.
LCK stat determines the chance of each wild card firing.

```
LCK Wild Card Chance = LCK × 0.1%
(LCK 10 = 1% chance, LCK 50 = 5% chance, LCK 100 = 10% chance)
```

Wild card effects (one random effect fires if check passes):
| Effect | Description |
|--------|-------------|
| **Fortune Strike** | Non-crit hit becomes a crit — full crit damage applies |
| **Debuff Shrug** | Incoming debuff fails to land despite successful hit |
| **Double Drop** | Next enemy kill drops double loot |
| **Mana Surge** | Next spell costs 0 mana (Arcanist) |
| **Quick Nock** | Bowstring draw speed +50% on next shot (Warden) |
| **Iron Skin** | Incoming damage reduced by 50% on next hit |

These are rare enough to feel like genuine luck moments rather than a primary combat strategy. Works identically during idle — the game rolls passively and applies the result.

---

### Step 6 — Debuff Application

If the attacker's move applies a debuff (poison, slow, void, etc.):
```
Debuff Land Chance = 85% base - Defender WIL × 0.3%
Minimum debuff land chance: 20%
```

WIL as debuff resistance:
| WIL | Debuff Resistance |
|-----|------------------|
| 10 | 3% reduction |
| 25 | 7.5% reduction |
| 50 | 15% reduction |
| 75 | 22.5% reduction |
| 100 | 30% reduction |

Maximum 30% debuff resistance at WIL 100 — debuffs always have a meaningful chance to land.

**WIL healing boost:**
```
Healing Received = Base Heal × (1 + WIL × 0.004)
(WIL 50 = +20% healing received, WIL 100 = +40% healing received)
```

---

## 📉 Diminishing Returns

Past the soft cap of 50 in any stat, gains reduce gradually:

```
Effective Stat Value:
  If raw stat ≤ 50: Effective = raw stat (1:1)
  If raw stat 51–75: Effective = 50 + (raw - 50) × 0.7
  If raw stat 76–100: Effective = 67.5 + (raw - 75) × 0.5
```

**Example — DEX accuracy:**
| Raw DEX | Effective DEX | Accuracy from DEX |
|---------|--------------|------------------|
| 25 | 25 | +20 accuracy |
| 50 | 50 | +40 accuracy |
| 75 | 67.5 | +54 accuracy |
| 100 | 80 | +64 accuracy |

This means:
- Early investment in a stat feels very impactful
- Spreading stats across multiple areas is rewarded vs hyper-focusing one stat
- Endgame players with max gear still feel strong but aren't infinitely scaling

---

## 🛡️ Character Sheet — Player Facing View

What players see on their character sheet (no raw formulas visible):

```
┌─────────────────────────────┐
│ DUSTIN — SHARPSHOT LV 31   │
├─────────────────────────────┤
│ ⚔  Attack        84        │
│ 🛡  Defense       42        │
│ ❤  Max HP        180       │
│ 💨  Evasion       18%       │
│ 🛡  Block         8%        │
│ 🎯  Accuracy      78        │
│ ⚡  Crit Chance   12%       │
│ 🍀  Luck          24        │
├─────────────────────────────┤
│ STR 22  DEX 31  VIT 28     │
│ INT 14  WIL 19  LCK 24     │
│ CHA 11                      │
├─────────────────────────────┤
│ Healing Boost    +8%        │
│ Debuff Resist    +6%        │
│ Idle Efficiency  74%        │
│ Drop Rate Bonus  +2.4%      │
└─────────────────────────────┘
```

Tapping any derived stat shows a brief plain-English tooltip:
- Attack: "Your damage output — higher means harder hits"
- Evasion: "Chance to dodge incoming attacks entirely"
- Block: "When hit, chance to reduce damage by your armor's block value"
- Luck: "Small chance each combat action triggers a fortune effect"

---

## ⚖️ Balance Checkpoints

Target combat feel per tier:

| Zone Tier | Expected Player Evasion | Expected Block | Expected Avg Damage Taken |
|-----------|------------------------|----------------|--------------------------|
| Tier 1 (Crude gear) | 18–22% | 3–8% | 6–9 per hit |
| Tier 2 (Rough gear) | 20–26% | 5–12% | 10–16 per hit |
| Tier 3 (Refined gear) | 22–30% | 8–18% | 16–24 per hit |
| Tier 4 (Pristine gear) | 24–34% | 11–24% | 20–32 per hit |
| Tier 5 (Masterwork gear) | 26–38% | 15–34% | 26–42 per hit |

Target: A fully geared player at tier-appropriate equipment should survive ~30 hits before needing to retreat or consume a meal. Under-geared players feel the pressure — Cookery and Alchemy consumables become meaningful.

---

## 📋 DLC Stat Notes

**Bard/Minstrel (DLC — path TBD)**
- Primary stats: WIL and CHA
- CHA combat role: Performance debuffs — high CHA reduces enemy accuracy and damage
- WIL combat role: Sustain auras, extended buff duration
- Specific formula to be designed at DLC spec phase
- Base game constraint: CHA and WIL formula slots reserved — don't hardcode them as purely non-combat

---

*Document version 0.1 — Stat Scaling & Combat Formulas*
*Next: Daily/weekly quest structure · Onboarding flow · While You Were Away screen · Main design doc cleanup*
