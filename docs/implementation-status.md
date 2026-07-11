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
- **Not yet built:** scheduled Edge Function to auto-close votes at 7 days below threshold.

### Guild Merchant — as-built
- Members-only listings; fee = **half the guild tax**, credited to the guild bank on sale.
- **Dual-currency price:** a listing carries both `price_sm` AND `price_gm` (either may be 0) — a combined-marks price, e.g. "3 GM 500 SM". (Superseded the original single-SM design, then a brief SM/GM toggle.)
- Buying goes through the atomic `buy_guild_listing` RPC (migrations 016→018): charges the buyer both currencies, pays the seller minus the per-currency fee, credits the guild bank the fee, deletes the listing. Items escrow out of inventory on post, return on cancel.
- **Not yet built:** scheduled Edge Function to sweep listings past `expires_at` (7 days) and return escrowed items.

### Reusable ItemListingComposer
`Assets/Scripts/UI/ItemListingComposer.cs` — a shared, domain-agnostic composer: searchable item
picker (live-filter over the ItemRegistry, held-qty per row) + quantity + optional dual SM/GM price +
optional note. Driven via `Open(title, confirmText, requireOwnership, showPrice, showNote, callback)`.
Currently backs guild merchant listings and material requests. **Intended reuse:** Wayfarer's Exchange
buy orders / sell orders / auctions (buy orders → `requireOwnership:false`, escrow currency instead of item).

## Other notable as-built facts
- Inventory, gathering→live-inventory, talent tiles with live XP, Combat Tab under Character, Exchange lock gate: built.
- Auth: Supabase Auth (JWT) wired into the core loop; RLS on all tables; guild RLS recursion avoided via SECURITY DEFINER helpers `auth_guild_ids()` / `auth_officer_guild_ids()`.

## Do-not-build (still in force)
Raids, dungeon room puzzles, faction system, Bloodweaver/Warlock/Kensei/Beastbond (DLC), guild bounties (post-launch), Divination talent, Legendary tier, Black Ledger.
