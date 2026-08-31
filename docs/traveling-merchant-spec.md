---
type: design-spec
version: 1.0
updated: 2026-08-29
release: 0.1.4
path: docs/traveling-merchant-spec.md
resolves: traveling-merchant-REQUEST.md
retires: material-recycling-spec.md in full, and player_currency.reclaimed_essence
implements: MerchantManager, merchant_sell RPC, convert_gm_to_sm RPC,
            InventoryManager sell actions, RoyalMerchantUI migration
---

# Traveling Merchant and Gold to Silver Conversion
### Version 1.0, release 0.1.4

---

## 1. What This Replaces

`material-recycling-spec.md` is retired in full. Reclaimed Essence, the recycle value
table, `RecycleManager`, the auto-recycle idle hook, and the Royal Merchant Reclamation
tab all go. Section 7 gives the item-by-item migration.

The pivot is correct. Essence solved a designer problem, keeping junk away from the
currency, by inventing a third currency that then needed sinks invented for it. A
merchant paying a low fixed floor in Silver is the simpler shape: it uses a currency the
player already understands, it needs no bespoke store, and the floor price itself is the
guardrail rather than a separate token being the guardrail.

---

## 2. The Rate Conflict, Resolve This First

Two documents disagree about what a Gold Mark is worth, by a factor of ten.

| Source | Rate |
|---|---|
| `wayferers-exchange-and-grimoire-system.md` | 1,000 SM = 1 GM |
| This request | roughly 1 GM = 100 SM |

**Recommendation: 100 SM = 1 GM is canonical. Update the Exchange doc.**

The income figures decide it. Quests yield 8 to 12 GM and 50 to 150 SM per day. At
100:1, daily GM income is worth 800 to 1,200 SM, roughly eight times daily SM income,
which makes GM clearly premium while leaving SM meaningful. At 1,000:1, daily GM income
is worth 8,000 to 12,000 SM, which is eighty times the SM income and makes Silver
decorative.

The 1,000:1 figure predates the current quest reward tuning. Fix the older document
rather than the newer decision, and do it before anything ships that reads either number.

---

## 3. Merchant Buy Rules

### 3.1 What the merchant buys

| Category | Bought | Note |
|---|---|---|
| Raw materials | Yes | The core case |
| Processed materials | Yes | |
| Assembly components | Yes | |
| Consumables | Yes | Potions, meals, coatings |
| Gear, weapons and armour | Yes | Uses `baseSellValue` directly |
| Tools | Yes | Same as gear |
| Grimoires | Never | Account-bound identity |
| Currency items | Never | |
| Quest items | Never | |
| `isProtected` items | Never | |
| Locked items | Never | Respects the existing lock flag |
| Equipped items | Never | |
| Legendary quality | Never | No path, no override |

### 3.2 Quality guardrails

| Quality | Single sell | Bulk sell | Auto-sell |
|---|---|---|---|
| Crude, Rough, Refined | Allowed | Allowed | Allowed |
| Pristine | Allowed | Allowed with a confirm naming the count | Never |
| Masterwork | Allowed with a per-item confirm | Never | Never |
| Legendary | Never | Never | Never |

Masterwork is the output of a roughly 20 percent success upgrade chain. A bulk button
that can consume it is a support ticket, and no confirm dialog makes a mass action on
that content safe.

---

## 4. Pricing Model

### 4.1 The formula

```csharp
// One rule for every item. baseSellValue wins where it is set.
int referenceValue = item.baseSellValue > 0
    ? item.baseSellValue
    : DerivedReference(item.category, item.materialTier);

int floorPrice = Mathf.Max(1, Mathf.RoundToInt(
    referenceValue * QualityFactor(item.quality) * MERCHANT_RATE));

const float MERCHANT_RATE = 0.18f;
```

**Quality factors:** Crude 1.0, Rough 1.5, Refined 2.2, Pristine 3.2, Masterwork 4.5.

