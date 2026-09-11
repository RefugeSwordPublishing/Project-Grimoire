---
type: design-spec
version: 1.1
updated: 2026-09-11
path: docs/phantom-boss-trophies-spec.md
resolves: phantom-boss-trophies-REQUEST.md, Buckets 2 and 3
implements: 19 ItemData assets, 25 Bucket 2 recipe assignments, atlas assignments
changelog: v1.1 corrects the accessory band against the shipped CreateAccessories values,
           switches tier assignment from boss CL to zone tier, and adds the Bucket 2
           recipe pass now that the real status doc is readable.
---

# Phantom Boss Trophies and the Bucket 2 Recipe Pass
### Version 1.1

---

## 0. Three Corrections From Reading The Real Status Doc

**The accessory band was wrong in v1.0.** `CreateAccessories` already shipped four dungeon-boss
accessories: Harbinger's Mark and Valdren's Apparatus Key at +10 percent damage / +12 percent resist,
and Warden's Seal and Firststone Key at +12 / +15. Those are the T4 and T5 rungs and they are live.
My v1.0 band proposed +15 / +18 at T4 and +18 / +22 at T5, which would have made these 19 stronger
than the trophies from the hardest content in the game. The band in section 2 is rebuilt underneath
the shipped values.

**The shipped pattern is dual, not lead-and-half.** Every existing boss accessory sets both fields
with resist running roughly 1.2 times damage. Slaying Hunt Trophies are damage-only at +2 percent.
Section 2 follows the shipped shape rather than inventing one.

**Tier now comes from the zone, not the boss's combat level.** Several of the CLs in the REQUEST
disagree with their zone's tier: Ironspine Reaches is T2B but its Warlord is CL 45 and its Colossus
CL 50, and Cinderpeak is T3 but Ignarath is CL 66. Zone tier is the structural truth the rest of the
content is built against, and using it puts these 19 cleanly at T1 through T3 with the already-shipped
accessories occupying T4 and T5. No overlap, no contradiction.

**Two identity notes, both confirmed rather than guessed now.**

