# ⚔️ Project Grimoire — The Wayfarer's Exchange & Grimoire Binding System
### Version 0.1

---

## 🏛️ The Wayfarer's Exchange

> The Wayfarer's Exchange is the central economic hub of Project Grimoire — a single unified marketplace encompassing player-to-player trade, system item sales, and creature listings. Accessible as a menu option from anywhere in the game. Named for the traveling merchants and wanderers who bring goods from across the world to a single meeting point.

---

### Access Requirements
- **Minimum:** Any single Talent at level 10
- **No guild requirement** — solo players have full access
- **Guild perks** (Phase 4): Reduced listing fees, bulk listing slots, buy order priority queue

---

### Currency — Silver & Gold Marks

The single unified currency used across all transactions in the game — market listings, system purchases, NPC rewards, and any other economy interaction.

| Denomination | Shorthand | Role |
|-------------|-----------|------|
| **Silver Mark** | SM | Day-to-day transactions — consumables, common materials, low-tier gear |
| **Gold Mark** | GM | Mid-to-high tier items, rare materials, Assembly components, Grimoire purchases |

**Conversion:** 1,000 Silver Marks = 1 Gold Mark

**Price Range by Rarity:**
| Item Tier | Typical Price Range |
|-----------|-------------------|
| Common | 10 – 500 SM |
| Uncommon | 500 SM – 5,000 SM |
| Rare | 5,000 SM – 50,000 SM (5–50 GM) |
| Epic | 50,000 SM – 500,000 SM (50–500 GM) |
| Legendary | 500,000 SM – 5,000,000 SM (500–5,000 GM) |

**Currency Sources:**
- Slaying enemies (direct drops)
- Selling items at The Wayfarer's Exchange
- Completing Faction quests and NPC contracts
- Gleaning (Old Coin drops convert to Marks)
- Daily Skirmish rewards (Phase 4)

**Gold Sinks:**
- Wayfarer's Exchange listing fees
- Assembly rare material costs
- Grimoire purchases
- System store items purchasable with Marks
- Talent equipment upgrades (e.g., better Workbench tiers)

---

### Market Sections

The Wayfarer's Exchange has two distinct sections visible in the UI:

#### 1. 🧑‍🤝‍🧑 Player Market
All player-created listings — auctions, store listings, and buy orders. Fully player-driven pricing. Economy balanced by drop rates, crafting success/fail rates, and supply/demand from combat and Talent needs.

#### 2. 🏪 System Store
Items sold by the game itself. Purchasable with **Gold Marks** (earned in-game) OR **real money** via App Store/Google Play/Steam purchase. Nothing in the System Store is exclusively pay-walled — all items are obtainable with in-game currency at high Mark cost.

**System Store categories:**
- Cosmetic items (character appearance, Grimoire skins, quiver skins)
- Grimoire unlocks (see Grimoire Binding System below)
- Convenience items (extra listing slots, idle queue expansion)
- Boosts (temporary XP or drop rate boosts — purchasable with Marks or real money)

---

## 📋 Listing Types

### 🔨 Auction Listings
Player lists an item for competitive bidding.

**Flow:**
1. Select item from inventory
2. Choose **Auction** listing type
3. Set **Starting Bid** (minimum first bid accepted)
4. Set **Buyout Price** (optional — allows instant purchase at set price)
5. Set **Duration:** 1 day / 7 days / 15 days
6. Pay listing fee (% of starting bid — see Fees section)
7. Listing goes live

**Rules:**
- Auction is **all or nothing** — full quantity listed must be purchased by winning bidder
- If no bids are placed, item is returned to seller (listing fee not refunded)
- If buyout price is set and met, auction closes immediately
- Outbid players have their Marks returned instantly
- No minimum bid floor — market finds its own price; "steals" are intentional and create engagement
- Timezone/inactivity risk mitigated by 1-day minimum option and buyout price availability

---

### 🏷️ Store Listings
Player lists items at a fixed price for immediate purchase.

