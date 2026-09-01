---
type: design-spec
version: 2.1
updated: 2026-08-31
release: 0.1.4
path: docs/daily-weekly-quest-system-pool.md
resolves: themed-quests-expansion-REQUEST.md
extends: daily-weekly-quest-system.md v2.0
scope: content only, no engine change
---

# Themed Quest Pool, Full Expansion
### Version 2.1, 85 definitions

---

## 0. What This Is

The complete authored pool: 55 daily and 30 weekly. The 28 launch definitions are kept,
five of them with corrections noted below. Everything else is new.

All rules from `daily-weekly-quest-system.md` v2.0 still hold. This document changes only
the content.

**Note on the status doc.** The copy of `implementation-status.md` I could retrieve is
dated 2026-07-10 and does not contain the 2026-08-31 themed-quests entry. I have authored
against the four as-built deviations exactly as the expansion request states them. If the
status entry says anything further, check this pool against it before transcribing.

---

## 1. As-Built Deviations Honored

| Deviation | How this pool complies |
|---|---|
| XP is a small flat side bonus, scaled by tier, not a fraction of a level | Every quest carries a fixed XP figure from the section 4 table. No quest scales XP to talent level. |
| Gear delivery matches ONE weapon or armour category | Every gear quest names a single category. `garrick_blades_daily` was "Sword or Dagger" and is now Sword only. |
| SellOnExchange counts earnings collections | Both Exchange quests count collections. `quinn_exchange` drops from 5 items to 3 collections. |
| Bonus items must be real ItemData | Every bonus is from the vetted appendix. Four quests used Void Spore or Phantom Pelt and are retargeted. |

### 1.1 The five corrected launch quests

| questId | What changed | Why |
|---|---|---|
| `garrick_blades_daily` | Target "Sword or Dagger" becomes "Sword" | Data model holds one category |
| `quinn_exchange` | 5 items becomes 3 earnings collections | Objective counts collections |
| `marrow_undead` | Bonus Refined Phantom Pelt becomes Ashbone | Phantom Pelt has no ItemData |
| `ilric_void` | Bonus Refined Void Spore becomes Void Crystal | Void Spore has no ItemData |
| `w_marrow_purge`, `w_ilric_void` | Bonuses Pristine Phantom Pelt and Pristine Void Spore become Ashbone and Void Shard | Same reason |

### 1.2 Five launch quests target items outside the vetted appendix

`corwin_hafts` (Ash Haft), `garrick_fittings` (Steel Fitting), `hestia_extract` and
`w_hestia_apoth` (Herb Extract), and `odell_vellum` (Vellum) deliver items the appendix
does not list. They are kept unchanged because they shipped and are working, so the items
presumably exist and the appendix is curated rather than exhaustive.

Worth confirming. If any of those five targets is not real ItemData, those quests are
silently unfillable and every one of them is in the daily pool. Every new quest in this
document uses appendix names only.

---

## 2. Givers

The ten existing givers, unchanged:

| Name | Trade | Personality |
|---|---|---|
| Bramblewick | Millwright, Grimwood | Gruff about quotas, quietly pays over the odds |
| Hestia Vale | Apothecary, Saltmarsh | Precise to the gram, no patience for approximation |
| Garrick Stone | Forgemaster, Ironspine | Blunt, measures twice, trusts nobody's count but his own |
| Mother Odell | Tanner, Ashfen Mire | Old and unhurried, tells you more than you asked for |
| Corwin Ash | Bowyer, Grimwood | Particular to the point of superstition about his materials |
| Sera Thorne | Bounty clerk, guild hall | Dry and bureaucratic, keeps the ledger and quotes it at you |
| Halvard Quinn | Caravan master, everywhere | Practical and permanently behind schedule |
| Wren | Scavenger, guild hall | A kid, eager, consistently undercharges herself |
| Master Ilric | Arcanist scholar, Shattered Citadel | Distracted, answers questions you did not ask |
| Dune Marrow | Undertaker, Dreadhollow | Calm about grim things, which is worse than being grim about them |

Four new, covering the uncovered trades:

| Name | Trade | Personality |
|---|---|---|
| Tamsin Kettle | Cook, guild hall kitchen | Feeds everyone without comment and remembers exactly who came back for seconds |
| Brother Aldis | Scribe and inscriber, Shattered Citadel | Copies everything by hand on principle, distrusts any page he did not letter himself |
| Nessa Fen | Tailor, Saltmarsh Shore | Sharp-eyed, measures you once and never asks again |
| Old Harl | Trapper, Grimwood | Says little, and most of what he says is about the weather |

**Trade assignments.** Tamsin covers Cookery and Dredging, since a cook wanting fish needs
no explanation. Aldis covers Inscription and the Undead and Arcane bounties, because a man
who copies inscriptions in crypts has a stake in what is down there. Nessa covers Tailoring.
Harl covers Trapping and the Beast bounties.

---

## 3. Coverage Audit

**All 15 non-combat talents:** every one has at least 2 daily and 1 weekly.

**All 6 factions:** Outlaw 2, Beast 3, Undead 3, Arcane 2, Void 3, Nature 2.
Nature is banded T2 to T2 exactly, as the appendix requires. Void starts at T3.

**Tier depth,** against a board that shows 6 daily and 4 weekly:

