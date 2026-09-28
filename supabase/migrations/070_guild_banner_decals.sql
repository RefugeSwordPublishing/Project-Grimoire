-- Project Grimoire: Guild Banner decals (Migration 070)
-- Evolves the banner from a single fixed emblem (069) into up to 3 placed decals, each with its
-- own emblem, metal, position, rotation and scale, stored as a jsonb array. Cloth tincture stays
-- an index. Run AFTER 069_guild_banner.sql.

-- ── Replace the fixed emblem/metal columns with a decals array ───────────────
alter table guilds drop constraint if exists guilds_banner_emblem_range;
alter table guilds drop constraint if exists guilds_banner_metal_range;
alter table guilds drop column if exists banner_emblem;
alter table guilds drop column if exists banner_metal;

-- Decal element shape: {"e":emblem 0-15,"m":metal 0-5,"x":0-1,"y":0-1,"r":deg,"s":scale}
alter table guilds add column if not exists banner_decals jsonb not null default '[]'::jsonb;

-- ── Officer-gated setter (new signature) ────────────────────────────────────
drop function if exists set_guild_banner(uuid, smallint, smallint, smallint);

create or replace function set_guild_banner(
    p_guild_id uuid,
    p_cloth    smallint,
    p_decals   jsonb
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
    elem jsonb;
    e int;
    m int;
begin
    if not exists (
        select 1 from guild_members
        where guild_id = p_guild_id
          and player_id = auth.uid()
          and role in ('officer','guild_master')
    ) then
        raise exception 'Only guild officers can change the banner';
    end if;

    if p_cloth is null or p_cloth < 0 or p_cloth > 11 then
        raise exception 'Cloth selection out of range';
    end if;

    if p_decals is null or jsonb_typeof(p_decals) <> 'array' then
        raise exception 'Decals must be a JSON array';
    end if;
    if jsonb_array_length(p_decals) > 3 then
        raise exception 'At most 3 decals allowed';
    end if;

    for elem in select * from jsonb_array_elements(p_decals) loop
        e := (elem->>'e')::int;
        m := (elem->>'m')::int;
        if e is null or e < 0 or e > 15 or m is null or m < 0 or m > 5 then
            raise exception 'Decal emblem/metal out of range';
        end if;
    end loop;

    update guilds
    set banner_cloth  = p_cloth,
        banner_decals = p_decals
    where id = p_guild_id;
end;
$$;

grant execute on function set_guild_banner(uuid, smallint, jsonb) to authenticated;
