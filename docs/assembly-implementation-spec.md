---
type: implementation-spec
step: 8
version: 2.0
updated: 2026-07-27
replaces: assembly-implementation-spec.md v1.0 (2026-07-22)
canonical: YES — this file supersedes assembly-materials-crafting-system.md for
           implementation purposes. The design doc remains as design reference but
           this file is what Claude Code builds from.
target: ProjectGrimoire (private Unity repo)
vocab:
  Quality: Crude / Rough / Refined / Pristine / Masterwork / Legendary
           (ItemQuality enum; Legendary is DLC-only, never author base-game items at it)
  Tier:    level-gated material progression (Bronze -> Void).
           Tier is crafted inside the owning talent. Assembly bench handles Quality only.
---

# Project Grimoire, Step 8: Assembly and Crafting System
## Version 2.0 (Reconciled)

---

## 0. What Changed from v1.0

This version reconciles assembly-implementation-spec.md v1.0 (2026-07-22) with:
- material-economy.md v1.0 (leather renames, arcane apparatus pipeline, Forge tool)
- assembly-materials-crafting-system.md v0.6 (per-item component tables)
- Post-Processing-merge talent structure (Gathering vs Crafting split only)

**Breaking changes from v1.0:**
- Processing talent category is dissolved. No TalentCategory.Processing references anywhere.
- Tanning Knife replaces "Tanning Frame" as the Tanning tool name.
- Artificer's Tools replaces "Carpenter's Kit" and "Weaving Loom" (neither is in the
  canonical tool list).
- Forge is a new 9th tool (added by material-economy.md).
- Smith's Hammer is removed (not in the canonical tool list).
- Arcane Weaving is dissolved into Artificing. All "Arcane Weaving" assembler and
  component references replaced with Artificing.
- Leather component names updated to use the renamed grades:
  Rabbit Hide / Fox Leather / Wolf Leather / Direwolf Leather.
- Fishing Rod secondary component changed from "Arcane Weaving Component" (retired)
  to Artificing component (Iron Hook Set etc.).
- Rare material substitutions for materials with no acquisition path:
  Abyssal Pearl -> Phantom Pelt (Trapping, real acquisition path)
  Aetheric Filament -> Ancient Sigil (Gleaning, real acquisition path)
  Prismatic Seed -> Runic Cog (Gleaning, real acquisition path)

---

## 1. Scope

This spec covers:
- The quality upgrade model (how the bench works, success/fail resolution)
- Success rates and XP
- Per-item component and rare-material tables for all 9 non-combat tools
- Per-item component and rare-material tables for all weapon types
- Per-item component and rare-material tables for all armor types
- The tool-slot tooltip next-upgrade display
- The ScriptableObject contract

Tier crafting (Bronze -> Iron -> Steel -> Mithril -> Void) is NOT bench assembly.
It is handled inside each owning talent's crafting screen. This spec does not cover it.

---

## 2. The Upgrade Model

### 2.1 Crude

Crude items are always built fresh from components. No previous item required.
Assembly always succeeds (100%).

### 2.2 Rough and above

Every quality above Crude requires the previous quality item as an ingredient.

```
Crude      built fresh from components
Rough      Crude item + Rough components + rare material
Refined    Rough item + Refined components + rare material
Pristine   Refined item + Pristine components + rare material
Masterwork Pristine item + Masterwork components + rare material
```

**On SUCCESS:** Previous quality item is consumed. Components and rare material
consumed. New item of target quality written to inventory.

**On FAIL:** Previous quality item returned unchanged to inventory. Components
and rare material consumed. No downgrade. No cascade. Player keeps exactly what
they had before the attempt.

Legendary is DLC only. Do not build upgrade paths to it.

### 2.3 Code contract

```csharp
public class AssemblyManager : MonoBehaviour
{
    // Returns true if the attempt succeeded.
    // Caller confirms the player has all required items before calling.
    // AssemblyManager does not re-check inventory; caller owns that validation.
    public bool AttemptUpgrade(
        ItemData currentItem,         // Crude/Rough/Refined/Pristine item being upgraded
        ItemData[] components,        // consumed regardless of outcome
        ItemData rareMaterial,        // consumed regardless of outcome; null for Crude
        TalentType assemblerTalent,   // which talent earns Assembly XP
        int assemblerTalentLevel,     // for success-rate modifier
        float attunementBonus = 0f)   // reserved for future attunement hook; pass 0f now
    { ... }
}
```