**Derived reference, used only when `baseSellValue` is 0:**

| Category | Formula | T1 | T2 | T3 | T4 | T5 |
|---|---|---|---|---|---|---|
| Raw material | 4 + (t-1)*6 | 4 | 10 | 16 | 22 | 28 |
| Processed material | 8 + (t-1)*12 | 8 | 20 | 32 | 44 | 56 |
| Component | 12 + (t-1)*18 | 12 | 30 | 48 | 66 | 84 |
| Consumable | 10 + (t-1)*15 | 10 | 25 | 40 | 55 | 70 |
| Gear | uses `baseSellValue` | 80 | 200 | 320 | 440 | 560 |

The gear row is written to match the existing `80 + (tier-1)*120` exactly, so gear
resolves identically whether it reads the field or the fallback. That keeps one number in
one place and means `baseSellValue` finally does something, which answers the dead-field
problem in passing.

### 4.2 Price tables

**Raw materials, SM**

| Quality | T1 | T2 | T3 | T4 | T5 |
|---|---|---|---|---|---|
| Crude | 1 | 2 | 3 | 4 | 5 |
| Rough | 1 | 3 | 4 | 6 | 8 |
| Refined | 2 | 4 | 6 | 9 | 11 |
| Pristine | 2 | 6 | 9 | 13 | 16 |
| Masterwork | 3 | 8 | 13 | 18 | 23 |

**Processed materials, SM**

| Quality | T1 | T2 | T3 | T4 | T5 |
|---|---|---|---|---|---|
| Crude | 1 | 4 | 6 | 8 | 10 |
| Rough | 2 | 5 | 9 | 12 | 15 |
| Refined | 3 | 8 | 13 | 17 | 22 |
| Pristine | 5 | 12 | 18 | 25 | 32 |
| Masterwork | 6 | 16 | 26 | 36 | 45 |

**Components, SM**

| Quality | T1 | T2 | T3 | T4 | T5 |
|---|---|---|---|---|---|
| Crude | 2 | 5 | 9 | 12 | 15 |
| Rough | 3 | 8 | 13 | 18 | 23 |
| Refined | 5 | 12 | 19 | 26 | 33 |
| Pristine | 7 | 17 | 28 | 38 | 48 |
| Masterwork | 10 | 24 | 39 | 53 | 68 |

**Consumables, SM**

| Quality | T1 | T2 | T3 | T4 | T5 |
|---|---|---|---|---|---|
| Crude | 2 | 4 | 7 | 10 | 13 |
| Rough | 3 | 7 | 11 | 15 | 19 |
| Refined | 4 | 10 | 16 | 22 | 28 |
| Pristine | 6 | 14 | 23 | 32 | 40 |
| Masterwork | 8 | 20 | 32 | 45 | 57 |

**Gear, SM**

| Quality | T1 | T2 | T3 | T4 | T5 |
|---|---|---|---|---|---|
| Crude | 14 | 36 | 58 | 79 | 101 |
| Rough | 22 | 54 | 86 | 119 | 151 |
| Refined | 32 | 79 | 127 | 174 | 222 |
| Pristine | 46 | 115 | 184 | 253 | 323 |
| Masterwork | 65 | 162 | 259 | 356 | 454 |

### 4.3 How the floor sits below the Exchange

The Exchange price bands from `wayferers-exchange-and-grimoire-system.md` are 10 to 500
SM for common items, 500 to 5,000 for uncommon, and 5,000 to 50,000 for rare. The
merchant floor for a Refined T3 component is 19 SM. For Refined T3 gear it is 127 SM.
The merchant pays somewhere between 2 and 20 percent of what the same item fetches from a
player, depending on band.

That gap is wide enough that anyone who checks will list instead, which is the intent.
Section 5.4 makes sure they check.

---

## 5. Sell UI

Sell actions live in the inventory, where the player already is when their bags are full.
The hub station is the shop front, not the transaction surface.

### 5.1 Single item, from the item popup

