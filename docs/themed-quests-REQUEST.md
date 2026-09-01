# Themed Quests + Delivery/Bounty Model, Design Request
### 0.1.4 quest overhaul. Requesting Chat's spec.

---

We are reworking the daily/weekly quest system so it reads as flavored NPC bounties instead of a raw
XP grind, and so it ties into the new Traveling Merchant economy. The quest **engine already supports
almost all of this**; the work is (a) a content rewrite of the pool and (b) two small engine additions
(accept-to-pin + delivery turn-in). We need Chat to design the content and arbitrate the open calls.

Read `implementation-status.md` first, then `daily-weekly-quest-system.md` (the current quest spec) and
`traveling-merchant-spec.md` (the economy this now feeds). This request assumes the merchant pivot that
already shipped: **SM is the core earned currency, GM is premium/IAP.**

## As-built facts (not visible in code to Chat)

The engine is richer than the current content uses. `QuestDefinition` (ScriptableObject) already has:

- Free-text `displayTitle` + `displayDescription` (so flavor is a content change, not an engine change).
- Objective types beyond XP: `GatherItem`, `ProcessItem`, `CraftItem`, `DefeatEnemies`, `DefeatElites`,
  `DefeatBoss`, `CompleteDungeon`, `EarnTalentXP`, `ReachZone`, `SellOnExchange`.
- Rewards of type `TalentXP`, `CombatXP`, `Item`, `SilverMarks`, `GoldMarks`, each with an amount.
- A guaranteed `rewards[]` array plus one chance-based `bonusReward` + `bonusChance`.
- Pool weighting: `weight`, `minZoneTier`, `maxZoneTier` (a T1 player never draws a T3 quest).

Current pool (30 quests, in `CreateQuests.cs`) and its problems:
- Objectives are often literally "Earn 1,500 Felling XP" / "Earn 8,000 Talent XP" (reads as a grind).
- Rewards are circular: nearly every quest pays `TalentXP`/`CombatXP`, so you grind XP and get XP back.
- **Zero quests reward SM**, even though SM is now the core earned currency.
- Quests spray `GoldMarks` (8-20 GM on dailies), which undercuts GM as premium.
- `GatherItem` currently counts items acquired **after** assignment and does **not** consume them
  (pure faucet, no sink). Progress today starts the moment a quest is assigned; there is no accept step.

## Decisions already made (design within these)

- **Bonus XP stays**, but only as a small side-reward. The lead reward is **SM + a themed item**.
- **GM only on weekly capstones**, never on routine dailies.
- **Themed flavor throughout.** Each quest has a named giver and a story framing. "Earn 1,500 Felling XP"
  becomes something like "Bramblewick the millwright needs 1,500 pine logs to meet his quota." Givers are
  lightweight: a `giverName` + flavor line on the existing quest card. No new hub surface, no portraits.
- **Themed bonus items mirror the activity.** A logs quest can bonus a few Raw Amber (the rare woodcutting
  byproduct), so it reads as "the rare find from a big haul." Balance leash: the bonus is a taste, never a
  farm. It must never become the optimal source of that rare mat, or players grind the quest for it.
- **Accept-to-pin (bounty model).** Quests appear on a notice board that refreshes daily. The player must
  **accept** a quest to pin it to their active list. This is the daily-login hook: hop on, see the day's
  board, choose what to take.
- **Delivery turn-in from inventory balance** for gather/process/craft objectives. Turning in checks the
  player's **current** stock, **consumes** the requested items, and grants the reward. This makes the quest
  a material **sink** and is functionally "the Traveling Merchant with a themed bonus offer." Because it
  reads the current balance, **offline idle gathering still counts** (the player just cannot turn in until
  they have accepted and hold enough), so accept-gating does not waste idle progress.
- Objectives that cannot be filled from stock (kills, dungeon clears, zone entry, exchange sales) stay
  **event-tracked after accept**: progress accrues from the accept moment, no consume.

## Design asks (spec these)

1. **Fulfillment split.** For each objective type, state whether it is **Delivery** (consumes stock at
   turn-in) or **Track** (event-counted after accept). Gather/Process/Craft are Delivery candidates; the
   combat/dungeon/zone/exchange types are Track. Confirm and note any edge cases.
2. **Giver roster + voice.** A cast of recurring NPC givers (name, trade, one-line personality) and the
   flavor voice for titles + descriptions. House style applies (see constraints).
3. **The reworked pool** (aim ~15 daily + ~10 weekly, same banding by zone tier). For each quest give:
   `questId`, cadence, objective type + target + count, giver, title, description, the fulfillment mode,
   the guaranteed rewards (SM amount + optional themed item + small bonus XP), and the chance-based
   `bonusReward` + `bonusChance`. Lead rewards with SM; GM only on weekly capstones.
4. **Reward tables + sizing.** Concrete SM payouts scaled by tier/effort, and bonus-item counts that honor
   the "taste not farm" rule. Give the reasoning so we can tune, not just numbers.
5. **Notice-board + accept UX.** The board layout (browse the day's offers), the accept action, the active
   /pinned list, the turn-in action for Delivery quests (where the player confirms handing over the mats),
   and how a not-yet-fillable Delivery quest reads ("have 900 / need 1,500"). All baked/skinnable, named
   regions.
6. **Guardrails.** Daily accept cap (how many of the day's board can be taken?), refresh timing, what
   happens to an accepted-but-unfinished quest at daily rollover, and whether Delivery quests need any
   anti-hoarding guard beyond small bonuses.

## Engine additions we will build from your spec (for context)

- `QuestDefinition`: add `giverName` (string) and a `fulfillment` enum (`Delivery` | `Track`).
- Accept-to-pin: quests are offered, not auto-assigned; an accept flips them active.
- Delivery turn-in: a client-authoritative turn-in (verify balance, deduct via `replace_inventory` RPC,
  grant reward), same rails as the Traveling Merchant sell.

## Constraints

- UI is authored/skinned in Unity (baked templates, populate-only runtime), so give concrete layouts with
  named regions.
- Mobile-first portrait.
- House style: no em/en dashes, no emojis, direct phrasing, no XP-for-XP reward loops.

**Deliver:** the giver roster, the fulfillment split, the full reworked daily+weekly pool with rewards,
the SM/bonus sizing logic, and the notice-board + accept + turn-in UX layouts.

---

*Path: docs/themed-quests-REQUEST.md*
