---
type: design-spec
version: 1.0
updated: 2026-09-04
path: docs/party-ally-cards-spec.md
resolves: party-ally-cards-REQUEST.md
implements: lobby_member_state migration, sync_member_state RPC, inspect_player RPC,
            boss_lobby slot expansion, MemberStateSync, AllyCardContainer, InspectPanel
scope: raid-ready plumbing. Raid combat stays deferred.
---

# Party Ally Cards and Live Member-State Sync
### Version 1.0

---

## 1. The Two Decisions That Shape Everything

**One RPC does the write and the read.** Each client calls `sync_member_state`, which writes
that client's own row and returns the whole party's state in the same round trip. There is no
separate write call and no separate read call. This halves the request count against the
naive design and it is what makes a 300ms cadence defensible at all.

**Member state is a normalized table, not widened `boss_lobby` columns.** The deciding argument
is write contention, not elegance. At five players polling every 300ms, per-slot columns on
`boss_lobby` would mean roughly 17 writes per second landing on a **single row** that all five
clients are also reading for roster and ready flags. That row becomes a lock queue, and every
HP write invalidates the roster read for everyone. One row per member means five clients write
five different rows and nothing contends.

The other reasons follow: `boss_lobby` is hard-capped at three slots and raids need five, and
mixing near-static roster data with 3-per-second HP churn on the same row means the cheap data
pays the expensive data's cost forever.

---

## 2. Schema

### 2.1 The member state table

```sql
create table lobby_member_state (
  lobby_id       uuid        not null references boss_lobby(id) on delete cascade,
  player_id      uuid        not null references auth.users on delete cascade,

  -- fast, written every sync tick
  current_hp     int         not null default 0,
  max_hp         int         not null default 1,
  statuses       jsonb       not null default '[]'::jsonb,
  member_status  text        not null default 'alive',   -- alive | downed | left

  -- near-static, written once on join
  username       text        not null,
  grimoire_id    text,
  combat_level   int         not null default 1,

  joined_at      timestamptz not null default now(),
  updated_at     timestamptz not null default now(),

  primary key (lobby_id, player_id)
);

create index lobby_member_state_lobby_idx on lobby_member_state (lobby_id);
```

`username`, `grimoire_id`, and `combat_level` are denormalized onto this row deliberately. They
are written once on join and never again during a fight, and carrying them here means the card
renders from one query with no joins and no cross-player reads through other RPCs.

`statuses` is the serialized debuff list, section 5.

### 2.2 RLS

```sql
alter table lobby_member_state enable row level security;

-- You can read the whole party if you are in the party.
create policy "read own party" on lobby_member_state for select
  using (exists (
    select 1 from lobby_member_state m
    where m.lobby_id  = lobby_member_state.lobby_id
      and m.player_id = auth.uid()
  ));

-- You can only ever write your own row.
create policy "write own row" on lobby_member_state for update
  using (player_id = auth.uid()) with check (player_id = auth.uid());
```

The read policy is self-referential on purpose. It asks "is the caller a member of this lobby"
without consulting `boss_lobby`'s slot columns at all, which means **it already works at any
party size** and will not need touching when raids arrive. That property is worth more than it
looks: every other gate in the game is a hardcoded `auth.uid() in (host_id, player_2_id,
player_3_id)` expression that has to grow every time the party does.

### 2.3 Scaling boss_lobby to five

```sql
alter table boss_lobby add column player_4_id      uuid references auth.users;
alter table boss_lobby add column player_5_id      uuid references auth.users;
alter table boss_lobby add column player_4_ready   boolean not null default false;
alter table boss_lobby add column player_5_ready   boolean not null default false;
```

Nullable, unused until raids ship, and the existing gate expressions in `boss_take_damage` and
`dungeon_take_damage` extend to include them.

**Worth flagging as a later refactor, not now.** Those gates could instead check
`exists (select 1 from lobby_member_state ...)` and never need a slot count again. That is the
better long-term shape, but it modifies two RPCs that currently work, for a benefit that does
not land until raids. Add the columns now, refactor when raids are actually scheduled.

