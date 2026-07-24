---
type: implementation-spec
step: 8
updated: 2026-07-22
target: ProjectGrimoire (private Unity repo)
vocab: Quality = Crude/Rough/Refined/Pristine/Masterwork/Legendary (ItemQuality enum).
       Tier = level-gated progression (zone bands, material unlock levels). Never mixed.
---

# Project Grimoire, Step 8: Assembly and Crafting System

## Scope

This spec covers the upgrade model, success rates, per-quality component and
rare-material requirements for the 8 non-combat tools (tools already in game
via CreateSampleTools), assembly XP, and the tool-slot tooltip showing the
next upgrade path. Weapons and armor follow the same model but are out of
scope for this step.

Tools are the priority because they drive idle speed and their assets already
exist at Refined and Masterwork quality.

---

## 1. The Upgrade Model

### 1.1 Crude

Crude items are always built fresh. No previous item is required.

Components + rare material in: new Crude item out.

Crude assembly always succeeds (100%).

### 1.2 Rough and above

Every quality above Crude requires the previous quality item as an ingredient.

```
Crude   built fresh from components, no previous item
Rough   Crude item + Rough components + rare material
Refined Rough item + Refined components + rare material
Pristine Refined item + Pristine components + rare material
Masterwork Pristine item + Masterwork components + rare material
```

On SUCCESS: the previous quality item is consumed and a new item of the target
quality is written to inventory. All components and the rare material are
consumed.

On FAIL: the previous quality item is returned unchanged to inventory. All
components and the rare material are consumed. No downgrade. No cascade. The
player keeps exactly what they had before the attempt.

There is no floor output on failure below the current quality. Legendary is
DLC only; do not build upgrade paths to it.

### 1.3 Code contract

```csharp
public class AssemblyManager : MonoBehaviour
{
    // Returns true if the attempt succeeded.
    // Caller is responsible for confirming the player has all required items
    // before calling this. AssemblyManager does not re-check.
    public bool AttemptUpgrade(
        ItemData currentItem,        // the Crude/Rough/Refined/Pristine item being upgraded
        ItemData[] components,       // the components consumed regardless of outcome
        ItemData rareMaterial,       // the rare material consumed regardless of outcome
        ArcanistSubclass assembler,  // which talent owns this assembly (for XP + attunement)
        int assemblerTalentLevel)    // for success-rate modifier
    { ... }
}
```

---

## 2. Success Rates

### 2.1 Base rates

| Target quality | Base success rate |
|---------------|-----------------|
| Crude | 100% |
| Rough | 70% |
| Refined | 55% |
| Pristine | 35% |
| Masterwork | 20% |

### 2.2 Assembler talent modifier

Each assembler talent level adds 0.18% to the base success rate.

```
modifier = assemblerTalentLevel * 0.18f   // max +18% at level 100
finalRate = Mathf.Clamp01(baseRate + modifier)
```

| Target quality | Base | Max (talent 100) |
|---------------|------|-----------------|
| Crude | 100% | 100% |
| Rough | 70% | 88% |
| Refined | 55% | 73% |
| Pristine | 35% | 53% |
| Masterwork | 20% | 38% |

### 2.3 Attunement modifier (future hook)

Reserve a float `attunementBonus` parameter in `AttemptUpgrade`. Currently
pass 0f. The phase 2 attunement spec will populate it. Do not block on this.

```csharp
finalRate = Mathf.Clamp01(baseRate + talentModifier + attunementBonus)
```

---

## 3. Assembly XP

Assembly XP is awarded to the assembler talent on every completed attempt,
win or lose. Failing still earns XP; the risk is the consumed materials, not
wasted effort.

| Target quality | Assembly XP awarded |
|---------------|-------------------|
| Crude | 15 |
| Rough | 35 |
| Refined | 65 |
| Pristine | 110 |
| Masterwork | 250 |

XP routing: call the same talent XP method used by idle actions, passing the
assembler talent and the flat XP value above. No multipliers from tool quality
or attunement apply at this stage.

---

## 4. Tool Component and Rare-Material Tables

These are the 8 non-combat tools that drive idle talents. Assets already exist
via `Create Sample Tools` at Refined and Masterwork quality.

For each tool the table lists what is consumed in addition to the previous
quality item (for Rough+). Crude rows require no previous item.

### 4.1 Felling Axe
Assembler talent: Timber Shaping
Rare material: Void Spore