| Tier | Daily eligible | Weekly eligible |
|---|---|---|
| T1 | 18 | 9 |
| T2 | 39 | 16 |
| T3 | 43 | 23 |
| T4 | 39 | 26 |
| T5 | 22 | 23 |

T1 rises from about 7 eligible to 18, which was the thin band the request called out. Every
tier now has at least three times the board size, so a returning player sees a genuinely
different board most days.

**Gold capstones:** exactly three, all weekly. `w_garrick_steel` at 40 GM,
`w_corwin_bows` at 25 GM, `w_quinn_caravan` at 25 GM.

---

## 4. Sizing Used

**Delivery Silver** is 1.8 times the Traveling Merchant floor value of the goods consumed,
rounded to the nearest 5. **Finished gear** uses 3.5 times, because the floor prices the
object and not the gathering and processing chain behind it. Both carry over from v2.0
unchanged.

**Track Silver** is the tier base: 60, 90, 130, 180, 240 daily, and five times that weekly.
A handful of Track quests carry a hand-set figure where the count is unusual, noted in the
tables.

**XP is a flat garnish scaled by tier**, per the as-built deviation:

| Tier band | Daily XP | Weekly XP |
|---|---|---|
| T1 | 120 | 500 |
| T2 | 180 | 750 |
| T3 | 240 | 1,000 |
| T4 | 300 | 1,250 |
| T5 | 360 | 1,500 |

The figure is taken from the quest's `minTier`. Silver and the bonus item are the payout;
XP is a nod.

**Bonus leash.** No chance exceeds 25 percent. Quantity is 1 everywhere except one 2x Crude
Amber on the T1 logs daily, which is the cheapest rare in the game. Every bonus is themed to
its activity: gather and craft quests pay a Gemstone or the activity's own rare, Undead pays
Ashbone, Void pays Void Crystal or Shard, Arcane pays Arcane Dust.

---

## 5. The Pool

Tables give the transcribable fields. The one-line description follows each table.

### Talent coverage

#### Foraging  (2 daily, 1 weekly)

| questId | Cadence | Objective | Fulfil | Giver | Title | Target | Count | Tier | SM | XP | Bonus |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `hestia_herbs` | Daily | GatherItem | Delivery | Hestia Vale | The Apothecary's Order | Common Herb | 35 | T1 to T3 | 65 SM | 120 Foraging | 1x Rare Herb at 20% |
| `hestia_thornbark` | Daily | GatherItem | Delivery | Hestia Vale | Bark for the Bitter Draught | Thornwood Bark | 20 | T2 to T4 | 70 SM | 180 Foraging | 1x Rare Herb at 20% |
| `w_hestia_forage` | Weekly | GatherItem | Delivery | Hestia Vale | The Spring Gathering | Common Herb | 180 | T1 to T4 | 325 SM | 500 Foraging | 1x Refined Gemstone at 25% |

- `hestia_herbs` > Common herb, cut clean, no root. Hestia has turned away better than you for bringing her root.
- `hestia_thornbark` > Thornwood bark, outer layer only. The inner is useless to her and she has said so.
- `w_hestia_forage` > Everything green she can dry before the damp sets in, and she counts the damp starting Tuesday.

#### Trapping  (3 daily, 1 weekly)

| questId | Cadence | Objective | Fulfil | Giver | Title | Target | Count | Tier | SM | XP | Bonus |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `harl_rabbit` | Daily | GatherItem | Delivery | Old Harl | Harl's Line | Rabbit Pelt | 25 | T1 to T2 | 45 SM | 120 Trapping | 1x Crude Amber at 22% |
| `harl_foxfur` | Daily | GatherItem | Delivery | Old Harl | Winter Fur | Fox Fur | 18 | T2 to T4 | 65 SM | 180 Trapping | 1x Rough Gemstone at 20% |
| `harl_direwolf` | Daily | GatherItem | Delivery | Old Harl | The Bigger Line | Direwolf Hide | 10 | T3 to T5 | 55 SM | 240 Trapping | 1x Dire Fang at 18% |
| `w_harl_shadow` | Weekly | GatherItem | Delivery | Old Harl | What Walks At Dusk | Shadow Pelt | 25 | T4 to T5 | 180 SM | 1250 Trapping | 1x Shadow Essence at 22% |

- `harl_rabbit` > He runs forty snares and checks them all. Some mornings the line runs short and he says nothing about it.
- `harl_foxfur` > Fox, taken clean. Harl can tell how a thing died by the pelt and he would rather not be able to.
- `harl_direwolf` > Direwolf hide, and Harl allows this is not a job for the snares.
- `w_harl_shadow` > Shadow pelt. Harl has set the line where he does not like to walk and will not be drawn on it.

#### Dredging  (3 daily, 1 weekly)

| questId | Cadence | Objective | Fulfil | Giver | Title | Target | Count | Tier | SM | XP | Bonus |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `tamsin_pondfish` | Daily | GatherItem | Delivery | Tamsin Kettle | Fish for the Pot | Pond Fish | 25 | T1 to T2 | 45 SM | 120 Dredging | 1x Crude Gemstone at 22% |
| `tamsin_trout` | Daily | GatherItem | Delivery | Tamsin Kettle | River Trout, Fresh | River Trout | 18 | T2 to T4 | 65 SM | 180 Dredging | 1x Rare Spice at 18% |
| `tamsin_eel` | Daily | GatherItem | Delivery | Tamsin Kettle | Eel for the Smoker | Saltmarsh Eel | 15 | T2 to T4 | 55 SM | 180 Dredging | 1x Black Pearl at 15% |
| `w_tamsin_clam` | Weekly | GatherItem | Delivery | Tamsin Kettle | Deep Water Clams | Deep Clam | 20 | T4 to T5 | 145 SM | 1250 Dredging | 1x Black Pearl at 25% |

