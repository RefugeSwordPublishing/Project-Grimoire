-- Project Grimoire, Guild roster with usernames (Migration 038)
-- The roster read embedded players(username, combat_level, ...), but players is "own row only" under
-- RLS, so PostgREST nulled every member except the viewer, and those rows fell back to the raw
-- player_id (UUID) and Combat Lv 0. This SECURITY DEFINER RPC returns the full roster with usernames,
-- gated so the caller must be a member of the guild (same pattern chat uses for sender names).

create or replace function guild_roster(p_guild_id uuid)
returns table (player_id uuid, role text, username text, combat_level int, grimoire_equipped text)
language sql stable security definer set search_path = public as $$
    select gm.player_id,
           gm.role,
           p.username,
           coalesce(p.combat_level, 0),
           p.grimoire_equipped
    from guild_members gm
    join players p on p.id = gm.player_id
    where gm.guild_id = p_guild_id
      and p_guild_id in (select auth_guild_ids())   -- caller must belong to this guild
    order by
      case gm.role when 'guild_master' then 0 when 'officer' then 1 else 2 end,
      lower(p.username);
$$;

grant execute on function guild_roster(uuid) to authenticated;
