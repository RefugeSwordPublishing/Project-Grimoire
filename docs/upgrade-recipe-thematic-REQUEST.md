---
type: design-request
for: Chat (claude.ai design collaborator)
from: Claude Code
date: 2026-08-24
subject: Reorganize the quality-upgrade recipes so upgrade materials match the item's material class
read-first: docs/implementation-status.md, then docs/upgrade-component-economy.md (the current v2)
---

# Request: thematic upgrade recipes (upgrade-component-economy v3)

## The problem, in one line

Every discipline's upgrade recipe currently forces a **metal "Fitting"** into the mix, so
cloth vestments and leather armor both demand a metal buckle to upgrade, and cloth vestments
(which are crafted from herbs and petals) are upgraded with **animal hide plus a metal fitting**.
The upgrade materials should match what the item is actually made of.

We want you to redesign the upgrade recipe table so each material line pulls thematically correct
components. This is a **design pass**; Claude Code implements the result. You cannot read the Unity
code, so everything you need about the current build is below. Please build on it rather than
re-deriving it.

---

## How the upgrade bench works today (as-built, `AssemblyManager`)

- Quality is an instance flag on an inventory stack. An upgrade walks one item **one quality step**:
  `Crude -> Rough -> Refined -> Pristine -> Masterwork`. (`Legendary` exists in the enum but is never
  authored; do not use it.) Quality is rarity, and is a **separate axis from Tier** (level gating).
  Never conflate the two, and never rename a quality field "tier".
- A recipe is chosen by the item's **`assemblerTalent`** and the **target quality band**. Each recipe is:
  `[one or more component items] + exactly one "rare" material`. All of them are consumed **whether the
  upgrade succeeds or fails** (failure does not downgrade; it just costs the mats). Assembly XP is
  awarded to the `assemblerTalent` **win or lose**.
