# ⚔️ Project Grimoire — Phase 2 Attunement Data Spec
### Version 0.1 — Spellcasting Talent

---

## 📐 Design Notes

Spellcasting attunement is fundamentally different from all Phase 1 Talent attunements:

- **Not cycle-based** — player initiates casts, no fixed cycle length
- **No critical hit system** — no weak points, no crit chance, no crit damage. Skill expression comes from draw speed and counter-element knowledge
- **No random proc** — every bonus is deterministic and skill-driven
- **Two independent attunement checks** fire on every cast — either, both, or neither can trigger
- **Marksmanship weak point system unchanged** — Bowstring accuracy-based crits remain as designed. This spec covers Mage Grimoires only

---

## ⚡ Spellcasting Attunement Structure

Unlike Phase 1 Talents which use a single `attunementWindowAt` timing system, Spellcasting uses two independent boolean checks evaluated at cast resolution (finger lift).

```
On cast resolution:
  1. Check speedAttunement → drawTime < threshold?
  2. Check counterAttunement → counter-element pair in sequence?
  3. Apply bonuses independently — both can fire on same cast
```

---

## 📊 Spellcasting Attunement Data Fields

```
hasAttunement              true
isPlayerDriven             true  (not cycle-based — same flag as Marksmanship)
cycleLength                N/A   (player-driven)
attunementWindowAt         0.0   (always active — player initiates)
attunementWindowDuration   N/A   (player-controlled draw)

// Speed Attunement
speedAttunement_enabled    true
speedAttunement_threshold  0.4s  (Lightning tier — draw all nodes in under 0.4s)
speedAttunement_xpBonus    1.5   (+50% XP on Lightning speed cast)
speedAttunement_cueLabel   "Lightning draw!"

// Counter Attunement  
counterAttunement_enabled  true
counterAttunement_lootBonus 0.06 (6% loot bonus — rewards counter knowledge)
counterAttunement_cueLabel "Counter element!"

// No mastery loot bonus — 4-rune depth reward is the damage multiplier itself
// No crit system — no weak points, no crit chance, no crit damage
```

---

## 🎯 Speed Tiers — Damage Modifiers

Speed affects damage output but is NOT the attunement check — attunement XP bonus only fires at Lightning tier. All speed tiers deal damage normally.

| Speed Tier | Draw Time | Damage Modifier | XP Attunement |
|-----------|-----------|----------------|--------------|
| **Lightning** | Under 0.4s | ×1.5 | ✅ +50% XP |
| **Swift** | 0.4s – 0.8s | ×1.25 | ❌ No bonus |
| **Standard** | 0.8s – 1.5s | ×1.0 | ❌ No bonus |
| **Slow** | Over 1.5s | ×0.85 | ❌ No bonus |

The damage modifier applies to ALL speed tiers — a slow cast still fires, just at reduced effectiveness. A Lightning cast deals 75% more damage than a Slow cast of the same combination.

---

## 🔄 Counter-Element Damage Bonus

Counter bonus applies to damage but NOT to the speed multiplier — they are independent calculations:

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
| Counter 2-rune, Lightning speed | Base × 1.4 × 1.5 × 1.25 — peak output |
| 4-rune, Lightning speed | Base × 2.2 × 1.5 — mastery reward |
| 4-rune counter, Lightning speed | Base × 2.2 × 1.5 × 1.25 — absolute peak |

---

## 🎮 Combination Depth Multipliers (from Runic Constellation spec)

| Depth | Multiplier | Notes |
|-------|-----------|-------|
| 1 rune | ×1.0 | Base |
| 2 runes | ×1.4 | Standard combo |
| 3 runes | ×1.8 | Significant jump |
| 4 runes | ×2.2 | Mastery reward — no extra loot needed |
| Counter-element bonus | ×1.25 | Stacks multiplicatively |

---

## 🎯 Attunement Visual & Audio Feedback