---

## 3. Success Rates

### 3.1 Base rates

| Target quality | Base success rate |
|---------------|-----------------|
| Crude | 100% |
| Rough | 70% |
| Refined | 55% |
| Pristine | 35% |
| Masterwork | 20% |

### 3.2 Assembler talent modifier

```csharp
float modifier = assemblerTalentLevel * 0.18f;  // max +18% at level 100
float finalRate = Mathf.Clamp01(baseRate + modifier + attunementBonus);
```

| Target quality | Base | Max (talent 100) |
|---------------|------|-----------------|
| Crude | 100% | 100% |
| Rough | 70% | 88% |
| Refined | 55% | 73% |
| Pristine | 35% | 53% |
| Masterwork | 20% | 38% |

---

## 4. Assembly XP

Awarded to the assembler talent on every attempt, win or lose.

| Target quality | Assembly XP |
|---------------|------------|
| Crude | 15 |
| Rough | 35 |
| Refined | 65 |
| Pristine | 110 |
| Masterwork | 250 |

No multipliers. Same XP method as idle actions. Pass assembler talent and flat value.

---

## 5. Talent Structure (post Processing-merge)

Talents split into two categories only: Gathering and Crafting.
There is no TalentCategory.Processing. Do not create it.

| Talent | Category | Assembles |
|--------|----------|-----------|
| Felling | Gathering | (none; produces logs) |
| Delving | Gathering | (none; produces ores, gems, amber) |
| Trapping | Gathering | (none; produces pelts, creature drops) |
| Dredging | Gathering | (none; produces fish, aquatic drops) |
| Foraging | Gathering | (none; produces herbs, reagents) |
| Gleaning | Gathering | (none; produces sigils, seals, cogs) |
| Smelting | Crafting | Ore -> bars, alloy recipes |
| Tanning | Crafting | Pelts -> leather grades |
| Timber Shaping | Crafting | Hafts, planks, bows, wood tools |
| Runesmithing | Crafting | Metal weapons, Plate armor, Pickaxe, Forge |
| Tailoring | Crafting | Leather armor, Vestments, Quiver |
| Artificing | Crafting | Arcane apparatus, Staff, Wand, Trapper's Kit, Alchemy Kit, Cookery Set, Tanning Knife, Inscription Set, Artificer's Tools |
| Alchemy | Crafting | Consumable potions, extracts |
| Cookery | Crafting | Consumable meals |
| Inscription | Crafting | Maps, scrolls, vellum, codices |
| Slaying | Crafting | (combat talent; no assembly) |

---

## 6. As-Built Bench Components vs Per-Item Tables

**The as-built Assembly bench uses shared components per quality band, not per-item:**

| Target quality | Component 1 | Component 2 | Rare material |
|---------------|-------------|-------------|---------------|
| Rough | Iron Fitting | Ash Haft | Rough Binding Sigil |
| Refined | Steel Fitting | Oak Haft | Refined Binding Sigil |
| Pristine | Mithral Fitting | Ironwood Haft | Pristine Binding Sigil |
| Masterwork | Adamant Fitting | Heartwood Haft | Masterwork Binding Sigil |

These shared components apply to ALL item types on the current bench implementation.
The per-item tables in Sections 7-9 are the design intent for a future per-item
bench UI. For Step 8, implement the shared-band model (above) as the bench behavior.
The per-item tables exist so future work can add item-specific component requirements
without redesigning the system.

**For Step 8, the bench asks:** "What quality band is the target?" Then applies the
shared row. The tool-slot tooltip (Section 11) uses these shared components to show
what the player needs.

---

## 7. Tool Assembly Tables

The canonical tool list (9 tools total):

