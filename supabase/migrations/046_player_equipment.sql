-- Project Grimoire, Migration 046: server-backed equipped gear
--
-- Equipped gear + tools were persisted ONLY in PlayerPrefs (device-local), and equipping REMOVES the
-- item from the server inventory. So any prefs loss (reinstall / new device) permanently lost worn gear
-- while carried inventory survived (the "gear wiped, inventory intact" bug). This stores the equipped set
-- server-side so it follows the account. One JSON blob per player: { gear:[{slot,item,q}], tools:[{talent,item,q}] }.

create table if not exists player_equipment (
    player_id  uuid primary key references players(id) on delete cascade,
    data       jsonb not null default '{}'::jsonb,
    updated_at timestamptz not null default now()
);

alter table player_equipment enable row level security;

create policy "player_equipment: own row"
    on player_equipment for all
    using (auth.uid() = player_id)
    with check (auth.uid() = player_id);

-- Upsert helper so the client can write with a single call (player_id is the PK; PostgREST upsert needs
-- extra headers the client's Post() doesn't set). SECURITY DEFINER but scoped to auth.uid(), so a player
-- can only ever write their own row.
create or replace function upsert_player_equipment(p_data jsonb)
returns void language plpgsql security definer set search_path = public as $$
begin
    if auth.uid() is null then raise exception 'not authenticated'; end if;
    insert into player_equipment (player_id, data, updated_at)
    values (auth.uid(), coalesce(p_data, '{}'::jsonb), now())
    on conflict (player_id) do update set data = excluded.data, updated_at = now();
end; $$;

grant execute on function upsert_player_equipment(jsonb) to anon, authenticated;
