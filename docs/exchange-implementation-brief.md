---
type: implementation-brief
spec: wayferers-exchange-and-grimoire-system.md, monetization-scope.md
updated: 2026-07-11
purpose: Wire the Wayfarer's Exchange using the existing ItemListingComposer
         infrastructure. Covers all three listing types, fee calculation,
         search/browse UI, and Royal Merchant tab.
---

# Wayfarer's Exchange — Implementation Brief

## What's Already Built (reuse these)

- `ItemListingComposer.cs` — searchable item picker, quantity, dual SM/GM price,
  optional note. Currently backs Guild Merchant + material requests.
  Reuse directly for all Exchange listing types.
- `buy_guild_listing` RPC pattern — atomic buy flow (charge buyer, pay seller
  minus fee, credit sink/bank, delete listing). Mirror this for Exchange.
- Inventory system, currency (SM/GM), item quality, ItemRegistry
- Exchange lock gate — unlocks when any Talent hits level 10 (already built)
- Auth, RLS on all tables

---

## Exchange Overview — Three Listing Types

| Type | Who posts | Price model | Fee | Partial fills |
|------|----------|-------------|-----|--------------|
| **Store Listing** | Seller | Fixed price per unit | System/guild tax on sale | Yes — buyer picks quantity |
| **Auction** | Seller | Starting bid + optional buyout | System/guild tax on sale | No — all or nothing |
| **Buy Order** | Buyer | Fixed offer per unit | 0% always | Yes — any seller fills any portion |

---

## Fee Calculation — apply to every sale

```csharp
float CalculateFee(float saleTotal, string sellerPlayerId) {
    bool isGuildMember = GuildManager.IsInGuild(sellerPlayerId);

    if (!isGuildMember) {
        // Solo player — 3% system tax, goes to economy sink (just deducted, not stored)
        return saleTotal * 0.03f;
    }

    // Guild member — guild tax rate replaces system tax
    float guildTaxRate = GuildManager.GetTaxRate(sellerPlayerId); // 0.0–0.03
    float fee = saleTotal * guildTaxRate;

    // Credit fee to guild bank
    GuildManager.CreditGuildBank(sellerPlayerId, fee);
    return fee;
}

// Seller receives: saleTotal - fee
// Buy Orders: fee = 0 always, no guild credit
```

---

## Supabase Schema

```sql
-- Store listings
CREATE TABLE exchange_store_listings (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    seller_id       UUID REFERENCES players(id),
    item_id         TEXT NOT NULL,
    quality         TEXT NOT NULL,
    quantity        INTEGER NOT NULL,
    price_sm        INTEGER NOT NULL DEFAULT 0,
    price_gm        INTEGER NOT NULL DEFAULT 0,
    note            TEXT,
    listed_at       TIMESTAMPTZ DEFAULT NOW(),
    expires_at      TIMESTAMPTZ DEFAULT NOW() + INTERVAL '30 days'
);

-- Auctions
CREATE TABLE exchange_auctions (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    seller_id       UUID REFERENCES players(id),
    item_id         TEXT NOT NULL,
    quality         TEXT NOT NULL,
    quantity        INTEGER NOT NULL,
    start_bid_sm    INTEGER NOT NULL DEFAULT 0,
    start_bid_gm    INTEGER NOT NULL DEFAULT 0,
    buyout_sm       INTEGER DEFAULT 0,
    buyout_gm       INTEGER DEFAULT 0,
    current_bid_sm  INTEGER DEFAULT 0,
    current_bid_gm  INTEGER DEFAULT 0,
    current_bidder  UUID REFERENCES players(id),
    duration_days   INTEGER NOT NULL, -- 1, 7, or 15
    ends_at         TIMESTAMPTZ NOT NULL,
    listed_at       TIMESTAMPTZ DEFAULT NOW()
);

-- Buy orders
CREATE TABLE exchange_buy_orders (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    buyer_id        UUID REFERENCES players(id),
    item_id         TEXT NOT NULL,
    quality         TEXT NOT NULL,
    quantity_wanted INTEGER NOT NULL,
    quantity_filled INTEGER NOT NULL DEFAULT 0,
    offer_sm        INTEGER NOT NULL DEFAULT 0,
    offer_gm        INTEGER NOT NULL DEFAULT 0,
    escrow_sm       INTEGER NOT NULL DEFAULT 0, -- currency held in escrow
    escrow_gm       INTEGER NOT NULL DEFAULT 0,
    listed_at       TIMESTAMPTZ DEFAULT NOW(),
    expires_at      TIMESTAMPTZ DEFAULT NOW() + INTERVAL '30 days'
);

-- RLS: listings readable by all authenticated players
--      writes restricted to owner
```

