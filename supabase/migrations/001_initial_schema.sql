-- Project Grimoire — Initial Schema
-- Run this in your Supabase SQL editor to set up the database.

-- Players
create table if not exists players (
    id uuid primary key default gen_random_uuid(),
    device_id text unique not null,
    display_name text not null default 'Traveller',
    silver_marks bigint not null default 500,
    gold_marks bigint not null default 0,
    str int not null default 1,
    dex int not null default 1,
    vit int not null default 1,
    int_stat int not null default 1,
    wil int not null default 1,
    lck int not null default 1,
    cha int not null default 1,
    last_session_at timestamptz,
    created_at timestamptz not null default now()
);

-- Talent progress per player
create table if not exists talent_progress (
    id uuid primary key default gen_random_uuid(),
    player_id uuid not null references players(id) on delete cascade,
    talent_name text not null,
    current_level int not null default 1,
    current_xp bigint not null default 0,
    updated_at timestamptz not null default now(),
    unique(player_id, talent_name)
);

-- Idle queue per player (ordered by slot_index)
create table if not exists idle_queue (
    id uuid primary key default gen_random_uuid(),
    player_id uuid not null references players(id) on delete cascade,
    talent_name text not null,
    slot_index int not null,
    efficiency_multiplier float not null default 1.0,
    unique(player_id, slot_index)
);

-- Inventory
create table if not exists inventory (
    id uuid primary key default gen_random_uuid(),
    player_id uuid not null references players(id) on delete cascade,
    item_name text not null,
    item_type text not null default 'misc',
    quantity int not null default 0,
    unique(player_id, item_name)
);

-- Idle XP rates per talent (used by Edge Function — tuned server-side)
create table if not exists talent_idle_rates (
    talent_name text primary key,
    base_xp_per_hour float not null default 100.0,
    updated_at timestamptz not null default now()
);

-- Seed idle rates for Phase 1 talents
insert into talent_idle_rates (talent_name, base_xp_per_hour) values
    ('Foraging',      120.0),
    ('Trapping',       90.0),
    ('Dredging',      100.0),
    ('Cookery',        80.0),
    ('Alchemy',        80.0),
    ('Marksmanship',  150.0),
    ('Slaying',       130.0)
on conflict (talent_name) do nothing;

-- Helper function for safe silver increment (used by Edge Function)
create or replace function increment_silver_marks(p_player_id uuid, p_amount bigint)
returns void language sql security definer as $$
    update players set silver_marks = silver_marks + p_amount where id = p_player_id;
$$;

-- Enable Row Level Security (open for now — add auth policies later)
alter table players enable row level security;
alter table talent_progress enable row level security;
alter table idle_queue enable row level security;
alter table inventory enable row level security;

-- Temporary open policies (replace with proper auth in Phase 2)
create policy "Allow all for now" on players for all using (true);
create policy "Allow all for now" on talent_progress for all using (true);
create policy "Allow all for now" on idle_queue for all using (true);
create policy "Allow all for now" on inventory for all using (true);
