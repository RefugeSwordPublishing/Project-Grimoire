---
type: design-spec
updated: 2026-08-17
status: DESIGN (not built)
purpose: Multiplayer chat + friend system. Architecture, data model, phasing, UI.
audience: Claude (Chat or Code). Read implementation-status.md first for what already exists.
---

# Project Grimoire, Multiplayer Chat + Friend System Spec

Design for in-game social chat: friend chat (DMs), guild chat, lobby chat (boss/dungeon/raid),
and a deferred general chat. Plus the friend system that friend chat and blocking depend on.

This is a design spec, nothing here is built yet. It is grounded in the existing multiplayer
plumbing (boss lobby, guild RLS, FCM) so it reuses rather than reinvents.

> **AMENDED by `chat-dock-panel-spec.md` v1.0 (2026-08-28).** Three of the locked decisions below no
> longer hold; the data model, channel types, RLS shape, friend graph, and block model still stand.
> 1. **Transport is POLLING, not websocket realtime.** The shipped chat polls (ChatManager, 3s), which
>    is what the dock spec designs for. Decision 1 below is retired.
> 2. **General (World) chat is UN-DEFERRED.** It ships as a single full-server room in the dock spec's
>    Stage 2, not P4. Decision 2 below is superseded.
> 3. **UI is a single docked multi-channel panel**, not the overlay pill + tabbed panel. Decision 3 is
>    superseded by the dock spec.

---

## Decisions locked (2026-08-17 scoping)

1. **Transport: Supabase realtime (websocket), not polling.** This is a deliberate departure from
   the rest of the codebase, which polls (BossLobbyManager polls its row every 2s; guild voting
   polls). The realtime DB publication already exists in SQL (migration 027 added `boss_lobby` to
   `supabase_realtime`) but no client has ever subscribed. Chat is the feature that most benefits
   from live delivery, so it gets the first real websocket client. See "Realtime risk" below, this
   is the first technical task, de-risk it before building on it.
2. **General chat: deferred to post-launch.** Highest scale + moderation cost, lowest core value
   for an idle RPG. Friends / guild / lobby cover the social core. General chat is P4, spec'd but
   not built at launch.
3. **UI: overlay pill + tabbed panel.** A small docked unread pill that overlays the HUD (never
   reflows it) and taps open into a larger tabbed panel. Rejected: a persistent chat bar under the
   HP bar that shifts the combat HUD up (eats scarce portrait combat space).

---

## What already exists (reuse, do not rebuild)

| Asset | Where | Reused for |
|-------|-------|-----------|
| Guild membership RLS helper `auth_guild_ids()` | migration 010 | Guild-chat channel gate |
| Lobby participant RLS (host/p2/p3 on the row) | migration 027 `boss_lobby` | Lobby-chat channel gate |
| Realtime publication `supabase_realtime` | migration 027 | Chat realtime (extend to chat tables) |
| FCM push (`FCMManager`) + `notification_log` | migration 006 | DM push when backgrounded (own limits) |
| Guild online-roster / guest discovery | task, boss lobby | Presence pattern for friend online status |

**No friend system exists.** `player_friendships` / `player_blocks` are net-new and are a hard
prerequisite for friend DMs and for blocking.

**FCM throttle caveat:** `notification_log` enforces a 30-min cooldown + 3-per-4h cap. That is for
"a boss spawned" nudges and is unusable for chat. DM push needs its own dispatch path with its own
(looser, per-conversation-debounced) limits, or chat stays in-app only when backgrounded.

---

## Realtime risk (the first technical task in P1)

The Unity client talks to Supabase through a thin `Sb.Post`/REST wrapper (`BackendManager`), not the
full supabase-csharp SDK, and has never held a live websocket. Before any chat feature depends on it:

- Stand up a `RealtimeManager`: connect to the Supabase realtime socket, subscribe to
  `postgres_changes` (INSERT) on `chat_messages` filtered by `channel_ref`, surface a C# event.
- Prove mobile lifecycle handling: **unsubscribe on background, reconnect + backfill on foreground.**
  Websockets die when Android suspends the app; the client must reconnect and fetch messages since
  `last_read_at` (REST) to fill the gap, then resume live.
- Reconnect/backoff on drop. Battery: one socket, subscribe only to the channels the player is a
  member of (small: 1 guild + 0-1 active lobby + N open DM threads, general deferred).
- **Fallback:** if realtime proves unreliable on-device, the same data model works with the existing
  poll pattern (open channel polls, unread-counts RPC for the rest). Keep the message read/write API
  transport-agnostic so this swap is possible without a schema change.

Backgrounded DM delivery is FCM, not the socket.

---

## Data model (new tables, all RLS-on at creation)