---

## Flow 1 — Store Listing (Seller posts fixed-price item)

### Post flow
```
Seller opens Exchange → My Listings tab → [ + New Listing ]
         ↓
ItemListingComposer opens:
  Open("New Store Listing", "List Item",
       requireOwnership: true,
       showPrice: true,
       showNote: true,
       callback: OnStoreListingConfirmed)
         ↓
Seller picks item, quantity, price (SM and/or GM), optional note
Taps "List Item"
         ↓
OnStoreListingConfirmed(item, qty, priceSM, priceGM, note):
  - Deduct item from seller inventory (escrow)
  - INSERT into exchange_store_listings
  - Show "Listed!" confirmation
```

### Buy flow
```
Buyer browses Exchange → finds listing → taps Buy
         ↓
Quantity picker appears (1 → available qty)
Buyer confirms quantity and total cost
         ↓
buy_exchange_store_listing RPC (server-side atomic):
  - Verify listing still exists + qty available
  - Deduct buyer currency (SM + GM)
  - Calculate fee via CalculateFee()
  - Credit seller: total - fee
  - Credit guild bank if seller is guild member
  - Add item to buyer inventory
  - Reduce listing quantity (delete if qty reaches 0)
         ↓
Both seller and buyer get notification:
  Seller: "Your [Item] listing sold — [Amount] SM collected"
  Buyer: (no notification — they just bought it)
```

### Listing expiry
Store listings expire after 30 days. Scheduled Edge Function (pg_cron, daily):
```sql
-- sweep_expired_exchange_listings()
-- Returns escrowed items to seller inventory
-- Deletes expired listings
```

---

## Flow 2 — Auction (Seller posts bidding item)

### Post flow
```
Seller opens Exchange → My Listings → [ + New Auction ]
         ↓
ItemListingComposer opens with auction fields added:
  - Starting bid (SM/GM)
  - Buyout price (SM/GM) — optional
  - Duration: [ 1 day ] [ 7 days ] [ 15 days ]
         ↓
OnAuctionConfirmed():
  - Deduct item from seller inventory (escrow)
  - INSERT into exchange_auctions with ends_at = NOW() + duration
```

### Bid flow
```
Buyer finds auction → taps [ Bid ]
         ↓
Shows current bid, minimum next bid (current + 5% minimum increment)
Buyer enters bid amount — must be ≥ minimumNextBid
         ↓
place_auction_bid RPC (server-side atomic):
  - Verify bid >= current_bid * 1.05  (5% minimum increment)
  - If bid < minimum: reject with "Bid must be at least [minimumNextBid]"
  - Escrow buyer's bid currency
  - Return previous bidder's escrow to them immediately
  - Update current_bid + current_bidder on auction row
  - Fire outbid notification to previous bidder (P2 — immediate)
         ↓
Previous bidder notification (P2 — push even if backgrounded):
  "⚠ You've been outbid on [Item] — someone bid [amount]"
```

**Minimum bid increment:**
```csharp
// Server-side in place_auction_bid RPC:
int minimumNextBidSM = Mathf.CeilToInt(currentBidSM * 1.05f);
int minimumNextBidGM = Mathf.CeilToInt(currentBidGM * 1.05f);

if (newBidSM < minimumNextBidSM || newBidGM < minimumNextBidGM) {
    return error("Minimum bid is [minimumNextBid]");
}
```

Display minimum next bid prominently in the bid UI so players know
before submitting what the floor is. No guessing.

### Buyout flow
```
Buyer taps [ Buyout ] (only shown if buyout price set)
         ↓
buy_auction_buyout RPC:
  - Deduct buyout price from buyer
  - Return any existing bidder's escrow
  - Calculate fee on buyout total
  - Credit seller: buyout - fee
  - Add item to buyer inventory
  - Delete auction row
         ↓
Seller notification: "Your [Item] auction sold via buyout"
```