**Flow:**
1. Select item from inventory
2. Choose **Store Listing** type
3. Set quantity
4. Set price per unit
5. Pay listing fee
6. Listing goes live indefinitely until sold or manually removed

**Rules:**
- Buyers can purchase **any quantity** up to the listed amount — partial fills allowed
- Listing remains active until fully sold or seller cancels
- Seller can update price on active listing (fee already paid, no additional charge)
- When selecting an item to list, seller sees **existing Buy Orders** for that item — can choose to fulfill a Buy Order instead of creating a listing

---

### 📥 Buy Orders
Players front Gold/Silver Marks to signal they want to purchase a specific item at a set price.

**Flow:**
1. Navigate to item (search or browse)
2. Select **Place Buy Order**
3. Set quantity wanted
4. Set price per unit willing to pay
5. Marks are **held in escrow** immediately (deducted from wallet)
6. Buy Order goes live

**Rules:**
- Partially fillable — sellers can fulfill any portion of the quantity
- Marks held in escrow are released to seller as portions are filled
- If a Buy Order is cancelled, held Marks are returned to buyer
- When a seller creates a Store Listing and selects an item, they see active Buy Orders sorted by highest price — one tap to fulfill instead of listing
- Multiple Buy Orders on the same item are filled in price-descending order (highest bidder gets filled first)
- Buy Orders have no expiry unless cancelled by the buyer

**Example:**
> Player A places a Buy Order: 500x Iron Bar @ 12 SM each (6,000 SM held in escrow)
> Player B goes to list Iron Bars, sees the Buy Order, taps to fulfill 200x
> Player B receives 2,400 SM instantly. Buy Order now shows 300x remaining.

---

## 💰 Listing Fees

All player listings charge a **percentage-based fee** paid upfront. No flat fees — scaling with item value keeps the fee meaningful at all price points.

| Listing Type | Fee | Paid When | Refundable? |
|-------------|-----|-----------|-------------|
| Auction | 3% of starting bid | At listing creation | No |
| Store Listing | 2% of total listing value | At listing creation | No |
| Buy Order | No listing fee | — | Marks held in escrow, returned on cancel |

**Fee destination:** Marks paid in listing fees are removed from circulation entirely (gold sink — not redistributed to any player or system).

**Guild perk (Phase 4):** Guild members receive 0.5% discount on all listing fees.

**CHA stat bonus:** High Charisma reduces listing fees by up to 1% at max CHA. Encourages CHA investment for dedicated traders.

---

## 🔍 Market UI Features

- **Search** by item name, type, Talent category, or rarity tier
- **Sort** by price (low/high), time remaining, quantity, rarity
- **Filter** by listing type (Auction / Store / Buy Orders)
- **Item page** shows:
  - Active Store Listings (sorted lowest price first)
  - Active Auctions (sorted by time remaining)
  - Active Buy Orders (sorted highest price first)
  - Recent sale history (last 10 sales with price and date) — helps players price accurately
- **My Listings** tab — manage all active listings, cancel, or relist
- **My Buy Orders** tab — manage active orders, cancel, adjust quantity
- **Watchlist** — bookmark items to monitor price trends

---

## ⚖️ Economy Balance Levers

The Wayfarer's Exchange economy is self-regulating through:

| Lever | Effect |
|-------|--------|
| **Crafting success/fail rates** | Failed Assemblies consume rare materials, reducing supply |
| **Combat drop rates** | Tuned per item to control market flood risk |
| **Listing fees** | Gold sink that removes Marks from circulation |
| **Gleaning RNG** | Rare Assembly materials from Gleaning have low drop rates by design |
| **Talent level gates** | High-tier items require high-level Talents to produce — limits supply naturally |
| **Time-gated growth cycles** | Cultivation output is time-gated — prevents farming floods |
| **Grimoire costs** | High Mark cost for Grimoire purchases acts as major gold sink |

No artificial price floors or ceilings — the market finds its own equilibrium. Developer tuning levers are drop rates and crafting rates, not price controls.

---

