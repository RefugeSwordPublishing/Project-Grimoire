---
type: design-spec
version: 1.0
updated: 2026-07-25
path: docs/material-economy.md
companion: equipment-tier-design.md, assembly-materials-crafting-system.md
---

# Project Grimoire, Material Economy
### Version 1.0

This document resolves the open questions from `material-economy-REQUEST.md`:
Delving and Smelting as proper talents, renamed leather grades, reconciled leather
chain, and acquisition paths for every material referenced in the assembly tables.

---

## 1. Talent Pipeline (corrected)

The full crafting pipeline per material family:

| Family | Gather | Process | Craft |
|--------|--------|---------|-------|
| Metal | Delving | Smelting | Runesmithing |
| Wood | Felling | Timber Shaping (owns both) | Timber Shaping |
| Leather | Trapping | Tanning | Tailoring |
| Arcane cloth | Foraging | Arcane Weaving | Tailoring / Artificing |
| Reagents | Foraging | Alchemy | Artificing / Inscription |
| Food | Foraging + Trapping + Dredging | Cookery | (final step) |
| Scrolls | Foraging (papyrus) + Gleaning (sigils) | Inscription | (final step) |

Runesmithing owns metal weapon and armour assembly only. Ore-to-bar conversion belongs
to Smelting. Runesmithing receives bars as inputs.

Timber Shaping owns both log processing and finished item assembly. No middleman needed.

---

## 2. Delving Talent

Delving is a gathering talent. It owns underground resource extraction: ore veins,
gem deposits, cave resin, and cave-specific drops. No processing.

### What Delving gathers

| Material | Zone | Notes |
|----------|------|-------|
| Copper Ore | T1 | Common; pairs with Tin for Bronze |
| Tin Ore | T1 | Common; pairs with Copper for Bronze |
| Iron Ore | T1-T2 | Transitions from T1 to T2 primary |
| Coal | T2-T3 | Fuel for Steel Bar; cave-floor gather |
| Crude Gemstone | T1-T2 | Rare material for T1-T2 weapon/armour assembly |
| Rough Gemstone | T2-T3 | Rare material for T2-T3 assembly |
| Refined Gemstone | T3-T4 | Rare material for T3-T4 assembly |
| Pristine Gemstone | T4-T5 | Rare material for T4-T5 assembly |
| Crude Amber | T1 | Cave resin deposit; Leather armour + Pickaxe rare mat |
| Rough Amber | T2-T3 | Cave resin deposit |
| Refined Amber | T3-T4 | Cave resin deposit |
| Pristine Amber | T4-T5 | Cave resin deposit |
| Mithril Ore | T4 | Rare; low drop rate from T4 ore nodes |
| Soulite Crystal | T5 | Very rare; T5 ore nodes and T5 enemy drop |
| Flint Fragment | T1 | Cave-specific; Gleaning/Inscription input |
| Fossil Shard | T2 | Cave-specific; Inscription input |
| Ancient Fossil | T3 | Cave-specific; Inscription input |

Gemstones are the rare material for most weapon and Plate armour assembly (see
assembly-materials-crafting-system.md tables). Every Runesmithing and Timber Shaping
assembler needs a Delving supplier. Amber is the rare material for Leather armour and
Pickaxe assembly. Both make Delving a critical economic talent.

### Delving tool: Pickaxe
As per the Pickaxe table in assembly-materials-crafting-system.md. Higher quality
Pickaxe increases ore yield and gem drop chance.

---

## 3. Smelting Talent

Smelting is a new processing talent sitting between Delving and Runesmithing.
It owns all ore-to-bar conversion and all alloy recipes.

### Smelting recipes

| Output | Inputs | Smelting level | Processing time |
|--------|--------|---------------|----------------|
| Copper Bar | 3x Copper Ore | 1 | 30s |
| Tin Bar | 3x Tin Ore | 1 | 30s |
| Bronze Bar | 2x Copper Bar + 1x Tin Bar | 5 | 45s |
| Iron Bar | 3x Iron Ore | 10 | 45s |
| Steel Bar | 2x Iron Bar + 1x Coal | 30 | 90s |
| Mithril Bar | 2x Mithril Ore | 60 | 120s |
| Void Alloy | 1x Mithril Bar + 1x Soulite Crystal | 85 | 180s |

