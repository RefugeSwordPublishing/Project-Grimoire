---
type: design-spec
version: 3.0
updated: 2026-08-24
supersedes: upgrade-component-economy.md v2.0
path: docs/upgrade-component-economy.md
resolves: upgrade-recipe-thematic-REQUEST.md
implements: AssemblyManager.Recipes, Tanning activities, Tailoring activities
carries-forward: v2.0 sections on Fitting production and Gleaning attunement rate split
---

# Upgrade Component Economy
### Version 3.0, thematic recipe pass

---

## 0. What Changed From v2.0

v2.0 fixed supply. Every component in the table had a producer and the bench worked.
It did not ask whether the components belonged on the items they were upgrading, and
they largely did not. A cloth vestment woven from herbs and petals was upgraded with
rabbit hide and an iron buckle.

v3.0 keeps every supply decision from v2.0 and re-cuts the recipe table so each line
pulls from its own material family.

**Carried forward unchanged from v2.0:**
- Fittings are produced by Runesmithing from Smelting bars, four recipes, yield 3.
- Binding Sigils and Runic Cog stay Gleaning rare drops with the attunement-gated rate
  split (idle rate unchanged, 8 to 16 percent on successful attunement).
- The Apparatus swap on the Artificing row.
- The Forge table cleanup (plain Runic Cog, no quality prefix).

**Changed in v3.0:**
- The metal Fitting is removed from Timber Shaping and Tailoring.
- Tailoring splits into two recipes keyed on `armorType`, Leather and Vestments.
- Two new component families, Sinew Cord (Tanning) and Spun Thread (Tailoring).
- Vestments move off leather and metal entirely and onto fiber plus botanicals.

---

## 1. Recipe Table

One row per resolver key. Components in brackets, rare after the arrow.

| assemblerTalent, armorType | Covers | Rough | Refined | Pristine | Masterwork |
|---|---|---|---|---|---|
| **Runesmithing**, None or Plate | metal weapons, Plate armor (44 items) | [Iron Fitting, Rough Binding Sigil] -> Crude Gemstone | [Steel Fitting, Refined Binding Sigil] -> Rough Gemstone | [Mithral Fitting, Pristine Binding Sigil] -> Refined Gemstone | [Adamant Fitting, Masterwork Binding Sigil] -> Pristine Gemstone |
| **Timber Shaping**, None | bows (6 items) | [Ash Haft, Rabbit Sinew Cord] -> Crude Amber | [Oak Haft, Fox Sinew Cord] -> Rough Amber | [Ironwood Haft, Wolf Sinew Cord] -> Refined Amber | [Heartwood Haft, Direwolf Sinew Cord] -> Pristine Amber |
| **Tailoring**, Leather | leather armor (25 items) | [Rabbit Hide, Rabbit Sinew Cord] -> Crude Amber | [Fox Leather, Fox Sinew Cord] -> Rough Amber | [Wolf Leather, Wolf Sinew Cord] -> Refined Amber | [Direwolf Leather, Direwolf Sinew Cord] -> Pristine Amber |
| **Tailoring**, Vestments | cloth vestments (25 items) | [Plain Thread, Herb Extract] -> Rough Binding Sigil | [Woven Thread, Rare Herb] -> Refined Binding Sigil | [Fine Thread, Moonbloom Petal] -> Pristine Binding Sigil | [Masterspun Thread, Shadow Essence] -> Masterwork Binding Sigil |
| **Artificing**, None | wands, staves, foci (17 items) | [Iron Apparatus, Ash Haft] -> Rough Binding Sigil | [Steel Apparatus, Oak Haft] -> Refined Binding Sigil | [Mithril Apparatus, Ironwood Haft] -> Pristine Binding Sigil | [Adamantine Apparatus, Heartwood Haft] -> Masterwork Binding Sigil |
| **Generic** fallback | unmapped items only | [Iron Fitting, Ash Haft] -> Rough Binding Sigil | [Steel Fitting, Oak Haft] -> Refined Binding Sigil | [Mithral Fitting, Ironwood Haft] -> Pristine Binding Sigil | [Adamant Fitting, Heartwood Haft] -> Masterwork Binding Sigil |

### 1.1 Line by line reasoning

**Metal, unchanged.** Fitting is metal hardware on a metal item and Runesmithing means
smithing runes into steel, so a Binding Sigil is the correct second component rather
than a foreign arcane import. Gemstone as the rare reads as pommel stones and setting
work. Nothing here was broken.

