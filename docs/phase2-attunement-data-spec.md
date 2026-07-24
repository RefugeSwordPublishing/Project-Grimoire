# Project Grimoire, Phase 2 Attunement Data Spec
### Version 0.5

---

## Core Attunement Rule, Always Additive, Never Gated

**Attunement windows NEVER gate content.** Idle players always receive the base
yield, base drop rate, base result. Active players who hit the attunement window
receive a bonus ON TOP of the base.

```
Idle player:   base yield
Active player: base yield + attunement bonus
```

This is non-negotiable. Any attunement that says "requires active play to get X"
contradicts the semi-idle design and will push players to feel punished for idling.
When reviewing attunement specs: if the idle result is "nothing", that's wrong.

---

---

## Design Notes

Spellcasting attunement is fundamentally different from all Phase 1 Talent attunements:

- **Not cycle-based**, player initiates casts, no fixed cycle length
- **No critical hit system**, no weak points, no crit chance, no crit damage. Skill expression comes from draw speed and counter-element knowledge
- **No random proc**, every bonus is deterministic and skill-driven
- **Two independent attunement checks** fire on every cast, either, both, or neither can trigger
- **Marksmanship weak point system unchanged**, Bowstring accuracy-based crits remain as designed. This spec covers Mage Grimoires only

---

## Spellcasting Attunement Structure

Unlike Phase 1 Talents which use a single `attunementWindowAt` timing system, Spellcasting uses two independent boolean checks evaluated at cast resolution (finger lift).

```
On cast resolution:
  1. Check speedAttunement → drawTime < threshold?
  2. Check counterAttunement → counter-element pair in sequence?
  3. Apply bonuses independently, both can fire on same cast
```

---

## Spellcasting Attunement Data Fields

```
hasAttunement              true
isPlayerDriven             true  (not cycle-based, same flag as Marksmanship)
cycleLength                N/A   (player-driven)
attunementWindowAt         0.0   (always active, player initiates)
attunementWindowDuration   N/A   (player-controlled draw)

// Speed Attunement
speedAttunement_enabled    true
speedAttunement_threshold  0.4s  (Lightning tier, draw all nodes in under 0.4s)
speedAttunement_xpBonus    1.5   (+50% XP on Lightning speed cast)
speedAttunement_cueLabel   "Lightning draw!"

// Counter Attunement  
counterAttunement_enabled  true
counterAttunement_lootBonus 0.06 (6% loot bonus, rewards counter knowledge)
counterAttunement_cueLabel "Counter element!"

// No mastery loot bonus, 4-rune depth reward is the damage multiplier itself
// No crit system, no weak points, no crit chance, no crit damage
```

---

## Speed Tiers, Damage Modifiers

Speed affects damage output but is NOT the attunement check, attunement XP bonus only fires at Lightning tier. All speed tiers deal damage normally.

| Speed Tier | Draw Time | Damage Modifier | XP Attunement |
|-----------|-----------|----------------|--------------|
| **Lightning** | Under 0.4s | ×1.5 | +50% XP |
| **Swift** | 0.4s - 0.8s | ×1.25 | No bonus |
| **Standard** | 0.8s - 1.5s | ×1.0 | No bonus |
| **Slow** | Over 1.5s | ×0.85 | No bonus |

The damage modifier applies to ALL speed tiers, a slow cast still fires, just at reduced effectiveness. A Lightning cast deals 75% more damage than a Slow cast of the same combination.

---

## Counter-Element Damage Bonus

Counter bonus applies to damage but NOT to the speed multiplier, they are independent calculations:

```
Final Damage = Base Magic Damage 
             × Combination Depth Multiplier 
             × Speed Tier Modifier
             × Counter Bonus (if applicable)
```

| Scenario | Damage Calculation |
|----------|-------------------|
| Standard 2-rune, Standard speed | Base × 1.4 × 1.0 |
| Standard 2-rune, Lightning speed | Base × 1.4 × 1.5 |
| Counter 2-rune, Standard speed | Base × 1.4 × 1.0 × 1.25 |
| Counter 2-rune, Lightning speed | Base × 1.4 × 1.5 × 1.25, peak output |
| 4-rune, Lightning speed | Base × 2.2 × 1.5, mastery reward |
| 4-rune counter, Lightning speed | Base × 2.2 × 1.5 × 1.25, absolute peak |

---

## Combination Depth Multipliers (from Runic Constellation spec)

| Depth | Multiplier | Notes |
|-------|-----------|-------|
| 1 rune | ×1.0 | Base |
| 2 runes | ×1.4 | Standard combo |
| 3 runes | ×1.8 | Significant jump |
| 4 runes | ×2.2 | Mastery reward, no extra loot needed |
| Counter-element bonus | ×1.25 | Stacks multiplicatively |

