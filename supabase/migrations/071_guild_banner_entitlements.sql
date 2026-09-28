-- Project Grimoire: Guild Banner special-emblem entitlements (Migration 071)
-- Adds exclusive, entitlement-gated guild emblems (Early Access / Creator / Supporter). The art
-- lives at emblem indices 16/17/18; a decal may only use one if the OFFICER applying it holds the
-- matching player entitlement. Enforced inside set_guild_banner so it cannot be spoofed client-side.
-- Run AFTER 070_guild_banner_decals.sql.

-- ── Player entitlements (admin/service-granted; never client-writable) ───────
create table if not exists player_entitlements (
    player_id   uuid not null references players(id) on delete cascade,
    entitlement text not null,               -- 'early_access' | 'creator' | 'supporter' | ...
    granted_at  timestamptz not null default now(),
    primary key (player_id, entitlement)
);

alter table player_entitlements enable row level security;
drop policy if exists "entitlements: read own" on player_entitlements;
create policy "entitlements: read own"
    on player_entitlements for select
    using (auth.uid() = player_id);
-- No insert/update/delete policy: grants happen via the service role key (bypasses RLS) only.

-- ── Special-emblem -> required entitlement map (single source of truth) ──────
create or replace function banner_emblem_entitlement(p_emblem int)
returns text language sql immutable as $$
    select case p_emblem
        when 16 then 'early_access'
        when 17 then 'creator'
        when 18 then 'supporter'
        else null
    end;
$$;

-- ── set_guild_banner: extend emblem range to 0-18 + gate the restricted ones ─
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
    req text;
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
        if e is null or e < 0 or e > 18 or m is null or m < 0 or m > 5 then
            raise exception 'Decal emblem/metal out of range';
        end if;
        req := banner_emblem_entitlement(e);
        if req is not null and not exists (
            select 1 from player_entitlements
            where player_id = auth.uid() and entitlement = req
        ) then
            raise exception 'Emblem requires the % entitlement', req;
        end if;
    end loop;

    update guilds
    set banner_cloth  = p_cloth,
        banner_decals = p_decals
    where id = p_guild_id;
end;
$$;

grant execute on function set_guild_banner(uuid, smallint, jsonb) to authenticated;
grant execute on function banner_emblem_entitlement(int) to authenticated;
