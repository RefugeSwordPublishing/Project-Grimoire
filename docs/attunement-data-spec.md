# ⚔️ Project Grimoire — Attunement Window Data Spec
### Version 0.1 — Phase 1 Talents

---

## 📐 Design Principles

- **Window position (attunementWindowAt):** Opens after the action is clearly telegraphed — never before the player has visual context
- **Window duration:** 1.5–3.0 seconds on mobile — achievable but not trivial. Combat is tighter than gathering
- **XP bonus:** +50% baseline across all gathering/processing talents (Attunement Surge spec)
- **Loot/yield bonus:** Varies by talent — gathering gets extra resource yield roll, combat gets rare drop chance boost
- **Idle fallback:** hasAttunement = false activities run at base rate with no penalty — never punished for not engaging
- **Cycle length:** The full action cycle duration in seconds. Window opens at `cycleLength × attunementWindowAt`

---

## 🌿 GATHERING TALENTS

### Foraging
**Mechanic:** Two or more plant nodes appear briefly. Tap the glowing one (rarer quality) for the bonus.
**Cue:** Subtle golden shimmer on one node among others

| Field | Value |
|-------|-------|
| `hasAttunement` | true |
| `attunementCueLabel` | "Rare plant — tap it!" |
| `attunementWindowAt` | 0.45 |
| `attunementWindowDuration` | 2.5 |
| `attunementXPBonus` | 1.5 |
| `attunementLootBonus` | 0.0 |
| `attunementYieldBonus` | 1 (extra resource of higher quality tier) |
| `cycleLength` | 6.0 seconds |

**Notes:** Window opens near the midpoint — player has time to see the choice. Bonus is quality upgrade on output, not extra quantity. Missing the window yields standard quality harvest.

---

### Felling
**Mechanic:** A bark crack visual appears on the tree sprite. Tap in rhythm with it.
**Cue:** Crack line appears on tree, brief audio bark crack SFX

| Field | Value |
|-------|-------|
| `hasAttunement` | true |
| `attunementCueLabel` | "Strike the crack!" |
| `attunementWindowAt` | 0.70 |
| `attunementWindowDuration` | 1.8 |
| `attunementXPBonus` | 1.5 |
| `attunementLootBonus` | 0.0 |
| `attunementYieldBonus` | 2 (extra timber logs) |
| `cycleLength` | 5.0 seconds |

**Notes:** Window opens late in the cycle — the axe is mid-swing, crack appears at impact point. Tighter window than Foraging to reflect the rhythm-timing nature. Bonus is extra timber yield, occasionally rare wood type.

---

### Delving
**Mechanic:** A vein on the rock sprite glows briefly. Tap to strike it.
**Cue:** Glowing highlight on ore vein, pulsing

| Field | Value |
|-------|-------|
| `hasAttunement` | true |
| `attunementCueLabel` | "Tap the glowing vein!" |
| `attunementWindowAt` | 0.60 |
| `attunementWindowDuration` | 2.0 |
| `attunementXPBonus` | 1.5 |
| `attunementLootBonus` | 0.12 |
| `attunementYieldBonus` | 1 (extra ore) |
| `cycleLength` | 6.0 seconds |

**Notes:** Loot bonus here represents gem drop chance increase — Delving is the primary gem source so this is meaningful. Window mid-late to give player time to identify the glowing vein before it fades.

---

### Trapping
**Mechanic:** Terrain highlights briefly showing optimal placement zones. Tap the highlighted zone to place the trap.
**Cue:** Ground zone glows briefly showing best trap placement

| Field | Value |
|-------|-------|
| `hasAttunement` | true |
| `attunementCueLabel` | "Optimal spot!" |
| `attunementWindowAt` | 0.30 |
| `attunementWindowDuration` | 2.5 |
| `attunementXPBonus` | 1.5 |
| `attunementLootBonus` | 0.20 |
| `attunementYieldBonus` | 0 |
| `cycleLength` | 8.0 seconds (traps take longer to set) |

**Notes:** Window opens early — placement decision happens at the start of the trap-setting action. Loot bonus is catch rate improvement (higher chance of catching the rarer creature in the zone). Longer cycle since trapping is a slower talent.

---

