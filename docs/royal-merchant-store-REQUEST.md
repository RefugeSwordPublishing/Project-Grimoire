# Royal Merchant Store, REQUEST for Chat

**Status:** design ask. Reconcile two existing specs plus the as-built storefront into ONE categorized
store design, then Code builds the full page. Deliver as `royal-merchant-store-spec.md`.

---

## Why this needs a reconcile (not just a build)

"Royal Merchant" currently means two different things, and the player-facing vision is a third:

1. **`monetization-scope.md` (v0.3)** defines the Royal Merchant as the **premium IAP vendor**: tradeable
   convenience tickets (inventory/quest/Slaying-task/exchange/guild slots), account-bound cosmetics
   (skins, portrait frames, name badges, guild cosmetics), Grimoires, and DLC packs. Payment is Unity
   IAP + RevenueCat, prices shown in real money and GM side by side. **Location: a tab inside the
   Wayfarer's Exchange, "not a separate screen."** No direct GM purchase.

2. **As-built (`RoyalMerchantUI`, `consumables-spec.md`):** a **Gold-Mark auto-eat upgrade store** (idle
   auto-eat tiers T1-T4). Bought with GM only. Currently a top-level **nav entry**, not an Exchange tab.
   The auto-eat tiers are NOT in `monetization-scope.md` at all.

3. **Player-facing vision (Dustin):** tapping "Royal Merchant" opens a **full store page with category
   sections, Consumables, Inventory, Cosmetics, etc.** A unified store, GM sinks and IAP together.

So the reconcile has to settle: is the Royal Merchant one unified categorized store page (Dustin's
vision), and if so how does that square with `monetization-scope.md` putting it inside the Exchange and
scoping it to IAP-only? And where do the GM auto-eat tiers live in that structure?

---

## Questions to resolve

1. **Location.** One full store PAGE reached by tapping "Royal Merchant" (nav entry, as built), or a tab
   inside the Wayfarer's Exchange (as `monetization-scope.md` says)? If a page, does the Exchange still
   deep-link to it?
2. **Category list + contents.** Propose the store's category tabs and what sits in each. Candidate set:
   - **Consumables** (the GM auto-eat tiers; any other GM consumable upgrades, e.g. auto-drink mana)
   - **Inventory** (inventory-slot tickets, exchange listing slots, guild bank slots)
   - **Quests & Tasks** (daily/weekly quest-slot tickets, Slaying task-slot tickets 6/7/8)
   - **Cosmetics** (Grimoire skins, portrait frames, name badges, guild banner/emblem)
   - **Grimoires & DLC** (extra base Grimoires, DLC packs)
3. **Currency split per item.** Which items are **GM-only sinks** (like the auto-eat tiers), which are
   **IAP** (real money), and which are **both / tradeable tickets** (the `monetization-scope.md` model
   where tickets are bought with real money OR GM on the Exchange)? A per-category rule is fine.
4. **Auto-eat tiers placement.** Confirm the as-built auto-eat tiers become the "Consumables" category of
   the unified store (keeps the GM sink, just re-homed), and whether their tier model changes.
5. **IAP build boundary.** For this pass, which categories are **live** (GM purchases we can wire now,
   like Consumables) vs **stubbed** ("available with in-app purchases") until Unity IAP + RevenueCat is
   integrated? Per CLAUDE.md we do NOT hand-build receipt validation.
6. **Cross-surface links.** The Slaying task-slot tickets also relate to the Slaying page, and the
   Slaying Hunt Trophies / boss "accessories" assume an accessory slot that does not exist yet. Flag
   whether the store spec should assume an accessory slot is coming (a separate task) or avoid it.

---

## What Code will do once the spec lands

Rebuild `RoyalMerchantUI` as the full categorized store page (category tabs + a scrollable item list per
category, current-owned state, GM purchase for live categories, stubbed rows for IAP-pending ones),
opened from the Royal Merchant nav entry (or Exchange tab, per the location decision). The existing
auto-eat GM purchase logic + `SettingsManager.SetAutoEatTier` is reused for the Consumables category.

Deliver as `royal-merchant-store-spec.md`.
