# ⚔️ Project Grimoire — Guild System
### Version 0.1

---

## 📐 Design Philosophy

Guilds are the social and economic backbone of multiplayer Project Grimoire. The system is built to give guilds permanent progression, ongoing reasons to earn, and meaningful leadership decisions — without ever touching Talent XP curves directly. Guild benefits live in economy, drop rate, and access — never in XP rate.

**Core principles:**
- Guild bank funded by tax on member Exchange sales — ties guild health to trading activity
- Tiered roster growth — guilds start small and earn their way to larger size
- Leadership governance — tax changes require majority vote, 48hr delay before taking effect
- Guild buffs are economy/drop-rate only — never XP. Protects the carefully tuned Talent progression curve
- Cross-guild access exists — guests for casual play, alliances for formal coordination
- Infinite progression via Guild Prestige — never a point where there's nothing left to earn for

---

## 🏰 Guild Creation

| Requirement | Detail |
|-------------|--------|
| Cost | 2,000 Gold Marks |
| Founder requirement | Any player level — no Talent gate |
| Initial roster cap | 10 members |
| Name requirements | Unique across all guilds, 3-20 characters |

The 2,000 GM cost is a deliberate commitment barrier — prevents guild spam while remaining achievable for a dedicated player within a few weeks of normal play.

---

## 👥 Roles & Governance

| Role | Permissions |
|------|------------|
| **Guild Master** | Full control — invite/kick, set tax rate (subject to vote), spend bank, promote/demote, disband guild |
| **Officer** | Invite/kick members, vote on tax changes, activate consumable buffs, manage applications |
| **Member** | Contribute to bank, access guild perks, participate in guild quests and bounties |

### Tax Rate Governance
- Tax rate range: **0% – 5%** on completed Exchange sales (Store Listings and Auctions only — not Buy Orders)
- Rate changes require a **majority vote** among Guild Master + Officers
- Approved changes take effect **48 hours after vote passes** — gives members time to adjust expectations
- All members receive a notification when a tax vote passes
- Default tax rate at guild creation: 2%

---

## 📈 Guild Roster Tiers

Roster size grows through permanent upgrades purchased from the guild bank.

| Tier | Roster Cap | Upgrade Cost | Unlocks |
|------|-----------|-------------|---------|
| Founding | 10 | — (starting size) | — |
| Tier 1 | 20 | 5,000 GM | Shared guild quest slot |
| Tier 2 | 30 | 15,000 GM | Raid access unlocked |
| Tier 3 | 45 | 35,000 GM | Exchange fee discount (0.5%) |
| Tier 4 | 60 | 75,000 GM | Second shared guild quest slot |
| Tier 5 | 80 | 150,000 GM | Exchange fee discount increased (1%) |
| Tier 6 | 100 | 300,000 GM | Alliance system unlocked |

> Note: Raid access at Tier 2 means members of guilds below this tier can still join raids as **guests** in another guild's group — see Cross-Guild Access below. The guild's own raid roster organization simply isn't available until Tier 2.

---

## 💰 Guild Bank — Funding

### Primary Source: Exchange Tax
Automatically deducted from completed Store Listing and Auction sales at the guild's set tax rate (0–5%). Deposited directly to guild bank — no member action required.

### Secondary Source: Direct Donation
Members can donate Silver Marks, Gold Marks, or materials directly from inventory to the guild bank at any time. Voluntary, not taxed.

### Why this works
- Active traders fund the guild fastest — naturally rewards guilds with strong crafting/economy members
- No tax on Buy Orders — purchasing doesn't get penalized, only selling
- Members always see the current tax rate before joining and in the guild info panel — full transparency
- A skilled trader who doesn't raid is just as valuable to a guild as a skilled raider

---

## 🎯 Guild Bank — Spending Categories

To avoid the "maxed upgrades, no reason to earn" problem, guild spending is split into four categories — only one of which is permanent and finite.

### 1. Permanent Upgrades (Finite)
The roster tier table above. Eventually maxes out at Tier 6.

### 2. Consumable Guild Buffs (Infinite — repeatable purchases)
Temporary guild-wide buffs, **economy and drop-rate only, never XP**. Activated by Officers or Guild Master, duration-based.