Bronze Bar is the T1 alloy used for all Crude Runesmithing components (Bronze Blade,
Bronze Head, Bronze Plate Body, etc.). Steel Bar is the first multi-step alloy,
gating T3 production behind maintaining both an Iron Bar and Coal supply.

### Smelting tool: Forge (new tool type)

Assembler: Runesmithing
Assembly XP: Runesmithing
Rare Material: Runic Cog (from Gleaning)

| Quality Target | Runesmithing Component | Artificing Component | Rare Material |
|---------------|------------------------|----------------------|---------------|
| Crude | Bronze Forge Frame | Iron Bellows | None |
| Rough | Iron Forge Frame | Steel Bellows | Runic Cog |
| Refined | Steel Forge Frame | Steel Clockwork Bellows | Runic Cog |
| Pristine | Mithril Forge Frame | Mithril Bellows | Runic Cog |
| Masterwork | Void Forge Frame | Adamantine Bellows | Runic Cog |

<!-- Runic Cog is a single ungraded item (Runesmithing craft, upgrade-component-economy.md 6);
     the Crude/Rough/Refined/Pristine graded variants above never existed as items. -->

**Quality-upgrade bench components (canonical):** the per-discipline, per-band component +
rare tables and the producer for every component live in `upgrade-component-economy.md` v2.0
(sections 8-9), and the as-built recipes are `AssemblyManager.Recipes` (code wins on conflict).
Summary: Runesmithing crafts all four **Fittings** (from bars, L10/30/60/80); the Artificing
bench recipe uses **Apparatus** in place of a Fitting. **Binding Sigils and Runic Cog stay
Gleaning rare drops** (not crafts). The scarcity fix for the sigils is a deferred idle-vs-attuned
rate split (keep the idle rate, add an elevated rate gated on active attunement), which depends on
a Gleaning attunement window that is not built yet, see upgrade-component-economy.md section 7.


Higher quality Forge reduces processing time and adds a small attunement-gated chance
to produce an extra bar per smelt.

### Smelting milestone unlocks (suggested)

| Level | Unlock |
|-------|--------|
| 5 | Bronze Bar recipe |
| 10 | Iron Bar recipe |
| 20 | STR +1 |
| 30 | Steel Bar recipe |
| 40 | VIT +1 |
| 50 | Bar yield attunement window unlocked |
| 60 | Mithril Bar recipe |
| 70 | STR +2 |
| 85 | Void Alloy recipe |
| 100 | Masterwork smelt: guaranteed extra bar 5% of attempts |

---

## 4. Renamed Leather Grades

The names Rough Leather and Masterwork Leather collide with quality vocabulary.
New names use the source animal so the material is self-describing.

| Old name | New name | Source pelt |
|----------|----------|-------------|
| Rough Leather | Rabbit Hide | Rabbit Pelt |
| Cured Leather | Fox Leather | Fox Fur |
| Fine Leather | Wolf Leather | Wolf Pelt |
| Masterwork Leather | Direwolf Leather | Direwolf Hide |

Apply everywhere: Tanning recipes, assembly component tables in
assembly-materials-crafting-system.md, drop tables, and all ItemData assets.

Shadow Pelt stays as-is and is not part of the standard leather chain.

### Assembly reference rename map

Apply these renames to all component references in assembly-materials-crafting-system.md:

| Old assembly reference | New name |
|------------------------|----------|
| Rough Leather Wrap / Body / Pouch | Rabbit Hide Wrap / Body / Pouch |
| Cured Leather Wrap / Body / Pouch | Fox Leather Wrap / Body / Pouch |
| Fine Leather Wrap / Body / Lining | Wolf Leather Wrap / Body / Lining |
| Wolf Leather Wrap / Body / Pouch | (unchanged, already correct post-rename) |
| Masterwork Leather Wrap / Body / Pouch | Direwolf Leather Wrap / Body / Pouch |

---

## 5. Reconciled Leather Chain

One consistent table from pelt to leather grade to armour tier.

