-- Project Grimoire, Friend system + block list + presence (Migration 036)
-- Multiplayer Chat P0 (see docs/multiplayer-chat-spec.md). Prerequisite for friend DMs and blocking.
--
-- Identity: players.username (unique) is the friend-search handle. Presence: players.last_active
-- (already bumped by PlayerDataService on save) + a light touch_presence() heartbeat; "online" means
-- last_active within 5 minutes, matching the guild online-roster (BossLobbyManager).
--
-- RLS note: players has an "own row only" SELECT policy, so a client cannot read another player's
-- username or last_active directly. Every cross-player read here goes through a SECURITY DEFINER RPC
-- that returns only safe public fields (id, username, online). Writes go through RPCs too, so the
-- tables need no INSERT/UPDATE/DELETE policies.

-- =============================================================================
-- Tables
-- =============================================================================

create table if not exists player_friendships (
    id            uuid primary key default gen_random_uuid(),
    requester_id  uuid not null references players(id) on delete cascade,
    addressee_id  uuid not null references players(id) on delete cascade,
    status        text not null default 'pending',   -- pending | accepted | declined
    created_at    timestamptz not null default now(),
    responded_at  timestamptz,
    unique (requester_id, addressee_id),
    check (requester_id <> addressee_id)
);
create index if not exists friendships_addressee_idx on player_friendships(addressee_id, status);
create index if not exists friendships_requester_idx on player_friendships(requester_id, status);

create table if not exists player_blocks (
    blocker_id  uuid not null references players(id) on delete cascade,
    blocked_id  uuid not null references players(id) on delete cascade,
    created_at  timestamptz not null default now(),
    primary key (blocker_id, blocked_id),
    check (blocker_id <> blocked_id)
);

alter table player_friendships enable row level security;
alter table player_blocks     enable row level security;

-- Participants may read their own friendships; all writes go through the RPCs below.
drop policy if exists "friendships: participant read" on player_friendships;
create policy "friendships: participant read"
    on player_friendships for select
    using (auth.uid() in (requester_id, addressee_id));

-- A player reads their own block rows.
drop policy if exists "blocks: own read" on player_blocks;
create policy "blocks: own read"
    on player_blocks for select
    using (blocker_id = auth.uid());

-- =============================================================================
-- Helpers
-- =============================================================================

-- True if either player has blocked the other. SECURITY DEFINER so it can see both block rows.
create or replace function friend_blocked_between(a uuid, b uuid)
returns boolean
language sql stable security definer set search_path = public as $$
    select exists (
        select 1 from player_blocks
        where (blocker_id = a and blocked_id = b)
           or (blocker_id = b and blocked_id = a)
    );
$$;

-- =============================================================================
-- RPCs (all SECURITY DEFINER; the caller is auth.uid())
-- =============================================================================

-- Find a player by exact (case-insensitive) username, to send a request. Never returns self,
-- deleted accounts, or anyone in a block relationship with the caller.
create or replace function friend_search(p_username text)
returns table (id uuid, username text)
language sql stable security definer set search_path = public as $$
    select p.id, p.username
    from players p
    where lower(p.username) = lower(p_username)
      and p.id <> auth.uid()
      and p.deleted_at is null
      and not friend_blocked_between(auth.uid(), p.id)
    limit 1;
$$;

-- Send a friend request. Auto-accepts if the target already requested the caller. Re-opens a
-- previously declined request. Returns: accepted | pending | already_pending | already_friends.
create or replace function friend_request(p_addressee uuid)
returns text
language plpgsql security definer set search_path = public as $$
declare
    me         uuid := auth.uid();
    reciprocal player_friendships;
    existing   player_friendships;
begin
    if me is null then raise exception 'not authenticated'; end if;
    if p_addressee = me then raise exception 'cannot friend yourself'; end if;
    if not exists (select 1 from players where id = p_addressee and deleted_at is null) then
        raise exception 'player not found';
    end if;
    if friend_blocked_between(me, p_addressee) then raise exception 'blocked'; end if;

    -- They already asked me -> accept it.
    select * into reciprocal from player_friendships
        where requester_id = p_addressee and addressee_id = me;
    if found then
        if reciprocal.status = 'accepted' then return 'already_friends'; end if;
        update player_friendships set status = 'accepted', responded_at = now()
            where id = reciprocal.id;
        return 'accepted';
    end if;

    -- My existing row toward them.
    select * into existing from player_friendships
        where requester_id = me and addressee_id = p_addressee;
    if found then
        if existing.status = 'accepted' then return 'already_friends'; end if;
        if existing.status = 'pending'  then return 'already_pending'; end if;
        update player_friendships set status = 'pending', created_at = now(), responded_at = null
            where id = existing.id;
        return 'pending';
    end if;

    insert into player_friendships (requester_id, addressee_id, status)
        values (me, p_addressee, 'pending');
    return 'pending';
