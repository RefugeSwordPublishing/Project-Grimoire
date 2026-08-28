---
type: design-spec
version: 1.0
updated: 2026-08-28
path: docs/chat-dock-panel-spec.md
resolves: chat-dock-panel-REQUEST.md
amends: multiplayer-chat-spec.md section "UI: overlay pill + tabbed panel", superseded
        multiplayer-chat-spec.md decision 1 (realtime), corrected to polling
        multiplayer-chat-spec.md decision 2 (general deferred), un-deferred
implements: ChatDockUI, ChatManager multi-channel, fetch_chat_feed RPC,
            general channel RLS, chat_mentions
---

# Docked Multi-Channel Chat Panel
### Version 1.0

---

## 1. What This Replaces

`multiplayer-chat-spec.md` locked three things that no longer hold. Its data model,
channel types, RLS shape, friend graph, and block model all stand unchanged.

| Old decision | Status | Replacement |
|---|---|---|
| Overlay pill plus tabbed panel | Superseded | Single docked panel, merged feed, filter chips |
| Supabase realtime websocket | Already wrong in practice | Polling, as shipped |
| General chat deferred to P4 | Un-deferred | World channel ships in Stage 2 |

`ChatPill` is absorbed rather than kept. The dock's minimized line is always on screen,
so a separate unread pill would be a second badge for the same information sitting a
centimetre away from the first.

---

## 2. Stage Plan

| Stage | Scope | Depends on | Ships without |
|---|---|---|---|
| 1 | Dock shell, merged feed, filter chips, multi-channel ChatManager, pill removal | nothing | World, pings |
| 2 | World channel, general RLS, rate limit, guardrails | Stage 1 | pings |
| 3 | @username pings: detect, resolve, highlight, badge, toast | Stage 1 | push |
| 4 | Polish: FCM for mentions and DMs when backgrounded, per-group mute, resize handle | Stages 1 to 3 | |

Stage 1 is the whole UI change and works with the channels that already exist. Stage 2
is mostly backend. Do not ship Stage 2 without the rate limit in section 6.3.

---

## 3. The Dock

Anchored directly above `ActiveIdleBarUI`, full width. Two states.

### 3.1 Minimized, one line

```
┌─────────────────────────────────────────┐
│                                         │
│        (game screen, untouched)         │
│                                         │
├─────────────────────────────────────────┤
│ [G] Dustin: got the drake scale fin...(3)│
├─────────────────────────────────────────┤
│ [        ACTIVE IDLE BAR        ]       │
└─────────────────────────────────────────┘
```

The line shows the most recent message across currently visible groups: a one-letter
group tag, sender name, body truncated to fit, and a total unread count on the right.

Tap anywhere on the line to expand. This line is the entire HUD footprint of chat when
collapsed, which is why the pill is redundant.

When no message has ever arrived, the line reads "Tap to open chat" so the affordance is
not invisible on a fresh account.

### 3.2 Expanded, grows upward

```
┌─────────────────────────────────────────┐
│        (game screen, still visible)     │
├─────────────────────────────────────────┤
│ [World 3][Guild][Private 2][Lobby]  [v] │
│ ─────────────────────────────────────── │
│ [W] Kaelen: anyone selling mithril bars │
│ [G] Dustin: got the drake scale finally │
│ [P] Mirra: want to run the warren?      │
│ [W] Toft: @Dustin nice pull             │
│ [G] Aldric: grats                       │
│                                         │
│ ─────────────────────────────────────── │
│ [ Replying to Mirra                 x ] │
│ [ Type a message              ] [ Send ]│
├─────────────────────────────────────────┤
│ [        ACTIVE IDLE BAR        ]       │
└─────────────────────────────────────────┘
```

**Height.** Fixed at roughly 45 percent of viewport height. Enough for five to seven
messages plus chips and input on an S10e, and it leaves the top half of the screen for
the game.

**Overlay, no dim, no push.** The panel sits on top of the game screen. It does not
reflow the HUD and it does not dim what is behind it. This is an idle game and the
player opening chat is often watching a gather or a fight continue at the same time.
Dimming the thing they are watching to read a line of text is the wrong trade.

**Scrolling.** Newest at the bottom, auto-scrolled to bottom on open and on new message,
unless the player has scrolled up, in which case a "new messages" affordance appears at
the bottom edge and tapping it jumps down. Standard, and it stops the feed yanking under
someone's thumb while they read back.

