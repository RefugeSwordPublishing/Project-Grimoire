---
type: design-spec
version: 1.0
updated: 2026-08-22
path: docs/upgrade-component-economy.md
resolves: upgrade-component-economy-REQUEST.md
folds-into: material-economy.md (add as sections 6.1, 6.2, and 11)
implements: AssemblyManager.Recipes, Runesmithing activities, Inscription activities,
            Gleaning rareLoot re-role
trigger: Playtest bug #41, Fittings have no producer so the upgrade bench is unusable.
---

# Upgrade Component Economy
### Version 1.0

---

## 1. The Three Decisions, Up Front

**Fittings get a producer. They are not retired.** Runesmithing crafts them from the
matching Smelting bar, one recipe per band. A Fitting is a bar that has been smithed
into hardware, which is exactly what the item names already imply.

**Fittings and Apparatus are not merged.** They sit on different axes and merging them
would break tier crafting. What changes is one token: Artificing's upgrade recipe uses
its own Apparatus in place of a Fitting. Full reasoning in section 4.

**Binding Sigils become craftable, not rarer.** Inscription crafts them from Gleaning's
regular output. The Gleaning rare drops stay rare and are re-roled from "only source"
to "found ready-made, skip the craft." Runic Cog gets the same treatment via Runesmithing.

---

## 2. Diagnosis and the Governing Principle

The Fitting dead-end and the 0.4% Sigil are the same bug in two costumes: a required
recipe input whose supply the player cannot plan around. One has no supply at all, the
other has supply the player cannot count on. Both make the bench feel broken rather
than expensive.

**Principle, adopt this as a standing rule:**

> No required recipe input is a sub-2% rare drop. Rare drops gate speed and luck.
> Crafted and gathered items gate feasibility.

Everything below follows from that. The rare slot on the bench is allowed to be a
gathered item with meaningful cost (Gemstone, Amber) because Delving produces those on
a normal curve. It is not allowed to be a lottery ticket.

A second observation worth naming. Fitting appears in all four as-built recipes, which
reads as a mistake but is actually correct: it is the generic metal hardware that goes
into a bow's nocks, a leather jerkin's rivets, and a sword's furniture alike. The
family earns its place. It simply never got a recipe.

---

## 3. Fittings, New Runesmithing Recipes

Runesmithing owns Fitting production. This gives every other discipline a Runesmithing
supplier, which is the correct shape for an Exchange-driven economy and gives solo
players one more talent worth levelling.

| Output | Inputs | Runesmithing level | Time | Yield |
|--------|--------|-------------------|------|-------|
| Iron Fitting | 1x Iron Bar | 10 | 30s | 3 |
| Steel Fitting | 1x Steel Bar | 30 | 45s | 3 |
| Mithral Fitting | 1x Mithril Bar | 60 | 90s | 3 |
| Adamant Fitting | 1x Void Alloy | 80 | 120s | 3 |

### 3.1 Why yield 3, uniformly

The bench consumes components on failure as well as success, so the real cost of an
upgrade is not one component, it is one component times the expected number of attempts.

| Band | Base success | Expected attempts | At assembler 100 | Expected attempts |
|------|-------------|------------------|-----------------|------------------|
| Rough | 70% | 1.43 | 88% | 1.14 |
| Refined | 55% | 1.82 | 73% | 1.37 |
| Pristine | 35% | 2.86 | 53% | 1.89 |
| Masterwork | 20% | 5.00 | 38% | 2.63 |

A flat yield of 3 means one bar comfortably covers a Rough or Refined attempt chain,
roughly covers a Pristine chain, and covers about 60% of a Masterwork chain. The cost
escalation comes from the bar itself getting dramatically more expensive up the ladder
(Iron Ore at T1 versus Void Alloy needing Mithril Bar plus Soulite Crystal at T5), not
from a fiddly yield curve. One number to remember, and the economy still steepens.

### 3.2 Level placement

