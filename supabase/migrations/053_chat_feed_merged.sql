-- Project Grimoire, merged chat feed (Migration 053)
-- chat-dock-panel-spec Stage 1 (8.2). One merged stream across the player's open channels in a single
-- round trip, for the docked chat panel. Returns the channel tags (so the dock can colour/prefix each
-- line) plus the sender username (joined), oldest-first ordering is done client-side. SECURITY INVOKER
-- (default) so per-row RLS still applies: a channel the caller cannot read simply returns nothing.
drop function if exists fetch_chat_feed(jsonb, timestamptz, integer);
create or replace function fetch_chat_feed(p_channels jsonb, p_since timestamptz, p_limit int default 100)
returns table (
  id           uuid,
  channel_type text,
  channel_ref  text,
  sender_id    uuid,
  username     text,
  body         text,
  created_at   timestamptz
)
language sql
stable
as $$
  select c.id, c.channel_type, c.channel_ref, c.sender_id, p.username, c.body, c.created_at
  from chat_messages c
  join lateral jsonb_array_elements(p_channels) ch on true
  left join players p on p.id = c.sender_id
  where c.channel_type = ch->>'type'
    and c.channel_ref  = ch->>'ref'
    and c.created_at    > p_since
  order by c.created_at desc
  limit greatest(1, least(p_limit, 200));
$$;
