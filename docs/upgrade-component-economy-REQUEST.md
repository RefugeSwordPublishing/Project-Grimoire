# Upgrade Component Economy, Design Request

**Status:** Design ask for Chat (implementation blocked pending sign-off)
**Trigger:** Playtester #41 ("can't find iron fittings or rough binding sigils anywhere") + Dustin asking
whether fittings and apparatus can be combined.
**Owner after resolution:** fold into `material-economy.md` (CANONICAL).

---

## The problem

The quality-upgrade bench (`AssemblyManager`: Crude → Rough → Refined → Pristine → Masterwork) consumes,
per step, two components + one rare, chosen by the item's assembler talent. **Two of those component
families cannot be obtained by any means:**

| Component family | Used by | Produced by |
|------------------|---------|-------------|
| **Fitting** (Iron / Steel / Mithral / Adamant) | **every** upgrade recipe | **nothing** |
| **Binding Sigil** (Rough / Refined / Pristine / Masterwork) | Runesmithing + Artificing recipes | **nothing** |

They exist as item assets (`Assets/Data/Items/Assembly/`) and are referenced by recipes, but no talent
activity outputs them and they are not enemy drops. So **the entire upgrade system is unusable** as soon
as it needs a Fitting, which is immediately. This pre-dates the recent talent-keyed recipe change; the old
shared recipe used Fittings too.

## What the current recipes ask for (talent-keyed, as-built)

| Talent (item kind) | Component 1 | Component 2 | Rare |
|--------------------|-------------|-------------|------|
| Runesmithing (weapons/plate) | **Fitting** ✗ | **Binding Sigil** ✗ | Gemstone ✓ |
| Timber Shaping (bows/wood tools) | Haft ✓ | **Fitting** ✗ | Amber ✓ |
| Tailoring (leather/cloth) | Leather grade ✓ | **Fitting** ✗ | Amber ✓ |
| Artificing (arcane apparatus) | **Fitting** ✗ | Haft ✓ | **Binding Sigil** ✗ |

✓ = obtainable, ✗ = unobtainable.

## What IS produced (the component roster)

Two parallel axes exist today:

- **Tier ladder** (Bronze → Void), crafted intermediates:
  - Bars (Smelting), Limbs (Runesmithing), **Apparatus** (Artificing), Hafts (Timber Shaping),
    Leather grades (Tanning).
- **Quality-band ladder** (Rough → Masterwork), the upgrade components:
  - **Haft** band overlaps the tier hafts (Ash/Oak/Ironwood/Heartwood) ✓ produced.
  - **Fitting** band ✗ no producer.
  - **Binding Sigil** band ✗ no producer.
- **Rares** (by combat tier): Gemstone, Amber (enemy drops / Delving) ✓; Gleaning makes Rune Shards +
  Enchant Seals (not sigils/cogs, despite the old spec note).

## Dustin's question: combine Fittings and Apparatus?

They sit on different axes: **Apparatus** is a *tier* intermediate Artificing crafts for staves/wands;
**Fitting** is meant to be the *quality-band* upgrade component. A literal merge is awkward. The actual
problem is not too many component types, it is that two band components have no source.

## Options for Chat to choose / refine

1. **Give the missing components producers (smallest).** Add crafting activities so Fittings + Binding
   Sigils are obtainable, e.g. Fittings from Smelting or Runesmithing (1x matching Bar → 1x Fitting per
   band), Binding Sigils from Gleaning or Inscription (Rune Shard + Enchant Seal → Sigil). ~8 activities,
   keeps the current recipe tables intact.

2. **Rework upgrade recipes onto produced items (fewer types).** Retire Fittings/Binding Sigils and build
   the upgrade recipes from components that already exist: Bars, Hafts, Apparatus, Leather grades, plus the
   Gemstone/Amber rares. Simplifies the roster (Dustin's "combine" instinct) but needs a deliberate map of
   which produced item fills each band for each discipline, and a rework of `AssemblyManager`'s tables.

3. **Hybrid.** Keep Hafts + Binding Sigils, retire Fittings in favour of Apparatus/Bars where sensible.

## What Chat should deliver

A canonical component-economy table folded into `material-economy.md`:
- For each assembler discipline (Runesmithing / Timber Shaping / Tailoring / Artificing) and each quality
  band (Rough / Refined / Pristine / Masterwork): the two components + the rare, **using only items that
  have a producer** (or specifying the new producer activity + its recipe + level if a component is added).
- The producer for every component the recipes reference (talent + activity + inputs + level).
- A decision on the Fitting/Apparatus question, stated explicitly.

Claude Code then implements the talent-activity additions and/or the `AssemblyManager` recipe changes.

## Reference (as-built, code wins on conflict)

- Recipes: `AssemblyManager.cs` (talent-keyed, `Recipes` dict).
- Component items: `Assets/Data/Items/Assembly/`.
- Talent outputs: `Assets/Data/Talents/*.asset` (activities' `possibleLoot`).
- Prior alignment precedent: `tanning-hide-alignment.md` (same class of dead-component bug, fixed by
  aligning producers to consumers).