```
┌─────────────────────────────────────┐
│  Wolf Leather            Refined    │
│  Processed material  ·  Tier 3      │
│  ─────────────────────────────────  │
│  Held                          24   │
│  ─────────────────────────────────  │
│  SELL TO TRAVELING MERCHANT         │
│                                     │
│  Offer per unit             13 SM   │
│  Exchange average          410 SM   │
│                                     │
│      [ - ]      12      [ + ]       │
│                                     │
│  Total                     156 SM   │
│                                     │
│  [        SELL 12        ]          │
│  [       Cancel          ]          │
└─────────────────────────────────────┘
```

The Exchange average line is the important one and it is deliberately placed directly
above the merchant offer. Reading 13 against 410 teaches the player to use the Exchange
without a tutorial, and a player who sells anyway has made an informed choice about
convenience versus value. Populate from `exchange_sale_history` over the last 30 days.
Hide the row when there is no sale history rather than showing a zero.

### 5.2 Bulk sell, from the bulk-select action list

Sits beside the existing Lock and Guild Bank actions. Opens a confirm listing what will
be sold, grouped by category, with a running total.

```
┌─────────────────────────────────────┐
│  SELL 47 ITEMS                      │
│  ─────────────────────────────────  │
│  Raw materials        18      42 SM │
│  Processed           21     189 SM  │
│  Components           8     104 SM  │
│  ─────────────────────────────────  │
│  Total                      335 SM  │
│                                     │
│  Daily buyback      335 of 500 SM   │
│  ███████████████░░░░░░              │
│  ─────────────────────────────────  │
│  Highest value item                 │
│  Wolf Leather   13 SM  ·  Exch 410  │
│  ─────────────────────────────────  │
│  [        CONFIRM        ]          │
│  [        Cancel         ]          │
└─────────────────────────────────────┘
```

Showing the highest-value item in the batch with its Exchange comparison is the guardrail
against a player bulk-dumping something worth listing. One line, and it catches the
mistake that matters.

### 5.3 Hub station

A merchant cart prop in the hub, alongside the four stations in
`hub-hud-station-brief.md`. Tapping it opens a panel that holds no transactions, only
context:

```
┌─────────────────────────────────────┐
│  THE TRAVELING MERCHANT             │
│  ─────────────────────────────────  │
│  "Bring me what you cannot carry."  │
│  ─────────────────────────────────  │
│  BUYING WELL TODAY                  │
│  Leather and hides         +50%     │
│  Herbs and reagents        +50%     │
│  ─────────────────────────────────  │
│  Daily buyback     335 of 500 SM    │
│  ███████████████░░░░░░              │
│  Resets in 6h 42m                   │
│  ─────────────────────────────────  │
│  [   Open Inventory to Sell   ]     │
└─────────────────────────────────────┘
```

### 5.4 Presence model

**Always available for selling. Rotating interest, not rotating availability.**

Gating the ability to clear bags behind a visit schedule would be hostile in an idle
game, where the player opens the app at whatever hour suits them and wants the chore
done. So he always buys.

What rotates is what he wants. Each day two item categories pay +50 percent, seeded from
the UTC date so every player sees the same pair. That gives a daily check-in reason and a
small planning decision (hold the leather until tomorrow) without ever blocking the core
utility.

The bonus applies before the daily cap, so a good day is worth more inside the same cap
rather than raising it.

---

## 6. Gold to Silver Conversion

### 6.1 Rules

- One direction only. GM to SM. There is no SM to GM path anywhere in the game.
- Rate is fixed at 1 GM = 100 SM. No spread, no fee.
- Conversion is always explicit and always confirmed. It never happens silently as part
  of another action.
- Converted SM is ordinary SM with no restrictions.

### 6.2 Make change at checkout

Fires when a Silver purchase exceeds the player's Silver balance and their Gold balance
covers the shortfall.

