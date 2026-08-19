-- Project Grimoire, Lobby chat channel (Migration 041)
-- Multiplayer Chat P2. A lobby channel_ref is a boss_lobby.id; the host and guests (host_id,
-- player_2_id, player_3_id) can read and post. Ephemeral: the channel lives with the lobby.

-- Extend the membership gate with the lobby branch.
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
    elsif p_type = 'lobby' then
        return exists (
            select 1 from boss_lobby l
            where l.id = p_ref::uuid
              and auth.uid() in (l.host_id, l.player_2_id, l.player_3_id)
        );
    end if;
    return false; -- general gate arrives later
end;
$$;

-- Lobby read policy (permissive, OR-ed with guild/dm). Lobby participants read the party thread.
drop policy if exists "chat_messages: lobby read" on chat_messages;
create policy "chat_messages: lobby read" on chat_messages for select
    using (
        channel_type = 'lobby' and exists (
            select 1 from boss_lobby l
            where l.id = channel_ref::uuid
              and auth.uid() in (l.host_id, l.player_2_id, l.player_3_id)
        )
    );

grant execute on function chat_can_post(text, text) to authenticated;