| Target quality | Timber Shaping component | Runesmithing component | Rare material |
|---------------|--------------------------|------------------------|---------------|
| Crude | Pine Haft | Bronze Axe Head | none |
| Rough | Hardwood Haft | Iron Axe Head | Crude Void Spore |
| Refined | Ashwood Haft | Steel Axe Head | Rough Void Spore |
| Pristine | Ironbark Haft | Mithril Axe Head | Refined Void Spore |
| Masterwork | Voidtimber Haft | Void Axe Head | Pristine Void Spore |

### 4.2 Pickaxe
Assembler talent: Timber Shaping
Rare material: Runic Cog

| Target quality | Timber Shaping component | Runesmithing component | Rare material |
|---------------|--------------------------|------------------------|---------------|
| Crude | Pine Haft | Bronze Pick Head | none |
| Rough | Hardwood Haft | Iron Pick Head | Crude Runic Cog |
| Refined | Ashwood Haft | Steel Pick Head | Rough Runic Cog |
| Pristine | Ironbark Haft | Mithril Pick Head | Refined Runic Cog |
| Masterwork | Voidtimber Haft | Void Pick Head | Pristine Runic Cog |

### 4.3 Trapper's Kit
Assembler talent: Artificing
Rare material: Phantom Pelt

| Target quality | Artificing component | Tailoring component | Rare material |
|---------------|----------------------|---------------------|---------------|
| Crude | Iron Snare Frame | Rough Leather Pouch | none |
| Rough | Steel Snare Frame | Cured Leather Pouch | Crude Phantom Pelt |
| Refined | Steel Clockwork Frame | Fine Leather Pouch | Rough Phantom Pelt |
| Pristine | Mithril Frame | Wolf Leather Pouch | Refined Phantom Pelt |
| Masterwork | Adamantine Frame | Masterwork Leather Pouch | Pristine Phantom Pelt |

### 4.4 Fishing Rod
Assembler talent: Timber Shaping
Rare material: Abyssal Pearl

| Target quality | Timber Shaping component | Artificing component | Rare material |
|---------------|--------------------------|----------------------|---------------|
| Crude | Pine Rod | Iron Hook Set | none |
| Rough | Hardwood Rod | Steel Hook Set | Crude Abyssal Pearl |
| Refined | Ashwood Rod | Steel Fine Hook Set | Rough Abyssal Pearl |
| Pristine | Ironbark Rod | Mithril Hook Set | Refined Abyssal Pearl |
| Masterwork | Voidtimber Rod | Adamantine Hook Set | Pristine Abyssal Pearl |

### 4.5 Smith's Hammer
Assembler talent: Timber Shaping
Rare material: Runic Cog

| Target quality | Timber Shaping component | Runesmithing component | Rare material |
|---------------|--------------------------|------------------------|---------------|
| Crude | Pine Haft | Bronze Hammer Head | none |
| Rough | Hardwood Haft | Iron Hammer Head | Crude Runic Cog |
| Refined | Ashwood Haft | Steel Hammer Head | Rough Runic Cog |
| Pristine | Ironbark Haft | Mithril Hammer Head | Refined Runic Cog |
| Masterwork | Voidtimber Haft | Void Hammer Head | Pristine Runic Cog |

### 4.6 Carpenter's Kit
Assembler talent: Artificing
Rare material: Runic Cog

| Target quality | Artificing component | Runesmithing component | Rare material |
|---------------|----------------------|------------------------|---------------|
| Crude | Iron Tool Set | Bronze Blades | none |
| Rough | Steel Tool Set | Iron Blades | Crude Runic Cog |
| Refined | Steel Fine Tool Set | Steel Blades | Rough Runic Cog |
| Pristine | Mithril Tool Set | Mithril Blades | Refined Runic Cog |
| Masterwork | Adamantine Tool Set | Void Blades | Pristine Runic Cog |

### 4.7 Alchemy Kit
Assembler talent: Artificing
Rare material: Aetheric Filament

| Target quality | Artificing component | Inscription component | Rare material |
|---------------|----------------------|-----------------------|---------------|
| Crude | Iron Apparatus | Basic Formulae Book | none |
| Rough | Steel Apparatus | Scroll-bound Formulae | Crude Aetheric Filament |
| Refined | Steel Clockwork Apparatus | Spellbook Formulae | Rough Aetheric Filament |
| Pristine | Mithril Apparatus | Ancient Text Formulae | Refined Aetheric Filament |
| Masterwork | Adamantine Apparatus | Living Grimoire Formulae | Pristine Aetheric Filament |

### 4.8 Cookery Set
Assembler talent: Artificing
Rare material: Prismatic Seed

