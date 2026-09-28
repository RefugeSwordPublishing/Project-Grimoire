-- Project Grimoire: Player chat badge (Migration 072)
-- A player may display ONE entitlement emblem (early_access / creator / supporter) as a badge next
-- to their name in chat. players.badge holds the chosen entitlement key; a trigger guarantees it can
-- only ever be an entitlement the player actually holds, on any write path. The chat feed resolves it
-- through a SECURITY DEFINER helper (players is own-row-only), same pattern as chat_username.
-- Run AFTER 071_guild_banner_entitlements.sql.

alter table players add column if not exists badge text;

-- Hard guard: badge must be null/empty or an entitlement the player holds (blocks spoofed direct writes).
create or replace function validate_player_badge()
returns trigger language plpgsql as $$
begin
    if new.badge is not null and new.badge <> '' then
        if not exists (
            select 1 from player_entitlements
            where player_id = new.id and entitlement = new.badge
        ) then
            raise exception 'Badge % is not an entitlement you hold', new.badge;
        end if;
    end if;
    return new;
end;
$$;

drop trigger if exists trg_validate_player_badge on players;
create trigger trg_validate_player_badge
    before insert or update of badge on players
    for each row execute function validate_player_badge();

-- Player sets/clears their own badge (empty/null clears). SECURITY DEFINER for a clean single call;
-- the trigger still enforces entitlement ownership.
create or replace function set_player_badge(p_badge text)
returns void language plpgsql security definer set search_path = public as $$
begin
    update players
    set badge = nullif(p_badge, '')
    where id = auth.uid();
end;
$$;

grant execute on function set_player_badge(text) to authenticated;

-- Resolve another player's badge for chat display (players RLS is own-row-only).
create or replace function chat_badge(p_id uuid)
returns text language sql stable security definer set search_path = public as $$
    select badge from players where id = p_id;
$$;

grant execute on function chat_badge(uuid) to authenticated;

-- Extend the chat feed with the sender's badge (signature changes, so drop + recreate). Message rows
-- stay under the caller's chat_messages RLS; only username/badge use the definer helpers.
drop function if exists public.fetch_chat_feed(jsonb, timestamptz, integer);

create function public.fetch_chat_feed(p_channels jsonb, p_since timestamptz, p_limit integer default 100)
returns table(id uuid, channel_type text, channel_ref text, sender_id uuid,
              username text, badge text, body text, created_at timestamptz)
language sql stable as $$
    select c.id, c.channel_type, c.channel_ref, c.sender_id,
           public.chat_username(c.sender_id) as username,
           public.chat_badge(c.sender_id)    as badge,
           c.body, c.created_at
    from chat_messages c
    join lateral jsonb_array_elements(p_channels) ch on true
    where c.channel_type = ch->>'type'
      and c.channel_ref  = ch->>'ref'
      and c.created_at    > p_since
    order by c.created_at desc
    limit greatest(1, least(p_limit, 200));
$$;

grant execute on function public.fetch_chat_feed(jsonb, timestamptz, integer) to authenticated;