## 📖 The Grimoire Binding System

> Your character's class, path, and subclass are determined entirely by which **Grimoire** you have equipped. Swap the Grimoire, swap the identity. No new character creation needed — one character can experience all paths.

---

### How It Works

Each player has:
- **1 Grimoire slot** (determines Path + Subclass)
- **1 Relic slot** (cosmetic or minor passive bonus tied to the Grimoire)
- A **Grimoire Collection** in their inventory — all Grimoires they own

Swapping Grimoires is instantaneous outside of combat. Stats, Talent levels, and inventory persist across all Grimoires — only the active combat style, subclass Techniques, and subclass-exclusive Talent branches change.

**Example:**
> A player owns the Warden's Grimoire (Sharpshot) and the Arcanist's Grimoire (Runeweaver).
> In the morning they idle Foraging with the Arcanist Grimoire equipped (better reagent quality baseline).
> In the evening they equip the Warden Grimoire for active Bowstring combat.
> All Talent XP and inventory is shared.

---

### Grimoire Structure

Grimoires are organized by **Archetype** (the three class paths) as categories. Each subclass has its own Grimoire.

#### 🏹 Warden Grimoires
| Grimoire | Unlock | Cost |
|----------|--------|------|
| **Grimoire of the Sharpshot** | Free — given at game start if Warden path chosen | — |
| **Grimoire of the Beastbond** | Purchase | 500 GM or premium |
| **Grimoire of the Lone Wanderer** | Purchase | 500 GM or premium |

#### 🔮 Arcanist Grimoires *(Phase 2)*
| Grimoire | Unlock | Cost |
|----------|--------|------|
| **Grimoire of the Runeweaver** | Free — given at game start if Arcanist path chosen | — |
| **Grimoire of the Warlock** | Purchase | 500 GM or premium |
| **Grimoire of the Summoner** | Purchase | 500 GM or premium |
| **Grimoire of the Lifebinder** | Purchase *(multiplayer unlock)* | 750 GM or premium |

#### ⚔️ Vanguard Grimoires *(Phase 2)*
| Grimoire | Unlock | Cost |
|----------|--------|------|
| **Grimoire of the Warlord** | Free — given at game start if Vanguard path chosen | — |
| **Grimoire of the Shadowblade** | Purchase | 500 GM or premium |
| **Grimoire of the Kensei** | Purchase | 500 GM or premium |

**Notes:**
- Players choose one free Grimoire at game start (their starting path)
- All other Grimoires are purchasable with Gold Marks or real money via System Store
- No Grimoire is exclusively pay-walled — all are obtainable with in-game Marks
- 500 GM = 500,000 SM — a significant grind, making real money purchase a genuine convenience option without being required
- Grimoires are **account-bound** — cannot be traded on the Wayfarer's Exchange

---

### Grimoire Cosmetics
Each Grimoire has a visual appearance reflected on the character:
- Cover design and color on the equipped book/tome
- Idle animation flavor (Warden flips through field notes; Arcanist traces runes on pages; Vanguard slams tome shut)
- **Grimoire Skins** available in System Store — purely cosmetic, no stat effect

---

## 🔗 Cross-System Notes

- **CHA stat** affects listing fees and buy/sell margins in the Wayfarer's Exchange — making CHA investment valuable for dedicated trader builds
- **Inscription** (Talent) produces Diplomatic Charters that grant Faction Reputation — Faction standing eventually unlocks System Store discounts (Phase 3)
- **Beastmastery** level 75 unlocks creature listings in the Wayfarer's Exchange — players can sell tamed familiars
- **Grimoire of the Shadowblade** grants access to a hidden **Black Ledger** section within the Exchange — rare untraceable goods from hostile zone Gleaning listed here at premium prices (no listing fee, but items can be seized by Faction NPCs if Faction standing is low)

---

*Document version 0.1 — Wayfarer's Exchange & Grimoire Binding System*
*Next: Assembly material tables · Enemy zone tables · Faction Reputation design pass · Subclass deep tree specs*