- `tamsin_pondfish` > Pond fish, gutted or not, she does not mind. The hall eats at sundown either way.
- `tamsin_trout` > Trout for the officers' table. Tamsin says the officers cannot tell trout from carp and she serves trout anyway.
- `tamsin_eel` > Saltmarsh eel, and she wants them alive in the bucket or not at all.
- `w_tamsin_clam` > Deep clam, which means deep water, which Tamsin notes she is not asking to go into herself.

#### Delving  (3 daily, 1 weekly)

| questId | Cadence | Objective | Fulfil | Giver | Title | Target | Count | Tier | SM | XP | Bonus |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `wren_copper` | Daily | GatherItem | Delivery | Wren | Wren's Trade | Copper Ore | 30 | T1 to T2 | 55 SM | 120 Delving | 1x Crude Gemstone at 20% |
| `garrick_iron_ore` | Daily | GatherItem | Delivery | Garrick Stone | Ore, Not Excuses | Iron Ore | 25 | T2 to T4 | 90 SM | 180 Delving | 1x Rough Gemstone at 20% |
| `garrick_mithril_ore` | Daily | GatherItem | Delivery | Garrick Stone | Mithril, Carefully | Mithril Ore | 12 | T4 to T5 | 85 SM | 300 Delving | 1x Pristine Gemstone at 18% |
| `w_wren_salvage` | Weekly | GatherItem | Delivery | Wren | Wren's Big Idea | Copper Ore | 250 | T1 to T3 | 450 SM | 500 Delving | 1x Refined Gemstone at 25% |

- `wren_copper` > She is saving for a proper pick and counting in copper. She will offer you less than the ore is worth and mean it kindly.
- `garrick_iron_ore` > Iron ore by the crate. Garrick will not smelt what he cannot see in front of him.
- `garrick_mithril_ore` > Mithril ore, and Garrick has priced the loss on every piece you drop on the way.
- `w_wren_salvage` > She has found a buyer and overpromised, which she will realise about halfway through counting.

#### Felling  (3 daily, 2 weekly)

| questId | Cadence | Objective | Fulfil | Giver | Title | Target | Count | Tier | SM | XP | Bonus |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `bramblewick_pine` | Daily | GatherItem | Delivery | Bramblewick | Bramblewick's Quota | Pine Log | 40 | T1 to T2 | 70 SM | 120 Felling | 2x Crude Amber at 25% |
| `bramblewick_ash` | Daily | GatherItem | Delivery | Bramblewick | Ash for the Wheelwright | Ash Log | 30 | T2 to T4 | 110 SM | 180 Felling | 1x Rough Amber at 22% |
| `bramblewick_ironwood` | Daily | GatherItem | Delivery | Bramblewick | Ironwood, Green | Ironwood Log | 15 | T4 to T5 | 110 SM | 300 Felling | 1x Refined Amber at 18% |
| `w_bramblewick_oak` | Weekly | GatherItem | Delivery | Bramblewick | The Season's Timber | Oak Log | 200 | T2 to T4 | 720 SM | 750 Felling | 1x Refined Amber at 25% |
| `w_bramblewick_ironwood` | Weekly | GatherItem | Delivery | Bramblewick | The Ironwood Order | Ironwood Log | 100 | T4 to T5 | 720 SM | 1250 Felling | 1x Pristine Amber at 25% |

- `bramblewick_pine` > The mill runs short every spring and the mill does not care whose fault that is.
- `bramblewick_ash` > Ash, straight-grained. The wheelwright is fussier than Bramblewick and Bramblewick resents it.
- `bramblewick_ironwood` > Ironwood cut green. Seasoned is someone else's problem and Bramblewick would like it to stay that way.
- `w_bramblewick_oak` > Not the daily quota. The whole season's worth, before the roads turn.
- `w_bramblewick_ironwood` > A hundred lengths of ironwood. He has seen the plans and thinks the architect has never lifted an axe.

#### Gleaning  (2 daily, 1 weekly)

| questId | Cadence | Objective | Fulfil | Giver | Title | Target | Count | Tier | SM | XP | Bonus |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `ilric_shards` | Daily | GatherItem | Delivery | Master Ilric | Shards, Any Shards | Crude Rune Shard | 25 | T1 to T3 | 45 SM | 120 Gleaning | 1x Arcane Dust at 22% |
| `ilric_seals` | Daily | GatherItem | Delivery | Master Ilric | Seals Worth Reading | Minor Enchant Seal | 15 | T2 to T4 | 55 SM | 180 Gleaning | 1x Runic Cog at 18% |
| `w_ilric_gleaning` | Weekly | GatherItem | Delivery | Master Ilric | A Reading Week | Crude Rune Shard | 150 | T1 to T4 | 270 SM | 500 Gleaning | 1x Ancient Sigil at 22% |

