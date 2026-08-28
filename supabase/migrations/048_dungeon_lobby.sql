-- Project Grimoire, Co-op dungeon lobby (Migration 048)
-- Generalizes boss_lobby (migration 027) into a co-op lobby that hosts either a zone-boss fight OR a
-- dungeon run (combat-menu-hub-spec Stage 4). The lobby lifecycle is identical: the same host/guest
-- slots, ready flags, join_boss_lobby / leave_boss_lobby RPCs, participant RLS, and realtime channel
-- serve both. Only the START action differs (StartFight scales boss HP; StartDungeon stamps a shared
-- layout seed). A dungeon lobby carries kind='dungeon', no boss_id, dungeon_id = the host zone id, and
-- run_seed = the host-generated seed so every member crawls the IDENTICAL dungeon.

alter table boss_lobby add column if not exists kind       text not null default 'boss';
alter table boss_lobby add column if not exists dungeon_id text;
alter table boss_lobby add column if not exists run_seed   integer;

-- Dungeon lobbies have no boss, so boss_id must be nullable (it was NOT NULL for boss-only lobbies).
alter table boss_lobby alter column boss_id drop not null;

-- RLS, the join/leave RPCs, and the realtime publication from migration 027 are unchanged: they key on
-- the participant columns (host_id / player_2_id / player_3_id) and never touch boss_id, so they already
-- serve dungeon lobbies without modification.