---

## Attunement Visual & Audio Feedback

### Speed Attunement (Lightning draw)
- **Visual:** Brief golden speed-line effect trails behind the draw path, appears only at Lightning tier
- **Audio:** A sharp ascending chime, distinct from the standard constellation completion sound
- **Feedback text:** "+Speed!" floats above the constellation briefly
- **When:** Fires at cast resolution, player sees it as the spell launches

### Counter Attunement
- **Visual:** The connection line between counter-element nodes glows brighter than standard connections, the counter pair visually "crackles" as drawn
- **Audio:** A harmonic resonance tone, two notes resolving into a chord
- **Feedback text:** "+Counter!" floats above the constellation
- **When:** Fires as the counter-element node is connected, immediate feedback during drawing, not just at cast

### Both Attunements Together
- **Visual:** Golden speed lines + crackling counter connections simultaneously
- **Audio:** Both sounds layer, speed chime over counter resonance
- **Feedback text:** "+Speed! +Counter!" stacked
- This is the peak active play moment, visually and aurally satisfying

---

## Idle Behavior

| Field | Value |
|-------|-------|
| Idle cast | Auto-casts last manually drawn combination |
| Idle potency | 60% of base Magic Attack |
| Idle speed tier | Always Standard (×1.0), no speed bonus during idle |
| Idle counter | Counter bonus DOES apply during idle if last combination was a counter pair |
| Idle XP | No speed attunement XP bonus during idle |
| Idle cast interval | Scales with Spellcasting level (see table below) |

**Why counter applies during idle but speed doesn't:**
Counter-element is a knowledge choice, the player set a counter combination as their idle cast. Rewarding that choice during idle makes strategic sense. Speed is an execution skill, impossible to measure during automated casting.

### Idle Cast Interval by Spellcasting Level
| Level | Cast Interval |
|-------|-------------|
| 1-20 | Every 5.0s |
| 21-40 | Every 4.0s |
| 41-60 | Every 3.5s |
| 61-80 | Every 3.0s |
| 81-100 | Every 2.5s |

---

## Implementation Notes for Claude Code

**Data structure, separate from Phase 1 TalentActivity:**
Spellcasting attunement does not use the standard `attunementWindowAt` timing system. This data lives on the Grimoire ScriptableObject rather than a TalentActivity ScriptableObject, Spellcasting is no longer a shared Talent. Each Arcanist Grimoire has its own `SpellcastingAttunementData` component:

```csharp
[CreateAssetMenu]
public class SpellcastingAttunementData : ScriptableObject {
    // Speed attunement
    public bool speedAttunement_enabled = true;
    public float speedThreshold = 0.4f;
    public float speedXPBonus = 1.5f;
    public string speedCueLabel = "Lightning draw!";

    // Counter attunement
    public bool counterAttunement_enabled = true;
    public float counterLootBonus = 0.06f;
    public string counterCueLabel = "Counter element!";

    // No crit system, no weak points, no crit chance
    // No mastery loot bonus, depth reward is the damage multiplier
}
```

**Speed check at cast resolution:**
```csharp
void OnCastResolved(float drawTime, bool isCounterElement) {
    // Speed attunement
    if (drawTime < spellcastingData.speedThreshold) {
        ApplyXPBonus(spellcastingData.speedXPBonus);
        ShowAttunementFeedback("speed");
    }

    // Counter attunement
    if (isCounterElement) {
        ApplyLootBonus(spellcastingData.counterLootBonus);
        ShowAttunementFeedback("counter");
    }

    // Speed damage modifier (always applies, not just at Lightning)
    float speedMod = drawTime < 0.4f ? 1.5f :
                     drawTime < 0.8f ? 1.25f :
                     drawTime < 1.5f ? 1.0f : 0.85f;

    // Counter damage bonus (independent)
    float counterMod = isCounterElement ? 1.25f : 1.0f;

    // Final damage
    float finalDamage = baseDamage 
                      * depthMultiplier 
                      * speedMod 
                      * counterMod;
    ApplyDamage(finalDamage);
}
```

**Counter-element detection:**
```csharp
bool IsCounterPair(RuneType a, RuneType b, ArcanistSubclass subclass) {
    // Look up subclass-specific counter pairs
    // from RunicConstellationData.counterPairs[subclass]
    return counterPairs[subclass].Contains((a, b)) || 
           counterPairs[subclass].Contains((b, a));
}
```

**No crit system for Mage Grimoires:**
```csharp
// In CombatManager:
if (currentGrimoire.path == GrimoirePath.Arcanist ||
    currentGrimoire.path == GrimoirePath.Vanguard) {
    critChance = 0f;           // No crit system for Mage or Melee
    weakPointEnabled = false;  // No weak points
}
// Marksmanship weak point system unaffected, Warden path only
// Vanguard skill expression = combo speed + streak maintenance
// Arcanist skill expression = draw speed + counter-element knowledge
```

