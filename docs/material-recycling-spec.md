---
type: design-spec
version: 1.0
updated: 2026-08-29
path: docs/material-recycling-spec.md
resolves: material-recycling-REQUEST.md
implements: RecycleManager, recycle_items RPC, players.reclaimed_essence,
            InventoryManager bulk action, RoyalMerchantUI Reclamation category,
            SettingsManager auto-recycle
companion: wayferers-exchange-and-grimoire-system.md, royal-merchant-store-spec.md
---

# Material Recycling
### Version 1.0

---

## 1. The Output Decision

**Recycling produces Reclaimed Essence, a bound token, plus a slice of Talent XP when
the item was crafted rather than gathered.**

Not currency. Not returned materials. Here is why each alternative loses.

**Not Silver Marks, even capped.** The developer's instinct is right and it is worth
stating the reason precisely: SM is the resource the Royal Merchant consumes, and a sink
only has teeth if the resource is scarce. Any faucet on the same resource weakens every
price in that store, and a capped faucet in an idle game is just a slower one, because
the defining property of an idle player is that they have unlimited time to reach a cap.

**Not returned materials.** This is the option that looks safest and is actually the most
dangerous. Any material return rate above zero creates a ratio, and in a game where the
player can run the loop indefinitely, every ratio eventually becomes a printer. Even a
lossy 25 percent return means a player with enough throughput can extract value from
crafting things they do not want. Zero material return is the only rate that cannot be
optimised.

**Talent XP alone is not enough.** It fits the crafter fantasy perfectly and it cannot
inflate anything, because XP is not tradable. But XP is invisible the instant it lands.
Recycling 400 Pine Logs and watching a bar move slightly does not feel like the player
got something. It also makes no sense for gathered raw materials, which the player never
practiced a craft to obtain.

**So: both, split by origin.**

| Item origin | Reclaimed Essence | Talent XP |
|---|---|---|
| Gathered raw material | Yes | No |
| Crafted or assembled item | Yes | Yes, to the crafting talent |

Essence is the tangible accumulating thing. XP is the reward for unmaking something you
made, which is exactly the fantasy an idle crafter is built on. The two together answer
"what did I get" for both halves of the inventory.

---

## 2. Stage Plan

| Stage | Scope | Why this order |
|---|---|---|
| 1 | Reclaimed Essence, value tables, inventory recycle action, guardrails | The verb. Useless alone but nothing else works without it. |
| 2 | Essence sinks: Royal Merchant Reclamation category | Must ship close behind Stage 1. An accumulating resource with no sink is worse than no resource. |
| 3 | Talent XP return with per-talent daily cap | Independent of Stages 1 and 2, adds the crafter payoff |
| 4 | Auto-recycle setting and bulk convenience controls | Pure quality of life, safe to lag |

Do not ship Stage 1 without Stage 2 in the same release. A currency the player cannot
spend teaches them the feature is unfinished, and that impression outlives the fix.

---

## 3. Stage 1, The Recycle Action

### 3.1 Where it lives

**The inventory bulk-select UI, as a third action beside Lock and Guild Bank.** No new
hub station and no new panel.

The bulk-select UI already does multi-select, sell, discard, lock, and guild bank. A
player drowning in items is already there when the feeling strikes. Adding a station
elsewhere would mean walking somewhere to do a chore, which is exactly the friction an
idle game cannot afford.

The Essence balance shows as a small chip in the inventory header so the number has a
visible home without needing a screen of its own.

### 3.2 Reclaimed Essence

A bound per-player counter, not an inventory item.

```sql
alter table players add column reclaimed_essence int not null default 0;
```

Stored as a column rather than an ItemData because it is closer to a currency than an
object: it has no quality, no tier, no stack limit that matters, and it must never
occupy an inventory slot in a system whose entire purpose is freeing inventory slots.

**Non-tradable, permanently.** It cannot be listed, cannot enter the guild bank, cannot
be gifted, and has no conversion to SM or GM in either direction. That single rule is
what keeps it from becoming laundered value re-entering the market.

### 3.3 Essence value curve

| Quality | T1 | T2 | T3 | T4 | T5 |
|---|---|---|---|---|---|
| Crude | 2 | 2 | 3 | 4 | 4 |
| Rough | 4 | 5 | 6 | 7 | 9 |
| Refined | 7 | 8 | 10 | 13 | 15 |
| Pristine | 11 | 13 | 16 | 20 | 24 |
| Masterwork | 16 | 19 | 24 | 29 | 35 |
| Legendary | Blocked, never recyclable | | | | |

Base by quality is 2, 4, 7, 11, 16, multiplied by tier factors 1.0, 1.2, 1.5, 1.8, 2.2
and rounded.

