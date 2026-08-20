---
type: design-spec
version: 1.0
updated: 2026-07-24
status: canonical
---

# Project Grimoire, Equipment Tier Design
### Version 1.0

> This document is the authoritative definition of the Tier axis.
> It supersedes the "quality tier" tables in assembly-materials-crafting-system.md
> and stat-scaling-combat-formulas.md, which used quality names to mean material tiers.
> Those docs now reference this one.

---

## 1. The Two-Axis Model (canonical)

**Quality** (one word; "rarity" is a synonym but "quality" is the term used in code)
is an instance flag on an inventory stack, displayed as a corner badge.
Ladder: Crude (0), Rough (1), Refined (2), Pristine (3), Masterwork (4), Legendary (5, DLC).
Quality is raised at the Assembly bench. It drives tool idle-time and a stat modifier on gear.
Quality values are fixed in code and do not change.

**Tier** is the material and power progression. Each tier is a distinct item asset
crafted from the previous tier's finished item plus a tier-specific raw material,
inside the owning crafting talent. Tier adds a flat bonus on top of the quality base.

**The combination rule:**

```
FinalWeaponDamage = QualityWeaponDamage(quality) + TierWeaponBonus(tier)
FinalArmourRating = QualityArmourRating(quality, armourType) + TierArmourBonus(tier, armourType)
FinalStatBonus    = QualityStatBonus(quality)   [quality-only, no tier component]
FinalEvasionBase  = QualityEvasionBase(quality, armourType)  [quality-only, no tier component]
```

Tier is additive, not multiplicative. Quality values stay exactly as built in code.
Tier shifts the floor and ceiling upward. This preserves all existing item data at T1.

Stat bonuses and evasion do not receive a tier component. Gear stats (STR, DEX, etc.)
are a character build axis that should remain bounded and manageable at all tiers.
Letting tier multiply stat bonuses would compound with quality and push stats past the
diminishing-returns soft cap of 50 routinely, breaking that system. Weapon damage and
armour rating absorb the tier progression instead.

---

## 2. Tier List

Five tiers, mapping 1:1 to the existing zone tier bands.

| Tier | Name | Zone band | Total Combat Level gate |
|------|------|-----------|------------------------|
| T1 | Bronze | Zone T1, Grimwood + Saltmarsh | Level 1 |
| T2 | Iron | Zone T2, Ashfen + Ironspine | Level 21 |
| T3 | Steel | Zone T3 | Level 51 |
| T4 | Mithril | Zone T4 | Level 91 |
| T5 | Void | Zone T5 | Level 141 |

**As-built (2026-08-19): equipment tier is gated by the EQUIPPED Grimoire's own combat level, not
Total Combat Level.** A single Grimoire caps at 100, so the Total-based 141 for T5 would be
unreachable by one Grimoire; and gating gear on the account total let a fresh Grimoire wield T5.
So equipment uses per-Grimoire thresholds that fit 1-100 (mirroring the crafting unlocks): T1 1,
T2 21, T3 42, T4 65, T5 88. Zones still gate on Total Combat Level (the table above). Swapping to a
Grimoire too low for the equipped gear auto-unequips it to the bag. Rarity is never gated.

Five tiers matches five zone bands exactly. No tier numbering appears in the player-facing
UI. Players see item names: "Iron Sword", "Steel Plate Helm", "Void Bow".

---

## 3. Raw Material and Talent Level Gate Per Tier

Each tier is crafted from the previous tier's finished item plus a raw material.
Crafting is done inside the owning talent, not at the bench.
The bench handles quality upgrades only.

### 3.1 Metal weapons and Plate armour (Runesmithing)

| Target tier | Previous item | Raw material consumed | Runesmithing level required |
|-------------|--------------|----------------------|----------------------------|
| Bronze (T1) | none, built fresh | Copper Bar + Tin Bar | 1 |
| Iron (T2) | Bronze item | Iron Bar | 21 |
| Steel (T3) | Iron item | Steel Bar | 42 |
| Mithril (T4) | Steel item | Mithril Bar | 65 |
| Void (T5) | Mithril item | Void Alloy | 88 |

Steel Bar requires Iron Bar + Coal processed at Smelting 35.
Mithril Bar from Mithril Ore, Smelting 65.
Void Alloy from Mithril Bar + Soulite, Smelting 85.

### 3.2 Bows and wood-hafted tools (Timber Shaping)