**Collapse control.** The chevron at the right end of the chip row. Tapping the minimized
line expands, tapping the chevron collapses. A downward swipe on the message area also
collapses, as a secondary gesture, not the only one.

### 3.3 Keyboard

Reuse `ChatPanelUI`'s existing keyboard-lift. When the input takes focus, the dock lifts
above the keyboard and the message list shrinks rather than the panel growing. The chip
row stays visible so the player can still see which groups they are writing into.

### 3.4 Auto-minimize during combat and dungeons

The dock minimizes automatically on entering a zone fight or a dungeon run, and stays
minimized until the player expands it. It does not hide entirely, because lobby
coordination happens in chat and hiding it during the exact activity that needs it would
be backwards. One line is a small enough footprint to leave up.

---

## 4. Group Model, Merged Feed With Filter Chips

**Recommendation: one merged stream, per-group colour and tag, filter chips that hide and
show groups.** Not tabs. Not a hybrid.

Three reasons, in order of weight:

**Polling makes the choice for us.** Tabs mean either polling every channel anyway (so
the tabs bought nothing) or lazy-loading a tab on selection (so every tab switch has
visible latency on a 3 second poll). A merged feed is one query on one interval.

**An idle player checks in briefly.** The session shape is open the app, glance, act,
close. A merged feed answers "did anything happen" in one glance. Tabs require the
player to check three places to answer the same question.

**Tabs hide activity, chips reveal it.** A chip with an unread count communicates the
same information as a tab badge while also showing the player what they are currently
filtering out, which is the thing they need to know when the feed looks quiet.

### 4.1 The groups

| Group | Tag | Channel | Present when |
|---|---|---|---|
| World | W | `general` / `global` | Always, from Stage 2 |
| Guild | G | `guild` / guild_id | Player is in a guild |
| Private | P | `dm` / friendship_id, all threads | Always |
| Lobby | L | `lobby` / boss_lobby_id | Player is in a lobby |

Lobby appears as a chip when the player enters a lobby, auto-enabled, and its chip is
removed when they leave. It is not a separate view. This answers the open question in
the brief: lobby chat joins the dock rather than staying lobby-only, because a player in
a lobby still wants to see their guild.

### 4.2 Filter chips

Each chip toggles its group's visibility in the merged feed. Chip carries the group name
and an unread count when there is one. A hidden group's chip stays visible and keeps
counting, so hiding World does not mean losing track of it.

Filter state persists per player in local prefs. It is a display preference, not
server state.

**World defaults on, panel defaults minimized.** A new player sees the game is inhabited
without chat taking screen space. If World proves noisy, one tap hides it. The
alternative, defaulting World off, protects the screen but means most players never
discover that chat exists. See section 9.1 for the risk.

### 4.3 Per-group unread

Reuse `chat_read_state` as specced. Unread per group is `count(*) where created_at >
last_read_at` for that group's channels. `Private` sums across all DM threads, which is
what `ChatManager`'s existing `DmUnreadTotal` already computes.

A group's unread clears when it is visible in the expanded panel and the player has
scrolled to the bottom. Not on expand alone, or a player who opens the dock to read
Guild silently marks World as read.

---

## 5. Where DMs Live

The brief flags this as ambiguous. Resolving it explicitly.

**Reading: inline, in the merged feed, under Private.** Incoming PMs appear as feed lines
tagged P with the sender's name. The player sees them without leaving the dock, which is
what the "Private is a filter group" half of the vision asks for.

**Composing a new DM: the thread view, opened from the friends list.** Today's `OpenDm`
path, unchanged. Starting a conversation with someone requires picking them, and the
friends list is where people are pickable. This is the "all chats minus DMs in one
panel" half.

**Replying: inline, via a reply target.** Tapping a P line in the feed sets a reply pill
above the input reading "Replying to Mirra" with a dismiss control. While the pill is
set, Send goes to that DM thread instead of the default target. Tapping the dismiss
clears it.

This is the piece that makes both halves of the vision true at once. The player can read
and answer a PM without leaving the dock, and they can never accidentally broadcast a
private reply to World, because the pill makes the destination explicit and visible
directly above the text they are typing.

