# ⚔️ Project Grimoire — Grimoire Combat XP Curve
### Version 0.1

---

## 📐 Design Philosophy

The Grimoire combat progression curve is **accelerating** — early levels unlock quickly to get players into interesting mechanics fast, while later levels require sustained investment. The curve is designed around a casual player (1–2 hours/day of combined active and idle play).

**Target milestones:**
- Level 15 (2-input combos): ~1 week first Grimoire
- Level 20 (stat milestone + zone 2 contribution): ~1–2 weeks
- Level 35 (3-input combos): ~1 month
- Level 55 (full combo depth): ~2–3 months
- Level 100 (mastery): ~4–6 months per Grimoire
- Full mastery (all 7 base Grimoires + all Talents to 100): ~3 years

**Second and subsequent Grimoires** level ~20–30% faster because:
- Player is in higher-tier zones earning more XP per kill
- Player knows the combat system — more active attunement hits
- No relearning curve — pure XP investment

---

## 📊 XP Required Per Level

Accelerating curve — gap between levels grows steadily throughout.

| Level Range | XP per level | Cumulative XP to reach |
|------------|-------------|----------------------|
| 1–5 | 100 | 500 |
| 6–10 | 200 | 1,500 |
| 11–15 | 350 | 3,250 |
| 16–20 | 550 | 6,000 |
| 21–25 | 800 | 10,000 |
| 26–30 | 1,100 | 15,500 |
| 31–35 | 1,500 | 23,000 |
| 36–40 | 2,000 | 33,000 |
| 41–45 | 2,700 | 46,500 |
| 46–50 | 3,500 | 64,000 |
| 51–55 | 4,500 | 86,500 |
| 56–60 | 5,800 | 115,500 |
| 61–65 | 7,200 | 151,500 |
| 66–70 | 8,800 | 195,500 |
| 71–75 | 10,500 | 248,000 |
| 76–80 | 12,500 | 310,500 |
| 81–85 | 15,000 | 385,500 |
| 86–90 | 18,000 | 475,500 |
| 91–95 | 21,500 | 583,000 |
| 96–100 | 25,000 | 708,000 |

**Total XP to level 100:** ~708,000

---

## ⚔️ XP Sources — Per Enemy Kill

XP awarded to the currently equipped Grimoire's combat progression. Idle and active both award XP — active play awards attunement bonus on top.

### Zone Enemy XP by Tier

| Zone Tier | Standard enemy | Elite enemy | Zone boss |
|-----------|--------------|------------|----------|
| Tier 1 | 8 XP | 40 XP | 160 XP |
| Tier 2 | 18 XP | 90 XP | 360 XP |
| Tier 3 | 35 XP | 175 XP | 700 XP |
| Tier 4 | 60 XP | 300 XP | 1,200 XP |
| Tier 5 | 100 XP | 500 XP | 2,000 XP |

**Active attunement bonus:**
- Successful attunement on kill: ×1.5 XP (same as Talent attunement)
- Applies to whichever attunement fires — speed, streak, counter, weak point

### Dungeon Completion XP

| Dungeon Tier | Base XP | First clear bonus |
|-------------|---------|-----------------|
| Tier 1 | 500 XP | +500 XP (one-time) |
| Tier 2 | 1,500 XP | +1,000 XP (one-time) |
| Tier 3 | 4,000 XP | +2,000 XP (one-time) |
| Tier 4 | 10,000 XP | +4,000 XP (one-time) |
| Tier 5 | 25,000 XP | +8,000 XP (one-time) |

First clear bonus applies once per dungeon per Grimoire — switching Grimoires and clearing the same dungeon again does NOT grant the first clear bonus again.

### Slaying Task Completion XP

| Task Tier | Bonus XP on completion |
|-----------|----------------------|
| Tier 1 tasks | 1,000 XP |
| Tier 2 tasks | 4,000 XP |
| Tier 3 tasks | 12,000 XP |
| Tier 4 tasks | 30,000 XP |
| Tier 5 tasks | 75,000 XP |

### Raid Completion XP

| Raid | XP on completion |
|------|----------------|
| Standard raid (any tier) | 50,000 XP |
| Raid boss kill (personal contribution) | +10,000 XP |

Raid XP is the single largest source per event — reinforces raids as meaningful progression milestones rather than just loot events.

---

## 📈 Progression Simulation — First Grimoire (Casual Player)

Assumptions:
- 1–2 hours/day combined active + idle
- Tier 1 zone combat for first 3 weeks, Tier 2 after
- ~60 standard kills/hour idle, ~120 kills/hour active
- 1 dungeon per week
- 2 Slaying tasks per day

### Week-by-Week Estimate