### Speed Attunement (Lightning draw)
- **Visual:** Brief golden speed-line effect trails behind the draw path — appears only at Lightning tier
- **Audio:** A sharp ascending chime — distinct from the standard constellation completion sound
- **Feedback text:** "+Speed!" floats above the constellation briefly
- **When:** Fires at cast resolution — player sees it as the spell launches

### Counter Attunement
- **Visual:** The connection line between counter-element nodes glows brighter than standard connections — the counter pair visually "crackles" as drawn
- **Audio:** A harmonic resonance tone — two notes resolving into a chord
- **Feedback text:** "+Counter!" floats above the constellation
- **When:** Fires as the counter-element node is connected — immediate feedback during drawing, not just at cast

### Both Attunements Together
- **Visual:** Golden speed lines + crackling counter connections simultaneously
- **Audio:** Both sounds layer — speed chime over counter resonance
- **Feedback text:** "+Speed! +Counter!" stacked
- This is the peak active play moment — visually and aurally satisfying

---

## 💤 Idle Behavior

| Field | Value |
|-------|-------|
| Idle cast | Auto-casts last manually drawn combination |
| Idle potency | 60% of base Magic Attack |
| Idle speed tier | Always Standard (×1.0) — no speed bonus during idle |
| Idle counter | Counter bonus DOES apply during idle if last combination was a counter pair |
| Idle XP | No speed attunement XP bonus during idle |
| Idle cast interval | Scales with Spellcasting level (see table below) |

**Why counter applies during idle but speed doesn't:**
Counter-element is a knowledge choice — the player set a counter combination as their idle cast. Rewarding that choice during idle makes strategic sense. Speed is an execution skill — impossible to measure during automated casting.

### Idle Cast Interval by Spellcasting Level
| Level | Cast Interval |
|-------|-------------|
| 1–20 | Every 5.0s |
| 21–40 | Every 4.0s |
| 41–60 | Every 3.5s |
| 61–80 | Every 3.0s |
| 81–100 | Every 2.5s |

---

## 🔧 Implementation Notes for Claude Code