---

## Phase 2 Additions, Cultivation Talent

Base Cultivation attunement (Phase 1) remains unchanged, watering/pruning prompt at cycle position 0.40, 1.5s window, +2 yield bonus. Phase 2 adds tier-specific attunement behavior for higher-level plot types.

### Cultivation, Tiered Attunement by Plot Type

As Cultivation level unlocks higher-tier plots, the attunement window and bonus scales with the rarity and value of the crop:

| Plot Type | Unlock Level | Window Duration | Yield Bonus | Loot Bonus | Notes |
|-----------|-------------|----------------|------------|-----------|-------|
| Basic Crops (Wheat, Potato) | 1 | 1.5s | +2 crops |, | Standard attunement |
| Herb Garden | 8 | 1.5s | +2 herbs |, | Same as basic |
| Fiber Crops | 13 | 1.5s | +2 fiber |, | Same as basic |
| Paper Plants | 24 | 1.5s | +1 paper |, | Lower yield, paper is higher value |
| Orchard | 32 | 1.2s | +2 fruit | +5% seed | Tighter, fruit timing more precise |
| Alchemical Garden | 44 | 1.0s | +1 reagent | +8% rare | Tighter, alchemical plants more delicate |
| Enchanted Soil | 53 | 0.8s | +1 output | +12% quality | Quality upgrade chance on success |
| Moonflower | 61 | 0.6s | +1 moonflower | +15% rare | Night-cycle only, tightest window |
| Void Bloom | 76 | 0.8s | +1 bloom | +20% yield | Very slow cycle (30s), high stakes |
| Worldseed | 84 | 0.5s | +1 worldseed |, | **Tightest window in the game**, one plot per account, each harvest matters enormously |

**Worldseed note:** The Worldseed plot is the single most valuable Cultivation output, one plot per account, slow growth, Masterwork Feast ingredient. The 0.5s attunement window on Worldseed is the tightest active window in all of Project Grimoire. Missing it loses an irreplaceable harvest tick. High-Cultivation players who master this window have a genuine economic advantage.

### Cultivation, Moonflower Night Cycle

Moonflower plots only grow during a simulated night cycle (real-world time: midnight to 6am local device time, or a server-defined night window):

- During day: Moonflower plots dormant, no attunement window fires
- During night: Growth cycle activates, attunement window appears at position 0.40
- **Night window bonus:** If player is active during night and hits attunement: +15% rare drop on top of standard bonus
- Push notification available: "Your Moonflower is ready to tend" (P3 priority, night-only)

```
moonflowerNightOnly = true
moonflowerActiveHours = "00:00 - 06:00 local"
nightBonusMultiplier = 1.15
```

### Cultivation, Cue Label Progression

As plots become rarer the cue label updates to match the stakes:

| Plot Type | Cue Label |
|-----------|----------|
| Basic/Herb/Fiber | "Tend the crop!" |
| Orchard | "Harvest carefully!" |
| Alchemical | "Precise timing!" |
| Enchanted | "Feel the magic!" |
| Moonflower | "Catch the bloom!" |
| Void Bloom | "Void stirs, act!" |
| Worldseed | "Once in a lifetime!" |

---

## Phase 2 Additions, Tracking Talent

Base Tracking attunement (Phase 1) remains unchanged, trail indicator at cycle position 0.35, 1.0s window, +30% loot bonus. Phase 2 adds context-specific attunement behavior as higher-tier trail types unlock.

### Tracking, Tiered Attunement by Trail Type

| Trail Type | Unlock Level | Window Duration | Loot Bonus | Yield | Notes |
|-----------|-------------|----------------|-----------|-------|-------|
| Basic Animal Tracks | 1 | 1.0s | +30% find |, | Standard |
| Terrain Reading | 11 | 1.0s | +30% node | +1 | Bonus Foraging node revealed |
| Rare Creature Trails | 22 | 0.9s | +35% find |, | Feeds high-tier Trapping |
| Monster Sign | 33 | 0.8s | +40% elite |, | Reveals elite spawn for Slaying, tighter window reflects danger |
| Ancient Trail | 53 | 0.7s | +45% cache |, | Reveals hidden Gleaning cache, very tight, very rewarding |
| Void Creature Tracks | 63 | 0.6s | +50% find |, | Endgame creatures, tightest standard window |
| Legendary Spoor | 74 | 0.5s | +60% find |, | Legendary creatures, matches Worldseed for tightest window |

### Tracking, Monster Sign Attunement (Level 33)

