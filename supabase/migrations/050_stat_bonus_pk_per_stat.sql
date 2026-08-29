-- Project Grimoire, per-stat milestone bonuses (Migration 050)
-- hp-progression-spec Stage 3 gives every path a VIT milestone ladder. Vanguard now grants two stats at
-- the same Grimoire level (Lv 23 STR + VIT), but player_stat_bonuses' primary key was
-- (player_id, grimoire_id, milestone_level), so a second stat at the same level collided on insert and was
-- silently dropped (409). Add stat_type to the PK so multiple stats per milestone level coexist, while the
-- client's idempotent re-grant (same player/grimoire/level/stat -> 409, ignored) still holds.

alter table player_stat_bonuses drop constraint if exists player_stat_bonuses_pkey;
alter table player_stat_bonuses
    add constraint player_stat_bonuses_pkey primary key (player_id, grimoire_id, milestone_level, stat_type);
