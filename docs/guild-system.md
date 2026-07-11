---
type: design-spec
version: 0.4
updated: 2026-07-11
reconciled-to: implementation-status.md (2026-07-10) + shipped code (GuildBankUI.cs)
---

# Project Grimoire — Guild System
### Version 0.4

> **As-built note:** Reconciled against `implementation-status.md` and the shipped code
> (`Assets/Scripts/UI/GuildBankUI.cs`, migrations 002/010–018). Where the original design and the
> shipped code differ, the shipped behaviour is documented and marked **[as-built]**. Design intent
> that hasn't shipped yet is marked **[pending]**.

---

## 📐 Design Philosophy

Guilds are the social backbone of Project Grimoire's economy. They give players a reason to
cooperate, pool resources, and invest in shared progression. Guild membership should always feel
economically advantageous over going solo — through Exchange tax relief, internal trading at better
rates, and shared consumable buffs that amplify everyone's idle gains.

---

## 🏰 Guild Creation

- Costs **2,000 GM** — a meaningful but reachable barrier.
- Creator becomes **Guild Master** by default (via the `create_guild` RPC).
- Guild name: 3–30 characters, unique.
- Join policy set at creation. **[as-built]** two policies ship: **Open** and **Invite Only**
  (`open` / `invite_only`).
- **[pending]** A **Closed** (undiscoverable, invite-direct-only) policy, an 80-char discovery
  description, and a Casual/Serious guild-type filter tag are designed but not yet built.

---

## 👥 Roles

| Role | Key permissions |
|------|----------------|
| **Guild Master** | All permissions; transfer role; disband guild |
| **Officer** | Invite/kick members, post material requests, activate buffs, initiate votes |
| **Member** | Donate to bank, list on Guild Merchant, vote |

---

## 💰 Exchange Tax

- **Solo players** pay a **3% system tax** on Exchange sales (Store Listings + Auctions). Goes to an economy sink — removed from circulation.
- **Guild members** pay a **0–3% guild tax** instead. This replaces the system tax entirely — never both.
- Guild tax rate is set by vote (see Voting below). Default at creation: **2%**.
- **Guild Merchant internal sales** are charged at **half the guild tax rate** (e.g. 3% guild tax → 1.5% internal). If guild tax is 0%, internal rate is also 0%.
- Buy Orders are always 0% — no fee on purchases, only on sales.

---

## 🗳️ Voting — as-built

> **[as-built]** The shipped voting model (`cast_guild_vote` RPC, migration 015) differs from the
> original design in two ways:
> 1. Approval threshold is **2/3 of the full roster** (`ceil(2/3 × member_count)`), not "majority of GM + Officers".
> 2. A vote **passes and applies immediately** when the threshold is reached — there is no 48-hour delay.
>
> A vote remains open until: threshold reached (immediate pass) / all members have voted / 7 days elapsed.
> One ballot per member (enforced by a `guild_vote_ballots` primary key).
> **[as-built]** `close_expired_guild_votes()` (migration 019, hourly pg_cron) closes open votes once 7 days elapse or all members have voted.

Votes are initiated by the Guild Master or any Officer. Votable decisions:
- **Tax rate change** — 30-day cooldown between changes.
- **Guild name change** — 3-month cooldown between changes.

---

## 🏪 Guild Merchant — as-built

> **[as-built]** Listings carry a **dual-currency price** — both `price_sm` and `price_gm` (either
> may be 0), representing a combined-marks price (e.g. "3 GM 500 SM"). This superseded the original
> SM-only design.

- **Members only** — listings are not visible to allied guilds or the public. Keeps it from making the Wayfarer's Exchange redundant.
- **Listing fee** = half the guild tax rate, credited to the guild bank on sale (taken from each currency).
- Items are **escrowed** out of the seller's inventory on posting and returned on cancel.
- Buying is handled by the atomic `buy_guild_listing` RPC: charges buyer both currencies, pays seller minus fee, credits guild bank, deletes listing.
- Listings expire after **7 days** if unsold. **[as-built]** `sweep_expired_merchant_listings()` (migration 019, hourly pg_cron) returns escrowed items to the seller's inventory and deletes the listing.
- Uses `ItemListingComposer` (also used for material requests) — reusable for Wayfarer's Exchange later.