### Dredging
**Mechanic:** Line tension arc appears. Hold tap in the sweet spot zone.
**Cue:** Tension arc with a green sweet spot band

| Field | Value |
|-------|-------|
| `hasAttunement` | true |
| `attunementCueLabel` | "Hold the tension!" |
| `attunementWindowAt` | 0.50 |
| `attunementWindowDuration` | 3.0 |
| `attunementXPBonus` | 1.5 |
| `attunementLootBonus` | 0.25 |
| `attunementYieldBonus` | 0 |
| `cycleLength` | 7.0 seconds |

**Notes:** Dredging is hold-based rather than tap-based — player holds their thumb in the sweet spot zone. Longest window of any gathering talent because fishing requires sustained engagement. Loot bonus is rare fish upgrade — higher chance of catching a rarer fish species than the zone's common catch.

---

### Gleaning
**Mechanic:** Hidden cache icon flickers briefly on the scavenge scene. Tap it before it fades.
**Cue:** Faint glint/shimmer on a specific area of the scene

| Field | Value |
|-------|-------|
| `hasAttunement` | true |
| `attunementCueLabel` | "Hidden cache — tap it!" |
| `attunementWindowAt` | 0.55 |
| `attunementWindowDuration` | 1.5 |
| `attunementXPBonus` | 1.5 |
| `attunementLootBonus` | 0.35 |
| `attunementYieldBonus` | 1 |
| `cycleLength` | 7.0 seconds |

**Notes:** Tightest window of all gathering talents — Gleaning rewards sharp eyes. High loot bonus because finding hidden caches is Gleaning's core fantasy. Missing it means the cache stays hidden (standard yield only).

---

### Cultivation
**Mechanic:** A watering/pruning prompt appears over a specific crop. Tap to tend it.
**Cue:** Crop icon pulses with a subtle glow

| Field | Value |
|-------|-------|
| `hasAttunement` | true |
| `attunementCueLabel` | "Tend the crop!" |
| `attunementWindowAt` | 0.40 |
| `attunementWindowDuration` | 3.0 |
| `attunementXPBonus` | 1.5 |
| `attunementLootBonus` | 0.0 |
| `attunementYieldBonus` | 2 |
| `cycleLength` | 12.0 seconds (growth cycle is slow) |

**Notes:** Cultivation has the longest cycle of any Phase 1 talent — crops take time. Generous window duration reflects the gentle nature of farming. Bonus is extra crop yield. No loot bonus since Cultivation doesn't produce rare drops.

---

### Tracking
**Mechanic:** Trail indicators appear on screen briefly. Tap to follow correctly.
**Cue:** Footprint or broken branch icon appears, fades quickly

| Field | Value |
|-------|-------|
| `hasAttunement` | true |
| `attunementCueLabel` | "Follow the trail!" |
| `attunementWindowAt` | 0.35 |
| `attunementWindowDuration` | 2.0 |
| `attunementXPBonus` | 1.5 |
| `attunementLootBonus` | 0.30 |
| `attunementYieldBonus` | 0 |
| `cycleLength` | 8.0 seconds |

**Notes:** Tracking's attunement bonus is node reveal quality — successfully following the trail reveals a rarer creature location or hidden resource node. Loot bonus represents the quality of what's found.

---

## ⚙️ PROCESSING TALENTS

### Alchemy
**Mechanic:** Stir timing — a rotating indicator reaches a target zone. Tap when it hits.
**Cue:** Rotating stir indicator with a highlighted sweet spot

| Field | Value |
|-------|-------|
| `hasAttunement` | true |
| `attunementCueLabel` | "Stir now!" |
| `attunementWindowAt` | 0.65 |
| `attunementWindowDuration` | 1.5 |
| `attunementXPBonus` | 1.5 |
| `attunementLootBonus` | 0.0 |
| `attunementYieldBonus` | 1 (extra potion output) |
| `cycleLength` | 8.0 seconds |

**Notes:** Tighter window — brewing requires precision. Bonus is +1 extra output per batch (e.g. brew 3 potions instead of 2). This is the most economically impactful gathering attunement since potions are high-value Exchange items.

---

### Cookery
**Mechanic:** Heat management — a temperature gauge must be kept in the green zone by tapping.
**Cue:** Temperature gauge appears, red zone on either side of green