**Data structure — separate from Phase 1 TalentActivity:**
Spellcasting attunement does not use the standard `attunementWindowAt` timing system. This data lives on the Grimoire ScriptableObject rather than a TalentActivity ScriptableObject — Spellcasting is no longer a shared Talent. Each Arcanist Grimoire has its own `SpellcastingAttunementData` component:

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

    // No crit system — no weak points, no crit chance
    // No mastery loot bonus — depth reward is the damage multiplier
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
// Marksmanship weak point system unaffected — Warden path only
// Vanguard skill expression = combo speed + streak maintenance
// Arcanist skill expression = draw speed + counter-element knowledge
```

---

## 🌾 Phase 2 Additions — Cultivation Talent

Base Cultivation attunement (Phase 1) remains unchanged — watering/pruning prompt at cycle position 0.40, 1.5s window, +2 yield bonus. Phase 2 adds tier-specific attunement behavior for higher-level plot types.

### Cultivation — Tiered Attunement by Plot Type

As Cultivation level unlocks higher-tier plots, the attunement window and bonus scales with the rarity and value of the crop:

| Plot Type | Unlock Level | Window Duration | Yield Bonus | Loot Bonus | Notes |
|-----------|-------------|----------------|------------|-----------|-------|
| Basic Crops (Wheat, Potato) | 1 | 1.5s | +2 crops | — | Standard attunement |
| Herb Garden | 8 | 1.5s | +2 herbs | — | Same as basic |
| Fiber Crops | 13 | 1.5s | +2 fiber | — | Same as basic |
| Paper Plants | 24 | 1.5s | +1 paper | — | Lower yield — paper is higher value |
| Orchard | 32 | 1.2s | +2 fruit | +5% seed | Tighter — fruit timing more precise |
| Alchemical Garden | 44 | 1.0s | +1 reagent | +8% rare | Tighter — alchemical plants more delicate |
| Enchanted Soil | 53 | 0.8s | +1 output | +12% quality | Quality upgrade chance on success |
| Moonflower | 61 | 0.6s | +1 moonflower | +15% rare | Night-cycle only, tightest window |
| Void Bloom | 76 | 0.8s | +1 bloom | +20% yield | Very slow cycle (30s), high stakes |
| Worldseed | 84 | 0.5s | +1 worldseed | — | **Tightest window in the game** — one plot per account, each harvest matters enormously |

**Worldseed note:** The Worldseed plot is the single most valuable Cultivation output — one plot per account, slow growth, Masterwork Feast ingredient. The 0.5s attunement window on Worldseed is the tightest active window in all of Project Grimoire. Missing it loses an irreplaceable harvest tick. High-Cultivation players who master this window have a genuine economic advantage.

### Cultivation — Moonflower Night Cycle

Moonflower plots only grow during a simulated night cycle (real-world time: midnight to 6am local device time, or a server-defined night window):

- During day: Moonflower plots dormant — no attunement window fires
- During night: Growth cycle activates — attunement window appears at position 0.40
- **Night window bonus:** If player is active during night and hits attunement: +15% rare drop on top of standard bonus
- Push notification available: "Your Moonflower is ready to tend" (P3 priority, night-only)

```
moonflowerNightOnly = true
moonflowerActiveHours = "00:00 - 06:00 local"
nightBonusMultiplier = 1.15
```

### Cultivation — Cue Label Progression

As plots become rarer the cue label updates to match the stakes:

| Plot Type | Cue Label |
|-----------|----------|
| Basic/Herb/Fiber | "Tend the crop!" |
| Orchard | "Harvest carefully!" |
| Alchemical | "Precise timing!" |
| Enchanted | "Feel the magic!" |
| Moonflower | "Catch the bloom!" |
| Void Bloom | "Void stirs — act!" |
| Worldseed | "Once in a lifetime!" |

---

## 🐾 Phase 2 Additions — Tracking Talent

Base Tracking attunement (Phase 1) remains unchanged — trail indicator at cycle position 0.35, 1.0s window, +30% loot bonus. Phase 2 adds context-specific attunement behavior as higher-tier trail types unlock.

### Tracking — Tiered Attunement by Trail Type

| Trail Type | Unlock Level | Window Duration | Loot Bonus | Yield | Notes |
|-----------|-------------|----------------|-----------|-------|-------|
| Basic Animal Tracks | 1 | 1.0s | +30% find | — | Standard |
| Terrain Reading | 11 | 1.0s | +30% node | +1 | Bonus Foraging node revealed |
| Rare Creature Trails | 22 | 0.9s | +35% find | — | Feeds high-tier Trapping |
| Monster Sign | 33 | 0.8s | +40% elite | — | Reveals elite spawn for Slaying — tighter window reflects danger |
| Ancient Trail | 53 | 0.7s | +45% cache | — | Reveals hidden Gleaning cache — very tight, very rewarding |
| Void Creature Tracks | 63 | 0.6s | +50% find | — | Endgame creatures — tightest standard window |
| Legendary Spoor | 74 | 0.5s | +60% find | — | Legendary creatures — matches Worldseed for tightest window |

### Tracking — Monster Sign Attunement (Level 33)

Monster Sign builds an **elite encounter queue** — rather than revealing a fixed location (elites spawn randomly, not pre-placed), successful tracking adds a guaranteed elite encounter to the player's queue. When combat begins, queued elites are pulled first before the normal random spawn system.

**Queue rules:**
- Maximum 3 queued elite encounters
- Queue persists until used — carries across sessions
- Queued elites respect current zone's elite enemy roster
- Queued elites still benefit from Slaying level spawn rate bonuses and drop table upgrades
- Drop rate bonus from successful Monster Sign attunement applies to that queued elite

**HUD display:**
```
⚔ Elite queue: [★][★][ ] — 2 tracked
```
Small indicator near the combat input area. Empty brackets = queue slots available.

**Three-tier outcome:**

| Outcome | What happens |
|---------|-------------|
| **Hit attunement** | +1 elite added to queue (up to 3) + 20% drop rate bonus on that queued encounter |
| **Miss attunement** | No queue addition — trail goes cold |
| **Idle Tracking** | No queue addition — requires active tracking to find elites |

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
Queued elite kills count as normal elite kills for Slaying XP and task progress. The combination of high Tracking (queue building) and high Slaying (elite spawn rate) creates a dedicated elite hunter build — always fighting elites, never waiting for random spawns.

### Tracking — Ancient Trail Attunement (Level 53)

Reveals hidden Gleaning cache locations. Works differently from standard trail following:

- Trail appears showing a path to a hidden cache location
- Player must tap trail waypoints in sequence (2–3 waypoints) within the window
- All waypoints tapped → cache revealed with +45% loot bonus
- Partial completion → cache revealed at reduced bonus (-15% per missed waypoint)
- No taps → cache NOT revealed (idle Tracking does not reveal Ancient caches)

```
ancientTrailAttunement_cueLabel = "Ancient cache — follow the trail!"
ancientTrailAttunement_waypointCount = 2-3 (random per occurrence)
ancientTrailAttunement_fullBonus = 0.45
ancientTrailAttunement_partialBonus = 0.45 - (0.15 × missedWaypoints)
ancientTrailAttunement_idleResult = "Cache not revealed — requires active tracking"
```

**Synergy note:** Ancient Trail + Gleaning 63 (Void Cache) together reveal dungeon caches AND zone caches — a high-level player with both has the best possible scavenging output in any content type.

> **Divination removed:** Divination Talent was removed for overlapping with Tracking's node-reveal functions. Tracking 53 (Ancient Trail) is now the primary hidden cache reveal mechanic. Divination deferred to future DLC.

### Tracking — Legendary Spoor (Level 74)

The highest-tier Tracking attunement. Reveals legendary creature locations for Beastmastery (DLC). In base game, legendary creatures are zone events similar to zone bosses — active play only.

- Longest cycle of any Tracking trail: 15.0 seconds (legendary creatures are rare)
- Tightest window: 0.5s — legendary creatures move quickly and unpredictably
- Hit attunement: Legendary creature spawns with 10-minute window, +60% rare drop
- Miss attunement: Creature location revealed but no spawn — next cycle may try again
- Idle: No legendary creature tracking — requires active engagement

```
legendarySpoorAttunement_cueLabel = "Legendary creature — now!"
legendarySpoorAttunement_cycleLength = 15.0s
legendarySpoorAttunement_windowDuration = 0.5s
legendarySpoorAttunement_onSuccess = SpawnLegendaryCreature(despawnTimer: 600)
legendarySpoorAttunement_lootBonus = 0.60
```

---

The base Gleaning attunement data (Phase 1 spec) remains unchanged. Phase 2 adds contextual attunement behavior in dungeons and raid aftermath.

### Gleaning — Dungeon Context (Void Cache, unlocks at Gleaning 63)

**Mechanic:** Hidden cache spots appear in specific dungeon rooms during the approach phase. A subtle glint is visible on specific tiles as the dungeon scrolls. Tap to claim before the room passes.
**Cue:** Faint shimmer on a dungeon tile — same visual language as zone Gleaning but in the dungeon tileset

| Field | Value |
|-------|-------|
| `hasAttunement` | true |
| `attunementCueLabel` | "Void Cache — tap it!" |
| `attunementWindowAt` | 0.45 |
| `attunementWindowDuration` | 2.0s |
| `attunementXPBonus` | 1.5 |
| `attunementLootBonus` | 0.50 |
| `attunementYieldBonus` | 1 (rare Assembly component) |
| `cycleLength` | Per room — triggers once per eligible room |

**Notes:** Longer window than zone Gleaning (2.0s vs 0.8s) since dungeon rooms are stationary — the tileset has stopped scrolling when this fires. Higher loot bonus (50%) because dungeon caches contain Assembly components and rare materials not available in zone Gleaning. Requires Gleaning 63 to unlock — not active in earlier dungeon runs.

**Dungeon cache content by dungeon tier:**
| Dungeon Tier | Cache Contents |
|-------------|---------------|
| Tier 1 | Crude–Rough rare materials, common crafting components |
| Tier 2 | Rough–Refined rare materials, uncommon Assembly components |
| Tier 3+ | Refined–Pristine rare materials, rare Assembly components |

---

### Gleaning — Raid Aftermath (unlocks when Gleaning 47+ AND raid completed)

**Mechanic:** After the raid boss is defeated, a brief aftermath phase opens where the battlefield is littered with scavengeable spots. Multiple glints visible simultaneously — player taps as many as possible before the aftermath window closes (30 seconds).
**Cue:** Multiple shimmer spots appear across the aftermath scene simultaneously — more spots than any zone or dungeon encounter

| Field | Value |
|-------|-------|
| `hasAttunement` | true |
| `attunementCueLabel` | "Scavenge the aftermath!" |
| `attunementWindowAt` | 0.0 (aftermath phase opens immediately after boss dies) |
| `attunementWindowDuration` | 30.0s (fixed aftermath window) |
| `attunementXPBonus` | 1.5 per successful tap |
| `attunementLootBonus` | 0.60 per cache (highest Gleaning bonus in the game) |
| `attunementYieldBonus` | 1–3 (random per cache) |
| `cycleLength` | One-time per raid — aftermath only |

**Notes:** The raid aftermath is the highest-value Gleaning moment in the game. Multiple simultaneous cache spots reward players who spam taps quickly. The Shadowblade subclass has a passive that extends the aftermath window by 10 seconds — their unique raid contribution beyond DPS.

**Number of cache spots visible:**
| Gleaning Level | Cache spots in aftermath |
|---------------|------------------------|
| 47–62 | 3–4 spots |
| 63–79 | 5–6 spots |
| 80–100 | 7–9 spots |

---

### Scavenger's Edge (Gleaning 54) — Passive, No Active Attunement

Scavenger's Edge is a passive proc — no player input required. After any combat encounter (zone, dungeon, or raid) there is a 15% chance a bonus Gleaning item drops automatically.

```
hasAttunement = false  // Passive only — no tap window
```

This rolls separately from the main combat loot table — it's additive. The Gleaning talent level affects what quality the bonus item is:

| Gleaning Level | Bonus item quality |
|---------------|-------------------|
| 54–69 | Crude–Rough tier material from current zone pool |
| 70–84 | Rough–Refined tier material |
| 85–100 | Refined–Pristine tier material |

**Visual feedback:** A small "scavenge!" icon briefly appears near the loot drop — distinguishes it from regular combat loot. No window to tap — it just appears.

---

Warfare attunement uses two independent checks at combo resolution — mirrors Spellcasting's structure. No crit system, no weak points. Skill expression through combo speed and streak maintenance.

---

### Warfare Attunement Fields

```
hasAttunement              true
isPlayerDriven             true  (combo-based, not cycle-based)
cycleLength                N/A   (player-driven input)
attunementWindowAt         0.0   (always active — player initiates)
attunementWindowDuration   N/A   (player-controlled)