1. Axe (Felling)
2. Pickaxe (Delving)
3. Trapper's Kit (Trapping)
4. Fishing Rod (Dredging)
5. Foraging Sickle (Foraging)
6. Tanning Knife (Tanning)
7. Alchemy Kit (Alchemy)
8. Cookery Set (Cookery)
9. Forge (Smelting) — new, added by material-economy.md

Inscription Set and Artificer's Tools are also tools but are not idle-speed tools in
the same sense. Author them as ItemData with upgrade paths but they are lower priority
for Step 8 since their parent talents don't drive idle gathering loops.

Smith's Hammer and Carpenter's Kit are NOT in the canonical tool list and should not
be authored. Weaving Loom is not in the canonical tool list.

---

### 7.1 Axe (Felling tool)

Assembler talent: Timber Shaping
Assembly XP: Timber Shaping
Rare material: Gemstone (Delving)

| Target quality | Runesmithing component | Timber Shaping component | Rare material |
|---------------|------------------------|--------------------------|---------------|
| Crude | Bronze Axe Head | Pine Haft | none |
| Rough | Iron Axe Head | Ash Haft | Crude Gemstone |
| Refined | Steel Axe Head | Oak Haft | Rough Gemstone |
| Pristine | Mithril Axe Head | Ironwood Haft | Refined Gemstone |
| Masterwork | Void Axe Head | Heartwood Haft | Pristine Gemstone |

Effect: higher quality Axe increases attunement window and bonus timber yield.

---

### 7.2 Pickaxe (Delving tool)

Assembler talent: Runesmithing
Assembly XP: Runesmithing
Rare material: Amber (Delving cave resin)

| Target quality | Runesmithing component | Timber Shaping component | Rare material |
|---------------|------------------------|--------------------------|---------------|
| Crude | Bronze Pick Head | Pine Haft | none |
| Rough | Iron Pick Head | Ash Haft | Crude Amber |
| Refined | Steel Pick Head | Oak Haft | Rough Amber |
| Pristine | Mithril Pick Head | Ironwood Haft | Refined Amber |
| Masterwork | Void Pick Head | Heartwood Haft | Pristine Amber |

Effect: higher quality Pickaxe increases ore yield and gem drop chance.

---

### 7.3 Trapper's Kit (Trapping tool)

Assembler talent: Artificing
Assembly XP: Artificing
Rare material: Phantom Pelt (Trapping rare drop)

| Target quality | Artificing component | Tanning component | Rare material |
|---------------|----------------------|-------------------|---------------|
| Crude | Iron Trap Frame | Rabbit Hide Pouch | none |
| Rough | Steel Trap Frame | Fox Leather Pouch | Crude Phantom Pelt |
| Refined | Steel Clockwork Frame | Wolf Leather Pouch | Rough Phantom Pelt |
| Pristine | Mithril Clockwork Frame | Direwolf Leather Pouch | Refined Phantom Pelt |
| Masterwork | Adamantine Frame | Drake Leather Pouch | Pristine Phantom Pelt |

Effect: higher quality Trapper's Kit increases catch rate and rare pelt chance.

---

### 7.4 Fishing Rod (Dredging tool)

Assembler talent: Timber Shaping
Assembly XP: Timber Shaping
Rare material: Void Spore (zone drops, Dreadhollow primary)

| Target quality | Timber Shaping component | Artificing component | Rare material |
|---------------|--------------------------|----------------------|---------------|
| Crude | Pine Rod | Iron Hook Set | none |
| Rough | Ash Rod | Steel Hook Set | Crude Void Spore |
| Refined | Oak Rod | Steel Fine Hook Set | Rough Void Spore |
| Pristine | Ironwood Rod | Mithril Hook Set | Refined Void Spore |
| Masterwork | Heartwood Rod | Adamantine Hook Set | Pristine Void Spore |

Note: "Arcane Weaving Component" in the v0.6 design doc is retired. Artificing
replaces it across all tool and weapon tables.

---

### 7.5 Foraging Sickle (Foraging tool)

Assembler talent: Runesmithing
Assembly XP: Runesmithing
Rare material: Runic Cog (Gleaning rare drop)

