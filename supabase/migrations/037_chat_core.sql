-- Project Grimoire, Chat core: messages + read state + guild channel (Migration 037)
-- Multiplayer Chat P1 (see docs/multiplayer-chat-spec.md). Transport-agnostic: the same tables/RPCs
-- serve both the realtime subscription and the poll fallback. Guild is the first live channel;
-- lobby/DM/general read policies land in P2/P3/P4.
--
-- Cross-player reads (sender usernames) go through SECURITY DEFINER RPCs because players is "own row
-- only" under RLS. chat_messages ALSO carries a per-channel SELECT policy so Supabase realtime (which
-- honors RLS) delivers live inserts to channel members only. Sends go through send_chat_message
-- (validates membership + rate limit), so chat_messages needs no INSERT policy.

-- =============================================================================
-- Tables
-- =============================================================================

create table if not exists chat_messages (
    id           uuid primary key default gen_random_uuid(),
    channel_type text not null,          -- 'guild' | 'lobby' | 'dm' | 'general'
    channel_ref  text not null,          -- guild_id | boss_lobby_id | dm_thread_ref | general_shard
    sender_id    uuid not null references players(id) on delete cascade,
    body         text not null check (char_length(body) between 1 and 500),
    created_at   timestamptz not null default now()
);
create index if not exists chat_messages_channel_idx on chat_messages(channel_type, channel_ref, created_at desc);

create table if not exists chat_read_state (
    player_id    uuid not null references players(id) on delete cascade,
    channel_type text not null,
    channel_ref  text not null,
    last_read_at timestamptz not null default now(),
    primary key (player_id, channel_type, channel_ref)
);

alter table chat_messages   enable row level security;
alter table chat_read_state enable row level security;

-- Read state is private to each player.
drop policy if exists "chat_read_state: own" on chat_read_state;
create policy "chat_read_state: own" on chat_read_state for all
    using (player_id = auth.uid()) with check (player_id = auth.uid());

-- Guild-channel read (P1). Members read their guild's messages; realtime honors this policy so live
-- delivery reaches guild members only. Additional per-channel SELECT policies (permissive, OR-ed) get
-- added for lobby/DM/general in later phases.
drop policy if exists "chat_messages: guild read" on chat_messages;
create policy "chat_messages: guild read" on chat_messages for select
    using (channel_type = 'guild' and channel_ref::uuid in (select auth_guild_ids()));

-- =============================================================================
-- Membership gate (extended per phase)
-- =============================================================================

-- True if the caller may read/post in the given channel. Guild only for now.
create or replace function chat_can_post(p_type text, p_ref text)
returns boolean
language plpgsql stable security definer set search_path = public as $$
begin
    if p_type = 'guild' then
        return p_ref::uuid in (select auth_guild_ids());
    end if;
    return false; -- lobby / dm / general gates arrive with those phases
end;
$$;

-- =============================================================================
-- RPCs
-- =============================================================================

-- Post a message to a channel. Validates membership, trims + length-checks the body, and rate-limits
-- to 5 messages / 10s per sender. Returns the inserted row.
create or replace function send_chat_message(p_channel_type text, p_channel_ref text, p_body text)
returns chat_messages
language plpgsql security definer set search_path = public as $$
declare me uuid := auth.uid(); msg chat_messages; recent int;
begin
    if me is null then raise exception 'not authenticated'; end if;
    p_body := btrim(coalesce(p_body, ''));
    if char_length(p_body) = 0   then raise exception 'empty message'; end if;
    if char_length(p_body) > 500 then raise exception 'message too long'; end if;
    if not chat_can_post(p_channel_type, p_channel_ref) then raise exception 'not a member of this channel'; end if;

    select count(*) into recent from chat_messages
        where sender_id = me and created_at > now() - interval '10 seconds';
    if recent >= 5 then raise exception 'sending too fast'; end if;

    insert into chat_messages (channel_type, channel_ref, sender_id, body)
        values (p_channel_type, p_channel_ref, me, p_body)
        returning * into msg;
    return msg;
end;
$$;

-- Recent messages for a channel with sender usernames (newest first; the client reverses for display).
-- Used for history load and the poll fallback; realtime handles live inserts on top.
create or replace function fetch_chat_messages(p_channel_type text, p_channel_ref text, p_limit int default 50)
returns table (id uuid, sender_id uuid, username text, body text, created_at timestamptz)
language plpgsql stable security definer set search_path = public as $$
begin
    if not chat_can_post(p_channel_type, p_channel_ref) then raise exception 'not a member of this channel'; end if;
    return query
        select m.id, m.sender_id, p.username, m.body, m.created_at
        from chat_messages m join players p on p.id = m.sender_id
        where m.channel_type = p_channel_type and m.channel_ref = p_channel_ref
        order by m.created_at desc
        limit greatest(1, least(p_limit, 200));
end;
$$;

-- Mark a channel read up to now (drives unread counts).
create or replace function mark_chat_read(p_channel_type text, p_channel_ref text)
returns void
language sql security definer set search_path = public as $$
    insert into chat_read_state (player_id, channel_type, channel_ref, last_read_at)
        values (auth.uid(), p_channel_type, p_channel_ref, now())
    on conflict (player_id, channel_type, channel_ref)
        do update set last_read_at = now();
$$;

-- Unread count for a guild channel: messages from others newer than my last read.
create or replace function chat_guild_unread(p_channel_ref text)
returns int
language sql stable security definer set search_path = public as $$
    select count(*)::int
    from chat_messages m
    where m.channel_type = 'guild' and m.channel_ref = p_channel_ref
      and m.sender_id <> auth.uid()
      and m.created_at > coalesce(
          (select last_read_at from chat_read_state r
           where r.player_id = auth.uid() and r.channel_type = 'guild' and r.channel_ref = p_channel_ref),
          'epoch'::timestamptz);
$$;

-- =============================================================================
-- Realtime + grants
-- =============================================================================

-- Publish chat_messages so the P1 RealtimeManager can subscribe (delivery gated by the SELECT policy).
do $$
begin
    if not exists (
        select 1 from pg_publication_tables
        where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'chat_messages'
    ) then
        alter publication supabase_realtime add table chat_messages;
    end if;
end $$;

grant execute on function chat_can_post(text, text)                 to authenticated;
grant execute on function send_chat_message(text, text, text)       to authenticated;
grant execute on function fetch_chat_messages(text, text, int)      to authenticated;
grant execute on function mark_chat_read(text, text)                to authenticated;
grant execute on function chat_guild_unread(text)                   to authenticated;