```
┌─────────────────────────────────────┐
│  NOT ENOUGH SILVER                  │
│  ─────────────────────────────────  │
│  Inventory Slots +5                 │
│                                     │
│  Cost                    6,000 SM   │
│  You have                5,760 SM   │
│  Short                     240 SM   │
│  ─────────────────────────────────  │
│  Convert 3 GM to 300 SM?            │
│                                     │
│  Gold after            9 GM to 6 GM │
│  Silver after     5,760 to 6,060 SM │
│  After purchase             60 SM   │
│  ─────────────────────────────────  │
│  Gold cannot be bought with Silver. │
│  This cannot be reversed.           │
│  ─────────────────────────────────  │
│  [   CONVERT AND BUY   ]            │
│  [        Cancel       ]            │
└─────────────────────────────────────┘
```

Convert `ceil(shortfall / 100)` Gold, never more. The remainder stays as Silver in the
wallet rather than being consumed or refunded, and the prompt names it so the player is
not surprised to find 60 SM afterwards.

The one-way warning stays on the prompt permanently, not just the first time. It is the
single most consequential fact about the conversion and a player converting Gold at 2am
should be told again.

### 6.3 Standalone converter

Yes, but quiet. One row in the Royal Merchant, Inventory category, reading "Exchange Gold
for Silver" and opening the same prompt with a free amount field.

The at-checkout path alone would leave a player unable to get Silver for a player-market
purchase, since Exchange listings are not a Royal Merchant checkout. The standalone row
closes that without advertising the conversion as a feature.

---

## 7. Reclamation Migration

| Old item | Old cost | Fate | New home | New cost |
|---|---|---|---|---|
| Inventory Slots +5 | 400 Essence | Kept, repriced | Royal Merchant, Inventory | 6,000 SM |
| Bulk Reclaim Filter | 600 Essence | Renamed to Bulk Sell Filter | Royal Merchant, Inventory | 3,500 SM |
| Auto-Recycle | 4,500 Essence | Becomes Auto-Sell | Royal Merchant, Inventory | 4,500 SM |
| Salvager's Satchel | 900 Essence | Becomes Merchant's Favor | Royal Merchant, Inventory | 8,000 SM |

**Inventory Slots +5** is priced in Silver rather than Gold on purpose. The existing
Inventory Pack Small gives +10 slots for 150 GM, so the +5 pack becomes the
reachable-by-play option next to a premium one. Since Silver cannot buy Gold, anything
priced in Gold is permanently outside the reach of a non-paying grinder, and slot
expansion should not be.

**Bulk Sell Filter** unlocks category filters in the bulk-sell selector. Same function it
had, new verb.

**Auto-Sell** replaces auto-recycle. Sells anything at or below a chosen quality to the
merchant as it enters the inventory, at the same floor price and against the same daily
cap. Offers Crude, Rough, and Refined only, never Pristine or above. Off by default, and
its activity is reported on the While You Were Away screen. A background process that
silently converts items to currency needs to say so.

**Merchant's Favor** replaces the Salvager's Satchel. A permanent +10 percent on all
merchant offers. Keep it rather than cutting it, because it is the one thing that makes
the merchant a relationship rather than a vending machine, and it pays for itself only
after 80,000 SM of sales, which is self-limiting.

### 7.1 Retiring the currency

```sql
-- 0.1.4: convert any outstanding Essence to Silver, then retire the column.
update player_currency
set    silver_marks = silver_marks + (reclaimed_essence * 2),
       reclaimed_essence = 0
where  reclaimed_essence > 0;

-- Drop in a later migration once 0.1.4 has been live for one release.
-- alter table player_currency drop column reclaimed_essence;
```

Two Silver per Essence is generous and it does not matter, because the Reclamation UI was
never baked and no tester could have accumulated a meaningful balance. Convert rather than
zero, so that anyone who did somehow acquire some is not silently robbed.

Keep the column for one release before dropping it. A dropped column is not recoverable
if the conversion turns out to have missed a code path.

---

## 8. Economy Guardrails