Each Fitting unlocks at or just above the Smelting level that produces its input bar,
so a player who can smelt the bar can shortly smith the fitting. Iron Bar is Smelting
10 and Iron Fitting is Runesmithing 10. Steel Bar is Smelting 30 and Steel Fitting is
Runesmithing 30. Mithril and Void follow at 60 and 80 against Smelting 60 and 85.

---

## 4. The Fitting versus Apparatus Question, Answered

**Do not merge them.** Apparatus is a tier intermediate consumed by Staff, Wand,
Alchemy Kit, Cookery Set, Tanning Knife, and Forge crafting. Collapsing it into the
band-keyed Fitting family would strand every one of those tier recipes. The merge
would trade one dead component for six.

**Do swap Apparatus in for Fitting on the Artificing bench recipe only.** As built,
Artificing's upgrade recipe is Fitting plus Haft plus Binding Sigil, which means the
arcane discipline produces none of its own upgrade components and depends on
Runesmithing, Timber Shaping, and Gleaning simultaneously. Every other discipline
contributes something from its own or its immediately adjacent talent. Artificing
should too, and it already makes exactly the right item.

This is a one-token change to one row of the recipe table. It answers the instinct
behind the question (use Apparatus where Apparatus makes sense) without the structural
damage of a global merge.

Band mapping for Apparatus on the bench: Iron, Steel, Mithril, Adamantine. Steel
Clockwork Apparatus stays a tier-only intermediate and is not used by the bench.

---

## 5. Binding Sigils, New Inscription Recipes

Move Binding Sigils out of the rare-drop table and into Inscription as a deterministic
craft. Inscription is the rune and scribing discipline, it currently has thin economic
demand, and Gleaning's regular output (Crude Rune Shard, Minor Enchant Seal) plus
Inscription's own Vellum are the natural inputs.

| Output | Inputs | Inscription level | Time |
|--------|--------|------------------|------|
| Rough Binding Sigil | 2x Crude Rune Shard + 1x Vellum | 10 | 45s |
| Refined Binding Sigil | 4x Crude Rune Shard + 1x Minor Enchant Seal + 1x Fine Vellum | 30 | 75s |
| Pristine Binding Sigil | 3x Minor Enchant Seal + 1x Runed Vellum | 55 | 120s |
| Masterwork Binding Sigil | 6x Minor Enchant Seal + 2x Runed Vellum | 75 | 180s |

Every input is regular output of a talent the player can grind deliberately. Crude Rune
Shard and Minor Enchant Seal are Gleaning's standard drops. Vellum grades come from
Tanning via the Inscription pipeline. Nothing here is a lottery.

Yield is 1 per craft. Unlike Fittings, Sigils appear in only two of the four bench
recipes, so total demand is lower and a yield of 1 keeps Inscription's throughput
meaningful without flooding.

---

## 6. Runic Cog, Same Fix

Runic Cog is flagged in the request as the same class of problem: a Gleaning rare at
roughly 1% that is a required input for Steel Clockwork Apparatus and every band of the
Forge upgrade table. Give it a producer.

| Output | Inputs | Runesmithing level | Time | Yield |
|--------|--------|-------------------|------|-------|
| Runic Cog | 1x Steel Bar + 1x Crude Rune Shard | 40 | 60s | 2 |

A cog is a machined metal part with a rune cut into it. Runesmithing is the right owner
and it keeps the Fitting and Cog production in one place.

Note: the Forge upgrade table in material-economy.md section 3 references Crude, Rough,
Refined, and Pristine Runic Cog as quality-graded variants. Those graded variants do not
exist as separate items. Treat Runic Cog as a single ungraded component and update the
Forge table to reference it without a quality prefix. Flagged for Code in section 10.

---

## 7. Gleaning Rare Drops, Re-Roled

Do not raise the rare rates. Change what the rares mean.

| Item | Old role | New role |
|------|---------|---------|
| Rough Binding Sigil | Only source, 1% | Found ready-made, skips the Inscription craft |
| Refined Binding Sigil | Only source, 0.8% | Found ready-made, skips the craft |
| Pristine Binding Sigil | Only source, 0.6% | Found ready-made, skips the craft |
| Masterwork Binding Sigil | Only source, 0.4% | Found ready-made, skips the craft |
| Runic Cog | Only source | Found ready-made, skips the Runesmithing craft |
| Ancient Sigil | Rare drop | Unchanged, stays a genuine rare, Void Foci input |
| Master Glyph | Rare drop | Unchanged |

