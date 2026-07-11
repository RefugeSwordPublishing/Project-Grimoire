---
type: implementation-status
updated: 2026-07-10
purpose: Single source of truth for WHAT IS ACTUALLY BUILT vs. design intent in the specs.
audience: Claude (Chat or Code) starting a session. Read this FIRST, then the relevant spec.
---

# Project Grimoire — Implementation Status (as-built)

The spec files in `docs/` describe **design intent**. This file records **what is actually
implemented in code** where the two diverge. When they conflict, the code (and this file) win.
Claude Code updates this file as features land; Claude Chat should read it before any design work
so it builds on the current state rather than the original design.

## Repo layout
- `Project-Grimoire` (public) — this repo: design docs (`docs/`), Supabase SQL (`supabase/migrations/`), and the Unity project as a **git submodule** at `ProjectGrimoire/`.
- `ProjectGrimoire` (private) — the Unity/C# game. Chat cannot read it (private → 404); design docs + SQL here are public and readable.

## Phase status
- **Phase 1:** complete (managers, ScriptableObjects, Bowstring mechanic, idle loop, Supabase + FCM).
- **Phase 2:** guild system + Guild Merchant complete (below). Remaining Phase 2: Runic Constellation, Summoner, Lifebinder, Vanguard combo, aggro, zone content, Exchange fees, sprite pass.

## Guild system — DONE (2026-07-10)
Unity: `Assets/Scripts/UI/GuildBankUI.cs` (+ `Editor/BuildGuildBankUI.cs`). SQL: migrations 002, 010–018.
Tabs: **Home / Roster / Bank / Upgrades / Prestige / Merchant / Settings**.
- Discovery + create (`create_guild` RPC) + join (`join_guild` RPC / apply for invite-only).
- Bank: responsive tile grid, donate/withdraw, expand slots, material requests, bounties.
- Upgrades: roster-tier purchase, consumable guild buffs.
- Prestige: milestone spend, hub stages.
- Roster shows username + equipped Grimoire + combat level (PostgREST embed).
- Settings: tax vote, join-policy toggle (Open/Invite-Only), name-change vote (3-month cooldown), announcement, disband.

### Voting (as-built) — differs from spec
- **2/3 approval of the full roster** (`ceil(2/3 × member_count)`), not "majority of GM + Officers".
- Applied server-side by `cast_guild_vote` RPC (migration 015); one ballot per member.
- Passes and applies **immediately** on reaching threshold (no 48-hour delay). Open until threshold / all voted / 7 days.
- **Auto-close (built, migration 019):** `close_expired_guild_votes()` SQL function, run hourly by pg_cron, closes open votes once 7 days elapse OR all members have voted.

### Guild Merchant — as-built
- Members-only listings; fee = **half the guild tax**, credited to the guild bank on sale.
- **Dual-currency price:** a listing carries both `price_sm` AND `price_gm` (either may be 0) — a combined-marks price, e.g. "3 GM 500 SM". (Superseded the original single-SM design, then a brief SM/GM toggle.)
- Buying goes through the atomic `buy_guild_listing` RPC (migrations 016→018): charges the buyer both currencies, pays the seller minus the per-currency fee, credits the guild bank the fee, deletes the listing. Items escrow out of inventory on post, return on cancel.
- **Expiry sweep (built, migration 019):** `sweep_expired_merchant_listings()` SQL function, run hourly by pg_cron, returns escrowed items from listings past `expires_at` (7 days) into the seller's `player_inventory` (loaded on next session) and deletes the listing.

### Scheduled jobs (migration 019)
Implemented as SECURITY DEFINER SQL functions run by **pg_cron** (hourly), not Deno Edge Functions — both are pure DB ops. Requires enabling the `pg_cron` extension in the Supabase dashboard. Jobs: `close-expired-guild-votes`, `sweep-expired-merchant-listings`.