| Field | Value |
|-------|-------|
| `hasAttunement` | true |
| `attunementCueLabel` | "Right temperature!" |
| `attunementWindowAt` | 0.50 |
| `attunementWindowDuration` | 2.5 |
| `attunementXPBonus` | 1.5 |
| `attunementLootBonus` | 0.0 |
| `attunementYieldBonus` | 1 (extra meal portion or quality upgrade) |
| `cycleLength` | 9.0 seconds |

**Notes:** Hold-based like Dredging — player taps to keep temperature in range rather than a single tap moment. Bonus is either an extra portion or a quality upgrade on the meal (higher stat buff value). Quality upgrade is more valuable for dungeon provisioning.

---

### Tanning
**Mechanic:** Scraping rhythm — tap in time with a rhythm indicator.
**Cue:** Scraping motion indicator, rhythmic beat

| Field | Value |
|-------|-------|
| `hasAttunement` | true |
| `attunementCueLabel` | "Keep the rhythm!" |
| `attunementWindowAt` | 0.60 |
| `attunementWindowDuration` | 2.0 |
| `attunementXPBonus` | 1.5 |
| `attunementLootBonus` | 0.0 |
| `attunementYieldBonus` | 1 (extra leather strips) |
| `cycleLength` | 6.0 seconds |

**Notes:** Rhythm-based tap. Bonus is extra leather strip output — useful for crafters making large quantities of armor components.

---

### Smelting
**Mechanic:** Bellows timing — tap to pump bellows at the right moment to maintain optimal heat.
**Cue:** Heat gauge with a brief optimal zone indicator

| Field | Value |
|-------|-------|
| `hasAttunement` | true |
| `attunementCueLabel` | "Pump the bellows!" |
| `attunementWindowAt` | 0.55 |
| `attunementWindowDuration` | 2.0 |
| `attunementXPBonus` | 1.5 |
| `attunementLootBonus` | 0.0 |
| `attunementYieldBonus` | 1 (extra bar output) |
| `cycleLength` | 7.0 seconds |

**Notes:** Bonus is extra metal bar output per smelt — significant value for Runesmithing supply chains. Similar to Cookery in mechanic feel but shorter cycle.

---

### Timber Shaping
**Mechanic:** Grain tracing — a grain pattern appears briefly, tap to trace it correctly.
**Cue:** Wood grain line highlights on the timber sprite

| Field | Value |
|-------|-------|
| `hasAttunement` | true |
| `attunementCueLabel` | "Follow the grain!" |
| `attunementWindowAt` | 0.50 |
| `attunementWindowDuration` | 2.0 |
| `attunementXPBonus` | 1.5 |
| `attunementLootBonus` | 0.0 |
| `attunementYieldBonus` | 1 (extra plank output) |
| `cycleLength` | 6.0 seconds |

**Notes:** Bonus is extra plank output. Simple tap-to-confirm in Phase 1 — could be expanded to a drag/trace gesture in later polish pass.

---

### Runesmithing
**Mechanic:** Anvil strike timing — tap when the hammer indicator hits the glowing strike point.
**Cue:** Glowing point appears on anvil sprite, hammer descends

| Field | Value |
|-------|-------|
| `hasAttunement` | true |
| `attunementCueLabel` | "Strike the mark!" |
| `attunementWindowAt` | 0.75 |
| `attunementWindowDuration` | 1.5 |
| `attunementXPBonus` | 1.5 |
| `attunementLootBonus` | 0.0 |
| `attunementYieldBonus` | 0 |
| `attunementQualityBonus` | true |
| `cycleLength` | 8.0 seconds |

**Notes:** Tightest processing window — smithing requires real precision. Bonus is component quality upgrade (e.g. Standard → Fine quality component) which improves Assembly success rate at Workbench. No yield bonus — smithing makes one item at a time. Quality bonus is a unique field for Runesmithing only.

---

### Tailoring
**Mechanic:** Thread tension — tap to maintain consistent thread pull tension.
**Cue:** Tension indicator bar, keep needle in the right zone

| Field | Value |
|-------|-------|
| `hasAttunement` | true |
| `attunementCueLabel` | "Keep tension steady!" |
| `attunementWindowAt` | 0.50 |
| `attunementWindowDuration` | 2.5 |
| `attunementXPBonus` | 1.5 |
| `attunementLootBonus` | 0.0 |
| `attunementYieldBonus` | 0 |
| `attunementQualityBonus` | true |
| `cycleLength` | 7.0 seconds |

