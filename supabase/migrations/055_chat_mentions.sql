-- Project Grimoire, @username mentions (Migration 055)
-- chat-dock-panel-spec Stage 3. When a message contains @name(s), record who was mentioned so the
-- mentioned player can be notified (pip + toast, polled). Detection/resolution happens server-side inside
-- send_chat_message (case-insensitive, unresolved names are just ignored, spec 7.1), so the client cannot
-- fake a mention. chat_mention_count powers the poll.

create table if not exists chat_mentions (
    message_id          uuid not null references chat_messages(id) on delete cascade,
    mentioned_player_id uuid not null references players(id) on delete cascade,
    created_at          timestamptz not null default now(),
    primary key (message_id, mentioned_player_id)
);
create index if not exists chat_mentions_player_idx on chat_mentions (mentioned_player_id, created_at desc);

alter table chat_mentions enable row level security;
drop policy if exists "chat_mentions: self read" on chat_mentions;
create policy "chat_mentions: self read" on chat_mentions for select using (mentioned_player_id = auth.uid());

-- send_chat_message + mention extraction (rebuilt from the live definition, unchanged except the mention
-- insert after the message row is created).
create or replace function send_chat_message(p_channel_type text, p_channel_ref text, p_body text)
returns chat_messages language plpgsql security definer set search_path to 'public' as $$
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

    -- Resolve @names to players and record mentions (unresolved names simply match nothing).
    insert into chat_mentions (message_id, mentioned_player_id)
        select msg.id, p.id
        from (select distinct lower(m[1]) as uname
              from regexp_matches(p_body, '@([A-Za-z0-9_]{3,16})', 'g') m) names
        join players p on lower(p.username) = names.uname
        on conflict do nothing;

    return msg;
end;
$$;

create or replace function chat_mention_count(p_since timestamptz)
returns int language sql stable security definer set search_path to 'public' as $$
    select count(*)::int
    from chat_mentions m
    join chat_messages c on c.id = m.message_id
    where m.mentioned_player_id = auth.uid() and c.created_at > p_since;
$$;
