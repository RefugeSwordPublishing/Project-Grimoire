---
type: design-spec
version: 2.0
updated: 2026-08-29
release: 0.1.4
path: docs/daily-weekly-quest-system.md
supersedes: daily-weekly-quest-system.md v1.0 sections 4, 6, 11
carries: daily-weekly-quest-system-scaling.md reward scaling model
resolves: themed-quests-REQUEST.md
implements: QuestDefinition.giverName, QuestDefinition.fulfillment,
            accept-to-pin, Delivery turn-in, NoticeBoardUI
economy: traveling-merchant-spec.md v1.0
---

# Themed Quests, Delivery and Bounty Model
### Version 2.0

---

## 0. Two Calls Made Inside The Locked Decisions

**`EarnTalentXP` is retired as an objective type. XP stays as a primary reward.**

The problem was never XP as a payout. It was the tautology of "earn 1,500 Felling XP and
I will give you Felling XP," where the ask and the reward are the same currency and the
quest adds nothing but a wrapper around work the player was already doing.

Asking for forty logs and paying in Felling XP is a different thing entirely. The player
earns XP while gathering because gathering earns XP, and then earns more for handing the
logs to someone who wanted them. The objective is a thing, the reward is progress, and the
flavour carries the rest.

So: no definition anywhere uses `EarnTalentXP`, and every quest in the pool pays
meaningful XP alongside Silver. The enum value stays in code for save compatibility,
weighted to zero.

**Finished gear is a valid Delivery target at low count and capped quality.**

Gear takes real time to craft, so quantities stay at two or three and the payout uses a
higher multiplier than raw goods, per section 5.2. Gear quests also accept Crude and Rough
only, enforced by the engine and stated in the flavour. A village bowyer wants serviceable
bows, not masterworks, and the cap means the lowest-first consume rule can never reach a
player's good equipment.

---

## 1. Fulfillment Split

| Objective type | Mode | Behaviour |
|---|---|---|
| GatherItem | Delivery | Reads current stock, consumes at turn-in |
| ProcessItem | Delivery | Reads current stock, consumes at turn-in |
| CraftItem | Delivery | Reads current stock, consumes at turn-in. Gear targets are capped at Rough, see section 1.1 |
| DefeatEnemies | Track | Counts from accept, no consume |
| DefeatElites | Track | Counts from accept, no consume |
| DefeatBoss | Track | Counts from accept, no consume |
| CompleteDungeon | Track | Counts from accept, no consume |
| ReachZone | Track | Counts from accept, no consume |
| SellOnExchange | Track | Counts from accept, no consume |
| EarnTalentXP | Retired | See section 0 |

The dividing line is whether the objective names a thing the player can hold. If it does,
the quest is a commission and the goods change hands. If it names something that happened,
the quest is a bounty and only the record changes.

### 1.1 Edge cases

**Finished gear Delivery is capped at Rough.** A gear quest accepts Crude and Rough
items only and the engine enforces the ceiling. Without it, the lowest-first consume rule
would eventually reach a player's Refined or better gear on the day they happened to be
short of cheap stock, and losing a Pristine weapon to a village commission is the single
worst outcome this system could produce. The cap also reads correctly in flavour, because
none of these givers is commissioning a masterwork.

**Quality selection on consume.** A Delivery quest names an item and a count, not a
quality. Consume ascending by quality, lowest first. A player holding 30 Crude and 12
Refined Fox Leather who owes 10 gives up 10 Crude. Never let a turn-in silently eat the
good stock.

**Protected and locked stock is invisible to Delivery.** It does not count toward the
"have" figure and it is never consumed. If a player has 1,500 Pine Logs but 800 are locked,
the quest reads 700 of 1,500 and the turn-in stays disabled. The card states why on tap.

**Two active quests wanting the same item.** Both read the same live balance, so both can
show as fillable when only one can actually be filled. The turn-in re-verifies at confirm
time and fails cleanly with "stock changed" rather than partially completing. Accept this
rather than reserving stock, because reserving would make the balance readout lie.

**Delivery progress before accept counts.** This is the point of reading current stock.
A player who gathered overnight and then accepts a logs quest can turn it in immediately.
Idle time is never wasted by the accept gate.

**Track progress before accept does not count.** Kills before accept are gone. This is the
asymmetry that makes accept meaningful for bounties, and it is why the board is worth
opening at the start of a session rather than the end.

**ReachZone when the player is already in the zone** completes on accept. Requiring them
to leave and re-enter to satisfy a bookkeeping detail is the kind of thing that makes a
quest system feel hostile.

