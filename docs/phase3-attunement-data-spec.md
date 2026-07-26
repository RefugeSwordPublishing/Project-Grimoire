---
type: design-spec
version: 1.0
updated: 2026-07-25
path: docs/phase3-attunement-data-spec.md
companion: attunement-data-spec.md, phase2-attunement-data-spec.md
---

# Project Grimoire, Phase 3 Attunement Data Spec
### Version 1.0

---

## Core Attunement Rule (unchanged)

**Attunement windows NEVER gate content.** Idle players always receive base yield.
Active players who hit the window receive a bonus on top.

```
Idle player:   base yield
Active player: base yield + attunement bonus
```

Every entry in this document follows this rule without exception. If any
attunement reads as "requires active play to get X at all", that is wrong.

---

## What Phase 3 Adds

Phase 3 unlocks talent tiers and zone contexts that did not exist in Phases 1 and 2.
This document covers only the new behavior. All existing attunement data in
`attunement-data-spec.md` and `phase2-attunement-data-spec.md` remains unchanged.

New attunement behavior in this phase:

- Felling: Voidtimber tier (already in Phase 2 tables at level 84, now actively reachable)
- Delving: Gold, Mithril, and Adamantine ore tiers (reachable in T3-T4 zones)
- Trapping: Shadow Snare and Drake Trap (Shadow Pelt, Drake Scale sources)
- Tanning: Tiered attunement by leather grade (Wolf Leather, Direwolf Leather)
- Smelting: New talent, full attunement design needed
- Dredging: T3 aquatic content (Dragon Eel unlock range)
- Combat: Zone-specific attunement events for Dreadhollow and Cinderpeak
- Gleaning: T3 dungeon cache content (Gravenspire, Ignarath's Maw)

---

## Felling, Phase 3 Tier Behavior

No new entries needed. The Voidtimber (level 84) and Worldtree Shard (level 89)
attunement rows are already defined in phase2-attunement-data-spec.md. Phase 3
is when these tiers become reachable for most players.

One addition: Voidtimber trees appear in the Dreadhollow zone (Zone 3A).
They use the Enchanted Grove irregular cycle mechanic defined in Phase 2,
but with void corruption effects replacing the arcane pulse:

```
voidtimber_irregularCycle  = true
voidtimber_cycleVariance   = +-0.5s (wider variance than Magicwood, void timing is erratic)
voidtimber_windowDuration  = 0.6s
voidtimber_yieldBonus      = +1 Voidtimber Log
voidtimber_rareBonus       = +18% rare drop (matches Phase 2 spec)
voidtimber_cueLabel        = "Void resonates!"
voidtimber_irregularNote   = "Void corruption makes the timing less predictable than
                              Magicwood. Player cannot rely on rhythm, must watch the
                              void pulse visual on the tree trunk."
```

---

## Delving, Phase 3 Tier Behavior

Gold, Mithril, and Adamantine tiers are defined in the Phase 2 spec tables.
Phase 3 is when these become the primary Delving grades in T3-T4 zones.

No new attunement rows needed. Implementation note for Claude Code:
the existing tier table must be applied to T3 zone ore nodes:

| Node placement | Zone | Ore tier active |
|---------------|------|----------------|
| Zone T1 nodes | Grimwood, Saltmarsh | Copper/Tin, Iron |
| Zone T2 nodes | Ashfen, Ironspine | Iron, Silver/Coal |
| Zone T3 nodes | Dreadhollow, Cinderpeak | Gold, Mithril (rare) |
| Zone T4 nodes | Veilborn, Shattered Citadel | Mithril, Adamantine |
| Zone T5 nodes | Ashenwold, Elder Reaches | Adamantine, Starstone, Soulite |

**Dreadhollow specific:** Coal seams are the primary fuel node in this zone,
supporting the Steel Bar production pipeline. Coal uses the Silver/Coal attunement
row (Delving 33, 1.1s window, +2 ore, +8% gem).

**Cinderpeak specific:** Mithril Ore nodes first appear here as rare spawns.
Attunement uses the Mithril row (Delving 64, 0.7s window, +1 ore, +12% gem).
Ember deposits (non-ore) also appear in Cinderpeak and feed Alchemy reagents.
Ember is gathered passively via Foraging, not Delving.

### Delving, Lava Cave Context (Cinderpeak dungeon, Ignarath's Maw)

Ore nodes inside Ignarath's Maw behave differently from zone nodes. Active heat
from the volcanic environment accelerates the vein pulse cycle.

```
lavaCave_cycleLength       = 3.5s (faster than standard 4.5-6.0s zone cycles)
lavaCave_windowDuration    = 0.8s
lavaCave_yieldBonus        = +2 ore
lavaCave_gemBonus          = +15% gem drop
lavaCave_cueLabel          = "Hot vein, tap now!"
lavaCave_note              = "Dungeon nodes pulse faster due to thermal pressure.
                              Players accustomed to zone timing will find these
                              slightly more demanding. Still additive — idle players
                              still gather from dungeon nodes at base rate."
```

---

## Trapping, Phase 3 Tier Behavior

Shadow Snare (Trapping 67) and Drake Trap (Trapping 82) are defined in the
Phase 2 spec tables. Phase 3 is when the creatures they target appear in zones.

**Shadow Snare activation in Dreadhollow (Zone 3A):**
Shadow Pelt drops from Shadow-type enemies and is the source material for
Shadow Essence (Vestments T4 chain). Shadow Snares activate at night as designed.
No new attunement data needed. Confirm Shadow-type enemies in Dreadhollow's
enemy roster count as valid Shadow Snare targets (Void Shade, Void Stalker).

```
shadowSnareTarget_tags = ["[Void]", "[Undead]"]  // Dreadhollow enemy tags
shadowSnareTarget_note = "Void Shades and Void Stalkers are valid Shadow Snare
                          targets in Dreadhollow. Shadow Pelt is the primary
                          rare drop for this snare type in T3 zones."
```

**Drake Trap activation in Cinderpeak (Zone 3B):**
Drake Scale (Drake Leather) drops from Cinderpeak Drake and Drake Pack Alpha.
Drake Trap is the primary active-play tool for boosting Drake Scale drop rates.

```
drakeTrap_windowDuration   = 0.6s   (as per Phase 2 spec)
drakeTrap_catchBonus       = +35%
drakeTrap_qualityBonus     = Drake Scale chance (as per Phase 2 spec)
drakeTrap_cueLabel         = "Drake holds!"
drakeTrap_T3note           = "Cinderpeak Drake and Drake Pack Alpha both respond
                              to Drake Trap. Highland Wyvern does not — different
                              creature family. Wyvern Hide drops from standard
                              combat loot table only."
```

---

## Tanning, Phase 3 Tiered Attunement

Tanning had no tiered attunement in Phases 1 or 2. Phase 3 introduces it because
Wolf Leather and Direwolf Leather are high-value T3-T4 materials with their own
craft complexity.

Tanning attunement is timing-based: a stretching cue fires when the hide reaches
optimal tension on the frame. The window tightens as hide thickness and toughness
increase. Hitting the window produces a cleaner cure with bonus output.

### Tanning, Tiered Attunement by Hide Grade

| Hide Grade | Leather Output | Tanning Level | Window Duration | Yield Bonus | Quality Bonus | Cue Label |
|-----------|---------------|--------------|----------------|------------|--------------|----------|
| Rabbit Pelt | Rabbit Hide | 1 | 2.0s | +1 Rabbit Hide | none | "Stretch it!" |
| Fox Fur | Fox Leather | 20 | 1.5s | +1 Fox Leather | none | "Even pull!" |
| Wolf Pelt | Wolf Leather | 40 | 1.2s | +1 Wolf Leather | +5% rare component | "Hold tension!" |
| Direwolf Hide | Direwolf Leather | 65 | 0.9s | +1 Direwolf Leather | +10% rare component | "Direwolf fights back!" |
| Shadow Pelt | Shadow Leather | 70 | 0.8s | +1 Shadow Leather | +Shadow Essence chance | "Feel the shadow!" |
| Drake Scale | Drake Leather | 88 | n/a | direct drop, no Tanning | n/a | n/a |

Drake Scale does not go through Tanning and has no attunement window. It arrives
as Drake Leather already. Shadow Pelt does pass through Tanning and gets an
attunement window that adds a chance of Shadow Essence as a byproduct.

### Tanning Attunement Data Fields (base, applies to all grades)

```
hasAttunement              true
isPlayerDriven             false   (cycle-based, not player-initiated)
cycleLength                varies by hide grade (see below)
attunementWindowAt         0.45    (window opens at 45% through the cure cycle)
attunementCue              "Stretching cue" — hide visually tightens on frame

// Idle behavior: base output always produced regardless of attunement
// Active attunement: bonus output on top of base
```

### Tanning Cycle Lengths by Hide Grade

| Hide Grade | Cure Cycle Length | Notes |
|-----------|------------------|-------|
| Rabbit Pelt | 12.0s | Shortest — thin, pliable hide |
| Fox Fur | 18.0s | Medium — denser fur layer |
| Wolf Pelt | 25.0s | Long — thick pelt requires longer cure |
| Direwolf Hide | 35.0s | Very long — hide actively resists curing |
| Shadow Pelt | 40.0s | Longest — supernatural resistance to process |

Cycle lengths match Tanning's role as a mid-tier processing talent. Long cycles
create a steady rhythm of attunement windows rather than rapid-fire tapping.

### Tanning, Level 100 Capstone Interaction

At Tanning 100: "Wolf and higher grade hides cure in half the time."
Cycle lengths for Wolf Pelt, Direwolf Hide, and Shadow Pelt halve:

```csharp
float cycleLength = (tanning100Unlocked && hideGrade >= HideGrade.Wolf)
    ? baseCycleLength * 0.5f
    : baseCycleLength;
```

Attunement window duration stays the same. Faster cycle means more opportunities
per session, not an easier window. High-level Tanners benefit from volume.

---

## Smelting, Full Attunement Design (new talent)

Smelting is a new processing talent with no existing attunement data.
Full design from scratch.

### Smelting Attunement Concept

Smelting attunement fires when molten metal reaches optimal pour temperature.
A heat gauge fills during the smelt cycle. The attunement window opens when the
gauge reaches the ideal zone — too early and the metal is unset, too late and
it loses refinement. Player taps when the gauge is in the marked zone.

This is visually distinct from all other attunement types: a vertical heat gauge
rather than a position-on-cycle indicator. Same feel (timing-based tap) but
different visual metaphor appropriate to the forge setting.

```
attunementCue     = "Heat gauge enters optimal zone — vertical bar fills,
                     a glowing band marks the target range, player taps within it"
attunementWindowAt = dynamic (not a fixed 0.40 position — gauge fills at variable
                     speed depending on Forge quality; higher Forge = more
                     consistent fill rate = easier to predict window)
```

### Smelting, Tiered Attunement by Bar Type

| Bar Type | Smelting Level | Window Duration | Yield Bonus | Quality Note | Cue Label |
|---------|--------------|----------------|------------|-------------|----------|
| Copper/Tin Bar | 1 | 2.0s | +1 bar | none | "Pour now!" |
| Bronze Bar | 5 | 1.8s | +1 bar | none | "Alloy set!" |
| Iron Bar | 10 | 1.5s | +1 bar | none | "Strike the heat!" |
| Steel Bar | 30 | 1.2s | +1 bar | +5% bar quality | "Perfect alloy!" |
| Mithril Bar | 60 | 0.9s | +1 bar | +8% quality | "Mithril sings!" |
| Void Alloy | 85 | 0.6s | +1 alloy | +void property | "Void locks in!" |

Yield bonus is always one extra bar of the type being smelted. For alloys (Bronze,
Steel, Void), the bonus bar is the alloy output, not a raw input.

### Smelting Attunement Data Fields

```
hasAttunement              true
isPlayerDriven             false   (cycle-based)
cycleLength                varies by bar type (see below)
attunementWindowAt         dynamic (gauge-based, not fixed position)
attunementCueType          "HeatGauge"   (new cue type, not "pulse" or "crack")
attunementWindowDuration   varies by bar type (see table above)

// Gauge behavior:
forgeQualityEffect         Higher Forge quality = more consistent gauge fill rate.
                           Crude Forge: gauge fills unevenly, window harder to predict.
                           Masterwork Forge: gauge fills steadily, window predictable.
                           (All still additive — idle always produces base bar.)
```

### Smelting Cycle Lengths

| Bar Type | Smelt Cycle Length |
|---------|------------------|
| Copper/Tin Bar | 30s |
| Bronze Bar | 45s |
| Iron Bar | 45s |
| Steel Bar | 90s (two-step alloy, longer process) |
| Mithril Bar | 120s |
| Void Alloy | 180s |

These match the recipe processing times defined in material-economy.md.
The attunement window fires once per cycle at the optimal pour moment.

### Smelting, Forge Quality Effect on Window Predictability

| Forge Quality | Gauge fill variance | Window difficulty |
|--------------|--------------------|--------------------|
| Crude | +-0.6s variance | Hard to predict — gauge speed uneven |
| Rough | +-0.4s variance | Moderate |
| Refined | +-0.25s variance | Manageable |
| Pristine | +-0.15s variance | Consistent |
| Masterwork | +-0.05s variance | Nearly perfectly predictable |

The Forge quality effect is the primary reason to upgrade the Forge tool beyond
the idle speed gain. A Masterwork Forge Smelter can predict the window reliably,
while a Crude Forge Smelter must react to it. Both get the base yield; the
Masterwork user just hits the bonus more often.

### Smelting Idle Behavior

```
Idle smelt:    base yield (1 bar per cycle, as specified in recipe)
Active smelt:  base yield + bonus bar if attunement hit
Idle note:     Forge quality still affects idle cycle speed even without attunement.
               Higher Forge = faster bar production for idle players too.
               This is the additive rule applied to tools: quality improves
               both idle floor and active ceiling.
```

### Smelting, Level 100 Capstone Interaction

At Smelting 100: "Double bar chance on every attunement hit."
The yield bonus bar becomes a double: on attunement hit, 2 bonus bars instead of 1.

```csharp
int bonusBars = attunementHit
    ? (smelting100Unlocked ? 2 : 1)
    : 0;
```

---

## Dredging, Phase 3 Tier Behavior

Dragon Eel (Dredging), Dragon Eel Oil, and Void Kraken Ink are Phase 3 materials.
The existing Dredging attunement structure applies, but these species have distinct
catch behavior.

### Dredging, Dragon Eel Context (T3 waters)

Dragon Eels are fast and aggressive. The dredging cue fires earlier in the cycle
than standard fish species, and the window is tighter.

```
dragonEel_cycleLength      = 20.0s  (longer — Eel makes more runs before bite)
dragonEel_windowAt         = 0.35   (earlier in cycle — eel strikes fast)
dragonEel_windowDuration   = 0.8s   (tighter than standard 1.0-1.5s)
dragonEel_yieldBonus       = +1 Dragon Eel
dragonEel_rareBonus        = +15% Dragon Eel Oil drop
dragonEel_cueLabel         = "Eel strikes — now!"
dragonEel_unlockLevel      = Dredging 42 (required to fish Saltmarsh-adjacent deep water)
```

**Idle behavior:** Dragon Eels are catchable during idle at base rate. Active
attunement adds one bonus Eel and Dragon Eel Oil drop chance.

### Dredging, Void Kraken Ink (T3 rare drop)

Void Kraken Ink does not drop from catching a Kraken. It is a rare ambient drop
from the water itself in T3 coastal zones — the Kraken presence taints the water.
No separate attunement event; it drops from the standard Dredging loot table at
a low rate (2%, as per enemy-zone-tables.md Phase 2 Dredging entries).

---

## Combat Attunement, Zone-Specific Events (Phase 3)

Zone-specific combat attunement events fire during the active combat loop in
Phase 3 zones. These supplement the standard combat XP attunement and weak
point mechanics with zone-flavored events.

### Dreadhollow (Zone 3A), Void Pulse Event

The void energy in Dreadhollow occasionally surges, creating a brief window
where all enemies take increased damage and void-type weaknesses are amplified.

```
voidPulse_trigger          = Random, every 4-7 combat encounters in zone
voidPulse_windowDuration   = 4.0s
voidPulse_damageBonus      = +20% to all damage dealt during window
voidPulse_voidBonus        = +35% to void-type damage specifically
voidPulse_cueLabel         = "Void surges!"
voidPulse_cueVisual        = Purple energy ripple across the combat scene background
voidPulse_idleBehavior     = Idle combat auto-attacks during Void Pulse still deal
                             +10% bonus damage passively (additive, no tap required)
voidPulse_activeBehavior   = Active player who taps within window deals full +20% bonus
```

**Design intent:** Rewards players who are watching the zone. The passive idle
bonus (+10%) keeps idle players benefiting; active players who react to the cue
get double the passive amount.

### Cinderpeak (Zone 3B), Thermal Vent Burst

Thermal vents in Cinderpeak occasionally rupture, sending ash and heat across
the combat area. Fire-resistant players and those with fire-coating active gain
a damage bonus while non-resistant enemies are briefly staggered.

```
thermalBurst_trigger       = Random, every 5-8 combat encounters in zone
thermalBurst_windowDuration = 3.0s
thermalBurst_damageBonus   = +15% to all damage during window
thermalBurst_fireBonus     = +30% to fire-damage coated weapons specifically
thermalBurst_cueLabel      = "Thermal burst!"
thermalBurst_cueVisual     = Heat haze and ash particle effect across combat backdrop
thermalBurst_idleBehavior  = Idle combat receives +8% passive bonus during burst
thermalBurst_activeBehavior = Active player tapping window receives full +15%
thermalBurst_coatingNote   = "Fire Coating (Alchemy) on active weapon doubles the
                              fire damage bonus to +30%. Synergy with Alchemy."
```

---

## Gleaning, Phase 3 Dungeon Cache Contents

Dungeon cache content scales with dungeon tier. Gravenspire and Ignarath's Maw
are Tier 3 dungeons. The Phase 2 cache table already defines this:

> Tier 3+: Refined-Pristine rare materials, rare Assembly components.

No new attunement data needed. Confirm the dungeon cache loot tables for
Gravenspire and Ignarath's Maw populate from the Refined-Pristine rare material
pool (Refined Phantom Pelt, Refined Void Spore, Refined Amber, Refined Gemstone,
Refined Ancient Sigil, Refined Runic Cog).

Cache spot count at Gleaning 63+ (as per Phase 2 spec): 5-6 spots per dungeon run.

---

## Implementation Notes for Claude Code

### New TalentActivity ScriptableObjects needed

| Talent | New entries | Notes |
|--------|------------|-------|
| Tanning | One entry per hide grade (5 entries) | New talent attunement, no existing data |
| Smelting | One entry per bar type (7 entries) | New talent, full attunement needed |
| Smelting | HeatGauge cue type | New cue visual type, not "pulse" or "crack" |

### Smelting HeatGauge cue type

```csharp
public enum AttunementCueType {
    Pulse,       // existing — visual pulse on object
    Crack,       // existing — sound + visual crack
    Shimmer,     // existing — glint on surface
    HeatGauge,   // NEW — vertical gauge fills, tap when in target band
    Placement,   // existing — spatial drag to zone (Trapping)
}

// HeatGauge implementation:
public class HeatGaugeAttunement : MonoBehaviour {
    [Range(0f, 1f)] public float targetBandMin = 0.65f;
    [Range(0f, 1f)] public float targetBandMax = 0.80f;
    public float fillVariance; // set by Forge quality at runtime

    void Update() {
        float gaugeValue = GetCurrentGaugeFill(); // rises during smelt cycle
        bool inWindow = gaugeValue >= targetBandMin && gaugeValue <= targetBandMax;
        if (inWindow && !windowFired) {
            TriggerAttunementWindow();
            windowFired = true;
        }
    }
}
```

### Tanning cue type

Tanning uses the existing Pulse cue type. Visual: the hide on the tanning frame
visibly tightens (texture change + subtle sound) at the attunement position.

```csharp
// TanningManager.cs additions:
TalentActivity[] tanningActivities = {
    // Rabbit Pelt -> Rabbit Hide
    new TalentActivity {
        activityId         = "tan_rabbit_hide",
        cycleLength        = 12.0f,
        attunementWindowAt = 0.45f,
        attunementWindowDuration = 2.0f,
        attunementCueType  = AttunementCueType.Pulse,
        attunementCueLabel = "Stretch it!",
        attunementYieldBonus = 1,
        idleYield          = 1,  // base always produced
    },
    // Fox Fur -> Fox Leather
    new TalentActivity {
        activityId         = "tan_fox_leather",
        cycleLength        = 18.0f,
        attunementWindowAt = 0.45f,
        attunementWindowDuration = 1.5f,
        attunementCueLabel = "Even pull!",
        attunementYieldBonus = 1,
        idleYield          = 1,
    },
    // Wolf Pelt -> Wolf Leather
    new TalentActivity {
        activityId         = "tan_wolf_leather",
        cycleLength        = 25.0f,
        attunementWindowAt = 0.45f,
        attunementWindowDuration = 1.2f,
        attunementCueLabel = "Hold tension!",
        attunementYieldBonus = 1,
        attunementRareBonus = 0.05f,
        idleYield          = 1,
    },
    // Direwolf Hide -> Direwolf Leather
    new TalentActivity {
        activityId         = "tan_direwolf_leather",
        cycleLength        = 35.0f,
        attunementWindowAt = 0.45f,
        attunementWindowDuration = 0.9f,
        attunementCueLabel = "Direwolf fights back!",
        attunementYieldBonus = 1,
        attunementRareBonus = 0.10f,
        idleYield          = 1,
    },
    // Shadow Pelt -> Shadow Leather
    new TalentActivity {
        activityId         = "tan_shadow_leather",
        cycleLength        = 40.0f,
        attunementWindowAt = 0.45f,
        attunementWindowDuration = 0.8f,
        attunementCueLabel = "Feel the shadow!",
        attunementYieldBonus = 1,
        attunementSpecial  = "ShadowEssenceChance_0.12",  // 12% Shadow Essence byproduct
        idleYield          = 1,
    },
};
```

---

*Phase 3 Attunement Data Spec, v1.0*
*Path: docs/phase3-attunement-data-spec.md*
*Adds: Tanning tiered attunement (new), Smelting full attunement design (new talent),*
*Voidtimber Felling zone context, Delving T3 node placement, Dredging Dragon Eel context,*
*Combat zone events (Void Pulse, Thermal Vent Burst), Gleaning T3 dungeon cache confirmation.*