Monster Sign builds an **elite encounter queue**, rather than revealing a fixed location (elites spawn randomly, not pre-placed), successful tracking adds a guaranteed elite encounter to the player's queue. When combat begins, queued elites are pulled first before the normal random spawn system.

**Queue rules:**
- Maximum 3 queued elite encounters
- Queue persists until used, carries across sessions
- Queued elites respect current zone's elite enemy roster
- Queued elites still benefit from Slaying level spawn rate bonuses and drop table upgrades
- Drop rate bonus from successful Monster Sign attunement applies to that queued elite

**HUD display:**
```
Elite queue: [][][ ], 2 tracked
```
Small indicator near the combat input area. Empty brackets = queue slots available.

**Three-tier outcome:**

| Outcome | What happens |
|---------|-------------|
| **Hit attunement** | +1 elite added to queue (up to 3) + 20% drop rate bonus on that queued encounter |
| **Miss attunement** | No queue addition, trail goes cold this cycle |
| **Idle Tracking** | +2% elite spawn chance bonus (passive, always active during idle), no queue addition |

**Idle players still benefit**, the +2% passive elite bonus applies during idle
without any input. Active attunement builds the queue for guaranteed elites.
Active play is better, idle is not penalised.

```csharp
void OnMonsterSignAttunement(bool success) {
    if (success && eliteQueue.Count < 3) {
        eliteQueue.Enqueue(new EliteEncounter {
            dropRateBonus = 0.20f,
            zone = currentZone
        });
        HUD.UpdateEliteQueueDisplay(eliteQueue.Count);
    }
}

EnemyEncounter GetNextEncounter() {
    if (eliteQueue.Count > 0) {
        return eliteQueue.Dequeue(); // Pull queued elite first
    }
    return GetRandomSpawn(); // Fall back to normal spawn
}
```

**Synergy with Slaying:**
Queued elite kills count as normal elite kills for Slaying XP and task progress. The combination of high Tracking (queue building) and high Slaying (elite spawn rate) creates a dedicated elite hunter build, always fighting elites, never waiting for random spawns.

### Tracking, Ancient Trail Attunement (Level 53)

Reveals hidden Gleaning cache locations. Works differently from standard trail following:

- Trail appears showing a path to a hidden cache location
- Player must tap trail waypoints in sequence (2-3 waypoints) within the window
- All waypoints tapped → cache revealed with +45% loot bonus
- Partial completion → cache revealed at reduced bonus (-15% per missed waypoint)
- No taps → cache NOT revealed (idle Tracking does not reveal Ancient caches)

```
ancientTrailAttunement_cueLabel      = "Ancient cache, follow the trail!"
ancientTrailAttunement_waypointCount = 2-3 (random per occurrence)
ancientTrailAttunement_fullBonus     = 0.45   (all waypoints hit)
ancientTrailAttunement_partialBonus  = 0.45 - (0.15 × missedWaypoints)
ancientTrailAttunement_idleResult    = "Cache revealed at base rate, no loot bonus"
```

**Idle players still find caches**, Ancient Trail always reveals the cache.
Active play adds a loot bonus (up to +45%) on top of the base reveal.
Missing the window = cache found, no bonus. Idle = cache found, no bonus.
This is the consistent attunement model: idle gets base, active gets more.

**Synergy note:** Ancient Trail + Gleaning 63 (Void Cache) together reveal dungeon caches AND zone caches, a high-level player with both has the best possible scavenging output in any content type.

> **Divination removed:** Divination Talent was removed for overlapping with Tracking's node-reveal functions. Tracking 53 (Ancient Trail) is now the primary hidden cache reveal mechanic. Divination deferred to future DLC.

### Tracking, Legendary Spoor (Level 74)

The highest-tier Tracking attunement. Reveals legendary creature locations for Beastmastery (DLC). In base game, legendary creatures are zone events similar to zone bosses, active play only.

- Longest cycle of any Tracking trail: 15.0 seconds (legendary creatures are rare)
- Tightest window: 0.5s, legendary creatures move quickly and unpredictably
- Hit attunement: Legendary creature spawns with 10-minute window, +60% rare drop
- Miss attunement: Creature location revealed but no spawn, next cycle may try again
- Idle: No legendary creature tracking, requires active engagement

```
legendarySpoorAttunement_cueLabel = "Legendary creature, now!"
legendarySpoorAttunement_cycleLength = 15.0s
legendarySpoorAttunement_windowDuration = 0.5s
legendarySpoorAttunement_onSuccess = SpawnLegendaryCreature(despawnTimer: 600)
legendarySpoorAttunement_lootBonus = 0.60
```

---