Aldric the Wolf was renamed **Garrik the Wolf** in the 2026-08-01 board sweep. The Warren, the Den, and
the Key all stay Aldric's, so `Aldric's Key` and `Worn Bandit Cowl` keep their names; only the source
boss attribution changes.

The REQUEST's "Cmdr Valdris the Turncoat (Valdren's Keep, 26)" is confirmed a typo. The status doc has
Valdris as the **Warden's Folly** boss at 5,200 HP, T2. Valdren the Unfinished is the separate T4
Shattered Citadel boss. All three Valdris drops are T2.

---

## 1. Tier Assignment

| Boss | Dungeon or zone | Zone tier |
|---|---|---|
| Garrik the Wolf | Aldric's Warren, Grimwood Fringe | T1 |
| Captain Mirra Vane | Crestfall Cove, Saltmarsh Shore | T1 |
| Aldrath the Sunken | Mirefall Barrow, Ashfen Mire | T2 |
| Cmdr Valdris the Turncoat | Warden's Folly, Ironspine Reaches | T2 |
| The Ashfen Lich | Ashfen Mire | T2 |
| Ironspine Warlord | Ironspine Reaches | T2 |
| The Ironspine Colossus | Ironspine Reaches | T2 |
| The Hollow Archbishop | Dreadhollow | T3 |
| Ignarath the Ashborn | Cinderpeak | T3 |
| Ignarath's Broodmother | Ignarath's Maw, Cinderpeak | T3 |

---

## 2. Accessory Band, Rebuilt Under The Shipped Values

| Tier | Damage | Resist | Status |
|---|---|---|---|
| T1 | 4 | 5 | new |
| T2 | 6 | 7 | new |
| T3 | 8 | 10 | new |
| T4 | 10 | 12 | **shipped** (Harbinger's Mark, Valdren's Apparatus Key) |
| T5 | 12 | 15 | **shipped** (Warden's Seal, Firststone Key) |

Steps of +2 damage and +2 or +3 resist per tier, extrapolated down from the two shipped rungs. Resist
runs above damage throughout, matching the shipped pattern, because a resist percentage only applies
when that faction is attacking you while a damage percentage applies to every swing you take at them.

Slaying Hunt Trophies at +2 percent damage sit below the whole ladder, which is correct: a Hunt is a
repeatable timed activity and a named boss drop should beat it.

### 2.1 The seven accessories

| itemName | Boss | Tier | Faction | `accessoryDamagePct` | `accessoryResistPct` |
|---|---|---|---|---|---|
| Mirra's Compass | Captain Mirra Vane | T1 | Outlaw | 4 | 5 |
| Aldrath's Signet | Aldrath the Sunken | T2 | Undead | 6 | 7 |
| Valdris's War Banner | Cmdr Valdris the Turncoat | T2 | Outlaw | 6 | 7 |
| Warlord's Badge | Ironspine Warlord | T2 | Outlaw | 6 | 7 |
| Colossus Core | The Ironspine Colossus | T2 | Arcane | 6 | 7 |
| Archbishop's Seal | The Hollow Archbishop | T3 | Undead | 6 | 12 |
| Ignarath's Fang | Ignarath the Ashborn | T3 | Beast | 8 | 10 |

Archbishop's Seal is the REQUEST's one resist-focused trophy, so its damage drops below band and its
resist rises above it. Net value stays at the T3 rung; the emphasis moves.

Archbishop is Undead/Void. **Set faction to Undead**, matching the existing precedent in the status
doc that dual-faction trophies model their primary faction only under the single-slot model.

Four T2 Outlaw and Arcane accessories at identical values is fine. They come from four different
bosses in two zones and a player will hold whichever they killed.

---

## 3. Equipment

**Every trophy equipment piece is Refined quality at its zone's material tier.** Refined beats
anything the player can craft at that point and leaves Pristine and Masterwork as bench goals. The
trophy is a head start, not an endpoint.

| itemName | Boss | Tier | Slot | Type | Quality |
|---|---|---|---|---|---|
| Worn Bandit Cowl | Garrik the Wolf | T1 | Helm | Leather | Refined |
| Corsair's Coat | Captain Mirra Vane | T1 | Chest | Leather | Refined |
| Barrow Knight Armor | Aldrath the Sunken | T2 | Chest | Plate | Refined |
| Turncoat's Blade | Cmdr Valdris the Turncoat | T2 | Weapon | Sword | Refined |
| Deserter's Arms | Cmdr Valdris the Turncoat | T2 | **Gloves** | Plate | Refined |
| Ashfen Lich Crown | The Ashfen Lich | T2 | Helm | Vestments | Refined |
| Ironspine Colossus Pauldrons | The Ironspine Colossus | T2 | Chest | Plate | Refined |
| Archbishop's Vestments | The Hollow Archbishop | T3 | Chest | Vestments | Refined |
| Wyvern Hide Armor | Ignarath's Broodmother | T3 | Chest | Leather | Refined |

**Turncoat's Blade is a one-handed sword** under the shipped handedness revision, so it is
shield-capable. That makes a T2 boss drop an attractive sword-and-board starting point.

**"Pauldrons" in the Chest slot** reads oddly since there is no shoulder slot. Chest is the only
sensible home. Rename the drop row to "Ironspine Colossus Harness" if it bothers anyone; the REQUEST
permits repointing and nothing else depends on the string.

---

## 4. Deserter's Arms

**Gloves, Plate, Refined, T2.** Arms as vambraces.

The design argument beats the linguistic one. Valdris already drops Valdris's War Banner and
Turncoat's Blade, so he is already the weapon source for that encounter and a second weapon is a
redundant reward in a three-item table. Meanwhile every other equipment trophy here is Helm, Chest, or
Weapon, and Gloves, Legs, and Boots have none. This fills a gap rather than doubling an occupied slot.

---

## 5. The Two Tomes

**Both are Inscription inputs, category `ScrollsAndCodex`.**

| itemName | Boss | Tier | Role |
|---|---|---|---|
| Spectral Tome | The Ashfen Lich | T2 | Mid-tier Codex input |
| Summoner's Tome | 4 dungeon bosses | T3 | High-tier Codex input |

Summoner is one of the seven starting Grimoires, so it cannot be gated behind a drop. Making the Tome
unlock a deep subclass would need an unlock system that does not exist, for one item, when Inscription
already has a Codex recipe line wanting rare inputs. Four bosses dropping the same Tome is the tell:
a one-off unlock comes from one source, a material you accumulate comes from several.

The Inscription line already runs Vellum plus a Gleaning sigil. These slot in as the rare third input
on the two highest Codex recipes.

If a Summoner deep-subclass unlock is ever built, this is the obvious key, and repointing it is a
category change on one asset.

---

## 6. Aldric's Key

Quest item, protected, non-sellable, **consumed on use**. Its purpose is defined in the T1 dungeon
brief: it opens the strongbox in Aldric's Warren's safe room containing a note on Aldric's backstory.

Consume it rather than keeping it. An unconsumed protected item that does nothing after one use is
permanent clutter in a game whose first-hour problem is inventory pressure. The note is the reward.

---

## 7. Sell Values and Atlases

| Type | T1 | T2 | T3 |
|---|---|---|---|
| Accessory | 30 | 70 | 120 |
| Tome | 15 | 25 | 40 |
| Quest key | 0, non-sellable | | |

Equipment derives its sell value from (type, quality, tier) automatically.

| Group | Count | Atlas |
|---|---|---|
| Accessories | 7 | `accessories` |
| Tomes | 2 | `inscription_scrolls` |
| Aldric's Key | 1 | `items_boss_drops` |
| Equipment | 9 | **`boss_trophies_equipment` (new)** |

**The equipment must not go in the generic type atlases.** Those were authored as material-neutral
silhouettes because quality and tier ride on a badge overlay, which is right for crafted gear and
wrong for a named drop. Archbishop's Vestments in `armor_arcanist` renders identical to anything a
Tailor makes. One new atlas, nine unique icons, and that is the difference between a trophy and a
recolour.

---

## 8. Full Authoring Table, Bucket 3

| itemName | Category | Slot / Type | Quality | Tier | Faction | Dmg% | Res% | Sell | Atlas |
|---|---|---|---|---|---|---|---|---|---|
| Mirra's Compass | Accessory | Accessory | n/a | 1 | Outlaw | 4 | 5 | 30 | accessories |
| Aldrath's Signet | Accessory | Accessory | n/a | 2 | Undead | 6 | 7 | 70 | accessories |
| Valdris's War Banner | Accessory | Accessory | n/a | 2 | Outlaw | 6 | 7 | 70 | accessories |
| Warlord's Badge | Accessory | Accessory | n/a | 2 | Outlaw | 6 | 7 | 70 | accessories |
| Colossus Core | Accessory | Accessory | n/a | 2 | Arcane | 6 | 7 | 70 | accessories |
| Archbishop's Seal | Accessory | Accessory | n/a | 3 | Undead | 6 | 12 | 120 | accessories |
| Ignarath's Fang | Accessory | Accessory | n/a | 3 | Beast | 8 | 10 | 120 | accessories |
| Worn Bandit Cowl | Equipment | Helm / Leather | Refined | 1 | n/a | n/a | n/a | derived | boss_trophies_equipment |
| Corsair's Coat | Equipment | Chest / Leather | Refined | 1 | n/a | n/a | n/a | derived | boss_trophies_equipment |
| Barrow Knight Armor | Equipment | Chest / Plate | Refined | 2 | n/a | n/a | n/a | derived | boss_trophies_equipment |
| Turncoat's Blade | Equipment | Weapon / Sword | Refined | 2 | n/a | n/a | n/a | derived | boss_trophies_equipment |
| Deserter's Arms | Equipment | Gloves / Plate | Refined | 2 | n/a | n/a | n/a | derived | boss_trophies_equipment |
| Ashfen Lich Crown | Equipment | Helm / Vestments | Refined | 2 | n/a | n/a | n/a | derived | boss_trophies_equipment |
| Ironspine Colossus Pauldrons | Equipment | Chest / Plate | Refined | 2 | n/a | n/a | n/a | derived | boss_trophies_equipment |
| Archbishop's Vestments | Equipment | Chest / Vestments | Refined | 3 | n/a | n/a | n/a | derived | boss_trophies_equipment |
| Wyvern Hide Armor | Equipment | Chest / Leather | Refined | 3 | n/a | n/a | n/a | derived | boss_trophies_equipment |
| Spectral Tome | ScrollsAndCodex | n/a | n/a | 2 | n/a | n/a | n/a | 25 | inscription_scrolls |
| Summoner's Tome | ScrollsAndCodex | n/a | n/a | 3 | n/a | n/a | n/a | 40 | inscription_scrolls |
| Aldric's Key | QuestItems | n/a | n/a | 1 | n/a | n/a | n/a | 0 | items_boss_drops |

---

## 9. Bucket 2, The 25 Recipe Assignments

### 9.1 The rule

**A material goes to the talent that works its physical class, not the talent that dropped it.** Bone
and claw go to Artificing because Artificing makes trinkets and relics out of hard organic matter,
even though Trapping killed the bear. Tanning takes hides, because Tanning works skin.

That is the correction to the looser rule I wrote in v1.0. Source-based assignment sends claws and
fangs to Tanning, which has nothing to do with them.

### 9.2 Assignments

| Material | Talent | Tier | Recipe role |
|---|---|---|---|
| Iron Scraps | Smelting | 1 | Melts into Copper or Iron Bar, low-tier bar filler |
| Crude Sword | Smelting | 1 | Scrap melt into Iron Bar. **See 9.4** |
| Mountain Core | Smelting | 2 | Alloy additive, Steel Bar line |
| Ember Core | Smelting | 3 | Heat catalyst, Mithril Bar line |
| Ember Shard | Smelting | 3 | Lesser heat catalyst, Steel and Mithril |
| Bear Claw | Artificing | 1 | Crude Tool and Stone Totem component |
| Wolf Fang | Artificing | 1 | Crude Tool and Shell Trinket component |
| Mountain Quartz | Artificing | 2 | Focus component, apparatus line |
| Drake Fang | Artificing | 3 | Ironbone Relic component |
| Wyvern Talon | Artificing | 3 | Ironbone Relic component |
| Worn Cloth | Tailoring | 1 | Plain Thread input, lowest rung |
| Rough Cloth | Tailoring | 1 | Plain and Woven Thread input |
| Grave Cloth | Tailoring | 2 | Woven Thread input, undead-sourced |
| Deadwood | Timber Shaping | 1 | Pine Haft and Plank filler |
| Feathers | Timber Shaping | 1 | Fletching, bow and quiver line |
| Blightbark | Timber Shaping | 3 | Ironwood Haft line, corrupted variant |
| Ancient Bark | Timber Shaping | 4 | Heartwood Haft line |
| Fish Scraps | Cookery | 1 | Broth and Simple Stew filler |
| Bog Herb | Alchemy | 2 | Herb Extract variant, low-tier reagent |
| Aquatic Reagent | Alchemy | 2 | Mana Vial line |
| Ashfen Spore | Alchemy | 2 | Antidote and poison-coating line |
| Venom Sac | Alchemy | 2 | Weapon coating, poison |
| Ectoplasm | Alchemy | 3 | Shadow Essence line, undead reagent |
| Spectral Essence | Alchemy | 4 | High-tier reagent, Clarity and Power line |
| Void Ichor | Alchemy | 4 | Void-tier reagent, top of the ladder |

Five talents take the load: Alchemy 7, Artificing 5, Smelting 5, Timber Shaping 4, Tailoring 3,
Cookery 1. Alchemy carrying the most is correct, since organic reagents are what Trapping, Foraging,
and undead enemies mostly produce.

### 9.3 Level-gate constraint

Every one of these must be obtainable at or before the level of the recipe that consumes it, or the
`RecipeValidator` will report a new deadlock. The 2026-08-02 audit found 20 hard locks from exactly
this class of mistake.

The safe pattern, given all 25 are enemy or node drops with no level gate of their own: **wire each
into a recipe at or above the tier listed**, never below. A T3 material feeding a T1 recipe is the
deadlock shape.

### 9.4 Crude Sword does not belong in this list

It is authored as `RawMaterials` but the name is a weapon. Two readings, and the category is the tell.

If enemies are meant to drop a usable low-tier sword, it is **equipment**, not a material, and it
needs a slot, type, and quality like every other weapon. If it is bandit junk loot to be melted down,
`RawMaterials` is right and Smelting scrap is its home.

I have assigned it as Smelting scrap because `Crude` plus `RawMaterials` plus a sell value in the 3 to
8 band all say junk loot. But it is worth thirty seconds to confirm, because a dropped sword the player
cannot equip is the kind of thing a tester reports as a bug.

---

## 10. Acceptance Criteria

- All 19 `itemName` values resolve through `ItemRegistry` and `AddItemByName` succeeds for each.
- Re-running the phantom sweep reports zero remaining phantoms.
- No new accessory exceeds the shipped T4 and T5 values of 10/12 and 12/15.
- Every accessory sets both `accessoryDamagePct` and `accessoryResistPct`, with resist at or above
  damage except on Archbishop's Seal where the emphasis is deliberately inverted.
- No boss trophy accessory falls at or below the +2 percent Slaying Hunt Trophy floor.
- All nine equipment pieces are Refined quality at their zone's material tier.
- Deserter's Arms occupies the Gloves slot.
- Both Tomes are `ScrollsAndCodex` and feed Inscription Codex recipes.
- Aldric's Key is protected, non-sellable, and consumed on use.
- The nine equipment trophies use unique icons in `boss_trophies_equipment`, not generic silhouettes.
- All 25 Bucket 2 materials are inputs to at least one recipe on the assigned talent.
- `RecipeValidator` reports zero level locks after the Bucket 2 wiring.
- Crude Sword's category is confirmed as material or reclassified as equipment before wiring.

---

*Path: docs/phantom-boss-trophies-spec.md*
*v1.1. Accessory band rebuilt under the shipped +10/12 and +12/15 dungeon trophies, tiers taken from*
*zone rather than boss CL, Garrik and Valdris identities confirmed. Nine equipment pieces at Refined,*
*Deserter's Arms as Gloves, both Tomes as Inscription inputs, one new atlas. All 25 Bucket 2 materials*
*assigned to a talent, tier, and recipe role.*