**Default send target when no reply pill is set.** The most recently active non-Private
group the player has visible, preferring Lobby, then Guild, then World. The current
target is shown as a label inside the input placeholder ("Message Guild") so it is never
ambiguous. Tapping the label cycles through available groups.

**Tapping a P line also offers the full thread.** Long-press or a small affordance on the
line opens the 1:1 thread view for history. Inline is for the last few messages, the
thread view is for the conversation.

---

## 6. World Channel

### 6.1 Identity

`channel_type = 'general'`, `channel_ref = 'global'`. One fixed room, full server.

The client never hardcodes the string. `ChatManager.WorldChannelRef` returns it. When
sharding arrives, that property becomes a lookup against player region or shard
assignment and no calling code changes. That is the entire forward-compatibility cost,
and it is worth paying now.

### 6.2 RLS

The current gate returns false. Replace with:

```sql
-- read
create policy "general read" on chat_messages for select
  using (channel_type = 'general' and auth.role() = 'authenticated');

-- insert
create policy "general insert" on chat_messages for insert
  with check (
    channel_type = 'general'
    and auth.role() = 'authenticated'
    and sender_id = auth.uid()
  );
```

Block enforcement on World is client-side filtering against the player's `player_blocks`
rows, not an RLS join. A server-side block join on a global room is a per-row subquery on
the hottest table in the schema. Client-side filtering costs a blocked player's messages
being fetched and discarded, which is cheap, and the outcome the player sees is identical.

### 6.3 Guardrails, all required before World ships

| Guardrail | Where | Value |
|---|---|---|
| Length cap | Check constraint plus client | 500 chars, already in schema |
| Rate limit | Send RPC, server-side | 5 messages per 10 seconds per player |
| Block respect | Client filter on read | Existing `player_blocks` |
| Client mute | Local pref | Per-group toggle, Stage 4 |
| Profanity | Client wordlist | Minimum viable, server-side deferred |
| History cap | Fetch limit | 50 messages, World only |
| Report capture | `chat_reports` | Long-press a line, captures, no live review |

The rate limit is not optional and not a Stage 4 polish item. A global room with no
server-side rate limit is a spam vector on day one, and it must live in the send RPC
where a modified client cannot skip it.

---

## 7. @username Pings

### 7.1 Detection and resolution

Client regex on send: `@([A-Za-z0-9_]{3,16})`. Extract candidates, resolve in one call:

```sql
create or replace function resolve_usernames(names text[])
returns table (username text, player_id uuid)
language sql stable as $$
  select username, id from players where username = any(names);
$$;
```

Resolved mentions are written alongside the message:

```sql
create table chat_mentions (
  message_id          uuid not null references chat_messages(id) on delete cascade,
  mentioned_player_id uuid not null references players(id) on delete cascade,
  created_at          timestamptz not null default now(),
  primary key (message_id, mentioned_player_id)
);
create index chat_mentions_player_idx on chat_mentions (mentioned_player_id, created_at desc);
```

**On a miss, do nothing.** An unresolved `@name` renders as plain text, sends normally,
and produces no error. Blocking or warning on a typo would make people stop using the
feature, and a name that does not resolve is indistinguishable from someone writing an
email address.

### 7.2 Highlight

The client re-scans message bodies on render and highlights any `@name` that appears in
that message's mention set. A mention of the local player gets a stronger treatment than
a mention of someone else, so a player scanning the feed finds their own name first.

Highlight styling is a skinned property on the row template, not a runtime colour.

### 7.3 Notification

Poll-friendly by design. The existing unread poll gains a mention count:

```sql
-- extend chat_unread_counts, or add:
create or replace function chat_mention_count(since timestamptz)
returns int language sql stable as $$
  select count(*) from chat_mentions m
  join chat_messages c on c.id = m.message_id
  where m.mentioned_player_id = auth.uid() and c.created_at > since;
$$;
```

In-app: a distinct pip on the dock's minimized line, visually different from the plain
unread count, plus a one-shot toast naming who mentioned you. Tapping the toast expands
the dock scrolled to that message.

Backgrounded: FCM, Stage 4, using the separate dispatch path the old spec already
identified for DMs. Not `notification_log`, whose 30 minute cooldown and 3-per-4-hour cap
would swallow mentions entirely.

**Mentions ignore group filters.** If someone @-mentions you in World while you have
World hidden, you still get the pip and the toast. A filter is a display preference, not
a request to be unreachable. Blocks still apply.

