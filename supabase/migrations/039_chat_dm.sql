-- Project Grimoire, Direct-message channel (Migration 039)
-- Multiplayer Chat P3. A DM channel_ref is a player_friendships.id; both participants of an ACCEPTED
-- friendship can read and post. Blocking removes the friendship (friend_block deletes it), so a blocked
-- pair has no accepted friendship and DM access falls away on its own, no extra block check needed.

-- Extend the membership gate with the dm branch (send + fetch both call chat_can_post).
create or replace function chat_can_post(p_type text, p_ref text)
returns boolean
language plpgsql stable security definer set search_path = public as $$
begin
    if p_type = 'guild' then
        return p_ref::uuid in (select auth_guild_ids());
    elsif p_type = 'dm' then
        return exists (
            select 1 from player_friendships f
            where f.id = p_ref::uuid
              and f.status = 'accepted'
              and auth.uid() in (f.requester_id, f.addressee_id)
        );
    end if;
    return false; -- lobby / general gates arrive with those phases
end;
$$;

-- DM read policy (permissive, OR-ed with the guild policy). Both friends read the thread; realtime
-- honors it. The player_friendships subquery is itself RLS-scoped to the caller's own friendships.
drop policy if exists "chat_messages: dm read" on chat_messages;
create policy "chat_messages: dm read" on chat_messages for select
    using (
        channel_type = 'dm' and exists (
            select 1 from player_friendships f
            where f.id = channel_ref::uuid
              and f.status = 'accepted'
              and auth.uid() in (f.requester_id, f.addressee_id)
        )
    );

-- Generic unread for any channel the caller can access (DMs use this; guild keeps chat_guild_unread).
create or replace function chat_channel_unread(p_type text, p_ref text)
returns int
language plpgsql stable security definer set search_path = public as $$
begin
    if not chat_can_post(p_type, p_ref) then return 0; end if;
    return (
        select count(*)::int
        from chat_messages m
        where m.channel_type = p_type and m.channel_ref = p_ref
          and m.sender_id <> auth.uid()
          and m.created_at > coalesce(
              (select last_read_at from chat_read_state r
               where r.player_id = auth.uid() and r.channel_type = p_type and r.channel_ref = p_ref),
              'epoch'::timestamptz));
end;
$$;

grant execute on function chat_can_post(text, text)        to authenticated;
grant execute on function chat_channel_unread(text, text)  to authenticated;
