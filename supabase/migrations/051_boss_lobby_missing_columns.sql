-- Project Grimoire, boss_lobby missing columns repair (Migration 051)
-- Migration 027 defined boss_lobby with ready flags and a boss_max_hp snapshot, but it used
-- `create table if not exists`, and an earlier reduced version of the table already existed, so those
-- columns were never actually added to the live table. The client (BossLobbyManager) writes them:
--   SetReady -> host_ready/p2_ready/p3_ready  (missing -> PATCH 400, Ready button did nothing)
--   StartFight -> boss_max_hp                 (missing -> PATCH 400, status never flipped to active,
--                                              so a solo host could not start the fight)
-- and join_boss_lobby / leave_boss_lobby set p2_ready/p3_ready. Add the columns so the table matches
-- what 027 and the code expect. Defaults match 027 (host ready-by-default, guests not).

alter table boss_lobby add column if not exists host_ready  boolean not null default true;
alter table boss_lobby add column if not exists p2_ready    boolean not null default false;
alter table boss_lobby add column if not exists p3_ready    boolean not null default false;
alter table boss_lobby add column if not exists boss_max_hp integer;