end;
$$;

-- Addressee accepts or declines a pending request. Returns the resulting status.
create or replace function friend_respond(p_friendship uuid, p_accept boolean)
returns text
language plpgsql security definer set search_path = public as $$
declare me uuid := auth.uid(); f player_friendships;
begin
    select * into f from player_friendships where id = p_friendship for update;
    if not found then raise exception 'request not found'; end if;
    if f.addressee_id <> me then raise exception 'not your request to answer'; end if;
    if f.status <> 'pending' then return f.status; end if;
    update player_friendships
        set status = case when p_accept then 'accepted' else 'declined' end,
            responded_at = now()
        where id = f.id;
    return case when p_accept then 'accepted' else 'declined' end;
end;
$$;

-- Remove an accepted friend, or cancel a pending request (either direction).
create or replace function friend_remove(p_other uuid)
returns void
language plpgsql security definer set search_path = public as $$
declare me uuid := auth.uid();
begin
    delete from player_friendships
    where (requester_id = me and addressee_id = p_other)
       or (requester_id = p_other and addressee_id = me);
end;
$$;

-- Block a player: record the block and drop any friendship/request between the two.
create or replace function friend_block(p_target uuid)
returns void
language plpgsql security definer set search_path = public as $$
declare me uuid := auth.uid();
begin
    if p_target = me then raise exception 'cannot block yourself'; end if;
    insert into player_blocks (blocker_id, blocked_id) values (me, p_target)
        on conflict do nothing;
    delete from player_friendships
    where (requester_id = me and addressee_id = p_target)
       or (requester_id = p_target and addressee_id = me);
end;
$$;

-- Unblock a player.
create or replace function friend_unblock(p_target uuid)
returns void
language sql security definer set search_path = public as $$
    delete from player_blocks where blocker_id = auth.uid() and blocked_id = p_target;
$$;

-- The one call the friend UI needs: accepted friends + incoming/outgoing pending, each with the
-- other player's username, the relationship direction, and online status. Excludes blocked pairs.
--   direction: friend (accepted) | incoming (they asked me) | outgoing (I asked them)
create or replace function friend_list()
returns table (friendship_id uuid, other_id uuid, username text, status text, direction text, online boolean)
language sql stable security definer set search_path = public as $$
    select f.id,
           case when f.requester_id = auth.uid() then f.addressee_id else f.requester_id end,
           p.username,
           f.status,
           case
               when f.status = 'accepted'         then 'friend'
               when f.requester_id = auth.uid()   then 'outgoing'
               else                                    'incoming'
           end,
           (p.last_active is not null and p.last_active > now() - interval '5 minutes')
    from player_friendships f
    join players p
        on p.id = case when f.requester_id = auth.uid() then f.addressee_id else f.requester_id end
    where auth.uid() in (f.requester_id, f.addressee_id)
      and f.status in ('accepted', 'pending')
      and p.deleted_at is null
      and not friend_blocked_between(auth.uid(), p.id)
    order by (f.status = 'accepted') desc, lower(p.username);
$$;

-- Blocked players, for a manage-blocks list.
create or replace function friend_blocked_list()
returns table (id uuid, username text)
language sql stable security definer set search_path = public as $$
    select p.id, p.username
    from player_blocks b join players p on p.id = b.blocked_id
    where b.blocker_id = auth.uid()
    order by lower(p.username);
$$;

-- Presence heartbeat: bump my last_active. Called on a light timer while the app is foregrounded.
create or replace function touch_presence()
returns void
language sql security definer set search_path = public as $$
    update players set last_active = now() where id = auth.uid();
$$;

-- =============================================================================
-- Grants (authenticated clients call these; SECURITY DEFINER runs them as owner)
-- =============================================================================
grant execute on function friend_search(text)            to authenticated;
grant execute on function friend_request(uuid)           to authenticated;
grant execute on function friend_respond(uuid, boolean)  to authenticated;
grant execute on function friend_remove(uuid)            to authenticated;
grant execute on function friend_block(uuid)             to authenticated;
grant execute on function friend_unblock(uuid)           to authenticated;
grant execute on function friend_list()                  to authenticated;
grant execute on function friend_blocked_list()          to authenticated;
grant execute on function touch_presence()               to authenticated;