**DefeatBoss requires the kill, not the encounter.** A boss that despawns on its timer
counts for nothing.

**SellOnExchange requires a completed sale.** Listing is not selling. Progress increments
when a buyer purchases, which already matches the collect-earnings flow.

**A Delivery quest is lossless to fail.** Nothing is consumed until turn-in, so an expired
Delivery quest costs the player nothing but the accept slot. A Track quest that expires
loses its accrued progress. Worth stating because it changes which quests a player should
accept when short on time.

---

## 2. Giver Roster

Ten recurring names covering every trade the pool touches. Givers are a `giverName` string
and a flavor line on the existing card. No portraits, no new surface, no relationship
tracking.

| Name | Trade | Personality in one line |
|---|---|---|
| Bramblewick | Millwright, Grimwood | Gruff about quotas, quietly pays over the odds |
| Hestia Vale | Apothecary, Saltmarsh | Precise to the gram, has no patience for approximation |
| Garrick Stone | Forgemaster, Ironspine | Blunt, measures everything twice, trusts nobody's count but his own |
| Mother Odell | Tanner, Ashfen Mire | Old and unhurried, tells you more than you asked for |
| Corwin Ash | Bowyer, Grimwood | Particular to the point of superstition about his materials |
| Sera Thorne | Bounty clerk, guild hall | Dry, bureaucratic, keeps the ledger and quotes it at you |
| Halvard Quinn | Caravan master, everywhere | Practical and permanently behind schedule |
| Wren | Scavenger, guild hall | A kid, eager, consistently undercharges herself |
| Master Ilric | Arcanist scholar, Shattered Citadel | Distracted, answers questions you did not ask |
| Dune Marrow | Undertaker, Dreadhollow | Calm about grim things, which is worse than being grim about them |

### 2.1 Voice rules for titles and descriptions

**Titles name the job or the giver's stake, never the verb and number.** "Bramblewick's
Quota" not "Gather 40 Pine Logs." The objective line under the title already carries the
number, and repeating it in the title wastes the one place the quest can have character.

**Descriptions are one or two sentences in the giver's own register.** They state why the
thing is wanted. They do not restate the count, because the count is on the objective line
and a mismatch between the two is a bug waiting to happen when someone tunes a number.

**These are transactions between working people.** No pleading, no exclamation marks, no
thanking the player in advance. Bramblewick has a quota and you have logs.

**A giver's voice stays consistent across every quest they own.** Garrick is always
counting. Hestia is always exact. Wren always undersells herself. That consistency is the
entire return on having named givers at all.

---

## 3. Daily Pool, 17 Definitions

Board shows 6 of these per day. Player accepts up to 3. All Delivery unless noted.

**Bonus XP column is the small side-reward.** Bonus item and chance are the
`bonusReward` / `bonusChance` pair.

---

**1. `bramblewick_pine`** · Daily · Gather Pine Log x40 · T1 to T2 · Delivery
**Giver:** Bramblewick
**Title:** Bramblewick's Quota
**Description:** The mill runs short every spring and the mill does not care whose fault
that is. Bring pine and he will not ask where it came from.
**Rewards:** 70 SM, Felling XP (daily band)
**Bonus:** 2x Crude Amber, 25 percent

**2. `wren_copper`** · Daily · Gather Copper Ore x30 · T1 to T2 · Delivery
**Giver:** Wren
**Title:** Wren's Trade
**Description:** She has been saving for a proper pick and she is counting in copper. She
will offer you less than the ore is worth and mean it kindly.
**Rewards:** 55 SM, Delving XP (daily band)
**Bonus:** 1x Crude Gemstone, 20 percent

**3. `hestia_herbs`** · Daily · Gather Common Herb x35 · T1 to T3 · Delivery
**Giver:** Hestia Vale
**Title:** The Apothecary's Order
**Description:** Common herb, cut clean, no root. Hestia has turned away better than you
for bringing her root.
**Rewards:** 65 SM, Foraging XP (daily band)
**Bonus:** 1x Rare Herb, 20 percent

**4. `corwin_hafts`** · Daily · Process Ash Haft x12 · T2 to T4 · Delivery
**Giver:** Corwin Ash
**Title:** Corwin's Stock
**Description:** Ash, seasoned, straight. He will run a thumb down every one of them and
he will find the crooked one.
**Rewards:** 110 SM, Timber Shaping XP (daily band)
**Bonus:** 1x Rough Amber, 20 percent

