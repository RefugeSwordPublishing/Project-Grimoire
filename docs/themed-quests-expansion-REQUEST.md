# Themed Quests Expansion, Design Request
### 0.1.4 quest pool expansion. Requesting Chat's content pass.

---

The themed-quest system is built and working (`daily-weekly-quest-system.md` v2.0). The launch pool you
authored is 17 daily + 11 weekly, and it plays well, but it only covers about half the game's content.
This request is a **content-only expansion**: more authored quests to cover every talent and faction and
give real daily rotation. The engine is done, so this lands as pure data in `CreateQuests.cs`, one editor
click, no new systems.

Read `implementation-status.md` (the 2026-08-31 themed-quests entry has the as-built deviations) and
`daily-weekly-quest-system.md` v2.0 (the model you are extending). Everything in v2.0 still holds; this
only adds quests within those rules.

## The gaps to fill (why we are expanding)

The launch pool covers 8 of the 15 non-combat talents and 3 of the 6 factions. Concretely:

- **Talents with ZERO quests:** Trapping, Dredging, Gleaning (gathering); Artificing, Cookery, Inscription,
  Tailoring (crafting). A player leveling any of these never sees a quest for it.
- **Factions with ZERO quests:** Outlaw, Arcane, Nature (only Beast, Undead, Void are covered).
- **Low-tier rotation is thin:** at T1 only ~7 quests are eligible and the board shows 6, so a new player
  sees nearly the same board daily. Fill the low band especially.
- **Item variety** is ~15 delivery targets against a much larger material list.

## Target

Roughly **45 to 60 daily + 25 to 30 weekly** definitions. Enough that every tier band has real rotation
(comfortably more eligible than the 6 daily / 4 weekly the board shows) and every talent + faction appears.

## What to keep identical to v2.0 (do not re-litigate)

- **Fulfillment split:** Gather/Process/Craft = Delivery (consumes stock at turn-in, reads live balance);
  Defeat/Dungeon/Zone/Exchange = Track (event-counted from accept).
- **Reward shape:** lead with **Silver Marks**, plus a themed **bonus item** (chance-based), plus a **small
  side XP** amount. Gold Marks appear ONLY on weekly capstones.
- **Voice rules:** named giver + one or two sentences in their register; titles name the job or the giver's
  stake, never the verb-and-number; transactions between working people, no pleading, no exclamation marks.
- **Bonus leash ("taste not farm"):** chance never above ~28%, quantity 1 for anything above Crude, and no
  bonus item may be the best source of itself.

## As-built deviations you MUST honor (these differ from the v2.0 doc's own text)

1. **XP is a SMALL side bonus, not the primary talent-scaled reward.** In code it is a modest flat base
   (about 120 daily / 500 weekly) scaled by tier. Do not size XP as a fraction of a level. SM + the themed
   item are the real payout; XP is a garnish.
2. **Gear delivery matches ONE weapon or armour category per quest.** The data model holds a single
   `deliverWeaponType` / `deliverArmorType`, so "Sword or Dagger" is not expressible in one quest. Write
   single-category gear quests ("Craft any Bow", "Craft any Plate piece"), capped at Rough quality.
3. **SellOnExchange counts earnings collections, not individual items.** Keep such targets small (about 3).
4. **Bonus items must be real ItemData.** Use only names from the vetted list in the appendix. Do NOT use
   Void Spore or Phantom Pelt (they have no ItemData and silently fail to grant).

## Coverage requirements for the expansion

- **Every talent** gets at least 2 daily + 1 weekly quest, themed to a giver whose trade fits it.
- **Every faction** (Outlaw, Beast, Undead, Arcane, Void, Nature) gets DefeatEnemies quests, tier-banded to
  where that faction actually appears (see appendix).
- **New givers:** add 3 to 4 for the uncovered trades (a cook, a scribe/inscriber, a tailor, a trapper),
  each with a name, trade, and one-line personality, in the same voice. Keep the existing 10.
- **Tier spread:** ensure every tier band (T1 through T5) has comfortably more than 6 daily + 4 weekly
  eligible. Add low-tier gather/process quests for the thin T1 band and high-tier delivery/craft quests for
  T4/T5 (which currently have no gather quests at all).
- Keep the daily:weekly capstone ratio: about 3 weekly capstones carry Gold; the rest do not.

## Deliverable format

Give the FULL expanded pool (existing 28 kept + the new ones) as a list, one quest per entry with:
`questId` (snake_case), cadence, objective type, fulfillment (Delivery/Track), giver, title, one-line
description, target item OR faction OR gear-category, count, tier band (minTier to maxTier), the guaranteed
SM amount, the small XP channel (talent name or Combat), and the bonus item + chance. Group by talent /
faction so the coverage is auditable. I will transcribe it into `CreateQuests.cs`.

## Constraints

- Mobile-first portrait; no new UI (reuses the notice board).
- House style: no em/en dashes, no emojis, direct phrasing, no XP-for-XP objectives.

**Deliver:** the new givers, and the full expanded daily+weekly pool covering every talent and faction,
using only the vetted item/faction names in the appendix below.

---

## Appendix: vetted names (authoritative, from the code)

*Every name below is a real ItemData / enum / zone on disk. Use ONLY these. Anything not listed here is
unverified, do not invent items.*

### A. Item-delivery targets by talent (Delivery quests: "deliver N of this item")

Order is low tier to high tier. Use the exact `itemName`.

