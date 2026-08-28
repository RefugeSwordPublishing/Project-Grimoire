---
type: design-request
for: Chat (claude.ai design collaborator)
from: Claude Code
date: 2026-08-28
subject: Redesign chat into a single docked multi-channel panel (RuneScape / Idle Clans style), minimize-to-one-line, expand upward above the idle bar, with group filters and @username pings
read-first: docs/implementation-status.md, then docs/multiplayer-chat-spec.md (this AMENDS its UI decision)
---

# Request: docked multi-channel chat panel

## The vision (from the developer)

Move to a proper chat like Idle Clans / most MMOs / RuneScape: **all chats except DMs live in one panel**.
That panel **docks just above the active idle bar** and can be **minimized to a single line** or **expanded
upward**. Players can **filter / hide by group** (for example World, Guild, Private). **World chat is
full-server for now** (a single global room; we may shard it later). A **ping when someone types
`@username`** of some form.

This SUPERSEDES the "overlay pill + tabbed panel" UI decision in `multiplayer-chat-spec.md` section 3. The
data model, channels, RLS, and friend/block plan from that spec still stand; only the chat surface changes.

## Where we are (as-built, so design against this, not the old spec)

- **Transport is POLLING, not websocket realtime.** The multiplayer-chat-spec locked "Supabase realtime,"
  but the shipped chat polls (`ChatManager` polls the open channel every 3s; DM unread every 15s). Grimoire
  has no websocket client. **Design for polling.** A merged/multi-group feed means either polling several
  channels or one merged query on a short interval.
- **`ChatManager` opens ONE channel at a time.** `OpenChannel(type, ref)` starts a 3s poll of that channel;
  `CloseChannel` stops it. `fetch_chat_messages(type, ref, limit=50)` reads; a send RPC writes;
  `OnMessagesChanged` fires on refresh. A docked panel showing multiple groups at once needs ChatManager to
  track more than one open channel (or a unified fetch). Call this out as the main manager change.
- **`chat_messages`** has `channel_type` ('guild' | 'lobby' | 'dm' | 'general') + `channel_ref`
  (guild_id | boss_lobby_id | dm friendship_id | general shard). Per-type RLS read policies exist for
  guild / lobby / dm. **`general` is NOT built:** the read gate returns false ("general gate arrives later")
  and the spec deferred it to P4. This request UN-DEFERS a simple full-server general channel (see Backend).
- **`ChatPanelUI`** is the current single-channel window (guild, or a DM opened from friends, or lobby via
  `OpenChannelView`). It already **lifts the input row above the mobile keyboard** (reuse this). Messages
  render from a `_rowPrefab` into a scroll list; own vs other messages are colour-coded.
- **`ChatPill`** is the current HUD entry point with an unread badge (`DmUnreadTotal` etc.). The docked panel
  likely replaces or absorbs the pill; say what happens to it.
- **`ChatManager` unread** already tracks per-DM unread + a total (drives the pill badge). Reusable for
  per-group unread counts on the new panel's filter chips.
- **`ActiveIdleBarUI`** is the idle bar the panel should dock ABOVE. The panel expands upward from there.
- Lobby chat is bound to a `boss_lobby.id` and opened from the pre-boss/dungeon lobby (`OpenChannelView
  "lobby"`). Decide whether lobby chat appears as a group in the docked panel while in a lobby, or stays a
  lobby-only view.

## The hard UI rule

All UI is authored/skinned in the Unity EDITOR via bakers: an editor tool builds skinnable
templates/elements into the scene, and runtime is populate-only (clone a template, set data). Every screen
in your design must be expressible as baked, skinnable elements. Call out each NEW baked template/panel and
the child element names the runtime will fill, so a baker can build it. Reuse `ChatPanelUI`'s row prefab and
keyboard-lift where you can.

## What to design

### 1. The docked panel and its states

- **Docked position:** anchored just above `ActiveIdleBarUI`, full width (or near). Specify the minimized
  and expanded layouts for mobile portrait (reference device: Samsung Galaxy S10e).
- **Minimized = single line:** what that one line shows (latest message across the active filter? a tap-to-
  expand affordance? unread indicator?).
- **Expanded = grows upward:** how tall, how it scrolls, how it coexists with the game screen behind it
  (does it dim/overlay, or push content?), and how the input row + keyboard-lift behave when expanded.
- The **expand / minimize control** and any drag/tap gesture.

### 2. Groups and filtering

- The groups: **World** (full-server general), **Guild**, and **Private** (PMs), plus **Lobby** when in one.
  Decide whether the feed is a **single merged stream with per-group colour/prefix** and filter chips that
  hide/show groups (RuneScape-style), or **tabs**, or a hybrid. Recommend one and say why for an idle game on
  mobile.
- **Filter chips** to hide/show each group, with per-group **unread counts**.
- **DMs are the ambiguous bit** the developer flagged: they said "all chats minus DMs in one panel," but also
  listed Private as a filter group. Resolve this: e.g. incoming PMs surface **inline in the panel under a
  Private filter** (so you see them), while **composing / a full 1:1 thread stays a separate view** opened
  from the friends list (today's `OpenDm`). Specify exactly what lives where.

### 3. World / general chat

- A single global room for now (full server). Design the room identity (one fixed `channel_ref`, e.g.
  "global") and note it may shard later (per-region/per-shard `channel_ref`) without a client rewrite.
- **Moderation is deferred** but say what minimal guardrails ship (length cap, rate limit, block-list
  respect using the existing `blocks` table from the spec, maybe a client mute).

### 4. @username ping

- Define the mechanism: detect `@name` in a message, **highlight** the mention in the feed, and **notify** the
  mentioned player (a badge/toast in-app; an optional push via the existing FCM path if they're away). Say how
  a name resolves (username lookup) and what happens on a miss. Keep it pollable (no realtime).

## Constraints

- **Polling, not realtime.** Reuse `ChatManager` / `fetch_chat_messages` / the send RPC and the unread polls.
- **Baked/skinnable, mobile portrait, one-handed.** Reuse the row prefab + keyboard-lift.
- **Reuse over rebuild.** Guild/dm/lobby channels, RLS, unread tracking, and the friend/block model all exist
  or are spec'd. Flag anything genuinely new (the `general` channel + RLS, a multi-channel ChatManager, the
  ping path, new baked templates).
- Writing style: no em dashes, en dashes, or "--" as prose punctuation; no emojis (this becomes UI copy and
  code comments).

## Deliverable

A spec I can implement in stages, with:
- The docked panel layout (minimized + expanded) and its dock/position above the idle bar.
- The group model (merged vs tabs) + filter chips + per-group unread.
- Where DMs live (inline Private group vs separate thread view) and how a PM is composed.
- The `general` channel: `channel_ref` scheme, RLS (any authed user read/write), and the minimal guardrails.
- The `@username` ping: detection, highlight, notification, name resolution.
- A **baker/asset checklist**: which existing pieces are reused (ChatPanelUI row prefab, keyboard-lift,
  ChatManager, ChatPill), which NEW baked templates/panels the developer must have a baker build (with child
  element names), and the ChatManager changes to hold multiple groups at once.

Point out anything about the current flow you think is wrong beyond what is listed here (for example whether
the pill should stay for unread-while-collapsed, or whether a merged stream will get too noisy with World on).