The base Gleaning attunement data (Phase 1 spec) remains unchanged. Phase 2 adds contextual attunement behavior in dungeons and raid aftermath.

### Gleaning, Dungeon Context (Void Cache, unlocks at Gleaning 63)

**Mechanic:** Hidden cache spots appear in specific dungeon rooms during the approach phase. A subtle glint is visible on specific tiles as the dungeon scrolls. Tap to claim before the room passes.
**Cue:** Faint shimmer on a dungeon tile, same visual language as zone Gleaning but in the dungeon tileset

| Field | Value |
|-------|-------|
| `hasAttunement` | true |
| `attunementCueLabel` | "Void Cache, tap it!" |
| `attunementWindowAt` | 0.45 |
| `attunementWindowDuration` | 2.0s |
| `attunementXPBonus` | 1.5 |
| `attunementLootBonus` | 0.50 |
| `attunementYieldBonus` | 1 (rare Assembly component) |
| `cycleLength` | Per room, triggers once per eligible room |

**Notes:** Longer window than zone Gleaning (2.0s vs 0.8s) since dungeon rooms are stationary, the tileset has stopped scrolling when this fires. Higher loot bonus (50%) because dungeon caches contain Assembly components and rare materials not available in zone Gleaning. Requires Gleaning 63 to unlock, not active in earlier dungeon runs.

**Dungeon cache content by dungeon tier:**
| Dungeon Tier | Cache Contents |
|-------------|---------------|
| Tier 1 | Crude-Rough rare materials, common crafting components |
| Tier 2 | Rough-Refined rare materials, uncommon Assembly components |
| Tier 3+ | Refined-Pristine rare materials, rare Assembly components |

---

### Gleaning, Raid Aftermath (unlocks when Gleaning 47+ AND raid completed)

**Mechanic:** After the raid boss is defeated, a brief aftermath phase opens where the battlefield is littered with scavengeable spots. Multiple glints visible simultaneously, player taps as many as possible before the aftermath window closes (30 seconds).
**Cue:** Multiple shimmer spots appear across the aftermath scene simultaneously, more spots than any zone or dungeon encounter

| Field | Value |
|-------|-------|
| `hasAttunement` | true |
| `attunementCueLabel` | "Scavenge the aftermath!" |
| `attunementWindowAt` | 0.0 (aftermath phase opens immediately after boss dies) |
| `attunementWindowDuration` | 30.0s (fixed aftermath window) |
| `attunementXPBonus` | 1.5 per successful tap |
| `attunementLootBonus` | 0.60 per cache (highest Gleaning bonus in the game) |
| `attunementYieldBonus` | 1-3 (random per cache) |
| `cycleLength` | One-time per raid, aftermath only |

**Notes:** The raid aftermath is the highest-value Gleaning moment in the game. Multiple simultaneous cache spots reward players who spam taps quickly. The Shadowblade subclass has a passive that extends the aftermath window by 10 seconds, their unique raid contribution beyond DPS.

**Number of cache spots visible:**
| Gleaning Level | Cache spots in aftermath |
|---------------|------------------------|
| 47-62 | 3-4 spots |
| 63-79 | 5-6 spots |
| 80-100 | 7-9 spots |

---

### Scavenger's Edge (Gleaning 54), Passive, No Active Attunement

Scavenger's Edge is a passive proc, no player input required. After any combat encounter (zone, dungeon, or raid) there is a 15% chance a bonus Gleaning item drops automatically.

```
hasAttunement = false  // Passive only, no tap window
```

This rolls separately from the main combat loot table, it's additive. The Gleaning talent level affects what quality the bonus item is:

| Gleaning Level | Bonus item quality |
|---------------|-------------------|
| 54-69 | Crude-Rough tier material from current zone pool |
| 70-84 | Rough-Refined tier material |
| 85-100 | Refined-Pristine tier material |

**Visual feedback:** A small "scavenge!" icon briefly appears near the loot drop, distinguishes it from regular combat loot. No window to tap, it just appears.

---

Warfare attunement uses two independent checks at combo resolution, mirrors Spellcasting's structure. No crit system, no weak points. Skill expression through combo speed and streak maintenance.

---

### Warfare Attunement Fields

```
hasAttunement              true
isPlayerDriven             true  (combo-based, not cycle-based)
cycleLength                N/A   (player-driven input)
attunementWindowAt         0.0   (always active, player initiates)
attunementWindowDuration   N/A   (player-controlled)

// Speed Attunement, all inputs completed under threshold
speedAttunement_enabled    true
speedAttunement_threshold  1.0s  (all combo inputs entered under 1.0s)
speedAttunement_xpBonus    1.5   (+50% XP on fast combo)
speedAttunement_damageBonus 0.25 (+25% damage on that combo)
speedAttunement_cueLabel   "Fast combo!"

// Streak Attunement, unlocks at Warfare level 38
streakAttunement_enabled   false (locked until Warfare Lv 38)
streakAttunement_threshold 3     (3 unique combos in a row)
streakAttunement_lootBonus 0.10  (+10% drop chance while streak active)
streakAttunement_cueLabel  "Combo streak!"

// No crit system for Vanguard
// weakPointEnabled = false
// critChance = 0f
```