```sql
-- One row per message across every channel type. channel_ref points at the owning entity.
chat_messages (
  id           uuid pk default gen_random_uuid(),
  channel_type text not null,            -- 'guild' | 'lobby' | 'dm' | 'general'
  channel_ref  text not null,            -- guild_id | boss_lobby_id | dm_thread_ref | general_shard
  sender_id    uuid not null references players(id) on delete cascade,
  body         text not null,            -- length-capped (e.g. <= 500 chars) via check + client
  created_at   timestamptz not null default now()
)
-- index (channel_type, channel_ref, created_at desc) for history + realtime filter

-- Per-player per-channel read cursor. Drives unread counts and reconnect backfill.
chat_read_state (
  player_id    uuid not null references players(id) on delete cascade,
  channel_type text not null,
  channel_ref  text not null,
  last_read_at timestamptz not null default now(),
  primary key (player_id, channel_type, channel_ref)
)

-- Friend graph. One row per relationship; status drives requests.
player_friendships (
  id           uuid pk default gen_random_uuid(),
  requester_id uuid not null references players(id) on delete cascade,
  addressee_id uuid not null references players(id) on delete cascade,
  status       text not null default 'pending',  -- 'pending' | 'accepted' | 'declined'
  created_at   timestamptz not null default now(),
  responded_at timestamptz,
  unique (requester_id, addressee_id)
)
-- DM thread identity: dm_thread_ref = the accepted friendship's id. DMs are friend-gated.

-- Block list. Enforced on DM insert and message read.
player_blocks (
  blocker_id uuid not null references players(id) on delete cascade,
  blocked_id uuid not null references players(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (blocker_id, blocked_id)
)

-- Presence: last_seen heartbeat for online status. A column on players is enough; the client
-- already makes periodic calls to bump it (no dedicated poll loop needed).
--   players.last_seen timestamptz  -> "online" if now() - last_seen < ~90s
```

**RLS per channel type (read + insert):**
- `guild`: `channel_ref::uuid in (select auth_guild_ids())`
- `lobby`: `auth.uid()` is a participant of the `boss_lobby` row `channel_ref` (join or `SECURITY
  DEFINER` helper `auth_lobby_ids()`, same shape as the guild helper, avoids recursion)
- `dm`: `auth.uid()` is a participant of the friendship `channel_ref` AND no `player_blocks` row
  exists either direction
- `general`: authenticated (deferred; when built, shard `channel_ref` by region/zone-tier)

**Unread counts:** one RPC `chat_unread_counts()` returns, per channel the caller belongs to,
`count(*) where created_at > last_read_at`. Cheap, and with realtime it is only needed on
foreground/reconnect, live inserts increment the badge client-side thereafter.

---

## Moderation (required before strangers can message)

Not optional the moment lobby/general/DM reaches non-friends:
- **Block** (`player_blocks`): hides their messages, forbids their DMs. Ships with the friend system.
- **Report** (`chat_reports` table: reporter, target, message_id, reason, created_at). Service-role
  review queue; no live human moderation at launch, just capture.
- **Mute** (client-side per-channel toggle, plus a server mute flag for offenders later).
- **Rate limit** (server-side in the send RPC: max N messages / 10s per player) + **length cap**
  (check constraint + client). Profanity filter: client wordlist at minimum, server-side deferred.

---

## UI: overlay pill + tabbed panel

- **ChatPill:** small docked element with an unread badge, overlays the HUD, never reflows it.
  During active combat/dungeon it collapses to just the pill so it never competes with the fight.
- **ChatPanel:** taps open from the pill. Tabs: **Friends / Guild / Lobby** (General tab hidden until
  P4). Per-tab **mute** toggle. Unread badge per tab.
  - Friends tab: friend list with online status, incoming/outgoing requests, tap a friend to open
    their DM thread.
  - Guild tab: the player's guild channel (empty state if guildless).
  - Lobby tab: only present while in a boss/dungeon lobby; auto-selected on entry.
- **Focus mode:** a global toggle (and an auto-trigger during boss/dungeon) that suppresses chat
  popups and badge pulses so players are not spammed. Muted channels do not push or increment.
- **Editable at edit-time (standing rule):** pill + panel + tab + message-row are authored as an
  editable prefab/overlay in the Unity editor and populated at runtime, never imposed purely by code.

---

## Phasing

| Phase | Scope | Depends on |
|-------|-------|-----------|
| **P0** | Friend + block + presence: `player_friendships`, `player_blocks`, `players.last_seen`, request/accept/decline flow, friend list UI | none |
| **P1** | Chat core + Guild chat: `chat_messages`, `chat_read_state`, `RealtimeManager` (de-risk first), unread RPC, guild channel, pill + panel shell | realtime task |
| **P2** | Lobby chat: `channel_ref = boss_lobby.id`, `auth_lobby_ids()` RLS, auto-create/tear-down with lobby, Lobby tab | P1 |
| **P3** | Friend DMs: dm channel (friendship-gated), block enforcement, FCM push path for backgrounded delivery | P0, P1 |
| **P4** | General chat (deferred, post-launch): sharded channel_ref, rate limits, capped history, full moderation | P1, moderation |

Guild chat is the first live channel because its audience is bounded, its RLS already exists, and
its moderation risk is low. General chat is last because it is the opposite on all three.

---

## Open questions for a build session

- Presence granularity: simple online/offline via `last_seen`, or also "in combat / in dungeon /
  idle" status shown to friends?
- DM gating: friend-only (this spec), or also allow DMing a recent lobby co-op partner?
- History retention: keep guild/general history forever, or trim to last N / last 30 days to bound
  the table?
- FCM DM push: per-message, or debounced to "you have unread messages from X" to respect battery
  and the spirit of the notification caps?
