# Upgrade Component Economy, Design Request

**Status:** Design ask for Chat (implementation blocked pending sign-off)
**Trigger:** Playtester #41 ("can't find iron fittings or rough binding sigils anywhere") + Dustin asking
whether fittings and apparatus can be combined.
**Owner after resolution:** fold into `material-economy.md` (CANONICAL).

---

## The problem

The quality-upgrade bench (`AssemblyManager`: Crude → Rough → Refined → Pristine → Masterwork) consumes,
per step, two components + one rare, chosen by the item's assembler talent. Two problems:

| Component family | Used by | Availability |
|------------------|---------|--------------|
| **Fitting** (Iron / Steel / Mithral / Adamant) | **every** upgrade recipe | **NO source at all** (not a talent output, not a drop) |
| **Binding Sigil** (Rough / Refined / Pristine / Masterwork) | Runesmithing + Artificing recipes | Gleaning **rare** drop only, at **0.4-1%** (effectively unfindable) |

Because **every** recipe needs a Fitting and Fittings have no source, **the entire upgrade bench is unusable**.
Binding Sigils do exist (Gleaning `rareLoot`: Runic Deposits→Rough @1%, Deep Runes→Refined @0.8%, Ancient
Runes→Pristine @0.6%, Voidtouched→Masterwork @0.4%) but the rates are so low that #41's tester couldn't
find them, a tuning problem layered on top of the Fitting dead-end. Runic Cog is likewise a Gleaning rare.
This pre-dates the recent talent-keyed recipe change; the old shared recipe used Fittings too.

## What the current recipes ask for (talent-keyed, as-built)

| Talent (item kind) | Component 1 | Component 2 | Rare |
|--------------------|-------------|-------------|------|
| Runesmithing (weapons/plate) | **Fitting** ✗ | Binding Sigil ~ | Gemstone ✓ |
| Timber Shaping (bows/wood tools) | Haft ✓ | **Fitting** ✗ | Amber ✓ |
| Tailoring (leather/cloth) | Leather grade ✓ | **Fitting** ✗ | Amber ✓ |
| Artificing (arcane apparatus) | **Fitting** ✗ | Haft ✓ | Binding Sigil ~ |

✓ = obtainable · ~ = obtainable but very rare (Gleaning 0.4-1%) · ✗ = no source.

## What IS produced (the component roster)

Two parallel axes exist today:

- **Tier ladder** (Bronze → Void), crafted intermediates:
  - Bars (Smelting), Limbs (Runesmithing), **Apparatus** (Artificing), Hafts (Timber Shaping),
    Leather grades (Tanning).
- **Quality-band ladder** (Rough → Masterwork), the upgrade components:
  - **Haft** band overlaps the tier hafts (Ash/Oak/Ironwood/Heartwood) ✓ produced (Timber Shaping).
  - **Binding Sigil** band ~ Gleaning `rareLoot` only, 0.4-1% (too rare to rely on).
  - **Fitting** band ✗ no producer at all, the hard blocker.
- **Rares** (by combat tier): Gemstone, Amber (enemy drops / Delving) ✓. Gleaning's regular output is Rune
  Shards + Enchant Seals; Binding Sigils and Runic Cogs are its rare drops.

## Dustin's question: combine Fittings and Apparatus?

They sit on different axes: **Apparatus** is a *tier* intermediate Artificing crafts for staves/wands;
**Fitting** is meant to be the *quality-band* upgrade component. A literal merge is awkward. The actual
problem is not too many component types, it is that two band components have no source.

## Options for Chat to choose / refine

1. **Give Fittings a producer + make Binding Sigils reliably obtainable (smallest).** Add Fitting crafting
   activities (e.g. Smelting or Runesmithing: 1x matching Bar → 1x Fitting per band), and either raise the
   Gleaning Binding-Sigil rare rates or add a deterministic Sigil craft (e.g. Inscription: Rune Shard +
   Enchant Seal → Sigil). Keeps the current recipe tables intact.

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
