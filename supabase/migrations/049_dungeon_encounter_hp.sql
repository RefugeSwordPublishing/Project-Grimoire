-- Project Grimoire, Co-op dungeon shared enemy HP (Migration 049)
-- Stage 4 Phase 2: party members in a co-op dungeon share each enemy's HP pool, keyed by a deterministic
-- ENCOUNTER SEQUENCE number. Because every client builds the identical room/enemy sequence from the shared
-- run_seed (migration 048) and increments the same counter per combat enemy, seq N is the same enemy on
-- every client. Each client batches its damage and calls dungeon_take_damage(lobby, seq, max, amount); the
-- server upserts the pool at max on first contact and decrements it atomically, so the mob melts faster
-- with more attackers and every client resolves the kill from one source of truth. Mirrors the boss
-- shared-HP model (migration 028), but per-encounter instead of a single boss pool. p_amount = 0 is a
-- cheap read. Rooms/advancement stay each client's own; only the enemy HP is shared, so a client that
-- drifts ahead simply fights the next seq's pool until the others catch up (graceful, no lockstep).

create table if not exists dungeon_encounter (
    lobby_id   uuid not null references boss_lobby(id) on delete cascade,
    seq        int  not null,             -- deterministic encounter index within the run
    current_hp int  not null,
    max_hp     int  not null,
    updated_at timestamptz not null default now(),
    primary key (lobby_id, seq)
);

create index if not exists dungeon_encounter_lobby_idx on dungeon_encounter(lobby_id);

alter table dungeon_encounter enable row level security;

-- Participants of the parent lobby may read their run's pools. Writes go only through the SECURITY
-- DEFINER RPC below (which bypasses RLS), so no insert/update policy is granted to clients directly.
drop policy if exists "dungeon_encounter: participants read" on dungeon_encounter;
create policy "dungeon_encounter: participants read"
    on dungeon_encounter for select
    using (exists (
        select 1 from boss_lobby l
        where l.id = dungeon_encounter.lobby_id
          and auth.uid() in (l.host_id, l.player_2_id, l.player_3_id)
    ));

-- Apply a client's batched damage to the shared pool for (lobby, seq). Upserts the pool at max_hp on
-- first contact so whichever client reaches the enemy first seeds it, then decrements atomically and
-- returns the authoritative current_hp. Returns -1-style failure is handled client-side (keep local HP).
create or replace function dungeon_take_damage(p_lobby uuid, p_seq int, p_max int, p_amount int)
returns int
language plpgsql
security definer
set search_path = public
as $$
declare
    l   boss_lobby;
    cur int;
begin
    select * into l from boss_lobby where id = p_lobby;
    if not found then raise exception 'lobby not found'; end if;
    if auth.uid() not in (l.host_id, l.player_2_id, l.player_3_id) then
        raise exception 'not a participant';
    end if;

    insert into dungeon_encounter (lobby_id, seq, current_hp, max_hp)
        values (p_lobby, p_seq, greatest(1, p_max), greatest(1, p_max))
        on conflict (lobby_id, seq) do nothing;

    update dungeon_encounter
       set current_hp = greatest(0, current_hp - greatest(0, p_amount)),
           updated_at = now()
     where lobby_id = p_lobby and seq = p_seq
    returning current_hp into cur;

    return coalesce(cur, 0);
end;
$$;