**Wood, Fitting out, Sinew Cord in.** A bow is a stave, a string, and a grip wrap. The
haft covers the stave, sinew covers the string, and Amber covers the resin used to glue
nocks and seal the limbs. There is no metal on a self bow anywhere.

**Leather, Fitting out, Sinew Cord in.** Leather armor is hide stitched to hide. Sinew
is the thread it is stitched with, drawn from the same animals as the panels. Amber
stays as the rare because it is the organic rare and it is already the leather line's
rare today.

**Vestments, the largest change.** Leather and metal are both gone. Vestments are woven
from botanical material and their entire craft ladder is Herb Extract, Rare Herb,
Moonbloom Petal, Shadow Essence. The upgrade now uses fiber (Spun Thread) plus the
matching botanical from that same ladder, with a Binding Sigil as the rare because
enchanted robes are the one armor line where an arcane rare belongs.

**Arcane, kept.** Apparatus plus Haft plus Binding Sigil. A staff has a wooden shaft and
a wand has a wooden core, so the haft is defensible and it keeps Timber Shaping selling
into the arcane line. No change.

### 1.2 Why wood and leather share both Sinew Cord and Amber

Two lines drawing on one component family and one rare looks like a shortcut. It is
deliberate. Both are organic lines fed by animals and trees, both already shared Amber
before this pass, and giving each its own bespoke cord and its own bespoke rare would
add four items and a rare family to save a table row from looking repetitive.

The lines stay distinguishable because component 1 differs and carries the identity:
Haft for a bow, Leather for armor.

---

## 2. New Components

Two families, eight items. Every other component in the table already exists.

### 2.1 Sinew Cord, produced by Tanning

Serves Timber Shaping and Tailoring/Leather. Grades follow the leather naming
convention (source animal, not a quality word) so the item never reads as a quality
grade.

| Name | Talent | Activity | Unlock | Inputs | Cycle | Yield |
|------|--------|----------|--------|--------|-------|-------|
| Rabbit Sinew Cord | Tanning | Draw Sinew, Rabbit | 8 | 2x Rabbit Pelt | 20s | 2 |
| Fox Sinew Cord | Tanning | Draw Sinew, Fox | 25 | 2x Fox Fur | 30s | 2 |
| Wolf Sinew Cord | Tanning | Draw Sinew, Wolf | 45 | 2x Wolf Pelt | 45s | 2 |
| Direwolf Sinew Cord | Tanning | Draw Sinew, Direwolf | 68 | 1x Direwolf Hide | 60s | 2 |

**Ladder placement.** Tanning's leather recipes sit at 1, 20, 40, 65. Sinew sits just
above each corresponding leather recipe at 8, 25, 45, 68, using the same tier of pelt.
The player unlocks the leather grade first and the cord shortly after, which is the
correct reading order and keeps the two recipes from competing for the same unlock beat.

**Curve safety.** Cycle times are shorter than the corresponding leather recipe and XP
per cycle should be set slightly lower, so xp per second lands close to the leather
recipe of the same tier and continues rising with tier. Do not make sinew the fastest
XP per second in Tanning at any tier. It is a side product, not a bypass.

**Supply pressure note.** Sinew competes with leather for the same pelts, which is
intended. It gives Trapping more demand and gives the player a real allocation decision
between panels and stitching.

### 2.2 Spun Thread, produced by Tailoring

Serves Tailoring/Vestments only. This is the "cloth" material the game currently lacks.

| Name | Talent | Activity | Unlock | Inputs | Cycle | Yield |
|------|--------|----------|--------|--------|-------|-------|
| Plain Thread | Tailoring | Spin Thread | 10 | 3x Wildgrass Clump | 25s | 2 |
| Woven Thread | Tailoring | Weave Thread | 30 | 1x Plain Thread + 4x Wildgrass Clump | 40s | 2 |
| Fine Thread | Tailoring | Spin Fine Thread | 55 | 1x Woven Thread + 5x Wildgrass Clump | 60s | 2 |
| Masterspun Thread | Tailoring | Masterspin | 75 | 1x Fine Thread + 6x Wildgrass Clump | 85s | 2 |

**Ladder placement.** Tailoring is currently an assembly talent with no processing
activities of its own. These four give it a production ladder and make it the only
discipline that both produces and consumes its own upgrade component, which suits a
weaving talent.

**Deliberately fiber-only.** The thread ladder takes no botanicals. The botanical enters
as component 2 in the recipe. Putting petals in both places would double-charge the
player for the same flavor and would make the botanical ladder illegible.

