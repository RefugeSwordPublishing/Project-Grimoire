---
type: implementation-brief
spec: slaying-talent-spec.md, combat-engagement-spec.md (v0.2)
updated: 2026-07-11
purpose: Wire the Slaying talent elite spawn bonus into the existing combat loop stub.
         Short brief, one method to implement, already stubbed in CombatManager.
---

# Slaying Talent, Elite Spawn Bonus Implementation Brief

## What's Already Built

Per `implementation-status.md`, the combat loop already has this stub:

```csharp
float slayingBonus = SlayingTalent.GetEliteSpawnBonus(); // returns 0 until built
float finalEliteChance = 0.06f
    + (CombatXPManager.TotalCombatLevel * 0.001f)
    + slayingBonus;
```

This brief tells Claude Code what `GetEliteSpawnBonus()` should return.

---

## Implement SlayingTalent.GetEliteSpawnBonus()

The bonus is milestone-based, specific Slaying levels unlock fixed bonuses,
not a smooth curve. Read current Slaying level from `TalentManager`.

```csharp
public static class SlayingTalent {
    public static float GetEliteSpawnBonus() {
        int slayingLevel = TalentManager.GetTalentLevel("Slaying");

        return slayingLevel switch {
            >= 100 => 0.20f,  // +20%
            >= 80  => 0.14f,  // +14%
            >= 60  => 0.09f,  // +9%
            >= 40  => 0.05f,  // +5%
            >= 20  => 0.02f,  // +2%
            _      => 0.00f   // no bonus below level 20
        };
    }
}
```

---

## Full Elite Chance Formula (already in CombatManager, no change needed)

```
finalEliteChance = 0.06                              // 6% base
                 + (TotalCombatLevel × 0.001, max +9%) // combat level scaling
                 + SlayingTalent.GetEliteSpawnBonus()  // Slaying milestone bonus
```

**Range at max investment:**
- Base: 6%
- Max combat level bonus: +9% (at Total Combat Level 90+)
- Max Slaying bonus: +20% (at Slaying 100)
- **Theoretical max: 35% elite chance**

This means a dedicated Slayer with maxed Slaying and high Total Combat Level
sees an elite roughly 1 in 3 encounters, a genuinely meaningful identity.

---

## Slaying XP, Also Wire Here

While touching Slaying, confirm XP awards on elite and boss kills are
flowing correctly into the Slaying talent. From the spec:

```csharp
// On any enemy kill in CombatManager:
void OnEnemyKilled(EnemyData enemy) {
    // Existing:
    CombatXPManager.AwardKill(enemy, equippedGrimoire);

    // Add if not already present:
    TalentManager.AwardSlayingXP(enemy.slayingXP);
    // enemy.slayingXP already set on EnemyData from CreateZoneEnemies tool
}
```

Elites and bosses should have higher `slayingXP` values on their
`EnemyData` assets than standard enemies. Confirm during the sprite/content
pass, if not set, add:

```
Standard enemy slayingXP:  10
Elite enemy slayingXP:     50
Zone boss slayingXP:       200
```

---

## Monster Sign Queue Integration (Tracking Talent, stub)

The Tracking talent's Monster Sign (level 33) feeds an elite encounter queue
(max 3 queued elites). When the queue has entries, the next combat encounter
pulls from the queue rather than rolling the spawn table.

Stub this now so it's ready when Tracking is implemented:

```csharp
// In CombatManager, before normal weighted spawn:
EnemyData GetNextEnemy(ZoneData zone) {
    // Check Monster Sign queue first
    if (TrackingTalent.EliteQueue.Count > 0) {
        var queued = TrackingTalent.EliteQueue.Dequeue();
        // Apply the queued elite's drop rate bonus
        _nextEnemyDropBonus = queued.dropRateBonus; // 0.20f
        return GetEliteEnemy(zone);
    }

    // Normal elite roll
    if (Random.value < finalEliteChance)
        return GetEliteEnemy(zone);

    // Standard weighted random
    return GetWeightedRandomEnemy(zone);
}
```

`TrackingTalent.EliteQueue` returns an empty queue until Tracking is
implemented, no behaviour change for now.

---

## That's It

One method. The stub is already in place. Wire `GetEliteSpawnBonus()`,
confirm Slaying XP is flowing on kills, add the Monster Sign queue stub.

---

*Path: `docs/slaying-elite-bonus-brief.md`*
