# Project Grimoire, Warfare: Vanguard Grimoire Combat Progression
### Version 0.1

---

## Design Philosophy

Warfare is the combat progression system housed on each Vanguard Grimoire, not a shared Talent. Each Vanguard Grimoire (Warlord, Shadowblade, Kensei DLC) levels independently from 1-100. Purchasing a new Grimoire starts its Warfare progression at level 1 regardless of other Grimoire levels.

**Core principles:**
- Combo depth unlocks are per-Grimoire, a level 55 Warlord does NOT give 3-input combos to a fresh Shadowblade
- Permanent stat bonuses from Warfare milestones apply to the character permanently, persist regardless of equipped Grimoire
- Stat bonuses accumulate across ALL paths, leveling Warlord gives STR even to an Arcanist character
- Combat XP from Slaying feeds the currently equipped Grimoire's Warfare level
- Idle auto-combat behavior improves with Warfare level
- Warfare progression displayed on the Combat Tab of the Character Panel

---

## Shared Warfare Unlock Table (All Vanguard Grimoires)

| Level | Unlock | Type | Notes |
|-------|--------|------|-------|
| 1 | Basic Strike | Combat | Single Strike input, base melee damage |
| 8 | Guard input unlocked | Combat | Defensive combos now possible |
| 15 | **2-input combos unlock** | Combat | Core combo system activates, all 2-input sequences available |
| 23 | STR passive +1 | **Permanent stat** | Added to character permanently |
| 31 | Surge input unlocked | Combat | Power combos now possible, all 3 inputs active |
| 38 | Combo Streak system activates | Combat | 3+ unique combos in a row grants streak bonus |
| 47 | VIT passive +1 | **Permanent stat** | Added to character permanently |
| 55 | **3-input combos unlock** | Combat | Full base game combo depth |
| 63 | STR passive +2 | **Permanent stat** | Added to character permanently |
| 72 | Idle auto-combo upgrade | Combat | Auto-uses last used 2-input combo at 70% potency (was single Strike) |
| 81 | VIT passive +2 | **Permanent stat** | Added to character permanently |
| 88 | Passive aggro rate +50% | Combat | Endgame tank identity solidifies, raids benefit significantly |
| 100 | Idle never retreats from Tier 3 zones or lower | **Mastery** | Reliable high-zone idle farming |

> **Permanent stat bonuses stack across all owned Grimoires.** A player with Warlord and Shadowblade both at level 23 gains +2 STR total. All three Vanguard Grimoires at 23 = +3 STR. These bonuses persist even when an Arcanist or Warden Grimoire is equipped.

---

## Warlord-Specific Technique Unlocks

| Level | Technique | Effect |
|-------|-----------|--------|
| 19 | **Shield Bash** | Interrupt enemy attack, stagger for 2s, moderate damage. Unlocks G→S combo variant with guaranteed stagger |
| 42 | **Warcry** | AoE taunt, all nearby enemies target Warlord for 6s. Unlocks U→U combo. Raid essential |
| 67 | **Titan's Blow** | Maximum single-target damage + maximum taunt spike. Unlocks G→U→S at full power |
| 85 | **Indomitable** | Full tank cooldown, +50% defense + HP regen + stagger immunity for 10s. Unlocks U→U→G at full power. Raid phase survival cooldown |

---

## Shadowblade-Specific Technique Unlocks

| Level | Technique | Effect |
|-------|-----------|--------|
| 19 | **Feint** | Dodge next attack + counter window, +60% damage on immediate counter. Unlocks S→G combo with guaranteed dodge |
| 42 | **Void Step** | Enter stealth from combat, 3s stealth window. Unlocks U→U combo. Setup for Void Assassin |
| 67 | **Flurry** | Triple rapid hit, S→S→S at +70% each hit. Shadowblade's sustained burst signature |
| 85 | **Void Assassin** | Stealth opener, +250% damage from stealth. Requires Void Step entry. Unlocks U→U→S at full power |