**5. `garrick_bars`** · Daily · Process Iron Bar x15 · T2 to T4 · Delivery
**Giver:** Garrick Stone
**Title:** The Forge Order
**Description:** Iron bar, not ore. Garrick has a commission and no interest in doing your
half of the work as well as his.
**Rewards:** 110 SM, Smelting XP (daily band)
**Bonus:** 1x Runic Cog, 15 percent

**6. `odell_fox_leather`** · Daily · Process Fox Leather x10 · T2 to T4 · Delivery
**Giver:** Mother Odell
**Title:** Odell's Cure
**Description:** She wants it tanned, not raw, and she will tell you about the winter of
the long freeze while she inspects it.
**Rewards:** 70 SM, Tanning XP (daily band)
**Bonus:** 1x Rough Binding Sigil, 15 percent

**7. `garrick_fittings`** · Daily · Craft Steel Fitting x8 · T3 to T5 · Delivery
**Giver:** Garrick Stone
**Title:** Fittings for the Keep
**Description:** Steel fittings, eight of them, and he has already counted the ones you
have not made yet.
**Rewards:** 130 SM, Runesmithing XP (daily band)
**Bonus:** 1x Refined Gemstone, 18 percent

**8. `hestia_extract`** · Daily · Process Herb Extract x10 · T2 to T5 · Delivery
**Giver:** Hestia Vale
**Title:** Extract, Not Leaf
**Description:** Hestia can make her own extract. She would simply rather be doing three
other things at the same time.
**Rewards:** 70 SM, Alchemy XP (daily band)
**Bonus:** 1x Moonbloom Petal, 15 percent

**9. `odell_vellum`** · Daily · Process Vellum x8 · T3 to T5 · Delivery
**Giver:** Mother Odell
**Title:** Skins for the Scribes
**Description:** The scholars want vellum and they want it thin. Odell says they have never
scraped a hide in their lives.
**Rewards:** 85 SM, Tanning XP (daily band)
**Bonus:** 1x Ancient Sigil, 10 percent

**12. `corwin_bows_daily`** · Daily · Craft Bow x2 · T1 to T3 · Delivery · **Gear, Rough or below**
**Giver:** Corwin Ash
**Title:** Two Plain Bows
**Description:** Nothing fancy, he says, twice. The militia lose them faster than he can
make them and a masterwork in the hands of a recruit is a masterwork in a ditch.
**Rewards:** 100 SM, Timber Shaping XP (daily band)
**Bonus:** 1x Rough Amber, 20 percent

**13. `garrick_blades_daily`** · Daily · Craft Sword or Dagger x2 · T2 to T5 · Delivery · **Gear, Rough or below**
**Giver:** Garrick Stone
**Title:** Blades for the Watch
**Description:** Two blades, serviceable, edge held. Garrick will check the edge and he
will not be quiet about the result.
**Rewards:** 250 SM, Runesmithing XP (daily band)
**Bonus:** 1x Refined Gemstone, 18 percent

**10. `thorne_beasts`** · Daily · DefeatEnemies [Beast] x25 · T1 to T3 · **Track**
**Giver:** Sera Thorne
**Title:** Standing Bounty, Beasts
**Description:** The ledger has a line for beasts and the line has been open a while.
Thorne would like to close it before the audit.
**Rewards:** 70 SM, Combat XP (daily band)
**Bonus:** 1x Crude Gemstone, 20 percent

**11. `marrow_undead`** · Daily · DefeatEnemies [Undead] x25 · T2 to T5 · **Track**
**Giver:** Dune Marrow
**Title:** Put Them Back
**Description:** Marrow buried most of them himself. He takes it personally when they do
not stay where he put them.
**Rewards:** 95 SM, Combat XP (daily band)
**Bonus:** 1x Refined Phantom Pelt, 15 percent

**14. `thorne_elites`** · Daily · DefeatElites any x3 · T1 to T5 · **Track**
**Giver:** Sera Thorne
**Title:** The Named Ones
**Description:** Three of the ones with names. Thorne does not care which three, only that
the ledger balances.
**Rewards:** 100 SM, Combat XP (daily band)
**Bonus:** 1x Refined Gemstone, 20 percent

**15. `quinn_dungeon`** · Daily · CompleteDungeon any x1 · T2 to T5 · **Track**
**Giver:** Halvard Quinn
**Title:** Clear the Road
**Description:** Quinn has a caravan two days out and something in the dark between here
and there. He is already behind schedule.
**Rewards:** 120 SM, Combat XP (daily band)
**Bonus:** 1x Refined rare material, 25 percent

