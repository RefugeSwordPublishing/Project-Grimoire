-- Project Grimoire, auto-recycle setting (Migration 057)
-- material-recycling-spec Stage 4. A per-player toggle + quality threshold: when on, items arriving at or
-- below the chosen quality are recycled automatically. The chooser offers Crude/Rough/Refined only, so the
-- threshold never reaches Pristine+ (a background process must never silently consume valuable gear).
alter table player_settings add column if not exists auto_recycle_enabled     boolean not null default false;
alter table player_settings add column if not exists auto_recycle_max_quality  text    not null default 'crude';
