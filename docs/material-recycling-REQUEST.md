---
type: design-request
for: Chat (claude.ai design collaborator)
from: Claude Code
date: 2026-08-29
subject: Design a way to "recycle" surplus materials and goods in an idle crafter, so throwaway items have a rewarding sink that does not just faucet the merchant currency
read-first: docs/implementation-status.md, then wayferers-exchange-and-grimoire-system.md, material-economy.md, royal-merchant-store-spec.md
---

# Request: material / goods recycling

## The problem (from the developer)

This is an idle crafter, so players generate a large volume of gathered and crafted items, and a lot of
it is throwaway. There is not always a way to move it:
- The Exchange needs a buyer, and nobody buys low-value junk.
- The guild bank is for things worth donating, not trash.
- Discarding deletes it for nothing.

"Sell to an NPC market for low value" is the obvious answer, but it does not feel right here, because the
Royal Merchant spends in-game currency (Silver Marks / Gold Marks). Minting SM from trash competes with,
and cheapens, the currency the merchant consumes. We want a recycling loop that gives the player
*something* for surplus goods without turning junk into a currency printer.

## Where we are (as-built, so design against this)

- **There is no NPC vendor.** The inventory "Sell" action actually opens an **Exchange** create-listing
  (`Market.OpenCreateListing`, player-to-player market, needs a buyer, 3% system-tax sink solo / guild tax
  in a guild). "Discard" (`InventoryManager.DiscardSlot`) just deletes the stack for nothing. So today the
  only outlet for genuinely unsellable items is deletion with zero reward. That is the gap.
- **Items carry `baseSellValue`** (a reference value, roughly `20 + quality*30` for assembly materials,
  higher for gear) but nothing pays it out. `isProtected` items (currency, Grimoires, quest items) cannot
  be discarded or sold and must be excluded from recycling too.
- **Quality** ladder is `Crude, Rough, Refined, Pristine, Masterwork, Legendary`; **tier** is the
  level-gated material ladder. Both are available to scale recycle output. Items also have a talent/source
  (Delving, Tanning, Cookery, Assembly, and so on).
- **Currencies:** Silver Marks (SM, the common currency) and Gold Marks (GM, premium). The **Royal
  Merchant** spends both (royal-merchant-store-spec.md). This is the currency the developer does not want a
  junk faucet to undermine.
- **Existing sinks/faucets:** Exchange system tax (SM sink), guild tax (to guild bank), crafting consumes
  materials, Royal Merchant consumes SM/GM. Recycling should slot in as the "no buyer, still worth doing
  something with it" fallback, not as a fourth way to print SM.

## What to design

### 1. What recycling OUTPUTS
This is the core decision, and the developer's constraint rules out "just pay SM." Weigh the options and
recommend one (or a small combination):
- **Salvage into base materials / a "scrap" resource** that feeds back into crafting (a material loop, not
  a currency loop). E.g. recycling refined goods yields a fraction of their inputs, or a generic Scrap
  used by a specific recipe or upgrade.
- **A dedicated recycling resource / token** with its own bespoke sink (a Royal Merchant "salvage" row, a
  cosmetic, an upgrade material) so it never touches SM/GM supply.
- **Talent XP** returned to the item's source talent (recycling a crafted item refunds a slice of the XP
  it represents). Fits the idle-crafter fantasy, and XP is not a tradable resource so it cannot inflate
  the economy.
- **A tightly capped, discounted SM trickle** as a last resort, if a currency reward is unavoidable, with
  the caps that keep it from being a farm.
Say which, and why it is the right sink for an idle crafter specifically.

### 2. Where it lives and how it feels (idle-friendly)
- A recycler as an inventory bulk action, a hub station, a talent, or the Royal Merchant. Recommend one.
- **Bulk and low-friction** is essential for an idle game drowning in items: recycle-all, recycle-all-of-a
  category, recycle-everything-below-quality-X, and ideally an **auto-recycle** setting (auto-scrap
  anything below a chosen quality/tier as it is produced or gathered). Design the controls.
- Guardrails against mistakes: never touch `isProtected` or locked items, confirm on anything above a
  quality threshold, and respect the existing item-lock flag.

### 3. The value curve
- How output scales by `baseSellValue`, quality, and tier, and how it compares to the (unreliable) Exchange
  price so recycling is the worse-but-guaranteed option, not the best one. It should be the floor, not the
  ceiling, or players will recycle instead of trading and the Exchange dies.
- Whether higher-quality items are worth recycling at all, or whether recycling is deliberately a
  low-quality-only tool (Masterwork/Legendary should probably never be scrapped by a bulk button).

### 4. Economy safety
- Confirm the loop cannot be gamed: gather -> craft -> recycle should never net more than gather -> craft
  in inputs or value (no perpetual-motion material printer), and recycling must not become a faster SM
  source than intended play.
- How it interacts with the Exchange (the floor, above) and whether recycled output should ever be
  tradable (recommend: no, keep scrap/essence bound so it cannot re-enter the market as laundered value).

## Constraints

- **Do not make recycling a raw SM/GM faucet** that undermines the Royal Merchant economy. That is the
  whole reason NPC-sell was rejected.
- Reuse existing plumbing where possible: `baseSellValue`, the quality/tier fields, `isProtected`, the
  item-lock flag, the inventory bulk-select UI (it already has bulk sell / discard / lock / guild-bank),
  and the SettingsManager for an auto-recycle toggle.
- **Baked/skinnable UI** if a new panel or station is introduced (editor-authored templates, populate-only
  runtime). **Mobile portrait.**
- Writing style: no em dashes, en dashes, or "--" as prose punctuation; no emojis (this becomes UI copy and
  code comments).

## Deliverable

A spec I can implement in stages, with:
- The recycle output (what you get) and why it fits an idle crafter without inflating SM/GM.
- Where it lives, the bulk + auto-recycle controls, and the safety guardrails.
- The value curve (formula by baseSellValue/quality/tier) and how it sits below the Exchange as a floor.
- The economy-safety argument (no material or currency perpetual motion; recycled output tradable or not).
- A **build checklist**: any new item/resource, any new baked UI template, the inventory-action wiring, the
  SettingsManager toggle, and any server/table change (e.g. a scrap resource or a per-player auto-recycle
  setting).

Point out anything about the current item economy you think is wrong beyond this (for example that there is
no NPC vendor at all, so "Sell" being an Exchange listing may confuse players who expect an instant sale).