**16. `ilric_void`** · Daily · DefeatEnemies [Void] x20 · T3 to T5 · **Track**
**Giver:** Master Ilric
**Title:** Field Observations
**Description:** Ilric wants them destroyed and he wants to know what happens when they
are. He considers these the same request.
**Rewards:** 135 SM, Combat XP (daily band)
**Bonus:** 1x Refined Void Spore, 18 percent

**17. `quinn_exchange`** · Daily · SellOnExchange any x5 · T1 to T5 · **Track**
**Giver:** Halvard Quinn
**Title:** Move the Goods
**Description:** Quinn takes a cut of everything that moves through the Exchange and a
slow day is a slow day for him too.
**Rewards:** 65 SM, Talent XP (daily band, split across active talents)
**Bonus:** 1x Crude Amber, 15 percent

---

## 4. Weekly Pool, 11 Definitions

Board shows 4 per week. Player accepts up to 2. Three carry Gold Marks and are marked
capstone.

---

**W1. `w_bramblewick_oak`** · Weekly · Gather Oak Log x200 · T1 to T4 · Delivery
**Giver:** Bramblewick
**Title:** The Season's Timber
**Description:** Not the daily quota. The whole season's worth, and he needs it before the
roads turn.
**Rewards:** 720 SM, Felling XP (weekly band)
**Bonus:** 1x Refined Amber, 25 percent

**W2. `w_garrick_steel`** · Weekly · Process Steel Bar x60 · T3 to T5 · Delivery · **Capstone**
**Giver:** Garrick Stone
**Title:** The Keep's Commission
**Description:** Sixty bars of steel for the keep, and Garrick has staked his name on the
delivery date rather than on yours.
**Rewards:** 650 SM, 40 GM, Smelting XP (weekly band)
**Bonus:** 1x Pristine Gemstone, 25 percent

**W3. `w_odell_wolf`** · Weekly · Process Wolf Leather x40 · T3 to T5 · Delivery
**Giver:** Mother Odell
**Title:** Winter Coats
**Description:** Forty hides cured properly. She has seen what happens to people who buy
their leather cheap and she will describe it.
**Rewards:** 430 SM, Tanning XP (weekly band)
**Bonus:** 1x Pristine Amber, 22 percent

**W4. `w_hestia_apoth`** · Weekly · Process Herb Extract x50 · T1 to T5 · Delivery
**Giver:** Hestia Vale
**Title:** Stocking the Shelves
**Description:** Fifty vials. Hestia has a ward full of people who will need them and no
time to say so twice.
**Rewards:** 360 SM, Alchemy XP (weekly band)
**Bonus:** 1x Pristine rare material, 20 percent

**W5. `w_corwin_bows`** · Weekly · Craft any Bow x3 · T1 to T5 · Delivery · **Capstone**
**Giver:** Corwin Ash
**Title:** Three Bows, Made Right
**Description:** Corwin's hands are not what they were and the order is due. He will not
say that part out loud.
**Rewards:** 380 SM, 25 GM, Timber Shaping XP (weekly band)
**Bonus:** 1x Pristine Gemstone, 25 percent

**W6. `w_thorne_bounty`** · Weekly · DefeatElites any x15 · T1 to T5 · **Track**
**Giver:** Sera Thorne
**Title:** The Long Ledger
**Description:** Fifteen named quarry, closed out by the week's end. Thorne has the column
ready and would like it filled.
**Rewards:** 450 SM, Combat XP (weekly band)
**Bonus:** 1x Pristine Gemstone, 25 percent

**W7. `w_marrow_purge`** · Weekly · DefeatEnemies [Undead] x120 · T2 to T5 · **Track**
**Giver:** Dune Marrow
**Title:** A Proper Clearing
**Description:** Marrow has stopped digging graves for the season. He says there is no
point until the old ones stay in theirs.
**Rewards:** 500 SM, Combat XP (weekly band)
**Bonus:** 1x Pristine Phantom Pelt, 22 percent

**W8. `w_quinn_caravan`** · Weekly · CompleteDungeon any x3 · T2 to T5 · **Track** · **Capstone**
**Giver:** Halvard Quinn
**Title:** The Whole Route
**Description:** Three of them, cleared, before the caravan moves. Quinn has run the
numbers on going around and he does not like them.
**Rewards:** 600 SM, 25 GM, Combat XP (weekly band)
**Bonus:** 1x Pristine rare material, 28 percent

**W9. `w_ilric_void`** · Weekly · DefeatEnemies [Void] x90 · T3 to T5 · **Track**
**Giver:** Master Ilric
**Title:** A Sufficient Sample
**Description:** Ninety, Ilric says, is where the pattern becomes visible. He does not say
what pattern.
**Rewards:** 650 SM, Combat XP (weekly band)
**Bonus:** 1x Pristine Void Spore, 25 percent