| Target quality | Runesmithing component | Timber Shaping component | Rare material |
|---------------|------------------------|--------------------------|---------------|
| Crude | Bronze Sickle Head | Pine Haft | none |
| Rough | Iron Sickle Head | Ash Haft | Crude Runic Cog |
| Refined | Steel Sickle Head | Oak Haft | Rough Runic Cog |
| Pristine | Mithril Sickle Head | Ironwood Haft | Refined Runic Cog |
| Masterwork | Void Sickle Head | Heartwood Haft | Pristine Runic Cog |

Effect: higher quality Foraging Sickle increases herb yield and rare herb chance.

---

### 7.6 Tanning Knife (Tanning tool)

Assembler talent: Runesmithing
Assembly XP: Runesmithing
Rare material: Runic Cog (Gleaning rare drop)

| Target quality | Runesmithing component | Tanning component | Rare material |
|---------------|------------------------|-------------------|---------------|
| Crude | Bronze Blade | Rabbit Hide Wrap | none |
| Rough | Iron Blade | Fox Leather Wrap | Crude Runic Cog |
| Refined | Steel Blade | Wolf Leather Wrap | Rough Runic Cog |
| Pristine | Mithril Blade | Direwolf Leather Wrap | Refined Runic Cog |
| Masterwork | Void Blade | Drake Leather Wrap | Pristine Runic Cog |

Note: Previously named "Tanning Frame" in older docs. Tanning Knife is the
canonical tool name. The tool is the blade implement, not the drying frame.

Effect: higher quality Tanning Knife reduces cure cycle time and increases
leather grade success rate.

---

### 7.7 Alchemy Kit (Alchemy tool)

Assembler talent: Artificing
Assembly XP: Artificing
Rare material: Ancient Sigil (Gleaning rare drop)

Note: v1.0 spec used "Aetheric Filament" as rare material. No acquisition path
exists for Aetheric Filament. Ancient Sigil replaces it (Gleaning T3-T4 drop,
real acquisition path in material-economy.md).

| Target quality | Artificing component | Inscription component | Rare material |
|---------------|----------------------|-----------------------|---------------|
| Crude | Iron Apparatus | Basic Formulae Book | none |
| Rough | Steel Apparatus | Scroll-bound Formulae | Crude Ancient Sigil |
| Refined | Steel Clockwork Apparatus | Spellbook Formulae | Rough Ancient Sigil |
| Pristine | Mithril Apparatus | Ancient Text Formulae | Refined Ancient Sigil |
| Masterwork | Adamantine Apparatus | Living Grimoire Formulae | Pristine Ancient Sigil |

Effect: higher quality Alchemy Kit reduces brew cycle time and increases
yield chance.

---

### 7.8 Cookery Set (Cookery tool)

Assembler talent: Artificing
Assembly XP: Artificing
Rare material: Runic Cog (Gleaning rare drop)

Note: v1.0 spec used "Prismatic Seed" as rare material. No acquisition path
exists for Prismatic Seed. Runic Cog replaces it (Gleaning T2-T3 drop,
real acquisition path in material-economy.md).

| Target quality | Artificing component | Tailoring component | Rare material |
|---------------|----------------------|---------------------|---------------|
| Crude | Iron Implements | Rabbit Hide Carry Bag | none |
| Rough | Steel Implements | Fox Leather Carry Bag | Crude Runic Cog |
| Refined | Steel Fine Implements | Wolf Leather Carry Bag | Rough Runic Cog |
| Pristine | Mithril Implements | Direwolf Leather Carry Bag | Refined Runic Cog |
| Masterwork | Adamantine Implements | Drake Leather Carry Bag | Pristine Runic Cog |

Effect: higher quality Cookery Set reduces cook cycle time and increases
meal quality chance.

---

### 7.9 Forge (Smelting tool)

Assembler talent: Runesmithing
Assembly XP: Runesmithing
Rare material: Runic Cog (Gleaning rare drop)

New tool added by material-economy.md. Not in v1.0 spec.

