-- Project Grimoire, Reclaimed Essence (Migration 052)
-- material-recycling-spec Stage 1. Recycling surplus items yields Reclaimed Essence, a bound per-player
-- counter (never tradable, no conversion to SM/GM). It lives alongside the other currencies in
-- player_currency, which is the client-authoritative balance table (the client owns the value and PATCHes
-- it back, like silver_marks/gold_marks).
alter table player_currency add column if not exists reclaimed_essence int not null default 0;