**Curve safety.** Escalating Wildgrass counts plus the previous grade give a rising
input cost per cycle. Set XP per cycle so xp per second rises across the four and lands
in the same band as Tanning's leather ladder at equivalent levels.

**This gives Wildgrass Clump a sink.** Foraging produces it today with, as far as I can
tell, no meaningful consumer. Flag in section 5 for verification.

### 2.3 The leaner alternative, if you want zero new vestment items

If eight new items is too many, the vestment row can drop Spun Thread and run on two
botanicals instead:

| Band | Alternative vestment recipe |
|------|----------------------------|
| Rough | [Herb Extract, Common Herb] -> Rough Binding Sigil |
| Refined | [Rare Herb, Herb Extract] -> Refined Binding Sigil |
| Pristine | [Moonbloom Petal, Rare Herb] -> Pristine Binding Sigil |
| Masterwork | [Shadow Essence, Moonbloom Petal] -> Masterwork Binding Sigil |

This costs nothing to build and is consistent with how vestments are crafted. I do not
recommend it, for one reason: every other line has a material component that reads as
part of the garment (Fitting, Haft, Leather grade), and a vestment upgraded entirely
from reagents reads like brewing a potion rather than reinforcing armor. Spun Thread
also solves the Wildgrass sink problem as a side effect.

Your call. The recipe table in section 1 assumes Spun Thread.

---

## 3. Resolver Note

The recipe key is `(assemblerTalent, armorType)`. No new field is required.

Mapping:

```
(Runesmithing, None)      -> metal row
(Runesmithing, Plate)     -> metal row, same recipe
(Timber Shaping, None)    -> wood row
(Tailoring, Leather)      -> leather row
(Tailoring, Vestments)    -> vestment row
(Artificing, None)        -> arcane row
anything else             -> Generic fallback
```

`(Runesmithing, Plate)` and `(Runesmithing, None)` intentionally resolve to the same
recipe. Plate and metal weapons are the same material family and splitting them would
add a row that says the same thing twice.

---

## 4. Asset Change Checklist

**Talent .asset files gaining activities:**

| File | Activities added |
|------|-----------------|
| Tanning | 4, Draw Sinew Rabbit / Fox / Wolf / Direwolf |
| Tailoring | 4, Spin Thread / Weave Thread / Spin Fine Thread / Masterspin |

**New ItemData assets to create (8):**

```
Rabbit Sinew Cord
Fox Sinew Cord
Wolf Sinew Cord
Direwolf Sinew Cord
Plain Thread
Woven Thread
Fine Thread
Masterspun Thread
```

All eight are crafting components, not equipment. No `armorType`, no `weaponType`, no
quality authored on the asset.

**Producers that change:** none. Every existing producer keeps its current outputs.
Tanning and Tailoring gain activities, they do not lose any.

**Recipe table edits in `AssemblyManager`:** replace all five rows plus Generic per
section 1. The Tailoring entry becomes two entries keyed on `armorType`.

**Art needed:** 8 new 64x64 item icons. Sinew cords read as coiled tan and grey cord,
graded by darkness and sheen. Threads read as wound spools, graded pale cream through
deep shadow-purple to mirror the vestment ladder.

---

## 5. Reality Check, Materials to Verify Before Implementing

I cannot read the Unity assets, so confirm these exist before wiring recipes to them.
If any is missing, create it rather than letting the resolver fall through to Generic.

| Material | Expected source | Confidence |
|----------|----------------|-----------|
| Wildgrass Clump | Foraging idle gather, T1 | Listed in the Foraging item sheet. Verify it is an authored ItemData and not just a tracker row. |
| Herb Extract | Alchemy, 3x Common Herb | Named in material-economy.md section 7. High. |
| Rare Herb | Foraging, low rate, T2 | High. |
| Moonbloom Petal | Foraging, rare, T3 | High. |
| Shadow Essence | Alchemy, 3x Shadow Pelt at Alchemy 60 | High. |
| Rabbit Pelt, Fox Fur, Wolf Pelt, Direwolf Hide | Trapping | High. |
| Ash / Oak / Ironwood / Heartwood Haft | Timber Shaping | High. |
| Iron / Steel / Mithril / Adamantine Apparatus | Artificing | High. |

Wildgrass Clump is the one I would check first. The whole Spun Thread ladder depends on
it and it is the material I have the least confirmation of.

---

## 6. Component Sinks After This Change

Nothing is stranded. Checked family by family.

