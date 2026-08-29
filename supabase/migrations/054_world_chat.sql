-- Project Grimoire, World (general) chat (Migration 054)
-- chat-dock-panel-spec Stage 2. Un-defers the general/World channel: a single full-server room
-- (channel_ref 'global'). Any authenticated player may read and post. send_chat_message already enforces
-- the 500-char cap and the 5-msgs-per-10s rate limit (the spam guard the spec requires), and block
-- filtering is client-side (spec 6.2), so no per-row block join on the hottest table.

-- Read: any authenticated player sees World.
drop policy if exists "chat_messages: general read" on chat_messages;
create policy "chat_messages: general read" on chat_messages for select
    using (channel_type = 'general' and auth.uid() is not null);

-- Post: allow general for authenticated players (send_chat_message is SECURITY DEFINER and gates on this).
create or replace function chat_can_post(p_type text, p_ref text)
returns boolean language plpgsql stable security definer set search_path to 'public' as $$
begin
    if p_type = 'guild' then
        return p_ref::uuid in (select auth_guild_ids());
    elsif p_type = 'dm' then
        return exists (select 1 from player_friendships f
            where f.id = p_ref::uuid and f.status = 'accepted'
              and auth.uid() in (f.requester_id, f.addressee_id));
    elsif p_type = 'lobby' then
        return exists (select 1 from boss_lobby l
            where l.id = p_ref::uuid and auth.uid() in (l.host_id, l.player_2_id, l.player_3_id));
    elsif p_type = 'general' then
        return auth.uid() is not null;  -- full-server room; may shard on p_ref later
    end if;
    return false;
end;
$$;