| Buff | Cost | Duration | Effect |
|------|------|----------|--------|
| Prospector's Fortune | 3,000 GM | 24 hrs | +15% rare material drop chance, guild-wide |
| Merchant's Window | 2,000 GM | 24 hrs | Guild Exchange tax reduced to 0% temporarily |
| Bountiful Harvest | 2,500 GM | 24 hrs | +20% gathering yield quantity, guild-wide |
| Hunter's Providence | 3,500 GM | 24 hrs | +25% Silver/Gold Mark drops from combat, guild-wide |
| Lucky Charm | 4,000 GM | 12 hrs | +10% LCK wild card trigger chance, guild-wide |

> These never affect Talent XP gain rate — protects the core progression curve.

### 3. Guild Bounties (Infinite — event-style spending)
Larger one-time spends that create a special guild-wide event with a clear goal and reward.

**Example bounty structure:**
```
THE ASHFEN BOUNTY
Guild spends: 8,000 GM to activate
Goal: Guild collectively slays 500 enemies in Ashfen Mire within 48 hours
Reward if met: All participating members receive 2x material 
drops in Ashfen Mire for the following week
Reward if guild reaches 75%+: Partial reward — 1.5x for 3 days
Reward if under 75%: Bounty fails, GM spent is not refunded
```

This creates a guild-wide collaborative push — exciting, time-limited, and gives leadership a reason to rally the guild. Officers can activate one bounty at a time.

### 4. Guild Prestige (Infinite — never maxes)
A separate infinite leveling track funded by spending directly from the **current guild bank balance**. Prestige competes with roster upgrades and consumable buffs for the same funds — leadership must choose how to allocate earnings rather than treating Prestige as a passive side-track.

This creates a genuine strategic decision every week: save for the next roster tier, activate a bounty, or push toward the next Prestige milestone. Well-run guilds with strong income can pursue more than one path; smaller guilds must prioritize.

| Prestige Level | Bank Spend Required | Reward |
|----------------|---------------------|--------|
| 1 | 10,000 GM | Guild Hub upgrades — Campfire Gathering |
| 5 | 75,000 GM | Guild title — "Established" + Guild Hub upgrade — Tent Camp |
| 10 | 250,000 GM | Guild emblem customization |
| 20 | 750,000 GM | Guild title — "Renowned" + Guild Hub upgrade — Army Encampment |
| 35 | 2,000,000 GM | Guild Hub upgrade — Fortress |
| 50 | 5,000,000 GM | Guild title — "Legendary" + leaderboard placement + Guild Hub upgrade — Castle |
| 75 | 15,000,000 GM | Guild Hub upgrade — Castle with surrounding Village |
| 100 | 40,000,000 GM | Guild Hub upgrade — Stronghold Capital + permanent leaderboard banner |

Prestige never caps — new tiers and Guild Hub stages can be added indefinitely as cosmetic and bragging-rights rewards. This is the long-term sink for guilds that have maxed roster tiers, since Prestige spending draws from the same pool as everything else and never runs out of reasons to exist.

---

## 🏛️ Guild Hub Visual Progression

The Guild Hub is the idle background/home screen members see when viewing their guild. It evolves visually with Prestige level — making progression something every member sees passively, not just a number on a screen.

| Prestige Level | Hub Visual | Mood |
|----------------|-----------|------|
| 0 (Founding) | A handful of people around a campfire | Humble beginnings |
| 1–4 | Campfire Gathering — small camp, a few people, modest fire | Settling in |
| 5–9 | Tent Camp — several tents pitched, more members visible | Growing community |
| 10–19 | Encampment — organized camp, banners raised, supply carts | Established presence |
| 20–34 | Army Encampment — large fortified camp, watchtowers, many figures | Renowned force |
| 35–49 | Fortress — stone walls, gate, defensive structure | Serious power |
| 50–74 | Castle — full castle structure, flags, guards | Legendary status |
| 75–99 | Castle with Village — castle plus surrounding village, market stalls, NPCs | Thriving domain |
| 100+ | Stronghold Capital — sprawling fortified capital, the guild's permanent legacy | Endgame prestige |