---

## 8. ChatManager Changes

This is the main code change and the one to scope first.

### 8.1 Multiple open channels

Today: `OpenChannel(type, ref)` starts a 3 second poll of one channel, `CloseChannel`
stops it.

Needed: a dock subscription set.

```csharp
public struct ChatSubscription { public string type; public string reference; }

// Replaces the single-channel open for the dock's use.
// Existing OpenChannel stays for the 1:1 DM thread view.
public void OpenDock(IReadOnlyList<ChatSubscription> subs);
public void SetDockExpanded(bool expanded);   // drives the poll interval
public event Action OnFeedChanged;
```

The dock rebuilds its subscription set when the player joins or leaves a guild or a
lobby. `ChatPanelUI`'s existing single-channel `OpenChannel` is untouched and still
serves the DM thread view.

### 8.2 One merged fetch, not N

```sql
create or replace function fetch_chat_feed(
  channels jsonb,          -- [{"type":"guild","ref":"..."}, ...]
  since    timestamptz,
  lim      int default 100
)
returns setof chat_messages
language sql stable as $$
  select c.* from chat_messages c
  join lateral jsonb_array_elements(channels) ch on true
  where c.channel_type = ch->>'type'
    and c.channel_ref  = ch->>'ref'
    and c.created_at   > since
  order by c.created_at desc
  limit lim;
$$;
```

RLS still applies per row, so a client asking for a channel it does not belong to simply
gets nothing back rather than an error. One round trip per poll regardless of how many
groups are open.

### 8.3 Poll interval by state

| Dock state | Interval |
|---|---|
| Expanded | 3 seconds |
| Minimized | 10 seconds |
| App backgrounded | Stopped |

An idle game spends most of its foreground time with the dock minimized. Polling a global
room every 3 seconds for a panel showing one truncated line is wasted battery and wasted
server load, and 10 seconds is imperceptible on a line the player is not reading.

---

## 9. Things I Think Are Wrong Or Risky

**9.1 A merged feed with World on will get noisy, and that is the real risk in this
design.** Guild and lobby traffic is bounded by group size. World is bounded by the
player base. At any meaningful scale, World will dominate a merged feed and push guild
messages off screen, which is the opposite of what matters to the player.

Mitigations in this spec: World defaults on but the panel defaults minimized, World has
its own smaller fetch limit, and the chip makes hiding it one tap. What is deliberately
not in this spec is auto-hiding World above a message rate threshold, because a chat that
silently turns itself off is worse than a noisy one.

Watch the first week of World traffic. If guild messages are getting buried, the next
lever is a separate smaller reserved area for World rather than tabs.

**9.2 The pill should not survive.** Two unread badges a centimetre apart, one on a pill
and one on the dock line, is a bug that ships looking like a feature. Delete `ChatPill`
and move its badge logic to the dock line.

**9.3 Unread clearing on expand alone is wrong.** If expanding the dock marks everything
read, a player who opens it to check Guild loses their World and Private counts without
reading them. Clear per group, on visible plus scrolled to bottom.

**9.4 The default send target needs to be visible at all times.** The single most likely
serious user error in a merged feed is typing a private thing into World. The input
placeholder naming the current target ("Message Guild") and the reply pill for DMs are
both there for this reason. Do not let the input ever be ambiguous about destination.

**9.5 The old spec's realtime decision should be formally retired in that document.**
Right now `multiplayer-chat-spec.md` says websocket, the code polls, and this spec says
polling. Two out of three is not enough. Edit that file's decision 1 rather than leaving
a contradiction for whoever reads it next.

**9.6 History retention is still an open question and World makes it urgent.** Guild
history growing forever is fine. A global room's history growing forever is not. Trim
World to the last 7 days or the last N thousand rows in a scheduled job before Stage 2
ships, or pick the retention now and note it.

---

## 10. Baker And Asset Checklist

### 10.1 Reused, no baker work

| Piece | Reused for |
|---|---|
| `ChatPanelUI` row prefab | Feed message rows, extended with a group tag child |
| `ChatPanelUI` keyboard-lift | Dock input focus behaviour |
| `ChatPanelUI` full view | DM thread view, unchanged |
| `ChatManager` unread tracking | Per-group chip counts |
| `chat_read_state` | Per-group unread cursors |
| `player_blocks` | Client-side World filtering |