### Auction end (pg_cron, hourly)
```sql
-- close_ended_auctions() — runs hourly
-- For each auction where ends_at < NOW():
--   If current_bidder exists:
--     Calculate fee on winning bid
--     Credit seller: bid - fee
--     Add item to winner inventory
--     Notify winner (P3): "You won the auction for [Item]!"
--     Notify seller (P3): "Your auction sold — [amount] collected"
--   If no bidder:
--     Return item to seller inventory
--     Notify seller (P4): "Your [Item] auction ended with no bids"
--   Delete auction row

-- fire_ending_soon_notifications() — runs hourly
-- For each auction where ends_at BETWEEN NOW() AND NOW() + INTERVAL '1 hour'
-- AND ending_soon_notified = false:
--   Notify current_bidder (P3): "⏰ [Item] auction ending in ~1 hour"
--   Set ending_soon_notified = true on auction row
```

Add `ending_soon_notified BOOLEAN DEFAULT false` to `exchange_auctions` table
so the notification only fires once per auction.

---

## Flow 3 — Buy Order (Buyer posts demand)

### Post flow
```
Buyer opens Exchange → Buy Orders tab → [ + New Buy Order ]
         ↓
ItemListingComposer opens:
  Open("New Buy Order", "Post Order",
       requireOwnership: false,  // buyer posting demand, not item
       showPrice: true,
       showNote: true,
       callback: OnBuyOrderConfirmed)
         ↓
Buyer picks item type, quality, quantity wanted, offer price per unit
Taps "Post Order"
         ↓
OnBuyOrderConfirmed():
  - Calculate total escrow = quantity × offer price
  - Deduct escrow from buyer currency (held, not spent yet)
  - INSERT into exchange_buy_orders
```

### Fill flow (seller fulfills buy order)
```
Seller browses Buy Orders → finds order → taps [ Fill ]
         ↓
Quantity picker: how many can you supply? (up to order's remaining qty)
         ↓
fill_buy_order RPC (server-side atomic):
  - Verify order still open + qty remaining
  - Deduct items from seller inventory
  - Release escrow proportional to filled qty (no fee — Buy Orders always 0%)
  - Credit seller full offer price × filled qty
  - Add items to buyer inventory
  - Update quantity_filled on order (delete if fully filled)
         ↓
Buyer notification: "Your Buy Order for [Item] was filled — [qty] received"
Seller: (no notification — they just sold)
```

### Buy order expiry
Same 30-day expiry. Scheduled Edge Function returns unused escrow to buyer.

---

## Browse & Search UI

### Main Exchange screen — tabs

```
[ Browse ] [ My Listings ] [ Buy Orders ] [ Royal Merchant ]
```

**Browse tab:**
- Search bar (item name filter, live)
- Filter row: [ All ] [ Materials ] [ Equipment ] [ Consumables ] [ Grimoires ]
- Quality filter: [ All ] [ Crude ] [ Rough ] [ Refined ] [ Pristine ] [ Masterwork ]
- Sort: [ Price ↑ ] [ Price ↓ ] [ Newest ] [ Ending Soon ] (auctions)
- Results list: item icon, name, quality badge, quantity, price, seller name, Buy button
- Auctions shown with time remaining badge

**My Listings tab:**
- Active store listings + auctions posted by this player
- Cancel button on each (returns escrowed item)
- Active buy orders posted by this player
- Cancel button (returns escrowed currency)
- Expired listings with "Collect item" button (item held in limbo after expiry)

**Buy Orders tab:**
- All active buy orders from all players
- Filter by item type
- Sort by offer price
- Fill button on each

---

## Royal Merchant Tab

Premium items sold by the system (not player-to-player).
Uses same Exchange UI shell but different data source — static item catalog
rather than player listings.

```
[ Browse ] [ My Listings ] [ Buy Orders ] [ 👑 Royal Merchant ]
```

**Royal Merchant items:**
- Tradeable tickets (Inventory Slot, Quest Slot, Slaying Task Slot etc.)
  — purchased here with GM or real money, then tradeable on Exchange
- Grimoire unlocks (account-bound on purchase — not tradeable)
- Cosmetics (account-bound — not tradeable)

```csharp
// Royal Merchant is a static catalog — no Supabase listing table
// Items defined in RoyalMerchantCatalog ScriptableObject
// Purchases go through Unity IAP + RevenueCat for real-money items
// GM purchases deduct from PlayerData.GoldMarks directly
```

---

## Tradeable Tickets — Exchange Integration

Tickets purchased from Royal Merchant appear in inventory as normal items
with `isConsumable = true` and `isTradeable = true`.
They can be listed on the Exchange as Store Listings — same flow as any item.