---

### Speed Tiers, Damage Modifiers

Speed affects damage on every combo. Attunement XP bonus only fires at Lightning tier.

| Speed | All inputs completed in | Damage Modifier | XP Attunement |
|-------|------------------------|----------------|--------------|
| **Lightning** | Under 1.0s | +25% damage | +50% XP |
| **Standard** | 1.0s - 2.5s | Base damage | No bonus |
| **Slow** | Over 2.5s or auto-fire | Base damage | No bonus |

No damage penalty for slow, idle auto-fire always deals standard damage.

---

### Streak Attunement, Unlocks at Warfare Level 38

| Streak Count | Bonus |
|-------------|-------|
| 3 unique combos | +10% damage on next combo |
| 5 unique combos | +20% damage + 5% loot bonus |
| 10 unique combos | +30% damage + 10% loot bonus + visual indicator |

**Streak breaks on:**
- Repeating a combo sequence
- Taking heavy damage (>30% max HP in one hit)
- Idle auto-combat taking over

Streak does not build during idle, active play only.

---

### Per-Grimoire Attunement Behavior

| Grimoire | Speed threshold | Streak unlock | Key attunement moment |
|---------|----------------|--------------|----------------------|
| **Warlord** | 1.0s | Warfare Lv 38 | G→G→U (Fortress Surge) fast = massive taunt spike |
| **Shadowblade** | 1.0s | Warfare Lv 38 | U→U→S (Void Assassin) fast from stealth = peak burst |
| **Kensei (DLC)** | 0.8s (tighter) | Warfare Lv 35 | Focus mechanic adds third attunement layer, designed at DLC phase |

Kensei's tighter threshold (0.8s vs 1.0s) reflects the samurai discipline fantasy, precision timing is more demanding.

---

### Idle Behavior

| Warfare Level | Auto-Combat |
|--------------|------------|
| 1-71 | Auto-fires single Strike at base damage, Standard speed tier |
| 72-100 | Auto-fires last used 2-input combo at 70% potency |
| 100 (mastery) | Never retreats from Tier 3 zones or lower |

Streak never builds during idle. Speed attunement never fires during idle. Counter/combo bonuses apply at 70% potency if the idle combo qualifies.

---

### Visual & Audio Feedback

**Speed Attunement (Lightning combo):**
- Visual: brief motion blur trail on the weapon swing, appears only at Lightning tier
- Audio: sharp metallic ring, distinct from standard hit sound
- Feedback text: "Fast combo!" floats above player

**Streak Attunement:**
- Visual: streak counter badge visible near combo queue, glows brighter at each tier
- Audio: ascending tone series as streak builds, distinctive chime at 3, 5, 10
- Feedback text: "Combo streak x3!" / "x5!" / "x10!"
- Visual indicator at streak 10: weapon trails a subtle glow for the duration

**Both firing together:**
- Most satisfying active play moment for Vanguard
- Lightning combo during an active streak, both feedback layers play simultaneously

---

### No Crit System, Vanguard

```csharp
// In CombatManager:
if (currentGrimoire.path == GrimoirePath.Vanguard) {
    critChance = 0f;
    weakPointEnabled = false;
}
// Marksmanship weak point system unaffected, Warden path only
// Vanguard skill expression = combo speed + streak maintenance
```

---
*Document version 0.4, Phase 2 Attunement Data Spec*
*Key change: Spellcasting removed as shared Talent, attunement data now lives on each Arcanist Grimoire's Combat Progression*
*Added: Warfare attunement (all Vanguard Grimoires), Gleaning Phase 2 contexts, Cultivation tiered attunement, Tracking tiered attunement*
*Next: Combat XP curve · Phase 2 handoff*

---

## Phase 2 Additions, Felling Talent

Base Felling attunement (Phase 1) remains unchanged, bark crack timing cue,
tap window, bonus timber on hit. Phase 2 adds tiered attunement behavior as
higher-value tree types unlock.

### Felling, Tiered Attunement by Tree Type

The attunement window tightens and rewards increase as tree type rarity increases.
Higher wood types are harder to chop cleanly, precision is more valuable.

