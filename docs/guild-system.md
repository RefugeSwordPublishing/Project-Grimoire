---
type: design-spec
version: 0.4
updated: 2026-07-11
reconciled-to: implementation-status.md (2026-07-10)
---

# Project Grimoire, Guild System
### Version 0.4

> **As-built note:** This spec has been reconciled against `implementation-status.md` (2026-07-10).
> Where the original design and the shipped code differ, the shipped behaviour is documented here
> and marked **[as-built]**. Design intent that hasn't shipped yet is marked **[pending]**.

---

## Design Philosophy

Guilds are the social backbone of Project Grimoire's economy. They give players a reason to
cooperate, pool resources, and invest in shared progression. Guild membership should always feel
economically advantageous over going solo, through Exchange tax relief, internal trading at better
rates, and shared consumable buffs that amplify everyone's idle gains.

---

## Guild Creation

- Costs **2,000 GM**, a meaningful but reachable barrier.
- Creator becomes **Guild Master** by default.
- Guild name: 3-30 characters, profanity-filtered, unique.
- Description: 80-character max shown on the discovery screen.
- Join policy set at creation: **Open**, **Invite Only**, or **Closed**.
- Guild type: **Casual** or **Serious**, shown as a filter tag on the discovery screen.

---

## Roles

| Role | Key permissions |
|------|----------------|
| **Guild Master** | All permissions; transfer role; disband guild |
| **Officer** | Invite/kick members, post material requests, activate buffs, initiate votes |
| **Member** | Donate to bank, list on Guild Merchant, vote |

---

## Exchange Tax

- **Solo players** pay a **3% system tax** on Exchange sales (Store Listings + Auctions). Goes to an economy sink, removed from circulation.
- **Guild members** pay a **0-3% guild tax** instead. This replaces the system tax entirely, never both.
- Guild tax rate is set by vote (see Voting below).
- **Guild Merchant internal sales** are charged at **half the guild tax rate** (e.g. 3% guild tax → 1.5% internal). If guild tax is 0%, internal rate is also 0%.
- Buy Orders are always 0%, no fee on purchases, only on sales.

---

## Voting, as-built

> **[as-built]** The shipped voting model differs from the original design in two ways:
> 1. Approval threshold is **2/3 of the full roster** (`ceil(2/3 × member_count)`), not "majority of GM + Officers".
> 2. A vote **passes and applies immediately** when the threshold is reached, there is no 48-hour delay.
>
> A vote remains open until: threshold reached (immediate pass) / all members have voted / 7 days elapsed.
> **[pending]** Scheduled Edge Function to auto-close votes that reach 7 days below threshold, not yet built.

Votes are initiated by the Guild Master or any Officer. One ballot per member.
Votable decisions:
- **Tax rate change**, 30-day cooldown between changes.
- **Guild name change**, 3-month cooldown between changes.

---

## Guild Merchant, as-built

> **[as-built]** The shipped Guild Merchant implementation has one key difference from the original design:
> listings carry a **dual-currency price**, both `price_sm` and `price_gm` (either may be 0),
> representing a combined-marks price (e.g. "3 GM 500 SM"). This superseded the original SM-only design.

- **Members only**, listings are not visible to allied guilds or the public. Keeps it from making the Wayfarer's Exchange redundant.
- **Listing fee** = half the guild tax rate, credited to the guild bank on sale.
- Items are **escrowed** out of the seller's inventory on posting and returned on cancel.
- Buying is handled by the atomic `buy_guild_listing` RPC: charges buyer both currencies, pays seller minus fee, credits guild bank, deletes listing.
- Listings expire after **7 days** if unsold. **[pending]** Scheduled Edge Function to sweep expired listings and return escrowed items, not yet built.
- Uses `ItemListingComposer` (also used for material requests), reusable for Wayfarer's Exchange later.

---

## Guild Bank

- Funded by guild tax on Exchange sales, Guild Merchant listing fees, and direct member donations.
- Officers and GM can withdraw. All members can view (transparency).
- 50 slots base, expandable via Royal Merchant ticket.
- Material requests posted by Officers/GM, any member can donate from inventory to fill them.

---

## Guild Upgrades & Prestige

### Roster Tier Upgrades
Increase the member cap. Purchased by GM/Officers from the guild bank.

| Tier | Member cap | Approximate GM cost |
|------|-----------|-------------------|
| 1 | 15 |, (starting) |
| 2 | 30 | 15,000 GM |
| 3 | 45 | 35,000 GM |
| 4 | 60 | 75,000 GM |
| 5 | 100 | 150,000 GM |

### Prestige & Hub Stages
Guild Prestige is a separate progression driven by milestone GM spends from the bank.
Each milestone unlocks a new Guild Hub background art stage.

| Prestige | Hub visual |
|----------|-----------|
| 0-4 | Campfire Gathering |
| 5-9 | Tent Camp |
| 10-19 | Encampment |
| 20-34 | Army Encampment |
| 35-49 | Fortress |
| 50-74 | Castle |
| 75-99 | Castle with Village |
| 100+ | Stronghold Capital |

### Consumable Guild Buffs
Purchased by Officers/GM from the bank, apply to all members for a fixed duration.

| Buff | Effect | Duration |
|------|--------|---------|
| Prospector's Fortune | +15% rare drop chance | 24 hours |
| Bountiful Harvest | +20% gathering yield | 24 hours |
| Scholar's Rest | +10% XP from all Talents | 12 hours |
| Merchant's Window | Guild tax reduced to 0% temporarily | 24 hours |

---

## Guild Roster & Invitations

- Discovery screen: search by name, filter by Casual/Serious and Open/Invite-Only.
- **Open guilds**: any player can join directly.
- **Invite Only**: players can submit a join request; Officers/GM approve or decline from the Roster tab.
- **Closed**: not discoverable; GM/Officers invite directly only.
- 72-hour cooldown before joining another guild after leaving one (prevents tax-rate hopping).
- Guild Master can transfer the GM role to any member; disbanding has a 7-day grace period.

---

## Adaptive Audio (Guild Hall)

The Guild Hall uses a layered stem system, one master composition with instrument stems that
fade in/out based on which tab is active. **[pending]** Requires commissioned stems (Suno generates
complete tracks, not stems). Phase 1/2 interim: single guild music track throughout all tabs.

---

## ⏳ Pending / Not Yet Built

| Item | Notes |
|------|-------|
| Auto-close vote Edge Function | Closes votes at 7 days if threshold not reached |
| Expired listing sweep Edge Function | Returns escrowed items from listings past `expires_at` |
| Guild Bounties | Deferred to post-launch content update |
| Alliance system | Deferred, Tier 6 permanent unlock |
| Adaptive audio stems | Deferred, requires commissioned multi-stem composition |

---

*Path: `docs/guild-system.md`*
