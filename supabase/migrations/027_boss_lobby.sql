-- Project Grimoire, Zone boss co-op lobby (Migration 027)
-- STEP 10 Phase B: the pre-boss lobby. A host (the player who spawned the boss) and up to two guild
-- guests coordinate before a zone-boss fight. Real-time synced: the host manages slots/status/HP, each
-- participant toggles their own ready flag. boss_current_hp is the shared, server-authoritative HP pool
-- used by the Phase C multiplayer fight.

create table if not exists boss_lobby (
    id              uuid primary key default gen_random_uuid(),
    zone_id         text not null,
    boss_id         text not null,
    host_id         uuid not null references players(id) on delete cascade,
    player_2_id     uuid references players(id) on delete set null,
    player_3_id     uuid references players(id) on delete set null,
    host_ready      boolean not null default true,   -- host opened it, ready by default
    p2_ready        boolean not null default false,
    p3_ready        boolean not null default false,
    boss_current_hp integer,                          -- shared pool (Phase C); null until the fight starts
    boss_max_hp     integer,                          -- scaled HP snapshot at start (party size)
    status          text not null default 'waiting',  -- waiting / active / complete
    despawn_at      timestamptz not null,
    created_at      timestamptz not null default now()
);

create index if not exists boss_lobby_host_idx   on boss_lobby(host_id);
create index if not exists boss_lobby_status_idx on boss_lobby(status);

alter table boss_lobby enable row level security;

-- Participants (host + guests) can read the lobby. The check references the row's own columns only,
-- so there is no self-subquery recursion (unlike the guild_members case in migration 010).
drop policy if exists "boss_lobby: participants read" on boss_lobby;
create policy "boss_lobby: participants read"
    on boss_lobby for select
    using (auth.uid() in (host_id, player_2_id, player_3_id));

-- Only the host creates their own lobby.
drop policy if exists "boss_lobby: host insert" on boss_lobby;
create policy "boss_lobby: host insert"
    on boss_lobby for insert
    with check (host_id = auth.uid());

-- Participants update the row (host manages slots/status/HP; guests toggle their own ready). Guests
-- join through join_boss_lobby() below, which adds them as a participant first.
drop policy if exists "boss_lobby: participants update" on boss_lobby;
create policy "boss_lobby: participants update"
    on boss_lobby for update
    using (auth.uid() in (host_id, player_2_id, player_3_id))
    with check (auth.uid() in (host_id, player_2_id, player_3_id));

-- Only the host removes the lobby (cleanup on retreat / completion).
drop policy if exists "boss_lobby: host delete" on boss_lobby;
create policy "boss_lobby: host delete"
    on boss_lobby for delete
    using (host_id = auth.uid());

-- An invited guest joins an open slot. SECURITY DEFINER so the guest can write themselves in before
-- they are a participant (the RLS update policy would otherwise deny it). Guild-membership and invite
-- validation are enforced client-side + by the invite notification; this just fills the first open slot.
create or replace function join_boss_lobby(p_lobby uuid)
returns boss_lobby
language plpgsql
security definer
set search_path = public
as $$
declare
    l boss_lobby;
begin
    select * into l from boss_lobby where id = p_lobby for update;
    if not found then raise exception 'lobby not found'; end if;
    if l.status <> 'waiting' then raise exception 'lobby is not accepting players'; end if;
    if auth.uid() in (l.host_id, l.player_2_id, l.player_3_id) then return l; end if; -- already in
    if l.player_2_id is null then
        update boss_lobby set player_2_id = auth.uid(), p2_ready = false where id = p_lobby returning * into l;
    elsif l.player_3_id is null then
        update boss_lobby set player_3_id = auth.uid(), p3_ready = false where id = p_lobby returning * into l;
    else
        raise exception 'lobby is full';
    end if;
    return l;
end;
$$;

-- A guest leaves their slot (or is kicked: the host can also just null the slot via update).
create or replace function leave_boss_lobby(p_lobby uuid)
returns boss_lobby
language plpgsql
security definer
set search_path = public
as $$
declare
    l boss_lobby;
begin
    select * into l from boss_lobby where id = p_lobby for update;
    if not found then raise exception 'lobby not found'; end if;
    if auth.uid() = l.player_2_id then
        update boss_lobby set player_2_id = null, p2_ready = false where id = p_lobby returning * into l;
    elsif auth.uid() = l.player_3_id then
        update boss_lobby set player_3_id = null, p3_ready = false where id = p_lobby returning * into l;
    end if;
    return l;
end;
$$;

-- Real-time so every participant sees slot / ready / status / HP changes live (same channel pattern as
-- guild voting). Guard the publication add so re-running the migration is idempotent.
do $$
begin
    if not exists (
        select 1 from pg_publication_tables
        where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'boss_lobby'
    ) then
        alter publication supabase_realtime add table boss_lobby;
    end if;
end $$;
