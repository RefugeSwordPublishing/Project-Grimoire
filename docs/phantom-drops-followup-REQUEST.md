# Phantom Drops Follow-up, Chat Design Request

### Status: awaiting Chat
### Raised: 2026-09-11 (phantom drop audit follow-up)

This is the follow-up to the phantom drop audit (see `implementation-status.md`, Session
2026-09-11, and `phantom-boss-trophies-REQUEST.md`). It covers three things Chat owns:

1. Bucket 2 recipe wiring (which talent consumes each of the 25 new raw materials).
2. Art prompts for the 30 new material sprites (tracker slots are already added; Chat writes the
   per-cell prompts).
3. Bucket 1 rare-material reconciliation (three new rares to ratify or repoint).

Claude Code will do the mechanical work (recipe edits, prompt seeding is yours, icon import) once
you decide.

---

## 1. Bucket 2 recipe proposal (25 raw materials)

All 25 exist now as `RawMaterials` (quality Crude, sell 3 to 8) and drop correctly, but nothing
consumes them yet. Proposed owning talent and use below. Owning talent is the recipe consumer; it
is deliberately independent of the tracker art sheet (which groups by what the item *is*, for
consistent art batching). Tiers refer to zone/material tier bands, not item quality.

| Material | Source | Proposed owning talent | Proposed use | Tier |
|---|---|---|---|---|
| Bear Claw | Grimwood Bear | Artificing | trinket/tool hard-part component | T1 |
| Wolf Fang | Wolfpack Leader | Artificing | trinket component | T1 |
| Venom Sac | Saltmarsh Serpent | Alchemy | poison coating / antidote reagent | T1 |
| Fish Scraps | Coastal Poacher | Cookery | low-tier meal / bait input | T1 |
| Aquatic Reagent | Shore Crab | Alchemy | water-based extract reagent | T1 |
| Worn Cloth | Grimwood Brigand | Tailoring | raw cloth to spin into Plain Thread | T1 |
| Rough Cloth | Saltmarsh Smuggler | Tailoring | raw cloth to spin into Woven Thread | T1 |
| Feathers | Mountain Hawk | Artificing / Marksmanship | arrow fletching component | T2 |
| Ancient Bark | Thornwood Ancient | Alchemy | bark reagent / astringent | T2 |
| Deadwood | Ashfen Treant | Timber Shaping | low-grade haft filler / kindling | T2 |
| Blightbark | Ashfen/Thornwood | Alchemy | blight reagent | T2 |
| Bog Herb | Spore Crawler | Alchemy | herb extract input | T2 |
| Ashfen Spore | Spore Crawler | Alchemy | spore reagent | T2 |
| Ectoplasm | Mire Wraith | Alchemy | spectral essence reagent | T2 |
| Spectral Essence | Barrow Revenant | Alchemy / Inscription | spectral ink / essence | T2 |
| Mountain Core | Stone Sentinel | Runesmithing | stone core component | T2 |
| Mountain Quartz | Mountain Golem | Runesmithing / Artificing | focusing crystal component | T2 |
| Iron Scraps | Ironspine Deserter | Smelting | salvage remelted into bars | T2 |
| Crude Sword | Rotting Soldier | Smelting | salvage remelted into bars | T2 |
| Ember Core | Fire Elemental | Smelting / Artificing | forge flux / fire component | T3 |
| Ember Shard | Greater Fire Elemental | Smelting / Artificing | forge flux (higher) | T3 |
| Drake Fang | Cinderpeak Drake | Artificing | trinket component | T3 |
| Wyvern Talon | Highland Wyvern | Artificing | trinket component | T3 |
| Void Ichor | Void Crawler/Shade | Alchemy | void reagent | T3 |
| Grave Cloth | undead (Dreadhollow+) | Tailoring / Inscription | shroud cloth / ritual wrap | T3 |

**Questions:** confirm or reassign the owning talent per row; give each a recipe (output + other
inputs + tier gate); decide whether the salvage pair (Iron Scraps, Crude Sword) yields a fractional
bar or a scrap intermediate. Where two talents are listed, pick one.

---

## 2. Art prompts for the 30 new material sprites

Tracker slots are added (asset_tracker `src/data/sheets.js`, pushed). The new cells show as
Pending with no prompt. Per the standing rule (only items that HAVE a prompt are generated), these
will not generate until you author their `asset_prompts` rows. Please write one prompt per cell.

**Slots added (sheet: cells):**

- `trapping` (monster parts), grid to 4x4: Bear Claw C2, Wolf Fang C3, Drake Fang C4, Wyvern Talon
  D1, Venom Sac D2, Feathers D3
- `foraging` (plants/wood), grid to 4x3: Ancient Bark B3, Deadwood B4, Blightbark C1, Bog Herb C2
- `dredging` (aquatic): Fish Scraps B4
- `alchemy` (reagents/essences), grid to 4x3: Ectoplasm B3, Spectral Essence B4, Void Ichor C1,
  Aquatic Reagent C2, Ashfen Spore C3
- `gleaning` (salvage/mineral fragments), grid to 4x4: Ember Core C2, Ember Shard C3, Mountain Core
  C4, Mountain Quartz D1, Iron Scraps D2, Crude Sword D3
- `tailoring` (raw cloth added alongside the thread ladder): Worn Cloth B1, Rough Cloth B2, Grave
  Cloth B3
- `rare_materials_ladder`: Masterwork Amber D2, Masterwork Gemstone D3

**Prompt style spec (match the existing item prompts):** `item icon, <subject>, 64x64, dark
medieval fantasy, small flat icon, limited palette, warm amber and dark teal palette, dark pixel
outline, transparent background, flat shading, low detail, single color black outline`. No quality
badge baked in (badge is a runtime overlay). One icon per item. Keep each within its sheet's palette
so the atlas reads as one set. Masterwork Amber and Masterwork Gemstone should continue the existing
Amber/Gemstone ladder look at the top (richest) grade.

---

## 3. Bucket 1 rare-material reconciliation

The audit created 3 new rare materials to unblock drops. They are NOT in your canonical rare set
(`rare_crafting_reagents` / `rare_boss_trophies`). Ratify each as a new item, or tell me to repoint
the drop to the existing canonical rare and delete the new asset:

| New item (created) | Dropped by | Closest existing canonical rare | Keep new, or repoint? |
|---|---|---|---|
| Void Spore | spore/void enemies (many) | Void Core / Void Crystal / Void Shard | ? |
| Phantom Pelt | Ashenwold/Veilborn phantoms | Shadow Pelt | ? |
| Abyssal Pearl | Saltmother, Tide Lurker | Black Pearl / Deep Clam | ? |

Already handled: `Crude Aetheric Filament` was a stale name for your canonical **Aetheric Fragment**;
the drop is repointed and no new item was made. Their tracker slots are held until you rule (to
avoid churn); once ratified I add the cells and you write their prompts.

---

## Handoff back to Claude Code

After your decisions: I wire the Bucket 2 recipes into the Talent ScriptableObjects, repoint or keep
the 3 rares, add any held tracker slots, and run the icon import once art is Approved.