| Week | Activity | XP earned | Est. level reached |
|------|---------|----------|-------------------|
| 1 | Tier 1 zones, learning combat | ~3,500 | **~Level 16** |
| 2 | Tier 1 zones, 1 dungeon clear | ~5,200 | **~Level 22** |
| 3 | Tier 1–2 zones, Slaying tasks | ~7,000 | **~Level 29** |
| 4 | Tier 2 zones, 1 dungeon clear | ~9,500 | **~Level 35** |
| 6 | Tier 2 zones consistently | ~18,000 | **~Level 47** |
| 8 | Tier 2–3 zones, raids unlocked | ~30,000 | **~Level 56** |
| 12 | Tier 3 zones, regular raids | ~55,000 | **~Level 68** |
| 16 | Tier 3–4 zones | ~80,000 | **~Level 78** |
| 20 | Tier 4 zones, endgame grind | ~110,000 | **~Level 86** |
| 24 | Tier 5 access, all content | ~150,000 | **~Level 93** |
| 26 | Full endgame | ~180,000 | **~Level 100** |

**~6 months to level 100** on the first Grimoire for a casual player. Well within the 4–6 month target.

---

## 📈 Subsequent Grimoires — Faster Progression

Players leveling their second Grimoire are already in higher-tier zones earning more XP per kill:

| Grimoire | Starting zone tier | Est. time to 100 |
|---------|-------------------|-----------------|
| 1st Grimoire | Tier 1 | ~5–6 months |
| 2nd Grimoire | Tier 2–3 (already unlocked) | ~3–4 months |
| 3rd Grimoire | Tier 3–4 | ~2.5–3 months |
| 4th+ Grimoire | Tier 4–5 | ~2–2.5 months |

This means the 3-year full mastery target is achievable:
```
7 Grimoires × average ~3.5 months = ~24 months
+ Talent progression runs in parallel via idle
+ DLC Grimoires add ~6–12 months beyond base game
Total: ~2.5–3.5 years for a dedicated player
```

---

## 🎯 Key Level Milestone Timing

| Level | Unlock | Estimated timing (1st Grimoire) |
|-------|--------|-------------------------------|
| 8 | Guard input | ~3 days |
| 15 | 2-input combos | ~1 week |
| 19 | Subclass Technique 1 | ~10 days |
| 23 | STR/DEX/INT +1 (permanent) | ~2 weeks |
| 31 | Surge input | ~3 weeks |
| 35 | 3-input combos | ~4 weeks |
| 38 | Combo Streak unlocks | ~5 weeks |
| 42 | Subclass Technique 2 | ~6 weeks |
| 47 | VIT/LCK/WIL +1 (permanent) | ~7 weeks |
| 55 | Full combo depth | ~2–3 months |
| 63 | STR/DEX/INT +2 (permanent) | ~3.5 months |
| 67 | Subclass Technique 3 | ~4 months |
| 81 | VIT/LCK/WIL +2 (permanent) | ~4.5 months |
| 85 | Subclass Technique 4 | ~5 months |
| 88 | Passive aggro +50% / Idle upgrade | ~5.5 months |
| 100 | Mastery | ~6 months |

---

## 🔧 Implementation Notes for Claude Code

**XP storage:**
```sql
-- player_grimoire_levels table (already defined)
combat_xp    INTEGER DEFAULT 0  -- current XP toward next level
combat_level INTEGER DEFAULT 1
```

**Level up check:**
```csharp
int[] xpPerLevel = {
    0,    // level 0 placeholder
    100, 100, 100, 100, 100,     // levels 1-5
    200, 200, 200, 200, 200,     // levels 6-10
    350, 350, 350, 350, 350,     // levels 11-15
    550, 550, 550, 550, 550,     // levels 16-20
    800, 800, 800, 800, 800,     // levels 21-25
    // ... continue pattern
};

void AddCombatXP(int amount) {
    currentXP += amount;
    while (currentXP >= xpPerLevel[currentLevel] && currentLevel < 100) {
        currentXP -= xpPerLevel[currentLevel];
        currentLevel++;
        OnLevelUp(currentLevel);
        CheckStatMilestone(currentLevel);
        CheckTechniqueUnlock(currentLevel);
    }
    SaveToSupabase();
}
```

**XP award on kill:**
```csharp
void OnEnemyKilled(EnemyData enemy, bool attunementSuccess) {
    int baseXP = enemy.xpValue; // Set per enemy in EnemyData ScriptableObject
    float multiplier = attunementSuccess ? 1.5f : 1.0f;
    int totalXP = Mathf.RoundToInt(baseXP * multiplier);
    
    // Award to currently equipped Grimoire only
    GrimoireManager.equippedGrimoire.AddCombatXP(totalXP);
    
    // Update Total Combat Level display
    CharacterPanel.UpdateTotalCombatLevel();
}
```

**EnemyData XP values:**
Set on each EnemyData ScriptableObject — use zone tier to determine base value:
```
Tier 1 standard: xpValue = 8
Tier 1 elite: xpValue = 40
Tier 1 boss: xpValue = 160
// etc. per zone tier table above
```

**Total Combat Level calculation:**
```csharp
int GetTotalCombatLevel() {
    return playerGrimoireLevels
        .Where(g => g.isOwned)
        .Sum(g => g.combatLevel);
}
```

Called on every level-up to check zone unlock thresholds.

---

*Document version 0.1 — Grimoire Combat XP Curve*
*Next: Phase 2 handoff*
