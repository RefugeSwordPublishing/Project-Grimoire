-- Project Grimoire, Chat unread summary + per-DM unread (Migration 040)
-- Multiplayer Chat P1 notification layer. Powers the chat pill badge (total unread) and the per-friend
-- unread count in the friends list. "Unread" = messages from others newer than my chat_read_state
-- last_read_at for that channel. Guild + DM only (lobby/general later).

-- Total unread across the caller's guild channel + all DM threads, as one int for the pill badge.
create or replace function chat_unread_summary()
returns int
language sql stable security definer set search_path = public as $$
    select (
        coalesce((
            select count(*) from chat_messages m
            where m.channel_type = 'guild'
              and m.channel_ref::uuid in (select auth_guild_ids())
              and m.sender_id <> auth.uid()
              and m.created_at > coalesce(
                  (select last_read_at from chat_read_state r
                   where r.player_id = auth.uid() and r.channel_type = 'guild' and r.channel_ref = m.channel_ref),
                  'epoch'::timestamptz)
        ), 0)
        +
        coalesce((
            select count(*) from chat_messages m
            join player_friendships f
              on f.id::text = m.channel_ref
             and f.status = 'accepted'
             and auth.uid() in (f.requester_id, f.addressee_id)
            where m.channel_type = 'dm'
              and m.sender_id <> auth.uid()
              and m.created_at > coalesce(
                  (select last_read_at from chat_read_state r
                   where r.player_id = auth.uid() and r.channel_type = 'dm' and r.channel_ref = m.channel_ref),
                  'epoch'::timestamptz)
        ), 0)
    )::int;
$$;

-- Per-friendship DM unread, so the friends list can badge each conversation.
create or replace function chat_dm_unread_all()
returns table (friendship_id uuid, unread int)
language sql stable security definer set search_path = public as $$
    select f.id,
        (select count(*)::int from chat_messages m
         where m.channel_type = 'dm' and m.channel_ref = f.id::text
           and m.sender_id <> auth.uid()
           and m.created_at > coalesce(
               (select last_read_at from chat_read_state r
                where r.player_id = auth.uid() and r.channel_type = 'dm' and r.channel_ref = f.id::text),
               'epoch'::timestamptz))
    from player_friendships f
    where f.status = 'accepted' and auth.uid() in (f.requester_id, f.addressee_id);
$$;

grant execute on function chat_unread_summary()  to authenticated;
grant execute on function chat_dm_unread_all()   to authenticated;