---

## 3. The Sync RPC

### 3.1 Signature

```sql
create or replace function sync_member_state(
  p_lobby_id  uuid,
  p_hp        int,
  p_max_hp    int,
  p_statuses  jsonb,
  p_full      boolean default false   -- false: fast fields only. true: include roster.
) returns jsonb
language plpgsql security definer as $$
declare v_result jsonb;
begin
  -- Membership gate. Non-members get nothing, not an error that leaks lobby existence.
  if not exists (select 1 from lobby_member_state
                 where lobby_id = p_lobby_id and player_id = auth.uid()) then
    return '[]'::jsonb;
  end if;

  update lobby_member_state
     set current_hp    = p_hp,
         max_hp        = p_max_hp,
         statuses      = p_statuses,
         member_status = case when p_hp <= 0 then 'downed' else 'alive' end,
         updated_at    = now()
   where lobby_id = p_lobby_id and player_id = auth.uid();

  select jsonb_agg(
    case when p_full then
      jsonb_build_object('pid', player_id, 'hp', current_hp, 'mhp', max_hp,
                         'st', statuses, 'ms', member_status,
                         'nm', username, 'gr', grimoire_id, 'cl', combat_level,
                         'ts', extract(epoch from updated_at))
    else
      jsonb_build_object('pid', player_id, 'hp', current_hp,
                         'ms', member_status,
                         'ts', extract(epoch from updated_at))
    end)
  into v_result
  from lobby_member_state
  where lobby_id = p_lobby_id and player_id <> auth.uid();

  return coalesce(v_result, '[]'::jsonb);
end; $$;
```

Two payload shapes behind one flag. The fast shape carries only what changes fast. The full
shape adds roster fields and the status list, and runs on the slow tier.

The caller's own row is excluded from the response. The client already knows its own HP.

`ts` is returned so the client can detect a member who has stopped writing. Section 7.4.

### 3.2 Joining and leaving

The existing lobby join path gains one insert:

```sql
insert into lobby_member_state
  (lobby_id, player_id, username, grimoire_id, combat_level, current_hp, max_hp)
values (p_lobby_id, auth.uid(), v_username, v_grimoire, v_combat_level, v_hp, v_max_hp)
on conflict (lobby_id, player_id) do update
  set username = excluded.username, grimoire_id = excluded.grimoire_id,
      combat_level = excluded.combat_level, member_status = 'alive';
```

On leave, set `member_status = 'left'` rather than deleting. The row is deleted by the cascade
when the lobby closes. Marking rather than deleting lets the card show a "left the party" state
for a few seconds instead of a member silently vanishing mid-fight, which reads as a bug.

---

## 4. Cadence and Load Budget

### 4.1 Four tiers

| Tier | Condition | Interval | Payload | Per client |
|---|---|---|---|---|
| T0 | Solo, or lobby of one | stopped | none | 0 req/s |
| T1 | In lobby, out of combat | 3000ms | full | 0.33 req/s |
| T2 | In combat, no party HP change in 3s | 1000ms | full every 5th, else fast | 1.00 req/s |
| T3 | In combat, any party HP changed in last 3s | 300ms | fast | 3.33 req/s |

**T3 is entered by the party, not by the individual.** If any member's HP moved, everyone
speeds up, because that is exactly when everyone wants to see the cards move.

The full payload runs on T1 always and on every fifth tick of T2, which is enough for debuffs
and roster since neither changes on a 300ms timescale. T3 never sends the full shape.

### 4.2 Immediate write on a large hit

The tick cadence bounds writes, but a player taking a large hit should not wait up to 300ms to
publish it.

```csharp
// In addition to the tick, fire an out-of-band sync when HP drops hard.
if (hpBefore - hpAfter >= maxHP * 0.15f) SyncNow();
```

Bounded by construction, since a 15 percent drop cannot happen more than about seven times
before the player is down.

### 4.3 The load budget