**W10. `w_wren_salvage`** · Weekly · Gather Copper Ore x250 · T1 to T3 · Delivery
**Giver:** Wren
**Title:** Wren's Big Idea
**Description:** She has found a buyer and overpromised, which she will realise about
halfway through counting.
**Rewards:** 450 SM, Delving XP (weekly band)
**Bonus:** 1x Refined Gemstone, 25 percent


**W11. `w_garrick_armour`** · Weekly · Craft Plate piece x2 · T3 to T5 · Delivery · **Gear, Rough or below**
**Giver:** Garrick Stone
**Title:** Harness for the Keep
**Description:** Two pieces of plate, fitted plain. The keep guard are not paying for
decoration and Garrick is not in the mood to argue the point again.
**Rewards:** 600 SM, Runesmithing XP (weekly band)
**Bonus:** 1x Pristine Gemstone, 25 percent

---

## 5. Reward Sizing, With The Reasoning

### 5.1 Delivery pays a multiple of merchant value

```
questSM = round(merchantFloorValue(items) * 1.8 / 5) * 5
```

The Traveling Merchant is the price floor for any stack of goods, so it is the correct
anchor. Paying 1.8 times the floor makes a themed commission strictly better than dumping
to the merchant, which is what "themed demand beats the generic floor" has to mean
numerically. It also means every Delivery payout tunes itself: change `MERCHANT_RATE` and
every quest follows without a content pass.

Rounding to the nearest 5 keeps the numbers legible on a card.

### 5.2 Finished gear pays a higher multiple

```
raw, processed, component   questSM = merchantFloorValue * 1.8
finished gear               questSM = merchantFloorValue * 3.5
```

The merchant floor prices an object. It does not price the chain behind the object. A bow
needs limbs, a grip, and tips, each of which needed gathering and processing first, and
then an assembly attempt that can fail. Paying 1.8 times the floor for something that took
an hour of chain work would make gear commissions strictly worse than selling the same
materials raw.

Doubling the multiple lands gear quests where they belong: a two-bow daily at T2 pays 250
SM against a 110 SM materials daily, which is roughly proportional to the time gap.

| Example | Count | Goods floor | Pay |
|---|---|---|---|
| T1 Crude gear | 2 | 28 SM | 100 SM |
| T2 Crude gear | 2 | 72 SM | 250 SM |
| T2 Crude gear | 3 | 108 SM | 380 SM |
| T3 Rough gear | 2 | 172 SM | 600 SM |

Counts stay at two or three, never more. The constraint is craft time, not payout balance,
and a five-bow daily would be a job rather than a quest.

### 5.3 Track pays a tier base scaled by count

| Tier | Daily base | Weekly base |
|---|---|---|
| T1 | 60 SM | 300 SM |
| T2 | 90 SM | 450 SM |
| T3 | 130 SM | 650 SM |
| T4 | 180 SM | 900 SM |
| T5 | 240 SM | 1,200 SM |

Track quests consume nothing, so there is no goods value to anchor on and they price on
time instead. The weekly base is five times the daily, not seven, because a weekly should
be worth more than the dailies it displaces but not so much that skipping dailies to do
weeklies is correct.

### 5.4 Where daily income lands

Three accepted dailies pay roughly 200 to 350 SM. The merchant caps at 500 SM per day.
Together that is 700 to 850 SM of daily Silver income against the old 50 to 150.

That is a large increase and it is deliberate. Silver is now the core earned currency
carrying the migrated Reclamation prices from the merchant spec: 3,500 SM for the Bulk
Sell Filter, 6,000 for Inventory Slots, 8,000 for Merchant's Favor. At the old income
those are months. At the new income they are one to two weeks, which is the right pace for
convenience unlocks.

The two streams stay distinct in feel. The merchant is a floor you can always reach and
it caps. Quests pay better per unit but only three per day and only for what the board
happens to ask for.

### 5.5 Gold stays premium

Three weekly capstones carry Gold, at 25, 25, and 40 GM. A player accepting two weeklies
will often draw neither. Expected weekly Gold from quests sits near 20 to 30 against a
baseline of 56 to 84 from daily income, so quests are a meaningful supplement and never a
Gold faucet.

The old pool paid 8 to 20 GM on routine dailies, which is 56 to 140 GM per week from
dailies alone. That is what undercut Gold as premium and it is now gone entirely.

### 5.6 XP is a primary reward, scaled to the talent