| Target tier | Previous item | Raw material consumed | Timber Shaping level required |
|-------------|--------------|----------------------|-------------------------------|
| Bronze (T1) | none, built fresh | Pine Haft + Bronze Limbs | 1 |
| Iron (T2) | Bronze item | Ash Haft + Iron Limbs | 21 |
| Steel (T3) | Iron item | Oak Haft + Steel Limbs | 42 |
| Mithril (T4) | Steel item | Ironwood Haft + Mithril Limbs | 65 |
| Void (T5) | Mithril item | Heartwood Haft + Void Limbs | 88 |

Hafts are Timber Shaping outputs. Limbs are Runesmithing components.
Cross-talent dependency: Bow upgraders need Runesmithing suppliers for limbs at T2+.

### 3.3 Leather armour (Tailoring)

| Target tier | Previous item | Raw material consumed | Tailoring level required |
|-------------|--------------|----------------------|--------------------------|
| Bronze (T1) | none, built fresh | Rough Leather (from Rabbit Pelt) | 1 |
| Iron (T2) | Bronze item | Supple Leather (from Fox Fur) | 21 |
| Steel (T3) | Iron item | Treated Leather (from Wolf Pelt) | 42 |
| Mithril (T4) | Steel item | Masterwork Leather (from Direwolf Hide) | 65 |
| Void (T5) | Mithril item | Drake Scale | 88 |

Leather grades are Tanning outputs. Drake Scale is a rare trapping drop from T4-T5 zones.

Player-facing names: Rabbit-Hide Armour, Fox Leather Armour, Wolfhide Armour,
Direwolf Armour, Drake Scale Armour.

### 3.4 Magical Vestments (Tailoring + Artificing)

| Target tier | Previous item | Raw material consumed | Tailoring level required |
|-------------|--------------|----------------------|--------------------------|
| Bronze (T1) | none, built fresh | Herb Extract | 1 |
| Iron (T2) | Bronze item | Rare Herb | 21 |
| Steel (T3) | Iron item | Moonbloom Petal | 42 |
| Mithril (T4) | Steel item | Shadow Essence | 65 |
| Void (T5) | Mithril item | Void Creature Part | 88 |

Player-facing names: Cloth Vestments, Woven Vestments, Emberpetal Vestments,
Shadow Vestments, Void Vestments.

### 3.5 Staff and Wand (Artificing)

| Target tier | Previous item | Raw material consumed | Artificing level required |
|-------------|--------------|----------------------|--------------------------|
| Bronze (T1) | none, built fresh | Pine Haft + Iron Apparatus | 1 |
| Iron (T2) | Bronze item | Ash Haft + Steel Apparatus | 21 |
| Steel (T3) | Iron item | Oak Haft + Steel Clockwork Apparatus | 42 |
| Mithril (T4) | Steel item | Ironwood Haft + Mithril Apparatus | 65 |
| Void (T5) | Mithril item | Heartwood Haft + Void Foci | 88 |

Player-facing names follow the haft: Pine Staff, Ash Staff, Oak Staff, Ironwood Staff,
Heartwood Staff. Same pattern for Wand.

---

## 4. Stat Scaling

### 4.1 Weapon damage

Quality base values (as built in code, unchanged):

| Quality | Damage band |
|---------|-------------|
| Crude | 4-8 |
| Rough | 8-14 |
| Refined | 14-22 |
| Pristine | 22-32 |
| Masterwork | 32-45 |
| Legendary (DLC) | 45-60 |

Tier flat bonus (added to both ends of the quality band):

| Tier | Name | Flat bonus |
|------|------|-----------|
| T1 | Bronze | +0 |
| T2 | Iron | +20 |
| T3 | Steel | +45 |
| T4 | Mithril | +80 |
| T5 | Void | +125 |

Full combined damage table:

| | Bronze | Iron | Steel | Mithril | Void |
|--|--------|------|-------|---------|------|
| Crude | 4-8 | 24-28 | 49-53 | 84-88 | 129-133 |
| Rough | 8-14 | 28-34 | 53-59 | 88-94 | 133-139 |
| Refined | 14-22 | 34-42 | 59-67 | 94-102 | 139-147 |
| Pristine | 22-32 | 42-52 | 67-77 | 102-112 | 147-157 |
| Masterwork | 32-45 | 52-65 | 77-90 | 112-125 | 157-170 |

### 4.2 Armour rating

Quality base values by armour type (as built in code, unchanged):

| Quality | Plate | Leather | Vestments |
|---------|-------|---------|-----------|
| Crude | 4 | 2 | 1 |
| Rough | 8 | 5 | 3 |
| Refined | 14 | 9 | 6 |
| Pristine | 22 | 15 | 10 |
| Masterwork | 32 | 22 | 15 |
| Legendary (DLC) | 45 | 30 | 22 |