---

## Permanent Stat Bonus Summary, All Paths

Stat milestones from Warfare progression are permanent character bonuses. They accumulate across all owned Grimoires regardless of which is currently equipped.

### Vanguard Path Stat Milestones
| Grimoire | Level 23 | Level 47 | Level 63 | Level 81 |
|---------|---------|---------|---------|---------|
| Warlord | STR +1 | VIT +1 | STR +2 | VIT +2 |
| Shadowblade | STR +1 | VIT +1 | STR +2 | VIT +2 |
| Kensei (DLC) | STR +1 | VIT +1 | STR +2 | VIT +2 |

**Max Vanguard stat gains (all 3 Grimoires maxed past 81):**
- STR: +9 total (3 Grimoires × STR +1 at 23 + STR +2 at 63)
- VIT: +9 total (3 Grimoires × VIT +1 at 47 + VIT +2 at 81)

### Warden Path Stat Milestones
| Grimoire | Level 23 | Level 38 | Level 63 | Level 81 |
|---------|---------|---------|---------|---------|
| Sharpshot | DEX +1 | LCK +1 | DEX +2 | LCK +2 |
| Lone Wanderer | DEX +1 | LCK +1 | DEX +2 | LCK +2 |
| Beastbond (DLC) | DEX +1 | LCK +1 | DEX +2 | LCK +2 |

**Max Warden stat gains:** DEX +9, LCK +9

### Arcanist Path Stat Milestones
| Grimoire | Level 23 | Level 38 | Level 63 | Level 81 |
|---------|---------|---------|---------|---------|
| Runeweaver | INT +1 | WIL +1 | INT +2 | WIL +2 |
| Summoner | INT +1 | WIL +1 | INT +2 | WIL +2 |
| Lifebinder | INT +1 | WIL +1 | INT +2 | WIL +2 |
| Warlock (DLC) | INT +1 | WIL +1 | INT +2 | WIL +2 |
| Bloodweaver (DLC) | INT +1 | WIL +1 | INT +2 | WIL +2 |

**Max Arcanist stat gains:** INT +15, WIL +15 (5 Grimoires including DLC)

### Cross-Path Accumulation
A player who levels Grimoires across all three paths accumulates stats in every attribute:

**Example, Completionist player with all base game Grimoires past level 23:**
```
From Warden Grimoires (×2):   DEX +2, LCK +2
From Arcanist Grimoires (×3): INT +3, WIL +3
From Vanguard Grimoires (×2): STR +2, VIT +2
```

This rewards breadth of play without making cross-path grinding mandatory, it's always optional but always meaningful.

> LCK and CHA are not tied to Grimoire stat milestones, they come from Talent milestones (Gleaning for LCK, Inscription diplomatic items for CHA). This keeps those stats tied to the crafting/gathering economy rather than combat investment.

---

## Warfare Attunement Data

Warfare attunement uses two independent checks at combo resolution, same philosophy as Spellcasting attunement.

### Attunement Fields
```
hasAttunement              true
isPlayerDriven             true (combo-based, not cycle-based)
cycleLength                N/A

// Speed Attunement, all 3 inputs entered under 1.0s
speedAttunement_enabled    true
speedAttunement_threshold  1.0s (all inputs completed)
speedAttunement_xpBonus    1.5 (+50% XP)
speedAttunement_damageBonus 0.25 (+25% damage on that combo)
speedAttunement_cueLabel   "Fast combo!"

// Streak Attunement, active from Warfare level 38
streakAttunement_enabled   true (unlocks at level 38)
streakAttunement_threshold 3 (3 unique combos in a row)
streakAttunement_lootBonus 0.10 (+10% drop chance while streak active)
streakAttunement_cueLabel  "Combo streak!"
```

### Speed Tiers
| Speed | All inputs completed in | Damage Modifier |
|-------|------------------------|----------------|
| Lightning | Under 1.0s | +25% damage |
| Standard | 1.0s - 2.5s | Base damage |
| Slow | Over 2.5s (or waited for auto-fire) | Base damage |

