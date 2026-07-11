-- Project Grimoire — Restore guild_members FKs to players (Migration 012)
-- Migration 002's `drop table players cascade` dropped the foreign keys from
-- guild_members, which broke PostgREST embeds like guild_members -> players(username)
-- (PGRST200). Re-add them so roster username lookups resolve.

alter table guild_members
    drop constraint if exists guild_members_player_id_fkey,
    add  constraint guild_members_player_id_fkey
         foreign key (player_id) references players(id) on delete cascade;

alter table guild_members
    drop constraint if exists guild_members_guild_id_fkey,
    add  constraint guild_members_guild_id_fkey
         foreign key (guild_id) references guilds(id) on delete cascade;