Rates can stay where they are, or rise modestly to 1.5% to 2% now that nothing depends
on them. A rare drop that saves you a craft is a pleasant surprise. A rare drop that is
the only path is a wall. Same item, same rate, entirely different feel.

---

## 8. Canonical Bench Recipe Table

This is the table to fold into material-economy.md. Every entry references an item with
a real producer, listed in section 9.

### Runesmithing, weapons and Plate armour
Rare axis: Gemstone (Delving)

| Band | Component 1 | Component 2 | Rare |
|------|------------|------------|------|
| Rough | Iron Fitting | Rough Binding Sigil | Crude Gemstone |
| Refined | Steel Fitting | Refined Binding Sigil | Rough Gemstone |
| Pristine | Mithral Fitting | Pristine Binding Sigil | Refined Gemstone |
| Masterwork | Adamant Fitting | Masterwork Binding Sigil | Pristine Gemstone |

### Timber Shaping, bows and wooden tools
Rare axis: Amber (Delving)

| Band | Component 1 | Component 2 | Rare |
|------|------------|------------|------|
| Rough | Ash Haft | Iron Fitting | Crude Amber |
| Refined | Oak Haft | Steel Fitting | Rough Amber |
| Pristine | Ironwood Haft | Mithral Fitting | Refined Amber |
| Masterwork | Heartwood Haft | Adamant Fitting | Pristine Amber |

### Tailoring, leather armour, Vestments, Quiver
Rare axis: Amber (Delving)

| Band | Component 1 | Component 2 | Rare |
|------|------------|------------|------|
| Rough | Rabbit Hide | Iron Fitting | Crude Amber |
| Refined | Fox Leather | Steel Fitting | Rough Amber |
| Pristine | Wolf Leather | Mithral Fitting | Refined Amber |
| Masterwork | Direwolf Leather | Adamant Fitting | Pristine Amber |

### Artificing, staves, wands, arcane tools
Rare axis: Binding Sigil (Inscription)
Change from as-built: Apparatus replaces Fitting in component slot 1.

| Band | Component 1 | Component 2 | Rare |
|------|------------|------------|------|
| Rough | Iron Apparatus | Ash Haft | Rough Binding Sigil |
| Refined | Steel Apparatus | Oak Haft | Refined Binding Sigil |
| Pristine | Mithril Apparatus | Ironwood Haft | Pristine Binding Sigil |
| Masterwork | Adamantine Apparatus | Heartwood Haft | Masterwork Binding Sigil |

### Crude band
Crude items are built fresh from tier components in the owning talent and do not use
the bench. No Crude row exists in any of the tables above.

---

## 9. Producer for Every Referenced Component

| Component | Producer | Activity | Level | Status |
|-----------|---------|----------|-------|--------|
| Iron Fitting | Runesmithing | 1x Iron Bar to 3x | 10 | NEW |
| Steel Fitting | Runesmithing | 1x Steel Bar to 3x | 30 | NEW |
| Mithral Fitting | Runesmithing | 1x Mithril Bar to 3x | 60 | NEW |
| Adamant Fitting | Runesmithing | 1x Void Alloy to 3x | 80 | NEW |
| Runic Cog | Runesmithing | 1x Steel Bar + 1x Crude Rune Shard to 2x | 40 | NEW |
| Rough Binding Sigil | Inscription | 2x Crude Rune Shard + 1x Vellum | 10 | NEW |
| Refined Binding Sigil | Inscription | 4x Crude Rune Shard + 1x Minor Enchant Seal + 1x Fine Vellum | 30 | NEW |
| Pristine Binding Sigil | Inscription | 3x Minor Enchant Seal + 1x Runed Vellum | 55 | NEW |
| Masterwork Binding Sigil | Inscription | 6x Minor Enchant Seal + 2x Runed Vellum | 75 | NEW |
| Ash / Oak / Ironwood / Heartwood Haft | Timber Shaping | Log to Haft | existing | built |
| Rabbit Hide / Fox / Wolf / Direwolf Leather | Tanning | Pelt to Leather | existing | built |
| Iron / Steel / Mithril / Adamantine Apparatus | Artificing | Bar + sigil input | existing | built |
| Crude / Rough / Refined / Pristine Gemstone | Delving | Idle gather, gem deposits | existing | built |
| Crude / Rough / Refined / Pristine Amber | Delving | Idle gather, cave resin | existing | built |
| Iron / Steel / Mithril Bar, Void Alloy | Smelting | Ore to bar | existing | built |
| Crude Rune Shard, Minor Enchant Seal | Gleaning | Idle gather, regular output | existing | built |
| Vellum / Fine Vellum / Runed Vellum | Tanning to Inscription | Pelt to vellum | existing | built |