| Scenario | Sync req/s | Damage flush | Total per lobby |
|---|---|---|---|
| Dungeon, 3 players, worst case all T3 | 10.0 | 3.0 | 13.0 |
| Dungeon, 3 players, realistic 30 percent T3 | 5.1 | 3.0 | 8.1 |
| Raid, 5 players, worst case all T3 | 16.7 | 5.0 | 21.7 |
| Raid, 5 players, realistic 30 percent T3 | 8.5 | 5.0 | 13.5 |
| Any party, idle in lobby | 1.7 | 0 | 1.7 |

Payload at five players on the fast tier is roughly 160 bytes, so 533 B/s per client at T3.
Bandwidth is not the constraint. Request count is, and worst case is 21.7 per second per
active raid lobby.

**Defensible because T3 is bounded and rare.** It requires an active fight with damage landing
in the last three seconds, and the tier drops to T2 automatically the moment the party is not
taking hits. A lobby sitting between pulls costs 1.7 requests per second, and a solo player
costs nothing at all.

### 4.4 Honest staleness

Up to 300ms to write plus up to 300ms to read is **600ms worst case, roughly 300ms average.**

That is the number to hold in mind rather than "300ms refresh," and it is why the large-hit
immediate write in 4.2 matters. Say this out loud in the doc rather than letting someone
discover it in playtest.

---

## 5. Debuff Serialization and Rendering

### 5.1 Wire format

Keys are short because this rides the fast path. Label and magnitude are omitted because the
client resolves both from the id, and the card shows neither.

```json
[{"i":"bleed","k":"D","r":4.2,"s":2},{"i":"chill","k":"L","r":2.0}]
```

| Key | Meaning |
|---|---|
| `i` | Status id, resolves to icon and label client side |
| `k` | Kind: `D` dot, `X` debuff, `L` slow, `S` shield, `H` hot, `B` buff |
| `r` | Remaining seconds, one decimal |
| `s` | Stacks, omitted when 1 |

Cap at six entries when serializing. A status list longer than six is not information, it is
noise, and bounding it server side keeps the payload predictable.

### 5.2 Everything with a timer shows, but threats sort first

The request asks whether shields and HoTs should appear. They should. An ally card's job is
situational awareness, and a shield about to expire is as actionable as a bleed.

What matters is ordering, because only three fit. **Sort threats before protections:**

1. Dot, Debuff, Slow
2. Shield, Hot, Buff

Within a group, sort by ascending remaining time so the thing about to matter is leftmost. If
more than three exist, show three and an overflow chip reading the remainder.

That ordering means a card with two dots and a shield shows both dots, which is the correct
answer to "does my ally need help."

### 5.3 Rendering

Reuse the enemy debuff row prefab directly. Same icon, same radial countdown, same stack
label, same three-icon cap. The only difference is the anchor, which sits above the ally card
rather than above the enemy nameplate.

Radial timers interpolate locally between polls from the last known `r`, so they sweep smoothly
at 300ms updates rather than stepping.

---

## 6. Inspect On Tap

### 6.1 The RPC

```sql
create or replace function inspect_player(p_target uuid)
returns jsonb language plpgsql security definer as $$
declare v_lobby uuid; v_out jsonb;
begin
  -- Gate: caller and target must share a lobby.
  select m1.lobby_id into v_lobby
  from lobby_member_state m1
  join lobby_member_state m2 on m2.lobby_id = m1.lobby_id
  where m1.player_id = auth.uid() and m2.player_id = p_target;

  if v_lobby is null then
    raise exception 'Not in your party';
  end if;

  select jsonb_build_object(
    'username',      p.username,
    'grimoire_id',   ms.grimoire_id,
    'combat_level',  ms.combat_level,
    'total_combat_level', st.total_combat_level,
    'stats',   jsonb_build_object('str',st.str,'dex',st.dex,'int',st.int_stat,
                                  'wil',st.wil,'vit',st.vit,'lck',st.lck),
    'derived', jsonb_build_object('max_hp',ms.max_hp,'armor_rating',st.armor_rating,
                                  'evasion',st.evasion_rating,'block_chance',st.block_chance),
    'equipment', pe.equipment          -- existing {gear:[],tools:[]} blob
  ) into v_out
  from players p
  join player_stats st on st.player_id = p.id
  join player_equipment pe on pe.player_id = p.id
  join lobby_member_state ms on ms.player_id = p.id and ms.lobby_id = v_lobby
  where p.id = p_target;

  return v_out;
end; $$;
```