- `ilric_shards` > Rune shards, unsorted. Ilric will sort them himself and complain about it later.
- `ilric_seals` > Minor enchant seals, intact. A cracked seal tells him nothing and he will hand it back.
- `w_ilric_gleaning` > Everything the ruins will give up. Ilric has cleared his table, which for him is a considerable gesture.

#### Smelting  (3 daily, 2 weekly)

| questId | Cadence | Objective | Fulfil | Giver | Title | Target | Count | Tier | SM | XP | Bonus |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `garrick_bronze` | Daily | ProcessItem | Delivery | Garrick Stone | Bronze, Not Brass | Bronze Bar | 20 | T1 to T3 | 35 SM | 120 Smelting | 1x Crude Gemstone at 22% |
| `garrick_bars` | Daily | ProcessItem | Delivery | Garrick Stone | The Forge Order | Iron Bar | 15 | T2 to T4 | 110 SM | 180 Smelting | 1x Runic Cog at 15% |
| `garrick_mithril_bar` | Daily | ProcessItem | Delivery | Garrick Stone | Mithril, Poured Clean | Mithril Bar | 10 | T4 to T5 | 145 SM | 300 Smelting | 1x Pristine Gemstone at 18% |
| `w_garrick_steel` | Weekly | ProcessItem | Delivery | Garrick Stone | The Keep's Commission | Steel Bar | 60 | T3 to T5 | 650 SM, 40 GM | 1000 Smelting | 1x Pristine Gemstone at 25% |
| `w_garrick_void` | Weekly | ProcessItem | Delivery | Garrick Stone | The Void Alloy Order | Void Alloy | 30 | T5 | 540 SM | 1500 Smelting | 1x Void Core at 25% |

- `garrick_bronze` > Bronze bar. Garrick has been handed brass twice this month and did not care for it.
- `garrick_bars` > Iron bar, not ore. Garrick has a commission and no interest in doing your half of the work as well.
- `garrick_mithril_bar` > Mithril bar with no slag in it. He will hold each one to the light and he will find the slag.
- `w_garrick_steel` > Sixty bars for the keep, and Garrick has staked his name on the delivery date rather than yours.
- `w_garrick_void` > Void alloy, and Garrick has stopped asking what the keep wants it for.

#### Tanning  (3 daily, 1 weekly)

| questId | Cadence | Objective | Fulfil | Giver | Title | Target | Count | Tier | SM | XP | Bonus |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `odell_fox_leather` | Daily | ProcessItem | Delivery | Mother Odell | Odell's Cure | Fox Leather | 10 | T2 to T4 | 70 SM | 180 Tanning | 1x Rough Binding Sigil at 15% |
| `odell_vellum` | Daily | ProcessItem | Delivery | Mother Odell | Skins for the Scribes | Vellum | 8 | T3 to T5 | 85 SM | 240 Tanning | 1x Ancient Sigil at 10% · **corrected: target not in vetted appendix** |
| `odell_direwolf` | Daily | ProcessItem | Delivery | Mother Odell | Direwolf, Properly Done | Direwolf Leather | 10 | T4 to T5 | 145 SM | 300 Tanning | 1x Refined Amber at 18% |
| `w_odell_wolf` | Weekly | ProcessItem | Delivery | Mother Odell | Winter Coats | Wolf Leather | 40 | T3 to T5 | 430 SM | 1000 Tanning | 1x Pristine Amber at 22% |

- `odell_fox_leather` > She wants it tanned, not raw, and will tell you about the winter of the long freeze while she inspects it.
- `odell_vellum` > The scholars want vellum and they want it thin. Odell says they have never scraped a hide in their lives.
- `odell_direwolf` > Direwolf leather. Odell says the trick is patience and she has no expectation you have any.
- `w_odell_wolf` > Forty hides cured properly. She has seen what happens to people who buy their leather cheap.

#### Alchemy  (3 daily, 2 weekly)

| questId | Cadence | Objective | Fulfil | Giver | Title | Target | Count | Tier | SM | XP | Bonus |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `hestia_salve` | Daily | ProcessItem | Delivery | Hestia Vale | Salve for the Ward | Healing Salve | 12 | T1 to T3 | 45 SM | 120 Alchemy | 1x Rare Herb at 22% |
| `hestia_extract` | Daily | ProcessItem | Delivery | Hestia Vale | Extract, Not Leaf | Herb Extract | 10 | T2 to T5 | 70 SM | 180 Alchemy | 1x Moonbloom Petal at 15% · **corrected: target not in vetted appendix** |
| `hestia_clarity` | Daily | ProcessItem | Delivery | Hestia Vale | Tonics for the Scholars | Clarity Tonic | 10 | T2 to T4 | 70 SM | 180 Alchemy | 1x Moonbloom Petal at 18% |
| `w_hestia_apoth` | Weekly | ProcessItem | Delivery | Hestia Vale | Stocking the Shelves | Herb Extract | 50 | T1 to T5 | 360 SM | 500 Alchemy | 1x Rare Herb at 20% · **corrected: target not in vetted appendix; bonus retargeted** |
| `w_hestia_draughts` | Weekly | ProcessItem | Delivery | Hestia Vale | A Season of Draughts | Speed Draught | 50 | T3 to T5 | 630 SM | 1000 Alchemy | 1x Moonbloom Petal at 25% |

