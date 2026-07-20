### Version 0.2 — Rebalanced (2026-07-19)

> **Playtesting found:** idle XP was far too fast — level 20 reachable in a single
> overnight session. Two fixes applied: (1) XP per level increased ~3× across the
> board, (2) XP model changed to **damage-based** — 0.3 XP per damage point dealt,
> every hit, both idle and active. Active players deal more damage per hit and
> naturally progress faster. No separate tick rate — one mechanism, always on.
> See `docs/progression-rebalance-brief.md`.

---

## 📐 Design Philosophy

The Grimoire combat progression curve is **accelerating** — early levels unlock
quickly to get players into interesting mechanics, while later levels require
sustained investment. The curve is designed around a casual player
(1–2 hours/day combined active and idle play).

**Target milestones (revised):**
- Level 15 (2-input combos): ~2–3 weeks first Grimoire
- Level 20 (stat milestone): ~1 month
- Level 35 (3-input combos): ~3 months
- Level 55 (full combo depth): ~6 months
- Level 100 (mastery): ~18 months per Grimoire
- Full mastery (all 7 Grimoires + Talents to 100): ~5+ years

---

## 📊 XP Required Per Level

| Level Range | XP per level | Cumulative XP to reach |
|------------|-------------|----------------------|
| 1–5 | 300 | 1,500 |
| 6–10 | 600 | 4,500 |
| 11–15 | 1,100 | 10,000 |
| 16–20 | 1,800 | 19,000 |
| 21–25 | 2,800 | 33,000 |
| 26–30 | 4,000 | 53,000 |
| 31–35 | 5,500 | 80,500 |
| 36–40 | 7,500 | 118,000 |
| 41–45 | 10,500 | 170,500 |
| 46–50 | 14,000 | 240,500 |
| 51–55 | 18,500 | 333,000 |
| 56–60 | 24,000 | 453,000 |
| 61–65 | 31,000 | 608,000 |
| 66–70 | 39,000 | 803,000 |
| 71–75 | 49,000 | 1,048,000 |
| 76–80 | 61,000 | 1,353,000 |
| 81–85 | 76,000 | 1,733,000 |
| 86–90 | 94,000 | 2,203,000 |
| 91–95 | 115,000 | 2,778,000 |
| 96–100 | 140,000 | 3,478,000 |

**Total XP to level 100: ~3,478,000**

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

**XP storage — unchanged (already built):**
```sql
-- player_grimoire_levels table (already exists)
combat_xp    INTEGER DEFAULT 0
combat_level INTEGER DEFAULT 1
```

**XP award — damage-based, every hit:**
```csharp
// In CombatManager, on every hit that deals damage:
void OnDamageDealt(float damage, bool isPlayerAttack) {
    if (!isPlayerAttack) return;

    float xp = damage * 0.3f; // 0.3 XP per damage point
    CombatXPManager.AwardXP(equippedGrimoire, xp);
}
```

No separate tick rate. No per-enemy xpValue needed for combat XP.
Idle and active both use the same path — active players deal more damage
per hit (combos, weak points, attunement bonuses) and earn more XP naturally.

**Attunement XP bonus still applies:**
```csharp
// Active attunement hit (weak point, speed bonus, counter etc.):
float xp = damage * 0.3f * 1.5f; // ×1.5 on attunement success
```

**Updated xpPerLevel array:**
```csharp
// Replace old array entirely:
int[] xpPerLevel = {
    0,                                           // level 0 placeholder
    300, 300, 300, 300, 300,                    // levels 1–5
    600, 600, 600, 600, 600,                    // levels 6–10
    1100, 1100, 1100, 1100, 1100,              // levels 11–15
    1800, 1800, 1800, 1800, 1800,              // levels 16–20
    2800, 2800, 2800, 2800, 2800,              // levels 21–25
    4000, 4000, 4000, 4000, 4000,              // levels 26–30
    5500, 5500, 5500, 5500, 5500,              // levels 31–35
    7500, 7500, 7500, 7500, 7500,              // levels 36–40
    10500, 10500, 10500, 10500, 10500,         // levels 41–45
    14000, 14000, 14000, 14000, 14000,         // levels 46–50
    18500, 18500, 18500, 18500, 18500,         // levels 51–55
    24000, 24000, 24000, 24000, 24000,         // levels 56–60
    31000, 31000, 31000, 31000, 31000,         // levels 61–65
    39000, 39000, 39000, 39000, 39000,         // levels 66–70
    49000, 49000, 49000, 49000, 49000,         // levels 71–75
    61000, 61000, 61000, 61000, 61000,         // levels 76–80
    76000, 76000, 76000, 76000, 76000,         // levels 81–85
    94000, 94000, 94000, 94000, 94000,         // levels 86–90
    115000, 115000, 115000, 115000, 115000,    // levels 91–95
    140000, 140000, 140000, 140000, 140000,    // levels 96–100
};

void AddCombatXP(float amount) {
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

Note: `xpValue` on `EnemyData` ScriptableObjects is no longer used for combat
Grimoire XP — remove that field or repurpose it for Slaying Talent XP only
(which remains flat per-kill, not damage-based).

**Total Combat Level calculation — unchanged:**
```csharp
int GetTotalCombatLevel() =>
    playerGrimoireLevels.Where(g => g.isOwned).Sum(g => g.combatLevel);
```

---

*Document version 0.2 — Grimoire Combat XP Curve (damage-based model)*
