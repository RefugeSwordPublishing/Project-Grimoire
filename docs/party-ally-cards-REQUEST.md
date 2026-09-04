# Party Ally Cards + Live Member-State Sync, Design Request
### Small ally cards on the combat screen (name / class / HP / debuffs, tap to inspect gear), and the server sync that feeds them. Requesting Chat's spec.

---

Co-op is live in Project Grimoire (shared boss fights and shared dungeons), but during a fight a
player sees nothing about their partners. Dustin wants small **ally cards** on the combat screen: one
per other party member, showing their name, class, and HP, with debuffs on/above the card, and a tap
that opens that player's equipment and stats. The cards rest just above the player's own HP bar.

The hard part is not the cards, it is that **none of what the cards show is synced today.** This brief
asks Chat to design the member-state sync layer plus the card UI, raid-ready but without touching raid
combat (which stays deferred).

Read `implementation-status.md` first, then this brief. The as-built facts below are things Chat cannot
see in the private Unity code, they were mapped directly from it for this request.

## As-built facts (not visible to Chat)

- **Co-op is one table, `boss_lobby`, polled, no realtime.** It is a FIXED 3-SLOT party: `host_id`,
  `player_2_id`, `player_3_id` plus per-slot ready flags, and it serves BOTH boss fights and dungeons
  (`kind`, `dungeon_id`, `run_seed` were added later). `BossLobbyManager` holds the row (`LobbyRow`) and
  polls it every ~2s. There is NO websocket realtime anywhere in this game; everything is polling.
- **The only shared combat state is the ENEMY HP pool.** Boss: `boss_take_damage` RPC decrements
  `boss_lobby.boss_current_hp`. Dungeon: `dungeon_take_damage` + a `dungeon_encounter` table. Each client
  accrues local damage and flushes it every ~1s, then adopts the authoritative enemy HP back.
- **A player's own HP is never written to the server during combat.** `player_stats.current_hp/max_hp`
  exist but are persistent/idle HP, own-row RLS, not updated live in a fight.
- **Debuffs/status effects are entirely local.** `StatusEffect` (kind Dot/Hot/Buff/Debuff/Shield/Slow,
  id, label, magnitude, remaining, stacks) lives only in `CombatManager.PlayerStatuses` on each client.
  There is no server representation of combat status, and no way to read a partner's statuses.
- **Player data tables are own-row-only RLS** (`players`, `player_stats`, `player_equipment`,
  `player_inventory`). Cross-player reads must go through SECURITY DEFINER RPCs. The only ones that exist:
  `guild_roster` (returns `username, combat_level, grimoire_equipped` for guildmates, so CLASS/subclass IS
  derivable via `grimoire_equipped`), `lookup_player_by_username` ({id, username}), and friend search
  ({id, username, online}). There is NO endpoint to read another player's equipment or stats.
- **The lobby does not even store usernames.** They are fetched only for the invite picker; once someone
  is in a slot the lobby shows a role label ("Player 2"), not their name.
- **Combat HUD precedents to reuse (both already exist):** the ENEMY debuff row (built at runtime, up to 3
  icons with radial countdown timers, driven by an `OnEnemyStatusesChanged` event) is the exact pattern for
  ally-card debuffs; and the Summoner SEGMENTED HP bar (personal HP + one segment per construct on one bar)
  is the precedent for rendering multiple entities near the HP bar. The player's own HP bar is a wide bar
  low on the screen; ally cards would anchor just above it.

## Constraints

- **Polling only, no realtime.** Every value on a card refreshes on a poll. Dustin accepts stepping but
  wants HP to feel responsive because it can drop fast: target a **~250-300ms** refresh for member HP
  DURING active combat. This is ~7x the current 2s lobby poll and multiplies across up to 5 members, so the
  design MUST keep it cheap: one BATCHED read of all members' state per tick (not N reads), the fast poll
  only while a fight is active, and a back-off (or stop) when idle / out of combat / lobby of one. Name,
  class, and equipment are near-static and can refresh far less often than HP.
- **Raid-ready plumbing, raids deferred.** Dungeons cap at 3 players (2 ally cards); raids at 5 players
  (4 ally cards). Build the member-state model and the card container to scale to 5, but raid COMBAT stays
  on the project's "do not implement" list. The current `boss_lobby` is hard-capped at 3 slots, so scaling
  to 5 is part of this design (extra slots, or a normalized member table).
- **Security.** Anything exposing another player's state must be gated to "is a co-participant in the
  caller's current lobby," mirroring how `boss_take_damage` gates on `auth.uid() in (host_id, player_2_id,
  player_3_id)` and how `guild_roster` gates on shared guild membership.

## What to design

1. **Member-state model.** How each player publishes their live combat state so partners can read it.
   Recommended direction to evaluate: a normalized `lobby_member_state` table (one row per member per
   lobby: player_id, current_hp, max_hp, a serialized debuff list, and near-static name + class), which
   scales cleanly to 5 and lets everyone read the whole party in ONE query. Weigh it against widening
   `boss_lobby` with per-slot columns (simpler, but awkward past 3 and mixes static roster with fast-changing
   HP). Specify the schema, RLS, and the write path (each client writes its own row on the combat flush).

2. **The write + poll cadence.** Define exactly what is written how often and by whom: HP on the ~1s combat
   flush (or faster if it is cheap), debuffs on change, name/class once on join. Define the read: a single
   batched poll of all members at ~250-300ms during active combat, backing off when idle. Name the load
   budget (requests/sec per client at a 5-player raid) and keep it defensible on mobile + Supabase.

3. **Debuff sync.** How to serialize a member's `StatusEffect` list compactly (id, label, stacks, remaining)
   and how the card renders them, reusing the enemy-debuff-row pattern (icons + radial timers, cap the count
   shown). Decide whether shields/HoTs show or only debuff-like effects.

4. **Inspect on tap.** A new SECURITY DEFINER `inspect_player`-style RPC that returns a partner's equipment
   and stat summary, gated on shared-lobby participation. Define the payload (equipment JSON is already a
   `{gear:[],tools:[]}` blob per player; plus combat level, class, key stats) and the panel that shows it.

5. **The card UI.** Name + class + HP bar per card; debuffs on or above the card; tap to open the inspect
   panel. Up to 4 cards (raid) / 2 (dungeon), anchored above the player HP bar, built at runtime like the
   enemy debuff row. Specify empty/dead/disconnected states (a member at 0 HP, or one who left).

## What Chat should return

One spec: the member-state schema + RLS + write path, the cadence design (with the load budget), the debuff
serialization, the inspect RPC + payload, and the card UI layout/content/states. Flag clearly which parts are
new server work (migration + RPCs) versus client-only, so the build order is obvious. Keep raid plumbing in
(scale to 5) but do not design raid combat.

---

*Path: docs/party-ally-cards-REQUEST.md*
