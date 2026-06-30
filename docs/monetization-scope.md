# ⚔️ Project Grimoire — Monetization Scope
### Version 0.1

---

## 📐 Design Philosophy

Nothing in Project Grimoire is exclusively pay-walled. Every item, unlock, and upgrade is earnable through normal play with Silver and Gold Marks. Real money purchases exist purely as a **convenience and time-savings option** for players who want to support development or accelerate their journey — never as the only path to power or content.

**Hard rules:**
- No XP boosts for sale, ever — protects the core progression curve and prevents whales from trivializing the leveling experience
- No stat-affecting items real-money exclusive — cosmetics and convenience only when real money is the sole option
- No guild power purchasable with real money — guild progression is GM and activity based only, protects competitive integrity
- No pay-to-skip on quests, dungeons, or raids — these are earned through play
- All pricing shown in both Gold Marks and real money side by side — full transparency, no obfuscation

---

## 💰 Currency Recap

| Currency | Source | Role |
|----------|--------|------|
| Silver Marks (SM) | Combat, selling, quests, gathering | Day-to-day economy |
| Gold Marks (GM) | Rare drops, weekly quests, high-value sales, real money purchase | Significant purchases — Grimoires, DLC, premium items |

Conversion: 1,000 SM = 1 GM (informal reference, not a forced exchange mechanic)

---

## 🛒 System Store Catalog

### Grimoires

| Item | GM Price | Real Money | Notes |
|------|---------|-----------|-------|
| Additional base game Grimoire (any of the 7) | 500 GM | $2.99 | First Grimoire is free at game start |
| DLC Grimoire — Beastbond, Warlock, Kensei | 2,500 GM | $4.99 | Higher tier — DLC exclusive content |
| DLC Subclass — Bard/Minstrel (when released) | 2,500 GM | $4.99 | Same DLC tier pricing |

### Content Packs (DLC)

| Item | GM Price | Real Money | Notes |
|------|---------|-----------|-------|
| Faction System Pack | 10,000 GM | $9.99 | Unlocks faction reputation, faction wars, level 120 cap |
| New Game Plus / Hard Mode Pack | 6,000 GM | $6.99 | Hard mode dungeons, expanded talent cap to 120 |

### Quest Board Expansions

| Item | GM Price | Real Money | Notes |
|------|---------|-----------|-------|
| Daily Quest Slots — unlock all 10/10 | 400 GM | $2.99 | Permanent, one-time purchase |
| Weekly Quest Slots — unlock all available | 400 GM | $2.99 | Permanent, one-time purchase |

### Exchange Conveniences

| Item | GM Price | Real Money | Notes |
|------|---------|-----------|-------|
| +5 Exchange listing slots | 300 GM | $1.99 | Permanent, stackable (can buy multiple times) |
| +10 Buy Order slots | 300 GM | $1.99 | Permanent, stackable |

### Cosmetics

| Item | GM Price | Real Money | Notes |
|------|---------|-----------|-------|
| Grimoire skin (per design) | 200 GM | $0.99 | Purely visual, no stat effect |
| Character portrait frame | 150 GM | $0.99 | UI cosmetic around player portrait |
| Name badge (non-supporter) | 150 GM | $0.99 | Displayed in chat/guild roster |
| Early Supporter Badge | — | One-time, tied to early purchase | Cannot be bought after launch window closes — see below |
| Guild banner color variant | 200 GM | $0.99 | Guild Master purchase, cosmetic only |
| Guild emblem theme | 300 GM | $1.99 | Guild Master purchase, cosmetic only |

### Gold Mark Packs (direct purchase, convenience only)

| Pack Name | GM Granted | Price | Notes |
|-----------|-----------|-------|-------|
| Wanderer's Pouch | 100 GM | $0.99 | Base value |
| Merchant's Satchel | 300 GM | $2.49 | Slight bonus over base rate |
| Wayfarer's Chest | 600 GM | $3.99 | Better value |
| Grimoire Vault | 1,500 GM | $7.99 | Best value — bulk purchase |

GM Packs let players who want to accelerate convert real money into the existing economy rather than buying power directly — they still have to spend the GM on actual catalog items, keeping the earnable-everything philosophy intact.

---

## 🏆 Early Supporter Badge

A one-time-only cosmetic badge available exclusively during a limited launch window — likely the first 30–60 days post-launch, or tied to any purchase made during early access/soft launch. Cannot be purchased after the window closes, regardless of GM or real money offered.

**Purpose:** Rewards early community trust and creates a permanent, non-repeatable status symbol. No gameplay effect — purely a badge displayed next to player name in chat, guild roster, and Exchange listings.

**Design consideration:** Avoid any tiered version of this (no "Bronze/Silver/Gold supporter") — keep it as a single binary badge to avoid feeling like a spending leaderboard. Status should come from being early, not from spending more.

---

## 🚫 What Will Never Be Sold

Explicitly excluded from monetization, regardless of future pressure to add revenue streams:

- XP boosts of any kind
- Stat-boosting consumables exclusive to real money
- Guild power, upgrades, or roster expansion via real money
- Faction standing or faction war advantages
- Raid or dungeon skip tickets
- Rare material direct purchase (must be earned via gathering, combat, or Assembly)
- Legendary or Mythic tier items direct purchase
- Loot boxes or gacha-style randomized purchases of any kind

This list should be revisited only with extreme caution — the core promise to players is that spending buys convenience and cosmetics, never power.

---

## 📊 Monetization Philosophy Summary

| Category | Real Money Role |
|----------|-----------------|
| Grimoires | Convenience — skip the GM grind, same end result as earning |
| DLC Content | Direct unlock — fair dollar pricing for genuinely new content |
| Quest Slots | Convenience — quality of life for engaged players |
| Exchange Slots | Convenience — quality of life for active traders |
| Cosmetics | Pure vanity — no gameplay impact whatsoever |
| GM Packs | Currency conversion — still must be spent in-game, no direct power purchase |

The guiding question for any future monetization addition should always be: **"Does this let a player buy an outcome they couldn't eventually earn through play?"** If yes, it doesn't belong in Project Grimoire.

---

## 🔧 Technical Notes for Implementation

- All System Store items require dual pricing display — GM cost AND real money cost shown simultaneously on every item card
- Real money purchases process through Unity IAP — App Store, Google Play, and Steam each need their own product ID mapping but should resolve to the same internal item grant
- Early Supporter Badge requires a server-side timestamp check against a fixed launch window end date — implement as a feature flag that can be toggled off after the window closes
- GM Packs should NOT have a fixed in-game equivalent earn rate displayed — avoid implying GM purchased equals GM earned at any specific ratio, keeps regulatory and platform policy risk low
- Guild cosmetic purchases (banner, emblem) should debit the purchasing player's personal GM balance, not the guild bank — keeps guild bank spend rules consistent with the Guild System doc

---

*Document version 0.1 — Monetization Scope*
*Next: Main design doc cleanup pass*