**The floor stays below the Exchange by construction.** `MERCHANT_RATE` at 0.18 puts the
merchant at 2 to 20 percent of typical player-market prices. The rate is a single
constant, so if the gap ever narrows the fix is one number.

**The Exchange comparison is shown at the point of sale**, in both the single and bulk
flows. This is the real guardrail. A hidden floor price that happens to be low relies on
the player never checking. A visible comparison makes the better option obvious.

**Daily buyback cap of 500 SM**, resetting 00:00 UTC to match the quest reset. Above the
cap the merchant still buys, at 25 percent of the floor price, with the UI stating why.

A degraded rate beats a hard block. A player with full bags at the cap can still clear
them, they just do it knowing they are taking a bad deal, and nothing about the core
utility is ever unavailable. A hard cap would send them back to deleting items, which is
the problem this feature exists to solve.

The cap is set at roughly three to ten times daily quest Silver income. Clearing a full
inventory should feel like a good day, not like a job.

**Inflation control is the cap plus the rate, not scarcity of opportunity.** Junk
accrues continuously in an idle crafter, so any uncapped buyback eventually becomes the
dominant Silver source no matter how low the rate. The cap is the load-bearing guardrail
and the rate is the fine tuning.

**No spread.** A buy and sell spread only matters if the merchant also sells, and he does
not. Keep him buy-only. Adding a sell inventory would put him in competition with both
the Royal Merchant and the Exchange for no gain.

---

## 9. Baked Templates

Runtime populates and toggles only. No colours, sizes, spacing, or fonts set in code.

**`MerchantSellPopup`**
```
ItemIcon           (Image)
Title              (Text)     item name
Subtitle           (Text)     "Processed material · Tier 3"
QualityLabel       (Text)
HeldRow
  Right            (Text)     held quantity
OfferRow
  Right            (Text)     "13 SM"
ExchangeRow        (GameObject)  hidden when no sale history
  Right            (Text)     "410 SM"
QtyMinus           (Button)
QtyValue           (Text)
QtyPlus            (Button)
TotalRow
  Right            (Text)     "156 SM"
ConfirmButton      (Button)
ConfirmLabel       (Text)     "SELL 12"
CancelButton       (Button)
```

**`MerchantBulkConfirm`**
```
Title              (Text)     "SELL 47 ITEMS"
CategoryContainer  (Transform) parent for MerchantOfferRow clones
TotalRow
  Right            (Text)
CapLabel           (Text)     "335 of 500 SM"
CapFill            (Image)    fillAmount
HighestItemRow     (GameObject)
  Title            (Text)
  Right            (Text)     "13 SM · Exch 410"
WarningRow         (GameObject)  toggled when the batch includes Pristine
ConfirmButton      (Button)
CancelButton       (Button)
```

**`MerchantOfferRow`**
```
Title              (Text)     category name
Middle             (Text)     count
Right              (Text)     subtotal
```

**`MerchantStationPanel`**
```
Title              (Text)
Flavor             (Text)
InterestHeader     (Text)     "BUYING WELL TODAY"
InterestContainer  (Transform) parent for MerchantOfferRow clones
CapLabel           (Text)
CapFill            (Image)
ResetLabel         (Text)     "Resets in 6h 42m"
OpenInventoryButton (Button)
```

**`MakeChangePrompt`**
```
Title              (Text)     "NOT ENOUGH SILVER"
PurchaseName       (Text)
CostRow            Right (Text)
HaveRow            Right (Text)
ShortRow           Right (Text)
ConversionLine     (Text)     "Convert 3 GM to 300 SM?"
GoldAfterRow       Right (Text)
SilverAfterRow     Right (Text)
RemainderRow       Right (Text)
WarningText        (Text)     one-way and irreversible notice
ConfirmButton      (Button)
CancelButton       (Button)
```

**Reused, no baker work:** the bulk-select action list row, the Royal Merchant store row
for the four migrated items, the settings toggle and chooser rows for Auto-Sell, and the
While You Were Away result row.