Tier flat bonus by armour type:

| Tier | Name | Plate | Leather | Vestments |
|------|------|-------|---------|-----------|
| T1 | Bronze | +0 | +0 | +0 |
| T2 | Iron | +8 | +5 | +3 |
| T3 | Steel | +18 | +12 | +8 |
| T4 | Mithril | +32 | +22 | +14 |
| T5 | Void | +50 | +35 | +22 |

Full combined armour rating (Crude and Masterwork columns only):

| | Bronze C | Bronze MW | Iron C | Iron MW | Steel C | Steel MW | Mithril C | Mithril MW | Void C | Void MW |
|--|--|--|--|--|--|--|--|--|--|--|
| Plate | 4 | 32 | 12 | 40 | 22 | 50 | 36 | 64 | 54 | 82 |
| Leather | 2 | 22 | 7 | 27 | 14 | 34 | 24 | 44 | 37 | 57 |
| Vestments | 1 | 15 | 4 | 18 | 9 | 23 | 15 | 29 | 23 | 37 |

### 4.3 Armour evasion base (quality-only, no tier)

Evasion is construction quality, not material. A well-stitched Rabbit-Hide suit
dodges as well as a well-stitched Drake Scale suit of the same quality.

Quality base values (as built):

| Quality | Leather | Vestments | Plate |
|---------|---------|-----------|-------|
| Crude | 12 | 10 | 4 |
| Rough | 14 | 11 | 5 |
| Refined | 16 | 13 | 6 |
| Pristine | 18 | 14 | 7 |
| Masterwork | 21 | 16 | 8 |
| Legendary (DLC) | 24 | 18 | 9 |

No armour: 15 flat. Final evasion: EvasionBase + DEX x 0.4.

### 4.4 Equipment stat bonus (quality-only, no tier)

Stat bonuses do not scale with tier. Primary stat gets the top number; secondary gets the bottom.

| Quality | Primary stat | Secondary stat |
|---------|-------------|---------------|
| Crude | +2 | +1 |
| Rough | +5 | +3 |
| Refined | +9 | +6 |
| Pristine | +14 | +10 |
| Masterwork | +20 | +15 |
| Legendary (DLC) | +35 | +25 |

Favoured stats (as built): Bow DEX/LCK, Sword STR/VIT, Dagger DEX/STR, Staff INT/WIL,
Wand INT/LCK, Axe STR/DEX; Plate VIT/STR, Leather DEX/VIT, Vestments INT/WIL.

### 4.5 Tool idle-time multiplier (quality-only, no tier)

| Quality | Idle-time multiplier |
|---------|---------------------|
| Crude | 1.00 |
| Rough | 0.85 |
| Refined | 0.70 |
| Pristine | 0.55 |
| Masterwork | 0.40 |
| Legendary (DLC) | 0.30 |

---

## 5. Coverage

**Weapons:** All six types (Sword, Bow, Dagger, Staff, Wand, Axe) get all five tiers.
Staff and Wand tier names follow the haft wood rather than the metal.

**Armour:** All three types (Plate, Leather, Vestments) get all five tiers.
Each of the five armour pieces (Helm, Chest, Legs, Boots, Gloves) is a distinct asset per tier.

**Tools:** Quality only. No material tiers for tools. One Axe item type, one Pickaxe item
type, etc. Quality badge differentiates. Tool material tiers are a future design decision
and not blocked by this spec.

---

## 6. Zone Alignment and Progression Feel

| Zone band | Combat Level | Appropriate tier | Quality arc |
|-----------|-------------|-----------------|-------------|
| Zone T1 | 1-20 | Bronze | Enter Crude, push to Refined before T2 |
| Zone T2 | 21-50 | Iron | Arrive with Iron Crude, grind to Refined/Pristine |
| Zone T3 | 51-90 | Steel | Steel Crude on arrival, Masterwork is the milestone |
| Zone T4 | 91-140 | Mithril | Major power jump; Crude Mithril surpasses Masterwork Steel |
| Zone T5 | 141+ | Void | Enter with Crude, Masterwork is the ceiling |

**Tier beats quality of the previous tier.** Bronze Masterwork weapon damage tops out at
32-45. Iron Crude starts at 24-28. Iron Crude just barely beats Bronze Masterwork at the
high end. Moving to a new zone and crafting the entry tier feels like a real upgrade.