| Target quality | Runesmithing component | Artificing component | Rare material |
|---------------|------------------------|----------------------|---------------|
| Crude | Bronze Forge Frame | Iron Bellows | none |
| Rough | Iron Forge Frame | Steel Bellows | Crude Runic Cog |
| Refined | Steel Forge Frame | Steel Clockwork Bellows | Rough Runic Cog |
| Pristine | Mithril Forge Frame | Mithril Bellows | Refined Runic Cog |
| Masterwork | Void Forge Frame | Adamantine Bellows | Pristine Runic Cog |

Effect: higher quality Forge reduces smelting cycle time and reduces
HeatGauge attunement variance (see phase3-attunement-data-spec.md).

---

## 8. Weapon Assembly Tables

Assembler talent earns Assembly XP. All use the shared-band bench components
as-built (Section 6), with these per-item tables as design reference for
future per-item bench expansion.

### 8.1 Bow

Assembler: Timber Shaping
Rare material: Gemstone (Delving)

| Target quality | Timber Shaping component | Runesmithing component | Rare material |
|---------------|--------------------------|------------------------|---------------|
| Crude | Pine Limbs + Grip | Bronze Tips | none |
| Rough | Ash Limbs + Grip | Iron Tips | Crude Gemstone |
| Refined | Oak Limbs + Grip | Steel Tips | Rough Gemstone |
| Pristine | Ironwood Limbs + Grip | Mithril Tips | Refined Gemstone |
| Masterwork | Heartwood Limbs + Grip | Void Tips | Pristine Gemstone |

### 8.2 Sword

Assembler: Runesmithing
Rare material: Gemstone (Delving)

| Target quality | Runesmithing component | Timber Shaping component | Rare material |
|---------------|------------------------|--------------------------|---------------|
| Crude | Bronze Blade | Pine Grip | none |
| Rough | Iron Blade | Ash Grip | Crude Gemstone |
| Refined | Steel Blade | Oak Grip | Rough Gemstone |
| Pristine | Mithril Blade | Ironwood Grip | Refined Gemstone |
| Masterwork | Void Blade | Heartwood Grip | Pristine Gemstone |

### 8.3 Axe (weapon)

Assembler: Runesmithing
Rare material: Gemstone (Delving)

| Target quality | Runesmithing component | Timber Shaping component | Rare material |
|---------------|------------------------|--------------------------|---------------|
| Crude | Bronze Axe Head | Pine Haft | none |
| Rough | Iron Axe Head | Ash Haft | Crude Gemstone |
| Refined | Steel Axe Head | Oak Haft | Rough Gemstone |
| Pristine | Mithril Axe Head | Ironwood Haft | Refined Gemstone |
| Masterwork | Void Axe Head | Heartwood Haft | Pristine Gemstone |

### 8.4 Dagger

Assembler: Runesmithing
Rare material: Gemstone (Delving)

| Target quality | Runesmithing component | Tanning component | Rare material |
|---------------|------------------------|-------------------|---------------|
| Crude | Bronze Blade | Rabbit Hide Wrap | none |
| Rough | Iron Blade | Fox Leather Wrap | Crude Gemstone |
| Refined | Steel Blade | Wolf Leather Wrap | Rough Gemstone |
| Pristine | Mithril Blade | Direwolf Leather Wrap | Refined Gemstone |
| Masterwork | Void Blade | Drake Leather Wrap | Pristine Gemstone |

### 8.5 Staff

Assembler: Artificing (Arcane Weaving dissolved into Artificing)
Rare material: Phantom Pelt (Trapping)

Note: v0.6 design doc listed "Arcane Weaving" as assembler. Arcane Weaving is
dissolved. Artificing owns Staff and Wand assembly.

| Target quality | Timber Shaping component | Artificing component | Rare material |
|---------------|--------------------------|----------------------|---------------|
| Crude | Pine Shaft | Iron Apparatus | none |
| Rough | Ash Shaft | Steel Apparatus | Crude Phantom Pelt |
| Refined | Oak Shaft | Steel Clockwork Apparatus | Rough Phantom Pelt |
| Pristine | Ironwood Shaft | Mithril Apparatus | Refined Phantom Pelt |
| Masterwork | Heartwood Shaft | Adamantine Apparatus | Pristine Phantom Pelt |