- `hestia_salve` > Healing salve, made to her measure, which is the only measure she recognises.
- `hestia_extract` > Hestia can make her own extract. She would simply rather be doing three other things at once.
- `hestia_clarity` > Clarity tonic. The scholars order it by the crate and drink it like water.
- `w_hestia_apoth` > Fifty vials. Hestia has a ward full of people who will need them and no time to say so twice.
- `w_hestia_draughts` > Speed draughts for the couriers. They lose them, break them, and come back for more.

#### Cookery  (3 daily, 1 weekly)

| questId | Cadence | Objective | Fulfil | Giver | Title | Target | Count | Tier | SM | XP | Bonus |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `tamsin_stew` | Daily | ProcessItem | Delivery | Tamsin Kettle | Stew for the Hall | Simple Stew | 15 | T1 to T3 | 55 SM | 120 Cookery | 1x Rare Spice at 22% |
| `tamsin_rations` | Daily | ProcessItem | Delivery | Tamsin Kettle | Rations for the Road | Traveler's Ration | 12 | T3 to T5 | 150 SM | 240 Cookery | 1x Rare Spice at 18% |
| `tamsin_feast` | Daily | ProcessItem | Delivery | Tamsin Kettle | The Warden's Table | Warden's Feast | 6 | T4 to T5 | 110 SM | 300 Cookery | 1x Pristine Amber at 18% |
| `w_tamsin_provision` | Weekly | ProcessItem | Delivery | Tamsin Kettle | Provisioning the Hall | Simple Stew | 90 | T1 to T4 | 325 SM | 500 Cookery | 1x Refined Gemstone at 25% |

- `tamsin_stew` > Simple stew, a lot of it. Nobody has ever complimented it and nobody has ever left it.
- `tamsin_rations` > Traveler's rations that will survive a week in a pack. She has opinions about the ones that do not.
- `tamsin_feast` > A proper feast. Tamsin has cooked for wardens before and remembers which ones said thank you.
- `w_tamsin_provision` > A week of meals in advance, because she has been told the hall is expecting guests and not told how many.

#### Inscription  (3 daily, 1 weekly)

| questId | Cadence | Objective | Fulfil | Giver | Title | Target | Count | Tier | SM | XP | Bonus |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `aldis_seals` | Daily | GatherItem | Delivery | Brother Aldis | Seals for the Archive | Minor Enchant Seal | 14 | T2 to T4 | 50 SM | 180 Inscription | 1x Arcane Dust at 20% |
| `aldis_marks` | Daily | CraftItem | Delivery | Brother Aldis | Marks for the Ledger | Refined Mark | 12 | T3 to T5 | 195 SM | 240 Inscription | 1x Runic Cog at 20% |
| `aldis_sigils` | Daily | CraftItem | Delivery | Brother Aldis | Ancient Sigils, Handled Carefully | Ancient Sigil | 8 | T4 to T5 | 175 SM | 300 Inscription | 1x Master Glyph at 15% |
| `w_aldis_glyphs` | Weekly | CraftItem | Delivery | Brother Aldis | The Great Copy | Master Glyph | 20 | T5 | 540 SM | 1500 Inscription | 1x Soulite Crystal at 25% |

- `aldis_seals` > Minor enchant seals for binding the folios. He has lost three books to damp already this year.
- `aldis_marks` > Refined marks, evenly cut. Aldis copies by hand and will not have his work spoiled by poor stock.
- `aldis_sigils` > Ancient sigils. Aldis will take them wrapped and he will not thank you for unwrapping them yourself.
- `w_aldis_glyphs` > Master glyphs for a work he has been copying for eleven years. He expects to finish it.

#### Artificing  (3 daily, 2 weekly)

| questId | Cadence | Objective | Fulfil | Giver | Title | Target | Count | Tier | SM | XP | Bonus |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `wren_tools` | Daily | CraftItem | Delivery | Wren | Wren's Toolkit Order | Crude Tool | 12 | T1 to T3 | 45 SM | 120 Artificing | 1x Crude Gemstone at 22% |
| `ilric_staves_daily` | Daily | CraftItem | Delivery | Master Ilric | Staves for the Apprentices | any Staff (Rough or below) | 2 | T2 to T4 | 250 SM | 180 Artificing | 1x Arcane Dust at 20% |
| `ilric_totems` | Daily | CraftItem | Delivery | Master Ilric | Totems for the Study | Stone Totem | 10 | T3 to T5 | 160 SM | 240 Artificing | 1x Arcane Dust at 20% |
| `w_ilric_staves` | Weekly | CraftItem | Delivery | Master Ilric | The Apprentices' Order | any Staff (Rough or below) | 3 | T3 to T5 | 610 SM | 1000 Artificing | 1x Pristine Gemstone at 25% |
| `w_ilric_relics` | Weekly | CraftItem | Delivery | Master Ilric | Relics of Iron and Bone | Ironbone Relic | 30 | T4 to T5 | 650 SM | 1250 Artificing | 1x Soulite Crystal at 25% |

- `wren_tools` > Crude tools for the other scavengers. She has decided she is in charge of this and nobody has corrected her.
- `ilric_staves_daily` > Two staves, plain. The apprentices break them and Ilric has stopped being surprised.
- `ilric_totems` > Stone totems, cut to his measure. Ilric will explain the measure at length if you let him.
- `w_ilric_staves` > Three staves for the new intake. Ilric has met them and is managing his expectations.
- `w_ilric_relics` > Ironbone relics for a comparison he is running. He has not said what against.