Levelling is the point of an idle crafter. A quest that pays only Silver and a chance of a
trinket is asking the player to step away from the thing they actually want, so XP leads
alongside Silver rather than trailing behind it.

The amount is a fraction of the relevant talent's own next level, not a flat number, so it
stays meaningful at every stage instead of decaying into nothing by talent 40.

```csharp
int talentLevel = TalentManager.GetLevel(quest.rewardTalent);
int xp = Mathf.RoundToInt(TalentManager.XpToNextLevel(talentLevel) * factor);
// daily  factor = 0.12
// weekly factor = 0.45
```

| Talent level | XP to next | Daily band | Weekly band |
|---|---|---|---|
| 10 | 1,990 | 239 | 896 |
| 25 | 8,623 | 1,035 | 3,880 |
| 50 | 26,140 | 3,137 | 11,763 |
| 75 | 50,011 | 6,001 | 22,505 |
| 100 | 79,244 | 9,509 | 35,660 |

**Which talent.** Delivery quests pay the talent that produces the requested item, so a
logs quest pays Felling and a bars quest pays Smelting. Combat objectives pay Combat XP to
the equipped Grimoire at the same factors. `quinn_exchange` is the one quest with no
natural talent and splits its band across the player's three highest-level talents.

**Pace check.** Three dailies and two weeklies come to roughly 3.4 levels per week in the
targeted talents, at every level, because the reward and the requirement scale together.
That is a real accelerant and it is not a replacement for playing: a player actively
working a talent will out-earn it several times over. Quests reward the direction you were
already heading rather than substituting for the journey.

**Why this is not the loop we removed.** The objective is never XP. A giver asks for logs
and pays in Felling XP, and the player earns Felling XP gathering those logs because
gathering earns XP. The reward is a second, larger payment for handing the work to someone
who wanted it. What is gone is the version where the ask itself was a number on an XP bar.

### 5.7 The taste-not-farm leash on bonus items

**Rule: expected bonus yield per day must stay under 10 percent of what one hour of the
relevant activity produces.**

Worked example. `bramblewick_pine` offers 2 Crude Amber at 25 percent, so expected yield
is 0.5 Amber per day, and only on days the quest is both drawn and accepted. Realistic
expectation is roughly 0.2 per day. A player actively felling produces Amber at the
Felling drop rate, which is orders of magnitude more per hour. The quest is a pleasant
surprise attached to work already done and it is never the efficient source.

Three constraints keep it there:

**Chance never exceeds 28 percent.** A bonus the player can count on stops being a bonus
and starts being part of the payout, at which point they will optimise for it.

**Quantity is 1 for anything above Crude.** The 2x Amber on the T1 logs quest is the only
multi-count bonus in the pool, and Crude Amber is the cheapest rare in the game.

**No bonus item is the best source of itself.** Before any bonus is added or tuned, check
it against the drop rate of the activity that normally produces it. `odell_vellum` offers
an Ancient Sigil at 10 percent precisely because Ancient Sigil is a genuine rare and 10
percent on a daily is already at the edge.

---

## 6. Notice Board UX

One panel, two tabs, two sections per tab. Reuses the existing `GamePanel.Quests` entry
rather than adding a surface.

### 6.1 Board layout

```
┌─────────────────────────────────────┐
│  [ Daily ]  [ Weekly ]              │
│  Refreshes in 6h 42m                │
│  ─────────────────────────────────  │
│  ACCEPTED            2 of 3         │
│                                     │
│  ┌───────────────────────────────┐  │
│  │ Bramblewick's Quota           │  │
│  │ Pine Log        1,240 / 1,500 │  │
│  │ ████████████████░░░░          │  │
│  │ 70 SM  ·  200 Felling XP      │  │
│  │ [      Turn In (short)      ] │  │
│  └───────────────────────────────┘  │
│  ┌───────────────────────────────┐  │
│  │ Put Them Back                 │  │
│  │ Undead defeated      18 / 25  │  │
│  │ █████████████░░░░░░░          │  │
│  │ 95 SM  ·  300 Combat XP       │  │
│  └───────────────────────────────┘  │
│  ─────────────────────────────────  │
│  TODAY'S BOARD                      │
│                                     │
│  ┌───────────────────────────────┐  │
│  │ The Apothecary's Order        │  │
│  │ Hestia Vale                   │  │
│  │ "Common herb, cut clean, no   │  │
│  │  root. Hestia has turned away │  │
│  │  better than you for bringing │  │
│  │  her root."                   │  │
│  │ Deliver Common Herb x35       │  │
│  │ 65 SM  ·  200 Foraging XP     │  │
│  │ Chance of a rare find         │  │
│  │ [          Accept           ] │  │
│  └───────────────────────────────┘  │
│  ...                                │
└─────────────────────────────────────┘
```

