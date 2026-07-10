# ⚔️ Project Grimoire — Monetization Scope
### Version 0.3

---

## 📐 Design Philosophy

Nothing in Project Grimoire is exclusively pay-walled. Every item, unlock, and upgrade is earnable through normal play with Silver and Gold Marks. Real money purchases exist purely as a **convenience and time-savings option** — never as the only path to power or content.

**Hard rules:**
- No XP boosts for sale, ever — protects the core progression curve
- No stat-affecting items real-money exclusive
- No guild power purchasable with real money
- No pay-to-skip on quests, dungeons, or raids
- No direct Gold Mark purchases — prevents market flooding and economy manipulation
- All pricing shown in both Gold Marks and real money side by side — full transparency
- Tradeable tickets let the player market set the effective exchange rate organically

---

## 💰 Currency

| Currency | Source | Role |
|----------|--------|------|
| Silver Marks (SM) | Combat, selling, quests, gathering | Day-to-day economy |
| Gold Marks (GM) | Rare drops, weekly quests, high-value sales, ticket sales on Exchange | Significant purchases |

**No direct Gold Mark purchases.** Players who want Gold Marks earn them through gameplay or by purchasing tradeable tickets from the Royal Merchant and listing them on the Wayfarer's Exchange. The Exchange sets the real-money-to-marks rate organically based on supply and demand — not the developer.

---

## 🏪 The Royal Merchant

All premium purchases are made through **The Royal Merchant** — a dedicated vendor tab inside the Wayfarer's Exchange. Feels like a natural part of the game world rather than a jarring external store screen.

**Location:** Wayfarer's Exchange → Royal Merchant tab
**Access:** Any player who can access the Exchange (any Talent level 10)

---

## 🎟️ Tradeable Tickets

Convenience items sold by the Royal Merchant. Key distinction from other purchases:
- **Tradeable** — can be listed on the Wayfarer's Exchange, sent to friends, or gifted to guild members
- **Account-bound on use** — once redeemed, the benefit applies to that account permanently
- **No expiry** — permanent until used
- **Player-driven exchange rate** — players who want GM buy tickets from other players on the Exchange rather than from the developer directly

| Ticket | Real Money | GM Price | Effect on Use | Tradeable |
|--------|-----------|---------|--------------|-----------|
| Inventory Slot Ticket | $1.99 | 300 GM | +10 personal inventory slots (permanent) | ✅ Yes |
| Daily Quest Slot Ticket | $1.99 | 400 GM | Expands daily quests from 5→10 (permanent) | ✅ Yes |
| Weekly Quest Slot Ticket | $1.99 | 400 GM | Expands weekly quests from 2→4 (permanent) | ✅ Yes |
| Slaying Task Slot Ticket (6th) | $0.99 | 200 GM | Unlocks 6th task slot (permanent) | ✅ Yes |
| Slaying Task Slot Ticket (7th) | $1.99 | 300 GM | Unlocks 7th task slot (permanent) | ✅ Yes |
| Slaying Task Slot Ticket (8th) | $2.99 | 500 GM | Unlocks 8th task slot (permanent) | ✅ Yes |
| Exchange Listing Slot Ticket | $1.99 | 300 GM | +5 Exchange listing slots (permanent, stackable) | ✅ Yes |
| Guild Bank Slot Ticket | $1.99 | 300 GM | +10 guild bank slots (permanent, stackable) | ✅ Yes |

> Note: Slaying task slots 4 and 5 are free milestone unlocks at Slaying level 25 and 50 — only slots 6, 7, and 8 require purchase.

---

## 🔒 Account-Bound Purchases

These items are account-bound immediately on purchase — cannot be traded, sold on Exchange, or gifted. Prevents flipping for marks on items that would create gameplay advantage.

### Grimoires

| Item | Real Money | GM Price | Notes |
|------|-----------|---------|-------|
| Additional base game Grimoire (any of 7) | $2.99 | 500 GM | First Grimoire free at start |
| DLC Grimoire — Beastbond, Warlock, Kensei | $4.99 | 2,500 GM | DLC exclusive |
| DLC Subclass — Bard/Minstrel | $4.99 | 2,500 GM | DLC exclusive |