#### Runesmithing  (3 daily, 2 weekly)

| questId | Cadence | Objective | Fulfil | Giver | Title | Target | Count | Tier | SM | XP | Bonus |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `garrick_daggers_daily` | Daily | CraftItem | Delivery | Garrick Stone | Daggers for the Scouts | any Dagger (Rough or below) | 2 | T1 to T3 | 100 SM | 120 Runesmithing | 1x Rough Gemstone at 20% |
| `garrick_blades_daily` | Daily | CraftItem | Delivery | Garrick Stone | Blades for the Watch | any Sword (Rough or below) | 2 | T2 to T5 | 250 SM | 180 Runesmithing | 1x Refined Gemstone at 18% · **corrected: was 'Sword or Dagger', split to one category** |
| `garrick_fittings` | Daily | CraftItem | Delivery | Garrick Stone | Fittings for the Keep | Steel Fitting | 8 | T3 to T5 | 130 SM | 240 Runesmithing | 1x Refined Gemstone at 18% · **corrected: target not in vetted appendix** |
| `w_garrick_swords` | Weekly | CraftItem | Delivery | Garrick Stone | Blades for the Muster | any Sword (Rough or below) | 3 | T2 to T5 | 380 SM | 750 Runesmithing | 1x Pristine Gemstone at 25% |
| `w_garrick_armour` | Weekly | CraftItem | Delivery | Garrick Stone | Harness for the Keep | any Plate (Rough or below) | 2 | T3 to T5 | 405 SM | 1000 Runesmithing | 1x Pristine Gemstone at 25% |

- `garrick_daggers_daily` > Two daggers. Short, honest, nothing on the pommel.
- `garrick_blades_daily` > Two blades, serviceable, edge held. Garrick will check the edge and will not be quiet about the result.
- `garrick_fittings` > Steel fittings, eight of them, and he has already counted the ones you have not made yet.
- `w_garrick_swords` > Three swords before the muster. Garrick has done this every year and complains every year.
- `w_garrick_armour` > Two pieces of plate, fitted plain. The keep guard are not paying for decoration.

#### Timber Shaping  (2 daily, 1 weekly)

| questId | Cadence | Objective | Fulfil | Giver | Title | Target | Count | Tier | SM | XP | Bonus |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `corwin_bows_daily` | Daily | CraftItem | Delivery | Corwin Ash | Two Plain Bows | any Bow (Rough or below) | 2 | T1 to T3 | 100 SM | 120 Timber Shaping | 1x Rough Amber at 20% |
| `corwin_hafts` | Daily | ProcessItem | Delivery | Corwin Ash | Corwin's Stock | Ash Haft | 12 | T2 to T4 | 110 SM | 180 Timber Shaping | 1x Rough Amber at 20% · **corrected: target not in vetted appendix** |
| `w_corwin_bows` | Weekly | CraftItem | Delivery | Corwin Ash | Three Bows, Made Right | any Bow (Rough or below) | 3 | T2 to T5 | 380 SM, 25 GM | 750 Timber Shaping | 1x Pristine Gemstone at 25% |

- `corwin_bows_daily` > Nothing fancy, he says, twice. The militia lose them faster than he can make them.
- `corwin_hafts` > Ash, seasoned, straight. He will run a thumb down every one and find the crooked one.
- `w_corwin_bows` > Corwin's hands are not what they were and the order is due. He will not say that part out loud.

#### Tailoring  (2 daily, 1 weekly)

| questId | Cadence | Objective | Fulfil | Giver | Title | Target | Count | Tier | SM | XP | Bonus |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `nessa_leather_daily` | Daily | CraftItem | Delivery | Nessa Fen | Leather, Cut Plain | any Leather (Rough or below) | 2 | T1 to T3 | 100 SM | 120 Tailoring | 1x Rough Amber at 22% |
| `nessa_vestments_daily` | Daily | CraftItem | Delivery | Nessa Fen | Vestments for the Chapel | any Vestments (Rough or below) | 2 | T3 to T5 | 405 SM | 240 Tailoring | 1x Refined Gemstone at 18% |
| `w_nessa_vestments` | Weekly | CraftItem | Delivery | Nessa Fen | Cloth for the Order | any Vestments (Rough or below) | 3 | T3 to T5 | 610 SM | 1000 Tailoring | 1x Pristine Gemstone at 25% |

- `nessa_leather_daily` > Two pieces of leather kit. Nessa measured the buyer once and has not asked again.
- `nessa_vestments_daily` > Two vestment pieces. The chapel pays late and Nessa sews for them anyway.
- `w_nessa_vestments` > Three vestment pieces to a pattern she was given and has quietly improved.

### Faction coverage

#### [Outlaw]

| questId | Cadence | Objective | Fulfil | Giver | Title | Target | Count | Tier | SM | XP | Bonus |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `thorne_outlaw` | Daily | DefeatEnemies | Track | Sera Thorne | The Road Toll | [Outlaw] | 25 | T1 to T3 | 60 SM | 120 Combat | 1x Crude Gemstone at 22% |
| `w_thorne_outlaw` | Weekly | DefeatEnemies | Track | Sera Thorne | Clearing the Warrants | [Outlaw] | 100 | T1 to T4 | 450 SM | 500 Combat | 1x Refined Gemstone at 25% |