// Speed Attunement — all inputs completed under threshold
speedAttunement_enabled    true
speedAttunement_threshold  1.0s  (all combo inputs entered under 1.0s)
speedAttunement_xpBonus    1.5   (+50% XP on fast combo)
speedAttunement_damageBonus 0.25 (+25% damage on that combo)
speedAttunement_cueLabel   "Fast combo!"

// Streak Attunement — unlocks at Warfare level 38
streakAttunement_enabled   false (locked until Warfare Lv 38)
streakAttunement_threshold 3     (3 unique combos in a row)
streakAttunement_lootBonus 0.10  (+10% drop chance while streak active)
streakAttunement_cueLabel  "Combo streak!"

// No crit system for Vanguard
// weakPointEnabled = false
// critChance = 0f
```

---

### Speed Tiers — Damage Modifiers

Speed affects damage on every combo. Attunement XP bonus only fires at Lightning tier.

| Speed | All inputs completed in | Damage Modifier | XP Attunement |
|-------|------------------------|----------------|--------------|
| **Lightning** | Under 1.0s | +25% damage | ✅ +50% XP |
| **Standard** | 1.0s – 2.5s | Base damage | ❌ No bonus |
| **Slow** | Over 2.5s or auto-fire | Base damage | ❌ No bonus |

No damage penalty for slow — idle auto-fire always deals standard damage.

---

### Streak Attunement — Unlocks at Warfare Level 38

| Streak Count | Bonus |
|-------------|-------|
| 3 unique combos | +10% damage on next combo |
| 5 unique combos | +20% damage + 5% loot bonus |
| 10 unique combos | +30% damage + 10% loot bonus + visual indicator |

**Streak breaks on:**
- Repeating a combo sequence
- Taking heavy damage (>30% max HP in one hit)
- Idle auto-combat taking over

Streak does not build during idle — active play only.

---

### Per-Grimoire Attunement Behavior

| Grimoire | Speed threshold | Streak unlock | Key attunement moment |
|---------|----------------|--------------|----------------------|
| **Warlord** | 1.0s | Warfare Lv 38 | G→G→U (Fortress Surge) fast = massive taunt spike |
| **Shadowblade** | 1.0s | Warfare Lv 38 | U→U→S (Void Assassin) fast from stealth = peak burst |
| **Kensei (DLC)** | 0.8s (tighter) | Warfare Lv 35 | Focus mechanic adds third attunement layer — designed at DLC phase |

Kensei's tighter threshold (0.8s vs 1.0s) reflects the samurai discipline fantasy — precision timing is more demanding.

---

### Idle Behavior

| Warfare Level | Auto-Combat |
|--------------|------------|
| 1–71 | Auto-fires single Strike at base damage, Standard speed tier |
| 72–100 | Auto-fires last used 2-input combo at 70% potency |
| 100 (mastery) | Never retreats from Tier 3 zones or lower |

Streak never builds during idle. Speed attunement never fires during idle. Counter/combo bonuses apply at 70% potency if the idle combo qualifies.

---

### Visual & Audio Feedback

**Speed Attunement (Lightning combo):**
- Visual: brief motion blur trail on the weapon swing — appears only at Lightning tier
- Audio: sharp metallic ring — distinct from standard hit sound
- Feedback text: "Fast combo!" floats above player

**Streak Attunement:**
- Visual: streak counter badge visible near combo queue — glows brighter at each tier
- Audio: ascending tone series as streak builds — distinctive chime at 3, 5, 10
- Feedback text: "Combo streak x3!" / "x5!" / "x10!"
- Visual indicator at streak 10: weapon trails a subtle glow for the duration

**Both firing together:**
- Most satisfying active play moment for Vanguard
- Lightning combo during an active streak — both feedback layers play simultaneously

---

### No Crit System — Vanguard

```csharp
// In CombatManager:
if (currentGrimoire.path == GrimoirePath.Vanguard) {
    critChance = 0f;
    weakPointEnabled = false;
}
// Marksmanship weak point system unaffected — Warden path only
// Vanguard skill expression = combo speed + streak maintenance
```

---
*Document version 0.4 — Phase 2 Attunement Data Spec*
*Key change: Spellcasting removed as shared Talent — attunement data now lives on each Arcanist Grimoire's Combat Progression*
*Added: Warfare attunement (all Vanguard Grimoires), Gleaning Phase 2 contexts, Cultivation tiered attunement, Tracking tiered attunement*
*Next: Combat XP curve · Phase 2 handoff*