- Base success per band (before the assembler's small per-level bonus): Rough 70%, Refined 55%,
  Pristine 35%, Masterwork 20%.
- The resolver can key on any field an item carries. Relevant ones that already exist on every item:
  - `assemblerTalent` (string): Runesmithing / Timber Shaping / Tailoring / Artificing (or empty).
  - `armorType` (enum): **None, Plate, Leather, Vestments**.  <-- this is the hook that lets leather and
    cloth get different recipes even though both are `assemblerTalent: Tailoring`.
  - `weaponType` (enum), `materialTier` (int 1..6), `category`.
  So a recipe table keyed by `(assemblerTalent, armorType)` is available with no new data model.
  If you need a finer split than that, say so and I will add a field.

### Current recipe table (exact)

Components in brackets, rare after the arrow. Bands are the four upgrade steps.

| assemblerTalent | Covers | Rough | Refined | Pristine | Masterwork |
|---|---|---|---|---|---|
| **Runesmithing** | metal weapons + Plate armor | [Iron Fitting, Rough Binding Sigil] -> Crude Gemstone | [Steel Fitting, Refined Binding Sigil] -> Rough Gemstone | [Mithral Fitting, Pristine Binding Sigil] -> Refined Gemstone | [Adamant Fitting, Masterwork Binding Sigil] -> Pristine Gemstone |
| **Timber Shaping** | wood weapons (bows) | [Ash Haft, Iron Fitting] -> Crude Amber | [Oak Haft, Steel Fitting] -> Rough Amber | [Ironwood Haft, Mithral Fitting] -> Refined Amber | [Heartwood Haft, Adamant Fitting] -> Pristine Amber |
| **Tailoring** | **Leather AND Vestments (one recipe for both)** | [Rabbit Hide, Iron Fitting] -> Crude Amber | [Fox Leather, Steel Fitting] -> Rough Amber | [Wolf Leather, Mithral Fitting] -> Refined Amber | [Direwolf Leather, Adamant Fitting] -> Pristine Amber |
| **Artificing** | arcane foci (wands/staves) | [Iron Apparatus, Ash Haft] -> Rough Binding Sigil | [Steel Apparatus, Oak Haft] -> Refined Binding Sigil | [Mithril Apparatus, Ironwood Haft] -> Pristine Binding Sigil | [Adamantine Apparatus, Heartwood Haft] -> Masterwork Binding Sigil |
| **Generic** (fallback) | anything unmapped | [Iron Fitting, Ash Haft] -> Rough Binding Sigil | [Steel Fitting, Oak Haft] -> Refined Binding Sigil | [Mithral Fitting, Ironwood Haft] -> Pristine Binding Sigil | [Adamant Fitting, Heartwood Haft] -> Masterwork Binding Sigil |

The **Fitting** (a metal component) appears in Runesmithing (fine), but also Timber Shaping, Tailoring,
and Generic, which is where it feels wrong.

---

## The item taxonomy (what actually needs upgrading)

| assemblerTalent | armorType | Lines (low -> high tier) | Count |
|---|---|---|---|
| Runesmithing | None (weapons) + **Plate** | swords/daggers/axes/plate: Bronze -> Iron -> Steel -> Mithril -> Void | 44 |
| Timber Shaping | None (weapons) | bows: Bronze -> Iron -> Steel -> Mithril -> Void | 6 |
| Artificing | None (foci) | wands/staves + apparatus foci | 17 |
| **Tailoring** | **Leather** | Rabbit-Hide -> Fox -> Wolf -> Direwolf -> Drake Scale | 25 |
| **Tailoring** | **Vestments** | Cloth -> Woven -> Emberpetal -> Shadow -> Void | 25 |

### The two Tailoring supply chains are completely different

- **Leather armor** is crafted and fed from **Tanning**: Rabbit Hide, Fox Leather, Wolf Leather,
  Direwolf Leather, Drake Leather. Hunting/Trapping supplies the raw hides. Leather using leather to
  upgrade is fine; the metal Fitting is the off-theme part.
- **Cloth Vestments** are a **botanical / arcane** line. Their craft inputs are herbs, petals, and
  essences, not cloth bolts and not hide:
  - Cloth Vestment  <- Herb Extract
  - Woven Vestment  <- Cloth Vestment + Rare Herb
  - Emberpetal Vestment <- Woven Vestment + Moonbloom Petal
  - Shadow Vestment <- Emberpetal Vestment + Shadow Essence
  - Void Vestment   <- Shadow Vestment + Void Creature Part
  There is currently **no woven-cloth / thread / fiber material** in the game at all. "Cloth" only
  exists as the finished vestment. So upgrading a vestment with **Rabbit Hide + Iron Fitting** is doubly
  wrong: wrong material family and wrong craft discipline.

---

## What upgrade components exist today, and who makes them

Reuse these before inventing anything. If you invent a new component, you must also specify its
producer (talent + activity + unlock level + inputs), because every component has to be obtainable and
has to keep its producing talent worth leveling.

| Component family | Grades | Produced by |
|---|---|---|
| Metal **Fitting** | Iron / Steel / Mithral / Adamant | Runesmithing (crafts from bars) |
| Wood **Haft** | Ash / Oak / Ironwood / Heartwood | Timber Shaping |
| Arcane **Apparatus** | Iron / Steel / Mithril / Adamantine | Artificing |
| **Binding Sigil** | Rough / Refined / Pristine / Masterwork | Gleaning (rare drop; attunement rate split) |
| **Leather** grades | Rabbit Hide, Fox/Wolf/Direwolf Leather, Drake Leather | Tanning |
| **Gemstone / Amber** (rares) | Crude / Rough / Refined / Pristine | gathered rare drops |
| cloth / thread / cord / strap | none exist | none exist |

---

## What we want back

A reorganized upgrade recipe table where **each material line's components + rare read as belonging to
that item**. Concretely:

1. **Metal (Runesmithing, Plate + metal weapons):** keep metal-flavored (Fitting + a metal-set rare like
   Gemstone). This one is already fine; adjust only if you see a reason.
2. **Wood (Timber Shaping, bows):** drop the metal Fitting. A bow should upgrade with wood + an organic
   binding (sinew / resin / cord) + Amber. Propose the binding component and its producer.
3. **Leather (Tailoring + armorType Leather):** drop the metal Fitting. Leather should upgrade with a
   leather grade + a leather binding (thong / cord / strap) + an organic rare. Propose the leather-cord
   component and its producer (Tanning is the natural home).
4. **Vestments (Tailoring + armorType Vestments):** drop leather AND metal entirely. Cloth should upgrade
   with a woven-cloth or thread component + a botanical binding (petal / extract / essence, which already
   exist) + a fitting rare. This line probably needs the most new material: decide whether to introduce a
   real cloth/fiber supply chain (fiber -> thread -> bolt) or to lean on the existing botanical inputs as
   the binding. Whichever you pick, name every material and its producer.
5. **Arcane (Artificing, foci):** currently Apparatus + Haft + Binding Sigil. The wooden Haft on an
   arcane focus is defensible (a staff has a shaft). Keep or refine; your call.

Deliverable format (so I can implement directly):

- A recipe table: **one row per (discipline / armorType) line, four columns for the quality bands**,
  each cell listing `[components] + rare`. Same shape as the current table above.
- A **new-components list**: for every material you introduce, give `name`, producing `talent`,
  `activity name`, `unlock level`, `inputs`, and roughly where it sits in that talent's ladder.
- A one-line **resolver note**: confirm the recipe key is `(assemblerTalent, armorType)` (or tell me the
  extra field you need).
- A short **asset-change checklist** for me: which talent `.asset` files gain activities, which new
  `ItemData` assets to create, and any producer that changes.

---

## Hard constraints (please honor all)

- **Do not regress the XP/throughput curve.** We just rebalanced gathering + Cookery so xp/sec rises
  monotonically with tier, and confirmed the crafting main ladders scale correctly. Any **new producer
  activity** must fit that curve (rising xp/sec with tier, cycle times thematic). Don't create a
  high-value XP shortcut or a dead low-XP grind. If a new component is a Tanning/Timber/Tailoring
  activity, place it so it does not flatten that talent's curve.
- **Quality vs Tier discipline.** Quality ladder is the six-value `ItemQuality` enum; Tier is level
  gating. Never add a parallel rarity enum, never name a quality field "tier".
- **Keep the roster lean.** Prefer reusing an existing component or an existing raw material over adding
  a new one. Every new component is new art + new recipes + new economy surface. Justify each.
- **Every crafting talent should stay meaningful** in the upgrade loop; don't strand Runesmithing's
  Fitting or Gleaning's Binding Sigil with nowhere to go if you remove them from a line. If a component
  loses all its consumers, say what replaces its sink.
- **Removed/forbidden systems:** no Enchanting (removed; Inscription is scroll/codex crafting only), no
  Legendary-quality authored items, no Black Ledger.
- **Writing style:** no em dashes, en dashes, or "--" as prose punctuation; no emojis. (These get copied
  into UI strings and commits.)
- **Reality check:** flag any material you reference that may not exist yet so I create the asset rather
  than silently falling back to Generic.

When you're done, hand it back as a spec I can drop into `docs/upgrade-component-economy.md` (v3) and
implement. Point out anything in the current design you think is wrong, not just the fittings issue.