Accepted quests sit above the board, because a returning player wants their active work
first and the offers second.

The bonus item is described, never itemised. "Chance of a rare find" rather than "20
percent chance of 1x Rare Herb." Naming the item and the odds turns a surprise into a
number the player evaluates, and a bonus that gets evaluated gets farmed.

### 6.2 Accept

One tap on the Accept button. No confirm. Accepting costs nothing and is capped, so the
worst case is a wasted slot the player can see and live with for one day.

Once at the cap, remaining board cards render their button disabled reading "3 of 3
accepted". The card stays fully readable, because a player deciding what to accept
tomorrow benefits from seeing what they turned down today.

Accepting cannot be undone. Abandoning would let a player reroll their slots by cycling
through the board, which turns a choice into a shopping trip.

### 6.3 Delivery turn-in

The button reads one of three ways and is the clearest signal on the card:

| State | Button | Enabled |
|---|---|---|
| Stock below target | "Turn In (short)" | No |
| Stock meets target | "Turn In 35 Common Herb" | Yes |
| Locked stock blocks it | "Turn In (locked stock)" | No, tap explains |

The short state shows the live balance on the progress line as "1,240 / 1,500", updating
as idle gathering lands. That readout is the feature: a player can watch a Delivery quest
fill itself while they are elsewhere in the app.

Confirm modal:

```
┌─────────────────────────────────────┐
│  HAND OVER TO HESTIA VALE           │
│  ─────────────────────────────────  │
│  Common Herb, Crude          x35    │
│  ─────────────────────────────────  │
│  You receive                        │
│  Silver Marks                65 SM  │
│  Foraging XP                   200  │
│  ─────────────────────────────────  │
│  Consumed from your inventory.      │
│  ─────────────────────────────────  │
│  [        HAND OVER        ]        │
│  [         Cancel          ]        │
└─────────────────────────────────────┘
```

The modal names the exact quality being consumed, because the lowest-first rule is
invisible until it is wrong and a player who sees "Crude" understands the rule instantly.

Track quests skip this entirely. Their button reads "Claim" and grants directly.

### 6.4 Baked regions

**`NoticeBoardPanel`**
```
TabDaily            (Button)
TabWeekly           (Button)
RefreshLabel        (Text)      "Refreshes in 6h 42m"
AcceptedHeader      (Text)      "ACCEPTED"
AcceptedCount       (Text)      "2 of 3"
AcceptedContainer   (Transform) parent for QuestActiveCard clones
BoardHeader         (Text)      "TODAY'S BOARD"
BoardContainer      (Transform) parent for QuestOfferCard clones
EmptyState          (GameObject) shown when the board is exhausted
```

**`QuestOfferCard`**
```
Title               (Text)
GiverName           (Text)
Description         (Text)
ObjectiveLine       (Text)      "Deliver Common Herb x35"
RewardSM            (Text)      "65 SM"
RewardXP            (Text)      "200 Foraging XP"
BonusHint           (GameObject) "Chance of a rare find", hidden when no bonus
AcceptButton        (Button)
AcceptLabel         (Text)      "Accept" or "3 of 3 accepted"
```

**`QuestActiveCard`**
```
Title               (Text)
GiverName           (Text)
ObjectiveLine       (Text)      "Pine Log" or "Undead defeated"
ProgressLabel       (Text)      "1,240 / 1,500"
ProgressFill        (Image)     fillAmount
RewardSM            (Text)
RewardXP            (Text)
ActionButton        (Button)
ActionLabel         (Text)      "Turn In 35 Common Herb" / "Turn In (short)" / "Claim"
LockedHint          (GameObject) shown when locked stock blocks turn-in
```

**`QuestTurnInModal`**
```
Title               (Text)      "HAND OVER TO HESTIA VALE"
ConsumeContainer    (Transform) parent for QuestLineRow clones
ReceiveHeader       (Text)      "You receive"
ReceiveContainer    (Transform) parent for QuestLineRow clones
ConsumeNotice       (Text)      "Consumed from your inventory."
ConfirmButton       (Button)
CancelButton        (Button)
```

**`QuestLineRow`**
```
Title               (Text)
Right               (Text)
```

Four new templates plus one row. The existing card templates do not fit because offer
cards and active cards now carry different content, and forcing one prefab to be both
would mean the runtime toggling half its children.

---

## 7. Guardrails