**Why not derive it from `baseSellValue`.** That field scales roughly linearly with
quality, so deriving from it would make a Masterwork item worth seven times a Crude one
in Essence. The table above deliberately compresses that to eight times across quality
but with much flatter growth at the top, so the marginal Essence from scrapping something
valuable never justifies scrapping something valuable. `baseSellValue` stays what it is,
a reference number, and section 8.3 says what should actually happen to it.

### 3.4 How this sits below the Exchange

The brief asks how recycling compares to Exchange price so that recycling stays the
floor. The honest answer is that they are not comparable by design, and that is the
mechanism rather than a dodge.

Selling on the Exchange yields Marks, which buy gear, Grimoires, Assembly rares, and
everything else that makes a character stronger. Recycling yields Essence, which buys
convenience and insurance and nothing else, ever. See section 4 for the sink list and
the rule that governs it.

A player choosing to recycle a Pristine Drake Leather instead of listing it is not making
a slightly worse trade, they are trading power for convenience. That is a real decision
with a clear loser, which is what keeps the Exchange alive. No price ratio to tune, and
no risk that a market swing accidentally makes recycling optimal.

### 3.5 Guardrails

| Rule | Behaviour |
|---|---|
| `isProtected` items | Never recyclable, excluded from every selector including auto |
| Locked items | Never recyclable, excluded from every selector including auto |
| Legendary | Never recyclable by any path, no override |
| Masterwork | Excluded from bulk and auto. Single-item recycle allowed with a modal confirm naming the item. |
| Pristine | Included in bulk with a modal confirm stating the count. Excluded from auto by default. |
| Equipped items | Never recyclable |
| Zero-value items | Recycle yields the floor of 1 Essence rather than 0, so the action never appears broken |

The Masterwork and Legendary rules are the important ones. A bulk button that can
destroy the output of a 20 percent success-rate upgrade chain is a support ticket
waiting to happen, and no amount of confirm dialog makes a mass action on that content
safe.

---

## 4. Stage 2, Where Essence Goes

Essence gets a **Reclamation** category in the Royal Merchant, alongside the existing
five. It is the only category that spends Essence and no other category accepts it.

**The governing rule for every Essence sink: convenience and insurance, never power.**
Nothing purchasable with Essence may raise a stat, improve a drop rate, or produce a
tradable good. Break that rule once and Essence becomes a shadow currency with a
conversion path to power, which is the thing this whole design exists to prevent.

### 4.1 Reclamation category rows

| Item | Cost | Effect |
|---|---|---|
| Reclamation Charge | 120 Essence | Assembly bench: returns the rare material on one failed upgrade. Consumed on use. |
| Reclamation Charge, 5 pack | 540 Essence | Same, bundled at a 10 percent discount |
| Attunement Extension | 200 Essence | Extends the next attunement window by 50 percent, one use |
| Inventory Slots +5 | 400 Essence | Permanent, stacks with the GM slot packs |
| Salvager's Satchel | 900 Essence | Permanent. Raises all Essence yields by 15 percent. |
| Bulk Reclaim Filter | 600 Essence | Permanent. Unlocks category filters in auto-recycle. |

**Reclamation Charge is the flagship and it should ship first.** It closes a loop that
is otherwise a genuine pain point: the Masterwork band runs at 20 percent base success
and consumes the rare material on failure, which means roughly five Binding Sigils per
successful Masterwork upgrade. Letting a player convert the junk their crafting produces
into protection for the rare materials their crafting consumes is the most thematically
correct sink available, and it makes recycling feel like part of crafting rather than a
chore beside it.

That row depends on the Assembly bench exposing a pre-attempt charge toggle. Flagged in
the checklist as a cross-spec dependency.

---

## 5. Stage 3, Talent XP Return

### 5.1 The formula

Only for crafted and assembled items. Gathered raw materials return Essence only.

```csharp
int qualityIndex = (int)item.quality;          // Crude 0 ... Masterwork 4
int talentLevel  = TalentManager.GetLevel(item.sourceTalent);
int xp = Mathf.RoundToInt(
    TalentManager.XpToNextLevel(talentLevel) * 0.0015f * (qualityIndex + 1));
```

Expressing the return as a fraction of the player's own next-level requirement keeps it
relevant at every level instead of decaying into a rounding error, which a flat number
would do by talent 40.

| Talent level | XP to next | Crude | Rough | Refined | Pristine | Masterwork | Daily cap |
|---|---|---|---|---|---|---|---|
| 10 | 1,990 | 3 | 6 | 9 | 12 | 15 | 298 |
| 25 | 8,623 | 13 | 26 | 39 | 52 | 65 | 1,293 |
| 50 | 26,140 | 39 | 78 | 118 | 157 | 196 | 3,921 |
| 75 | 50,011 | 75 | 150 | 225 | 300 | 375 | 7,502 |
| 100 | 79,244 | 119 | 238 | 357 | 475 | 594 | 11,887 |