**Design notes:**
- Each stage is a single illustrated pixel art background — no functional change, purely atmospheric
- Transitions between stages could include a brief celebratory animation when the guild hits the milestone
- Background is visible on the Guild Home tab and could optionally be used as a loading screen backdrop for guild members
- Long-term art pipeline item — early stages needed for launch, later stages (Fortress onward) can be produced post-launch as guilds approach those milestones
- This single piece of art becomes one of the most repeated and recognizable visuals in the game for active guilds — worth investing real art quality here over time

---

## ⚔️ Cross-Guild Access

Solves the small-guild content access problem — players shouldn't be locked out of raids/dungeons just because their guild hasn't hit Tier 2.

### Guest System (available to everyone, no guild upgrade required)
- Any player can join another guild's raid or dungeon group as a **Guest**
- Guild leadership of the hosting guild approves guest requests
- Guests do not receive that guild's permanent perks (Exchange discount etc.) — only participate in the specific activity
- Guests are NOT taxed by the hosting guild — their Exchange sales remain taxed by their own guild only
- No cooldown or penalty for guesting with multiple different guilds

### Alliance System (Guild Tier 6 unlock)
- Two guilds can formally ally
- Allied guild members can freely join each other's raid/dungeon groups without per-instance approval
- Alliances are mutual — both Guild Masters must agree
- Either guild can dissolve the alliance at any time
- Sets up the foundation for Faction War guild cooperation (DLC)

---

## 🚪 Joining & Leaving

### Join Policies (guild sets their own — configurable by Guild Master)
| Policy | How it works |
|--------|--------------|
| **Open** | Anyone can join instantly, no approval needed |
| **Apply** | Player requests to join, Officer or Guild Master approves/denies |
| **Invite Only** | Player must be directly invited — cannot request to join |

### Leaving a Guild
- No Gold Mark cost to leave
- **72 hour cooldown** before joining another guild — prevents guild hopping to dodge tax rate changes or chase better perks
- Leaving forfeits any unclaimed bounty rewards in progress
- Guild Master leaving triggers automatic promotion of the senior-most Officer

---

## 📋 Shared Guild Quest Slots

Unlocked at Roster Tier 1 (first slot) and Tier 4 (second slot). Functions alongside the individual Daily/Weekly Quest System.

- One shared quest appears on the guild's weekly board
- Any member's contribution counts toward the shared goal
- Example: "Guild Quest: Collectively gather 1,000 Iron Ore this week"
- Reward is deposited directly to the guild bank, not individual players
- Encourages collaboration without forcing it — solo players can ignore it, social players rally around it

---

## 🔗 Cross-System Notes

- **Wayfarer's Exchange:** Guild tax is calculated and deducted automatically on sale completion — Exchange system needs a guild_id lookup on every transaction
- **Raids:** Guild Tier 2 unlocks organized raid rosters; Guest system provides access below Tier 2
- **Daily/Weekly Quests:** Shared guild quest slot is additive to the individual 5 daily / 2 weekly slots — does not replace them
- **Monetization:** No real-money guild purchases planned — guild progression is GM/gameplay only, keeps guild standing skill and activity based rather than pay-to-win
- **Faction Wars (DLC):** Alliance system architecture will extend to support faction-aligned guild cooperation
- **Zone Conquest (Warlord subclass):** When a guild's Warlord clears a zone boss, priority resource access is granted to the guild — ties into this system's roster and bank structure

---

## 📱 Guild UI Structure

**Guild Home tab:**
- Guild name, emblem, Prestige level, member count/cap
- Current tax rate and pending vote status if applicable
- Bank balance (visible to all members for transparency)
- Active consumable buffs with time remaining

**Roster tab:**
- Member list with role, contribution total, last active
- Invite/kick controls for appropriate roles

**Bank tab:**
- Donation interface
- Upgrade purchase options (next roster tier)
- Consumable buff activation (Officer/Guild Master only)
- Bounty activation and progress tracking

**Prestige tab:**
- Current Prestige level and progress to next
- Current Guild Hub visual stage displayed prominently
- Reward history and cosmetic unlocks
- Preview of next Guild Hub visual milestone to motivate saving

---

*Document version 0.2 — Guild System*
*Next: Monetization scope (with guild upgrades included) · Main design doc cleanup*
