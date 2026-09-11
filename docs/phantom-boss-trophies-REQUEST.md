# Phantom Boss Trophies, Design Request

### Status: awaiting Chat design pass
### Raised: 2026-09-11 (offline-combat WYWA data audit)

---

## Context

A sweep of every enemy and zone drop table against the actual `ItemData` assets found 65 drop
`itemName` values with no matching item, so `InventoryManager.AddItemByName` failed for them: no
icon, and the player never received the drop. Two of the three buckets are already fixed in the
Unity data (see `implementation-status.md`, "Phantom drop audit"):

- **Bucket 1, quality-prefixed rare materials:** created the 4 truly-missing base materials
  (Void Spore, Phantom Pelt, Abyssal Pearl, Aetheric Filament) plus the 2 gem top-rungs
  (Masterwork Amber, Masterwork Gemstone), and stripped the stale quality prefixes off 61 drop
  rows so they resolve to the base material.
- **Bucket 2, creature and gathered raw materials:** created 25 as `RawMaterials`, registered,
  sell values in the 3 to 8 band. Icons and crafting-recipe wiring are still open (below).

**Bucket 3 is this document.** These 19 are unique named drops from bosses and dungeon bosses.
Each is a design object, not a generic material: it needs a decided item type (accessory, quest
item, or equipment), and for accessories a faction and bonus, or for equipment a slot, type,
tier, and quality. They were left uncreated on purpose so the numbers are your call, not a guess.
Until they exist as assets, every one of these boss drops is a dead reward.

The runtime resolves drops by the `itemName` field through `ItemRegistry`, so whatever we author
must carry the exact `itemName` in the left column (or we repoint the drop row to a new name).

---

## The 19 trophies

Recommended type per item. "Accessory" means `EquipmentSlot.Accessory` with a faction-scoped
`accessoryDamagePct` / `accessoryResistPct` (the boss-trophy pattern already in `ItemData`).
"Equipment" means a real gear piece whose stats derive from (type, quality, tier). "Quest/Key"
means a protected, non-sellable item tied to progression.

| itemName | Source boss (zone, ~CL) | Faction | Recommended type | Proposal |
|---|---|---|---|---|
| Warlord's Badge | Ironspine Warlord (Ironspine, 45) | Outlaw | Accessory | +damage vs Outlaw |
| Aldrath's Signet | Aldrath the Sunken (Mirefall Barrow, 25) | Undead | Accessory | +damage vs Undead |
| Archbishop's Seal | The Hollow Archbishop (Dreadhollow, 58) | Undead/Void | Accessory | +resist vs Undead |
| Ignarath's Fang | Ignarath the Ashborn (Cinderpeak, 66) | Beast | Accessory | +damage vs Beast |
| Colossus Core | The Ironspine Colossus (Ironspine, 50) | Arcane | Accessory | +damage vs Arcane |
| Mirra's Compass | Captain Mirra Vane (Crestfall Cove, 12) | Outlaw | Accessory | +damage vs Outlaw (low tier) |
| Valdris's War Banner | Cmdr Valdris the Turncoat (Valdren's Keep, 26) | Outlaw | Accessory | +damage vs Outlaw |
| Barrow Knight Armor | Aldrath the Sunken (Mirefall Barrow, 25) | Undead | Equipment (Chest, Plate) | tier/quality by CL |
| Archbishop's Vestments | The Hollow Archbishop (Dreadhollow, 58) | Undead | Equipment (Chest, Vestments) | caster chest |
| Corsair's Coat | Captain Mirra Vane (Crestfall Cove, 12) | Outlaw | Equipment (Chest, Leather) | light chest |
| Wyvern Hide Armor | Ignarath's Broodmother (Ignarath's Maw, 66) | Beast | Equipment (Chest, Leather) | high-tier light chest |
| Ironspine Colossus Pauldrons | The Ironspine Colossus (Ironspine, 50) | Arcane | Equipment (Chest, Plate) | heavy chest |
| Ashfen Lich Crown | The Ashfen Lich (Ashfen Mire, 35) | Undead | Equipment (Helm, Vestments) | caster helm |
| Worn Bandit Cowl | Aldric the Wolf (Aldric's Warren, 8) | Outlaw | Equipment (Helm, Leather) | starter helm |
| Turncoat's Blade | Cmdr Valdris the Turncoat (Valdren's Keep, 26) | Outlaw | Equipment (Weapon, Sword) | one-handed sword |
| Deserter's Arms | Cmdr Valdris the Turncoat (Valdren's Keep, 26) | Outlaw | Equipment or Rare mat | ambiguous, see below |
| Aldric's Key | Aldric the Wolf (Aldric's Warren, 8) | Outlaw | Quest/Key | protected, non-sellable |
| Spectral Tome | The Ashfen Lich (Ashfen Mire, 35) | Undead | Quest/Codex | Inscription input or lore |
| Summoner's Tome | 4 dungeon bosses (CL varies) | mixed | Quest/Codex | Summoner unlock or codex |

---

## Open questions for Chat

1. **Accessory bonus magnitudes.** The 7 accessories want `accessoryDamagePct` / `accessoryResistPct`
   values that scale with the boss's combat level. Propose a per-tier band (for example Tier 2
   trophies +8%, Tier 3 +12%, Tier 4 to 5 +15% to 20%), consistent with any existing Slaying
   Hunt trophies.
2. **Equipment stats.** The 9 equipment pieces derive stats from (slot, type, quality, tier). Give
   each a quality and `materialTier` appropriate to its boss CL. Confirm slot/type guesses above.
3. **"Deserter's Arms".** Reads either as a weapon (arms = weaponry) or a set of armour arms.
   Decide, or make it a sellable trophy rare-material if it is just flavour loot.
4. **The two Tomes.** Is "Summoner's Tome" a Summoner-path unlock, an Inscription codex input, or
   a lore/quest item? Is "Spectral Tome" the same class of thing? This decides category
   (`ScrollsAndCodex` vs `QuestItems`) and whether it feeds a recipe.
5. **Icons.** None of the 19 have art. They need atlas cells (equipment atlas, or an accessories
   /trophies atlas) in the sprite pass. Flag which atlas each belongs to.

## Also needs a recipe pass (Bucket 2 follow-up)

The 25 new raw materials are created and drop correctly, but are not yet inputs to any recipe.
Decide which crafting talent consumes each (Tanning for hides and pelts, Alchemy for herbs and
reagents, Smelting for ore and scrap, and so on) and at what tier, then Claude Code wires them
into the Talent ScriptableObjects and assigns atlas cells. List of the 25 is in
`implementation-status.md`.

---

## Handoff back to Claude Code

Once decided, Claude Code will author the 19 assets (correct category, quality, tier, faction,
sell value), register them, repoint any drop rows that need a renamed target, wire the Bucket 2
recipe inputs, and run the sprite pass to assign icons.
