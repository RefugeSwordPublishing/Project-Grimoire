---
type: design-spec
version: 2.0
updated: 2026-08-22
supersedes: upgrade-component-economy.md v1.0 (same path, do not implement v1.0)
path: docs/upgrade-component-economy.md
resolves: upgrade-component-economy-REQUEST.md, playtest bug #41
folds-into: material-economy.md (sections 8 and 9 below become the canonical tables)
implements: AssemblyManager.Recipes, Runesmithing activities, Gleaning attunement
            window, Gleaning rareLoot rate split
depends-on: Gleaning active attunement, not yet built, see section 7.3
---

# Upgrade Component Economy
### Version 2.0

---

## 0. Correction Notice, Read This First

**Version 1.0 of this document was wrong on one point and must not be implemented.**

v1.0 proposed moving Binding Sigils to an Inscription craft and Runic Cog to a
Runesmithing craft, on the reasoning that a sub-2% rare drop cannot be a required
recipe input. That reasoning failed to account for why the rates were set low in the
first place.

The 0.4% to 1% rates are deliberate. They exist because gathering runs unattended
overnight, and any rate high enough to feel reasonable in a 30-minute active session
prints a fortune across an 8-hour idle session. The rate was tuned against the
overnight case on purpose, to protect the economy.

So the problem was never the rate and never the drop model. It is that a single global
rate has to serve two session types roughly 20 times apart in duration. Tune for
overnight and active play starves. Tune for active and overnight breaks the economy.
No single number satisfies both. That is a rate-model problem wearing a supply-bug
costume, and v1.0 treated the costume.

**What v2.0 changes instead:** rare drops stay rare drops, produced by Gleaning, at
their existing idle rate. An elevated rate is attached to active attunement, which idle
play cannot trigger. See section 7.

**What survives from v1.0 unchanged:** the Fitting producer (section 3) and the
Apparatus swap on the Artificing bench row (section 4). Neither touches drop rates.

---

## 1. The Three Decisions

**Fittings get a producer.** Runesmithing crafts them from the matching Smelting bar,
one recipe per band. A Fitting is manufactured hardware with no source at all today,
and hardware is not something a player finds in the dirt. This is the only genuine
dead component in the system.

**Fittings and Apparatus are not merged.** Different axes. What changes is one token:
Artificing's bench recipe uses its own Apparatus in place of a Fitting. Section 4.

**Binding Sigils and Runic Cog stay Gleaning rare drops.** Their idle rate does not
change. An elevated rate is added, gated behind active attunement so that unattended
sessions cannot access it. Section 7.

---

## 2. Diagnosis

Two separate faults were reported together, and they are not the same fault.

**Fault one, Fittings.** Required by all four bench recipes, produced by nothing. This
is a straightforward dead component and it has a straightforward fix: give it a recipe.
Every other component family in the bench already has a producer.

**Fault two, Binding Sigils at 0.4% to 1%.** Not a dead component. A working drop with
a rate correctly tuned for the wrong session type. Gleaning runs unattended overnight,
so the rate had to be set against an 8-hour unsupervised session. That protects the
economy and it is the right instinct. The side effect is that a player doing 40 minutes
of hands-on Gleaning sees nothing, which is what bug #41 actually reported.

The governing observation is that these two faults want opposite fixes. Fittings need a
new producer. Sigils need their existing producer to distinguish between a player who is
present and one who is asleep.

**Principle to adopt:**

> When a drop rate must serve both idle and active play, do not pick a compromise
> number. Split the roll: keep the idle rate, and attach the elevated rate to
> attunement, which idle cannot reach.

This generalises past Gleaning. Any future rare that faces the same overnight problem
gets the same treatment rather than a new tuning argument.

---

## 3. Fittings, New Runesmithing Recipes

Unchanged from v1.0. Runesmithing owns Fitting production, which gives three of the four
benches a Runesmithing supplier and makes the talent economically load-bearing.