### 6.2 What it deliberately does not return

Inventory, currency, quest state, friend list, and talent levels. The panel exists to answer
"is my partner geared for this fight," and every field beyond that is a privacy surface added
for no gameplay reason.

The equipment blob should be returned with item names, quality, and tier already resolved, so
the client does not need a second cross-player lookup to render it.

### 6.3 Guard

One call per target per two seconds, client side, plus a server side check against
`updated_at` on a small `inspect_log`. A tap action does not need a hard rate limit, but a
mashing or modified client should not be able to poll a partner's gear as a data feed.

### 6.4 The panel

A modal over the combat screen. Combat continues behind it, since dismissing a panel to avoid
dying would be a poor trade for curiosity.

```
┌─────────────────────────────────────┐
│  KAELEN                             │
│  Sharpshot  ·  Combat Level 45      │
│  ─────────────────────────────────  │
│  HP        1,240 / 1,340            │
│  Armour    128    Evasion    22     │
│  Block     none                     │
│  ─────────────────────────────────  │
│  STR 12   DEX 48   INT 9            │
│  WIL 14   VIT 31   LCK 22           │
│  ─────────────────────────────────  │
│  EQUIPMENT                          │
│  Weapon    Mithril Longbow, Refined │
│  Helm      ...                      │
│  ...                                │
│  ─────────────────────────────────  │
│  [           Close           ]      │
└─────────────────────────────────────┘
```

---

## 7. The Ally Cards

### 7.1 Placement and sizing

A horizontal row anchored directly above the player's own HP bar, low on the screen. Up to four
cards in a raid, two in a dungeon.

Card width flexes by count through a `HorizontalLayoutGroup` with the cell size authored in the
editor. At four cards on a 1080 portrait screen each card is roughly 250px wide, which fits a
truncated name, a class line, and a bar. At two cards they are comfortable.

The debuff row sits **above** each card rather than inside it, which keeps the card body a fixed
height whether or not statuses are present.

### 7.2 Layout

```
        [icon][icon][+2]              debuff row, above the card
┌────────────────────────┐
│ Kaelen                 │            name, truncated with ellipsis
│ Sharpshot              │            class from grimoire_id
│ ██████████░░░░  1,240  │            HP bar and current value
└────────────────────────┘
```

### 7.3 States

| State | Trigger | Rendering |
|---|---|---|
| Alive | `member_status = 'alive'` | Normal |
| Downed | `member_status = 'downed'` or hp 0 | Desaturated, bar empty, HP value replaced by "DOWNED", red border |
| Left | `member_status = 'left'` | Greyed, "Left the party" replaces the class line, card removed after 5s |
| Stale | `now - ts > 5s` | Last known values dimmed, connection dot shown in the corner |
| Empty | Fewer members than card slots | No card rendered at all, container shrinks |

### 7.4 The stale state matters more than it looks

The request did not ask for it and it is the state most likely to cause a support ticket. With
polling and no realtime, a client that has been backgrounded, has lost signal, or has crashed
keeps looking perfectly healthy on everyone else's screen forever, because their last written
HP just sits there.

Returning `ts` from the sync RPC and dimming a card that has not updated in five seconds costs
one comparison and turns a silent lie into visible information.

### 7.5 Baked regions

```
AllyCardContainer            HorizontalLayoutGroup, cell size authored in editor
AllyCard
  DebuffRow      (Transform)    parent for AllyDebuffIcon clones
  OverflowChip   (GameObject)
  OverflowLabel  (Text)         "+2"
  Name           (Text)
  Class          (Text)
  HPFill         (Image)        fillAmount
  HPLabel        (Text)
  StatusOverlay  (GameObject)   downed and left tint
  StatusLabel    (Text)         "DOWNED" / "Left the party"
  StaleDot       (GameObject)
  TapTarget      (Button)

AllyDebuffIcon               reuse the existing enemy debuff icon prefab unchanged
  Icon           (Image)
  RadialTimer    (Image)        fillAmount
  StackLabel     (Text)

InspectPanel                 modal, regions per section 6.4
```

