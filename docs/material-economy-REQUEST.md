---
type: design-request
status: resolved
resolved-by: material-economy.md
for: Chat (design)
updated: 2026-07-25
---

> RESOLVED by `material-economy.md` (canonical). This request is kept for history.

# Design Request: The Material Economy

The tier system is built (see `equipment-tier-design.md`): quality is an instance flag raised at the
bench; tier is a crafted item ladder (Bronze -> Void) adding a flat damage/armour bonus. Tier crafting
recipes exist, but the **tier materials have no way to be obtained**, and some material names/chains
are inconsistent. This request asks you to design the material economy.

## As-built talents
- Gathering: Foraging, Dredging, Trapping.
- Processing/crafting: Tanning, Alchemy, Cookery, Inscription, Artificing, and the new smith talents
  Runesmithing, Timber Shaping, Tailoring.
- There is **no Smelting/Mining talent built.** `equipment-tier-design.md` section 3 references
  "Smelting 35" etc. Decide whether to add a talent, fold smelting into an existing one (Runesmithing?),
  or change the source.

## Tier materials with NO acquisition path yet (need sources)
- Metal bars: Copper Bar, Tin Bar, Iron Bar, Steel Bar, Mithril Bar, Void Alloy.
- Weapon limbs: Bronze / Iron / Steel / Mithril / Void Limbs.
- Hafts: Pine Haft (Ash / Oak / Ironwood / Heartwood Haft already exist).
- Arcane parts: Iron Apparatus, Steel Apparatus, Steel Clockwork Apparatus, Mithril Apparatus, Void Foci.
- Vestment mats: Rare Herb, Shadow Essence, Void Creature Part (Herb Extract, Moonbloom Petal exist).
- Leather: Drake Scale (rare drop). Rough / Supple / Treated / Masterwork Leather exist.

## Existing materials to build on
Pelts (Rabbit Pelt, Fox Fur, Wolf Pelt, Direwolf Hide, Shadow Pelt), Rare Ore, Ironroot Chunk,
Bone Fragment, Thornwood Bark, Common Herb, Moonbloom Petal, Herb Extract, the leather grades.

## Two inconsistencies to fix
1. **Names reuse quality words.** "Rough Leather" and "Masterwork Leather" collide with the
   Crude -> Masterwork quality ladder and are confusing as tier materials. Rename the quality-word
   materials to neutral names.
2. **The leather chain does not line up.** As-built Tanning makes Rough / Supple / Treated / Masterwork
   Leather from Wolf / Fox / Direwolf / Shadow pelts. `equipment-tier-design.md` section 3.3 assigns
   leather grades to armour tiers from Rabbit / Fox / Wolf / Direwolf. Reconcile the
   pelt -> leather grade -> armour tier mapping into one coherent chain.

## Deliverables
1. **Acquisition per tier material** - for every material above, the source: which gathering talent
   drops/gathers it, or which processing recipe makes it (inputs -> output, talent, level), or which
   zone/enemy drops it. Include the ore -> bar flow and resolve the Smelting-talent question.
2. **Renamed material list** - no quality words in material names; give the old -> new mapping so it
   can be applied to the recipes and drop tables.
3. **Reconciled leather chain** - pelt -> leather grade -> Leather-armour tier, one consistent table.
4. **Zone alignment** - which materials come from which zone bands, so tier N materials are gatherable
   around the zone where tier N gear is relevant.

Keep it consistent with the tier tables in `equipment-tier-design.md` section 3 (the recipes already
consume those material names; renames will be applied to match).