### 8.6 Wand

Assembler: Artificing
Rare material: Void Spore (zone drops)

| Target quality | Timber Shaping component | Artificing component | Rare material |
|---------------|--------------------------|----------------------|---------------|
| Crude | Pine Handle | Iron Apparatus | none |
| Rough | Ash Handle | Steel Apparatus | Crude Void Spore |
| Refined | Oak Handle | Steel Clockwork Apparatus | Rough Void Spore |
| Pristine | Ironwood Handle | Mithril Apparatus | Refined Void Spore |
| Masterwork | Heartwood Handle | Adamantine Apparatus | Pristine Void Spore |

---

## 9. Armor Assembly Tables

Three armor types. Each piece (Helm, Chest, Legs, Boots, Gloves) assembled
separately — 5 attempts per full set. Assembler earns Assembly XP per attempt.

### 9.1 Plate Armor (Vanguard, per piece)

Assembler: Runesmithing
Rare material: Gemstone (Delving)
Components: 3 + rare material

| Target quality | Runesmithing component | Tanning component | Artificing component | Rare material |
|---------------|------------------------|-------------------|----------------------|---------------|
| Crude | Bronze Plate Body | Cloth Padding | Iron Fastenings | none |
| Rough | Iron Plate Body | Rabbit Hide Padding | Steel Fastenings | Crude Gemstone |
| Refined | Steel Plate Body | Fox Leather Padding | Steel Clockwork Fastenings | Rough Gemstone |
| Pristine | Mithril Plate Body | Wolf Leather Padding | Mithril Fastenings | Refined Gemstone |
| Masterwork | Void Plate Body | Direwolf Leather Padding | Adamantine Fastenings | Pristine Gemstone |

### 9.2 Leather Armor (Warden, per piece)

Assembler: Tailoring
Rare material: Amber (Delving cave resin)
Components: 3 + rare material

| Target quality | Tanning component | Tailoring component | Runesmithing component | Rare material |
|---------------|-------------------|---------------------|------------------------|---------------|
| Crude | Rabbit Hide Body | Cloth Lining | Bronze Reinforcement | none |
| Rough | Fox Leather Body | Rabbit Hide Lining | Iron Reinforcement | Crude Amber |
| Refined | Wolf Leather Body | Fox Leather Lining | Steel Reinforcement | Rough Amber |
| Pristine | Direwolf Leather Body | Wolf Leather Lining | Mithril Reinforcement | Refined Amber |
| Masterwork | Drake Leather Body | Direwolf Leather Lining | Void Reinforcement | Pristine Amber |

### 9.3 Magical Vestments (Arcanist, per piece)

Assembler: Tailoring
Rare material: Ancient Sigil (Gleaning)
Components: 3 + rare material

Note: v0.6 design doc used "Arcane Weaving Component" as primary and
"Aetheric Filament" as rare material. Both are retired. Tailoring owns
Vestment assembly; Ancient Sigil is the rare material.

| Target quality | Tailoring component | Tanning component | Inscription component | Rare material |
|---------------|---------------------|-------------------|-----------------------|---------------|
| Crude | Cloth Vestment Body | Cloth Lining | Paper Binding | none |
| Rough | Arcane Thread Body | Rabbit Hide Lining | Scroll Binding | Crude Ancient Sigil |
| Refined | Emberpetal Weave Body | Fox Leather Lining | Spellbook Binding | Rough Ancient Sigil |
| Pristine | Drake Scale Weave Body | Wolf Leather Lining | Ancient Text Binding | Refined Ancient Sigil |
| Masterwork | Celestine Weave Body | Direwolf Leather Lining | Grimoire Page Binding | Pristine Ancient Sigil |

---

## 10. Quiver Assembly Table

Quiver is Warden core equipment, not a weapon or armor. Assembled by Tailoring.
Rare material: Void Spore (zone drops)