| Tree Type | Unlock Level | Window Duration | Yield Bonus | Rare Drop Bonus | Cue Label |
|-----------|-------------|----------------|------------|----------------|----------|
| Softwood (Pine, Birch) | 1 | 1.5s | +2 timber |, | "Tap now!" |
| Hardwood (Oak, Elm) | 14 | 1.2s | +2 timber | +5% bark | "Steady tap!" |
| Ancient Trees (Ironbark, Ashwood) | 33 | 1.0s | +2 timber | +8% heartwood | "Clean cut!" |
| Magicwood | 58 | 0.8s | +1 timber | +12% rare | "Feel the grain!" |
| Voidtimber | 84 | 0.6s | +1 void timber | +18% rare | "Void resonates!" |
| Worldtree Shard | 89 | 0.4s | +1 shard |, | "Once in a lifetime!" |

**Worldtree Shard note:** Tightest window in Felling, matches Worldseed Cultivation
for rarest gathering attunement. One Worldtree Shard per session maximum regardless
of attunement hits. Hitting the 0.4s window guarantees the shard that session.
Missing it means no shard that session, next session resets.

### Felling, Enchanted Grove Context (unlocks at Felling 52)

Enchanted Grove trees behave differently, they pulse with magical energy
that interferes with normal chopping rhythm. The bark crack cue fires in
irregular intervals rather than a predictable rhythm.

```
enchantedGrove_irregularCycle = true
enchantedGrove_cycleVariance  = ±0.4s (cue fires within a 0.8s random window)
enchantedGrove_windowDuration = 0.8s
enchantedGrove_yieldBonus     = +1 Magicwood
enchantedGrove_rareBonus      = +15% Arcane Weaving component drop
enchantedGrove_cueLabel       = "Now, the pulse!"
```

The irregular cycle means players cannot rely on muscle memory, must watch
for each individual cue. Rewards attention over reflex.

### Felling, Level 100 Capstone Interaction

At Felling level 100: "Bonus timber on every chop regardless of Attunement."
This means the idle yield floor rises to match the previous attunement yield.
Attunement still fires but the gap between hit and miss narrows significantly.

```csharp
// In FellingManager:
float baseYield = felling100Unlocked ? attunementYield : standardYield;
float bonusYield = attunementHit ? attunementBonus : 0;
```

---

## Phase 2 Additions, Delving Talent

Base Delving attunement (Phase 1) remains unchanged, glowing vein highlights
appear at cycle position 0.40, tap before they fade, bonus ore and gem drop.
Phase 2 adds tiered behavior as ore grades escalate.

### Delving, Tiered Attunement by Ore Grade

| Ore Grade | Key Unlock Level | Window Duration | Ore Yield Bonus | Gem Bonus | Cue Label |
|-----------|-----------------|----------------|----------------|----------|----------|
| Copper/Tin | 1 | 1.5s | +2 ore |, | "Tap the vein!" |
| Iron | 14 | 1.3s | +2 ore | +5% gem | "Strike it!" |
| Silver/Coal | 33 | 1.1s | +2 ore | +8% gem | "Hit the seam!" |
| Gold | 49 | 0.9s | +1 ore | +10% gem | "Rich vein!" |
| Mithril | 64 | 0.7s | +1 ore | +12% gem | "Careful, Mithril!" |
| Adamantine | 76 | 0.5s | +1 ore | +15% gem | "Adamantine holds!" |
| Starstone | 86 | 0.4s | +1 starstone | +20% rare | "Starstone pulse!" |
| Soulite | 92 | 0.3s | +1 soulite |, | "Soul resonates!" |

**Soulite note:** Tightest gathering window in the entire game at 0.3s. Matches
the reflex skill required of top Warden players. Soulite is endgame Runesmithing
material, the difficulty gate is intentional.

### Delving, Deep Cave Zone (unlocks at Delving 67)

Deep Cave nodes use the same tiered attunement as standard nodes, glowing vein
highlight, tap before it fades, bonus ore and gem. No additional hazard mechanic
in zone combat context.

> **Deferred:** Cave collapse warning mechanic (ceiling cracks, tap to brace,
> damage on miss) is reserved as a dungeon/raid environmental hazard where
> active play is expected. Not appropriate for zone gathering where idle players
> should still be able to mine normally.

### Delving, Level 100 Capstone Interaction

At Delving 100: "Gem drop guaranteed on every Attunement hit."
Attunement hits now always include a gem, not a chance roll.

```csharp
// In DelvingManager:
bool gemDrops = attunementHit
    ? (delving100Unlocked ? true : Random.value < gemDropChance)
    : false;
```

---

## Phase 2 Additions, Trapping Talent

Base Trapping attunement (Phase 1), placement-based, player sees optimal terrain
positions briefly then must place trap accurately. Better placement = higher catch rate.
Phase 2 adds tiered behavior as trap types escalate in complexity.