| Component | Sinks before | Sinks after | Status |
|-----------|-------------|------------|--------|
| Fitting | Runesmithing, Timber, Tailoring, Generic | Runesmithing, Generic | Reduced but healthy. Runesmithing is 44 items, the largest line in the game, so Fitting demand stays the highest of any component. |
| Haft | Timber, Artificing, Generic | Timber, Artificing, Generic | Unchanged |
| Apparatus | Artificing | Artificing | Unchanged |
| Binding Sigil | Runesmithing, Artificing | Runesmithing, Artificing, Vestments | Gained a sink |
| Leather grades | Tailoring (both types) | Tailoring/Leather only | Reduced. Offset by Sinew Cord competing for the same pelts, so Tanning throughput demand is roughly flat. |
| Gemstone | Runesmithing | Runesmithing | Unchanged |
| Amber | Timber, Tailoring | Timber, Tailoring/Leather | Slightly reduced, vestments no longer draw on it |
| Wildgrass Clump | none that I can find | Spun Thread ladder | Gained its first real sink |

The one to watch is Amber. It loses the vestment line and now serves only 31 items
across two rows. If Amber supply feels loose after this ships, the fix is to raise the
Amber cost on the leather line rather than to reintroduce it to vestments.

---

## 7. Things In The Current Design I Think Are Wrong

The brief asked for this, so here it is, beyond the fittings issue.

**7.1 The Generic fallback fires silently.** With `(assemblerTalent, armorType)` covering
every authored line, Generic should now only catch items with an empty `assemblerTalent`,
which is a data bug rather than a legitimate case. Recommend logging a warning whenever
Generic resolves, naming the item. Keep the row so nothing hard-fails, but make it
audible. A silent fallback is how the vestment problem survived this long.

**7.2 Masterwork will be the dominant Binding Sigil sink and may break the v2 rate model.**
Masterwork is 20 percent base success and the rare is consumed on failure, so one
successful Masterwork upgrade costs about 5 Binding Sigils. Sigils are attunement-gated
rare drops at 8 to 16 percent. Three of the five recipe rows now use a Sigil as the rare
and one more uses it as a component. Before shipping, instrument actual Sigil throughput
against Masterwork attempt volume. If a Masterwork upgrade costs more Gleaning time than
it plausibly should, the lever is the attuned rate, not the recipe.

**7.3 Consuming the rare on failure is worth revisiting separately.** At Masterwork the
expected cost is five of everything, including the rare. That is a defensible endgame
tax, but it means the rare is doing double duty as both a rarity gate and a failure
tax. If Masterwork upgrades test as punishing, consider returning the rare on failure
while still consuming the components. That change is out of scope here and I am flagging
it, not proposing it.

**7.4 Drake Leather has no band.** The leather bands top out at Direwolf, so Drake
Leather is a tier material with no role in the upgrade bench. This is correct given
quality and tier are separate axes, but it will read as an omission to a player holding
Drake Leather and wondering why it does nothing at the bench. Worth a line of UI copy on
the item rather than a design change.

**7.5 The vestment line had no material component at all.** Worth stating plainly as the
root cause rather than a symptom. Metal, wood, and leather all have a material family
with grades. Cloth never got one, so whoever wrote the original table reached for the
nearest graded soft material, which was leather, and then needed a fastener, which was
the Fitting. The fix is not to pick better substitutes, it is to give the line the
material it was always missing. That is what Spun Thread is for.

---

## 8. Acceptance Criteria

- Upgrading a Vestment consumes no leather and no metal at any band.
- Upgrading a bow consumes no metal at any band.
- Upgrading leather armor consumes no metal at any band.
- `(Tailoring, Leather)` and `(Tailoring, Vestments)` resolve to different recipes.
- `(Runesmithing, None)` and `(Runesmithing, Plate)` resolve to the same recipe.
- All eight new components are craftable by a player who has levelled the producing
  talent to the listed unlock, using inputs that talent or its supplier already produces.
- Tanning xp per second still rises monotonically with tier after the four sinew
  activities are added.
- Tailoring xp per second rises monotonically across the four thread activities.
- The Generic fallback logs a warning naming any item that resolves to it.
- No new rarity enum exists. No quality field is named "tier". No Legendary item is
  authored.
- Every material referenced in section 1 resolves to an authored ItemData asset.

---

*Path: docs/upgrade-component-economy.md*
*Version 3.0 supersedes 2.0. Supply decisions from v2.0 carry forward unchanged.*
*Two new component families, eight items, two talents gain activities, one resolver*
*key change from assemblerTalent to (assemblerTalent, armorType).*
