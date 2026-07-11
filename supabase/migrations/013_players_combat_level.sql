-- Project Grimoire — Cached combat level on players (Migration 013)
-- CombatXPManager writes the player's Total Combat Level here on level-up so other
-- players (e.g. the guild roster) can display it without summing player_grimoire_levels.
alter table players add column if not exists combat_level integer not null default 0;