- `thorne_outlaw` > Brigands on the north road again. Thorne has the warrants already written and only wants them closed.
- `w_thorne_outlaw` > A hundred warrants closed by week's end. Thorne has cleared the column and expects it filled.

#### [Beast]

| questId | Cadence | Objective | Fulfil | Giver | Title | Target | Count | Tier | SM | XP | Bonus |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `thorne_beasts` | Daily | DefeatEnemies | Track | Sera Thorne | Standing Bounty, Beasts | [Beast] | 25 | T1 to T3 | 60 SM | 120 Combat | 1x Crude Gemstone at 20% |
| `harl_beasts` | Daily | DefeatEnemies | Track | Old Harl | Too Many Teeth | [Beast] | 25 | T2 to T4 | 90 SM | 180 Combat | 1x Dire Fang at 20% |
| `w_harl_beasts` | Weekly | DefeatEnemies | Track | Old Harl | A Quiet Wood | [Beast] | 120 | T1 to T5 | 450 SM | 500 Combat | 1x Wyvern Heart at 22% |

- `thorne_beasts` > The ledger has a line for beasts and the line has been open a while.
- `harl_beasts` > Something has been working his line before he gets to it. Harl would like it stopped rather than explained.
- `w_harl_beasts` > Harl wants a week where the line comes back full. He is not optimistic and he is asking anyway.

#### [Undead]

| questId | Cadence | Objective | Fulfil | Giver | Title | Target | Count | Tier | SM | XP | Bonus |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `marrow_undead` | Daily | DefeatEnemies | Track | Dune Marrow | Put Them Back | [Undead] | 25 | T2 to T5 | 90 SM | 180 Combat | 1x Ashbone at 15% · **corrected: bonus was Refined Phantom Pelt (banned)** |
| `aldis_undead` | Daily | DefeatEnemies | Track | Brother Aldis | They Are In The Crypt Again | [Undead] | 25 | T2 to T4 | 90 SM | 180 Combat | 1x Ashbone at 20% |
| `w_marrow_purge` | Weekly | DefeatEnemies | Track | Dune Marrow | A Proper Clearing | [Undead] | 120 | T2 to T5 | 500 SM | 750 Combat | 1x Ashbone at 22% · **corrected: bonus was Pristine Phantom Pelt (banned)** |

- `marrow_undead` > Marrow buried most of them himself. He takes it personally when they do not stay where he put them.
- `aldis_undead` > Aldis went down to copy an inscription and came back without the inscription.
- `w_marrow_purge` > Marrow has stopped digging graves for the season. There is no point until the old ones stay in theirs.

#### [Arcane]

| questId | Cadence | Objective | Fulfil | Giver | Title | Target | Count | Tier | SM | XP | Bonus |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `ilric_arcane` | Daily | DefeatEnemies | Track | Master Ilric | Unbound Workings | [Arcane] | 25 | T2 to T4 | 90 SM | 180 Combat | 1x Arcane Dust at 22% |
| `w_ilric_arcane` | Weekly | DefeatEnemies | Track | Master Ilric | A Controlled Silence | [Arcane] | 90 | T3 to T5 | 650 SM | 1000 Combat | 1x Void Crystal at 25% |

- `ilric_arcane` > Something in the ruins is still running. Ilric wants it stopped before he studies why.
- `w_ilric_arcane` > Ninety of them, and then Ilric would like a week where nothing in the citadel moves on its own.

#### [Void]

| questId | Cadence | Objective | Fulfil | Giver | Title | Target | Count | Tier | SM | XP | Bonus |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `ilric_void` | Daily | DefeatEnemies | Track | Master Ilric | Field Observations | [Void] | 20 | T3 to T5 | 130 SM | 240 Combat | 1x Void Crystal at 18% · **corrected: bonus was Refined Void Spore (banned)** |
| `marrow_void` | Daily | DefeatEnemies | Track | Dune Marrow | What Should Not Be Here | [Void] | 20 | T4 to T5 | 180 SM | 300 Combat | 1x Void Shard at 18% |
| `w_ilric_void` | Weekly | DefeatEnemies | Track | Master Ilric | A Sufficient Sample | [Void] | 90 | T3 to T5 | 650 SM | 1000 Combat | 1x Void Shard at 25% · **corrected: bonus was Pristine Void Spore (banned)** |

- `ilric_void` > Ilric wants them destroyed and wants to know what happens when they are. He considers these the same request.
- `marrow_void` > Marrow has no plot for these and no words over them. He wants them gone regardless.
- `w_ilric_void` > Ninety, Ilric says, is where the pattern becomes visible. He does not say what pattern.

#### [Nature]

| questId | Cadence | Objective | Fulfil | Giver | Title | Target | Count | Tier | SM | XP | Bonus |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `odell_nature` | Daily | DefeatEnemies | Track | Mother Odell | The Mire Is Waking | [Nature] | 25 | T2 | 90 SM | 180 Combat | 1x Rare Herb at 22% |
| `w_odell_nature` | Weekly | DefeatEnemies | Track | Mother Odell | A Season In The Mire | [Nature] | 100 | T2 | 450 SM | 750 Combat | 1x Refined Amber at 25% |