| Target quality | Tailoring component | Timber Shaping component | Rare material |
|---------------|---------------------|--------------------------|---------------|
| Crude | Rabbit Hide Body | Pine Frame | none |
| Rough | Fox Leather Body | Ash Frame | Crude Void Spore |
| Refined | Wolf Leather Body | Oak Frame | Rough Void Spore |
| Pristine | Direwolf Leather Body | Ironwood Frame | Refined Void Spore |
| Masterwork | Drake Leather Body | Heartwood Frame | Pristine Void Spore |

Effect: higher quality Quiver increases max coating slots and fire rate cap.
Crude: 1 slot. Refined: 2 slots. Masterwork: 3 slots.

---

## 11. Component Save Chance (Component Crafting Attunement)

When crafting individual components inside a talent (not at the bench), high
talent level gives a small chance to save the secondary component.

| Talent level | Secondary component save chance |
|-------------|--------------------------------|
| 1-20 | 1% |
| 21-40 | 2% |
| 41-60 | 4% |
| 61-80 | 6% |
| 81-100 | 8% |

Roll when a component recipe finishes, before deducting inventory. If successful,
do not deduct the secondary component.

---

## 12. Tool-Slot Tooltip: Next Upgrade

### 12.1 Data shape

```csharp
public class ToolUpgradeRequirement
{
    public ItemQuality targetQuality;
    public float successRate;            // computed with talent modifier applied
    public ItemData previousQualityItem; // null for Crude
    public UpgradeComponent[] components;
    public UpgradeComponent rareMaterial; // null for Crude
    public int assemblyXpReward;
}

public class UpgradeComponent
{
    public ItemData item;
    public int quantityRequired;
    public int quantityOwned;            // live from InventoryManager
}
```

### 12.2 Display rules

Show next quality step only. If player owns a Refined Axe, show only
the Pristine upgrade path.

If already Masterwork: show "Maximum quality reached."

Each component row shows item name, required quantity, owned quantity,
and a green/red indicator (sufficient / insufficient).

Success rate shown as percentage rounded to one decimal, including talent modifier.

Previous quality item row shown first, labelled "Current item (consumed on success)."

### 12.3 Tooltip layout reference

```
Upgrade: Refined Axe -> Pristine Axe
Success rate: 53.0%  (Timber Shaping 100)

Current item (consumed on success):
  Refined Axe          x1   owned: 1  [OK]

Components (consumed either way):
  Mithral Fitting      x1   owned: 0  [MISSING]
  Ironwood Haft        x1   owned: 2  [OK]

Rare material (consumed either way):
  Pristine Binding Sigil  x1  owned: 0  [MISSING]

Assembly XP on attempt: 110 (Timber Shaping)
```

Note: the tooltip uses the as-built shared-band components (Section 6),
not the per-item components from the tool tables. The bench uses shared bands.

---

## 13. ScriptableObject Contract

No new ScriptableObject type needed. Add upgrade data to existing ItemData:

```csharp
// Add to ItemData:
[Header("Assembly upgrade (tools, weapons, armor)")]
public ItemQuality upgradeTargetQuality;  // Rough, Refined, etc.
public TalentType assemblerTalent;        // which talent earns Assembly XP
public ItemData[] upgradeComponents;      // 2 for tools/weapons, 3 for armor
public ItemData upgradeRareMaterial;      // null for Crude
public int assemblyXp;                    // flat value from Section 4

// Extend CreateSampleTools (or add sibling script) to populate these
// fields for all 9 tools across all 5 quality steps.
```

---

## 14. Acceptance Criteria

- Attempting to upgrade a Rough Axe with correct components and rare material
  either produces a Refined Axe (success) or returns the Rough Axe unchanged
  with components consumed (failure).
- In neither case is the Rough Axe destroyed or downgraded.
- Success rate for Refined target at talent 100: 73.0%.
- Failing a Pristine attempt consumes components and rare material, leaves the
  Refined item in inventory.
- Assembly XP of 65 credited to the assembler talent on a Refined attempt, win or lose.
- Crude items require no previous quality item.
- No item is ever downgraded. No quality below the starting quality is produced.
- Legendary items cannot be authored or assembled in base game build.
- No TalentCategory.Processing exists anywhere in code.
- "Arcane Weaving" does not appear as a TalentType. Artificing covers all
  previously-Arcane-Weaving assembly roles.
