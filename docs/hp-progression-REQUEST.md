---
type: design-request
for: Chat (claude.ai design collaborator)
from: Claude Code
date: 2026-08-28
subject: Design an HP / survivability progression so players do not get squishier as enemies scale by tier, with tankier Grimoires getting more
read-first: docs/implementation-status.md, then docs/stat-scaling-combat-formulas.md and the enemy tables (enemy-zone-tables.md, phase2-zone-tables.md, phase4-enemy-content-brief.md)
---

# Request: HP / survivability progression

## The problem (from the developer)

As players progress, enemies get stronger and hit harder (tier bands gate content by Total Combat
Level: 1-20 T1, 21-50 T2, 51-90 T3, 91-140 T4, 141+ T5). But **player max HP does not scale with
progression**, so players get **squishier the further they go**. It makes sense that **tankier
Grimoires get more HP**, but there needs to be a **baseline HP progression** so nobody's survivability
falls behind the enemy curve.

## Where we are (as-built, so design against this)

### Max HP formula
`PlayerData.GetMaxHP()`:
```
maxHP = round( (50 + totalVIT*4 + VITBonus*3 + VITEquip*3) * HPPoolMultiplier )
        totalVIT = VIT(base) + VITBonus + VITEquip
```
It is **entirely VIT-driven**. Consequences:
- A point of **base VIT** = **+4 HP**. A point of VIT from a **bonus or equipment** = **+7 HP** (the
  x4 plus an extra x3). Bonus/equip VIT is weighted ~75% higher than base VIT. Flag whether that
  double-count is intended or should be cleaned up.
- `HPPoolMultiplier` is **1.6 for Lifebinder** (HP is their casting resource) and **1.0 for everyone
  else**. (Summoner's "constructs are the HP pool" is a separate effectiveHP calc, not this multiplier.)

### The four VIT sources (the only ways HP grows today)
1. **Equipment** (`VITEquip`) - VIT on worn gear. +7 HP/point. The main active lever.
2. **Talent milestones** (`VITBonus`, permanent) - `TalentManager.ApplyMilestone` adds `milestone.vitGain`.
3. **Grimoire combat-level milestones** (`VITBonus`, permanent, cross-path) - written to
   `player_stat_bonuses`. **Only Vanguard grants VIT** (Lv 47 +1, Lv 81 +2). **Warden and Arcanist get
   ZERO VIT milestones**, so those paths never gain permanent HP except from gear.
4. **Meals / buffs** (`VITBonus`, temporary) - a dish with a VIT buff raises HP for its duration.

**There is no HP "level" and no per-level stat allocation.** Base VIT is a near-fixed server value (a
fresh account seeds low, ~54 max HP). So HP growth is gear + milestone + meal only, with two paths
getting almost none.

### How damage lands (the other half of survivability)
`ResolveEnemyAttack`:
```
hitChance   = clamp(enemy.baseAccuracy - playerEvasion, 5, 95)   // then a second evasion roll
rawDamage   = random(enemy.damageRangeMin, enemy.damageRangeMax)
finalDamage = max(1, rawDamage - playerDefense * 0.4)            // defense mitigates 0.4 per point
```
Plus: Hunted variants hit +15%, accessory resist multiplies, shields (Lifebinder) absorb first. On a
knockout the player revives at **10% max HP**, and **HP does not regenerate out of combat** (heal with
consumables between fights). So effective survivability is a function of **HP and defense together**
against a rising `damageRange`. Enemy `damageRange` climbs by tier (early T1 is single digits; higher
tiers are far larger, see the enemy tables).

## What to design

A survivability progression that closes the gap, with these parts:

### 1. Baseline HP progression for everyone
Something that raises max HP as the player advances, so a T3 player is not fighting T3 enemies on a
near-T1 health pool. Decide **what drives it**. Candidates to weigh (recommend one):
- **Total Combat Level** (the existing prestige stat, sum of Grimoire combat levels) granting VIT or a
  flat HP curve.
- **Per-Grimoire combat level** granting small VIT steps (fits `player_stat_bonuses`).
- **A Vitality talent line** trained like any other, granting VIT milestones (fits `vitGain`).
- A **flat HP-per-tier** term in `GetMaxHP` keyed off Total Combat Level.
Whatever it is, tie its magnitude to the enemy damage curve so survivability stays roughly flat or
gently improves across tiers, rather than being a number picked in a vacuum.

### 2. Per-Grimoire tank identity
Tankier paths (Vanguard, especially the Bulwark tank subclass; Lifebinder already has 1.6x) should end
up meaningfully beefier than squishy paths (Arcanist), while squishy paths must stay **viable**, they
lean on evasion/shields/range instead of raw HP. Say how the differentiation is expressed:
`HPPoolMultiplier` per subclass, path-specific VIT milestone tables, a defense/mitigation identity, or a
mix. Keep it legible to the player.

### 3. HP vs defense vs evasion
Survivability is HP plus mitigation. Decide whether the fix is HP, defense, or both, and how the three
paths' survivability identities differ (e.g. Vanguard = high HP + armor, Warden = evasion, Arcanist =
shields/range). Note the KO-at-10% and no-out-of-combat-regen rules when you reason about time-to-die.

### 4. Layering
Gear VIT, meals, and milestones should **stack on top of** the new baseline without either trivializing
content (a fully-geared player one-shotting a tier) or making the baseline pointless. Say how they
compose.

## Constraints

- **Reuse the existing pipes** where possible: `VITBonus` / `player_stat_bonuses`, `HPPoolMultiplier`,
  `TalentMilestone.vitGain`. Adding a new term to `GetMaxHP` is acceptable if justified.
- **Keep the two-axis quality/tier model** and the current stat set (STR/DEX/VIT/INT/WIL/LCK).
- **Mobile idle balance:** most damage is taken idle/auto; the player heals between fights with
  consumables. Do not assume active dodging.
- Address the **x4 base vs x7 bonus/equip VIT weighting**: keep it (and say why) or normalize it.
- Do not make any of the three paths unviable, and do not let HP scale so hard that defense/evasion or
  content difficulty stop mattering.
- Writing style: no em dashes, en dashes, or "--" as prose punctuation; no emojis (this becomes UI copy
  and code comments).

## Deliverable

A spec I can implement in stages, with:
- The baseline HP-progression mechanic (what drives it, the curve, and the concrete formula/tables),
  calibrated against the enemy damage curve by tier.
- The per-Grimoire tank identity (mechanism + rough magnitudes) and how squishy paths stay viable.
- Whether defense/evasion also change, and each path's survivability identity.
- How gear, meals, and milestones layer on top.
- A short **numbers pass**: expected max HP and rough time-to-die for a representative build in each of
  T1, T3, T5, so the curve can be sanity-checked before it is built.

Point out anything about the current model you think is wrong beyond what is listed here (the base-VIT
double-count, the two paths with zero VIT, the 10%-revive with no regen, or the Summoner/Lifebinder HP
special cases).
