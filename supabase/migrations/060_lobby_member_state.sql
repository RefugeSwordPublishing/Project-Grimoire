-- 060_lobby_member_state.sql
-- Party ally cards: live member-state sync (docs/party-ally-cards-spec.md v1.0, slice 1 + raid plumbing).
--
-- Co-op today shares only the enemy HP pool; a player sees nothing about partners. This adds a normalized
-- per-member state row (one row per member per lobby) plus a single RPC that WRITES the caller's own row and
-- READS the whole party back in one round trip, which is what makes the ~300ms combat cadence affordable.
-- One row per member (not widened boss_lobby columns) so five clients writing 3x/sec never contend on a
-- single shared row, and so the model already scales to a 5-player raid.
--
-- Raid COMBAT stays deferred; this is plumbing only. The boss_lobby slots 4/5 are added here (S4) so the
-- membership gate can be written raid-ready once, and stay null/unused until raids ship.

-- ── S4: raid-ready slots on boss_lobby (nullable, inert until raids) ──────────────────────────────
alter table boss_lobby add column if not exists player_4_id    uuid references auth.users;
alter table boss_lobby add column if not exists player_5_id    uuid references auth.users;
alter table boss_lobby add column if not exists player_4_ready boolean not null default false;
alter table boss_lobby add column if not exists player_5_ready boolean not null default false;

-- ── S1: the member-state table ────────────────────────────────────────────────────────────────────
create table if not exists lobby_member_state (
  lobby_id       uuid        not null references boss_lobby(id) on delete cascade,
  player_id      uuid        not null references auth.users on delete cascade,

  -- fast fields, written every sync tick
  current_hp     int         not null default 0,
  max_hp         int         not null default 1,
  statuses       jsonb       not null default '[]'::jsonb,   -- serialized debuff list (spec 5.1)
  member_status  text        not null default 'alive',       -- alive | downed | left

  -- near-static, populated on the first sync from the players row
  username       text        not null default '',
  grimoire_id    text,                                       -- players.grimoire_equipped (the subclass/"class")
  combat_level   int         not null default 1,

  joined_at      timestamptz not null default now(),
  updated_at     timestamptz not null default now(),

  primary key (lobby_id, player_id)
);

create index if not exists lobby_member_state_lobby_idx on lobby_member_state (lobby_id);

alter table lobby_member_state enable row level security;

-- Read the whole party if you are in the party (self-referential: no boss_lobby slot columns, so it already
-- works at any party size). Access is normally through the SECURITY DEFINER RPCs below; this is the backstop.
drop policy if exists "read own party" on lobby_member_state;
create policy "read own party" on lobby_member_state for select
  using (exists (
    select 1 from lobby_member_state m
    where m.lobby_id = lobby_member_state.lobby_id
      and m.player_id = auth.uid()
  ));

-- You can only ever write your own row.
drop policy if exists "write own row" on lobby_member_state;
create policy "write own row" on lobby_member_state for all
  using (player_id = auth.uid()) with check (player_id = auth.uid());

-- ── S2 (+S3 folded in): the one write-and-read RPC ─────────────────────────────────────────────────
-- Writes the caller's own row and returns every OTHER member's state in the same call. Self-healing: the
-- row is upserted on the first sync (static fields sourced from the players table), so no edit to the
-- working join RPC is needed. Membership is gated against the real boss_lobby roster (all five slots).
--   p_full = false  -> fast shape (hp + member_status + ts), for the ~300ms combat tier
--   p_full = true   -> adds roster fields + the status list, for the slow tiers
create or replace function sync_member_state(
  p_lobby_id uuid,
  p_hp       int,
  p_max_hp   int,
  p_statuses jsonb,
  p_full     boolean default false
) returns jsonb
language plpgsql security definer set search_path = public as $$
declare v_result jsonb;
begin
  -- Membership gate. A non-member gets an empty array, never an error that leaks whether the lobby exists.
  if not exists (
    select 1 from boss_lobby b
    where b.id = p_lobby_id
      and auth.uid() in (b.host_id, b.player_2_id, b.player_3_id, b.player_4_id, b.player_5_id)
  ) then
    return '[]'::jsonb;
  end if;

  -- Write own row (create on first sync, static fields from players; update fast fields thereafter).
  insert into lobby_member_state
    (lobby_id, player_id, current_hp, max_hp, statuses, member_status, username, grimoire_id, combat_level, updated_at)
  select p_lobby_id, auth.uid(), p_hp, p_max_hp, coalesce(p_statuses, '[]'::jsonb),
         case when p_hp <= 0 then 'downed' else 'alive' end,
         coalesce(pl.username, ''), pl.grimoire_equipped, coalesce(pl.combat_level, 1), now()
  from players pl where pl.id = auth.uid()
  on conflict (lobby_id, player_id) do update
    set current_hp    = excluded.current_hp,
        max_hp        = excluded.max_hp,
        statuses      = excluded.statuses,
        member_status = excluded.member_status,
        updated_at    = now();

  -- Read the rest of the party (caller excluded; the client knows its own state).
  select jsonb_agg(
    case when p_full then
      jsonb_build_object('pid', player_id, 'hp', current_hp, 'mhp', max_hp,
                         'st', statuses, 'ms', member_status,
                         'nm', username, 'gr', grimoire_id, 'cl', combat_level,
                         'ts', extract(epoch from updated_at))
    else
      jsonb_build_object('pid', player_id, 'hp', current_hp, 'ms', member_status,
                         'ts', extract(epoch from updated_at))
    end)
  into v_result
  from lobby_member_state
  where lobby_id = p_lobby_id and player_id <> auth.uid();

  return coalesce(v_result, '[]'::jsonb);
end; $$;

-- Mark the caller as having left (card shows a "left the party" state briefly; the row is removed by the
-- cascade when the lobby closes). Gated the same way.
create or replace function leave_member_state(p_lobby_id uuid)
returns void language plpgsql security definer set search_path = public as $$
begin
  update lobby_member_state set member_status = 'left', updated_at = now()
   where lobby_id = p_lobby_id and player_id = auth.uid();
end; $$;

grant execute on function sync_member_state(uuid, int, int, jsonb, boolean) to authenticated;
grant execute on function leave_member_state(uuid) to authenticated;