- Tool-slot tooltip shows live owned quantities for all requirements and
  marks missing items correctly.
- Forge is authored as a 9th tool type with its own upgrade table.
- Smith's Hammer, Carpenter's Kit, and Weaving Loom are NOT authored as tools.

---

## 15. Conflicts Found and How They Were Resolved

| Conflict | Resolution |
|----------|-----------|
| Step 8 v1.0 listed 8 tools including Smith's Hammer, omitting Forge and Foraging Sickle | Smith's Hammer removed (not in canonical tool list). Forge added (material-economy.md). Foraging Sickle added (canonical tool list). Tanning Knife replaces Tanning Frame. Canonical list is now 9 tools. |
| Design doc listed Arcane Weaving as assembler for Staff, Wand, Fishing Rod secondary | Arcane Weaving dissolved into Artificing. Artificing replaces it everywhere. |
| Leather component names used old vocabulary (Rough Leather Pouch, Cured Leather Wrap etc.) | Applied material-economy.md rename map throughout: Rabbit Hide / Fox Leather / Wolf Leather / Direwolf Leather. Drake Leather at Masterwork. |
| v1.0 spec rare materials: Abyssal Pearl, Aetheric Filament, Prismatic Seed | None have a defined acquisition path. Replaced: Abyssal Pearl -> Phantom Pelt (Trapping), Aetheric Filament -> Ancient Sigil (Gleaning), Prismatic Seed -> Runic Cog (Gleaning). |
| Fishing Rod secondary component listed as "Arcane Weaving Component" (retired talent) | Replaced with Artificing component (Iron/Steel/Steel Fine/Mithril/Adamantine Hook Set). |
| As-built bench uses shared components per band; per-item tables say otherwise | Resolved: shared-band model is what Step 8 builds. Per-item tables retained as design reference for future work, clearly labelled. Tooltip uses shared-band components. |
| equipment-tier-design.md (404 on fetch) | Used the locally-known model: quality is instance flag at bench; tier is crafted in owning talent. Spec is consistent with this. If the live doc differs, that doc wins. |

## 16. Items Needing Your Call

**1. Rare material for Fishing Rod.** I replaced "Arcane Weaving Component" with
Void Spore (matches the previous v0.6 table choice). If you want a different rare
material for the Fishing Rod, call it.

**2. Staff and Wand rare materials.** v0.6 used Abyssal Pearl (Staff) and Void Spore
(Wand). I changed Staff to Phantom Pelt (real acquisition path) and kept Void Spore
for Wand. If the intent was a deep-water-themed rare material for Staff, you need to
define one with a real Dredging acquisition path.

**3. Vestment assembly — Arcane Weaving component.** v0.6 used "Arcane Weaving
Component" as the primary body. I replaced it with Tailoring as the assembler using
named weave body components (Cloth -> Arcane Thread -> Emberpetal Weave -> Drake Scale
Weave -> Celestine Weave). If the Vestment body should come from a different talent or
use different component names, call it.

**4. Foraging Sickle and Tanning Knife rare materials.** Not defined in either previous
doc (they weren't in the Step 8 tool list). I assigned Runic Cog to both — same rare
material as Smith's Hammer had in v1.0. If you want something different, call it.

---

## Canonical Document Status

**This file (assembly-implementation-spec.md v2.0) is now canonical for Claude Code.**

`assembly-materials-crafting-system.md` remains as design reference for the full
per-item component tables and the ownership/economy notes. It should NOT be read
as an implementation spec. When the two conflict, this file wins.

`equipment-tier-design.md` governs tier crafting (Bronze -> Void ladder inside
owning talents). This file governs quality upgrading (bench). They are non-overlapping.

`material-economy.md` governs acquisition paths for all raw materials. This file
consumes its output (component names, rare material names). When a component name
appears here, its acquisition path lives there.

---

*Assembly and Crafting System, Step 8, v2.0*
*Reconciled: 2026-07-27*
*Supersedes: assembly-implementation-spec.md v1.0 (2026-07-22)*
*Canonical for implementation. assembly-materials-crafting-system.md is design reference only.*