| Talent | Deliverable items (low → high) |
|---|---|
| **Foraging** | Wildgrass Clump, Common Herb, Thornwood Bark, Ironroot Chunk |
| **Trapping** | Rabbit Pelt, Rabbit Meat, Fox Fur, Direwolf Hide, Shadow Pelt |
| **Dredging** | Pond Fish, River Trout, Saltmarsh Eel, Deep Clam |
| **Delving** | Copper Ore, Tin Ore, Iron Ore, Coal, Mithril Ore |
| **Felling** | Pine Log, Ash Log, Oak Log, Ironwood Log, Heartwood Log |
| **Gleaning** | Crude Rune Shard, Minor Enchant Seal |
| **Smelting** | Copper Bar, Tin Bar, Bronze Bar, Iron Bar, Steel Bar, Mithril Bar, Void Alloy |
| **Tanning** | Rabbit Hide, Fox Leather, Wolf Leather, Direwolf Leather |
| **Alchemy** | Healing Salve, Clarity Tonic, Speed Draught, Power Elixir |
| **Cookery** | Simple Stew, Herb Broth, Traveler's Ration, Warden's Feast |
| **Inscription** | Minor Enchant Seal, Refined Mark, Ancient Sigil, Master Glyph |
| **Artificing** | Crude Tool, Shell Trinket, Stone Totem, Ironbone Relic |

Tier banding rule: pick a `minTier`/`maxTier` that matches where the item sits (e.g. Pine Log T1 to T2,
Mithril Ore T4 to T5, Steel Bar T3 to T5). Low-tier items must have a low band so new players draw them.

### B. Gear-crafter quests (Delivery by CATEGORY, capped at Rough quality)

These four talents craft finished gear only, so their quests are "Craft any \<category\> x2 to x3". One
category per quest (the data model holds a single weapon/armour type).

| Talent | Categories (weaponType / armorType) | Example tier names (for flavor only; matching is by type) |
|---|---|---|
| **Runesmithing** | Sword, Dagger, Axe (weapon); Plate (armour) | Bronze Sword, Steel Dagger, Void Battle Axe; Iron Plate Chest |
| **Timber Shaping** | Bow (weapon) | Bronze Bow, Mithril Bow |
| **Artificing** | Staff, Wand (weapon) | Pine Staff, Heartwood Staff, Oak Wand |
| **Tailoring** | Leather, Vestments (armour) | Fox Leather Chest, Cloth Vestment Legs, Void Vestment Helm |

Keep gear counts at 2 to 3 and quality capped at Rough (the giver wants serviceable kit, not masterworks).

### C. Faction kill quests (Track), with tier bands

| Faction | Tier band | Example enemies |
|---|---|---|
| **Outlaw** | T1 to T4 | Grimwood Brigand, Bandit Scout, Warband Raider, Ruin Scavenger |
| **Beast** | T1 to T5 | Forest Wolf, Shore Crab, Mountain Golem, Cinderpeak Drake, Primordial Drake |
| **Undead** | T2 to T5 | Bogwalker Skeleton, Bone Archer, Sundered Revenant, Ashen Warlord |
| **Arcane** | T2 to T5 | Rune Orrery, Fire Elemental, Citadel Archmage, Rune Colossus |
| **Void** | T3 to T5 | Void Shade, Reality Shade, Void Archon |
| **Nature** | T2 ONLY | Ashfen Treant, Bog Lurker, Spore Crawler, Thornwood Ancient |

Nature is T2-locked (only in Ashfen Mire); a Nature quest must be `tier 2 to 2`. Void starts at T3.

### D. Bonus reward items (safe, real assets)

**Quality ladders (pick the tier that fits the quest):**
- **Gemstone**: Crude, Rough, Refined, Pristine (NO Masterwork)
- **Amber**: Crude, Rough, Refined, Pristine (NO Masterwork)
- **Binding Sigil**: Rough, Refined, Pristine, Masterwork (NO Crude, ladder is shifted up)

**Single-instance rares (no quality prefix, use the exact name):** Rare Herb, Moonbloom Petal, Runic Cog,
Ancient Sigil, Master Glyph, Rare Earth, Rare Ore, Rare Spice, Dire Fang, Black Pearl, Shadow Pelt,
Shadow Essence, Ashbone, Arcane Dust, Soulite Crystal, Void Crystal, Void Core, Void Shard, Wyvern Heart,
Ancient Fang, Drake Scale.

**DO NOT USE as reward or requirement (no ItemData, silently fails):** Void Spore, Phantom Pelt (any
quality), Masterwork Gemstone, Masterwork Amber, quality-prefixed Runic Cog, and any enemy drop-table
flavor string (Blightbark, Ectoplasm, Ember Core, etc.).

Theming guide: combat quests bonus an Amber or a faction-flavored rare (Undead -> Ashbone, Void -> Void
Crystal/Shard, Arcane -> Arcane Dust); gather/craft quests bonus a Gemstone or the activity's own rare.

### E. Dungeons (for "Clear a dungeon" Track quests)

Leave `targetId` empty for "any dungeon", or name one for flavor. By tier:
T1 Aldric's Warren, Crestfall Cove · T2 Mirefall Barrow, Warden's Folly · T3 Gravenspire, Ignarath's Maw ·
T4 The Breach, Valdren's Keep · T5 The Pale Vault, Firststone Sanctum.

---

*Path: docs/themed-quests-expansion-REQUEST.md*