| Output | Inputs | Runesmithing level | Time | Yield |
|--------|--------|-------------------|------|-------|
| Iron Fitting | 1x Iron Bar | 10 | 30s | 3 |
| Steel Fitting | 1x Steel Bar | 30 | 45s | 3 |
| Mithral Fitting | 1x Mithril Bar | 60 | 90s | 3 |
| Adamant Fitting | 1x Void Alloy | 80 | 120s | 3 |

### 3.1 Why yield 3, uniformly

The bench consumes components on failure as well as success, so the true cost of an
upgrade is one component times expected attempts, not one component.

| Band | Base success | Expected attempts | At assembler 100 | Expected attempts |
|------|-------------|------------------|-----------------|------------------|
| Rough | 70% | 1.43 | 88% | 1.14 |
| Refined | 55% | 1.82 | 73% | 1.37 |
| Pristine | 35% | 2.86 | 53% | 1.89 |
| Masterwork | 20% | 5.00 | 38% | 2.63 |

A flat yield of 3 covers a Rough or Refined chain comfortably, roughly covers a Pristine
chain, and covers about 60% of a Masterwork chain. Cost escalation comes from the input
bar getting dramatically more expensive up the ladder, not from a yield curve. One
number to remember and the economy still steepens correctly.

### 3.2 Level placement

Each Fitting unlocks at or just above the Smelting level producing its input bar. Iron
Bar is Smelting 10 and Iron Fitting is Runesmithing 10. Steel Bar is Smelting 30 and
Steel Fitting is Runesmithing 30. Mithril and Void follow at 60 and 80 against Smelting
60 and 85.

---

## 4. The Fitting versus Apparatus Question, Answered

Unchanged from v1.0.

**Do not merge them.** Apparatus is a tier intermediate consumed by Staff, Wand, Alchemy
Kit, Cookery Set, Tanning Knife, and Forge crafting. Collapsing it into the band-keyed
Fitting family strands all six of those tier recipes. The merge trades one dead
component for six.

**Do swap Apparatus in for Fitting on the Artificing bench row only.** As built,
Artificing produces none of its own upgrade components while depending on Runesmithing,
Timber Shaping, and Gleaning simultaneously. Every other discipline contributes
something from its own or an immediately adjacent talent. Artificing already makes
exactly the right item.

One token, one row. It satisfies the instinct behind the question without the structural
damage of a global merge.

Band mapping on the bench: Iron, Steel, Mithril, Adamantine Apparatus. Steel Clockwork
Apparatus stays a tier-only intermediate and is not used by the bench.

---

## 5. Binding Sigils Stay Gleaning Drops

**Reversing v1.0.** No Inscription craft. Binding Sigils remain Gleaning rare drops,
found not made. Gleaning's identity is finding the valuable thing, and moving its
signature output into another talent's recipe list would demote a talent that does not
need demoting.

The four bands and their existing Gleaning sources are unchanged:

| Item | Gleaning source node |
|------|---------------------|
| Rough Binding Sigil | Runic Deposits |
| Refined Binding Sigil | Deep Runes |
| Pristine Binding Sigil | Ancient Runes |
| Masterwork Binding Sigil | Voidtouched |

What changes is the rate model, not the source. Section 7.

---

## 6. Runic Cog Stays a Gleaning Drop

**Reversing v1.0.** No Runesmithing craft. Runic Cog remains a Gleaning rare drop and
receives the same attunement treatment as Binding Sigils.

One genuine cleanup does still apply. The Forge upgrade table in material-economy.md
section 3 references quality-graded Runic Cogs (Crude, Rough, Refined, Pristine) that do
not exist as items. Runic Cog is a single ungraded component. Update those four rows to
reference plain Runic Cog with no quality prefix. This is an asset-reference bug, not an
economy change.

---

## 7. The Rate Split, Idle Versus Attuned

The fix for bug #41. One item, one drop table, two roll rates.