**Art:** one merchant cart prop for the hub station, matching the existing station
treatment. No new icons, since Silver already has one.

---

## 10. Server

| Change | Type |
|---|---|
| `merchant_sell(items jsonb)` RPC, validates eligibility, computes price server-side, applies daily cap and interest bonus, credits SM additively | RPC |
| `convert_gm_to_sm(gold int)` RPC, one direction, fixed rate, additive on both sides | RPC |
| `players.merchant_sold_today int`, `players.merchant_reset_at timestamptz` | Migration |
| `players.auto_sell_enabled bool`, `players.auto_sell_max_quality text` | Migration |
| `players.merchant_favor bool` | Migration |
| Essence conversion and column retirement, section 7.1 | Migration |

Price computation belongs in the RPC. The client proposing which items to sell is fine.
The client computing what they are worth is not, for the same reason every other currency
grant already goes through an additive server call.

---

## 11. Things Worth Flagging

**11.1 The GM rate conflict is the highest-risk item in this document.** Two live specs
disagree by 10x on what a Gold Mark is worth. Whichever way it is resolved, resolve it in
both documents in the same commit.

**11.2 `baseSellValue` is only set on gear.** Materials and consumables leave it at 0,
which is why section 4.1 needs a fallback at all. The cleaner end state is to author the
field on every item and delete the fallback. Worth doing eventually, not worth blocking
0.1.4 on.

**11.3 Auto-Sell converts items to currency in the background.** That is a bigger step
than auto-recycle was, because Silver is fungible and Essence was not. The While You Were
Away line is not optional. A player who returns to find their bags empty and their Silver
up needs to be told which items went.

**11.4 The merchant undercuts the Guild Merchant as well as the Exchange.** Guild
listings carry a dual SM and GM price and a fee that funds the guild bank. Nothing in this
spec breaks that, but a guild whose members all dump to the merchant instead of listing
internally loses bank income. Worth watching once guilds are active, and the fix if it
bites is a guild perk that raises merchant prices for members, not a nerf to the merchant.

**11.5 No new tradable output exists here, which is the point.** The merchant emits
Silver and nothing else. There is no scrap resource, no token, and nothing that can
re-enter the market as laundered value. That property is what makes this simpler than the
system it replaces, and it should survive any future addition to the merchant.

---

## 12. Acceptance Criteria

- The merchant buys every non-protected, non-locked, non-equipped, non-quest item except
  Grimoires, currency, and Legendary quality.
- Price is computed server-side from `baseSellValue` where set and the derived table
  otherwise, times the quality factor, times 0.18.
- Gear resolves to the same price whether it reads `baseSellValue` or the fallback.
- Masterwork items are excluded from bulk sell and require a per-item confirm.
- Pristine items are excluded from auto-sell.
- Both sell flows display the Exchange average beside the merchant offer where sale
  history exists.
- The daily cap is 500 SM, resets at 00:00 UTC, and above it the merchant pays 25 percent
  with the UI stating why.
- Two item categories pay +50 percent each day, seeded from the UTC date, identical for
  all players.
- Gold converts to Silver at exactly 100 SM per GM, one direction only, always confirmed.
- No path anywhere converts Silver to Gold.
- Make change converts the minimum whole Gold that covers the shortfall and leaves the
  remainder as Silver.
- All four Reclamation items exist in their new form at their new prices.
- Reclaimed Essence balances are converted to Silver and the balance is zeroed.
- Auto-Sell activity appears on the While You Were Away screen.
- Runtime sets no colours, sizes, spacing, or fonts in any template in this spec.

---

*Path: docs/traveling-merchant-spec.md*
*Retires material-recycling-spec.md and Reclaimed Essence. Merchant pays 18 percent of a*
*reference value in Silver, capped at 500 SM per day. Gold converts to Silver at 100 to 1,*
*one direction, always confirmed. Four Reclamation items migrate to Silver pricing.*
