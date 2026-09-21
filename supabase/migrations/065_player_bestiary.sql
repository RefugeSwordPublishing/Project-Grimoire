-- 065_player_bestiary.sql
-- The Bestiary (retention spec 2/5). One row per (player, enemy) tracking lifetime kills. Thresholds
-- (Observed/Studied/Mastered) are derived client-side from `kills` against the enemy's role, so nothing
-- about which tier is unlocked is stored (a stored flag would be a second source of truth). Kill counts
-- batch-increment through the existing combat flush, never per kill.

create table if not exists player_bestiary (
  player_id   uuid not null references auth.users on delete cascade,
  enemy_id    text not null,
  kills       int  not null default 0,
  first_seen  timestamptz not null default now(),
  primary key (player_id, enemy_id)
);

create index if not exists player_bestiary_player_idx on player_bestiary (player_id);

alter table player_bestiary enable row level security;

drop policy if exists "own rows" on player_bestiary;
create policy "own rows" on player_bestiary
  for all using (auth.uid() = player_id) with check (auth.uid() = player_id);

-- Batch increment: the client folds kills into a small {enemy_id: count} map on the combat flush and calls
-- this once. Increments (not overwrites) so concurrent sessions never lose kills, and stamps first_seen on
-- the first record. SECURITY DEFINER + auth.uid() keeps it own-row safe regardless of the caller.
create or replace function increment_bestiary(p_kills jsonb)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  k record;
begin
  if p_kills is null then return; end if;
  for k in select key as enemy_id, (value)::int as cnt from jsonb_each_text(p_kills) loop
    if k.cnt is null or k.cnt <= 0 then continue; end if;
    insert into player_bestiary (player_id, enemy_id, kills)
    values (auth.uid(), k.enemy_id, k.cnt)
    on conflict (player_id, enemy_id)
      do update set kills = player_bestiary.kills + excluded.kills;
  end loop;
end;
$$;

grant execute on function increment_bestiary(jsonb) to authenticated;