| Target quality | Artificing component | Tailoring component | Rare material |
|---------------|----------------------|---------------------|---------------|
| Crude | Iron Implements | Rough Cloth Carry Bag | none |
| Rough | Steel Implements | Linen Carry Bag | Crude Prismatic Seed |
| Refined | Steel Fine Implements | Fine Cloth Carry Bag | Rough Prismatic Seed |
| Pristine | Mithril Implements | Silk Carry Bag | Refined Prismatic Seed |
| Masterwork | Adamantine Implements | Arcane Carry Bag | Pristine Prismatic Seed |

---

## 5. Component Save Chance (Resource Attunement Bonus)

When crafting individual components (not during assembly itself), high talent
level gives a small chance to save the secondary component (it is not consumed).
This is a component-crafting attunement, separate from the assembly success-rate
modifier.

| Assembler talent level | Secondary component save chance |
|-----------------------|--------------------------------|
| 1-20 | 1% |
| 21-40 | 2% |
| 41-60 | 4% |
| 61-80 | 6% |
| 81-100 | 8% |

Apply this roll when a component recipe finishes, before deducting inventory.
If the roll succeeds, return the secondary component to inventory (or simply
do not deduct it).

---

## 6. Tool-Slot Tooltip: Next Upgrade

The tool slot on the Character page already auto-equips the best owned quality.
The tooltip (long-press or hover) should show what the player needs for the
next quality step.

### 6.1 Data shape

```csharp
public class ToolUpgradeRequirement
{
    public ItemQuality targetQuality;
    public float successRate;          // already computed with talent modifier
    public ItemData previousQualityItem; // null for Crude (not needed)
    public UpgradeComponent[] components;
    public UpgradeComponent rareMaterial; // null for Crude
    public int assemblyXpReward;
}

public class UpgradeComponent
{
    public ItemData item;
    public int quantityRequired;
    public int quantityOwned;          // live from InventoryManager
}
```

### 6.2 Display rules

Show the next quality step only. If the player owns a Refined Axe, show
only the Pristine upgrade path, not the full chain.

If the tool is already Masterwork, show "Maximum quality reached."

Each component row shows: item name, required quantity, owned quantity,
and a green/red indicator (sufficient / insufficient).

Success rate shown as a percentage rounded to one decimal place, already
including the assembler talent modifier.

The previous quality item row is shown first, labelled "Current item (consumed
on success)". This makes the risk visible.

### 6.3 Tooltip layout (plain text reference for the UI build)

```
Upgrade: Refined Axe -> Pristine Axe
Success rate: 53.0%  (Timber Shaping 100)

Current item (consumed on success):
  Refined Axe         x1   owned: 1  [OK]

Components (consumed either way):
  Ironbark Haft       x1   owned: 0  [MISSING]
  Mithril Axe Head    x1   owned: 2  [OK]

Rare material (consumed either way):
  Refined Void Spore  x1   owned: 0  [MISSING]

Assembly XP on attempt: 110  (Timber Shaping)
```

---

## 7. ScriptableObject Structure

No new ScriptableObject type is needed. Add upgrade data to the existing
`ItemData` as optional fields:

```csharp
// On ItemData (add these fields):
[Header("Assembly upgrade (tools, weapons, armor)")]
public ItemQuality upgradeTargetQuality;  // Rough, Refined, etc.
public TalentType assemblerTalent;
public ItemData[] upgradeComponents;      // 2 for tools, 3 for armor
public ItemData upgradeRareMaterial;      // null for Crude
public int assemblyXp;
```

The existing `CreateSampleTools` editor script already produces Refined and
Masterwork tools. Extend it (or add a sibling script) to populate these new
fields for all 8 tools across all 5 quality steps.

---

## 8. Acceptance Criteria

- Attempting to upgrade a Rough Felling Axe with correct components and rare
  material either produces a Refined Axe (success) or returns the Rough Axe
  with components consumed (failure). In neither case is the Rough Axe
  destroyed or downgraded.
- Success rate for Refined target with a talent-100 assembler is 73.0%.
- Failing a Pristine attempt consumes the Pristine components and rare
  material but leaves the Refined tool in inventory.
- Assembly XP of 65 is credited to the assembler talent on a Refined attempt,
  win or lose.
- The tool-slot tooltip correctly identifies the next upgrade step for the
  best tool the player owns, shows live owned quantities for all requirements,
  and marks missing items as MISSING.
- Crude tools are built without requiring any previous quality item.
- No item is ever downgraded. No quality below the starting quality is ever
  produced as output.

---

*Assembly and Crafting System, implementation spec v1.0*
*Scope: 8 non-combat tools, upgrade model, success rates, component tables,*
*assembly XP, tool-slot tooltip. Weapons and armor follow the same model,*
*out of scope for Step 8.*