**Quality within a tier is always meaningful.** Steel Crude Plate armour rating 22;
Steel Masterwork 50. That is a 2.3x difference in a single tier. The quality grind
provides sustained progression between major tier jumps.

**No quality gate on zone access.** Zone entry uses Total Combat Level only (ZoneAccess.cs).
A player with Bronze Crude gear can enter Zone T2 at level 21 and should feel the pressure.

---

## 7. Power Check

Attack at zone entry (Sword user, approximate STR growth from talent milestones):

| Zone | Gear | Weapon midpoint | STR x 1.5 | Approx Attack |
|------|------|----------------|-----------|--------------|
| T1 | Bronze Crude | 6 | 30 | 36 |
| T2 | Iron Crude | 26 | 42 | 68 |
| T3 | Steel Crude | 51 | 53 | 104 |
| T4 | Mithril Crude | 86 | 63 | 149 |
| T5 | Void Crude | 131 | 72 | 203 |

Damage taken at zone entry, Plate Crude armour, VIT 25 throughout:

| Zone | Enemy avg | Plate Crude rating | Defense = VIT x 0.8 + rating | Damage taken |
|------|-----------|-------------------|------------------------------|-------------|
| T1 | 8 | 4 | 24 | max(1, 8-9.6) = 1 |
| T2 | 16 | 12 | 32 | max(1, 16-12.8) = 3 |
| T3 | 27 | 22 | 42 | max(1, 27-16.8) = 10 |
| T4 | 39 | 36 | 56 | max(1, 39-22.4) = 17 |
| T5 | 55 | 54 | 74 | max(1, 55-29.6) = 25 |

T1 nearly negates weak hits. T5 Crude gear still takes meaningful damage (25 per hit
against a T5 enemy base; T5 Masterwork Plate at 82 rating reduces this to around 8).
The quality grind at T5 is the primary survivability lever. Numbers land correctly.

---

## 8. ItemData Changes for Claude Code

```csharp
// Add to ItemData:
[Header("Material Tier (1=Bronze 2=Iron 3=Steel 4=Mithril 5=Void; tools always 1)")]
public int materialTier = 1; // default 1 preserves all existing items

// Tier bonus tables (add to ItemData or a static TierConfig):
static readonly int[] tierWeaponBonus    = { 0, 0, 20, 45,  80, 125 }; // index 0 unused
static readonly int[] tierPlateBonus     = { 0, 0,  8, 18,  32,  50 };
static readonly int[] tierLeatherBonus   = { 0, 0,  5, 12,  22,  35 };
static readonly int[] tierVestmentBonus  = { 0, 0,  3,  8,  14,  22 };

// Replace quality-only damage calls with:
int GetWeaponDamageMin() =>
    qualityDamageMin[(int)quality] + tierWeaponBonus[materialTier];
int GetWeaponDamageMax() =>
    qualityDamageMax[(int)quality] + tierWeaponBonus[materialTier];

// Replace quality-only armour rating calls with:
int GetArmourRating() {
    int qBase = qualityArmourRating[(int)quality][(int)armourType];
    int[] tBonusTable = armourType switch {
        ArmourType.Plate     => tierPlateBonus,
        ArmourType.Leather   => tierLeatherBonus,
        ArmourType.Vestments => tierVestmentBonus,
        _ => new int[6]
    };
    return qBase + tBonusTable[materialTier];
}

// Evasion, stat bonuses, idle multiplier: no change, quality-only as built.
```

All existing items default to `materialTier = 1`. Output is identical to current code.
New T2-T5 items set `materialTier` accordingly and get tier bonus automatically.

---

## 9. Assembly Components (as built, noting the simplification)

The built bench uses shared components per quality band, not per item type.
This supersedes the per-item component tables in assembly-materials-crafting-system.md v0.5.

| Target quality | Component 1 | Component 2 | Rare material |
|---------------|-------------|-------------|---------------|
| Rough | Iron Fitting | Ash Haft | Rough Binding Sigil |
| Refined | Steel Fitting | Oak Haft | Refined Binding Sigil |
| Pristine | Mithral Fitting | Ironwood Haft | Pristine Binding Sigil |
| Masterwork | Adamant Fitting | Heartwood Haft | Masterwork Binding Sigil |

These apply to all item types. The per-item tables in assembly-materials-crafting-system.md
v0.5 are retained as design reference but are not what code implements.

---

*Equipment Tier Design, v1.0*
*Companion docs: assembly-materials-crafting-system.md (bench quality upgrades),*
*stat-scaling-combat-formulas.md (combat formulas)*