```csharp
// ItemData for tickets:
public bool isTradeable = true;    // can list on Exchange
public bool isAccountBound = false; // becomes true on USE, not on purchase
```

When a player USES a ticket (redeems it from inventory):
```csharp
// Set isAccountBound = true — remove from tradeable pool
// Apply the benefit (extra inventory slot etc.)
// Cannot be re-listed after use
```

---

## Notifications — Full Exchange Matrix

All Exchange notifications use the existing FCM infrastructure.
In-app: shown as a banner if the player has the app open.
Push: fires via FCM if the player is backgrounded or app is closed.

| Event | Recipient | Timing | Priority | In-app | Push |
|-------|----------|--------|---------|--------|------|
| Store listing sold | Seller | On sale | P3 | ✅ | ✅ |
| Buy order filled (partial) | Buyer | On fill | P3 | ✅ | ✅ |
| Buy order filled (complete) | Buyer | On fill | P3 | ✅ | ✅ |
| Buy order expired | Buyer | On expiry | P4 | ✅ | ✅ |
| **Auction outbid** | Previous bidder | Immediately | **P2** | ✅ | ✅ |
| Auction ending soon | Current high bidder | 1 hour before close | P3 | ✅ | ✅ |
| Auction won | Winning bidder | On auction close | P3 | ✅ | ✅ |
| Auction sold | Seller | On auction close | P3 | ✅ | ✅ |
| Auction ended — no bids | Seller | On auction close | P4 | ✅ | ✅ |
| Store listing expired | Seller | On expiry | P4 | ✅ | ✅ |

**Outbid is P2** — the only Exchange notification that warrants waking a player's
phone urgently. They have currency escrowed and the auction is actively running.
All other Exchange notifications are P3/P4 — informational, not time-critical.

**Notification copy:**

```
Outbid (P2):
Title: "⚠ You've been outbid!"
Body:  "[Item Name] — someone bid [amount]. Auction ends [time remaining]"

Auction ending soon (P3):
Title: "⏰ Auction ending soon"
Body:  "[Item Name] — 1 hour remaining. Current bid: [amount]"

Auction won (P3):
Title: "🏆 You won the auction!"
Body:  "[Item Name] has been added to your inventory"

Auction sold (P3):
Title: "✓ Your auction sold"
Body:  "[Item Name] — [amount] SM/GM collected after fees"

Store listing sold (P3):
Title: "✓ Listing sold"
Body:  "[qty]× [Item Name] sold — [amount] collected after fees"

Buy order filled (P3):
Title: "✓ Buy Order filled"
Body:  "[qty]× [Item Name] received — [remaining qty] still wanted"

No bids / expired (P4):
Title: "[Item Name] listing expired"
Body:  "Collect your item from My Listings"
```

All notifications deep-link back to the Exchange My Listings tab.

---

---

## Implementation Order

**Part A — Store Listings (start here, reuses ItemListingComposer directly)**
1. Create `exchange_store_listings` table with RLS
2. Reuse `ItemListingComposer` with `requireOwnership: true, showPrice: true`
3. Build `buy_exchange_store_listing` RPC with fee calculation
4. Build Browse tab (search, filter, sort, Buy button)
5. Build My Listings tab (cancel, collect expired)
6. Wire seller + buyer notifications
7. Scheduled Edge Function for 30-day expiry

**Part B — Buy Orders**
8. Create `exchange_buy_orders` table with RLS
9. Reuse `ItemListingComposer` with `requireOwnership: false`
10. Build `fill_buy_order` RPC (0% fee always)
11. Build Buy Orders browse tab
12. Wire buyer notification on fill
13. Scheduled Edge Function for 30-day expiry + escrow return

**Part C — Auctions**
14. Create `exchange_auctions` table with RLS
15. Build auction post flow with duration picker
16. Build `place_auction_bid` RPC (escrow management)
17. Build `buy_auction_buyout` RPC
18. Scheduled Edge Function `close_ended_auctions` (hourly)
19. Wire all auction notifications

**Part D — Royal Merchant**
20. `RoyalMerchantCatalog` ScriptableObject with item list
21. Royal Merchant tab UI
22. GM purchase flow (deduct from PlayerData.GoldMarks)
23. Real-money purchase flow (Unity IAP + RevenueCat)
24. Ticket grant to inventory on purchase

---

*Path: `docs/exchange-implementation-brief.md`*