### 5.2 The daily cap is the anti-exploit

Cap recycle XP at 15 percent of `XpToNextLevel` per talent per day.

Without a cap there is a real exploit. Crafting an item awards XP, and recycling it
awards more, so craft-then-scrap becomes strictly better than crafting alone for anyone
who does not want the item. In an idle game with unlimited throughput, that becomes the
only correct way to level a crafting talent.

The cap makes the exploit self-limiting. It resolves to 100 Crude items or 33 Refined
items per talent per day at every level, because both the reward and the cap scale with
the same curve. A player recycling their genuine surplus will rarely reach it. A player
farming it hits a wall in a few minutes.

Reset at 00:00 UTC, matching the daily quest reset already in the codebase.

```sql
alter table players add column recycle_xp_today  jsonb not null default '{}'::jsonb;
alter table players add column recycle_xp_reset  timestamptz not null default now();
```

---

## 6. Stage 4, Bulk and Auto-Recycle

### 6.1 Manual controls

| Control | Behaviour |
|---|---|
| Recycle Selected | Acts on the current bulk selection |
| Recycle All Below Quality | Picks a quality from a chooser, recycles everything at or under it |
| Recycle All In Category | Gathering, Crafting, Consumables, Gear, subject to the same quality ceiling |

All three route through one confirm modal showing the item count, the quality range, and
the total Essence and XP the action will award. Showing the reward before the confirm is
what turns a destructive action into a satisfying one.

### 6.2 Auto-recycle

A `SettingsManager` toggle plus a threshold, persisted per player.

```sql
alter table players add column auto_recycle_enabled     boolean not null default false;
alter table players add column auto_recycle_max_quality text    not null default 'crude';
```

When enabled, any item entering the inventory at or below the chosen quality is recycled
on arrival. Default off, default threshold Crude.

**Auto-recycle never touches Pristine or above, regardless of the setting.** The chooser
offers Crude, Rough, and Refined only. A background process that can silently consume a
Pristine item is not a setting, it is a trap.

**Report what it did.** The While You Were Away screen gains a line reading how many
items auto-recycle consumed and the Essence it returned. Silent deletion, even
consented, reads as a bug the first time a player notices something missing.

---

## 7. Economy Safety

The four claims, each with its argument.

**No material perpetual motion.** Recycling returns zero materials of any kind. There is
no ratio to optimise because there is no material output. Gather to craft to recycle
strictly loses materials against gather to craft.

**No currency perpetual motion.** Essence has no conversion to SM or GM in either
direction, and no Essence sink produces a tradable good. Marks cannot be created by any
path in this spec.

**No laundering.** Essence is account-bound and every Reclamation purchase is either
consumed on use or a permanent account unlock. Nothing bought with Essence can be sold,
listed, banked, or gifted, so junk cannot be converted into market value through an
intermediate step.

**No XP exploit.** The per-talent daily cap resolves to a fixed item count at every
level, so the loop cannot outpace normal play regardless of throughput.

The one thing to keep watching after launch is the Salvager's Satchel. A permanent 15
percent yield boost is safe at 15 and would not be at 50, and it is the kind of number
that gets raised in a later balance pass by someone who does not know why it is low.
Worth a code comment.

---

## 8. Things Wrong Beyond The Brief

**8.1 "Sell" opening an Exchange listing is a real usability bug, and this feature makes
it worse.** A player tapping Sell expects an instant transaction. They get a listing
form, a fee, and a wait for a buyer who may never come. Once Recycle exists there will be
two non-instant-looking options and one instant one, and the labels will actively mislead.

Rename it. Sell becomes **List on Exchange**. Recycle becomes the instant option and
should sit directly beneath it in the action list, so the pair reads as "trade it for
Marks, eventually" against "reclaim it now."

**8.2 Discard should be retired once Recycle ships.** Deleting a stack for nothing is
strictly worse than recycling it for something, in every case, for every item. Keeping
both means every player periodically picks the wrong one. Replace Discard with Recycle
in the action list and keep a Destroy path only for the handful of items that yield
nothing, if any exist.

**8.3 `baseSellValue` is a dead field pretending to be live.** Nothing pays it out, but
it is authored on every item and reads like a price. Either wire it to something or
rename it to `referenceValue` so the next person to read it does not assume there is a
vendor somewhere. This spec deliberately does not use it, per section 3.3.