| Armour tier | Pelt source | Tanning recipe | Leather output | Tanning level |
|-------------|------------|----------------|---------------|--------------|
| T1 Bronze | Rabbit Pelt | 3x Rabbit Pelt | Rabbit Hide | 1 |
| T2 Iron | Fox Fur | 2x Fox Fur | Fox Leather | 20 |
| T3 Steel | Wolf Pelt | 2x Wolf Pelt | Wolf Leather | 40 |
| T4 Mithril | Direwolf Hide | 1x Direwolf Hide | Direwolf Leather | 65 |
| T5 Void | Drake Scale | direct drop, no Tanning needed | Drake Leather | n/a |

Rabbit requires 3x because it is the most common early pelt. Higher tiers require
fewer pelts because those animals are rarer by zone.

Drake Scale drops directly as Drake Leather from Drake enemies in T4-T5 zones.
Drakes are not hunted via Trapping; the hide arrives ready to use. No Tanning recipe needed.

Shadow Pelt is not part of the leather chain. It has one use: Alchemy recipe
(3x Shadow Pelt -> 1x Shadow Essence, Alchemy 60), which feeds T4 Vestment production.

---

## 6. Arcane Apparatus Recipes (Artificing)

These components feed Staff, Wand, Alchemy Kit, and tool assembly. All require
a metal bar plus a Gleaning sigil or seal drop.

| Output | Inputs | Artificing level | Processing time |
|--------|--------|-----------------|----------------|
| Iron Apparatus | 2x Iron Bar + 1x Crude Rune Shard | 15 | 60s |
| Steel Apparatus | 2x Steel Bar + 1x Minor Enchant Seal | 35 | 90s |
| Steel Clockwork Apparatus | 1x Steel Apparatus + 1x Runic Cog | 50 | 120s |
| Mithril Apparatus | 1x Mithril Bar + 1x Refined Binding Sigil | 65 | 150s |
| Adamantine Apparatus | 1x Void Alloy + 1x Pristine Binding Sigil | 80 | 180s |
| Void Foci | 1x Void Alloy + 1x Ancient Sigil | 88 | 180s |

Sigil sources (as-built): Gleaning guarantees the common rune materials each cycle (Crude
Rune Shard, Minor Enchant Seal) and drops the scarce upgrade materials as tiered RARE bonus
rolls (`rareLoot` + `rareLootChance`), rolled independently both idle and active (active adds a
x1.5 bonus on a landed attunement tap). By level band: Glean Runic Deposits (20) -> Rough
Binding Sigil / Runic Cog @1.0%; Glean Deep Runes (45) -> Refined Binding Sigil @0.8%; Glean
Ancient Runes (70) -> Pristine Binding Sigil / Ancient Sigil @0.6%; Glean Voidtouched Runes
(88) -> Masterwork Binding Sigil @0.4%. Cycle time scales as 14 + level, so a full 8h idle
session yields roughly T2 ~8, T3 ~4, T4 ~2, T5 ~1 sigil, scarce and tier-gated.

Gleaning is therefore a supply dependency for all Artificing production. Players
who neglect Gleaning will bottleneck Staff, Wand, Alchemy Kit, and tool crafting.

---

## 7. Vestment Material Acquisition

| Material | Source | Zone |
|----------|--------|------|
| Herb Extract | Alchemy recipe: 3x Common Herb | T1 |
| Rare Herb | Foraging idle gather (low rate) | T2 |
| Moonbloom Petal | Foraging idle gather (rare) | T3 |
| Shadow Essence | Alchemy recipe: 3x Shadow Pelt (Alchemy 60) | T4 |
| Void Creature Part | Enemy drop from Void-type enemies only | T5 |

---

## 8. Pine Haft

Missing from the as-built haft chain. Completes Pine -> Ash -> Oak -> Ironwood -> Heartwood.

Talent: Timber Shaping
Recipe: 2x Pine Log -> 1x Pine Haft (Timber Shaping 1, 20s)
Pine Log: Felling idle gather, Zone T1.

---

## 9. Full Zone Alignment