### Guild constants (as-built — do not re-derive from memory)
- **Create cost:** 2,000 GM. Name 3–30 chars. Join policies: `open`, `invite_only` only (no "Closed" yet). Default tax 2%.
- **Roster tiers** (cap → GM cost): 10→start, 20→5k, 30→15k, 45→35k, 60→75k, 80→150k, 100→300k (7 tiers).
- **Prestige milestones:** 1/5/10/20/35/50/75/100 → hub stages Campfire Gathering → Tent Camp → Encampment → Army Encampment → Fortress → Castle → Castle with Village → Stronghold Capital.
- **Consumable buffs** (5): Prospector's Fortune 3,000 (+15% rare, 24h) · Merchant's Window 2,000 (guild tax 0%, 24h) · Bountiful Harvest 2,500 (+20% gathering, 24h) · Hunter's Providence 3,500 (+25% SM/GM drops, 24h) · Lucky Charm 4,000 (+10% LCK, 12h).
- **Bank:** 50 slots base; Officers/GM expand +10 at a time from the bank.

### Reusable ItemListingComposer
`Assets/Scripts/UI/ItemListingComposer.cs` — a shared, domain-agnostic composer: searchable item
picker (live-filter over the ItemRegistry, held-qty per row) + quantity + optional dual SM/GM price +
optional note. Driven via `Open(title, confirmText, requireOwnership, showPrice, showNote, callback)`.
Currently backs guild merchant listings and material requests. **Intended reuse:** Wayfarer's Exchange
buy orders / sell orders / auctions (buy orders → `requireOwnership:false`, escrow currency instead of item).

## Combat progression — foundation BUILT (migration 009 + CombatXPManager)
- Tables `player_grimoire_levels` (per-Grimoire combat_level + combat_xp) and `player_stat_bonuses` (milestone-keyed permanent stat grants), both RLS-owner-only. Helper `total_combat_level(player_id)` sums per-Grimoire levels. `players.combat_level` (migration 013) caches the total for other players to read (guild roster).
- `CombatXPManager.cs`: loads both tables, creates rows for owned Grimoires, PATCHes level/XP on level-up, posts milestone stat bonuses, caches Total Combat Level, exposes `TotalCombatLevel`. `CombatTabUI` displays it.
- **Zone gating logic BUILT:** `ZoneAccess.cs` is the single source of truth for the tier→level thresholds (T1≥1 · T2≥21 · T3≥51 · T4≥91 · T5≥141), with a per-zone `combatTalentLevelRequired` override. `CombatManager.EnterZone(zone)` now returns `bool` and refuses locked zones. `ZoneData` carries `tier` + `combatTalentLevelRequired`.
- **Combat hub BUILT (`CombatHubUI.cs`):** nav → Combat shows large Zone/Dungeon **tiles** — art placeholder (`ZoneData.icon`, null → colour box), title + tier, lock state via `ZoneAccess`, and per-zone **enemy roster with spawn rate** (`EnemyData.spawnWeight` share; elites/boss tagged). Tapping an unlocked tile calls `CombatManager.EnterZone`. Raids = Phase-4 placeholder. `BuildCombatTabUI` auto-fills tiles from every `ZoneData` asset.
- **Design hooks pending spec:** (1) the actual in-zone **combat loop** (spawn → resolve → loot → repeat; elite ~5–8%, boss ~1/20 active-only) — `EnterZone` is still a stub. (2) **Spawn-rate buff bonus** — `CombatHubUI.SpawnBonusPercent()` returns 0; needs the combat spec to define which buffs modify spawn. (3) `ZoneData.icon` / `EnemyData.icon` are placeholder slots for the later sprite pass.

## Other notable as-built facts
- Inventory, gathering→live-inventory, talent tiles with live XP, Combat Tab under Character, Exchange lock gate: built.
- Auth: Supabase Auth (JWT) wired into the core loop; RLS on all tables; guild RLS recursion avoided via SECURITY DEFINER helpers `auth_guild_ids()` / `auth_officer_guild_ids()`.

## Do-not-build (still in force)
Raids, dungeon room puzzles, faction system, Bloodweaver/Warlock/Kensei/Beastbond (DLC), guild bounties (post-launch), Divination talent, Legendary tier, Black Ledger.