**Board size and accept cap.** Daily board shows 6 offers, accept up to 3. Weekly board
shows 4, accept up to 2. The board is deliberately larger than the cap, because "choose
what to take" only means something when taking everything is not an option. Every tier has
at least 6 daily and 4 weekly eligible definitions, verified against the banding.

**Refresh.** Daily board regenerates at 00:00 UTC. Weekly at Monday 00:00 UTC. Both match
the existing reset logic and the merchant's daily cap reset, so the whole game has one
rollover moment.

**Rollover of accepted-but-unfinished quests.** They expire. No partial reward, no
carry-over, no penalty. The accept slot is released with the new board.

This lands differently by mode and that asymmetry is worth surfacing to the player.
A Delivery quest that expires costs nothing, because nothing was consumed and the
materials are still in the bag for tomorrow's board. A Track quest that expires loses its
accrued kills. A player with twenty minutes should accept Delivery quests they can already
fill, and a player settling in for the evening should take the Track bounties.

**Anti-hoarding.** No guard beyond the accept cap, and the reason is worth stating.
A stockpiling player who instantly fills a Delivery quest every morning still earns only
three quests of Silver per day, and the stock they are drawing down was gathered with real
time. The cap is the throttle, and adding a second one would punish preparation, which is
the behaviour an idle crafter should reward.

**The one real arbitrage to watch.** A Delivery quest becomes exploitable if the Exchange
price per unit for its item drops below the quest's implied per-unit payout, because the
player could buy stock and flip it. At current numbers the gap is wide: `bramblewick_pine`
pays 1.8 SM per log against an Exchange common band starting at 10 SM. The rule to hold is
that quest pay per unit must stay below typical Exchange price per unit for that item. If
a future Delivery quest targets something with a thin market, check this before shipping it.

**No reroll, no abandon.** Both would convert the accept decision into a browse.

---

## 8. What Changes In The Data Model

```csharp
// Added to QuestDefinition:
public string giverName;                 // "Bramblewick"
public QuestFulfillment fulfillment;     // Delivery | Track
public QuestReward bonusReward;          // already present
public float bonusChance;                // already present

public enum QuestFulfillment { Delivery, Track }
```

```sql
-- player_quests gains an accepted flag. Offered rows exist unaccepted.
alter table player_quests add column accepted   boolean not null default false;
alter table player_quests add column accepted_at timestamptz;
```

The assignment Edge Function now writes 6 daily and 4 weekly rows as offers with
`accepted = false`, rather than 3 and 2 as assignments. Accept flips the flag and stamps
the time. Track progress counts only from `accepted_at`.

Delivery turn-in follows the same rails as the merchant sell: verify balance server-side,
deduct through the inventory RPC, grant currency additively, mark claimed. The client
proposing the turn-in is fine. The client computing the reward is not.

---

## 9. Acceptance Criteria

- No quest definition uses `EarnTalentXP` as an objective type.
- Every quest pays talent or combat XP scaled from the relevant talent's XpToNextLevel,
  at 0.12 daily and 0.45 weekly.
- Every quest has a non-empty `giverName` and a description in that giver's voice.
- Delivery quests read current inventory balance, including items gathered before accept.
- Delivery turn-in consumes lowest quality first and never consumes protected or locked items.
- Finished gear Delivery accepts Crude and Rough only, enforced by the engine, and can
  never consume Refined or better gear.
- Finished gear Delivery targets a count of two or three, never more.
- A Delivery quest short of stock shows the live balance as "have / need" and a disabled button.
- Delivery turn-in re-verifies stock at confirm and fails cleanly if it changed.
- Track quests count only from the accept timestamp.
- `ReachZone` completes on accept when the player is already in the target zone.
- Daily board offers 6 from a pool of 17, weekly offers 4 from a pool of 11.
- Accept caps at 3 daily and 2 weekly.
- Every zone tier has at least 6 daily and 4 weekly eligible definitions.
- Accepted quests expire at rollover with no reward and no penalty.
- Delivery quests consume nothing until turn-in, so expiry costs the player no materials.
- Bonus items are described as a chance of a rare find, never itemised with odds.
- No daily quest pays Gold Marks. Exactly three weekly capstones do.
- All currency is granted server-side.
- Runtime sets no colours, sizes, spacing, or fonts in any template in this spec.

---

*Path: docs/daily-weekly-quest-system.md*
*Version 2.0. Retires EarnTalentXP as an objective type and restores XP as a primary*
*reward scaled to the talent. 17 themed dailies, 11 weeklies. Delivery pays 1.8x merchant*
*floor value and 3.5x for finished gear. Gold appears only on three weekly capstones.*
