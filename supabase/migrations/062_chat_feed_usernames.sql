-- Bug #84: chat messages from other users showed no name.
--
-- fetch_chat_feed left-joins players to get the sender's username, but the function runs with the
-- CALLER's privileges and players RLS is own-row-only, so every other sender's username came back NULL.
-- We deliberately do NOT make fetch_chat_feed SECURITY DEFINER: that would bypass the chat_messages
-- per-channel read policies (dm/general/guild/lobby) and let a caller read any channel. Instead, a tiny
-- SECURITY DEFINER helper resolves just the username; message-row access stays under the caller's RLS.

create or replace function public.chat_username(p_id uuid)
returns text
language sql
stable
security definer
set search_path = public
as $$
  select username from players where id = p_id;
$$;

grant execute on function public.chat_username(uuid) to authenticated;

-- Recreate the feed with the username resolved via the helper (message rows still gated by the caller's
-- chat_messages RLS, unchanged). Signature is identical, so the client (ChatManager) needs no change.
create or replace function public.fetch_chat_feed(p_channels jsonb, p_since timestamptz, p_limit integer default 100)
returns table(id uuid, channel_type text, channel_ref text, sender_id uuid, username text, body text, created_at timestamptz)
language sql
stable
as $$
  select c.id, c.channel_type, c.channel_ref, c.sender_id,
         public.chat_username(c.sender_id) as username,
         c.body, c.created_at
  from chat_messages c
  join lateral jsonb_array_elements(p_channels) ch on true
  where c.channel_type = ch->>'type'
    and c.channel_ref  = ch->>'ref'
    and c.created_at    > p_since
  order by c.created_at desc
  limit greatest(1, least(p_limit, 200));
$$;