Runtime instantiates cards and icons and fills data. It sets no colours, sizes, spacing, or
padding, matching every other baked surface in the game.

---

## 8. Build Order, Server Versus Client

### 8.1 New server work

| # | Item | Kind | Blocks |
|---|---|---|---|
| S1 | `lobby_member_state` table, index, RLS | Migration | Everything |
| S2 | `sync_member_state` RPC | Migration | Everything |
| S3 | Lobby join and leave write to `lobby_member_state` | RPC edit | Everything |
| S4 | `boss_lobby` player 4 and 5 columns, gate expressions extended | Migration | Raids only |
| S5 | `inspect_player` RPC | Migration | Tap to inspect |

S1 through S3 are the minimum for anything to work at all. S4 is raid plumbing and can land
any time. S5 is independent of the cards and can land after them.

### 8.2 Client only

| # | Item | Depends on |
|---|---|---|
| C1 | `MemberStateSync`, the four-tier cadence controller | S1 to S3 |
| C2 | Status serialization on write, deserialization on read | C1 |
| C3 | `AllyCardContainer` and card population | C1 |
| C4 | Debuff row on the card, reusing the enemy icon prefab | C2, C3 |
| C5 | Card states including stale detection | C3 |
| C6 | Inspect panel and tap wiring | S5, C3 |

### 8.3 Recommended slices

| Slice | Contents | Result |
|---|---|---|
| 1 | S1, S2, S3, C1, C3 | Cards showing name, class, and live HP. The feature is useful here. |
| 2 | C2, C4, C5 | Debuffs and the downed, left, and stale states |
| 3 | S5, C6 | Tap to inspect |
| 4 | S4 | Raid plumbing, inert until raids |

Slice 1 is the one that matters. Everything after it is refinement of a feature that already
works.

---

## 9. Acceptance Criteria

- A member's HP appears on a partner's card within 600ms worst case and about 300ms typical.
- A single `sync_member_state` call performs both the write and the read. No separate write
  call exists.
- Reading the party costs exactly one query regardless of party size.
- Five clients syncing at 300ms write to five distinct rows and never contend on one row.
- A non-member calling `sync_member_state` for a lobby receives an empty array, not an error
  that reveals whether the lobby exists.
- A player can only ever write their own `lobby_member_state` row.
- The cadence drops to 1000ms when no party HP has changed for three seconds, to 3000ms out of
  combat, and stops entirely in a lobby of one.
- An HP drop of 15 percent or more of max triggers an immediate out-of-band sync.
- The fast payload omits roster fields and the status list.
- Statuses sort threats before protections, and by ascending remaining time within a group.
- A card whose member has not updated in five seconds renders as stale.
- A member at 0 HP renders as downed, and one who left renders as left for five seconds before
  the card is removed.
- `inspect_player` refuses any target not sharing the caller's lobby.
- `inspect_player` returns no inventory, currency, quest, or talent data.
- Runtime sets no colours, sizes, spacing, or fonts on any card or panel.

---

## 10. Out of Scope

Raid combat itself, party heal targeting, revive mechanics, the drag-to-ally Lifebinder support
kit, and any change to `boss_take_damage` or `dungeon_take_damage` beyond extending their slot
gates. The gate refactor onto `lobby_member_state` is noted in section 2.3 as the right later
move and is deliberately not scoped here.

---

*Path: docs/party-ally-cards-spec.md*
*One RPC does write and read in a single round trip. Normalized `lobby_member_state` avoids*
*17 writes per second landing on one shared row. Four cadence tiers put a five-player raid at*
*13.5 requests per second realistic and 21.7 worst case. Five server items, six client items,*
*and slice 1 delivers a working feature.*
