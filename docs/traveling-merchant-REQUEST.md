# Traveling Merchant + Gold-to-Silver Conversion, Design Request
### 0.1.4 economy pivot. Requesting Chat's spec.

---

We are pivoting away from the recycle-to-Reclaimed-Essence system. It shipped in 0.1.3c but its UI was
never baked, so no tester saw it. Treat it as unbuilt and free to replace. Two connected features
replace it: a **Traveling Merchant** that buys scrap for Silver, and a **Gold-to-Silver** conversion.

Read `implementation-status.md` first, then `material-recycling-spec.md` (what we're retiring),
`wayferers-exchange-and-grimoire-system.md` (player market), `royal-merchant-store-spec.md`, and
`daily-weekly-quest-system.md` (currency income: GM ~8-12/day, SM ~50-150/day).

## As-built facts (not visible in code to Chat)

- Three currencies today: **Silver Marks** (SM, primary/common), **Gold Marks** (GM, premium, headed for
  IAP), **Reclaimed Essence** (bound token, `player_currency.reclaimed_essence`), which we are RETIRING.
- `ItemData.baseSellValue` exists on every item but is unused ("dead field"); gear sets it to
  `80 + (tier-1)*120`, most materials/consumables leave it 0.
- Recycle system to retire: `RecycleManager` (quality x tier essence value table), bulk-select recycle
  plus a per-item Recycle action, IdleManager auto-recycle, and a Royal Merchant "Reclamation" tab with
  4 Essence purchases (Inventory Slots +5, Salvager's Satchel +15% essence, Bulk Reclaim Filter,
  Auto-Recycle).
- The Exchange is the player-to-player market (SM listings + `exchange_sale_history`). No NPC-priced
  buyback exists yet.

## Decisions already made (design within these)

- **Traveling Merchant** buys junk/scrap for **SM** at a **low fixed floor price**, well below player-market
  value, so the Exchange stays the venue for anything worth listing. The floor seeds the economy;
  availability drives the real price above it.
- **GM is premium (IAP-bound).** Allow **GM to SM only**, never SM to GM (prevents grinding premium
  currency). GM to SM is a "make change" flow at checkout: if a SM cost exceeds the player's SM, prompt to
  spend 1+ GM (rate ~1 GM = 100 SM), show the math, complete the purchase, and return the SM remainder.
  Always an explicit confirm.
- **Retire Reclaimed Essence.** Migrate the Reclamation shop: re-price Inventory Slots / Bulk Filter in
  SM/GM; turn Auto-Recycle into **Auto-Sell to the Traveling Merchant**; turn Salvager's Satchel into a
  merchant-buyback perk or cut it.

## Design asks (spec these)

1. **Traveling Merchant**: what it buys (all non-protected/locked? exclude quest items, Grimoires,
   currency? include gear + materials + consumables?), the **pricing formula** (use `baseSellValue` where
   set, else derive from quality x tier, give a concrete table), the presence model (always-available vs a
   rotating stock/visit that adds flavour), and the sell UI (single-item from the item popup + a bulk-sell
   flow, both baked/skinnable).
2. **GM to SM converter**: the checkout prompt + math display, the change-return, the rate, and whether
   there is also a standalone manual converter or only the at-checkout path.
3. **Economy guardrails**: how the floor stays below Exchange prices, inflation control, and whether the
   buyback should have any daily cap or spread.
4. **Reclamation migration**: exact fate of each of the 4 items and where they live now.

## Constraints

- UI is authored/skinned in Unity (baked templates, populate-only runtime), so give concrete layouts with
  named regions.
- Mobile-first portrait.
- House style: no em/en dashes, no emojis, direct phrasing.

**Deliver:** the merchant pricing model + buy rules, the sell UI layouts, the GM to SM flow, and the
Reclamation-shop migration table.

---

*Path: docs/traveling-merchant-REQUEST.md*
