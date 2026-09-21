-- 067_grimoire_ascension.sql
-- Grimoire Ascension (retention spec 5/5). At Grimoire level 100 a Grimoire may Ascend: it resets to level 1,
-- its ascension_rank increments (cap 10), and it permanently grants +8% XP + +1 to the path primary per rank.
-- NOTHING ELSE resets (Talents, gear, currency, bestiary, expeditions untouched). Total Combat Level floors at
-- peak_level so ascending never removes zone access. Ascension is SERVER-SIDE only (the most exploitable action
-- in the game if client-authoritative): the ascend_grimoire RPC validates level 100 and mutates the row.

alter table player_grimoire_levels add column if not exists ascension_rank int not null default 0;
alter table player_grimoire_levels add column if not exists peak_level     int not null default 0;

-- Backfill: peak is at least the current level for every existing row.
update player_grimoire_levels set peak_level = greatest(peak_level, combat_level)
  where peak_level < combat_level;

create or replace function ascend_grimoire(p_grimoire_id text)
returns table(grimoire_id text, combat_level int, ascension_rank int, peak_level int)
language plpgsql
security definer
set search_path = public
as $$
declare
  r player_grimoire_levels%rowtype;
begin
  select * into r from player_grimoire_levels
    where player_id = auth.uid() and player_grimoire_levels.grimoire_id = p_grimoire_id
    for update;
  if not found then raise exception 'grimoire not owned'; end if;
  if r.combat_level < 100 then raise exception 'grimoire is not at level 100'; end if;
  if r.ascension_rank >= 10 then raise exception 'grimoire is already at max ascension rank'; end if;

  update player_grimoire_levels set
    ascension_rank = r.ascension_rank + 1,
    peak_level     = greatest(r.peak_level, 100),  -- level 100 is the floor this climb banked
    combat_level   = 1,
    combat_xp      = 0,
    updated_at     = now()
  where player_id = auth.uid() and player_grimoire_levels.grimoire_id = p_grimoire_id;

  return query
    select p_grimoire_id, 1, r.ascension_rank + 1, greatest(r.peak_level, 100);
end;
$$;

grant execute on function ascend_grimoire(text) to authenticated;