**Notes:** Quality bonus on armor output — better armor rating on the assembled piece. Hold-based mechanic similar to Cookery.

---

### Arcane Weaving
**Mechanic:** Mana thread alignment — drag threads into correct formation briefly shown.
**Cue:** Thread pattern appears, player aligns by tapping the correct node

| Field | Value |
|-------|-------|
| `hasAttunement` | true |
| `attunementCueLabel` | "Align the threads!" |
| `attunementWindowAt` | 0.55 |
| `attunementWindowDuration` | 2.0 |
| `attunementXPBonus` | 1.5 |
| `attunementLootBonus` | 0.0 |
| `attunementYieldBonus` | 0 |
| `attunementQualityBonus` | true |
| `cycleLength` | 9.0 seconds |

**Notes:** Quality bonus on woven output — higher magical potency. Most complex visual cue of all processing talents — could be simplified to tap-to-confirm in Phase 1 and expanded later.

---

### Artificing
**Mechanic:** Assembly sequence — components shown briefly in correct order, tap to confirm.
**Cue:** Component icons flash in sequence, tap to match

| Field | Value |
|-------|-------|
| `hasAttunement` | true |
| `attunementCueLabel` | "Connect in order!" |
| `attunementWindowAt` | 0.45 |
| `attunementWindowDuration` | 2.5 |
| `attunementXPBonus` | 1.5 |
| `attunementLootBonus` | 0.0 |
| `attunementYieldBonus` | 0 |
| `attunementQualityBonus` | true |
| `cycleLength` | 8.0 seconds |

**Notes:** Quality bonus — better device durability or function. Phase 1 simplify to tap-to-confirm, expand to sequence matching in later polish.

---

### Inscription
**Mechanic:** Calligraphy stroke — glyph path briefly highlighted, tap to trace.
**Cue:** Glyph outline glows on the scroll/parchment

| Field | Value |
|-------|-------|
| `hasAttunement` | true |
| `attunementCueLabel` | "Trace the glyph!" |
| `attunementWindowAt` | 0.60 |
| `attunementWindowDuration` | 2.0 |
| `attunementXPBonus` | 1.5 |
| `attunementLootBonus` | 0.0 |
| `attunementYieldBonus` | 1 (extra scroll charge or bonus copy) |
| `cycleLength` | 7.0 seconds |

**Notes:** Bonus is extra scroll charge on output — a Minor Enchant Scroll with 2 charges instead of 1, or an extra Zone Map copy. High Exchange value since scribes sell their output.

---

## ⚔️ COMBAT TALENTS

### Marksmanship (Bowstring)
**Mechanic:** Full Bowstring mechanic — press/drag to draw, aim at weak point, release.
**Cue:** Weak point glows subtly on enemy sprite when draw begins

| Field | Value |
|-------|-------|
| `hasAttunement` | true |
| `attunementCueLabel` | "Aim for the weak point!" |
| `attunementWindowAt` | 0.0 (always active during combat — player initiates) |
| `attunementWindowDuration` | N/A (player-controlled, not timed) |
| `attunementXPBonus` | 1.5 (body hit) / 2.0 (weak point crit) |
| `attunementLootBonus` | 0.35 (weak point crit) / 0.10 (body hit) |
| `attunementYieldBonus` | 0 |
| `cycleLength` | N/A (player-driven, not cycle-based) |

**Notes:** Marksmanship/Bowstring attunement is fundamentally different from other talents — it's not a timed window but a skill-based active system. The Bowstring mechanic IS the attunement. Idle auto-combat fires at mid-draw baseline (no attunement bonus). Active play always has the attunement opportunity.

> **Implementation note:** Marksmanship no longer exists as a shared Talent. This attunement data applies to each Warden Grimoire's Combat Progression independently. XP bonuses feed the equipped Grimoire's combat level, not a shared Talent.

**Sharpshot-specific:** Weak point glow duration = 3.0 seconds (longer window, rewards patience)
**Lone Wanderer-specific:** Weak point glow duration = 1.5 seconds (shorter window, rewards speed)

---