### 7.1 The model

| Gathering action | Rare roll rate |
|-----------------|---------------|
| Idle gather, unattended | Existing rate, unchanged, 0.4% to 1% by band |
| Successful attunement, active | Elevated rate, 8% to 16% by band |
| Active gather without attunement | Idle rate, unchanged |

Attunement requires a timed player input on the gathering window. It cannot fire while
the app is backgrounded or the player is asleep, so an overnight session accrues at
exactly the rate you already tuned it to. The overnight economy is protected by
construction rather than by picking a compromise number.

Note the third row. Merely being in the app is not enough. The elevated rate attaches to
a successful attunement, not to an active session, which keeps the reward tied to
attention rather than presence.

### 7.2 Rates by band

Elevated rates scale down by band so Masterwork stays the scarcest thing in the ladder
and the relative rarity ordering the current table already establishes is preserved.

| Item | Idle rate (unchanged) | Attuned rate |
|------|----------------------|-------------|
| Rough Binding Sigil | 1.0% | 16% |
| Refined Binding Sigil | 0.8% | 13% |
| Pristine Binding Sigil | 0.6% | 10% |
| Masterwork Binding Sigil | 0.4% | 8% |
| Runic Cog | existing | 12% |

Ancient Sigil and Master Glyph are genuine rares rather than recipe inputs. They may
receive the attuned bonus at the implementer's discretion, but they are not required to
and nothing depends on them.

### 7.3 Dependency, Gleaning attunement is not built yet

Gleaning has no active attunement window today. It is next on the build list. This
section cannot ship before that lands.

**Sequencing for Code:**

1. Build the Gleaning attunement window, matching the pattern already used by the other
   gathering talents.
2. Then wire the rare-roll split in section 7.1, keyed on attunement success.
3. Ship the Fitting recipes (section 3) and the Artificing row edit (section 4)
   independently. Neither depends on attunement, and together they close the hard
   blocker in bug #41.

Steps 1 and 2 fix the scarcity complaint. Step 3 fixes the dead component. Step 3 can
and should go first, because the bench is unusable until it does.

---

## 8. Canonical Bench Recipe Table

Fold this into material-economy.md. Every entry references an item with a real producer,
listed in section 9.

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
Rare axis: Binding Sigil (Gleaning)
Change from as-built: Apparatus replaces Fitting in component slot 1.

| Band | Component 1 | Component 2 | Rare |
|------|------------|------------|------|
| Rough | Iron Apparatus | Ash Haft | Rough Binding Sigil |
| Refined | Steel Apparatus | Oak Haft | Refined Binding Sigil |
| Pristine | Mithril Apparatus | Ironwood Haft | Pristine Binding Sigil |
| Masterwork | Adamantine Apparatus | Heartwood Haft | Masterwork Binding Sigil |

### Crude band
Crude items are built fresh from tier components in the owning talent and do not use the
bench. No Crude row exists in any table above.

---

## 9. Producer for Every Referenced Component

| Component | Producer | Activity | Level | Status |
|-----------|---------|----------|-------|--------|
| Iron Fitting | Runesmithing | 1x Iron Bar to 3x | 10 | NEW |
| Steel Fitting | Runesmithing | 1x Steel Bar to 3x | 30 | NEW |
| Mithral Fitting | Runesmithing | 1x Mithril Bar to 3x | 60 | NEW |
| Adamant Fitting | Runesmithing | 1x Void Alloy to 3x | 80 | NEW |
| Rough Binding Sigil | Gleaning | Runic Deposits, rare drop | existing | rate split |
| Refined Binding Sigil | Gleaning | Deep Runes, rare drop | existing | rate split |
| Pristine Binding Sigil | Gleaning | Ancient Runes, rare drop | existing | rate split |
| Masterwork Binding Sigil | Gleaning | Voidtouched, rare drop | existing | rate split |
| Runic Cog | Gleaning | rare drop | existing | rate split |
| Ash / Oak / Ironwood / Heartwood Haft | Timber Shaping | Log to Haft | existing | built |
| Rabbit Hide / Fox / Wolf / Direwolf Leather | Tanning | Pelt to Leather | existing | built |
| Iron / Steel / Mithril / Adamantine Apparatus | Artificing | Bar plus sigil input | existing | built |
| Crude / Rough / Refined / Pristine Gemstone | Delving | Idle gather, gem deposits | existing | built |
| Crude / Rough / Refined / Pristine Amber | Delving | Idle gather, cave resin | existing | built |
| Iron / Steel / Mithril Bar, Void Alloy | Smelting | Ore to bar | existing | built |

