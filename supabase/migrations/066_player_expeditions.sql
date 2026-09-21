-- 066_player_expeditions.sql
-- Zone Expeditions (retention spec 4/5). RuneScape-style achievement diaries scoped to zones: 12 templated
-- tasks per zone across Novice/Adept/Expert tiers, each task tracking progress. Tier completion is DERIVED
-- (a tier is done when every task under it has completed_at), never stored. Progress rides the existing quest
-- event rails, so this table just persists per-task progress + completion.

create table if not exists player_expeditions (
  player_id     uuid not null references auth.users on delete cascade,
  zone_id       text not null,
  task_id       text not null,
  progress      int  not null default 0,
  completed_at  timestamptz,
  primary key (player_id, zone_id, task_id)
);

create index if not exists player_expeditions_player_idx on player_expeditions (player_id, zone_id);

alter table player_expeditions enable row level security;

drop policy if exists "own rows" on player_expeditions;
create policy "own rows" on player_expeditions
  for all using (auth.uid() = player_id) with check (auth.uid() = player_id);

-- Batch upsert task progress. p_rows is a json array of {zone_id, task_id, progress, completed}. Sets progress
-- to the reported value (monotonic: never lowers a stored higher progress) and stamps completed_at once, the
-- first time a task reports completed. SECURITY DEFINER + auth.uid() keeps it own-row safe.
create or replace function upsert_expeditions(p_rows jsonb)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  r jsonb;
begin
  if p_rows is null then return; end if;
  for r in select * from jsonb_array_elements(p_rows) loop
    insert into player_expeditions (player_id, zone_id, task_id, progress, completed_at)
    values (
      auth.uid(),
      r->>'zone_id',
      r->>'task_id',
      coalesce((r->>'progress')::int, 0),
      case when coalesce((r->>'completed')::boolean, false) then now() else null end
    )
    on conflict (player_id, zone_id, task_id) do update set
      progress     = greatest(player_expeditions.progress, excluded.progress),
      completed_at = coalesce(player_expeditions.completed_at, excluded.completed_at);
  end loop;
end;
$$;

grant execute on function upsert_expeditions(jsonb) to authenticated;