### DLC Content Packs

| Item | Real Money | GM Price | Notes |
|------|-----------|---------|-------|
| Faction System Pack | $9.99 | 10,000 GM | Factions, faction wars, level 120 cap |
| New Game Plus / Hard Mode Pack | $6.99 | 6,000 GM | Hard dungeons, expanded Talent cap |

### Cosmetics
Account-bound — cosmetics should represent personal expression, not be commodities.

| Item | Real Money | GM Price | Notes |
|------|-----------|---------|-------|
| Grimoire skin (per design) | $0.99 | 200 GM | Purely visual |
| Character portrait frame | $0.99 | 150 GM | UI cosmetic |
| Name badge | $0.99 | 150 GM | Displayed in chat/guild/Exchange |
| Early Supporter Badge | One-time, launch window only | — | Cannot be purchased after window closes |
| Guild banner color variant | $0.99 | 200 GM | Guild Master purchase |
| Guild emblem theme | $1.99 | 300 GM | Guild Master purchase |

---

## 🎟️ How Tradeable Tickets Create a Player-Driven Exchange

The flow for a player who wants Gold Marks but doesn't want to grind:

```
Player buys Inventory Slot Tickets from Royal Merchant ($1.99 each)
         ↓
Lists tickets on Wayfarer's Exchange at market price
         ↓
Other players buy tickets with earned Gold Marks
         ↓
Buyer redeems ticket → gets inventory slots
Seller gets Gold Marks → spends on Grimoires, rare materials etc.
```

This means:
- Developer captures revenue through ticket sales
- No fixed real-money → GM conversion rate — Exchange sets the rate
- Players who grind can acquire premium convenience without spending real money
- Spenders get a liquid market for their purchases
- Economy cannot be flooded since tickets are consumed on use

---

## 🚫 What Will Never Be Sold

Explicitly excluded from monetization permanently:

- XP boosts of any kind
- Direct Gold Mark or Silver Mark purchases
- Stat-boosting consumables exclusive to real money
- Guild power, upgrades, or roster expansion via real money
- Faction standing or faction war advantages
- Raid or dungeon skip tickets
- Rare material direct purchase
- Legendary or Mythic tier items direct purchase
- Loot boxes or gacha-style randomized purchases

---

## 📊 Monetization Summary

| Category | Real Money Role | Tradeable |
|----------|----------------|-----------|
| Grimoires | Convenience — skip GM grind | No |
| DLC Content | Direct unlock for new content | No |
| Convenience Tickets | Buy and use, or sell on Exchange | Yes |
| Cosmetics | Pure vanity, no gameplay impact | No |
| Currency | No direct purchase — tickets only | Tickets yes |

The guiding question for any future monetization addition: **"Does this let a player buy an outcome they couldn't eventually earn through play?"** If yes, it doesn't belong in Project Grimoire.

---

## 🔧 Technical Notes for Implementation

- Royal Merchant is a tab within the Wayfarer's Exchange UI — not a separate screen
- **RevenueCat SDK** handles all purchase validation across iOS, Android, and Steam — do not build custom receipt validation
- RevenueCat validates purchases, grants entitlements, and sends webhook events to Supabase to update player account
- All purchases process through Unity IAP, validated by RevenueCat, then recorded in Supabase
- Tradeable tickets stored in inventory as normal items with `is_tradeable: true` flag
- Account-bound items set `is_tradeable: false` and `is_account_bound: true` on purchase grant
- Early Supporter Badge requires server-side timestamp check against launch window end date
- Ticket redemption calls a server-side Edge Function to validate and apply the benefit
- Exchange listing of tickets follows normal listing rules — solo players pay 3% system tax, guild members pay their guild tax rate (0–3%)
- Guild Bank Slot Ticket redeemed by Guild Master or Officer only — server validates role before applying

---

*Document version 0.3 — Monetization Scope*
*Next: Session 3 handoff*