---

## 🏦 Guild Bank

- Funded by guild tax on Exchange sales, Guild Merchant listing fees, and direct member donations.
- Officers and GM can withdraw. All members can view (transparency).
- **[as-built]** 50 slots base; Officers/GM expand in **+10-slot** increments, paid from the guild bank.
- Material requests posted by Officers/GM — any member can donate from inventory to fill them.

---

## ⚔️ Guild Upgrades & Prestige

### Roster Tier Upgrades — [as-built]
Increase the member cap. Purchased by GM from the guild bank. Seven tiers (tier 0 is the starting cap).

| Tier | Member cap | GM cost |
|------|-----------|---------|
| 0 | 10 | — (starting) |
| 1 | 20 | 5,000 |
| 2 | 30 | 15,000 |
| 3 | 45 | 35,000 |
| 4 | 60 | 75,000 |
| 5 | 80 | 150,000 |
| 6 | 100 | 300,000 |

### Prestige & Hub Stages — [as-built]
Guild Prestige is a separate progression driven by milestone GM spends from the bank.
Each milestone unlocks a new Guild Hub background art stage.

| Prestige | Hub visual |
|----------|-----------|
| 0–4 | Campfire Gathering |
| 5–9 | Tent Camp |
| 10–19 | Encampment |
| 20–34 | Army Encampment |
| 35–49 | Fortress |
| 50–74 | Castle |
| 75–99 | Castle with Village |
| 100+ | Stronghold Capital |

Milestone thresholds: 1 / 5 / 10 / 20 / 35 / 50 / 75 / 100.

### Consumable Guild Buffs — [as-built]
Purchased by Officers/GM from the bank — apply to all members for a fixed duration.

| Buff | Cost | Effect | Duration |
|------|------|--------|---------|
| Prospector's Fortune | 3,000 GM | +15% rare material drop chance | 24 hours |
| Merchant's Window | 2,000 GM | Guild Exchange tax reduced to 0% | 24 hours |
| Bountiful Harvest | 2,500 GM | +20% gathering yield | 24 hours |
| Hunter's Providence | 3,500 GM | +25% Silver/Gold Mark drops from combat | 24 hours |
| Lucky Charm | 4,000 GM | +10% LCK wild-card trigger chance | 12 hours |

---

## 📋 Guild Roster & Invitations

- Discovery screen: search by name; shows Open and Invite-Only guilds.
- **Open guilds**: any player can join directly (`join_guild` RPC).
- **Invite Only**: players submit a join request; Officers/GM approve or decline from the Roster tab.
- Roster shows each member's username, equipped Grimoire, and combat level.
- Guild Master can transfer the GM role to any member; disbanding has a 7-day grace period.
- **[pending]** 72-hour cooldown before joining another guild after leaving one (anti tax-hopping) — designed, not yet enforced in code.

---

## 🎵 Adaptive Audio (Guild Hall)

The Guild Hall uses a layered stem system — one master composition with instrument stems that
fade in/out based on which tab is active. **[pending]** Requires commissioned stems (Suno generates
complete tracks, not stems). Phase 1/2 interim: single guild music track throughout all tabs.

---

## ⏳ Pending / Not Yet Built

| Item | Notes |
|------|-------|
| Closed join policy + Casual/Serious type | Discovery filtering additions |
| 72-hour re-join cooldown | Anti tax-hopping enforcement |
| Guild Bounties | Deferred to post-launch content update |
| Alliance system | Deferred — Tier 6 permanent unlock |
| Adaptive audio stems | Deferred — requires commissioned multi-stem composition |

---

*Path: `docs/guild-system.md`*