No damage penalty for slow inputs, idle auto-fire always deals standard damage. Speed bonus rewards active fast play.

### Combo Streak Bonus
Active after Warfare level 38. Requires 3 different unique combo sequences in a row without repeating.

| Streak | Bonus |
|--------|-------|
| 3 unique combos | +10% damage on next combo |
| 5 unique combos | +20% damage + 5% loot bonus |
| 10 unique combos | +30% damage + 10% loot bonus + visual streak indicator |

Streak breaks on: taking heavy damage, repeating a combo sequence, idle auto-combat taking over.

### Idle Behavior
| Level | Auto-Combat Behavior |
|-------|---------------------|
| 1-71 | Auto-fires single Strike at base damage |
| 72-100 | Auto-fires last used 2-input combo at 70% potency |
| 100 (mastery) | Never retreats from Tier 3 zones or lower |

Streak does not build during idle, active play only.

---

## Technical Notes for Implementation

**Grimoire ScriptableObject, Warfare fields:**
```csharp
public class GrimoireData : ScriptableObject {
    // Combat progression
    public GrimoirePath path;          // Warden/Arcanist/Vanguard
    public int combatLevel;
    public int combatXP;

    // Warfare specific
    public bool twoInputUnlocked;      // Level 15
    public bool surgeInputUnlocked;    // Level 31
    public bool threeInputUnlocked;    // Level 55
    public bool comboStreakActive;     // Level 38
    public bool idleComboUpgraded;     // Level 72
    public List<string> unlockedTechniques;

    // Permanent stat bonuses (accumulated on milestone reach)
    // Written to player_stat_bonuses table when milestone hit
    // NOT stored on Grimoire, stored on character permanently
}
```

**Permanent stat bonus application:**
```csharp
void OnWarfareLevelReached(int level, GrimoireData grimoire) {
    // Check for stat milestones
    if (level == 23) GrantPermanentStat(StatType.STR, 1, grimoire.id);
    if (level == 47) GrantPermanentStat(StatType.VIT, 1, grimoire.id);
    if (level == 63) GrantPermanentStat(StatType.STR, 2, grimoire.id);
    if (level == 81) GrantPermanentStat(StatType.VIT, 2, grimoire.id);
}

void GrantPermanentStat(StatType stat, int amount, string grimoireId) {
    // Check not already granted for this grimoire + milestone
    if (!AlreadyGranted(grimoireId, stat, amount)) {
        playerStats.AddPermanentBonus(stat, amount, grimoireId);
        SaveToSupabase();
    }
}
```

**Supabase schema, permanent stat bonuses:**
```sql
CREATE TABLE player_stat_bonuses (
    player_id    UUID REFERENCES players(id),
    grimoire_id  TEXT,
    stat_type    TEXT,
    amount       INTEGER,
    granted_at   TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (player_id, grimoire_id, stat_type)
);
```

**Combo speed check:**
```csharp
void OnComboResolved(List<ComboInput> inputs, float totalInputTime) {
    bool isLightning = totalInputTime < 1.0f && inputs.Count > 1;

    if (isLightning) {
        ApplyXPBonus(1.5f);
        ApplyDamageBonus(0.25f);
        ShowFeedback("Fast combo!");
    }

    // Streak check
    if (comboStreakActive) UpdateStreakCounter(inputs);
}
```

**No crit system for Vanguard**, same as Arcanist. Skill expression is through combo knowledge, execution speed, and streak maintenance. No random crit procs.

```csharp
if (currentGrimoire.path == GrimoirePath.Vanguard) {
    critChance = 0f;
    weakPointEnabled = false;
}
// Marksmanship weak point system unaffected, Warden only
```

---

*Document version 0.1, Warfare: Vanguard Grimoire Combat Progression*
*Next: Shadowblade / Black Ledger depth · Runeweaver deep tree · Phase 2 handoff*