Four new recipes on one talent. Everything else is an existing producer, with five
Gleaning entries gaining a second roll rate.

---

## 10. Resulting Supply Dependencies

| Discipline | Depends on |
|-----------|-----------|
| Runesmithing | Smelting (bars), Delving (gems), Gleaning (sigils) |
| Timber Shaping | Felling (logs), Runesmithing (fittings), Delving (amber) |
| Tailoring | Tanning (leather), Runesmithing (fittings), Delving (amber) |
| Artificing | Smelting (bars), Timber Shaping (hafts), Gleaning (sigils) |

Every discipline needs two or three suppliers and every discipline supplies someone
else. Runesmithing becomes the hardware supplier for three of the four benches. Delving
and Gleaning are the two load-bearing gathering talents. No discipline is fully
self-sufficient and none is a dead end.

---

## 11. What Claude Code Builds

**Ship first, closes the hard blocker, no dependencies:**

1. **Four Fitting recipes** on Runesmithing, section 3. ItemData assets already exist in
   `Assets/Data/Items/Assembly/` and only lack producers.
2. **One recipe-table edit** in `AssemblyManager.Recipes`: the Artificing row's component
   1 changes from Fitting to Apparatus, section 8.
3. **Forge table cleanup**: material-economy.md section 3 references quality-graded Runic
   Cogs that do not exist. Change all four rows to plain Runic Cog.
4. **Fold sections 8 and 9 into material-economy.md** as the canonical component tables.

**Ship after Gleaning attunement lands:**

5. **Gleaning active attunement window**, matching the pattern used by the other
   gathering talents.
6. **Rare-roll rate split**, section 7. Idle rate unchanged, attuned rate 8% to 16% by
   band, keyed on attunement success and not merely on an active session.

**Do not build:** the Inscription Binding Sigil recipes or the Runesmithing Runic Cog
recipe proposed in v1.0 of this document. Both are retracted.

---

## 12. Acceptance Criteria

- Every component named in section 8 resolves to an item with a producer in section 9.
- A player can craft an Iron Fitting from an Iron Bar at Runesmithing 10.
- The Artificing bench recipe consumes an Apparatus, not a Fitting.
- Apparatus items remain consumable by Staff, Wand, and tool tier crafting. Nothing that
  previously consumed an Apparatus has stopped working.
- The Forge upgrade table references plain Runic Cog with no quality prefix.
- Binding Sigils and Runic Cog are obtainable only from Gleaning. No craft recipe exists
  for either.
- An 8-hour unattended idle Gleaning session yields the same expected number of rares as
  it does today. The idle rate is byte-identical to the pre-change value.
- A successful Gleaning attunement rolls the elevated rate. An active gather without
  attunement rolls the idle rate.
- Bug #41 closes in two parts: items 1 and 2 make the bench operable at all, and items 5
  and 6 make Sigil supply reachable through active play.

---

*Path: docs/upgrade-component-economy.md*
*Version 2.0 supersedes 1.0. Corrections in section 0.*
*Decisions: Fittings get a Runesmithing producer, Apparatus replaces Fitting on the*
*Artificing bench row only, Binding Sigils and Runic Cog stay Gleaning rare drops with*
*an attunement-gated elevated rate that idle play cannot reach.*