### Slaying
**Mechanic:** Finishing blow — when enemy drops below 20% HP, a tap prompt appears for bonus kill XP.
**Cue:** Enemy flashes red, "Finish!" prompt appears

| Field | Value |
|-------|-------|
| `hasAttunement` | true |
| `attunementCueLabel` | "Finishing blow!" |
| `attunementWindowAt` | 0.0 (triggers on enemy HP threshold, not cycle) |
| `attunementWindowDuration` | 2.0 |
| `attunementXPBonus` | 1.8 (higher bonus — rewards active combat awareness) |
| `attunementLootBonus` | 0.20 |
| `attunementYieldBonus` | 0 |
| `cycleLength` | N/A (HP-triggered, not cycle-based) |

**Notes:** Slaying attunement is HP-threshold triggered rather than cycle-based. Works during idle. Slaying XP feeds the currently equipped Grimoire's combat level — not a separate Slaying Talent level. Zone access is gated by Total Combat Level (sum of all owned Grimoire levels), not Slaying level.

---

## 📊 Summary Table — All Phase 1 Talents

| Talent | Window Position | Duration | XP Bonus | Loot Bonus | Yield Bonus | Quality Bonus |
|--------|----------------|----------|----------|-----------|------------|--------------|
| Foraging | 0.45 | 1.2s | +50% | — | +1 quality | — |
| Felling | 0.70 | 0.9s | +50% | — | +2 timber | — |
| Delving | 0.60 | 1.0s | +50% | +12% gem | +1 ore | — |
| Trapping | 0.30 | 1.0s | +50% | +20% catch | — | — |
| Dredging | 0.50 | 1.5s | +50% | +25% rare fish | — | — |
| Gleaning | 0.55 | 0.8s | +50% | +35% find | +1 | — |
| Cultivation | 0.40 | 1.5s | +50% | — | +2 crop | — |
| Tracking | 0.35 | 1.0s | +50% | +30% node | — | — |
| Alchemy | 0.65 | 0.8s | +50% | — | +1 potion | — |
| Cookery | 0.50 | 1.2s | +50% | — | +1 portion | — |
| Tanning | 0.60 | 1.0s | +50% | — | +1 leather | — |
| Smelting | 0.55 | 1.0s | +50% | — | +1 bar | — |
| Timber Shaping | 0.50 | 1.0s | +50% | — | +1 plank | — |
| Runesmithing | 0.75 | 0.6s | +50% | — | — | ✅ |
| Tailoring | 0.50 | 1.2s | +50% | — | — | ✅ |
| Arcane Weaving | 0.55 | 1.0s | +50% | — | — | ✅ |
| Artificing | 0.45 | 1.2s | +50% | — | — | ✅ |
| Inscription | 0.60 | 1.0s | +50% | — | +1 charge | — |
| Marksmanship | Player-driven | Subclass | +50/+100% | +10/+35% | — | — |
| Slaying | HP-triggered | 2.0s | +80% | +20% | — | — |

---

## 🔧 Implementation Notes for Claude Code

- Add `attunementQualityBonus` bool field to TalentActivity — used by Runesmithing, Tailoring, Arcane Weaving, Artificing
- Add `attunementYieldBonus` int field — extra units of primary output on success
- Marksmanship and Slaying are **not cycle-based** — flag these separately in IdleManager logic
- Slaying window triggers on `enemyHPPercent < 0.20` threshold check, not cycle position
- Marksmanship window is always open during active combat — Bowstring IS the attunement mechanic
- Weak point glow duration should be a **per-Grimoire parameter** on the Marksmanship TalentActivity:
  - Sharpshot: `weakPointGlowDuration = 3.0f`
  - Lone Wanderer: `weakPointGlowDuration = 1.5f`
- All gathering/processing talents use the same AttunementUI component — only cue label and timing differ
- Phase 1 simplification: complex visual cues (grain tracing, thread alignment, sequence matching) can be reduced to a single tap-to-confirm in Phase 1. The data fields are set correctly — just the visual cue complexity is simplified. Expand visuals in later polish pass.

---

*Document version 0.3 — Attunement Window Data Spec*
*Key change: Combat Talents removed — attunement data now feeds Grimoire Combat Progression, not shared Talent levels*
*Update this doc as new talents are added in Phase 2+*