Nine new recipes across two talents. Nothing else changes.

---

## 10. Resulting Supply Dependencies

Worth stating plainly, because this is the economy the change creates.

| Discipline | Depends on |
|-----------|-----------|
| Runesmithing | Smelting (bars), Delving (gems), Inscription (sigils) |
| Timber Shaping | Felling (logs), Runesmithing (fittings), Delving (amber) |
| Tailoring | Tanning (leather), Runesmithing (fittings), Delving (amber) |
| Artificing | Smelting (bars), Timber Shaping (hafts), Inscription (sigils) |

Every discipline needs two or three suppliers and every discipline supplies someone
else. Runesmithing becomes the hardware supplier for three of the four benches, and
Inscription gains real demand for the first time. Delving stays the single most
economically load-bearing gathering talent, which section 2 of material-economy.md
already called out as intended.

No discipline is fully self-sufficient and none is a dead end.

---

## 11. What Claude Code Builds

1. **Four Fitting recipes** on Runesmithing, per section 3. New ItemData assets already
   exist in `Assets/Data/Items/Assembly/`, they only lack producers.
2. **One Runic Cog recipe** on Runesmithing, per section 6.
3. **Four Binding Sigil recipes** on Inscription, per section 5.
4. **One recipe-table edit** in `AssemblyManager.Recipes`: the Artificing row's
   component 1 changes from Fitting to Apparatus, per section 8.
5. **Gleaning rareLoot re-role**, per section 7. Rates may stay as-is. The items remain
   in the table, they are no longer the only source.
6. **Forge table cleanup**: material-economy.md section 3 references quality-graded
   Runic Cogs (Crude, Rough, Refined, Pristine) that do not exist as items. Change all
   four rows to reference plain Runic Cog.
7. **Fold sections 8 and 9 of this doc into material-economy.md** as the canonical
   component tables.

---

## 12. Acceptance Criteria

- Every component named in the section 8 tables resolves to an item with a producer
  listed in section 9.
- A player can craft an Iron Fitting from an Iron Bar at Runesmithing 10.
- A player can craft a Rough Binding Sigil at Inscription 10 without any rare drop.
- No recipe input anywhere in the bench tables is a sub-2% rare drop.
- The Artificing bench recipe consumes an Apparatus, not a Fitting.
- Apparatus items remain consumable by Staff, Wand, and tool tier crafting. Nothing that
  previously consumed an Apparatus has stopped working.
- The Forge upgrade table references plain Runic Cog with no quality prefix.
- Gleaning still drops Binding Sigils and Runic Cogs, and finding one lets the player
  skip the corresponding craft.
- Bug #41 closes: a player at Runesmithing 10 and Inscription 10 with a stocked Delving
  supply can complete a Crude to Rough upgrade on every one of the four disciplines.

---

*Path: docs/upgrade-component-economy.md*
*Resolves: upgrade-component-economy-REQUEST.md and playtest bug #41.*
*Decisions: Fittings get a Runesmithing producer, Apparatus replaces Fitting on the*
*Artificing bench row only, Binding Sigils and Runic Cogs become craftable and their*
*rare drops re-role to shortcuts. Nine new recipes, one recipe-table edit.*