### 10.2 New baked templates

Runtime clones and fills data only. Child names below are what the runtime looks for.

**1. `ChatDockRoot`** (one instance, anchored above `ActiveIdleBarUI`)
```
MinimizedRoot     (GameObject)   shown when collapsed
  GroupTag        (Text)         "G"
  Preview         (Text)         "Dustin: got the drake scale fin..."
  UnreadCount     (Text)         "(3)"
  MentionPip      (GameObject)   toggled, distinct from UnreadCount
ExpandedRoot      (GameObject)   shown when expanded
  ChipContainer   (Transform)    parent for ChatGroupChip clones
  CollapseButton  (Button)
  MessageList     (ScrollRect)
  MessageContent  (Transform)    parent for row clones
  NewMessagesJump (GameObject)   toggled when scrolled up
  ReplyPill       (GameObject)   toggled
    ReplyLabel    (Text)         "Replying to Mirra"
    ReplyDismiss  (Button)
  InputField      (InputField)
  TargetLabel     (Text)         "Message Guild"
  SendButton      (Button)
```

**2. `ChatGroupChip`** (one per group)
```
Title             (Text)         "World"
Right             (Text)         unread count, blank when zero
Inactive          (GameObject)   toggled when the group is filtered out
```

**3. `ChatFeedRow`** (extension of the existing row prefab)
```
GroupTag          (Text)         "W" / "G" / "P" / "L"
Sender            (Text)
Body              (Text)         rich text, mentions highlighted
MentionSelf       (GameObject)   toggled when the local player is mentioned
```

**4. `ChatMentionToast`** (one, transient)
```
Title             (Text)         "Toft mentioned you"
Body              (Text)         message excerpt
TapTarget         (Button)
```

### 10.3 Skinning notes for the baker

Group colour lives on `ChatGroupChip` and `ChatFeedRow` as authored per-group variants or
as a colour set the runtime indexes by group. Either is fine as long as the runtime picks
an index rather than a colour value.

Panel height, chip sizing, row spacing, and the message list layout are all authored in
the editor. The runtime toggles `MinimizedRoot` and `ExpandedRoot` and never sets a
RectTransform size.

### 10.4 New backend

| Item | Type | Stage |
|---|---|---|
| `fetch_chat_feed` | RPC | 1 |
| `general` read and insert RLS | Migration | 2 |
| Rate limit in the send RPC | Migration | 2 |
| World history trim job | Scheduled | 2 |
| `chat_mentions` table plus index | Migration | 3 |
| `resolve_usernames` | RPC | 3 |
| `chat_mention_count` | RPC | 3 |
| Mention FCM dispatch path | Service | 4 |

---

## 11. Acceptance Criteria

- The dock renders above `ActiveIdleBarUI` and never reflows the HUD in either state.
- Minimized shows one line with the latest visible message and a total unread count.
- Expanded covers roughly 45 percent of viewport height, overlays without dimming, and
  does not push game content.
- The feed is a single merged stream. Guild, Private, Lobby, and World messages interleave
  by timestamp and are distinguished by tag and colour.
- Filter chips hide and show groups. A hidden group still accumulates unread on its chip.
- Per-group unread clears only when that group is visible and the feed is scrolled to
  bottom.
- The Lobby chip appears on lobby entry and is removed on leave.
- Tapping a Private line sets a reply pill and Send routes to that DM thread.
- The current send target is always visible in the input placeholder.
- `ChatPill` no longer exists.
- The dock auto-minimizes on entering combat or a dungeon and does not hide entirely.
- One poll request per interval regardless of how many groups are open.
- Poll interval is 3 seconds expanded, 10 seconds minimized, stopped when backgrounded.
- A message containing a resolvable `@name` highlights it and notifies that player.
- An unresolvable `@name` sends normally as plain text with no error.
- Mentions notify regardless of the recipient's filter state, subject to blocks.
- World enforces the server-side rate limit before any client can post.
- Runtime sets no colours, sizes, spacing, or padding anywhere in this spec.

---

*Path: docs/chat-dock-panel-spec.md*
*Four stages. Four new baked templates, existing row prefab and keyboard-lift reused.*
*Main code change is ChatManager holding multiple channels behind one merged fetch.*
*Amends multiplayer-chat-spec.md UI section, realtime decision, and general deferral.*