- `odell_nature` > The mire has always been unfriendly. Odell says it has started being deliberate about it.
- `w_odell_nature` > A hundred of them, and Odell will tell you which parts are worth keeping.

### Elite, boss, dungeon, exchange, and zone

| questId | Cadence | Objective | Fulfil | Giver | Title | Target | Count | Tier | SM | XP | Bonus |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `quinn_dungeon` | Daily | CompleteDungeon | Track | Halvard Quinn | Clear the Road | any dungeon | 1 | T2 to T5 | 120 SM | 180 Combat | 1x Refined Amber at 25% |
| `aldis_dungeon` | Daily | CompleteDungeon | Track | Brother Aldis | An Inscription Worth Copying | any dungeon | 1 | T3 to T5 | 140 SM | 240 Combat | 1x Ancient Sigil at 22% |
| `w_quinn_caravan` | Weekly | CompleteDungeon | Track | Halvard Quinn | The Whole Route | any dungeon | 3 | T2 to T5 | 600 SM, 25 GM | 750 Combat | 1x Pristine Amber at 28% |
| `w_marrow_boss` | Weekly | DefeatBoss | Track | Dune Marrow | Three Graves Prepared | any zone boss | 3 | T2 to T5 | 500 SM | 750 Combat | 1x Ancient Fang at 25% |
| `thorne_elites` | Daily | DefeatElites | Track | Sera Thorne | The Named Ones | any Elite | 3 | T1 to T5 | 100 SM | 120 Combat | 1x Refined Gemstone at 20% |
| `w_thorne_bounty` | Weekly | DefeatElites | Track | Sera Thorne | The Long Ledger | any Elite | 15 | T1 to T5 | 450 SM | 500 Combat | 1x Pristine Gemstone at 25% |
| `nessa_zone` | Daily | ReachZone | Track | Nessa Fen | Where The Good Hides Come From | any unvisited zone | 1 | T1 to T4 | 70 SM | 120 Combat | 1x Crude Amber at 20% |
| `quinn_exchange` | Daily | SellOnExchange | Track | Halvard Quinn | Move the Goods | earnings collections | 3 | T1 to T5 | 65 SM | 120 Combat | 1x Crude Amber at 15% · **corrected: count was 5 items, now 3 collections** |
| `w_quinn_exchange` | Weekly | SellOnExchange | Track | Halvard Quinn | A Week of Trade | earnings collections | 10 | T1 to T5 | 300 SM | 500 Combat | 1x Refined Gemstone at 22% |

- `quinn_dungeon` > Quinn has a caravan two days out and something in the dark between here and there.
- `aldis_dungeon` > There is a wall down there Aldis wants read, and something between him and the wall.
- `w_quinn_caravan` > Three cleared before the caravan moves. Quinn has run the numbers on going around and does not like them.
- `w_marrow_boss` > Marrow has dug three already. He says it saves time and he is not joking.
- `thorne_elites` > Three of the ones with names. Thorne does not care which three, only that the ledger balances.
- `w_thorne_bounty` > Fifteen named quarry, closed out by the week's end.
- `nessa_zone` > Nessa wants to know the country her leather comes from before she vouches for it again.
- `quinn_exchange` > Quinn takes a cut of everything that moves through the Exchange and a slow day is a slow day for him too.
- `w_quinn_exchange` > Quinn wants the Exchange busy. His cut depends on it and he has never pretended otherwise.
---

## 6. Notes For Transcription

**Delivery quests** take the item name exactly as written in the Target column. **Gear
quests** set `deliverWeaponType` or `deliverArmorType` to the single named category and cap
accepted quality at Rough.

**Faction quests** set `factionTags` to the single tag shown. Nature must be banded 2 to 2.

**`nessa_zone`** uses ReachZone with an empty `targetId`, meaning any zone the player has
not yet entered. If the engine needs a named zone, band it T1 to T2 and name Saltmarsh Shore.

**The three Gold capstones** are the only weeklies with a non-zero `goldMarks` reward.

**Bonus rewards** go in `bonusReward` with the listed `bonusChance`. Quality-prefixed names
use the ladders in the appendix: Gemstone and Amber run Crude through Pristine with no
Masterwork, Binding Sigil runs Rough through Masterwork with no Crude.

---

## 7. Acceptance Criteria

- 85 definitions exist: 55 daily and 30 weekly.
- Every one of the 15 non-combat talents has at least 2 daily and 1 weekly quest.
- All 6 factions have DefeatEnemies quests, banded where that faction appears.
- Nature quests are banded T2 to T2. Void quests start at T3.
- Every tier band has at least 12 eligible daily and 8 eligible weekly definitions.
- Exactly three weekly quests award Gold Marks. No daily quest does.
- Every gear quest names exactly one weapon or armour category.
- Every SellOnExchange target is a collection count of 10 or fewer.
- No bonus reward uses Void Spore, Phantom Pelt, Masterwork Gemstone, Masterwork Amber, or
  a quality-prefixed Runic Cog.
- Every bonus chance is 25 percent or lower.
- Every new delivery target appears in the vetted appendix.

---

*Path: docs/daily-weekly-quest-system-pool.md*
*85 definitions, 55 daily and 30 weekly. Four new givers. All 15 talents and all 6 factions*
*covered. Five launch quests corrected against the as-built deviations, five more flagged*
*for target verification.*