**8.4 New players have no outlet at all, and that is the sharpest version of this
problem.** Exchange access requires a talent at level 10. Before that, a player's only
option for surplus is deletion for nothing. Recycling should be available from level 1,
with no gate, precisely because the players who most need somewhere to put junk are the
ones who cannot yet reach the market. Do not gate this feature behind anything.

**8.5 The Exchange has one SM sink and it is 3 percent.** Listing fees are the only
thing removing Marks from circulation in normal play. That is thin for a game that
intends the Royal Merchant to be a meaningful gold sink, and it is worth a separate look.
Not this spec's job, but this spec touching the economy is a reasonable moment to raise it.

---

## 9. Build Checklist

### 9.1 Server

| Change | Type | Stage |
|---|---|---|
| `players.reclaimed_essence int default 0` | Migration | 1 |
| `recycle_items(items jsonb)` RPC, validates and awards, server-authoritative | RPC | 1 |
| `players.recycle_xp_today jsonb`, `players.recycle_xp_reset timestamptz` | Migration | 3 |
| `players.auto_recycle_enabled bool`, `players.auto_recycle_max_quality text` | Migration | 4 |
| `merchant_purchases` entries for the six Reclamation rows | Data | 2 |

The RPC must own validation. The client proposing which items to recycle is fine, the
client computing the Essence award is not, for the same reason currency grants already
go through additive server RPCs.

### 9.2 Client

| Change | Where | Stage |
|---|---|---|
| `RecycleManager`, value tables, RPC call, result aggregation | New class | 1 |
| Recycle action in the bulk-select action list | `InventoryManager` | 1 |
| Rename Sell to List on Exchange, retire Discard | `InventoryManager` | 1 |
| Essence balance chip in the inventory header | `InventoryUI` | 1 |
| Reclamation category | `RoyalMerchantUI` | 2 |
| Reclamation Charge toggle on the upgrade confirm | `AssemblyManager` | 2 |
| Talent XP award and daily cap check | `RecycleManager` | 3 |
| Auto-recycle hook on item acquisition | `InventoryManager` | 4 |
| Auto-recycle rows | `SettingsManager` UI | 4 |
| Auto-recycle summary line | While You Were Away | 4 |

### 9.3 New baked templates

Only two are genuinely new. Everything else reuses an existing template.

**1. `RecycleConfirmModal`**
```
Title            (Text)   "Recycle 47 items?"
Subtitle         (Text)   "Crude to Refined"
EssenceRow       (Transform)
  Icon           (Image)
  Right          (Text)   "+312 Essence"
XPRow            (GameObject)   toggled when any item is crafted
  Right          (Text)   "+1,840 Tanning XP"
WarningRow       (GameObject)   toggled when the selection includes Pristine
  Title          (Text)   "This includes 2 Pristine items."
ConfirmButton    (Button)
CancelButton     (Button)
```

**2. `EssenceBalanceChip`**
```
Icon             (Image)
Right            (Text)   "1,240"
```

**Reused, no baker work:** the bulk-select action list row, the Royal Merchant store row
template for the Reclamation category, the settings toggle and chooser rows, and the
While You Were Away result row.

### 9.4 Art

One 64x64 Reclaimed Essence icon. Suggested read: a small cluster of ground-down
material fragments with a faint warm glow, in the amber and dark teal item palette, so it
sits beside the Marks icons without being mistaken for currency.

---

## 10. Acceptance Criteria

- Recycling is available from account level 1 with no talent or Exchange gate.
- Recycling awards Reclaimed Essence per the section 3.3 table.
- Crafted items additionally award Talent XP to their source talent, capped at 15 percent
  of that talent's XP to next level per day.
- Gathered raw materials award Essence only, never XP.
- Recycling returns no materials of any kind, ever.
- Reclaimed Essence cannot be listed, banked, gifted, or converted to SM or GM.
- No item purchasable with Essence raises a stat, alters a drop rate, or is tradable.
- `isProtected`, locked, and equipped items are excluded from every recycle path.
- Legendary items cannot be recycled by any path.
- Masterwork items are excluded from bulk and auto, and require a per-item confirm.
- Auto-recycle offers Crude, Rough, and Refined only and is off by default.
- The confirm modal shows Essence and XP totals before the action commits.
- Auto-recycle activity is reported on the While You Were Away screen.
- The Essence award is computed server-side in the RPC, never trusted from the client.
- The inventory action list reads List on Exchange, not Sell.

---

*Path: docs/material-recycling-spec.md*
*Output is Reclaimed Essence, a bound token, plus Talent XP for crafted items only.*
*Zero material return and zero currency conversion by design. Four stages, two new baked*
*templates, one new player column plus three settings columns.*