### Trapping, Tiered Attunement by Trap Type

Trapping attunement is fundamentally different from timing-based talents, 
it rewards **accurate spatial placement** rather than timed taps.

| Trap Type | Unlock Level | Placement Window | Catch Rate Bonus | Quality Bonus | Cue Label |
|-----------|-------------|-----------------|-----------------|--------------|----------|
| Rabbit Snare | 1 | 3.0s | +15% catch rate |, | "Place here!" |
| Fox Trap | 9 | 2.5s | +18% catch rate |, | "Set the trap!" |
| Deer Cage | 22 | 2.0s | +20% catch rate | +1 quality tier | "Bait the cage!" |
| Reinforced Snare | 16 | 2.0s | +22% catch rate |, | "Reinforce here!" |
| Wild Boar Trap | 39 | 1.5s | +25% catch rate | +1 quality tier | "Brace it!" |
| Beast Cage | 53 | 1.5s | +25% catch rate | +1 quality tier | "Secure the cage!" |
| Wolf Trap | 61 | 1.2s | +28% catch rate | +1 quality tier | "Steady now!" |
| Shadow Snare | 67 | 1.0s | +30% catch rate | +1 quality tier | "Feel the shadow!" |
| Runed Trap | 73 | 0.8s | +30% catch rate | +rare creature chance | "Bind the rune!" |
| Drake Trap | 82 | 0.6s | +35% catch rate | +Drake Scale chance | "Drake holds!" |
| Void Snare | 89 | 0.4s | +35% catch rate | +void creature chance | "Void binds!" |

### How Trapping Placement Attunement Works

Trapping attunement is always **additive**, idle traps still catch creatures
at the base catch rate. The placement indicator gives active players a bonus.

Unlike other talents where the player taps a cue, Trapping shows an **optimal
placement indicator**, a glowing zone on the terrain, for a brief window.
Player drags their trap icon to land within the zone for a bonus.
Missing the window or idling: trap is placed at standard position, base catch rate.

```
Accuracy tiers:
  Perfect placement (within inner 25% of zone): full catch rate bonus + quality bonus
  Good placement (within zone): catch rate bonus only
  Outside zone (missed window): base catch rate, no bonus
```

**Distance from optimal scales the bonus:**
```csharp
float distanceFromOptimal = Vector2.Distance(placementPos, optimalPos);
float optimalRadius = 50f; // pixels
float placementScore = Mathf.Clamp01(1f - (distanceFromOptimal / optimalRadius));
float catchBonus = maxCatchBonus * placementScore;
bool qualityUpgrade = placementScore > 0.75f; // top 25% gets quality tier
```

### Trapping, Shadow Snare Special (unlocks at Trapping 67)

Shadow Snares catch nocturnal and rare creatures. They only activate during
the simulated night cycle (same window as Moonflower Cultivation, midnight to 6am).

```
shadowSnare_nightOnly = true
shadowSnare_activeHours = "00:00 - 06:00 local"
shadowSnare_dayBehavior = "Trap visible but inactive, catches nothing during day"
shadowSnare_nightBonus  = +15% catch chance on top of placement bonus
```

Push notification available: "Your Shadow Snares are active!" (fires at midnight,
P4 priority, low urgency, opt-in).

### Trapping, Runed Trap (unlocks at Trapping 73, requires Runelore 40)

Runed Traps catch magical creatures (Mire Foxes, Rune-touched animals, etc.).
The placement indicator shows in a RUNIC pattern rather than a simple circle, 
player must place within a specific rune-shaped zone.

```
runedTrap_patternType    = "RunicCircle"  (versus standard "Circle")
runedTrap_windowDuration = 0.8s           (tight, rune pattern is complex)
runedTrap_cueLabel       = "Bind the rune!"
runedTrap_missEffect     = "Trap set but mundane creatures only, magical catch
                            rate 0% until reset"
```

The Runed Trap is the most complex Trapping attunement, player must match a
rune shape overlay rather than just landing within a circle. Rewards Trapping
mastery and cross-talent Runelore investment.

### Trapping, Level 100 Capstone Interaction

At Trapping 100: "Traps auto-reset without manual check."
Idle trap loop becomes fully autonomous, no active check needed to collect
and reset. Attunement still fires during the reset animation if player is active,
but the idle loop functions without any player input.

---

*Document version 0.5, Phase 2 Attunement Data Spec*
*Added: Felling tiered attunement, Delving tiered attunement (Deep Cave collapse removed, deferred to raids),
Trapping placement attunement + Shadow Snare + Runed Trap*
*Fixed: All attunement windows are now additive bonuses, idle always gets base yield/result.
Ancient Trail, Legendary Spoor, Monster Sign all confirmed additive not gated.*