| Material | Zone | Source |
|----------|------|--------|
| Copper Ore | T1 | Delving |
| Tin Ore | T1 | Delving |
| Iron Ore | T1-T2 | Delving |
| Coal | T2-T3 | Delving |
| Mithril Ore | T4 | Delving (rare) |
| Soulite Crystal | T5 | Delving (rare) + T5 enemy drop |
| Crude Gemstone | T1-T2 | Delving |
| Rough Gemstone | T2-T3 | Delving |
| Refined Gemstone | T3-T4 | Delving |
| Pristine Gemstone | T4-T5 | Delving |
| Crude Amber | T1 | Delving cave resin |
| Rough Amber | T2-T3 | Delving cave resin |
| Refined Amber | T3-T4 | Delving cave resin |
| Pristine Amber | T4-T5 | Delving cave resin |
| Bronze Bar | T1 | Smelting (Copper + Tin Bar) |
| Iron Bar | T1-T2 | Smelting (Iron Ore) |
| Steel Bar | T2-T3 | Smelting (Iron Bar + Coal) |
| Mithril Bar | T4 | Smelting (Mithril Ore) |
| Void Alloy | T5 | Smelting (Mithril Bar + Soulite) |
| Pine Log | T1 | Felling |
| Ash / Oak / Ironwood / Heartwood Log | T2 / T3 / T4 / T5 | Felling |
| Pine Haft | T1 | Timber Shaping (Pine Log) |
| Ash / Oak / Ironwood / Heartwood Haft | T2 / T3 / T4 / T5 | Timber Shaping |
| Rabbit Pelt | T1 | Trapping |
| Fox Fur | T1-T2 | Trapping |
| Wolf Pelt | T2-T3 | Trapping |
| Direwolf Hide | T3-T4 | Trapping |
| Shadow Pelt | T3-T4 | Trapping (rare) |
| Drake Scale / Drake Leather | T4-T5 | Drake enemy drop (direct) |
| Rabbit Hide | T1 | Tanning (3x Rabbit Pelt) |
| Fox Leather | T2 | Tanning (2x Fox Fur) |
| Wolf Leather | T3 | Tanning (2x Wolf Pelt) |
| Direwolf Leather | T4 | Tanning (1x Direwolf Hide) |
| Common Herb | T1 | Foraging |
| Rare Herb | T2 | Foraging (low rate) |
| Moonbloom Petal | T3 | Foraging (rare) |
| Shadow Essence | T4 | Alchemy (Shadow Pelt) |
| Void Creature Part | T5 | Enemy drop only |
| Herb Extract | T1 | Alchemy (Common Herb) |
| Iron Apparatus | T1-T2 | Artificing |
| Steel Apparatus | T2-T3 | Artificing |
| Steel Clockwork Apparatus | T3 | Artificing |
| Mithril Apparatus | T4 | Artificing |
| Adamantine Apparatus | T4-T5 | Artificing |
| Void Foci | T5 | Artificing |
| Crude Rune Shard | T1-T2 | Gleaning drop |
| Minor Enchant Seal | T2 | Gleaning drop |
| Runic Cog | T2-T3 | Gleaning rare drop |
| Refined Binding Sigil | T3-T4 | Gleaning drop |
| Pristine Binding Sigil | T4 | Gleaning drop |
| Ancient Sigil | T3-T4 | Gleaning rare drop |

---

## 10. What Claude Code Needs to Build

1. **Delving talent** — new gathering talent. Ore nodes, gem deposits, and amber/cave
   drops as idle gather sources per zone tier. Pickaxe as tool type.
   Add milestone passives to talent-spec-sheets.md.

2. **Smelting talent** — new processing talent. Recipes in Section 3.
   Forge as new tool type; assembly table in Section 3.
   Add milestone passives to talent-spec-sheets.md.

3. **Leather renames** — apply old -> new name mapping (Section 4) to all ItemData
   assets, Tanning recipes, and every component reference in
   assembly-materials-crafting-system.md.

4. **Pine Haft** — add as Timber Shaping recipe (Section 8).

5. **Arcane apparatus recipes** — add to Artificing (Section 6).

6. **Drake Leather** — add as direct enemy drop from Drake enemies (T4-T5); no Tanning.

7. **Shadow Essence** — add as Alchemy recipe: 3x Shadow Pelt, Alchemy 60.

8. **Ore/amber/gem nodes per zone** — Delving idle gather sources placed per zone band
   matching the zone alignment table in Section 9.

---

*Material Economy, v1.0*
*Path: docs/material-economy.md*
*Resolves: material-economy-REQUEST.md*
