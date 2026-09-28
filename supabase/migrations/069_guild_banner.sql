-- Project Grimoire: Guild Banner customization (Migration 069)
-- Adds a customizable heraldic banner to each guild: a cloth tincture, an emblem
-- metal, and one of 16 emblems, all stored as small palette indices (validated
-- server-side, re-themeable without a data migration). Officers/Guild Masters set
-- it through a SECURITY DEFINER RPC, mirroring create_guild() / guild bounties.
-- Run AFTER 003_guild_schema.sql.

-- ── Banner columns on guilds ────────────────────────────────────────────────
-- Indices map to GuildBannerPalette in the client:
--   banner_emblem 0-15  (ui_guild_emblems A1..D4, row-major)
--   banner_cloth  0-11  (12 cloth tinctures)
--   banner_metal  0-5   ( 6 emblem metals)
-- Defaults = Sword / Sable / Iron (a plain, unclaimed-looking banner).
alter table guilds add column if not exists banner_emblem smallint not null default 0;
alter table guilds add column if not exists banner_cloth  smallint not null default 11;
alter table guilds add column if not exists banner_metal  smallint not null default 0;

-- Range guards (idempotent: drop-then-add so re-running is safe).
alter table guilds drop constraint if exists guilds_banner_emblem_range;
alter table guilds drop constraint if exists guilds_banner_cloth_range;
alter table guilds drop constraint if exists guilds_banner_metal_range;
alter table guilds add constraint guilds_banner_emblem_range check (banner_emblem between 0 and 15);
alter table guilds add constraint guilds_banner_cloth_range  check (banner_cloth  between 0 and 11);
alter table guilds add constraint guilds_banner_metal_range  check (banner_metal  between 0 and 5);

-- guilds already has "public read", so every player can SELECT the banner columns
-- to render another guild's heraldry. No new read policy needed.

-- ── Officer-gated setter ────────────────────────────────────────────────────
-- SECURITY DEFINER so it writes past the founder-only UPDATE policy, while still
-- requiring the caller to be an officer or guild_master of that guild. Validates
-- ranges defensively (independent of the CHECK constraints).
create or replace function set_guild_banner(
    p_guild_id uuid,
    p_emblem   smallint,
    p_cloth    smallint,
    p_metal    smallint
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
    if not exists (
        select 1 from guild_members
        where guild_id = p_guild_id
          and player_id = auth.uid()
          and role in ('officer','guild_master')
    ) then
        raise exception 'Only guild officers can change the banner';
    end if;

    if p_emblem is null or p_emblem < 0 or p_emblem > 15
       or p_cloth is null or p_cloth < 0 or p_cloth > 11
       or p_metal is null or p_metal < 0 or p_metal > 5 then
        raise exception 'Banner selection out of range';
    end if;

    update guilds
    set banner_emblem = p_emblem,
        banner_cloth  = p_cloth,
        banner_metal  = p_metal
    where id = p_guild_id;
end;
$$;

grant execute on function set_guild_banner(uuid, smallint, smallint, smallint) to authenticated;
